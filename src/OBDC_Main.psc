Scriptname OBDC_Main extends Quest
{O'Blood, Dirt and Cum v0.1. A SkyrimNet companion for Dirt and Blood, by That Guy (Coronerra).
 Tells SkyrimNet what Dirt and Blood is doing, and washes OCum's cum off during a real Dirt and Blood bath.
 Dirt and Blood, OCum, Tull Animated Creampie and Liquid Pack are found at run time with GetFormFromFile;
 none of them is a master and nothing of them is overridden.}

; ---------------------------------------------------------------------------------------------
;  Properties filled by the plugin
; ---------------------------------------------------------------------------------------------
Actor Property PlayerRef Auto
OBDC_PlayerAlias Property PlayerAlias Auto
GlobalVariable Property OBDC_WashUpEnabled Auto       ; read by the WashUp action's eligibility rule
GlobalVariable Property OBDC_PromptEnabled Auto       ; read by the hygiene prompt
GlobalVariable Property OBDC_CumPromptEnabled Auto    ; read by the hygiene prompt (cum fact)
Keyword Property ActorTypeNPC Auto

string Property DNB_ESP = "Dirt and Blood - Dynamic Visuals.esp" AutoReadOnly
string Property MALIGNIS_ESP = "Dirt and Blood - Malignis Animations Patch.esp" AutoReadOnly
string Property OCUM_ESP = "OCum.esp" AutoReadOnly
string Property TULL_ESP = "TullAnimatedCreampie.esp" AutoReadOnly
string Property LIQUID_ESP = "[Predator] Liquid Pack v2.esp" AutoReadOnly
string Property SETTINGS_FILE = "../OBlood_Dirt_and_Cum/settings.json" AutoReadOnly
string Property ACTION_NAME = "WashUp" AutoReadOnly
float Property POLL = 2.0 AutoReadOnly               ; bath check interval, only while a bath runs
float Property SCAN_STEP = 1.5 AutoReadOnly          ; after the player casts Dirt and Blood's NPC bath spell
float Property BATH_CAP = 150.0 AutoReadOnly         ; longest a bath is followed (s)
float Property NARRATION_GAP = 120.0 AutoReadOnly    ; at most one dirt/blood narration this often (s)
float Property CUM_NARRATION_GAP = 30.0 AutoReadOnly ; at most one cum narration this often (s)
float Property CUM_NARRATION_RANGE = 4096.0 AutoReadOnly
float Property WITNESS_RADIUS = 1500.0 AutoReadOnly
int Property WITNESS_MAX = 3 AutoReadOnly
int Property WASHUP_COOLDOWN = 30 AutoReadOnly
int Property VERSION = 1 AutoReadOnly                ; 0.1

; ---------------------------------------------------------------------------------------------
;  Settings (MCM; first defaults come from settings.json written by the installer)
; ---------------------------------------------------------------------------------------------
bool Property bNarration = true Auto Hidden
bool Property bMemories = true Auto Hidden
bool Property bBystanders = true Auto Hidden
bool Property bStateEvents = true Auto Hidden
bool Property bMalignis = false Auto Hidden
bool Property bCumWash = true Auto Hidden
bool Property bCumNarration = true Auto Hidden
bool Property bDebug = false Auto Hidden
bool bSettingsRead = false

; ---------------------------------------------------------------------------------------------
;  Dirt and Blood forms (resolved on every load)
; ---------------------------------------------------------------------------------------------
bool Property bDnB = false Auto Hidden
bool Property bMalignisLoaded = false Auto Hidden
Dirty_BathingQuest kBathQuest
FormList kBathingActors
FormList kSoaps
FormList kFall256
FormList kFall512
FormList kFall2048
FormList kFall4096
GlobalVariable gSoapReq
GlobalVariable gWaterReq
MagicEffect Property fxSoapy Auto Hidden
MagicEffect[] Property fxTier Auto Hidden
Spell Property kNPCBathSpell Auto Hidden             ; Dirty_CleanYoSelfNPC, cast by the player on an NPC
int[] tierCode
Spell kWade1
Spell kWade2

; ---------------------------------------------------------------------------------------------
;  OCum and its mesh add-ons (optional; resolved on every load)
; ---------------------------------------------------------------------------------------------
bool Property bOCum = false Auto Hidden
Quest kOCumQuest              ; OCumQuest 0x800 (script OCumScript)
Faction kHasCumFaction        ; OCum_HasCumFaction 0xF46
Keyword kAppliedCum           ; OCumAppliedCum 0xF16
Spell kOCumSpell              ; OCumSpell 0xF15
MagicEffect fxOCum            ; OCumMagicEffect 0xF14
Form[] kMeshItems             ; Tull / Liquid Pack items worn by the OCum Tull and Liquid add-on and by Beast Pie
int nMeshItems = 0

