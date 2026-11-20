Scriptname OBDC_MCM extends SKI_ConfigBase
{O'Blood, Dirt and Cum: settings page.}

OBDC_Main Property Main Auto

int oPrompt
int oNarr
int oMem
int oBys
int oEvt
int oWash
int oCumWash
int oCumNarr
int oCumPrompt
int oMal
int oDbg
int oLog
int oReload
int oNormBath
int oNormSex
int oWalk
int oRadius
int oAllNPC

int Function GetVersion()
	return 5
EndFunction

Event OnConfigInit()
	ModName = "O'Blood, Dirt and Cum"
EndEvent

Event OnPageReset(string a_page)
	int fD = OPTION_FLAG_NONE      ; Dirt and Blood settings
	int fC = OPTION_FLAG_NONE      ; OCum settings
	int fB = OPTION_FLAG_NONE      ; settings that need both
	int fA = OPTION_FLAG_NONE      ; settings that need either
	If !Main.bDnB
		fD = OPTION_FLAG_DISABLED
		fB = OPTION_FLAG_DISABLED
	EndIf
	If !Main.bOCum
		fC = OPTION_FLAG_DISABLED
		fB = OPTION_FLAG_DISABLED
	EndIf
	If !Main.bDnB && !Main.bOCum
		fA = OPTION_FLAG_DISABLED
	EndIf
	int fWalk = fD
	If fD == OPTION_FLAG_NONE && !Main.bWalkToWater
		fWalk = OPTION_FLAG_DISABLED
	EndIf
	int fWashSub = fD
	If fD == OPTION_FLAG_NONE && Main.OBDC_WashUpEnabled.GetValue() != 1.0
		fWashSub = OPTION_FLAG_DISABLED
	EndIf
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("Status")
	AddTextOption("Version", "0.5", OPTION_FLAG_DISABLED)
	If Main.bDnB
		AddTextOption("Dirt and Blood", "found", OPTION_FLAG_DISABLED)
	Else
		AddTextOption("Dirt and Blood", "not installed", OPTION_FLAG_DISABLED)
	EndIf
	If Main.bOCum
		AddTextOption("OCum", "found", OPTION_FLAG_DISABLED)
	Else
		AddTextOption("OCum", "not installed", OPTION_FLAG_DISABLED)
	EndIf
	AddTextOption("Mode", Main.ModeName(), OPTION_FLAG_DISABLED)
	If Main.bDnB
		AddTextOption("Your state", Main.TierName(Main.iLastTier), OPTION_FLAG_DISABLED)
		If Main.bMalignisLoaded
			AddTextOption("Malignis Animations patch", "loaded", OPTION_FLAG_DISABLED)
		Else
			AddTextOption("Malignis Animations patch", "not loaded", OPTION_FLAG_DISABLED)
		EndIf
	ElseIf !Main.bOCum
		AddTextOption("Install Dirt and Blood, OCum or both", "", OPTION_FLAG_DISABLED)
	EndIf
	AddEmptyOption()
	oReload = AddTextOption("Reload installer settings", "go")
	AddHeaderOption("Other")
	oMal = AddToggleOption("Malignis Animations installed", Main.bMalignis, fD)
	oDbg = AddToggleOption("Debug notifications", Main.bDebug)
	oLog = AddToggleOption("Write log file", Main.bLogFile)      ; 0.4
	SetCursorPosition(1)
	AddHeaderOption("SkyrimNet")
	oPrompt = AddToggleOption("Hygiene in character bios", Main.OBDC_PromptEnabled.GetValue() == 1.0, fA)
	AddHeaderOption("Bathing customs")
	oNormBath = AddToggleOption("Open and communal bathing is normal", Main.OBDC_NormBathing.GetValue() == 1.0, fA)
	oNormSex = AddToggleOption("Intimacy in bathing spots is normal", Main.OBDC_NormBathingSex.GetValue() == 1.0, fA)
	AddHeaderOption("Dirt and Blood")
	oEvt = AddToggleOption("Short-lived state events", Main.bStateEvents, fD)
	oNarr = AddToggleOption("Narration (big moments only)", Main.bNarration, fD)
	oMem = AddToggleOption("Bath memories", Main.bMemories, fD)
	oBys = AddToggleOption("Onlookers remember baths", Main.bBystanders, fD)
	oWash = AddToggleOption("WashUp action", Main.OBDC_WashUpEnabled.GetValue() == 1.0, fD)
	oWalk = AddToggleOption("Walk to nearby water", Main.bWalkToWater, fD)
	oRadius = AddSliderOption("Water search range", Main.fWaterSearchRadius, "{0} units", fWalk)
	oAllNPC = AddToggleOption("Non-followers can WashUp", Main.OBDC_AllNPCsWashUp.GetValue() == 1.0, fWashSub)
	AddHeaderOption("OCum")
	oCumPrompt = AddToggleOption("Cum in character bios", Main.OBDC_CumPromptEnabled.GetValue() == 1.0, fC)
	oCumWash = AddToggleOption("Baths wash cum off", Main.bCumWash, fB)
	oCumNarr = AddToggleOption("Narrate the cum in the bath", Main.bCumNarration, fB)
EndEvent

Event OnOptionSelect(int a_option)
	If a_option == oPrompt
		Main.OBDC_PromptEnabled.SetValue(1.0 - Main.OBDC_PromptEnabled.GetValue())
		SetToggleOptionValue(a_option, Main.OBDC_PromptEnabled.GetValue() == 1.0)
	ElseIf a_option == oNormBath
		Main.OBDC_NormBathing.SetValue(1.0 - Main.OBDC_NormBathing.GetValue())
		SetToggleOptionValue(a_option, Main.OBDC_NormBathing.GetValue() == 1.0)
	ElseIf a_option == oNormSex
		Main.OBDC_NormBathingSex.SetValue(1.0 - Main.OBDC_NormBathingSex.GetValue())
		SetToggleOptionValue(a_option, Main.OBDC_NormBathingSex.GetValue() == 1.0)
	ElseIf a_option == oEvt
		Main.bStateEvents = !Main.bStateEvents
		SetToggleOptionValue(a_option, Main.bStateEvents)
	ElseIf a_option == oNarr
		Main.bNarration = !Main.bNarration
		SetToggleOptionValue(a_option, Main.bNarration)
	ElseIf a_option == oMem
		Main.bMemories = !Main.bMemories
		SetToggleOptionValue(a_option, Main.bMemories)
	ElseIf a_option == oBys
		Main.bBystanders = !Main.bBystanders
		SetToggleOptionValue(a_option, Main.bBystanders)
	ElseIf a_option == oWash
		Main.OBDC_WashUpEnabled.SetValue(1.0 - Main.OBDC_WashUpEnabled.GetValue())
		Main.ApplyWashUpToggle()
		SetToggleOptionValue(a_option, Main.OBDC_WashUpEnabled.GetValue() == 1.0)
		If Main.OBDC_WashUpEnabled.GetValue() == 1.0
			ShowMessage("WashUp comes back the next time SkyrimNet reloads its actions (or after a save and load).", false)
		EndIf
		ForcePageReset()
	ElseIf a_option == oWalk
		Main.bWalkToWater = !Main.bWalkToWater
		Main.ApplyWalkToWater()
		SetToggleOptionValue(a_option, Main.bWalkToWater)
		ForcePageReset()
	ElseIf a_option == oAllNPC
		Main.OBDC_AllNPCsWashUp.SetValue(1.0 - Main.OBDC_AllNPCsWashUp.GetValue())
		SetToggleOptionValue(a_option, Main.OBDC_AllNPCsWashUp.GetValue() == 1.0)
	ElseIf a_option == oCumWash
		Main.bCumWash = !Main.bCumWash
		SetToggleOptionValue(a_option, Main.bCumWash)
	ElseIf a_option == oCumNarr
		Main.bCumNarration = !Main.bCumNarration
		SetToggleOptionValue(a_option, Main.bCumNarration)
	ElseIf a_option == oCumPrompt
		Main.OBDC_CumPromptEnabled.SetValue(1.0 - Main.OBDC_CumPromptEnabled.GetValue())
		SetToggleOptionValue(a_option, Main.OBDC_CumPromptEnabled.GetValue() == 1.0)
	ElseIf a_option == oMal
		Main.bMalignis = !Main.bMalignis
		SetToggleOptionValue(a_option, Main.bMalignis)
	ElseIf a_option == oDbg
		Main.bDebug = !Main.bDebug
		SetToggleOptionValue(a_option, Main.bDebug)
	ElseIf a_option == oLog
		Main.bLogFile = !Main.bLogFile
		Main.LogToggled()
		SetToggleOptionValue(a_option, Main.bLogFile)
	ElseIf a_option == oReload
		Main.ReadSettings(true)
		Main.ApplyWashUpToggle()
		Main.ApplyWalkToWater()
		ForcePageReset()
	EndIf
EndEvent

Event OnOptionSliderOpen(int a_option)
	If a_option == oRadius
		SetSliderDialogStartValue(Main.fWaterSearchRadius)
		SetSliderDialogDefaultValue(2000.0)
		SetSliderDialogRange(500.0, 3500.0)
		SetSliderDialogInterval(50.0)
	EndIf
EndEvent

Event OnOptionSliderAccept(int a_option, float a_value)
	If a_option == oRadius
		Main.fWaterSearchRadius = a_value
		SetSliderOptionValue(a_option, a_value, "{0} units")
		Main.UpdateNearbyWater(true)
	EndIf
EndEvent

Event OnOptionHighlight(int a_option)
	If a_option == oPrompt
		SetInfoText("Master switch for the SkyrimNet bio facts: dirt and blood (with Dirt and Blood) and cum (with OCum). Also required for the bathing-customs text. Quiet when there is nothing to say, when clean or only lightly dusty, and for NPCs whose Dirt and Blood options are off.")
	ElseIf a_option == oNormBath
		SetInfoText("ON (default): SkyrimNet is told that bathing nude in rivers, streams, lakes, hot springs and communal pools, where others can see, is ordinary Nordic custom, not shocking or immodest. OFF: that sentence is not added. Needs 'Hygiene in character bios' to be on.")
	ElseIf a_option == oNormSex
		SetInfoText("ON (default): SkyrimNet is told that intimacy and sex in open-air bathing spots, hot springs, streams, lakes and communal pools is socially accepted as normal, not scandalous. OFF: that sentence is not added. Needs 'Hygiene in character bios' to be on.")
	ElseIf a_option == oEvt
		SetInfoText("Short-lived SkyrimNet events when your Dirt and Blood state changes or someone starts bathing.")
	ElseIf a_option == oNarr
		SetInfoText("A narration line only for big moments: after a fight that left you covered or soaked in blood, and when you finish a bath. At most one every 2 minutes.")
	ElseIf a_option == oMem
		SetInfoText("Bathers remember that they bathed (SkyrimNet persistent event).")
	ElseIf a_option == oBys
		SetInfoText("Up to 3 adult NPCs who can see a bath remember it. No forced dialogue.")
	ElseIf a_option == oWash
		SetInfoText("Needs Dirt and Blood. Lets followers (and, if that toggle is on, nearby non-followers) decide to wash with Dirt and Blood's own bath. Follows Dirt and Blood's soap and water rules. Separate from Dirt and Blood's own NPC bathing option.")
	ElseIf a_option == oWalk
		SetInfoText("ON (default): if someone chooses WashUp and is not already in water, they walk to the nearest real water within the search range (a stream, lake, waterfall, pool or tub — fake decorative water is ignored), then bathe. Also tells SkyrimNet when a pool, tub or open water is nearby. OFF: no walking, no cell water scan, and no nearby-water prompt text. WashUp then needs them to already be standing in water, as in 0.4.")
	ElseIf a_option == oRadius
		SetInfoText("How far WashUp looks for real water, and how far the nearby-water check looks around you (500 to 3500 units, default 2000 — about 20 to 30 metres). Greyed out when 'Walk to nearby water' is off.")
	ElseIf a_option == oAllNPC
		SetInfoText("ON (default): nearby adult NPCs who are not your followers (for example the Companions in Jorrvaskr) can also choose WashUp. OFF: only your followers can. Greyed out when WashUp itself is off.")
	ElseIf a_option == oCumWash
		SetInfoText("Needs Dirt and Blood and OCum. If someone has OCum's cum on them when a Dirt and Blood bath starts, it is washed off a few seconds into the bath (OCum's own clean, plus Tull / Liquid Pack items). Works even if OCum's 'clean when entering water' is off. Swimming is left to OCum.")
	ElseIf a_option == oCumNarr
		SetInfoText("Needs Dirt and Blood and OCum. A short SkyrimNet narration just before the cum is washed off. At most one every 30 seconds, only for bathers near you.")
	ElseIf a_option == oCumPrompt
		SetInfoText("Adds 'has cum on them' to SkyrimNet character bios while OCum marks someone. Works with or without Dirt and Blood. If OStimNet is installed and already describes the cum, its details take priority and this adds nothing. Gone when OCum's own timer, a swim or a bath cleans it. Personality decides the reaction.")
	ElseIf a_option == oMal
		SetInfoText("Set by the installer. Only changes the log text (a woman's bath runs about 65 s). Bath ends are always detected the same way.")
	ElseIf a_option == oLog
		SetInfoText("ON (default): writes Data/SKSE/Plugins/OBloodDirtCum.log (MO2: overwrite/SKSE/Plugins). Each game load: what was found, the settings and how the cum fact is decided; then baths, washes, WashUp and narrations. Attach it to bug reports. Needs PapyrusUtil.")
	ElseIf a_option == oReload
		SetInfoText("Read the installer's settings.json again (overwrites the toggles on this page).")
	EndIf
EndEvent
