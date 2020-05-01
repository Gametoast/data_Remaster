------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

ReadDataFile("..\\..\\addon\\Remaster\\remaster_hook.lvl")

local exist = ScriptCB_IsFileExist

ScriptCB_IsFileExist = function(filename, ...)
	if filename == "custom_gc_0.lvl" then 
		ScriptCB_IsFileExist = exist
		ReadDataFile("..\\..\\addon\\Remaster\\scripts\\interface_controller.lvl")
		ScriptCB_DoFile("interface_controller")
		return ScriptCB_IsFileExist(filename, unpack(arg))
	end
	
	return exist(filename, unpack(arg))
end

ScriptCB_DoFile("stock_shell_interface")