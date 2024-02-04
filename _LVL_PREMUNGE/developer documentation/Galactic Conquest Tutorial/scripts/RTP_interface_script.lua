-- STAR WARS BATTLEFRONT II - REMASTER
-- Developer Documentation by Anakin

-- load all scripts needed for your custom gc match here
ScriptCB_DoFile("ifs_freeform_init_cgc")
ScriptCB_DoFile("ifs_freeform_start_cgc")

-- some variables needed by the register function
local gcButtonTag = "cgcButton"				-- the button tag needs to be unique
local gcButtonString = "CGC Tutorial"		-- the name can be localized or hardcoded
local start_gc = ifs_freeform_start_cgc		-- This is the function that starts the gc match.

-- register the button
swbf2Remaster_registerCGCButton(gcButtonTag, gcButtonString, start_gc )