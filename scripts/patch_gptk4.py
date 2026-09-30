#!/usr/bin/env python3
"""
Patcheur ciblé des DLL PE de GPTK 4.0b2 pour un Wine 7.7 (runner GPTK 3.0-3).

Contexte (vérifié par désassemblage) : à l'initialisation, chaque DLL GPTK 4 fait
    h = GetModuleHandleW(L"ntdll.dll")
    p = GetProcAddress(h, "__wine_unix_call_dispatcher")   # variable exportée (Wine récent)
    ... NtQueryVirtualMemory(...) ; dispatcher = *(void **)p
Wine 7.7 n'exporte pas cette variable, mais exporte la fonction __wine_unix_call
(même signature : handle, code, args). Le patch minimal est donc :
    1. la chaîne "__wine_unix_call_dispatcher" -> "__wine_unix_call" (occurrence mappée en mémoire)
    2. UNIQUEMENT l'instruction `mov rax,[rsi]` qui déréférence le résultat de ce GetProcAddress
       devient `mov rax,rsi` (la fonction sert directement de dispatcher).

Garde-fous : aucun octet en dehors de ces deux sites n'est modifié ; arrêt (code 2) si le motif
n'est pas exactement celui attendu ; lit la source sans jamais l'écrire ; --dry-run par défaut.
"""
import argparse, hashlib, json, os, re, sys
import pefile, capstone

DLLS = ["d3d10.dll", "d3d11.dll", "d3d12.dll", "dxgi.dll", "nvapi64.dll", "nvngx-on-metalfx.dll"]
OLD = b"__wine_unix_call_dispatcher\x00"
NEW = b"__wine_unix_call\x00".ljust(len(OLD), b"\x00")
OP_OLD, OP_NEW = b"\x48\x8b\x06", b"\x48\x89\xf0"   # mov rax,[rsi] -> mov rax,rsi


class Unexpected(Exception):
    pass


def sha(b): return hashlib.sha256(b).hexdigest()


def import_slots(pe):
    slots = {}
    for e in pe.DIRECTORY_ENTRY_IMPORT:
        for i in e.imports:
            if i.name:
                slots[i.address - pe.OPTIONAL_HEADER.ImageBase] = (e.dll.decode().lower(), i.name.decode())
    return slots


