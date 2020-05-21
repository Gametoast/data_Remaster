------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

function ReadRemasterFile(file)
	ReadDataFile("..\\..\\addon\\Remaster\\" .. file)
end

local exist = ScriptCB_IsFileExist

ScriptCB_IsFileExist = function(filename, ...)
	if filename == "user_script_0.lvl" then 
		ScriptCB_IsFileExist = exist
		ReadRemasterFile("scripts\\ingame_controller.lvl")
		ScriptCB_DoFile("ingame_controller")
		return ScriptCB_IsFileExist(filename, unpack(arg))
	end
	
	return exist(filename, unpack(arg))
end

ReadRemasterFile("remaster_hook.lvl")
ScriptCB_DoFile("stock_game_interface")
