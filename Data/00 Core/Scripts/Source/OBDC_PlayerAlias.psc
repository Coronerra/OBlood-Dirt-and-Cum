Scriptname OBDC_PlayerAlias extends ReferenceAlias
{O'Blood, Dirt and Cum: hears only Dirt and Blood's tier and soap effects landing on the player (po3 filtered event),
 and the player casting Dirt and Blood's "clean an NPC" spell.}

OBDC_Main Property Main Auto
Form kNPCBathSpell

Event OnInit()
	; Main starts itself from its own OnInit
EndEvent

Event OnPlayerLoadGame()
	Main.Startup()
EndEvent

Function Arm(MagicEffect[] akTiers, MagicEffect akSoapy, Spell akNPCBathSpell)
	PO3_Events_Alias.UnregisterForAllMagicEffectApplyEx(self)
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
EndFunction

Function Disarm()
	PO3_Events_Alias.UnregisterForAllMagicEffectApplyEx(self)
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
