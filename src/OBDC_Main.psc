Scriptname OBDC_Main extends Quest
{O'Blood, Dirt and Cum v0.5.7. A SkyrimNet companion for Dirt and Blood and/or OCum, by That Guy (Coronerra).
 Both are optional and found at run time; at least one is needed for the mod to do anything:
   Dirt and Blood only: hygiene facts, state and bath events, bath memories, WashUp.
   OCum only: nothing runs in Papyrus; the hygiene prompt tells SkyrimNet who has cum on them.
   Both: all of the above, and a real Dirt and Blood bath washes OCum's cum off.
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
GlobalVariable Property OBDC_DnBFound Auto            ; 1 while Dirt and Blood is found; read by the WashUp action's eligibility rule (0.2)
GlobalVariable Property OBDC_NormBathing Auto         ; 0.5: 1 = open/communal bathing is ordinary (prompt)
GlobalVariable Property OBDC_NormBathingSex Auto      ; 0.5: 1 = intimacy in bathing spots is ordinary (prompt)
GlobalVariable Property OBDC_NearbyWater Auto         ; 0.5: 0 none, 1 open water, 2 pool/tub nearby (prompt)
GlobalVariable Property OBDC_AllNPCsWashUp Auto       ; 0.5: 1 = nearby non-followers may WashUp
Quest Property TravelQuest Auto                       ; 0.5: OBDC_TravelQuest (travel aliases + packages)
ReferenceAlias Property TravelActor0 Auto
ReferenceAlias Property TravelDest0 Auto
ReferenceAlias Property TravelActor1 Auto
ReferenceAlias Property TravelDest1 Auto
ReferenceAlias Property TravelActor2 Auto
ReferenceAlias Property TravelDest2 Auto
ReferenceAlias Property TravelActor3 Auto
ReferenceAlias Property TravelDest3 Auto
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
int Property VERSION = 5 AutoReadOnly                ; 0.5

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
bool Property bWalkToWater = true Auto Hidden         ; 0.5: find real water and walk to it
float Property fWaterSearchRadius = 2000.0 Auto Hidden ; 0.5: MCM 500-3500
float Property WALK_TIMEOUT = 24.0 AutoReadOnly
float Property WALK_ARRIVE = 80.0 AutoReadOnly
float Property WALK_ARRIVE_TUB = 150.0 AutoReadOnly
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
Form kPseudoArmor             ; 0.5.4: OCumPseudoArmor 0xF49 (OCum's RaceMenu redraw workaround)
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
bool[] cumOk                  ; 0.5.3: true once the mid-bath clean was verified
string sCumLeft = ""         ; 0.5.3: what the last verify still found ("" = nothing)
float[] cumNarrAt
float[] cumCleanAt
Actor[] staleActor            ; still listed by Dirt and Blood long after their bath; not followed again
int nBaths = 0

; 0.5 walk-to-water: only while an NPC is actually walking (no idle polling)
ObjectReference kProbe
ObjectReference[] kDest
Actor[] walkActor
float[] walkWait
bool[] walkTub
float[] walkTubX
float[] walkTubY
float[] walkTubZ
float[] walkLastX
float[] walkLastY
float[] walkLastZ
int[] walkStall
int[] walkRetries
int nWalks = 0
Cell kLastWaterCell
ReferenceAlias[] kWalkActorAlias
ReferenceAlias[] kWalkDestAlias

; =============================================================================================
;  Start-up
; =============================================================================================
Event OnInit()
	If IsRunning()
		Startup()
	EndIf
EndEvent

Function Startup()
	LogSessionStart()      ; 0.4: OBloodDirtCum.log, new section per game load
	ReadSettings(false)
	Resolve()
	bathActor = new Actor[4]
	bathWaited = new float[4]
	bathOwned = new bool[4]
	cumStage = new int[4]
	cumOk = new bool[4]
	cumNarrAt = new float[4]
	cumCleanAt = new float[4]
	staleActor = new Actor[4]
	nBaths = 0
	iScanLeft = 0
	bPendNarr = false
	UnregisterForUpdate()
	UnregisterForModEvent("OBDC_DoWash")
	If bDnB
		PlayerAlias.Arm(fxTier, fxSoapy, kNPCBathSpell)
		iLastTier = CurrentTier(PlayerRef)
		RegisterForModEvent("OBDC_DoWash", "OnDoWash")
	Else
		; OCum only, or nothing found: no listeners, no updates. The prompt alone carries OCum's cum fact.
		PlayerAlias.Disarm()
		iLastTier = -1
	EndIf
	SetDnBFound()
	ApplyWashUpToggle()
	If bDnB
		EnsureTravel()
	EndIf
	UpdateNearbyWater(true)
	Log("started (" + ModeName() + "). Dirt and Blood " + bDnB + ", OCum " + bOCum + " (" + nMeshItems + " mesh items), Malignis flag " + bMalignis + ", Malignis plugin " + bMalignisLoaded + ", player tier " + TierName(iLastTier))
	LogStartup()
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
	bWalkToWater = JsonUtil.GetIntValue(SETTINGS_FILE, "walk_to_water", 1) == 1
	fWaterSearchRadius = JsonUtil.GetIntValue(SETTINGS_FILE, "water_search_radius", 2000) as float
	If fWaterSearchRadius < 500.0
		fWaterSearchRadius = 500.0
	ElseIf fWaterSearchRadius > 3500.0
		fWaterSearchRadius = 3500.0
	EndIf
	If OBDC_NormBathing
		OBDC_NormBathing.SetValue(JsonUtil.GetIntValue(SETTINGS_FILE, "norm_bathing", 1) as float)
	EndIf
	If OBDC_NormBathingSex
		OBDC_NormBathingSex.SetValue(JsonUtil.GetIntValue(SETTINGS_FILE, "norm_bathing_sex", 1) as float)
	EndIf
	If OBDC_AllNPCsWashUp
		OBDC_AllNPCsWashUp.SetValue(JsonUtil.GetIntValue(SETTINGS_FILE, "all_npcs_washup", 1) as float)
	EndIf
EndFunction

Function Resolve()
	bMalignisLoaded = Game.IsPluginInstalled(MALIGNIS_ESP)
	ResolveOCum()
	bDnB = false
	kBathQuest = None
	kBathingActors = None
	kSoaps = None
	gSoapReq = None
	gWaterReq = None
	fxSoapy = None
	kNPCBathSpell = None
	If !Game.IsPluginInstalled(DNB_ESP)
		fxTier = new MagicEffect[1]     ; no tiers: CurrentTier / CodeFor see Length < 9
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

; The WashUp action is only offered while Dirt and Blood is found (eligibility rule on OBDC_DnBFound).
Function SetDnBFound()
	If !OBDC_DnBFound
		OBDC_DnBFound = Game.GetFormFromFile(0x805, "OBlood_Dirt_and_Cum.esp") as GlobalVariable   ; a 0.1 save before the property was filled
	EndIf
	If OBDC_DnBFound
		OBDC_DnBFound.SetValue(bDnB as float)
	EndIf
EndFunction

string Function ModeName()
	If bDnB && bOCum
		return "Dirt and Blood + OCum"
	ElseIf bDnB
		return "Dirt and Blood only"
	ElseIf bOCum
		return "OCum only"
	EndIf
	return "neither Dirt and Blood nor OCum found"
EndFunction

; OCum Ascended 4.1.1 forms, and the mesh items the OCum Tull and Liquid add-on and Beast Pie put on.
Function ResolveOCum()
	bOCum = false
	kOCumQuest = None
	kHasCumFaction = None
	kAppliedCum = None
	kOCumSpell = None
	fxOCum = None
	kPseudoArmor = None
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
	kPseudoArmor = Game.GetFormFromFile(0xF49, OCUM_ESP)
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
	cumOk[s] = false
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
	If nBaths > 0 || nWalks > 0
		RegisterForSingleUpdate(POLL)
	ElseIf iScanLeft > 0
		RegisterForSingleUpdate(SCAN_STEP)
	ElseIf bPendNarr
		RegisterForSingleUpdate(5.0)
	EndIf
EndFunction

Event OnUpdate()
	float step = 5.0
	If nWalks > 0
		TickWalks()
	EndIf
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
	bool wasOk = cumOk[s]
	cumOk[s] = false
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
	bool cumClean = true
	If cs == 1 || cs == 2
		; a short bath (bath animations off) ended before the mid-wash clean: clean now
		If abDone && !a.IsDead()
			cumClean = CleanCum(a)
			cum = true
		EndIf
	ElseIf cs == 3 && !a.IsDead()
		; Dirt and Blood re-equips what it took off at the start, which can include the mesh items:
		; take them off again, and check once more before anyone is told the cum is gone
		cumClean = VerifyAtEnd(a, wasOk)
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
			If cum && !cumClean
				SkyrimNetApi.RegisterPersistentEvent(nm + " bathed" + where + " and washed off the dirt and blood, but some cum is still on " + PossOf(a) + " " + LeftArea() + ".", a, None)
			ElseIf cum
				SkyrimNetApi.RegisterPersistentEvent(nm + " bathed" + where + " and washed off the dirt, blood and cum.", a, None)
			Else
				SkyrimNetApi.RegisterPersistentEvent(nm + " bathed" + where + " and washed off the dirt and blood.", a, None)
			EndIf
		EndIf
		If bBystanders
			TellWitnesses(a, nm + " bathed nearby" + where + ".")
		EndIf
		If bNarration
			If cum && !cumClean
				If a == PlayerRef
					If CanNarrate()
						Narrate(nm + " has finished bathing, but there is still cum on " + PossOf(a) + " " + LeftArea() + ".", a)
					EndIf
				Else
					SkyrimNetApi.GenerateNPCThought(a, "You have just finished washing yourself, but there is still cum on your " + LeftArea() + ".")
				EndIf
			ElseIf a == PlayerRef
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
	ElseIf OBDC_OCum.HasCumOverlay(a)
		return true     ; any cum-looking overlay, both gender keys (0.5.3)
	EndIf
	return CumItemsOn(a, false) != ""     ; any other cum armor in the inventory (0.5.3)
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
		cumOk[s] = CleanCum(bathActor[s], false)   ; 0.5.6: no redraw mid-bath (it froze Dirt and Blood's soap on); the bath end redraws
	EndIf
EndFunction

Function CumNarration(Actor a)
	If !bCumNarration || !a
		return
	EndIf
	float now = Utility.GetCurrentRealTime()
	If now - fLastCumNarr < CUM_NARRATION_GAP && now >= fLastCumNarr
		Log("cum narration skipped for " + a.GetDisplayName() + ": another one less than 30 s ago")
		return
	EndIf
	If a != PlayerRef && (!a.Is3DLoaded() || a.GetDistance(PlayerRef) > CUM_NARRATION_RANGE)
		Log("cum narration skipped for " + a.GetDisplayName() + ": too far from you")
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

; 0.5.3: a full wash, then a check. Returns true only once nothing is left on them.
; 1) OCum's own clean (as its water clean does, whatever OCum's "clean cum when entering water" option says),
; 2) the loops that put cum back on are stopped, 3) OBDC strips every cum-looking overlay slot itself and
; 4) takes off every cum mesh item, 5) after a short wait it checks again; one more pass if anything is left.
; Only "cum washed off" and OBDC_CumWashed when the check is clean; otherwise OCum's faction is put back
; so SkyrimNet still knows. One-shot at bath time; no polling.
bool Function CleanCum(Actor a, bool abRedraw = true)
	If !bOCum || !a
		return true
	EndIf
	string nm = a.GetDisplayName()
	bool redraw = WashPass(a)
	Utility.Wait(1.5)
	string left = CumLeft(a)
	If left != ""
		Log("after the wash, still on " + nm + ": " + left + " | second pass")
		redraw = WashPass(a) || redraw
		Utility.Wait(1.0)
		left = CumLeft(a)
	EndIf
	; 0.5.5: always redraw. OCum's own water clean often removes the overlays before our pass runs,
	; so we see nothing left to strip, but RaceMenu still shows the stale cum until something redraws.
	If abRedraw
		RedrawOverlays(a)
	EndIf
	return Settle(a, left)
