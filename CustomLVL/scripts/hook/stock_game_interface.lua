------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

function ReadRemasterFile(file)
	ReadDataFile("..\\..\\addon\\Remaster\\" .. file)
end

ReadRemasterFile("scripts\\ingame_controller.lvl")
ScriptCB_DoFile("ingame_controller")

