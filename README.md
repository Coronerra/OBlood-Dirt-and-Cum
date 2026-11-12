# O'Blood, Dirt and Cum

**v0.1** · By **That Guy (Coronerra)** · Skyrim Special Edition · ESL-flagged plugin · Adults only

**[Download v0.1](https://github.com/Coronerra/OBlood-Dirt-and-Cum/releases/tag/v0.1)** (`OBlood_Dirt_and_Cum_0.1.zip`) · [Changelog](CHANGELOG.md) · License: [MIT for coronerra's work](LICENSE)

A small, standalone **SkyrimNet companion for [Dirt and Blood - Dynamic Visuals](https://www.nexusmods.com/skyrimspecialedition/mods/38886)**. It is a companion, **not a replacement**: Dirt and Blood is required and does all the dirt, blood and bathing. This mod tells SkyrimNet about it, lets followers decide to wash, and, if you also run **OCum** (optional), makes a Dirt and Blood bath wash OCum's cum off too.

This is a test build (0.1). It compiles, and the plugin and installer were checked, but it has not been played in game yet. Please report problems on [GitHub Issues](https://github.com/Coronerra/OBlood-Dirt-and-Cum/issues) with your Papyrus log (lines start with `[OBDC]`).

## Contents
1. [What it does](#1-what-it-does)
2. [Requirements](#2-requirements)
3. [Install](#3-install)
4. [Settings](#4-settings)
5. [The WashUp action](#5-the-washup-action)
6. [OCum: washing cum off in a bath](#6-ocum-washing-cum-off-in-a-bath)
7. [For modders: mod events](#7-for-modders-mod-events)
8. [Known limits](#8-known-limits)
9. [Uninstall](#9-uninstall)
10. [Repository contents and building](#10-repository-contents-and-building)
11. [Credits and permissions](#11-credits-and-permissions)

## 1. What it does
- **Hygiene in character bios.** The prompt `0172_obdc_hygiene.prompt` (a SkyrimNet `character_bio` submodule) states plain facts, such as "Lydia is bloodstained and very dirty.", "Lydia has cum on them." or "You are washing right now." It never tells anyone how to react; their personality decides that.
  - It stays quiet for Clean and Dirt1 (lightly dusty is normal in Skyrim).
  - NPC dirt and blood only appear while the matching Dirt and Blood option is on (NPCs get bloody, bandit dirt, profession dirt). If you turned those off in Dirt and Blood's MCM, NPCs show nothing.
  - The cum fact appears only with OCum installed, while OCum itself marks the character (its `OCum_HasCumFaction` or its cum effect). It goes away when OCum's own timer cleans them, when they swim (OCum's own water clean) or when they bathe (this mod). Without OCum it is completely silent.
  - There is no header at all when there is nothing to say. Characters read about themselves in the second person and about others in the third person.
- **State events.** When your Dirt and Blood state changes (blood from a hit, dirt over time, rain, a swim), SkyrimNet gets a short-lived event, for example "<your name> is now covered in blood."
- **Narration, only for big moments.** One narration line when a fight leaves you covered or soaked in blood (sent after the fight ends), and one when you finish a bath. At most one every 2 minutes.
- **Bath memories.** When a bath ends, the bather remembers it ("... washed off the dirt, blood and cum." if cum was washed off). Up to 3 adult NPCs who can see the bath also remember it (no forced dialogue, no extra LLM call).
- **WashUp action** for followers (section 5).
- **OCum wash-off** during any real Dirt and Blood bath, with a short narration (section 6).
- **Public mod events** for other mods (section 7).

How it stays light:
- One player alias, with a po3 event filtered to Dirt and Blood's 9 player tier effects and its soap effect, and a check for the player casting Dirt and Blood's "clean an NPC" spell. There is no global polling.
- Only while a bath is running does it look every 2 seconds whether the bath has ended (and at Dirt and Blood's bathing list for anyone else who started bathing). It stops when the bather leaves Dirt and Blood's bathing list, and gives up after 150 seconds.
- Nothing of Dirt and Blood or OCum is overridden. Neither is a master; their forms are found at run time.
- It reads Dirt and Blood's **live** settings (soap required, water required, NPC options) instead of assuming any defaults. Strip and dress, and whether a swim cleans completely, stay entirely Dirt and Blood's.

## 2. Requirements
Required:
- Skyrim Special Edition. Built and checked for **1.5.97** (Nolvus-friendly). The plugin is a normal ESL with only `Skyrim.esm` as a master and there is no SKSE DLL of ours, so AE should also work with matching builds of the requirements; AE reports are welcome.
- **Dirt and Blood - Dynamic Visuals 2.37** (the version bundled with Nolvus works): https://www.nexusmods.com/skyrimspecialedition/mods/38886
- **SkyrimNet** (0.28 or newer)
- SKSE64, Address Library for SKSE Plugins
- powerofthree's Papyrus Extender
- PapyrusUtil SE (settings.json and StorageUtil)
- SkyUI (for the MCM page; everything else works without it)

Optional (detected automatically, never masters, nothing of theirs is included):
- **OCum / OCum Ascended 4.1.1** (`OCum.esp`). Enables the bath wash-off and the cum fact. There is no installer option for it; without it, every OCum part does nothing.
- **Tull Animated Creampie** and **[Predator] Liquid Pack v2**, as used by the OCum Ascended Tull and Liquid Pack add-on and by the OCum Werewolf Shot / OStim Beast Form mesh loads. Their items are taken off in the bath as a backup (section 6).
- **Malignis Animations** (https://www.nexusmods.com/skyrimspecialedition/mods/166293) with its Dirt and Blood patch. If you use it, tick the installer option (section 3).
- **WadeInWater**: standing in its water counts as water for WashUp, the same as in Dirt and Blood.

Not needed: Bathing in Skyrim, BiS SN-SA, SeverActions.

## 3. Install
1. Install `OBlood_Dirt_and_Cum_0.1.zip` with your mod manager. The installer has one option:
   - **"I use Malignis Animations with Dirt and Blood"**: tick it only if you use the Malignis Animations bathing patch. It installs no Malignis files; it only sets `"malignis": 1` in `SKSE/Plugins/OBlood_Dirt_and_Cum/settings.json`. The flag is shown in the MCM and used in the log. Bath ends are always detected the same way (wait until the bath is really over, at most 150 s), so leaving it unticked is safe.
2. Enable `OBlood_Dirt_and_Cum.esp`. It is ESL-flagged, with `Skyrim.esm` as its only master. Load order does not matter.
3. **Remove any old hygiene overlay prompt.** Some setups have an older user overlay, `SKSE/Plugins/SkyrimNet/overlay/prompts/submodules/character_bio/1010_dirtandblood.prompt` (credited to Min), usually in the mod manager's overwrite folder. With both installed, characters get two hygiene blocks. That overlay also checks EditorIDs that do not exist in Dirt and Blood 2.37 and always prints its header. Move it out of the overlay folder or delete it. This mod never touches it for you.
4. Start or load a game. The MCM page "O'Blood, Dirt and Cum" shows whether Dirt and Blood and OCum were found.

## 4. Settings
MCM page **O'Blood, Dirt and Cum**:
- **Hygiene in character bios** (on). Global `OBDC_PromptEnabled`.
- **Short-lived state events** (on).
- **Narration (big moments only)** (on).
- **Bath memories** (on).
- **Onlookers remember baths** (on).
- **WashUp action (followers)** (on). Its own switch, separate from Dirt and Blood's own "NPCs bathe" option.
- **Baths wash cum off** (on; greyed out without OCum).
- **Narrate the cum in the bath** (on; greyed out without OCum).
- **Cum in character bios** (on; greyed out without OCum). Global `OBDC_CumPromptEnabled`.
- **Malignis Animations installed** (from the installer). Only changes log text.
- **Debug notifications** (off).
- **Reload installer settings** reads settings.json again.

`SKSE/Plugins/OBlood_Dirt_and_Cum/settings.json` (PapyrusUtil format) holds the first values: `malignis`, `narration`, `memories`, `bystanders`, `state_events`, `washup`, `cum_wash`, `cum_narration`, `cum_prompt` (1 = on, 0 = off). It is read once on the first start and again with "Reload installer settings". After that the MCM values are kept in your save.

## 5. The WashUp action
A follower can choose **WashUp** when they want to get clean. The follower then runs Dirt and Blood's own bath, `PlayBatheAnimation`, exactly as Dirt and Blood's own NPC washing does.

SkyrimNet only offers it when the character is your follower, is not in combat or in a SexLab or OStim scene, has their weapon sheathed, and the WashUp switch is on.

When the action runs, the script checks again and follows Dirt and Blood's **live** rules:
- **Water required**: the follower must be swimming, in water, near one of Dirt and Blood's waterfall lists (same heights and radii as Dirt and Blood uses), or in WadeInWater water.
- **Soap required**: the follower must carry a soap from Dirt and Blood's soap list. One soap is used up, as with Dirt and Blood's own soap.

If a rule fails, the follower does not wash. They get a private thought with the reason ("there is no water here", "you have no soap"), and the action has a 30-second cooldown.

Turning WashUp off in the MCM removes the action until it is turned back on. After turning it on again, it returns the next time SkyrimNet reloads its actions, or after a save and load.

## 6. OCum: washing cum off in a bath
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
- `OBDC_StateChanged`: `Event X(Form akActor, string asTier, int aiTier, int aiOldTier)`. The player's Dirt and Blood tier changed. Names `Clean`, `Dirt1`-`Dirt4`, `Blood1`-`Blood4`; codes Clean 0, Dirt 1-4, Blood 11-14, unknown -1.
- `OBDC_BathStart`: `Event X(Form akActor)`. A followed bath started.
- `OBDC_BathEnd`: `Event X(Form akActor, float afSeconds, bool abCompleted)`. `abCompleted` is false if the bath was still running after 150 s, or the bather died.
- `OBDC_CumWashed`: `Event X(Form akActor)`. OCum's cum was washed off in a bath.

## 8. Known limits
- **Not tested in game yet** (0.1).
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
- `Data/`: exactly what the release zip installs (`00 Core`, `01 Malignis Flag`, `fomod`).
- `src/`: Papyrus sources (`OBDC_Main`, `OBDC_PlayerAlias`, `OBDC_MCM`, and `OBDC_OCum`, the only script that names OCum's and RaceMenu's types; it is only called after `OCum.esp` is confirmed loaded).
- `tools/`: `compile.sh` (Caprica, Skyrim flags), `mkesp.py` (writes the plugin), `verify.py` (parses it back), `scrub.py` (strips build paths from .pex), `mkzip.py` (the release zip), and compile-only stubs in `tools/stubs/` (never shipped).
- Plugin: `OBlood_Dirt_and_Cum.esp`, ESL, master `Skyrim.esm` only: quests `OBDC_Quest` and `OBDC_MCMQuest`, globals `OBDC_WashUpEnabled`, `OBDC_PromptEnabled`, `OBDC_CumPromptEnabled`.
- SkyrimNet pack: `SKSE/Plugins/SkyrimNet/external/coronerra.oblood_dirt_and_cum/` (manifest, `prompts/submodules/character_bio/0172_obdc_hygiene.prompt`, `actions/washup.yaml`).

## 11. Credits and permissions
- **That Guy (Coronerra)**: this mod.
- **JaySerpa**, Dirt and Blood - Dynamic Visuals: the mod this is a companion for. Nothing of it is included.
- **OCum / OCum Ascended** and its authors: optional, detected at run time. Nothing of it is included.
- **Tullius** (Tull Animated Creampie), **Predator** ([Predator] Liquid Pack), and **DwemerMods** (OCum Ascended - Tull and Liquid Pack Meshes): optional; only their item IDs are referenced. Nothing of them is included.
- **Malignis** (Malignis Animations): optional. Nothing of it is included.
- The **SkyrimNet** team, **powerofthree** (Papyrus Extender), the **PapyrusUtil** authors, **expired6978** (RaceMenu / NiOverride), and the **SkyUI** team.
- The idea of a facts-only hygiene prompt and onlooker memories was inspired by Telord's Bathing in Skyrim SN-SA plugins. No code or files from that mod are included.

No assets from other mods are included. coronerra's work is MIT (see [LICENSE](LICENSE)); please credit "That Guy (Coronerra)".