EndFunction

; Bath end after a mid-bath clean: Dirt and Blood has put the worn items back, so strip and check once more.
bool Function VerifyAtEnd(Actor a, bool abWasOk)
	If !bOCum || !a
		return true
	EndIf
	StopCumLoops(a)
	RemoveMeshItems(a)
	; 0.5.6: give Dirt and Blood time to take its soap overlay off, then sweep cum overlays once more
	; and redraw once, after everything else has finished touching her.
	Utility.Wait(2.0)
	OBDC_OCum.ScanOverlays(a, true, true)
	string left = CumLeft(a)
	If left != ""
		Log("at bath end, still on " + a.GetDisplayName() + ": " + left + " | another pass")
		WashPass(a)
		Utility.Wait(1.0)
		left = CumLeft(a)
	EndIf
	RedrawOverlays(a)
	If left == "" && abWasOk
		return true     ; still clean, already logged and announced
	EndIf
	return Settle(a, left)
EndFunction

bool Function Settle(Actor a, string asLeft)
	string nm = a.GetDisplayName()
	sCumLeft = asLeft
	If asLeft != ""
		If kHasCumFaction && !a.IsInFaction(kHasCumFaction)
			a.AddToFaction(kHasCumFaction)      ; keep the "has cum on them" fact for SkyrimNet
		EndIf
		Log("cum still on " + nm + ": " + asLeft)
		return false
	EndIf
	int h = ModEvent.Create("OBDC_CumWashed")
	If h
		ModEvent.PushForm(h, a)
		ModEvent.Send(h)
	EndIf
	Log("cum washed off " + nm + " (checked: no cum overlays, cum items or OCum marks left)")
	return true
EndFunction

