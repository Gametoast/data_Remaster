------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

ReadDataFile("..\\..\\addon\\Remaster\\remaster_hook.lvl")

local exist = ScriptCB_IsFileExist

ScriptCB_IsFileExist = function(filename, ...)
	if filename == "user_script_0.lvl" then 
		ScriptCB_IsFileExist = exist
		ReadDataFile("..\\..\\addon\\Remaster\\scripts\\ingame_controller.lvl")
		ScriptCB_DoFile("ingame_controller")
		return ScriptCB_IsFileExist(filename, unpack(arg))
	end
	
	return exist(filename, unpack(arg))
end

ScriptCB_DoFile("stock_game_interface")