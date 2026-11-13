# Changelog

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