int Property iLastTier = -1 Auto Hidden
float fLastNarr = -1000.0
float fLastCumNarr = -1000.0
bool bPendNarr = false
int iPendCode = 0
float fPendWaited = 0.0
int iScanLeft = 0

; one slot per bath followed (max 4)
Actor[] bathActor
float[] bathWaited
bool[] bathOwned
int[] cumStage                ; 0 no cum seen at start, 1 waiting to narrate, 2 waiting to clean, 3 cleaned
float[] cumNarrAt
float[] cumCleanAt
Actor[] staleActor            ; still listed by Dirt and Blood long after their bath; not followed again
int nBaths = 0

; =============================================================================================
;  Start-up
; =============================================================================================
Event OnInit()
	If IsRunning()
		Startup()
	EndIf
EndEvent

Function Startup()
	ReadSettings(false)
	Resolve()
	bathActor = new Actor[4]
	bathWaited = new float[4]
	bathOwned = new bool[4]
	cumStage = new int[4]
	cumNarrAt = new float[4]
	cumCleanAt = new float[4]
	staleActor = new Actor[4]
	nBaths = 0
	iScanLeft = 0
	bPendNarr = false
	UnregisterForUpdate()
	If bDnB
		PlayerAlias.Arm(fxTier, fxSoapy, kNPCBathSpell)
		iLastTier = CurrentTier(PlayerRef)
	Else
		PlayerAlias.Disarm()
	EndIf
	UnregisterForModEvent("OBDC_DoWash")
	RegisterForModEvent("OBDC_DoWash", "OnDoWash")
	ApplyWashUpToggle()
	Log("started. Dirt and Blood " + bDnB + ", OCum " + bOCum + " (" + nMeshItems + " mesh items), Malignis flag " + bMalignis + ", Malignis plugin " + bMalignisLoaded + ", player tier " + TierName(iLastTier))
EndFunction

Function ReadSettings(bool abForce)
	If bSettingsRead && !abForce
		return
	EndIf
	bSettingsRead = true
	If !JsonUtil.JsonExists(SETTINGS_FILE)
		return
	EndIf
	bMalignis = JsonUtil.GetIntValue(SETTINGS_FILE, "malignis", 0) == 1
	bNarration = JsonUtil.GetIntValue(SETTINGS_FILE, "narration", 1) == 1
	bMemories = JsonUtil.GetIntValue(SETTINGS_FILE, "memories", 1) == 1
	bBystanders = JsonUtil.GetIntValue(SETTINGS_FILE, "bystanders", 1) == 1
	bStateEvents = JsonUtil.GetIntValue(SETTINGS_FILE, "state_events", 1) == 1
	bCumWash = JsonUtil.GetIntValue(SETTINGS_FILE, "cum_wash", 1) == 1
	bCumNarration = JsonUtil.GetIntValue(SETTINGS_FILE, "cum_narration", 1) == 1
	If OBDC_WashUpEnabled
		OBDC_WashUpEnabled.SetValue(JsonUtil.GetIntValue(SETTINGS_FILE, "washup", 1) as float)
	EndIf
	If OBDC_CumPromptEnabled
		OBDC_CumPromptEnabled.SetValue(JsonUtil.GetIntValue(SETTINGS_FILE, "cum_prompt", 1) as float)
	EndIf
EndFunction

