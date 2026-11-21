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

; true if any RaceMenu overlay slot on the body, face, hands or feet holds a cum texture (broad test, see IsCumTexture).
; Only called at the start of a bath, and only if the cheaper checks found nothing.
bool Function HasCumOverlay(Actor akActor) global
	return ScanOverlays(akActor, false, false) != ""
EndFunction

; 0.5.3: OBDC's own overlay pass, after OCum's clean. Looks at every normal and spell overlay slot on the
; face, body, hands and feet, under both gender keys (OCum keys them by OStim.AppearsFemale, which can differ
; from the actor's sex), and returns what it found as "Face ovl1 <texture>; ...". "" = nothing found.
; abStrip: also remove what it finds, the way OCum removes its own, then reapply the overrides once.
; One-shot at bath time only.
string Function ScanOverlays(Actor akActor, bool abStrip, bool abRefresh) global
	If !akActor || SKSE.GetPluginVersion("skee") <= 0
		return ""
	EndIf
	string found = ""
	found = AreaScan(akActor, "Face", Slots(NiOverride.GetNumFaceOverlays(), 6), Slots(NiOverride.GetNumSpellFaceOverlays(), 1), abStrip, found)
	found = AreaScan(akActor, "Body", Slots(NiOverride.GetNumBodyOverlays(), 10), Slots(NiOverride.GetNumSpellBodyOverlays(), 2), abStrip, found)
	found = AreaScan(akActor, "Hands", Slots(NiOverride.GetNumHandOverlays(), 6), Slots(NiOverride.GetNumSpellHandOverlays(), 2), abStrip, found)
	found = AreaScan(akActor, "Feet", Slots(NiOverride.GetNumFeetOverlays(), 6), Slots(NiOverride.GetNumSpellFeetOverlays(), 2), abStrip, found)
	If abStrip && (found != "" || abRefresh)
		NiOverride.ApplyNodeOverrides(akActor)
	EndIf
	return found
EndFunction

; RaceMenu's count from skee64.ini; if RaceMenu reports nothing usable, a generous fixed maximum.
int Function Slots(int aiReported, int aiFallback) global
	If aiReported > 0 && aiReported <= 32
		return aiReported
	ElseIf aiReported == 0 && aiFallback <= 2
		return 0      ; spell overlays switched off in skee64.ini
	EndIf
	return aiFallback
EndFunction

string Function AreaScan(Actor akActor, string asArea, int aiSlots, int aiSpellSlots, bool abStrip, string asFound) global
	string found = asFound
	int i = 0
	While i < aiSlots
		found = SlotScan(akActor, asArea, "ovl", i, abStrip, found)
		i += 1
	EndWhile
	i = 0
	While i < aiSpellSlots
		found = SlotScan(akActor, asArea, "sOvl", i, abStrip, found)
		i += 1
	EndWhile
	return found
EndFunction

string Function SlotScan(Actor akActor, string asArea, string asKind, int aiSlot, bool abStrip, string asFound) global
	string node = asArea + " [" + asKind + aiSlot + "]"
	string found = asFound
	int g = 0
	While g < 2
		bool female = g == 1
		string tex = NiOverride.GetNodeOverrideString(akActor, female, node, 9, 0)
		If IsCumTexture(tex)
			If found != ""
				found += "; "
			EndIf
			found += asArea + " " + asKind + aiSlot + " " + tex
			If abStrip
				RemoveSlot(akActor, female, node)
			EndIf
		EndIf
		g += 1
	EndWhile
	return found
EndFunction

; Same removal OCum uses for its own CumOverlays.
Function RemoveSlot(Actor akActor, bool abFemale, string asNode) global
	NiOverride.AddNodeOverrideString(akActor, abFemale, asNode, 9, 0, "actors\\character\\overlays\\default.dds", false)
	NiOverride.RemoveNodeOverride(akActor, abFemale, asNode, 9, 0)
	NiOverride.RemoveNodeOverride(akActor, abFemale, asNode, 7, -1)
	NiOverride.RemoveNodeOverride(akActor, abFemale, asNode, 0, -1)
	NiOverride.RemoveNodeOverride(akActor, abFemale, asNode, 8, -1)
	NiOverride.RemoveNodeOverride(akActor, abFemale, asNode, 2, -1)
	NiOverride.RemoveNodeOverride(akActor, abFemale, asNode, 3, -1)
EndFunction

; StringUtil.Find ignores case.
bool Function IsCumTexture(string asTex) global
	If asTex == "" || StringUtil.Find(asTex, "default.dds") >= 0
		return false
	EndIf
	return StringUtil.Find(asTex, "cum") >= 0 || StringUtil.Find(asTex, "creampie") >= 0 || StringUtil.Find(asTex, "semen") >= 0 || StringUtil.Find(asTex, "facial") >= 0 || StringUtil.Find(asTex, "liquid") >= 0
EndFunction
