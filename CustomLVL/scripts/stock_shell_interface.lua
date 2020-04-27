------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

ReadDataFile("REMASTER\\swbf2Remaster_hook.lvl")

local exist = ScriptCB_IsFileExist

ScriptCB_IsFileExist = function(filename, ...)
	if filename == "custom_gc_0.lvl" then 
		ReadDataFile("REMASTER\\swbf2Remaster_ui_controller.lvl")
		ScriptCB_DoFile("swbf2Remaster_ui_controller")
		ScriptCB_IsFileExist = exist
		return ScriptCB_IsFileExist(filename, unpack(arg))
	end
	
	return exist(filename, unpack(arg))
end

ScriptCB_DoFile("stock_shell_interface")