; Returns true if any cum overlay was on them before this pass (so they need one redraw afterwards).
bool Function WashPass(Actor a)
	bool had = OBDC_OCum.ScanOverlays(a, false, false) != ""
	StopCumLoops(a)
	If kOCumSpell
		a.DispelSpell(kOCumSpell)
	EndIf
	If kOCumQuest
		OBDC_OCum.Clean(kOCumQuest, a)
	EndIf
	If kHasCumFaction
		a.RemoveFromFaction(kHasCumFaction)
	EndIf
	string stripped = OBDC_OCum.ScanOverlays(a, true, true)
	If stripped != ""
		Log("stripped overlays left after OCum's clean on " + a.GetDisplayName() + ": " + stripped)
	EndIf
	RemoveMeshItems(a)
	return had
EndFunction

; 0.5.4: RaceMenu keeps drawing removed overlays until a reload. OCum's own workaround forces the redraw:
; put its invisible pseudo armor on for a moment (only while the body slot is free, as OCum does), then take it off.
; Once per wash, never in a scene.
Function RedrawOverlays(Actor a)
	If !a.Is3DLoaded()
		return
	EndIf
	If InScene(a)
		NiOverride.ApplyNodeOverrides(a)
		Log("overlay redraw on " + a.GetDisplayName() + ": in a scene, overrides reapplied only")
		return
	EndIf
	; 0.5.7: for NPCs, a quick Disable/Enable is the only thing that reliably drops RaceMenu's stale overlays
	; (same as leaving and re-entering the cell). Not for the player, the dead, riders, or anyone in combat.
	If a != PlayerRef && !a.IsDead() && !a.IsOnMount() && !a.IsInCombat()
		a.Disable(false)
		Utility.Wait(0.1)
		a.Enable(false)
		Log("overlay redraw on " + a.GetDisplayName() + ": disable/enable")
		return
	EndIf
	If kPseudoArmor && !a.GetWornForm(0x00000004)
		a.EquipItem(kPseudoArmor, false, true)
		Utility.Wait(0.05)
		NiOverride.AddOverlays(a)
		NiOverride.ApplyNodeOverrides(a)
		Utility.Wait(0.05)
		a.UnequipItem(kPseudoArmor, false, true)
		a.RemoveItem(kPseudoArmor, 99, true, None)
		Utility.Wait(0.1)
		NiOverride.ApplyNodeOverrides(a)
		a.QueueNiNodeUpdate()
		Log("overlay redraw on " + a.GetDisplayName() + ": OCum pseudo armor")
	Else
		NiOverride.AddOverlays(a)
		NiOverride.ApplyNodeOverrides(a)
		a.QueueNiNodeUpdate()
		Log("overlay redraw on " + a.GetDisplayName() + ": node update")
	EndIf
EndFunction

; Moves on the stamps of every loop that re-applies cum (Beast Form's mesh set and Beast Pie, OCumTL's pie):
; each old loop then stops at its next check without touching her again.
Function StopCumLoops(Actor a)
	StorageUtil.AdjustIntValue(a, "OBF_BL_Stamp", 1)
	int k = 0
	While k < 6
		StorageUtil.AdjustIntValue(a, "OCumBP_Stamp" + k, 1)
		If k < 3
			StorageUtil.AdjustIntValue(a, "OCumTL_Stamp" + k, 1)
		EndIf
		k += 1
	EndWhile
	StorageUtil.UnsetIntValue(a, "OBF_BL_Set")
	StorageUtil.UnsetIntValue(a, "OBF_BL_Round")
	StorageUtil.UnsetFloatValue(a, "OBF_BL_Last")
EndFunction

; What is still on them, as a readable list ("" = clean).
string Function CumLeft(Actor a)
	string left = OBDC_OCum.ScanOverlays(a, false, false)
	string items = CumItemsOn(a, false)
	If items != ""
		left = Join(left, items)
	EndIf
	If kHasCumFaction && a.IsInFaction(kHasCumFaction)
		left = Join(left, "OCum_HasCumFaction")
	EndIf
	If kAppliedCum && a.HasMagicEffectWithKeyword(kAppliedCum)
		left = Join(left, "effect with OCumAppliedCum")
	EndIf
	If fxOCum && a.HasMagicEffect(fxOCum)
		left = Join(left, "OCumMagicEffect")
	EndIf
	return left
EndFunction

string Function Join(string a, string b)
	If a == ""
		return b
	EndIf
	return a + "; " + b
EndFunction

; Where the leftover is, for the memory and the thought.
string Function LeftArea()
	If StringUtil.Find(sCumLeft, "Face ") >= 0
		return "face"
	EndIf
	return "body"
EndFunction

string Function PossOf(Actor a)
	int sex = a.GetLeveledActorBase().GetSex()
	If sex == 0
		return "his"
	ElseIf sex == 1
		return "her"
	EndIf
	return "their"
EndFunction

; The Tull / Liquid Pack items (known list), plus any other cum armor in their inventory, worn or not.
; Their own loops (OCum Tull and Liquid add-on, Beast Pie) are stopped first by StopCumLoops.
Function RemoveMeshItems(Actor a)
	int i = 0
	While i < nMeshItems
		Form it = kMeshItems[i]
		If it && a.GetItemCount(it) > 0
			a.UnequipItem(it, false, true)
			a.RemoveItem(it, 99, true, None)
		EndIf
		i += 1
	EndWhile
	string other = CumItemsOn(a, true)
	If other != ""
		Log("took off cum items on " + a.GetDisplayName() + ": " + other)
	EndIf
EndFunction

; One pass over the inventory (only at bath time). Armor counts as cum if its name or model looks like cum,
; or it comes from Tull Animated Creampie, Liquid Pack v2 or OCum. abRemove: unequip and remove them.
string Function CumItemsOn(Actor a, bool abRemove)
	string found = ""
	Form[] hit = new Form[32]
	int nHit = 0
	int n = a.GetNumItems()
	int i = 0
	While i < n && nHit < 32
		Armor ar = a.GetNthForm(i) as Armor
		If ar && IsCumArmor(ar)
			hit[nHit] = ar
			nHit += 1
		EndIf
		i += 1
	EndWhile
	i = 0
	While i < nMeshItems
		Form it = kMeshItems[i]
		If it && nHit < 32 && hit.Find(it) < 0 && a.GetItemCount(it) > 0
			hit[nHit] = it
			nHit += 1
		EndIf
		i += 1
	EndWhile
	i = 0
	While i < nHit
		Form it = hit[i]
		found = Join(found, "item " + it.GetName() + " [" + PO3_SKSEFunctions.GetFormModName(it, false) + " " + IntToHex(it.GetFormID()) + "]")
		If abRemove
			a.UnequipItem(it, false, true)
			a.RemoveItem(it, 99, true, None)
		EndIf
		i += 1
	EndWhile
	return found
EndFunction

