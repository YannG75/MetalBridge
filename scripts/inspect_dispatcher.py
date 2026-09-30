#!/usr/bin/env python3
"""Localise les usages de __wine_unix_call(_dispatcher) dans une DLL (lecture seule)."""
import sys, pefile, capstone, re
p = sys.argv[1]
data = open(p,"rb").read()
pe = pefile.PE(data=data)
base = pe.OPTIONAL_HEADER.ImageBase
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_64); md.detail = False
print("== ntdll imports:", [(i.name.decode(), hex(i.address)) for e in pe.DIRECTORY_ENTRY_IMPORT if e.dll.lower()==b"ntdll.dll" for i in e.imports])
for m in re.finditer(rb"__wine_unix_call\w*\x00", data):
    off = m.start(); rva = pe.get_rva_from_offset(off)
    print(f"string {m.group(0)!r} file_off={off:#x} rva={hex(rva) if rva is not None else None}")
# refs RIP-relatives vers la chaîne
text = [s for s in pe.sections if s.Name.startswith(b".text")][0]
code = text.get_data(); tva = text.VirtualAddress
targets = {pe.get_rva_from_offset(m.start()) for m in re.finditer(rb"__wine_unix_call\w*\x00", data)} - {None}
for ins in md.disasm(code, tva):
    if ins.op_str.startswith(("rcx, [rip","rdx, [rip","r8, [rip","r9, [rip","rax, [rip")) and ins.mnemonic=="lea":
        m = re.search(r"rip ([+-]) (0x[0-9a-f]+)\]", ins.op_str)
        if m:
            t = ins.address + ins.size + (1 if m.group(1)=="+" else -1)*int(m.group(2),16)
            if t in targets:
                print(f"\nLEA -> string à rva {ins.address:#x}: {ins.mnemonic} {ins.op_str}")
                for c in md.disasm(code[ins.address-tva-0x20: ins.address-tva+0x80], ins.address-0x20):
                    print(f"   {c.address:#x}: {c.bytes.hex():<16} {c.mnemonic} {c.op_str}")
                break
