# Builds OBlood_Dirt_and_Cum.esp (ESL-flagged, master Skyrim.esm only). By That Guy (Coronerra).
# 0.1-0.4 FormIDs are preserved. 0.5 adds four globals, OBDC_TravelQuest, and four Travel packages.
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
def alias(aid, name, flags, forced=None, packs=None):
    s = [sub('ALST', struct.pack('<I', aid)), sub('ALID', z(name)), sub('FNAM', struct.pack('<I', flags))]
    if forced is not None: s.append(sub('ALFR', struct.pack('<I', forced)))
    if packs:
        for p in packs:
            s.append(sub('ALPC', struct.pack('<I', p)))
    s.append(sub('ALED', b''))
    return s

# ----- preserved 0.1 / 0.2 FormIDs -----
MAINQ, MCMQ = OWN | 0x800, OWN | 0x801
G_WASH, G_PROMPT, G_CUM, G_DNB = OWN | 0x802, OWN | 0x803, OWN | 0x804, OWN | 0x805
# ----- new in 0.5 -----
G_NORM, G_NORMSEX, G_NEAR, G_ALLNPC = OWN | 0x806, OWN | 0x807, OWN | 0x808, OWN | 0x809
TRAVELQ = OWN | 0x80A
PACKS = [OWN | 0x80B, OWN | 0x80C, OWN | 0x80D, OWN | 0x80E]
# Travel template in Skyrim.esm (no extra master)
TRAVEL_TMPL = 0x00016FAA

globs = [rec('GLOB', fid, [sub('EDID', z(ed)), sub('FNAM', b'f'), sub('FLTV', struct.pack('<f', val))])
         for ed, fid, val in (
            ('OBDC_WashUpEnabled', G_WASH, 1.0),
            ('OBDC_PromptEnabled', G_PROMPT, 1.0),
            ('OBDC_CumPromptEnabled', G_CUM, 1.0),
            ('OBDC_DnBFound', G_DNB, 0.0),
            ('OBDC_NormBathing', G_NORM, 1.0),
            ('OBDC_NormBathingSex', G_NORMSEX, 1.0),
            ('OBDC_NearbyWater', G_NEAR, 0.0),
            ('OBDC_AllNPCsWashUp', G_ALLNPC, 1.0),
         )]

main_props = [
    pobj('PlayerRef', 0x14), pobj('PlayerAlias', MAINQ, 0),
    pobj('OBDC_WashUpEnabled', G_WASH), pobj('OBDC_PromptEnabled', G_PROMPT),
    pobj('OBDC_CumPromptEnabled', G_CUM), pobj('OBDC_DnBFound', G_DNB),
    pobj('OBDC_NormBathing', G_NORM), pobj('OBDC_NormBathingSex', G_NORMSEX),
    pobj('OBDC_NearbyWater', G_NEAR), pobj('OBDC_AllNPCsWashUp', G_ALLNPC),
    pobj('TravelQuest', TRAVELQ),
    pobj('TravelActor0', TRAVELQ, 0), pobj('TravelDest0', TRAVELQ, 1),
    pobj('TravelActor1', TRAVELQ, 2), pobj('TravelDest1', TRAVELQ, 3),
    pobj('TravelActor2', TRAVELQ, 4), pobj('TravelDest2', TRAVELQ, 5),
    pobj('TravelActor3', TRAVELQ, 6), pobj('TravelDest3', TRAVELQ, 7),
    pobj('ActorTypeNPC', 0x13794),
]
v_main = vmad_quest([script('OBDC_Main', main_props)], [(0, MAINQ, [script('OBDC_PlayerAlias', [pobj('Main', MAINQ)])])])
qmain = rec('QUST', MAINQ, [sub('EDID', z('OBDC_Quest')), sub('VMAD', v_main), sub('FULL', z("O'Blood, Dirt and Cum")),
    sub('DNAM', bytes.fromhex('01003cff0000000000000000')), sub('FLTR', z('OBlood_Dirt_and_Cum\\')), sub('NEXT', b''),
    sub('ANAM', struct.pack('<I', 1))] + alias(0, 'Player', 0, 0x14))
v_mcm = vmad_quest([script('OBDC_MCM', [pobj('Main', MAINQ)])], [(0, MCMQ, [script('SKI_PlayerLoadGameAlias', [])])])
qmcm = rec('QUST', MCMQ, [sub('EDID', z('OBDC_MCMQuest')), sub('VMAD', v_mcm), sub('FULL', z("O'Blood, Dirt and Cum MCM")),
    sub('DNAM', bytes.fromhex('110132ff0000000000000000')), sub('FLTR', z('OBlood_Dirt_and_Cum\\')), sub('NEXT', b''),
    sub('ANAM', struct.pack('<I', 1))] + alias(0, 'PlayerAlias', 0, 0x14))