bool Function IsCumArmor(Armor ar)
	string mn = PO3_SKSEFunctions.GetFormModName(ar, false)
	If mn == TULL_ESP || mn == LIQUID_ESP || mn == OCUM_ESP
		return true
	EndIf
	If LooksCum(ar.GetName())
		return true
	EndIf
	If LooksCum(ar.GetModelPath(true)) || LooksCum(ar.GetModelPath(false))
		return true
	EndIf
	If ar.GetNumArmorAddons() > 0
		ArmorAddon aa = ar.GetNthArmorAddon(0)
		If aa && (LooksCum(aa.GetModelPath(false, true)) || LooksCum(aa.GetModelPath(false, false)))
			return true
		EndIf
	EndIf
	return false
EndFunction

; Case-insensitive (StringUtil.Find ignores case). Common words that merely contain "cum" are skipped.
bool Function LooksCum(string s)
	If s == ""
		return false
	EndIf
	If StringUtil.Find(s, "creampie") >= 0 || StringUtil.Find(s, "semen") >= 0 || StringUtil.Find(s, "facial") >= 0
		return true
	EndIf
	int p = StringUtil.Find(s, "cum")
	While p >= 0
		bool skip = false
		If p >= 2
			string pre = StringUtil.Substring(s, p - 2, 2)
			skip = pre == "do" || pre == "cu" || pre == "ir" || pre == "ac"   ; document, cucumber, circum, accum
		EndIf
		If !skip
			return true
		EndIf
		p = StringUtil.Find(s, "cum", p + 1)
	EndWhile
	return false
EndFunction

string Function IntToHex(int v)
	string digits = "0123456789ABCDEF"
	string out = ""
	int i = 0
	While i < 8
		int nib = Math.LogicalAnd(Math.RightShift(v, 28 - i * 4), 0xF)
		out += StringUtil.GetNthChar(digits, nib)
		i += 1
	EndWhile
	return out
EndFunction

; =============================================================================================
;  0.5: travel markers, real-water search, walk-to-bathe
; =============================================================================================
Function EnsureTravel()
	If kDest.length != 4
		kDest = new ObjectReference[4]
		walkActor = new Actor[4]
		walkWait = new float[4]
		walkTub = new bool[4]
		walkTubX = new float[4]
		walkTubY = new float[4]
		walkTubZ = new float[4]
		kWalkActorAlias = new ReferenceAlias[4]
		kWalkDestAlias = new ReferenceAlias[4]
		kWalkActorAlias[0] = TravelActor0
		kWalkDestAlias[0] = TravelDest0
		kWalkActorAlias[1] = TravelActor1
		kWalkDestAlias[1] = TravelDest1
		kWalkActorAlias[2] = TravelActor2
		kWalkDestAlias[2] = TravelDest2
		kWalkActorAlias[3] = TravelActor3
		kWalkDestAlias[3] = TravelDest3
	EndIf
	Form xm = Game.GetFormFromFile(0x3B, "Skyrim.esm")
	If !xm
		Log("walk-to-water: vanilla XMarker 0x3B was not found")
		return
	EndIf
	If walkLastX.length != 4
		walkLastX = new float[4]
		walkLastY = new float[4]
		walkLastZ = new float[4]
		walkStall = new int[4]
		walkRetries = new int[4]
	EndIf
	If !kProbe
		kProbe = PlayerRef.PlaceAtMe(xm, 1, true, false)
	ElseIf kProbe.IsDisabled()
		kProbe.EnableNoWait()
	EndIf
	int i = 0
	While i < 4
		If !kDest[i]
			kDest[i] = PlayerRef.PlaceAtMe(xm, 1, true, true)
		EndIf
		If kDest[i]
			If kDest[i].IsDisabled()
				kDest[i].EnableNoWait()
			EndIf
			If kWalkDestAlias[i]
				kWalkDestAlias[i].ForceRefTo(kDest[i])
			EndIf
		EndIf
		i += 1
	EndWhile
	If TravelQuest && !TravelQuest.IsRunning()
		TravelQuest.Start()
	EndIf
EndFunction

Function ApplyWalkToWater()
	If !bWalkToWater
		AbortAllWalks("Walk to nearby water was turned off.")
		SetNearbyWater(0)
		kLastWaterCell = None
	Else
		UpdateNearbyWater(true)
	EndIf
EndFunction

Function SetNearbyWater(int aiVal)
	If OBDC_NearbyWater
		OBDC_NearbyWater.SetValue(aiVal as float)
	EndIf
EndFunction

; One-shot: on load, location change, or a new player cell. Never on a timer.
Function UpdateNearbyWater(bool abForce = false)
	If !bDnB || !bWalkToWater
		SetNearbyWater(0)
		kLastWaterCell = None
		return
	EndIf
	Cell c = PlayerRef.GetParentCell()
	If !abForce && c && c == kLastWaterCell
		return
	EndIf
	kLastWaterCell = c
	EnsureTravel()
	If !kProbe
		SetNearbyWater(0)
		return
	EndIf
	int kind = 0
	If HasWater(PlayerRef)
		kind = 1
	EndIf
	; Prefer a real water activator (tub/pool) when one is in range
	If FindWaterNear(PlayerRef, true)
		If iFoundKind == 2
			kind = 2
		ElseIf kind == 0
			kind = 1
		EndIf
	EndIf
	SetNearbyWater(kind)
	If bDebug
		Log("nearby water: " + kind + " (2=pool/tub, 1=open water, 0=none)")
	EndIf
EndFunction

; Search outputs (used by FindWaterNear / walk start)
bool bFoundWater
int iFoundKind            ; 1 = open water / waterfall, 2 = real tub/pool activator
float fFoundX
float fFoundY
float fFoundZ
bool bFoundTub
float fFoundTubX
float fFoundTubY
float fFoundTubZ

Function ClearFound()
	bFoundWater = false
	iFoundKind = 0
	bFoundTub = false
	fFoundX = 0.0
	fFoundY = 0.0
	fFoundZ = 0.0
	fFoundTubX = 0.0
	fFoundTubY = 0.0
	fFoundTubZ = 0.0
EndFunction

Function AcceptFound(int aiKind, float x, float y, float z, bool abTub, float tx, float ty, float tz)
	bFoundWater = true
	iFoundKind = aiKind
	fFoundX = x
	fFoundY = y
	fFoundZ = z
	bFoundTub = abTub
	fFoundTubX = tx
	fFoundTubY = ty
	fFoundTubZ = tz
EndFunction

bool Function BetterThanFound(ObjectReference a, float x, float y, float z)
	If !bFoundWater
		return true
	EndIf
	return Dist2(a, x, y, z) < Dist2(a, fFoundX, fFoundY, fFoundZ)
EndFunction

float Function Dist2(ObjectReference a, float x, float y, float z)
	float dx = a.GetPositionX() - x
	float dy = a.GetPositionY() - y
	float dz = a.GetPositionZ() - z
	return dx * dx + dy * dy + dz * dz
EndFunction

Function MoveProbe(float x, float y, float z, ObjectReference akNear)
	If !kProbe
		return
	EndIf
	If akNear
		kProbe.MoveTo(akNear)
	EndIf
	kProbe.SetPosition(x, y, z)
