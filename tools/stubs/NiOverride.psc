Scriptname NiOverride Hidden
{Compile-only stub (not shipped). The real script belongs to RaceMenu.}
int Function GetNumBodyOverlays() native global
int Function GetNumHandOverlays() native global
int Function GetNumFeetOverlays() native global
int Function GetNumFaceOverlays() native global
string Function GetNodeOverrideString(ObjectReference ref, bool isFemale, string node, int key, int index) native global
int Function GetNumSpellBodyOverlays() native global
int Function GetNumSpellHandOverlays() native global
int Function GetNumSpellFeetOverlays() native global
int Function GetNumSpellFaceOverlays() native global
Function AddNodeOverrideString(ObjectReference ref, bool isFemale, string node, int key, int index, string value, bool persist) native global
Function RemoveNodeOverride(ObjectReference ref, bool isFemale, string node, int key, int index) native global
Function ApplyNodeOverrides(ObjectReference ref) native global
Function AddOverlays(ObjectReference ref) native global
