# Changelog

## 0.5.2
- Walk-to-water tries harder at rimmed pools and tubs: if an NPC reaches the edge and stalls for a few seconds (a rim, a ladder, or steep stairs), it checks chest-height line of sight over the water and attempts a short step into the verified wet point; if the navmesh snapped to the wrong side of a wall, it re-targets the opposite side.
- Interior cell water is treated as a pool or tub rather than open water, so sunken indoor basins without navmesh at the bottom are handled as rimmed pools.
- **Custom player homes, rimmed tubs, and walled or ladder-entry pools may or may not work.** Rivers, streams, lakes, and other open bodies of water work reliably. Indoor or custom basins depend on each home's navmesh and water setup; NPCs may stop at the edge if Skyrim's pathfinding cannot navigate stairs, ladders, or walls around the basin.
- Save-safe over 0.4 and earlier 0.5 test builds (all 0.4 FormIDs preserved).

## 0.5.1
- NPCs only skip walking and bathe in place when they are physically standing in water (swimming, in water, or wading). A Dirt and Blood waterfall static across a room, or water-required being off, no longer counts as "already in water."
- When **Walk to nearby water** is on and their feet are dry, real water activators and tighter indoor/outdoor cell-water rings are searched first; a waterfall static is only used if no real wet pool or tub is found. Bathing starts as soon as their feet actually hit water.
- `OBloodDirtCum.log` now records the exact walk vs. in-place decision.

## 0.5
- **Walk to nearby water.** If someone chooses WashUp and is not already standing in water, they walk to the nearest real water within a set range (default 2000 units) and then bathe. Fake decorative water (shader meshes with no WaterType) is ignored. Real indoor tubs and pools (water activators) are found first; outdoor streams, rivers and lakes are sampled on demand when nothing closer is found. The MCM toggle **Walk to nearby water** is ON by default. Turning it off disables walking, the cell water scan, and the nearby-water prompt text; WashUp then needs the bather to already be in water, as in 0.4.
- **Water search range** slider (500–3500 units, default 2000).
- **Non-followers can WashUp** (ON by default). Nearby adult NPCs who are not your followers can also choose WashUp (for example at a communal pool). Turn it off to keep WashUp to followers only.
- **Bathing customs** for SkyrimNet, in `prompts/submodules/user_final_instructions/0503_obdc_bathing_norms.prompt` (so it reaches dialogue and thoughts, and sits just after OStimNet's sex instructions). Two MCM toggles, both ON by default, and both silent when **Hygiene in character bios** is off:
  - **Open and communal bathing is normal** — public, open-air and communal bathing is ordinary custom, not shocking or immodest.
  - **Intimacy in bathing spots is normal** — intimacy in those same places is socially accepted as normal.
- A one-shot nearby-water check on load, location change and a new player cell (no idle polling) sets `OBDC_NearbyWater` (2 = pool or tub, 1 = open water, 0 = none) so the prompt can mention water that is actually there. Cleared when **Walk to nearby water** is turned off.
- New plugin records (all 0.1–0.4 FormIDs kept): globals `OBDC_NormBathing`, `OBDC_NormBathingSex`, `OBDC_NearbyWater`, `OBDC_AllNPCsWashUp`; quest `OBDC_TravelQuest` (started from script, not Start Game Enabled, so existing saves are not asked to grow aliases on `OBDC_Quest`); four Travel packages. ESL flag and `Skyrim.esm` as the only master unchanged. Update in place from 0.1–0.4.

## 0.4
- **Own log file** for troubleshooting: `Data/SKSE/Plugins/OBloodDirtCum.log` (MO2: `overwrite/SKSE/Plugins`). A header every game load, what was found (Dirt and Blood and its forms, Malignis patch, OCum, Tull, Liquid Pack, OStimNet, SkyrimNet, WadeInWater, powerofthree, RaceMenu, settings.json), the settings, and how the cum fact is decided (OStimNet's description first, this mod's short fact, or off). Then baths, washes, cum narration (and why one was skipped), WashUp accepted / refused / ignored, narrations, tier changes.
- MCM > Other: **Write log file** (ON by default). Restarts after 10 game loads, at most 2000 lines per load. PapyrusUtil is checked first; without it nothing is written.
- Scripts and docs only. Plugin, records, FormIDs and the SkyrimNet pack are unchanged; update in place from 0.1-0.3.

## 0.3
- **Works around OStimNet's OCum prompts** (OStimNet itself is not changed). The cum fact moved out of `## Hygiene` into its own submodule, `0402_obdc_cum_covering.prompt`:
  - If OStimNet (`TT_OStimNet.esp`) is loaded and its `ocum_description` has text for the character, this mod prints nothing; OStimNet's details stand.
  - If that description is empty, or OStimNet is not installed, but OCum still marks the character (faction or effect: meshes, 3D not loaded, and so on), this mod prints "You have cum on you." / "<name> has cum on them." under `### Cum covering`, the same heading OStimNet uses, so OStimNet's reaction rule still applies.
  - OStimNet's decorator is only called when `TT_OStimNet.esp` is loaded. No reaction instructions added; still facts-only.
- `0172_obdc_hygiene.prompt` now holds only dirt, blood and washing.
- Version strings 0.3 (MCM, plugin description, manifest, FOMOD). No new plugin records; update in place from 0.1 or 0.2.

## 0.2
- Dirt and Blood and OCum are now **each optional**, detected when the game loads. At least one is needed.
  - OCum only: the hygiene prompt tells SkyrimNet who "has cum on them". Nothing is registered in Papyrus (no alias events, no updates, no WashUp).
  - Dirt and Blood only: the 0.1 Dirt and Blood companion; every OCum part stays silent.
  - Both: everything, as in 0.1.
  - Neither: loads safely, does nothing, MCM says both are missing.
- WashUp is only offered with Dirt and Blood: new global `OBDC_DnBFound` (set on every load) in its eligibility rule, and the action is unregistered without Dirt and Blood.
- SkyrimNet manifest no longer lists Dirt and Blood as a required mod.
- MCM shows Dirt and Blood found / not installed, OCum found / not installed and the mode, and greys out settings whose mod is missing.
- Same plugin `OBlood_Dirt_and_Cum.esp`; all 0.1 records kept, one global added. Update in place.

## Repository
- Cover art added at `docs/OBlood_Dirt_and_Cum_cover.jpg`. The v0.1 install zip is unchanged.

## 0.1 (first release)
- SkyrimNet companion for Dirt and Blood - Dynamic Visuals: facts-only hygiene prompt, state and bath events, bath memories with onlookers, WashUp action for followers (follows Dirt and Blood's live soap and water rules), MCM, settings.json, installer flag for Malignis Animations.
- Optional OCum support (soft-detected, no master): any real Dirt and Blood bath (your own, WashUp, Dirt and Blood's "clean an NPC" spell, others seen in its bathing list) checks for cum at the start, narrates a short line a few seconds in, then washes it off mid-bath with OCum's own clean, even if OCum's water clean is off. Tull Animated Creampie / Liquid Pack items are removed as a backup, and again after Dirt and Blood's auto-dress.
- Optional "has cum on them" fact in the hygiene prompt while OCum marks a character.
- New mod event `OBDC_CumWashed`.