Function Resolve()
	bMalignisLoaded = Game.IsPluginInstalled(MALIGNIS_ESP)
	ResolveOCum()
	bDnB = false
	kBathQuest = None
	If !Game.IsPluginInstalled(DNB_ESP)
		return
	EndIf
	kBathQuest = Game.GetFormFromFile(0xDC3, DNB_ESP) as Dirty_BathingQuest
	kBathingActors = Game.GetFormFromFile(0xDC4, DNB_ESP) as FormList
	kSoaps = Game.GetFormFromFile(0x85B, DNB_ESP) as FormList
	kFall256 = Game.GetFormFromFile(0x86C, DNB_ESP) as FormList
	kFall512 = Game.GetFormFromFile(0x86D, DNB_ESP) as FormList
	kFall2048 = Game.GetFormFromFile(0x86E, DNB_ESP) as FormList
	kFall4096 = Game.GetFormFromFile(0x86F, DNB_ESP) as FormList
	gSoapReq = Game.GetFormFromFile(0x82D, DNB_ESP) as GlobalVariable
	gWaterReq = Game.GetFormFromFile(0x86A, DNB_ESP) as GlobalVariable
	fxSoapy = Game.GetFormFromFile(0x803, DNB_ESP) as MagicEffect
	kNPCBathSpell = Game.GetFormFromFile(0x860, DNB_ESP) as Spell
	fxTier = new MagicEffect[9]
	tierCode = new int[9]
	SetTier(0, 0x813, 0)     ; Dirty_Effect_Clean
	SetTier(1, 0x80D, 1)     ; Dirty_Effect_Dirt1
	SetTier(2, 0x80E, 2)     ; Dirty_Effect_Dirt2
	SetTier(3, 0x80F, 3)     ; Dirty_Effect_Dirt3
	SetTier(4, 0x83B, 4)     ; Dirty_Effect_Dirt4
	SetTier(5, 0x810, 11)    ; Dirty_Effect_Blood1
	SetTier(6, 0x811, 12)    ; Dirty_Effect_Blood2
	SetTier(7, 0x812, 13)    ; Dirty_Effect_Blood3
	SetTier(8, 0x83A, 14)    ; Dirty_Effect_Blood4
	kWade1 = None
	kWade2 = None
	If Game.IsPluginInstalled("WadeInWater.esp")
		kWade1 = Game.GetFormFromFile(0xD64, "WadeInWater.esp") as Spell
		kWade2 = Game.GetFormFromFile(0xD65, "WadeInWater.esp") as Spell
	EndIf
	bDnB = kBathQuest && kBathingActors && fxSoapy && fxTier[0] && fxTier[8]
	If !bDnB
		Log("Dirt and Blood is loaded but its forms were not found. Is it version 2.37?")
	EndIf
EndFunction

Function SetTier(int i, int aiFormID, int aiCode)
	fxTier[i] = Game.GetFormFromFile(aiFormID, DNB_ESP) as MagicEffect
	tierCode[i] = aiCode
EndFunction

; OCum Ascended 4.1.1 forms, and the mesh items the OCum Tull and Liquid add-on and Beast Pie put on.
Function ResolveOCum()
	bOCum = false
	kOCumQuest = None
	kHasCumFaction = None
	kAppliedCum = None
	kOCumSpell = None
	fxOCum = None
	kMeshItems = new Form[8]
	nMeshItems = 0
	If !Game.IsPluginInstalled(OCUM_ESP)
		return
	EndIf
	kOCumQuest = Game.GetFormFromFile(0x800, OCUM_ESP) as Quest
	kHasCumFaction = Game.GetFormFromFile(0xF46, OCUM_ESP) as Faction
	kAppliedCum = Game.GetFormFromFile(0xF16, OCUM_ESP) as Keyword
	kOCumSpell = Game.GetFormFromFile(0xF15, OCUM_ESP) as Spell
	fxOCum = Game.GetFormFromFile(0xF14, OCUM_ESP) as MagicEffect
	bOCum = kHasCumFaction || kAppliedCum || fxOCum
	If !bOCum
		return
	EndIf
	If Game.IsPluginInstalled(TULL_ESP)
		AddMesh(Game.GetFormFromFile(0x807, TULL_ESP))     ; creampie (slot 59)
		AddMesh(Game.GetFormFromFile(0x809, TULL_ESP))     ; creampie drip (slot 60)
		AddMesh(Game.GetFormFromFile(0x803, TULL_ESP))     ; oral (slot 59)
	EndIf
	If Game.IsPluginInstalled(LIQUID_ESP)
		AddMesh(Game.GetFormFromFile(0x803, LIQUID_ESP))   ; bottom (slot 47)
		AddMesh(Game.GetFormFromFile(0x808, LIQUID_ESP))   ; bottom SMP (slot 43)
		AddMesh(Game.GetFormFromFile(0x804, LIQUID_ESP))   ; face (slot 55)
		AddMesh(Game.GetFormFromFile(0x809, LIQUID_ESP))   ; face SMP (slot 57)
		AddMesh(Game.GetFormFromFile(0xD63, LIQUID_ESP))   ; torso (slot 36)
	EndIf
EndFunction

