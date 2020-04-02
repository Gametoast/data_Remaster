-- STAR WARS BATTLEFRONT II - REMASTER
-- Developer Documentation by Anakin

-- Remaster will call this function to get the settings parameter
function swbf2Remaster_getCustomSettings()
	
	-- here we define our settings
	local customSettings = {
		radios = {
			{
				-- we need a individual tag. Make sure it's unique, because every tag can only exist once.
				tag = "cusTag1",
				-- This is the titel that is shown on the setting page. We can hardcode it
				title = "Custom Setting 1", 
				-- Our two options 
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.off")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.on"))},
				-- The default value.
				default = 1
			},	
			{
				tag = "cusTag2",
				-- We can use a localized string, too. But we need to define 
				-- it in our localize file or use an existing string path
				title = ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.radio.awardeffects")),
				-- Those two can be anything
				buttonStrings = {"Republic", "Rebels"},
				default = 2
			}
		}
	}
	
	-- pass our settings to who ever is interessted in it
	return customSettings
end
