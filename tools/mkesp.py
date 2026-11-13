# Builds OBlood_Dirt_and_Cum.esp (ESL-flagged, master Skyrim.esm only). By That Guy (Coronerra).
import struct, sys
OWN = 0x01000000
def sub(t, b): return t.encode() + struct.pack('<H', len(b)) + b
def z(s): return s.encode() + b'\0'
def rec(t, fid, subs_, flags=0):
    d = b''.join(subs_)
    return t.encode() + struct.pack('<IIIIHH', len(d), flags, fid, 0, 44, 0) + d
def grup(label, rs):
    body = b''.join(rs)
    return b'GRUP' + struct.pack('<I', 24 + len(body)) + label.encode() + struct.pack('<IIHH', 0, 0, 0, 0) + body
def ws(s): b = s.encode(); return struct.pack('<H', len(b)) + b
def pobj(name, fid, alias=-1): return ws(name) + bytes([1, 1]) + struct.pack('<HhI', 0, alias, fid)
def script(name, props): return ws(name) + b'\0' + struct.pack('<H', len(props)) + b''.join(props)
def vmad_quest(scripts, aliases):
    b = struct.pack('<hhH', 5, 2, len(scripts)) + b''.join(scripts)
    b += b'\x02' + struct.pack('<H', 0) + ws('') + struct.pack('<H', len(aliases))
    for aid, qfid, ascripts in aliases:
        b += struct.pack('<HhI', 0, aid, qfid) + struct.pack('<hhH', 5, 2, len(ascripts)) + b''.join(ascripts)
    return b
def alias(aid, name, flags, forced=None):
    s = [sub('ALST', struct.pack('<I', aid)), sub('ALID', z(name)), sub('FNAM', struct.pack('<I', flags))]
    if forced is not None: s.append(sub('ALFR', struct.pack('<I', forced)))
    s.append(sub('ALED', b''))
    return s

MAINQ, MCMQ, G_WASH, G_PROMPT, G_CUM, G_DNB = OWN | 0x800, OWN | 0x801, OWN | 0x802, OWN | 0x803, OWN | 0x804, OWN | 0x805
# 0.1 records keep their FormIDs; 0.2 adds OBDC_DnBFound (set by the script on every load)
globs = [rec('GLOB', fid, [sub('EDID', z(ed)), sub('FNAM', b'f'), sub('FLTV', struct.pack('<f', val))])
         for ed, fid, val in (('OBDC_WashUpEnabled', G_WASH, 1.0), ('OBDC_PromptEnabled', G_PROMPT, 1.0), ('OBDC_CumPromptEnabled', G_CUM, 1.0), ('OBDC_DnBFound', G_DNB, 0.0))]
main_props = [pobj('PlayerRef', 0x14), pobj('PlayerAlias', MAINQ, 0),
              pobj('OBDC_WashUpEnabled', G_WASH), pobj('OBDC_PromptEnabled', G_PROMPT), pobj('OBDC_CumPromptEnabled', G_CUM), pobj('OBDC_DnBFound', G_DNB),
              pobj('ActorTypeNPC', 0x13794)]
v_main = vmad_quest([script('OBDC_Main', main_props)], [(0, MAINQ, [script('OBDC_PlayerAlias', [pobj('Main', MAINQ)])])])
qmain = rec('QUST', MAINQ, [sub('EDID', z('OBDC_Quest')), sub('VMAD', v_main), sub('FULL', z("O'Blood, Dirt and Cum")),
    sub('DNAM', bytes.fromhex('01003cff0000000000000000')), sub('FLTR', z('OBlood_Dirt_and_Cum\\')), sub('NEXT', b''),
    sub('ANAM', struct.pack('<I', 1))] + alias(0, 'Player', 0, 0x14))
v_mcm = vmad_quest([script('OBDC_MCM', [pobj('Main', MAINQ)])], [(0, MCMQ, [script('SKI_PlayerLoadGameAlias', [])])])
qmcm = rec('QUST', MCMQ, [sub('EDID', z('OBDC_MCMQuest')), sub('VMAD', v_mcm), sub('FULL', z("O'Blood, Dirt and Cum MCM")),
    sub('DNAM', bytes.fromhex('110132ff0000000000000000')), sub('FLTR', z('OBlood_Dirt_and_Cum\\')), sub('NEXT', b''),
    sub('ANAM', struct.pack('<I', 1))] + alias(0, 'PlayerAlias', 0, 0x14))
nrec = 2 + len(globs)
hdr = rec('TES4', 0, [sub('HEDR', struct.pack('<fII', 1.71, nrec, 0x806)), sub('CNAM', z('That Guy (Coronerra)')),
    sub('SNAM', z("O'Blood, Dirt and Cum v0.3. SkyrimNet companion for Dirt and Blood and/or OCum (each optional). By That Guy (Coronerra).")),
    sub('MAST', z('Skyrim.esm')), sub('DATA', struct.pack('<Q', 0))], flags=0x200)
out = sys.argv[1] if len(sys.argv) > 1 else 'OBlood_Dirt_and_Cum.esp'
open(out, 'wb').write(hdr + grup('QUST', [qmain, qmcm]) + grup('GLOB', globs))
print('wrote', out, 'records', nrec)
