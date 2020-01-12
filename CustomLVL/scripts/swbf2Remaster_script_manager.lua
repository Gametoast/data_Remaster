------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

local base36 = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", 
                 "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", 
                 "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", 
                 "U", "V", "W", "X", "Y", "Z" }

local exists = ScriptCB_IsFileExist -- Store the function into a local for performance.

function swbf2Remaster_getOPPath(modID)
	return "..\\..\\addon\\" .. modID .. "\\scripts\\" .. modID .. "_option_script.lvl"
end

function swbf2Remaster_getIFPath(modID)
	return "..\\..\\addon\\" .. modID .. "\\scripts\\" .. modID .. "_interface_script.lvl"
end

function swbf2Remaster_getIGPath(modID)
	return "..\\..\\addon\\" .. modID .. "\\scripts\\" .. modID .. "_game_script.lvl"
end

function swbf2Remaster_getGTPath(modID)
	return "..\\..\\addon\\" .. modID .. "\\scripts\\" .. modID .. "_theme_script.lvl"
end

function swbf2Remaster_loadTheme()
	print("load theme:", rema_database.scripts_GT[rema_database.themeIdx].filePath, rema_database.scripts_GT[rema_database.themeIdx].modID .. "_theme_script")
	ReadDataFile(rema_database.scripts_GT[rema_database.themeIdx].filePath)
	ScriptCB_DoFile(rema_database.scripts_GT[rema_database.themeIdx].modID .. "_theme_script")
end

function swbf2Remaster_runInterfaceScripts()

	for i = 1, table.getn(rema_database.scripts_IF) do
		ReadDataFile(swbf2Remaster_getIFPath(rema_database.scripts_IF[i]))
		ScriptCB_DoFile(rema_database.scripts_IF[i] .. "_interface_script")
	end
end

function swbf2Remaster_runGameScripts()

	for i = 1, table.getn(rema_database.scripts_IG) do
		ReadDataFile(swbf2Remaster_getIGPath(rema_database.scripts_IG[i]))
		ScriptCB_DoFile(rema_database.scripts_IG[i] .. "_game_script")
	end
end

function swbf2Remaster_loadScripts()
	
	-- clean up first
	rema_database.scripts_OP = nil
	rema_database.scripts_IF = nil
	rema_database.scripts_IG = nil
	rema_database.scripts_GT = nil
	
	rema_database.scripts_OP = {}
	rema_database.scripts_IF = {}
	rema_database.scripts_IG = {}
	rema_database.scripts_GT = {{modID = "Remaster", filePath = "REMASTER\\swbf2Remaster_theme.lvl"},}
	
	for x = 1, 36 do
		for y = 1, 36 do
			for z = 1, 36 do
			
				local modID =  base36[x] .. base36[y] .. base36[z]
				local opPath = swbf2Remaster_getOPPath(modID)
				local ifPath = swbf2Remaster_getIFPath(modID)
				local igPath = swbf2Remaster_getIGPath(modID)
				local gtPath = swbf2Remaster_getGTPath(modID)
				
				if exists(opPath) ~= 0 then
					rema_database.scripts_OP[table.getn(rema_database.scripts_OP) + 1] = modID
				end
				
				if exists(ifPath) ~= 0 then
					rema_database.scripts_IF[table.getn(rema_database.scripts_IF) + 1] = modID
				end
				
				if exists(igPath) ~= 0 then
					rema_database.scripts_IG[table.getn(rema_database.scripts_IG) + 1] = modID
				end
				
				if exists(gtPath) ~= 0 then
					rema_database.scripts_GT[table.getn(rema_database.scripts_GT) + 1] = {modID = modID, filePath = gtPath}
				end
			end
		end
	end

end

function swbf2Remaster_registerCGCButton(tag, label, func)
	if ifs_sp_gc_main.funclist[tag] then
		print("registerCGCButton: failed " .. tag .. " already exists")
	else
		ifs_sp_gc_main.funclist[tag] = func
		table.insert(ifs_sp_gc_main.datalist, 1,{tag = tag, string = label})
	end
end
