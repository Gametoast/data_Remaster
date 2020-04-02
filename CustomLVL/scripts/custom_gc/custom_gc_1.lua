------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

--[[local temp = ScriptCB_DoFile
ScriptCB_DoFile = function(...)
	
	if arg[1] == "ifs_credits" then
		print("marker test")
		temp("ifs_credits")
		temp("ifs_fonttest")
		ifs_movietrans_PushScreen(ifs_fonttest)
	else
		return temp(unpack(arg))
	end
end

local temp2 = ScriptCB_PushScreen
ScriptCB_PushScreen = function(...)
	
	if arg[1] == "ifs_boot" then
		arg[1] = "ifs_fonttest"
	end
	
	print("marker", arg[1])
	return temp2(unpack(arg))
end--]]

print("custom_gc_1: SWBF 2 Remaster mod")
ReadDataFile("REMASTER\\swbf2Remaster_ui_controller.lvl")
ScriptCB_DoFile("swbf2Remaster_ui_controller")