def analyse(name, data):
    """Retourne la liste des modifications [(offset_fichier, ancien, nouveau, description)]."""
    pe = pefile.PE(data=data)
    base = pe.OPTIONAL_HEADER.ImageBase
    slots = import_slots(pe)
    # 1. occurrence(s) mappée(s) de la chaîne
    mapped = []
    for m in re.finditer(re.escape(OLD), data):
        rva = pe.get_rva_from_offset(m.start())
        if rva is not None and pe.get_offset_from_rva(rva) == m.start():
            sec = pe.get_section_by_rva(rva)
            if sec is not None:
                mapped.append((m.start(), rva))
    if len(mapped) != 1:
        raise Unexpected(f"{name}: {len(mapped)} occurrence(s) mappée(s) de la chaîne (attendu 1)")
    str_off, str_rva = mapped[0]
    # 2. l'unique `lea rdx,[rip+x]` qui la référence, précédé d'un appel à GetModuleHandleW
    text = next(s for s in pe.sections if s.Name.startswith(b".text"))
    code, tva = text.get_data(), text.VirtualAddress
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64)
    md.skipdata = True
    insns = list(md.disasm(code, tva))
    refs = []
    for k, ins in enumerate(insns):
        m = re.fullmatch(r"rdx, \[rip ([+-]) (0x[0-9a-f]+)\]", ins.op_str) if ins.mnemonic == "lea" else None
        if m and ins.address + ins.size + (1 if m.group(1) == "+" else -1) * int(m.group(2), 16) == str_rva:
            refs.append(k)
    if len(refs) != 1:
        raise Unexpected(f"{name}: {len(refs)} référence(s) code vers la chaîne (attendu 1)")
    k = refs[0]
    prev = insns[k - 1]
    m = re.fullmatch(r"qword ptr \[rip ([+-]) (0x[0-9a-f]+)\]", prev.op_str) if prev.mnemonic == "call" else None
    if not m or slots.get(prev.address + prev.size + (1 if m.group(1) == "+" else -1) * int(m.group(2), 16)) != ("kernel32.dll", "GetModuleHandleW"):
        raise Unexpected(f"{name}: l'instruction précédant le lea n'est pas call GetModuleHandleW")
    # 3. après `mov rcx,rax ; call GetProcAddress ; test rax,rax ; je ; mov R,rax` -> premier `mov rax,[R]`
    seq = insns[k + 1: k + 5]
    if [i.mnemonic for i in seq[:2]] != ["mov", "call"] or seq[0].op_str != "rcx, rax":
        raise Unexpected(f"{name}: séquence `mov rcx,rax; call` absente après le lea")
    m = re.fullmatch(r"qword ptr \[rip ([+-]) (0x[0-9a-f]+)\]", seq[1].op_str)
    tgt = seq[1].address + seq[1].size + (1 if m.group(1) == "+" else -1) * int(m.group(2), 16) if m else None
    if slots.get(tgt) != ("kernel32.dll", "GetProcAddress"):
        raise Unexpected(f"{name}: l'appel suivant n'est pas GetProcAddress")
    reg, deref = None, []
    for ins in insns[k + 3: k + 40]:
        if ins.mnemonic == "ret":
            break
        if reg is None:
            m = re.fullmatch(r"(r[a-z0-9]+), rax", ins.op_str) if ins.mnemonic == "mov" else None
            if m:
                reg = m.group(1)
            continue
        if ins.mnemonic == "mov" and ins.op_str == f"rax, qword ptr [{reg}]":
            deref.append(ins)
    if reg != "rsi" or len(deref) != 1:
        raise Unexpected(f"{name}: registre={reg}, déréférencements={len(deref)} (attendu rsi / 1)")
    d = deref[0]
    op_off = pe.get_offset_from_rva(d.address)
    if bytes(d.bytes) != OP_OLD or data[op_off:op_off + 3] != OP_OLD:
        raise Unexpected(f"{name}: encodage inattendu {bytes(d.bytes).hex()}")
    return [
        (str_off, OLD, NEW, f"chaîne dispatcher (rva {str_rva:#x})"),
        (op_off, OP_OLD, OP_NEW, f"mov rax,[rsi] -> mov rax,rsi (rva {d.address:#x})"),
    ]


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--src", required=True, help="dossier x86_64-windows du DMG (lecture seule)")
    ap.add_argument("--out", help="dossier de sortie (requis sauf --dry-run)")
    ap.add_argument("--apply", action="store_true", help="écrit les DLL patchées (sinon simulation)")
    a = ap.parse_args()
    if a.apply and not a.out:
        ap.error("--apply exige --out")
    manifest, rc = [], 0
    for n in DLLS:
        p = os.path.join(a.src, n)
        data = open(p, "rb").read()
        try:
            edits = analyse(n, data)
        except Unexpected as e:
            print(f"[STOP] {e}", file=sys.stderr)
            rc = 2
            break
        out = bytearray(data)
        for off, old, new, _ in edits:
            assert out[off:off + len(old)] == old
            out[off:off + len(new)] = new
        changed = sum(1 for x, y in zip(data, out) if x != y)
        assert len(out) == len(data)
        assert changed == sum(sum(1 for x, y in zip(o, nw) if x != y) for _, o, nw, _ in edits)
        pefile.PE(data=bytes(out))  # doit rester un PE valide
        print(f"[OK] {n}: {len(edits)} sites, {changed} octets modifiés, sha256 {sha(data)[:12]} -> {sha(bytes(out))[:12]}")
        for off, _, _, desc in edits:
            print(f"       @{off:#x} {desc}")
        manifest.append({"dll": n, "sha256_before": sha(data), "sha256_after": sha(bytes(out)),
                         "edits": [{"offset": o, "old": ol.hex(), "new": ne.hex(), "what": d} for o, ol, ne, d in edits]})
        if a.apply:
            os.makedirs(a.out, exist_ok=True)
            open(os.path.join(a.out, n), "wb").write(bytes(out))
    if rc == 0 and a.apply:
        json.dump(manifest, open(os.path.join(a.out, "patch-manifest.json"), "w"), indent=2)
        print(f"[✓] {len(manifest)} DLL écrites dans {a.out}")
    elif rc == 0:
        print("[dry-run] rien écrit (utiliser --apply --out DIR)")
    sys.exit(rc)


if __name__ == "__main__":
    main()