EndFunction

bool Function ProbeInWater()
	return kProbe && PO3_SKSEFunctions.IsRefInWater(kProbe)
EndFunction

; Depth at a navmesh-snapped point: wet at floor and at +20, not over the head at +95.
bool Function ProbeWadeable(float x, float y, float z, ObjectReference akNear)
	MoveProbe(x, y, z, akNear)
	If !ProbeInWater()
		return false
	EndIf
	MoveProbe(x, y, z + 20.0, akNear)
	If !ProbeInWater()
		return false
	EndIf
	MoveProbe(x, y, z + 95.0, akNear)
	If ProbeInWater()
		return false
	EndIf
	return true
EndFunction

; abActivatorsOnly: used by the nearby-water cell check when we only need to know if a tub/pool exists.
; Returns true and fills the Found* values with the closest valid target.
bool Function FindWaterNear(Actor a, bool abKeepOutdoor = true)
	ClearFound()
	If !a || !kProbe
		return false
	EndIf
	float radius = fWaterSearchRadius
	If radius < 500.0
		radius = 500.0
	ElseIf radius > 3500.0
		radius = 3500.0
	EndIf
	int tests = 0

	; 1. Real water activators (form type 24). Fake decorative water is usually a static and never appears here.
	ObjectReference[] acts = PO3_SKSEFunctions.FindAllReferencesOfFormType(a, 24, radius)
	If acts
		int n = acts.Length
		int i = 0
		While i < n && tests < 48
			ObjectReference act = acts[i]
			If act && act != kProbe
				float ax = act.GetPositionX()
				float ay = act.GetPositionY()
				float az = act.GetPositionZ()
				If Dist2(a, ax, ay, az) <= radius * radius
					; Real engine water only: probe just under the activator surface
					MoveProbe(ax, ay, az - 12.0, act)
					If ProbeInWater()
						tests += 1
						kProbe.SetPosition(ax, ay, az)
						PO3_SKSEFunctions.MoveToNearestNavmeshLocation(kProbe)
						float nx = kProbe.GetPositionX()
						float ny = kProbe.GetPositionY()
						float nz = kProbe.GetPositionZ()
						If ProbeWadeable(nx, ny, nz, act)
							If BetterThanFound(a, nx, ny, nz)
								AcceptFound(2, nx, ny, nz, false, 0.0, 0.0, 0.0)
							EndIf
						Else
							; Rimmed tub: the basin is real water, but the navmesh stops at the rim.
							float rx = ax - nx
							float ry = ay - ny
							float rz = az - nz
							If (rx * rx + ry * ry + rz * rz) <= 40000.0    ; 200 units
								MoveProbe(ax, ay, az - 12.0, act)
								If ProbeInWater() && BetterThanFound(a, nx, ny, nz)
									float stepZ = nz
									If stepZ < az - 40.0
										stepZ = az - 20.0
									EndIf
									AcceptFound(2, nx, ny, nz, true, ax, ay, stepZ)
								EndIf
							EndIf
						EndIf
					Else
						tests += 1
					EndIf
				EndIf
			EndIf
			i += 1
		EndWhile
	EndIf

	; 2. Real cell water (sunken indoor pools, rivers, lakes): tight inner rings first, stops after first wet ring
	If abKeepOutdoor
		Cell pc = a.GetParentCell()
		bool isInt = pc && pc.IsInterior()
		int cellKind = 1
		If isInt
			cellKind = 2
		EndIf
		float ax = a.GetPositionX()
		float ay = a.GetPositionY()
		float az = a.GetPositionZ()
		float[] ux = new float[8]
		float[] uy = new float[8]
		ux[0] = 1.0
		uy[0] = 0.0
		ux[1] = 0.707107
		uy[1] = 0.707107
		ux[2] = 0.0
		uy[2] = 1.0
		ux[3] = -0.707107
		uy[3] = 0.707107
		ux[4] = -1.0
		uy[4] = 0.0
		ux[5] = -0.707107
		uy[5] = -0.707107
		ux[6] = 0.0
		uy[6] = -1.0
		ux[7] = 0.707107
		uy[7] = -0.707107
		float[] rings = new float[5]
		rings[0] = 150.0
		rings[1] = 320.0
		rings[2] = 650.0
		rings[3] = 1150.0
		rings[4] = 1750.0
		int ri = 0
		bool foundCell = false
		While ri < 5 && !foundCell
			float rad = rings[ri]
			If rad <= radius
				int d = 0
				While d < 8
					float px = ax + ux[d] * rad
					float py = ay + uy[d] * rad
					MoveProbe(px, py, az, a)
					PO3_SKSEFunctions.MoveToNearestNavmeshLocation(kProbe)
					float nx = kProbe.GetPositionX()
					float ny = kProbe.GetPositionY()
					float nz = kProbe.GetPositionZ()
					If ProbeWadeable(nx, ny, nz, a)
						foundCell = true
						If BetterThanFound(a, nx, ny, nz)
							AcceptFound(cellKind, nx, ny, nz, false, 0.0, 0.0, 0.0)
						EndIf
					ElseIf isInt
						; Sunken indoor pool without navmesh inside the basin: check just below floor level
						float sdx = px - nx
						float sdy = py - ny
						If (sdx * sdx + sdy * sdy) <= 48400.0
							MoveProbe(px, py, az - 45.0, a)
							If ProbeInWater()
								MoveProbe(px, py, az + 30.0, a)
								If !ProbeInWater()
									foundCell = true
									If BetterThanFound(a, nx, ny, nz)
										AcceptFound(2, nx, ny, nz, true, px, py, az - 45.0)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					d += 1
				EndWhile
			EndIf
			ri += 1
		EndWhile
	EndIf

	; 3. Dirt and Blood waterfall lists: only as fallback if no real wet pool/tub/cell water was found
	If !bFoundWater
		ObjectReference fall = ClosestWaterfall(a, radius)
		If fall
			float fx = fall.GetPositionX()
			float fy = fall.GetPositionY()
			float fz = fall.GetPositionZ()
			MoveProbe(fx, fy, fz, fall)
			PO3_SKSEFunctions.MoveToNearestNavmeshLocation(kProbe)
			float nx = kProbe.GetPositionX()
			float ny = kProbe.GetPositionY()
			float nz = kProbe.GetPositionZ()
			AcceptFound(1, nx, ny, nz, false, 0.0, 0.0, 0.0)
		EndIf
	EndIf
	return bFoundWater
EndFunction

