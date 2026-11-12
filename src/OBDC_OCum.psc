Scriptname OBDC_OCum Hidden
{O'Blood, Dirt and Cum: the only script that names OCum's and RaceMenu's script types.
 Its global functions are called only after OCum.esp is confirmed loaded, so without OCum this script is never loaded.}

; OCum's own clean: removes its RaceMenu CumOverlays and OCum_HasCumFaction.
bool Function Clean(Quest akOCumQuest, Actor akActor) global
	OCumScript oc = akOCumQuest as OCumScript
	If !oc || !akActor
		return false
	EndIf
	oc.CleanCumTexturesFromActor(akActor)
	return true
EndFunction

; true if any RaceMenu overlay slot on the body, face, hands or feet holds one of OCum's CumOverlays textures
; (the same test OCum's RemoveCumOverlay uses). Only called at the start of a bath, and only if the cheaper checks found nothing.
bool Function HasCumOverlay(Actor akActor) global
	If !akActor || SKSE.GetPluginVersion("skee") <= 0
		return false
	EndIf
	bool female = akActor.GetLeveledActorBase().GetSex() == 1
	If AreaHas(akActor, female, "Body", NiOverride.GetNumBodyOverlays())
		return true
	ElseIf AreaHas(akActor, female, "Face", NiOverride.GetNumFaceOverlays())
		return true
	ElseIf AreaHas(akActor, female, "Hands", NiOverride.GetNumHandOverlays())
		return true
	ElseIf AreaHas(akActor, female, "Feet", NiOverride.GetNumFeetOverlays())
		return true
	EndIf
	return false
EndFunction

bool Function AreaHas(Actor akActor, bool abFemale, string asArea, int aiSlots) global
	int i = 0
	While i < aiSlots
		string tex = NiOverride.GetNodeOverrideString(akActor, abFemale, asArea + " [ovl" + i + "]", 9, 0)
		If tex != "" && StringUtil.Find(tex, "CumOverlays") >= 0
			return true
		EndIf
		i += 1
	EndWhile
	return false
EndFunction
