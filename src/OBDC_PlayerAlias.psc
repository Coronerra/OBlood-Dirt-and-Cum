Scriptname OBDC_PlayerAlias extends ReferenceAlias
{O'Blood, Dirt and Cum: hears only Dirt and Blood's tier and soap effects landing on the player (po3 filtered event),
 and the player casting Dirt and Blood's "clean an NPC" spell.
 Since 0.5 also notices location and cell changes so the nearby-water prompt can update, with no polling.}

OBDC_Main Property Main Auto
Form kNPCBathSpell

Event OnInit()
	; Main starts itself from its own OnInit
EndEvent

Event OnPlayerLoadGame()
	Main.Startup()
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	Main.UpdateNearbyWater(true)
EndEvent

Event OnCellFullyLoaded(Cell akCell)
	Main.UpdateNearbyWater(false)
EndEvent

Function Arm(MagicEffect[] akTiers, MagicEffect akSoapy, Spell akNPCBathSpell)
	PO3_Events_Alias.UnregisterForAllMagicEffectApplyEx(self)
	PO3_Events_Alias.UnregisterForCellFullyLoaded(self)
	int i = 0
	While i < akTiers.Length
		If akTiers[i]
			PO3_Events_Alias.RegisterForMagicEffectApplyEx(self, akTiers[i], true)
		EndIf
		i += 1
	EndWhile
	If akSoapy
		PO3_Events_Alias.RegisterForMagicEffectApplyEx(self, akSoapy, true)
	EndIf
	kNPCBathSpell = akNPCBathSpell
	PO3_Events_Alias.RegisterForCellFullyLoaded(self)
EndFunction

Function Disarm()
	PO3_Events_Alias.UnregisterForAllMagicEffectApplyEx(self)
	PO3_Events_Alias.UnregisterForCellFullyLoaded(self)
	kNPCBathSpell = None
EndFunction

Event OnMagicEffectApplyEx(ObjectReference akCaster, MagicEffect akEffect, Form akSource, bool abApplied)
	If abApplied
		Main.OnPlayerEffect(akEffect)
	EndIf
EndEvent

Event OnSpellCast(Form akSpell)
	If akSpell && akSpell == kNPCBathSpell
		Main.OnNPCBathCast()
	EndIf
EndEvent