Function AddMesh(Form akItem)
	If akItem && nMeshItems < 8
		kMeshItems[nMeshItems] = akItem
		nMeshItems += 1
	EndIf
EndFunction

; =============================================================================================
;  Tiers
; =============================================================================================
int Function CurrentTier(Actor a)
	If !a || fxTier.Length < 9
		return -1
	EndIf
	int i = 0
	While i < 9
		If fxTier[i] && a.HasMagicEffect(fxTier[i])
			return tierCode[i]
		EndIf
		i += 1
	EndWhile
	return -1
EndFunction

int Function CodeFor(MagicEffect fx)
	If !fx || fxTier.Length < 9
		return -1
	EndIf
	int i = fxTier.Find(fx)
	If i < 0
		return -1
	EndIf
	return tierCode[i]
EndFunction

string Function TierName(int code)
	If code == 0
		return "Clean"
	ElseIf code >= 1 && code <= 4
		return "Dirt" + code
	ElseIf code >= 11 && code <= 14
		return "Blood" + (code - 10)
	EndIf
	return "Unknown"
EndFunction

string Function TierText(int code)
	If code == 0
		return "clean"
	ElseIf code == 1
		return "a little dusty from the road"
	ElseIf code == 2
		return "dirty"
	ElseIf code == 3
		return "very dirty"
	ElseIf code == 4
		return "filthy"
	ElseIf code == 11
		return "spattered with blood"
	ElseIf code == 12
		return "bloodstained"
	ElseIf code == 13
		return "covered in blood"
	ElseIf code == 14
		return "soaked in blood"
	EndIf
	return ""
EndFunction

; Called by the player alias for every filtered effect that lands on the player.
Function OnPlayerEffect(MagicEffect fx)
	If !bDnB || !fx
		return
	EndIf
	If fx == fxSoapy
		OnBathStart(PlayerRef, false, 1)
		return
	EndIf
	int code = CodeFor(fx)
	If code < 0 || code == iLastTier
		return     ; not a tier, or the same tier re-applied (e.g. on load)
	EndIf
	int old = iLastTier
	iLastTier = code
	SendState(PlayerRef, code, old)
	If SlotOf(PlayerRef) >= 0
		return     ; bathing: the bath end reports it
	EndIf
	string nm = PlayerRef.GetDisplayName()
	If bStateEvents
		SkyrimNetApi.RegisterShortLivedEvent("obdc_state_player", "obdc_state", nm + " is now " + TierText(code) + ".", "", 600000, PlayerRef, None)
	EndIf
	; narration only for a big jump: freshly covered or soaked in blood
	If bNarration && code >= 13 && (old < 13 || old > 14)
		bPendNarr = true
		iPendCode = code
		fPendWaited = 0.0
		Schedule()
	ElseIf code < 11
		bPendNarr = false     ; blood already gone again (rain, swimming)
	EndIf
	Log("player tier " + TierName(old) + " -> " + TierName(code))
EndFunction

; Called by the player alias when the player casts Dirt and Blood's "clean an NPC" spell.
; The bath starts on the target a moment later; look at Dirt and Blood's bathing list a few times.
Function OnNPCBathCast()
	If !bDnB
		return
	EndIf
	iScanLeft = 4
	Schedule()
EndFunction

Function SendState(Actor a, int code, int old)
	int h = ModEvent.Create("OBDC_StateChanged")
	If h
		ModEvent.PushForm(h, a)
		ModEvent.PushString(h, TierName(code))
		ModEvent.PushInt(h, code)
		ModEvent.PushInt(h, old)
		ModEvent.Send(h)
	EndIf
EndFunction

bool Function CanNarrate()
	return Utility.GetCurrentRealTime() - fLastNarr >= NARRATION_GAP || Utility.GetCurrentRealTime() < fLastNarr
EndFunction

Function Narrate(string asText, Actor akActor)
	fLastNarr = Utility.GetCurrentRealTime()
	SkyrimNetApi.DirectNarration(asText, akActor)
	Log("narration: " + asText)
EndFunction

; =============================================================================================
;  Baths
; =============================================================================================
int Function SlotOf(Actor a)
	If bathActor.Length < 4
		return -1
	EndIf
	return bathActor.Find(a)
EndFunction