ObjectReference Function ClosestWaterfall(Actor a, float afRadius)
	If !a
		return None
	EndIf
	float x = a.GetPositionX()
	float y = a.GetPositionY()
	float z = a.GetPositionZ()
	ObjectReference best = None
	float bestD = afRadius
	ObjectReference r
	If kFall256
		r = Game.FindClosestReferenceOfAnyTypeInList(kFall256, x, y, z + 256.0, afRadius)
		If r && a.GetDistance(r) < bestD
			best = r
			bestD = a.GetDistance(r)
		EndIf
	EndIf
	If kFall512
		r = Game.FindClosestReferenceOfAnyTypeInList(kFall512, x, y, z + 512.0, afRadius)
		If r && a.GetDistance(r) < bestD
			best = r
			bestD = a.GetDistance(r)
		EndIf
	EndIf
	If kFall2048
		r = Game.FindClosestReferenceOfAnyTypeInList(kFall2048, x, y, z + 2048.0, afRadius)
		If r && a.GetDistance(r) < bestD
			best = r
			bestD = a.GetDistance(r)
		EndIf
	EndIf
	If kFall4096
		r = Game.FindClosestReferenceOfAnyTypeInList(kFall4096, x, y, z + 4096.0, afRadius)
		If r && a.GetDistance(r) < bestD
			best = r
			bestD = a.GetDistance(r)
		EndIf
	EndIf
	return best
EndFunction

int Function WalkSlotOf(Actor a)
	If !a || walkActor.length < 4
		return -1
	EndIf
	return walkActor.Find(a)
EndFunction

bool Function StartWalk(Actor a)
	EnsureTravel()
	If !a || !TravelQuest || !TravelQuest.IsRunning() || kDest.length < 4
		return false
	EndIf
	If WalkSlotOf(a) >= 0
		return true
	EndIf
	int s = walkActor.Find(None)
	If s < 0
		return false
	EndIf
	If !kDest[s] || !kWalkActorAlias[s]
		return false
	EndIf
	kDest[s].MoveTo(a)
	kDest[s].SetPosition(fFoundX, fFoundY, fFoundZ)
	walkActor[s] = a
	walkWait[s] = 0.0
	walkTub[s] = bFoundTub
	walkTubX[s] = fFoundTubX
	walkTubY[s] = fFoundTubY
	walkTubZ[s] = fFoundTubZ
	walkLastX[s] = a.GetPositionX()
	walkLastY[s] = a.GetPositionY()
	walkLastZ[s] = a.GetPositionZ()
	walkStall[s] = 0
	walkRetries[s] = 0
	nWalks += 1
	kWalkActorAlias[s].ForceRefTo(a)
	a.EvaluatePackage()
	string kind = "open water"
	If iFoundKind == 2
		If bFoundTub
			kind = "a tub (will step in at the rim)"
		Else
			kind = "a pool or tub"
		EndIf
	EndIf
	Log("WashUp: " + a.GetDisplayName() + " walks to " + kind + " (" + (a.GetDistance(kDest[s]) as int) + " units)")
	Schedule()
	return true
EndFunction

bool Function CanSeeWaterPoint(Actor a, float wx, float wy, float wz)
	If !a || !kProbe
		return false
	EndIf
	If kProbe.IsDisabled()
		kProbe.EnableNoWait()
	EndIf
	; Check LOS at chest/head height above the water so rims, ladders and stairs don't block it, while room walls do
	MoveProbe(wx, wy, wz + 75.0, a)
	return a.HasLOS(kProbe)
EndFunction

Function TickWalks()
	EnsureTravel()
	int i = 0
	While i < 4
		Actor a = walkActor[i]
		If a
			walkWait[i] = walkWait[i] + POLL
			string why = WalkAbortReason(a)
			float need = WALK_ARRIVE
			If walkTub[i]
				need = WALK_ARRIVE_TUB
			EndIf
			float dist = 99999.0
			float wx = 0.0
			float wy = 0.0
			float wz = 0.0
			If kDest[i]
				dist = a.GetDistance(kDest[i])
				wx = kDest[i].GetPositionX()
				wy = kDest[i].GetPositionY()
				wz = kDest[i].GetPositionZ()
			EndIf
			If walkTub[i]
				wx = walkTubX[i]
				wy = walkTubY[i]
				wz = walkTubZ[i]
			EndIf
			; Track whether the NPC is still making progress or stopped at a rim/ladder/wall
			float cx = a.GetPositionX()
			float cy = a.GetPositionY()
			float cz = a.GetPositionZ()
			float mdx = cx - walkLastX[i]
			float mdy = cy - walkLastY[i]
			float mdz = cz - walkLastZ[i]
			walkLastX[i] = cx
			walkLastY[i] = cy
			walkLastZ[i] = cz
			If (mdx * mdx + mdy * mdy + mdz * mdz) <= 256.0
				walkStall[i] = walkStall[i] + 1
			Else
				walkStall[i] = 0
			EndIf
			If why != ""
				Log("WashUp walk aborted for " + a.GetDisplayName() + ": " + why)
				ClearWalk(i, false)
				SkyrimNetApi.GenerateNPCThought(a, why)
			ElseIf (!walkTub[i] && InWaterNow(a)) || dist <= need
				ArriveAndWash(i, false)
			ElseIf walkStall[i] >= 2 && dist <= 260.0
				bool canSee = CanSeeWaterPoint(a, wx, wy, wz)
				If canSee
					Log("WashUp: " + a.GetDisplayName() + " reached the water edge (" + (dist as int) + " units) and steps in")
					ArriveAndWash(i, true)
				ElseIf walkRetries[i] == 0 && kDest[i] && kProbe
					; Blocked by a wall beside a tub/pool: try snapping destination to the opposite side
					float ox = wx + (wx - cx)
					float oy = wy + (wy - cy)
					MoveProbe(ox, oy, wz, a)
					PO3_SKSEFunctions.MoveToNearestNavmeshLocation(kProbe)
					kDest[i].SetPosition(kProbe.GetPositionX(), kProbe.GetPositionY(), kProbe.GetPositionZ())
					walkRetries[i] = 1
					walkStall[i] = 0
					walkWait[i] = 0.0
					a.EvaluatePackage()
					Log("WashUp: " + a.GetDisplayName() + " stopped behind a wall (" + (dist as int) + " units), trying opposite side of water")
				ElseIf walkWait[i] >= WALK_TIMEOUT
					Log("WashUp walk timed out for " + a.GetDisplayName() + " after " + (WALK_TIMEOUT as int) + " s (still " + (dist as int) + " units away, LOS=" + canSee + ")")
					ClearWalk(i, false)
					SkyrimNetApi.GenerateNPCThought(a, "You wanted to wash, but you could not reach the water.")
				EndIf
			ElseIf walkWait[i] >= WALK_TIMEOUT
				bool canSee2 = dist <= 260.0 && CanSeeWaterPoint(a, wx, wy, wz)
				If canSee2
					Log("WashUp: " + a.GetDisplayName() + " timed out right beside the water (" + (dist as int) + " units); stepping in")
					ArriveAndWash(i, true)
				Else
					Log("WashUp walk timed out for " + a.GetDisplayName() + " after " + (WALK_TIMEOUT as int) + " s (still " + (dist as int) + " units away, LOS=" + canSee2 + ")")
					ClearWalk(i, false)
					SkyrimNetApi.GenerateNPCThought(a, "You wanted to wash, but you could not reach the water.")
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction

string Function WalkAbortReason(Actor a)
	If !a || a.IsDead()
		return "You wanted to wash, but you cannot."
	ElseIf a.IsInCombat()
		return "You wanted to wash, but you are in the middle of a fight."
	ElseIf a.IsWeaponDrawn()
		return "You wanted to wash, but your weapon is still drawn."
	ElseIf InScene(a)
		return "You wanted to wash, but you are busy with something else right now."
	EndIf
	return ""
EndFunction

Function ArriveAndWash(int s, bool abStepIn = false)
	Actor a = walkActor[s]
	bool tub = walkTub[s]
	float tx = walkTubX[s]
	float ty = walkTubY[s]
	float tz = walkTubZ[s]
	float dx = 0.0
	float dy = 0.0
	float dz = 0.0
	bool hasDest = kDest.length > s && kDest[s] != None
	If hasDest
		dx = kDest[s].GetPositionX()
		dy = kDest[s].GetPositionY()
		dz = kDest[s].GetPositionZ()
	EndIf
	ClearWalk(s, false)
	If !a || a.IsDead()
		return
	EndIf
	bool stepped = false
	If tub
		a.SetPosition(tx, ty, tz)
		stepped = true
		Log("WashUp: " + a.GetDisplayName() + " steps into the tub/pool")
	ElseIf abStepIn && hasDest
		a.SetPosition(dx, dy, dz)
		stepped = true
		Log("WashUp: " + a.GetDisplayName() + " steps into the water")
	EndIf
	bool waterReq = gWaterReq && gWaterReq.GetValue() == 1.0
	If waterReq && !stepped && !HasWater(a)
		SkyrimNetApi.GenerateNPCThought(a, "You wanted to wash, but there is no water here.")
		Log("WashUp refused for " + a.GetDisplayName() + " after walking: no water at the destination")
		return
	EndIf
	bool soap = gSoapReq && gSoapReq.GetValue() == 1.0
	Log("WashUp: " + a.GetDisplayName() + " starts to wash after walking (soap " + soap + ")")
	int h = ModEvent.Create("OBDC_DoWash")
	If h
		ModEvent.PushForm(h, a)
		ModEvent.PushBool(h, soap)
		ModEvent.Send(h)
	EndIf
EndFunction

Function ClearWalk(int s, bool abUnused)
	Actor a = walkActor[s]
	walkActor[s] = None
	walkWait[s] = 0.0
	walkTub[s] = false
	If walkStall.length > s
		walkStall[s] = 0
		walkRetries[s] = 0
	EndIf
	nWalks -= 1
	If nWalks < 0
		nWalks = 0
	EndIf
	If kWalkActorAlias[s]
		kWalkActorAlias[s].Clear()
	EndIf
	If a
		a.EvaluatePackage()
	EndIf
EndFunction

Function AbortAllWalks(string asWhy)
	If walkActor.length < 4
		return
	EndIf
	int i = 0
	While i < 4
		Actor a = walkActor[i]
		If a
			If asWhy != ""
				SkyrimNetApi.GenerateNPCThought(a, asWhy)
			EndIf
			ClearWalk(i, false)
		EndIf
		i += 1
	EndWhile
EndFunction

bool Function IsOurFollower(Actor a)
	If !a
		return false
	EndIf
	If a.IsPlayerTeammate()
		return true
	EndIf
	Faction fol = Game.GetFormFromFile(0x5C84E, "Skyrim.esm") as Faction
	If fol && a.GetFactionRank(fol) >= 0
		return true
	EndIf
	return false
EndFunction

; =============================================================================================
;  WashUp action (followers, and nearby NPCs if that toggle is on)
; =============================================================================================
Function ApplyWashUpToggle()
	SkyrimNetApi.SetActionCooldown(ACTION_NAME, WASHUP_COOLDOWN)
	If !bDnB || (OBDC_WashUpEnabled && OBDC_WashUpEnabled.GetValue() != 1.0)
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
		Log("WashUp from SkyrimNet for " + akActor.GetDisplayName() + " ignored: WashUp is off in the MCM")
		return
	EndIf
	If !bDnB
		Resolve()
		If !bDnB
			Log("WashUp from SkyrimNet for " + akActor.GetDisplayName() + " ignored: Dirt and Blood not found")
			return
		EndIf
	EndIf
	string why = WashBlocker(akActor)
	If why != ""
		SkyrimNetApi.GenerateNPCThought(akActor, why)
		Log("WashUp refused for " + akActor.GetDisplayName() + ": " + why)
		return
	EndIf
	bool inNow = InWaterNow(akActor)
	bool waterReq = gWaterReq && gWaterReq.GetValue() == 1.0
	bool soap = gSoapReq && gSoapReq.GetValue() == 1.0
	; Physically standing in water right now: bathe on the spot
	If inNow
		Log("WashUp: " + akActor.GetDisplayName() + " is already in water, washes here (soap " + soap + ")")
		int h = ModEvent.Create("OBDC_DoWash")
		If h
			ModEvent.PushForm(h, akActor)
			ModEvent.PushBool(h, soap)
			ModEvent.Send(h)
		EndIf
		return
	EndIf
	; Feet are dry: if Walk to nearby water is on, always look for real water and walk there first
	If bWalkToWater
		EnsureTravel()
		If FindWaterNear(akActor, true)
			If StartWalk(akActor)
				return
			EndIf
			SkyrimNetApi.GenerateNPCThought(akActor, "You wanted to wash, but you cannot walk to the water right now.")
			Log("WashUp refused for " + akActor.GetDisplayName() + ": no free walk slot")
			return
		EndIf
	EndIf
	; No walkable water found (or walk toggle is off): fall back to Dirt and Blood's own spot check
	bool hasW = HasWater(akActor)
	If !waterReq || hasW
		Log("WashUp: " + akActor.GetDisplayName() + " washes in place (waterReq=" + waterReq + ", hasWater=" + hasW + ", walk=" + bWalkToWater + ", soap " + soap + ")")
		int h2 = ModEvent.Create("OBDC_DoWash")
		If h2
			ModEvent.PushForm(h2, akActor)
			ModEvent.PushBool(h2, soap)
			ModEvent.Send(h2)
		EndIf
		return
	EndIf
	If !bWalkToWater
		SkyrimNetApi.GenerateNPCThought(akActor, "You wanted to wash, but there is no water here. You would need a river, a lake or a waterfall.")
		Log("WashUp refused for " + akActor.GetDisplayName() + ": no water here (walk to water is off)")
	Else
		SkyrimNetApi.GenerateNPCThought(akActor, "You wanted to wash, but there is no water nearby. You would need a river, a lake, a pool or a tub.")
		Log("WashUp refused for " + akActor.GetDisplayName() + ": no real water in range (" + (fWaterSearchRadius as int) + " units)")
	EndIf
EndFunction