# TravelQuest: not start-game-enabled (started from script). Priority 70 so the walk package beats sandbox.
# Alias flags: Optional | Allow Reuse | Allow Dead | Allow Reserved = 0x21A (actors)
# Dest flags:  Optional | Allow Reuse | Allow Disabled | Allow Reserved = 0x28A
AF_ACTOR = 0x021A
AF_DEST = 0x028A
v_travel = vmad_quest([], [])
taliases = []
for i in range(4):
    aid_actor = i * 2
    aid_dest = i * 2 + 1
    taliases += alias(aid_actor, f'TravelActor{i}', AF_ACTOR, packs=[PACKS[i]])
    taliases += alias(aid_dest, f'TravelDest{i}', AF_DEST)
qtravel = rec('QUST', TRAVELQ, [
    sub('EDID', z('OBDC_TravelQuest')),
    sub('VMAD', v_travel),
    sub('FULL', z("O'Blood, Dirt and Cum Travel")),
    sub('DNAM', bytes.fromhex('000046ff0000000000000000')),
    sub('FLTR', z('OBlood_Dirt_and_Cum\\')),
    sub('NEXT', b''),
    sub('ANAM', struct.pack('<I', 8)),
] + taliases)

def travel_pack(fid, edid, dest_alias):
    """Vanilla Travel template (0x16FAA): Location + 2 Bools, UNAM slots 0/2/4, XNAM 5.
    PLDT type 8 = Alias (reference). Preferred speed Jog, interruptible by combat, allow swimming."""
    # Must Complete | Unlock doors at start | Preferred Speed | Allow Swimming
    genflags = 0x04 | 0x40 | 0x2000 | 0x40000
    pkdt = struct.pack('<IBBBB I'.replace(' ', ''), genflags, 18, 0, 1, 0x65, 0x0000FEFF)
    psdt = bytes.fromhex('ffff00ffff00000000000000')
    # empty begin/end/change fragments
    frag = sub('INAM', struct.pack('<I', 0)) + sub('PDTO', b'\x00' * 8)
    return rec('PACK', fid, [
        sub('EDID', z(edid)),
        sub('PKDT', pkdt),
        sub('PSDT', psdt),
        sub('QNAM', struct.pack('<I', TRAVELQ)),
        sub('PKCU', struct.pack('<III', 3, TRAVEL_TMPL, 3)),
        sub('ANAM', z('Location')),
        sub('PLDT', struct.pack('<iIi', 8, dest_alias, 100)),
        sub('ANAM', z('Bool')),
        sub('CNAM', b'\x00'),
        sub('ANAM', z('Bool')),
        sub('CNAM', b'\x00'),
        sub('UNAM', bytes([0])),
        sub('UNAM', bytes([2])),
        sub('UNAM', bytes([4])),
        sub('XNAM', bytes([5])),
        sub('POBA', b''), *([frag] if False else []),
        sub('POBA', b''),  # will duplicate if I'm not careful - build below without this
    ])

# Build packages without the accidental duplicate; rewrite cleanly:
def travel_pack(fid, edid, dest_alias):
    genflags = 0x04 | 0x40 | 0x2000 | 0x40000
    pkdt = struct.pack('<I' + 'BBBB' + 'I', genflags, 18, 0, 1, 0x65, 0x0000FEFF)
    psdt = bytes.fromhex('ffff00ffff00000000000000')
    frag = lambda: [sub('INAM', struct.pack('<I', 0)), sub('PDTO', b'\x00' * 8)]
    subs_ = [
        sub('EDID', z(edid)),
        sub('PKDT', pkdt),
        sub('PSDT', psdt),
        sub('QNAM', struct.pack('<I', TRAVELQ)),
        sub('PKCU', struct.pack('<III', 3, TRAVEL_TMPL, 3)),
        sub('ANAM', z('Location')),
        sub('PLDT', struct.pack('<iIi', 8, dest_alias, 100)),
        sub('ANAM', z('Bool')),
        sub('CNAM', b'\x00'),
        sub('ANAM', z('Bool')),
        sub('CNAM', b'\x00'),
        sub('UNAM', bytes([0])),
        sub('UNAM', bytes([2])),
        sub('UNAM', bytes([4])),
        sub('XNAM', bytes([5])),
        sub('POBA', b''), *frag(),
        sub('POEA', b''), *frag(),
        sub('POCA', b''), *frag(),
    ]
    return rec('PACK', fid, subs_)

packs = [travel_pack(PACKS[i], f'OBDC_TravelPack{i}', i * 2 + 1) for i in range(4)]

nrec = 3 + len(globs) + len(packs)  # 3 QUST + 8 GLOB + 4 PACK = 15
hdr = rec('TES4', 0, [sub('HEDR', struct.pack('<fII', 1.71, nrec, 0x80F)), sub('CNAM', z('That Guy (Coronerra)')),
    sub('SNAM', z("O'Blood, Dirt and Cum v0.5. SkyrimNet companion for Dirt and Blood and/or OCum (each optional). By That Guy (Coronerra).")),
    sub('MAST', z('Skyrim.esm')), sub('DATA', struct.pack('<Q', 0))], flags=0x200)
out = sys.argv[1] if len(sys.argv) > 1 else 'OBlood_Dirt_and_Cum.esp'
open(out, 'wb').write(hdr + grup('QUST', [qmain, qmcm, qtravel]) + grup('GLOB', globs) + grup('PACK', packs))
print('wrote', out, 'records', nrec)