; aiKind: 0 = our own WashUp (seen before Dirt and Blood strips and lathers),
;         1 = the player's soap lather (seen at the lather),
;         2 = found in Dirt and Blood's bathing list (seen within about 2 s of the start)
Function OnBathStart(Actor a, bool abOwned, int aiKind)
	If !a || a.IsChild() || bathActor.Length < 4
		return
	EndIf
	If SlotOf(a) >= 0
		return
	EndIf
	int s = bathActor.Find(None)
	If s < 0
		return
	EndIf
	bathActor[s] = a
	bathWaited[s] = 0.0
	bathOwned[s] = abOwned
	cumStage[s] = 0
	nBaths += 1
	; cum is looked for now, before anything is washed
	If bOCum && bCumWash && HasCum(a)
		cumStage[s] = 1
		If aiKind == 0
			cumNarrAt[s] = 6.0
			cumCleanAt[s] = 10.0
		ElseIf aiKind == 1
			cumNarrAt[s] = 2.0
			cumCleanAt[s] = 6.0
		Else
			cumNarrAt[s] = 4.0
			cumCleanAt[s] = 8.0
		EndIf
	EndIf
	int h = ModEvent.Create("OBDC_BathStart")
	If h
		ModEvent.PushForm(h, a)
		ModEvent.Send(h)
	EndIf
	If bStateEvents
		SkyrimNetApi.RegisterShortLivedEvent("obdc_bath_" + a.GetFormID(), "obdc_bath", a.GetDisplayName() + " is bathing, washing off dirt and blood.", "", 180000, a, None)
	EndIf
	Log("bath start: " + a.GetDisplayName() + Expect() + CumNote(s))
	Schedule()
EndFunction

string Function CumNote(int s)
	If cumStage[s] == 1
		return " (has cum on them: will wash it off)"
	EndIf
	return ""
EndFunction

string Function Expect()
	If bMalignis
		return " (Malignis flag on: a woman's bath runs about 65 s)"
	EndIf
	return ""
EndFunction

bool Function StillBathing(Actor a)
	If kBathingActors
		return kBathingActors.HasForm(a)
	EndIf
	return fxSoapy && a.HasMagicEffect(fxSoapy)
EndFunction

