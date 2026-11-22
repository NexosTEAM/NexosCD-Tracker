local name, Addon = ...
Addon.name = name
_G.NexosCD = Addon
Addon.db = {profile={themes={nameplates={fontSize=15,fontFlags="OUTLINE",defaultTextColor="FFFFFFFF",textColors={{threshold=5,color="FF6347FF"},{threshold=60,color="32CD32FF"},{threshold=3600,color="40E0D0FF"}}}}}}
Addon.ResolveFont = function(_, font) return STANDARD_TEXT_FONT end
