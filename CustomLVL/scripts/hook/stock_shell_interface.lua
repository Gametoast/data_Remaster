------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

function ReadRemasterFile(file)
	ReadDataFile("..\\..\\addon\\Remaster\\" .. file)
end

-- load strings
ReadRemasterFile("localize_main.lvl")
print("Remaster " .. ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.version")))

local exist = ScriptCB_IsFileExist

ScriptCB_IsFileExist = function(filename, ...)
	if filename == "custom_gc_0.lvl" then 
		ScriptCB_IsFileExist = exist
		ReadRemasterFile("scripts\\interface_controller.lvl")
		ScriptCB_DoFile("interface_controller")
		return ScriptCB_IsFileExist(filename, unpack(arg))
	end
	
	return exist(filename, unpack(arg))
end

ReadRemasterFile("remaster_hook.lvl")
ScriptCB_DoFile("stock_shell_interface")