; Any actor in Dirt and Blood's bathing list that is not followed yet is a real bath
; (Dirt and Blood's NPC bath spell, a follower bathing next to you, another mod calling PlayBatheAnimation).
; Only runs while a bath is followed or just after the NPC bath spell was cast.
Function ScanBathers()
	If !kBathingActors
		return
	EndIf
	int n = kBathingActors.GetSize()
	int i = 0
	While i < n && nBaths < 4
		Actor a = kBathingActors.GetAt(i) as Actor
		If a && SlotOf(a) < 0 && staleActor.Find(a) < 0 && !a.IsDead()
			OnBathStart(a, false, 2)
		EndIf
		i += 1
	EndWhile
EndFunction

Function Schedule()
	If nBaths > 0
		RegisterForSingleUpdate(POLL)
	ElseIf iScanLeft > 0
		RegisterForSingleUpdate(SCAN_STEP)
	ElseIf bPendNarr
		RegisterForSingleUpdate(5.0)
	EndIf
EndFunction

Event OnUpdate()
	float step = 5.0
	If nBaths > 0
		step = POLL
		int i = 0
		While i < 4
			Actor a = bathActor[i]
			If a
				bathWaited[i] = bathWaited[i] + POLL
				If a.IsDead()
					EndBath(i, false)
				ElseIf bathOwned[i]
					CumTick(i)
					If bathWaited[i] >= BATH_CAP + 30.0
						EndBath(i, false)     ; our own WashUp call never came back
					EndIf
				ElseIf !StillBathing(a)
					EndBath(i, true)
				ElseIf bathWaited[i] >= BATH_CAP
					MarkStale(a)
					EndBath(i, false)
				Else
					CumTick(i)
				EndIf
			EndIf
			i += 1
		EndWhile
	ElseIf iScanLeft > 0
		step = SCAN_STEP
	EndIf
	If iScanLeft > 0 || nBaths > 0
		ScanBathers()
		If iScanLeft > 0
			iScanLeft -= 1
		EndIf
	EndIf
	If bPendNarr
		fPendWaited += step
		If fPendWaited > 180.0 || iLastTier != iPendCode
			bPendNarr = false
		ElseIf !PlayerRef.IsInCombat() && SlotOf(PlayerRef) < 0 && CanNarrate()
			bPendNarr = false
			Narrate(PlayerRef.GetDisplayName() + " is " + TierText(iPendCode) + " after the fight.", PlayerRef)
		EndIf
	EndIf
	Schedule()
EndEvent

Function MarkStale(Actor a)
	int s = staleActor.Find(None)
	If s < 0
		s = 0
	EndIf
	staleActor[s] = a
EndFunction

Function EndBath(int s, bool abDone)
	Actor a = bathActor[s]
	float secs = bathWaited[s]
	int cs = cumStage[s]
	bathActor[s] = None
	bathWaited[s] = 0.0
	bathOwned[s] = false
	cumStage[s] = 0
	nBaths -= 1
	If nBaths < 0
		nBaths = 0
	EndIf
	If !a
		return
	EndIf
	bool cum = false
	If cs == 1 || cs == 2
		; a short bath (bath animations off) ended before the mid-wash clean: clean now
		If abDone && !a.IsDead()
			CleanCum(a)
			cum = true
		EndIf
	ElseIf cs == 3
		; Dirt and Blood re-equips what it took off at the start, which can include the mesh items: take them off again
		RemoveMeshItems(a)
		cum = true
	EndIf
	string nm = a.GetDisplayName()
	If a == PlayerRef
		int code = CurrentTier(PlayerRef)
		If code >= 0
			iLastTier = code
		EndIf
		bPendNarr = false
	EndIf
	If abDone && !a.IsDead()
		string where = PlaceOf(a)
		If bMemories
			If cum
				SkyrimNetApi.RegisterPersistentEvent(nm + " bathed" + where + " and washed off the dirt, blood and cum.", a, None)
			Else
				SkyrimNetApi.RegisterPersistentEvent(nm + " bathed" + where + " and washed off the dirt and blood.", a, None)
			EndIf
		EndIf
		If bBystanders
			TellWitnesses(a, nm + " bathed nearby" + where + ".")
		EndIf
		If bNarration
			If a == PlayerRef
				If CanNarrate()
					Narrate(nm + " has finished bathing and is clean.", a)
				EndIf
			Else
				SkyrimNetApi.GenerateNPCThought(a, "You have just finished washing yourself.")
			EndIf
		EndIf
		Log("bath end: " + nm + " after about " + (secs as int) + " s")
	Else
		Log("bath end not seen for " + nm + " within " + (BATH_CAP as int) + " s; stopped following it")
	EndIf
	int h = ModEvent.Create("OBDC_BathEnd")
	If h
		ModEvent.PushForm(h, a)
		ModEvent.PushFloat(h, secs)
		ModEvent.PushBool(h, abDone)
		ModEvent.Send(h)
	EndIf
EndFunction

string Function PlaceOf(Actor a)
	Location l = a.GetCurrentLocation()
	If l
		string n = l.GetName()
		If n != ""
			return " in " + n
		EndIf
	EndIf
	return ""
EndFunction

; Persistent awareness for a few adults who can actually see it (no LLM call, no forced reply).
; Uses po3's high-process actor list rather than a cell scan.
Function TellWitnesses(Actor bather, string asText)
	If !bather.Is3DLoaded()
		return
	EndIf
	Actor[] near = PO3_SKSEFunctions.GetActorsByProcessingLevel(0)
	int told = 0
	int i = 0
	While i < near.Length && told < WITNESS_MAX
		Actor w = near[i]
		If w && w != bather && w != PlayerRef && !w.IsDead() && !w.IsChild() && (!ActorTypeNPC || w.HasKeyword(ActorTypeNPC))
			If w.GetDistance(bather) <= WITNESS_RADIUS && w.HasLOS(bather)
				SkyrimNetApi.RegisterPersistentEvent(asText, bather, w)
				told += 1
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction

; =============================================================================================
;  OCum: wash the cum off during a real bath
; =============================================================================================
; Detection, cheapest first. Called once, at the start of a bath.
bool Function HasCum(Actor a)
	If !bOCum || !a
		return false
	EndIf
	If kHasCumFaction && a.IsInFaction(kHasCumFaction)
		return true
	ElseIf kAppliedCum && a.HasMagicEffectWithKeyword(kAppliedCum)
		return true
	ElseIf fxOCum && a.HasMagicEffect(fxOCum)
		return true
	ElseIf StorageUtil.GetIntValue(a, "OBF_BL_Set", 0) != 0
		return true     ; Beast Pie mesh set still running on them
	ElseIf HasMeshItem(a)
		return true     ; Tull / Liquid Pack items (counted in the inventory: Dirt and Blood may already have taken them off)
	EndIf
	return OBDC_OCum.HasCumOverlay(a)
EndFunction

bool Function HasMeshItem(Actor a)
	int i = 0
	While i < nMeshItems
		If kMeshItems[i] && a.GetItemCount(kMeshItems[i]) > 0
			return true
		EndIf
		i += 1
	EndWhile
	return false
EndFunction

Function CumTick(int s)
	int cs = cumStage[s]
	If cs == 1 && bathWaited[s] >= cumNarrAt[s]
		cumStage[s] = 2
		CumNarration(bathActor[s])
	ElseIf cs == 2 && bathWaited[s] >= cumCleanAt[s]
		cumStage[s] = 3
		CleanCum(bathActor[s])
	EndIf
EndFunction

Function CumNarration(Actor a)
	If !bCumNarration || !a
		return
	EndIf
	float now = Utility.GetCurrentRealTime()
	If now - fLastCumNarr < CUM_NARRATION_GAP && now >= fLastCumNarr
		return
	EndIf
	If a != PlayerRef && (!a.Is3DLoaded() || a.GetDistance(PlayerRef) > CUM_NARRATION_RANGE)
		return
	EndIf
	fLastCumNarr = now
	string nm = a.GetDisplayName()
	string their = "their"
	int sex = a.GetLeveledActorBase().GetSex()
	If sex == 0
		their = "his"
	ElseIf sex == 1
		their = "her"
	EndIf
	string t
	int r = Utility.RandomInt(0, 4)
	If r == 0
		t = nm + " slides the cum between " + their + " fingers for a moment, feeling it, before washing it away."
	ElseIf r == 1
		t = nm + " rubs the cum between " + their + " fingertips, lingering on the feel of it, then rinses it off."
	ElseIf r == 2
		t = "Before scrubbing it off, " + nm + " smears the cum slowly between " + their + " fingers."
	ElseIf r == 3
		t = nm + " pauses mid-wash and rolls the cum between " + their + " fingers, feeling it, before letting the water take it."
	Else
		t = nm + " gathers some of the cum on " + their + " fingers and rubs it a moment before washing it away."
	EndIf
	SkyrimNetApi.DirectNarration(t, a)
	Log("narration: " + t)
EndFunction

; OCum's own clean (as its water clean does), whatever OCum's "clean cum when entering water" option says.
Function CleanCum(Actor a)
	If !bOCum || !a
		return
	EndIf
	If kOCumSpell && fxOCum && a.HasMagicEffect(fxOCum)
		a.DispelSpell(kOCumSpell)
	EndIf
	If kOCumQuest
		OBDC_OCum.Clean(kOCumQuest, a)
	EndIf
	RemoveMeshItems(a)
	int h = ModEvent.Create("OBDC_CumWashed")
	If h
		ModEvent.PushForm(h, a)
		ModEvent.Send(h)
	EndIf
	Log("cum washed off " + a.GetDisplayName())
EndFunction

; Backup for the Tull / Liquid Pack items. Their own loops (OCum Tull and Liquid add-on, Beast Pie) keep re-equipping
; them while they run, so their stamps are moved on first: the old loop then stops without touching the items.
Function RemoveMeshItems(Actor a)
	If nMeshItems <= 0
		return
	EndIf
	bool any = StorageUtil.GetIntValue(a, "OBF_BL_Set", 0) != 0
	int i = 0
	While i < nMeshItems && !any
		If kMeshItems[i] && a.GetItemCount(kMeshItems[i]) > 0
			any = true
		EndIf
		i += 1
	EndWhile
	If !any
		return
	EndIf
	StorageUtil.AdjustIntValue(a, "OBF_BL_Stamp", 1)
	StorageUtil.AdjustIntValue(a, "OCumTL_Stamp0", 1)
	StorageUtil.AdjustIntValue(a, "OCumTL_Stamp1", 1)
	i = 0
	While i < nMeshItems
		Form it = kMeshItems[i]
		If it && a.GetItemCount(it) > 0
			a.UnequipItem(it, false, true)
			a.RemoveItem(it, 99, true, None)
		EndIf
		i += 1
	EndWhile
	StorageUtil.UnsetIntValue(a, "OBF_BL_Set")
	StorageUtil.UnsetIntValue(a, "OBF_BL_Round")
EndFunction

; =============================================================================================
;  WashUp action (followers)
; =============================================================================================
Function ApplyWashUpToggle()
	SkyrimNetApi.SetActionCooldown(ACTION_NAME, WASHUP_COOLDOWN)
	If OBDC_WashUpEnabled && OBDC_WashUpEnabled.GetValue() != 1.0
		If SkyrimNetApi.IsActionRegistered(ACTION_NAME)
			SkyrimNetApi.UnregisterAction(ACTION_NAME)
		EndIf
	EndIf
EndFunction

Function WashUpNow(Actor akActor)
	If !akActor || akActor == PlayerRef || akActor.IsDead() || akActor.IsChild()
		return
	EndIf
	If !OBDC_WashUpEnabled || OBDC_WashUpEnabled.GetValue() != 1.0
		return
	EndIf
	If !bDnB
		Resolve()
		If !bDnB
			return
		EndIf
	EndIf
	string why = WashBlocker(akActor)
	If why != ""
		SkyrimNetApi.GenerateNPCThought(akActor, why)
		Log("WashUp refused for " + akActor.GetDisplayName() + ": " + why)
		return
	EndIf
	bool soap = gSoapReq && gSoapReq.GetValue() == 1.0
	int h = ModEvent.Create("OBDC_DoWash")
	If h
		ModEvent.PushForm(h, akActor)
		ModEvent.PushBool(h, soap)
		ModEvent.Send(h)
	EndIf
EndFunction

string Function WashBlocker(Actor a)
	If a.IsInCombat()
		return "You wanted to wash, but you are in the middle of a fight."
	ElseIf a.IsWeaponDrawn()
		return "You wanted to wash, but your weapon is still drawn."
	ElseIf InScene(a)
		return "You wanted to wash, but you are busy with something else right now."
	ElseIf kBathingActors.HasForm(a)
		return "You are already washing."
	ElseIf gWaterReq && gWaterReq.GetValue() == 1.0 && !HasWater(a)
		return "You wanted to wash, but there is no water here. You would need a river, a lake or a waterfall."
	ElseIf gSoapReq && gSoapReq.GetValue() == 1.0 && (!kSoaps || !PO3_SKSEFunctions.FindFirstItemInList(a, kSoaps))
		return "You wanted to wash, but you have no soap."
	EndIf
	return ""
EndFunction

bool Function InScene(Actor a)
	If Game.IsPluginInstalled("OStim.esp") && OActor.IsInOStim(a)
		return true
	EndIf
	If Game.IsPluginInstalled("SexLab.esm")
		Faction f = Game.GetFormFromFile(0xE50F, "SexLab.esm") as Faction
		If f && a.IsInFaction(f)
			return true
		EndIf
	EndIf
	return false
EndFunction

; Same water rule as Dirt and Blood's own soap: the waterfall lists at the same heights and radii,
; or a WadeInWater spell; swimming and po3's in-water check count too.
bool Function HasWater(Actor a)
	If a.IsSwimming() || PO3_SKSEFunctions.IsActorInWater(a)
		return true
	EndIf
	If kWade1 && a.HasSpell(kWade1)
		return true
	ElseIf kWade2 && a.HasSpell(kWade2)
		return true
	EndIf
	float x = a.GetPositionX()
	float y = a.GetPositionY()
	float z = a.GetPositionZ()
	If kFall256 && Game.FindClosestReferenceOfAnyTypeInList(kFall256, x, y, z + 256.0, 312.0)
		return true
	ElseIf kFall512 && Game.FindClosestReferenceOfAnyTypeInList(kFall512, x, y, z + 512.0, 512.0)
		return true
	ElseIf kFall2048 && Game.FindClosestReferenceOfAnyTypeInList(kFall2048, x, y, z + 2048.0, 1000.0)
		return true
	ElseIf kFall4096 && Game.FindClosestReferenceOfAnyTypeInList(kFall4096, x, y, z + 4096.0, 1000.0)
		return true
	EndIf
	return false
EndFunction

; Runs on its own stack: Dirt and Blood's PlayBatheAnimation blocks until the bath is over.
Event OnDoWash(Form akForm, bool abSoap)
	Actor a = akForm as Actor
	If !a || !kBathQuest || kBathingActors.HasForm(a)
		return
	EndIf
	OnBathStart(a, true, 0)
	kBathQuest.PlayBatheAnimation(a, false, abSoap)
	int s = SlotOf(a)
	If s >= 0
		EndBath(s, true)
		Schedule()
	EndIf
EndEvent

; =============================================================================================
Function Log(string asMsg)
	Debug.Trace("[OBDC] " + asMsg)
	If bDebug
		Debug.Notification("OBDC: " + asMsg)
	EndIf
EndFunction
