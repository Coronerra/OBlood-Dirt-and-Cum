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
int oReload

int Function GetVersion()
	return 1
EndFunction

Event OnConfigInit()
	ModName = "O'Blood, Dirt and Cum"
EndEvent

Event OnPageReset(string a_page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	AddHeaderOption("Status")
	AddTextOption("Version", "0.1", OPTION_FLAG_DISABLED)
	If Main.bDnB
		AddTextOption("Dirt and Blood", "found", OPTION_FLAG_DISABLED)
	Else
		AddTextOption("Dirt and Blood", "NOT found", OPTION_FLAG_DISABLED)
	EndIf
	If Main.bOCum
		AddTextOption("OCum (optional)", "found", OPTION_FLAG_DISABLED)
	Else
		AddTextOption("OCum (optional)", "not installed", OPTION_FLAG_DISABLED)
	EndIf
	AddTextOption("Your state", Main.TierName(Main.iLastTier), OPTION_FLAG_DISABLED)
	If Main.bMalignisLoaded
		AddTextOption("Malignis Animations patch", "loaded", OPTION_FLAG_DISABLED)
	Else
		AddTextOption("Malignis Animations patch", "not loaded", OPTION_FLAG_DISABLED)
	EndIf
	AddEmptyOption()
	oReload = AddTextOption("Reload installer settings", "go")
	AddHeaderOption("Other")
	oMal = AddToggleOption("Malignis Animations installed", Main.bMalignis)
	oDbg = AddToggleOption("Debug notifications", Main.bDebug)
	SetCursorPosition(1)
	AddHeaderOption("SkyrimNet")
	oPrompt = AddToggleOption("Hygiene in character bios", Main.OBDC_PromptEnabled.GetValue() == 1.0)
	oEvt = AddToggleOption("Short-lived state events", Main.bStateEvents)
	oNarr = AddToggleOption("Narration (big moments only)", Main.bNarration)
	oMem = AddToggleOption("Bath memories", Main.bMemories)
	oBys = AddToggleOption("Onlookers remember baths", Main.bBystanders)
	oWash = AddToggleOption("WashUp action (followers)", Main.OBDC_WashUpEnabled.GetValue() == 1.0)
	AddHeaderOption("OCum (optional)")
	int f = OPTION_FLAG_NONE
	If !Main.bOCum
		f = OPTION_FLAG_DISABLED
	EndIf
	oCumWash = AddToggleOption("Baths wash cum off", Main.bCumWash, f)
	oCumNarr = AddToggleOption("Narrate the cum in the bath", Main.bCumNarration, f)
	oCumPrompt = AddToggleOption("Cum in character bios", Main.OBDC_CumPromptEnabled.GetValue() == 1.0, f)
EndEvent

Event OnOptionSelect(int a_option)
	If a_option == oPrompt
		Main.OBDC_PromptEnabled.SetValue(1.0 - Main.OBDC_PromptEnabled.GetValue())
		SetToggleOptionValue(a_option, Main.OBDC_PromptEnabled.GetValue() == 1.0)
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
	ElseIf a_option == oReload
		Main.ReadSettings(true)
		Main.ApplyWashUpToggle()
		ForcePageReset()
	EndIf
EndEvent

Event OnOptionHighlight(int a_option)
	If a_option == oPrompt
		SetInfoText("Adds facts about dirt and blood (and, with OCum, cum) to SkyrimNet character bios. Quiet when clean or only lightly dusty, and for NPCs whose Dirt and Blood options are off.")
	ElseIf a_option == oEvt
		SetInfoText("Short-lived SkyrimNet events when your Dirt and Blood state changes or someone starts bathing.")
	ElseIf a_option == oNarr
		SetInfoText("A narration line only for big moments: after a fight that left you covered or soaked in blood, and when you finish a bath. At most one every 2 minutes.")
	ElseIf a_option == oMem
		SetInfoText("Bathers remember that they bathed (SkyrimNet persistent event).")
	ElseIf a_option == oBys
		SetInfoText("Up to 3 adult NPCs who can see a bath remember it. No forced dialogue.")
	ElseIf a_option == oWash
		SetInfoText("Lets followers decide to wash with Dirt and Blood's own bath. Follows Dirt and Blood's soap and water rules. Separate from Dirt and Blood's own NPC bathing option.")
	ElseIf a_option == oCumWash
		SetInfoText("If someone has OCum's cum on them when a Dirt and Blood bath starts, it is washed off a few seconds into the bath (OCum's own clean, plus Tull / Liquid Pack items). Works even if OCum's 'clean when entering water' is off. Swimming is left to OCum.")
	ElseIf a_option == oCumNarr
		SetInfoText("A short SkyrimNet narration just before the cum is washed off. At most one every 30 seconds, only for bathers near you.")
	ElseIf a_option == oCumPrompt
		SetInfoText("Adds 'has cum on them' to SkyrimNet character bios while OCum marks someone. Gone after a wash or when OCum's own timer cleans it. Personality decides the reaction.")
	ElseIf a_option == oMal
		SetInfoText("Set by the installer. Only changes the log text (a woman's bath runs about 65 s). Bath ends are always detected the same way.")
	ElseIf a_option == oReload
		SetInfoText("Read the installer's settings.json again (overwrites the toggles on this page).")
	EndIf
EndEvent