string Function WashBlocker(Actor a)
	If a.IsInCombat()
		return "You wanted to wash, but you are in the middle of a fight."
	ElseIf a.IsWeaponDrawn()
		return "You wanted to wash, but your weapon is still drawn."
	ElseIf InScene(a)
		return "You wanted to wash, but you are busy with something else right now."
	ElseIf kBathingActors && kBathingActors.HasForm(a)
		return "You are already washing."
	ElseIf WalkSlotOf(a) >= 0
		return "You are already on your way to wash."
	ElseIf !IsOurFollower(a)
		If !OBDC_AllNPCsWashUp || OBDC_AllNPCsWashUp.GetValue() != 1.0
			return "You wanted to wash, but only followers wash on their own."
		ElseIf a.GetParentCell() != PlayerRef.GetParentCell() && a.GetDistance(PlayerRef) > fWaterSearchRadius
			return "You wanted to wash, but the water is not nearby."
		EndIf
	EndIf
	If gSoapReq && gSoapReq.GetValue() == 1.0 && (!kSoaps || !PO3_SKSEFunctions.FindFirstItemInList(a, kSoaps))
		return "You wanted to wash, but you have no soap."
	EndIf
	; Water is checked in WashUpNow so we can walk to it first when that toggle is on.
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
bool Function InWaterNow(Actor a)
	If !a
		return false
	EndIf
	If a.IsSwimming() || PO3_SKSEFunctions.IsActorInWater(a)
		return true
	EndIf
	If kWade1 && a.HasSpell(kWade1)
		return true
	ElseIf kWade2 && a.HasSpell(kWade2)
		return true
	EndIf
	return false
EndFunction

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
	LogFileLine(asMsg)      ; 0.4
	If bDebug
		Debug.Notification("OBDC: " + asMsg)
	EndIf
EndFunction

; =============================================================================================
;  0.4: own log file for bug reports: Data/SKSE/Plugins/OBloodDirtCum.log (MO2: overwrite).
;  PapyrusUtil soft check (without it nothing is written). A header per game load, then one line
;  per event; restarts after 10 game loads (StorageUtilData/OBloodDirtCum_log.json), at most
;  2000 lines per game load. No polling.
; =============================================================================================
bool Property bLogFile = true Auto Hidden
string Property LOG_FILE = "Data/SKSE/Plugins/OBloodDirtCum.log" AutoReadOnly
string Property LOG_STATE = "OBloodDirtCum_log" AutoReadOnly
bool bLogPU = false
int iLogLines = 0

bool Function PapyrusUtilOK()
	return SKSE.GetPluginVersion("papyrusutil plugin") > 0
EndFunction

Function LogSessionStart()
	bLogPU = PapyrusUtilOK()
	iLogLines = 0
	If !bLogPU || !bLogFile
		return
	EndIf
	int n = JsonUtil.GetIntValue(LOG_STATE, "session", 0) + 1
	bool fresh = n > 10 || !MiscUtil.FileExists(LOG_FILE)
	If fresh
		n = 1
	EndIf
	JsonUtil.SetIntValue(LOG_STATE, "session", n)
	JsonUtil.Save(LOG_STATE)
	string h = "===== O'Blood, Dirt and Cum 0.5.7 | game load " + n + " of 10 in this file | game time " + Utility.GameTimeToString(Utility.GetCurrentGameTime()) + " ====="
	MiscUtil.WriteToFile(LOG_FILE, h + "\n", !fresh, true)
EndFunction

Function LogFileLine(string s)
	If !bLogPU || !bLogFile || iLogLines >= 2000
		return
	EndIf
	iLogLines += 1
	If iLogLines == 2000
		s += "\n[OBDC] (2000 lines this game load: the rest only goes to Papyrus.0.log)"
	EndIf
	MiscUtil.WriteToFile(LOG_FILE, "[OBDC] " + s + "\n", true, true)
EndFunction

Function LogToggled()
	If bLogFile
		LogSessionStart()
		LogStartup()
	EndIf
EndFunction

string Function YN(bool b)
	If b
		return "yes"
	EndIf
	return "no"
EndFunction

Function LogStartup()
	If !bLogPU || !bLogFile
		return
	EndIf
	Log("found: Dirt and Blood plugin " + YN(Game.IsPluginInstalled(DNB_ESP)) + " (forms OK " + YN(bDnB) + ") | Malignis patch " + YN(bMalignisLoaded) + " | OCum " + YN(bOCum) + " | Tull Animated Creampie " + YN(Game.IsPluginInstalled(TULL_ESP)) + " | Liquid Pack v2 " + YN(Game.IsPluginInstalled(LIQUID_ESP)) + " | OStimNet (TT_OStimNet.esp) " + YN(Game.IsPluginInstalled("TT_OStimNet.esp")) + " | SkyrimNet " + YN(Game.IsPluginInstalled("SkyrimNet.esp")) + " | WadeInWater " + YN(Game.IsPluginInstalled("WadeInWater.esp")) + " | powerofthree " + YN(SKSE.GetPluginVersion("powerofthree's Papyrus Extender") > 0) + " | RaceMenu (skee) " + YN(SKSE.GetPluginVersion("skee") > 0) + " | settings.json " + YN(JsonUtil.JsonExists(SETTINGS_FILE)))
	bool prompt = OBDC_PromptEnabled && OBDC_PromptEnabled.GetValue() == 1.0
	bool cumPrompt = OBDC_CumPromptEnabled && OBDC_CumPromptEnabled.GetValue() == 1.0
	string fact = "off"
	If !bOCum
		fact = "silent (no OCum)"
	ElseIf prompt && cumPrompt
		If Game.IsPluginInstalled("TT_OStimNet.esp")
			fact = "OStimNet found: its cum description wins whenever it has text; this mod adds the short fact only when OStimNet's is empty"
		Else
			fact = "no OStimNet: this mod adds the short fact while OCum marks someone"
		EndIf
	EndIf
	Log("settings: bio facts " + YN(prompt) + " | cum in bios " + YN(cumPrompt) + " | cum fact: " + fact)
	Log("settings: state events " + YN(bStateEvents) + " | narration " + YN(bNarration) + " | bath memories " + YN(bMemories) + " | onlookers " + YN(bBystanders) + " | WashUp " + YN(OBDC_WashUpEnabled && OBDC_WashUpEnabled.GetValue() == 1.0) + " | baths wash cum off " + YN(bCumWash) + " | cum narration " + YN(bCumNarration) + " | Malignis flag " + YN(bMalignis) + " | debug " + YN(bDebug))
	Log("settings: open bathing is normal " + YN(OBDC_NormBathing && OBDC_NormBathing.GetValue() == 1.0) + " | intimacy in bathing spots is normal " + YN(OBDC_NormBathingSex && OBDC_NormBathingSex.GetValue() == 1.0) + " | walk to nearby water " + YN(bWalkToWater) + " | water search range " + (fWaterSearchRadius as int) + " | non-followers can WashUp " + YN(OBDC_AllNPCsWashUp && OBDC_AllNPCsWashUp.GetValue() == 1.0) + " | nearby water now " + (OBDC_NearbyWater.GetValue() as int))
EndFunction
