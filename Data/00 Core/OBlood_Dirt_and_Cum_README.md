![O'Blood, Dirt and Cum](docs/OBlood_Dirt_and_Cum_cover.jpg)

# O'Blood, Dirt and Cum

**v0.5.2** · By **That Guy (Coronerra)** · Skyrim Special Edition · ESL-flagged plugin · Adults only

**[Download v0.5.2](https://github.com/Coronerra/OBlood-Dirt-and-Cum/releases/tag/v0.5.2)** (`OBlood_Dirt_and_Cum_0.5.2.zip`) · [Changelog](CHANGELOG.md) · [Earlier v0.3](https://github.com/Coronerra/OBlood-Dirt-and-Cum/releases/tag/v0.3) · [v0.2](https://github.com/Coronerra/OBlood-Dirt-and-Cum/releases/tag/v0.2) · [v0.1](https://github.com/Coronerra/OBlood-Dirt-and-Cum/releases/tag/v0.1) · License: [MIT for coronerra's work](LICENSE)

A small, standalone **SkyrimNet companion for [Dirt and Blood - Dynamic Visuals](https://www.nexusmods.com/skyrimspecialedition/mods/38886) and/or OCum**. Since 0.2, **Dirt and Blood and OCum are each optional**: the mod looks for both when the game loads and does what it can with what it finds. You need **at least one** of them for it to do anything.

| You have | What it does |
|---|---|
| **Dirt and Blood + OCum** | Everything: dirt, blood and cum facts in SkyrimNet bios, state and bath events, bath memories, WashUp (followers, and nearby NPCs if that toggle is on; they can walk to nearby real water), bathing customs, and a real Dirt and Blood bath washes OCum's cum off (section 6). |
| **Dirt and Blood only** | The Dirt and Blood companion: dirt and blood facts, state and bath events, bath memories, WashUp (with walk-to-water), bathing customs. Every OCum part stays silent. |
| **OCum only** | An OCum to SkyrimNet link: NPCs (and you) are told who "has cum on them" (or, with OStimNet, OStimNet's own detailed description is used; see [OStimNet](#ostimnet-works-alongside-it)). No Papyrus runs for it at all; the bio prompt reads OCum directly. No WashUp, no dirt or blood, no bath wash-off. |
| **Neither** | Nothing. The plugin loads safely and the MCM says both are missing. |

When Dirt and Blood is installed this is a companion for it, **not a replacement**: Dirt and Blood still does all the dirt, blood and bathing; this mod tells SkyrimNet about it.

> **Note on water and player homes.** Rivers, streams, lakes, and other open bodies of water work reliably. **Custom player homes, rimmed tubs, and walled or ladder-entry pools may or may not work**, depending on each home's navmesh and water setup. NPCs may walk up to the edge and stop if Skyrim's pathfinding cannot navigate stairs, ladders, or walls around the basin.

0.5.2 is save-safe over 0.4 and earlier 0.5 test builds (all 0.4 FormIDs preserved). Please report problems on [GitHub Issues](https://github.com/Coronerra/OBlood-Dirt-and-Cum/issues) with `OBloodDirtCum.log` attached (see [Troubleshooting / log files](#troubleshooting--log-files)).

## Contents
1. [What it does](#1-what-it-does)
2. [Requirements](#2-requirements)
3. [Install](#3-install)
4. [Settings](#4-settings)
5. [The WashUp action](#5-the-washup-action)
6. [OCum: washing cum off in a bath](#6-ocum-washing-cum-off-in-a-bath)
7. [For modders: mod events](#7-for-modders-mod-events)
8. [Known limits](#8-known-limits) · [Troubleshooting / log files](#troubleshooting--log-files)
9. [Uninstall](#9-uninstall)
10. [Repository contents and building](#10-repository-contents-and-building)
11. [Credits and permissions](#11-credits-and-permissions)

## 1. What it does
- **Hygiene in character bios.** The prompt `0172_obdc_hygiene.prompt` (a SkyrimNet `character_bio` submodule) states plain facts under `## Hygiene`, such as "Lydia is bloodstained and very dirty." or "You are washing right now." A separate submodule, `0402_obdc_cum_covering.prompt`, adds "Lydia has cum on them." under `### Cum covering` when needed (see [OStimNet](#ostimnet-works-alongside-it)). Neither tells anyone how to react; their personality decides that. A separate `user_final_instructions` submodule, `0503_obdc_bathing_norms.prompt`, states the bathing customs and (when the walk-to-water check has found some) that a pool, tub or open water is nearby.
  - It stays quiet for Clean and Dirt1 (lightly dusty is normal in Skyrim).
  - NPC dirt and blood only appear while the matching Dirt and Blood option is on (NPCs get bloody, bandit dirt, profession dirt). If you turned those off in Dirt and Blood's MCM, NPCs show nothing.
  - The dirt and blood facts appear only with Dirt and Blood installed.
  - The cum fact appears only with OCum installed (with or without Dirt and Blood), only when OStimNet is not already describing it, and only while OCum itself marks the character (its `OCum_HasCumFaction` or its cum effect). It goes away when OCum's own timer cleans them, when they swim (OCum's own water clean) or when they bathe (this mod). Without OCum it is completely silent.
  - There is no header at all when there is nothing to say. Characters read about themselves in the second person and about others in the third person.

### OStimNet works alongside it
[OStimNet](https://github.com/tetherball88/OStimNet) by tetherball88 already has its own OCum prompts: a `### Cum covering` section in character bios with detailed sentences read from OCum's RaceMenu overlays (its `ocum_description` decorator), and a final instruction telling NPCs how to notice anyone with a `### Cum covering` section. This mod does not change OStimNet in any way; it works around it so the two never contradict each other:
- **OStimNet has a description** for the character: this mod prints **no cum line at all**. OStimNet's details stand.
- **OStimNet's description is empty** (or OStimNet is not installed) **but OCum still marks the character** (for example Tull / Liquid Pack / werewolf-shot meshes, or the character's 3D is not loaded so overlays cannot be read): this mod prints one short fact, "You have cum on you." / "<name> has cum on them.", under the **same heading, `### Cum covering`**, so OStimNet's reaction rule still applies. No body-part detail is invented.
- This mod adds **no reaction instructions** of its own. It stays facts-only.
- OStimNet is detected by its plugin `TT_OStimNet.esp`; OStimNet's decorator is only called when that plugin is loaded, so nothing breaks without OStimNet. The heading is the same with or without OStimNet.

- **State events** (Dirt and Blood). When your Dirt and Blood state changes (blood from a hit, dirt over time, rain, a swim), SkyrimNet gets a short-lived event, for example "<your name> is now covered in blood."
- **Narration, only for big moments** (Dirt and Blood). One narration line when a fight leaves you covered or soaked in blood (sent after the fight ends), and one when you finish a bath. At most one every 2 minutes.
- **Bath memories** (Dirt and Blood). When a bath ends, the bather remembers it ("... washed off the dirt, blood and cum." if cum was washed off). Up to 3 adult NPCs who can see the bath also remember it (no forced dialogue, no extra LLM call).
- **WashUp action** for followers (Dirt and Blood, section 5).
- **OCum wash-off** (Dirt and Blood + OCum) during any real Dirt and Blood bath, with a short narration (section 6).
- **Public mod events** for other mods (section 7).

How it stays light:
- Without Dirt and Blood nothing is registered at all (no alias events, no updates); the OCum fact comes from the prompt alone.
- With Dirt and Blood: one player alias, with a po3 event filtered to Dirt and Blood's 9 player tier effects and its soap effect, and a check for the player casting Dirt and Blood's "clean an NPC" spell. There is no global polling.
- Only while a bath is running does it look every 2 seconds whether the bath has ended (and at Dirt and Blood's bathing list for anyone else who started bathing). It stops when the bather leaves Dirt and Blood's bathing list, and gives up after 150 seconds.
- Nothing of Dirt and Blood or OCum is overridden. Neither is a master; their forms are found at run time.
- It reads Dirt and Blood's **live** settings (soap required, water required, NPC options) instead of assuming any defaults. Strip and dress, and whether a swim cleans completely, stay entirely Dirt and Blood's.

## 2. Requirements
Required:
- Skyrim Special Edition. Built and checked for **1.5.97** (Nolvus-friendly). The plugin is a normal ESL with only `Skyrim.esm` as a master and there is no SKSE DLL of ours, so AE should also work with matching builds of the requirements; AE reports are welcome.
- **SkyrimNet** (0.28 or newer)
- SKSE64, Address Library for SKSE Plugins
- powerofthree's Papyrus Extender
- PapyrusUtil SE (settings.json and StorageUtil)
- SkyUI (for the MCM page; everything else works without it)
- **At least one of** the two mods below.

Each optional, detected automatically when the game loads (never masters, no installer option, nothing of theirs is included):
- **Dirt and Blood - Dynamic Visuals 2.37** (`Dirt and Blood - Dynamic Visuals.esp`; the version bundled with Nolvus uses the same file and works): https://www.nexusmods.com/skyrimspecialedition/mods/38886 . Enables the dirt and blood facts, events, bath memories and WashUp.
- **OCum / OCum Ascended 4.1.1** (`OCum.esp`). Enables the cum fact, and with Dirt and Blood also the bath wash-off.

Other optional mods:
- **OStimNet** (tetherball88, `TT_OStimNet.esp`): complementary. If it is installed, its detailed OCum description takes priority and this mod only fills gaps (section 1).
- **Tull Animated Creampie** and **[Predator] Liquid Pack v2**, as used by the OCum Ascended Tull and Liquid Pack add-on and by the OCum Werewolf Shot / OStim Beast Form mesh loads. Their items are taken off in the bath as a backup (section 6).
- **Malignis Animations** (https://www.nexusmods.com/skyrimspecialedition/mods/166293) with its Dirt and Blood patch. If you use it, tick the installer option (section 3).
- **WadeInWater**: standing in its water counts as water for WashUp, the same as in Dirt and Blood.

Not needed: Bathing in Skyrim, BiS SN-SA, SeverActions.

## 3. Install
1. Install `OBlood_Dirt_and_Cum_0.5.2.zip` (updating from 0.1–0.4 or an earlier 0.5 test build: just replace it in your mod manager; same plugin name, all 0.4 FormIDs preserved, earlier settings are kept) with your mod manager. The installer has one option:
   - **"I use Malignis Animations with Dirt and Blood"**: only matters with Dirt and Blood. Tick it only if you use the Malignis Animations bathing patch. It installs no Malignis files; it only sets `"malignis": 1` in `SKSE/Plugins/OBlood_Dirt_and_Cum/settings.json`. The flag is shown in the MCM and used in the log. Bath ends are always detected the same way (wait until the bath is really over, at most 150 s), so leaving it unticked is safe.
2. Enable `OBlood_Dirt_and_Cum.esp`. It is ESL-flagged, with `Skyrim.esm` as its only master. Load order does not matter.
3. **Remove any old hygiene overlay prompt** (Dirt and Blood users). Some setups have an older user overlay, `SKSE/Plugins/SkyrimNet/overlay/prompts/submodules/character_bio/1010_dirtandblood.prompt` (credited to Min), usually in the mod manager's overwrite folder. With both installed, characters get two hygiene blocks. That overlay also checks EditorIDs that do not exist in Dirt and Blood 2.37 and always prints its header. Move it out of the overlay folder or delete it. This mod never touches it for you.
4. Start or load a game. The MCM page "O'Blood, Dirt and Cum" shows whether Dirt and Blood and OCum were found and which mode is running. Settings that need a missing mod are greyed out.

## 4. Settings
MCM page **O'Blood, Dirt and Cum**. The Status block shows Dirt and Blood found / not installed, OCum found / not installed, and the mode. Settings that need a missing mod are greyed out.
- **Hygiene in character bios** (on; needs either mod). Master switch for the bio facts, and for the bathing-customs text. Global `OBDC_PromptEnabled`.
- **Bathing customs** (needs Hygiene in character bios):
  - **Open and communal bathing is normal** (on). Global `OBDC_NormBathing`. Tells SkyrimNet that bathing nude in rivers, streams, lakes, hot springs and communal pools, where others can see, is ordinary Nordic custom, not shocking or immodest. Off: that sentence is not added.
  - **Intimacy in bathing spots is normal** (on). Global `OBDC_NormBathingSex`. Tells SkyrimNet that intimacy and sex in those same places is socially accepted as normal, not scandalous. Off: that sentence is not added.
- Dirt and Blood (greyed out without it):
  - **Short-lived state events** (on).
  - **Narration (big moments only)** (on).
  - **Bath memories** (on).
  - **Onlookers remember baths** (on).
  - **WashUp action** (on). Its own switch, separate from Dirt and Blood's own "NPCs bathe" option.
  - **Walk to nearby water** (on). If WashUp is chosen and the bather is not already standing in water, they walk to the nearest real water in range and then bathe. Detection is mod-independent: real water activators, wadeable cell water, swimming and wading count; fake decorative water is ignored. Also runs a one-shot nearby-water check (on load, location change, or a new cell — no idle polling) so SkyrimNet can be told a pool, tub or open water is nearby. Off: no walking, no cell water scan, and no nearby-water prompt text; WashUp then needs them to already be in water, as in 0.4. Rivers, streams and lakes work reliably; see the note above about custom player homes, rimmed tubs, and walled or ladder-entry pools.
  - **Water search range** (2000 units; 500–3500). How far WashUp and the nearby-water check look. Greyed out when Walk to nearby water is off.
  - **Non-followers can WashUp** (on). Nearby adult NPCs who are not your followers can also choose WashUp. Off: followers only. Greyed out when WashUp itself is off.
  - **Malignis Animations installed** (from the installer). Only changes log text.
- OCum:
  - **Cum in character bios** (on; needs OCum). Global `OBDC_CumPromptEnabled`. Toggles only this mod's short fact; when OStimNet already describes the cum, there is nothing extra to print anyway.
  - **Baths wash cum off** (on; needs Dirt and Blood and OCum).
  - **Narrate the cum in the bath** (on; needs Dirt and Blood and OCum).
- **Debug notifications** (off).
- **Write log file** (on). Writes `Data/SKSE/Plugins/OBloodDirtCum.log` (see [Troubleshooting / log files](#troubleshooting--log-files)).
- **Reload installer settings** reads settings.json again.

`SKSE/Plugins/OBlood_Dirt_and_Cum/settings.json` (PapyrusUtil format) holds the first values: `malignis`, `narration`, `memories`, `bystanders`, `state_events`, `washup`, `cum_wash`, `cum_narration`, `cum_prompt`, `walk_to_water`, `water_search_radius` (units), `norm_bathing`, `norm_bathing_sex`, `all_npcs_washup` (1 = on, 0 = off, except the range). It is read once on the first start and again with "Reload installer settings". After that the MCM values are kept in your save.

## 5. The WashUp action
Needs Dirt and Blood. Without it the action is never offered (its eligibility rule reads the global `OBDC_DnBFound`, which the script sets on every load, and the script also unregisters it).

A follower — and, if **Non-followers can WashUp** is on, a nearby adult NPC — can choose **WashUp** when they want to get clean. They then run Dirt and Blood's own bath, `PlayBatheAnimation`, exactly as Dirt and Blood's own NPC washing does.

SkyrimNet only offers it when Dirt and Blood is found, the WashUp switch is on, the character is not in combat or in a SexLab or OStim scene, has their weapon sheathed, and they are either your follower or **Non-followers can WashUp** is on.

When the action runs, the script checks again and follows Dirt and Blood's **live** rules:
- **Water required**: they only skip the walk and bathe on the spot when they are physically standing in water (swimming, in water, or wading, including WadeInWater). A Dirt and Blood waterfall static across a room is not enough; their feet have to be wet. If **Walk to nearby water** is on and they are not yet in water, they walk to the nearest real water within the search range (a real water activator such as a tub or indoor pool, a wadeable point in a stream, river or lake, or a Dirt and Blood waterfall if no real wet pool or tub is found). Fake decorative water is ignored. Bathing starts as soon as their feet actually hit water. At a rimmed tub or pool they walk to the edge and then try to step in; **custom player homes, rimmed tubs, and walled or ladder-entry pools may or may not work** if Skyrim's pathfinding cannot navigate stairs, ladders, or walls around the basin. The walk is aborted if they enter combat, draw a weapon, start an OStim or SexLab scene, die, or take longer than about 24 seconds.
- **Soap required**: they must carry a soap from Dirt and Blood's soap list. One soap is used up, as with Dirt and Blood's own soap.

If a rule fails, they do not wash. They get a private thought with the reason ("there is no water nearby", "you have no soap"), and the action has a 30-second cooldown.

Turning WashUp off in the MCM removes the action until it is turned back on. After turning it on again, it returns the next time SkyrimNet reloads its actions, or after a save and load.

## 6. OCum: washing cum off in a bath
Needs Dirt and Blood **and** OCum. With OCum alone there is no Dirt and Blood bath, so cum is only cleaned by OCum itself (its timer, or a swim if OCum's water clean is on), and the bio fact follows that.

Why: Dirt and Blood's bath does not fire OCum's swim event, so without this a character could be Dirt and Blood-clean while OCum's cum is still on them. Swimming is left alone; OCum already cleans on a swim if you enabled that in OCum.

Which baths: **every real Dirt and Blood bath**, not only WashUp:
- your own bath (Dirt and Blood's power or soap),
- a follower's WashUp,
- an NPC you wash with Dirt and Blood's "clean an NPC" spell,
- anyone else who shows up in Dirt and Blood's bathing list while a bath is being followed (for example a follower bathing next to you, or another mod calling Dirt and Blood's bath).

What happens, step by step:
1. **At the start of the bath** (before anything is washed) it looks for cum on the bather, cheapest check first: OCum's `OCum_HasCumFaction` (0xF46), any effect with OCum's `OCumAppliedCum` keyword (0xF16) or OCum's own cum effect, a running OCum Werewolf Shot / Beast Form mesh load (StorageUtil `OBF_BL_Set`), Tull / Liquid Pack items in the inventory, and finally OCum's RaceMenu `CumOverlays` textures on the body, face, hands and feet.
2. **A few seconds in**, if cum was found and the bather is you or near you, SkyrimNet gets one short narration that the bather slides the cum between their fingers or rubs it a moment, feeling it, before washing it away. The wording varies and uses his / her / their. At most one every 30 seconds.
3. **A few seconds later, mid-wash** (so you can see it come off), it removes it: dispels `OCumSpell` and calls OCum's own `CleanCumTexturesFromActor`, the same clean OCum's water clean uses. This happens **even if OCum's "clean cum when entering water" option is off**, because a bath is deliberate.
4. **Backup for the mesh items:** the known Tull Animated Creampie (0x807, 0x809, 0x803) and Liquid Pack v2 (0x803, 0x808, 0x804, 0x809, 0xD63) items are taken off and removed. Their own add-on loops would put them back while they run, so their StorageUtil stamps (`OCumTL_Stamp0/1`, `OBF_BL_Stamp`) are moved on first and those loops stop by themselves.
5. **At the end of the bath** the mesh items are removed once more, because Dirt and Blood's auto-dress puts back everything it took off at the start, and that can include them.

If Dirt and Blood's bath animations are off (the bath is over almost at once), the clean happens when the bath ends instead. Timing: about 6 s (narration) and 10 s (clean) into a WashUp, about 2 s and 6 s after your own soap lather, about 4 s and 8 s after another bather is noticed.

## 7. For modders: mod events
Sent with SKSE `ModEvent`. Register with `RegisterForModEvent("<name>", "<your event>")`.
All four need Dirt and Blood (`OBDC_CumWashed` needs OCum too). In OCum-only mode none is sent.
- `OBDC_StateChanged`: `Event X(Form akActor, string asTier, int aiTier, int aiOldTier)`. The player's Dirt and Blood tier changed. Names `Clean`, `Dirt1`-`Dirt4`, `Blood1`-`Blood4`; codes Clean 0, Dirt 1-4, Blood 11-14, unknown -1.
- `OBDC_BathStart`: `Event X(Form akActor)`. A followed bath started.
- `OBDC_BathEnd`: `Event X(Form akActor, float afSeconds, bool abCompleted)`. `abCompleted` is false if the bath was still running after 150 s, or the bather died.
- `OBDC_CumWashed`: `Event X(Form akActor)`. OCum's cum was washed off in a bath.

## Troubleshooting / log files
New in 0.4: the mod writes its own log, so you do not need Papyrus logging.
- **Where:** `Data/SKSE/Plugins/OBloodDirtCum.log`. With MO2 it is in `overwrite/SKSE/Plugins/OBloodDirtCum.log`.
- **What it records:** a header every game load (version, game time; every line has the real date and time); what was found (Dirt and Blood and whether its forms were found, the Malignis patch, OCum, Tull Animated Creampie, Liquid Pack v2, OStimNet, SkyrimNet, WadeInWater, powerofthree, RaceMenu, settings.json); the settings; and how the cum fact in character bios is decided (off, OCum missing, OStimNet's description first, or this mod's short fact). Then one line per event: your Dirt and Blood tier changes, bath start and end (and whether cum will be washed off), cum washed off, cum narration and why one was skipped, WashUp from SkyrimNet (accepted, refused and why, or ignored), narration lines.
- **MCM:** O'Blood, Dirt and Cum > Other > **Write log file** (ON by default).
- **Size:** one line per event, nothing per frame. The file starts over after 10 game loads (counter in `SKSE/Plugins/StorageUtilData/OBloodDirtCum_log.json`); at most 2000 lines per game load.
- **Needs PapyrusUtil** (already required). Without it nothing is written and nothing errors. Every line also goes to `Papyrus.0.log` (`[OBDC]`) when Papyrus logging is on.
- **Bug reports:** attach `OBloodDirtCum.log`. If the game crashed, copy it before you load again.

## 8. Known limits
- **Custom player homes, rimmed tubs, and walled or ladder-entry pools may or may not work.** Rivers, streams, lakes, and other open bodies of water work reliably. Indoor or custom basins depend on each home's navmesh and water setup; NPCs may walk up to the edge and stop if Skyrim's pathfinding cannot navigate stairs, ladders, or walls around the basin. The walk times out after about 24 seconds.
- **Fake decorative water is ignored**, on purpose: only real WaterType activators, Dirt and Blood waterfalls, WadeInWater, swimming, or wadeable cell water count. A house "tub" that is only a water-shader mesh will not be used.
- **OStimNet's own location scan is not changed.** Dialogue and thoughts see the bathing-customs text. OStimNet's `ostimnet_scan_location` prompt still has its own privacy wording ("a crowded public space with no private option is a real barrier for characters who would need discretion"). This mod does not edit OStimNet, so some characters may still hesitate to start a scene in a busy hall even when the customs text is on.
- **Outdoor shorelines** are found by sampling up to 24 points around the NPC (on demand, only when WashUp or the nearby-water check needs it). A very irregular or distant shore just outside those samples may be missed; raising the search range helps.
- **OStimNet detection** uses `TT_OStimNet.esp`. If that plugin is active but OStimNet's SKSE DLL failed to load, OStimNet's own 0401 prompt breaks the same way; this mod's cum fact is in its own submodule, so the dirt and blood facts are not affected.
- **Dirt and Blood is found by its plugin file** `Dirt and Blood - Dynamic Visuals.esp` (also the Nolvus file name). A renamed or merged copy is not found.
- **OCum-only cum fact** relies on OCum's own markers (`OCum_HasCumFaction` or its cum effect); if OCum's decals are turned off in OCum, it may not mark anyone.
- **NPC dirt and blood visuals do not change after a bath.** This is Dirt and Blood's design: NPC blood follows health and NPC dirt follows class or faction.
- **Follower "blood bottle" effects** are not removed by WashUp; they wear off on their own.
- **Baths that start with nobody being followed** are only noticed through your own bath, WashUp and Dirt and Blood's "clean an NPC" spell. An NPC bath started by some other mod while no bath is being followed is not seen (that would need polling). It still shows as "washing right now" in the prompt.
- **Only the player has dirt over time** in Dirt and Blood.
- **Conditional NPC effects.** It has not been checked in game whether SkyrimNet's `has_magic_effect` also counts an NPC effect whose conditions are currently false.
- **OCum's own creampie meshes** (OStim equip objects) are left to OStim and OCum.
- **Max 4 baths followed at once.**

## 9. Uninstall
Turn off the MCM toggles, save, disable the plugin and remove the mod. The scripts keep no data outside your save except settings.json.

## 10. Repository contents and building
- `docs/`: cover art (`OBlood_Dirt_and_Cum_cover.jpg`). This is for the repository only; it is not in the install zip.
- `Data/`: exactly what the release zip installs (`00 Core`, `01 Malignis Flag`, `fomod`).
- `src/`: Papyrus sources (`OBDC_Main`, `OBDC_PlayerAlias`, `OBDC_MCM`, and `OBDC_OCum`, the only script that names OCum's and RaceMenu's types; it is only called after `OCum.esp` is confirmed loaded).
- `tools/`: `compile.sh` (Caprica, Skyrim flags), `mkesp.py` (writes the plugin), `verify.py` (parses it back), `scrub.py` (strips build paths from .pex), `mkzip.py` (the release zip), and compile-only stubs in `tools/stubs/` (never shipped).
- Plugin: `OBlood_Dirt_and_Cum.esp`, ESL, master `Skyrim.esm` only: quests `OBDC_Quest` and `OBDC_MCMQuest` (FormIDs unchanged from 0.1), globals `OBDC_WashUpEnabled`, `OBDC_PromptEnabled`, `OBDC_CumPromptEnabled`, and (0.2) `OBDC_DnBFound`. 0.5 adds globals `OBDC_NormBathing`, `OBDC_NormBathingSex`, `OBDC_NearbyWater`, `OBDC_AllNPCsWashUp`, quest `OBDC_TravelQuest`, and four Travel packages. All earlier FormIDs are kept.
- SkyrimNet pack: `SKSE/Plugins/SkyrimNet/external/coronerra.oblood_dirt_and_cum/` (manifest, `prompts/submodules/character_bio/0172_obdc_hygiene.prompt`, `prompts/submodules/character_bio/0402_obdc_cum_covering.prompt`, `prompts/submodules/user_final_instructions/0503_obdc_bathing_norms.prompt`, `actions/washup.yaml`).

## 11. Credits and permissions
- **That Guy (Coronerra)**: this mod.
- **JaySerpa**, Dirt and Blood - Dynamic Visuals: optional, detected at run time; this is a companion for it. Nothing of it is included.
- **OCum / OCum Ascended** and its authors: optional, detected at run time. Nothing of it is included.
- **Tullius** (Tull Animated Creampie), **Predator** ([Predator] Liquid Pack), and **DwemerMods** (OCum Ascended - Tull and Liquid Pack Meshes): optional; only their item IDs are referenced. Nothing of them is included.
- **Malignis** (Malignis Animations): optional. Nothing of it is included.
- **tetherball88** (OStimNet): complementary, optional, detected at run time. This mod defers to OStimNet's OCum description and reuses its `### Cum covering` heading. Nothing of OStimNet is included or changed.
- The **SkyrimNet** team, **powerofthree** (Papyrus Extender), the **PapyrusUtil** authors, **expired6978** (RaceMenu / NiOverride), and the **SkyUI** team.
- The idea of a facts-only hygiene prompt and onlooker memories was inspired by Telord's Bathing in Skyrim SN-SA plugins. No code or files from that mod are included.

No assets from other mods are included. coronerra's work is MIT (see [LICENSE](LICENSE)); please credit "That Guy (Coronerra)".

---

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
