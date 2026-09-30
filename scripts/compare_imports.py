#!/usr/bin/env python3
"""Compare les imports/exports PE des DLL GPTK 3 (runner) et GPTK 4 (DMG). Lecture seule."""
import sys, pefile
OLD = sys.argv[1]  # dossier x86_64-windows du runner GPTK 3
NEW = sys.argv[2]  # dossier x86_64-windows du DMG GPTK 4
DLLS = ["d3d10","d3d11","d3d12","dxgi","nvapi64","nvngx-on-metalfx"]
def imports(p):
    pe = pefile.PE(p, fast_load=True)
    pe.parse_data_directories([pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_IMPORT"], pefile.DIRECTORY_ENTRY["IMAGE_DIRECTORY_ENTRY_EXPORT"]])
    imp = {}
    for e in getattr(pe, "DIRECTORY_ENTRY_IMPORT", []):
        imp[e.dll.decode().lower()] = sorted((i.name.decode() if i.name else f"#{i.ordinal}") for i in e.imports)
    exp = sorted((s.name.decode() if s.name else f"#{s.ordinal}") for s in pe.DIRECTORY_ENTRY_EXPORT.symbols) if hasattr(pe,"DIRECTORY_ENTRY_EXPORT") else []
    return imp, exp, [s.Name.rstrip(b"\0").decode() for s in pe.sections], pe.OPTIONAL_HEADER.MajorSubsystemVersion
for d in DLLS:
    print(f"\n===== {d}.dll")
    try: o = imports(f"{OLD}/{d}.dll")
    except Exception as ex: o = None; print("  GPTK3: absent/illisible:", ex)
    n = imports(f"{NEW}/{d}.dll")
    print("  sections GPTK4:", n[2])
    if o: print("  sections GPTK3:", o[2])
    dlls = sorted(set(n[0]) | (set(o[0]) if o else set()))
    for dll in dlls:
        a = set(o[0].get(dll, [])) if o else set(); b = set(n[0].get(dll, []))
        if a == b: print(f"  {dll}: identiques ({len(b)})"); continue
        print(f"  {dll}: GPTK3={len(a)} GPTK4={len(b)}")
        if b - a: print("     + nouveaux en GPTK4:", sorted(b - a))
        if a - b: print("     - retirés en GPTK4:", sorted(a - b))
    if o: 
        ea, eb = set(o[1]), set(n[1])
        if ea != eb: print("  exports: +", sorted(eb-ea), " -", sorted(ea-eb))
