# mkzip.py OUT.zip SRCDIR item [item...]  -> deterministic zip with directory entries
import sys, os, zipfile
out, root, items = sys.argv[1], sys.argv[2], sys.argv[3:]
paths = []
for it in items:
    p = os.path.join(root, it)
    if os.path.isdir(p):
        for dp, dn, fn in os.walk(p):
            dn.sort()
            rel = os.path.relpath(dp, root).replace(os.sep, '/') + '/'
            paths.append((rel, None))
            for f in sorted(fn):
                paths.append((os.path.relpath(os.path.join(dp, f), root).replace(os.sep, '/'), os.path.join(dp, f)))
    else:
        paths.append((it, p))
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for arc, src in paths:
        if src is None:
            zi = zipfile.ZipInfo(arc, (2026, 11, 12, 12, 0, 0)); zi.external_attr = (0o40755 << 16) | 0x10
            z.writestr(zi, b'')
        else:
            zi = zipfile.ZipInfo(arc, (2026, 11, 12, 12, 0, 0)); zi.compress_type = zipfile.ZIP_DEFLATED
            zi.external_attr = 0o644 << 16
            z.writestr(zi, open(src, 'rb').read())
print('wrote', out, len(paths), 'entries')
