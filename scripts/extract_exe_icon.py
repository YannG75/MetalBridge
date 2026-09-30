#!/usr/bin/env python3
"""Extrait la plus grande icône d'un .exe Windows (ressources RT_GROUP_ICON) vers un .ico. Usage : extract_exe_icon.py app.exe out.ico"""
import struct, sys, pefile
pe = pefile.PE(sys.argv[1]); res = {}
for t in pe.DIRECTORY_ENTRY_RESOURCE.entries:
    if t.id in (3, 14):
        for n in t.directory.entries:
            for l in n.directory.entries:
                res.setdefault(t.id, {})[n.id] = pe.get_data(l.data.struct.OffsetToData, l.data.struct.Size)
g = res[14][sorted(res[14])[0]]
cnt = struct.unpack("<HHH", g[:6])[2]
entries = [struct.unpack("<BBBBHHIH", g[6 + i * 14:20 + i * 14]) for i in range(cnt)]
out, blob, off = struct.pack("<HHH", 0, 1, cnt), b"", 6 + 16 * cnt
for w, h, cc, r, pl, bc, sz, iid in entries:
    d = res[3][iid]
    out += struct.pack("<BBBBHHII", w, h, cc, r, pl, bc, len(d), off + len(blob)); blob += d
open(sys.argv[2], "wb").write(out + blob)
