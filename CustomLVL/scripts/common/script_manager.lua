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
	if modID == "REMA" then
		return "..\\..\\addon\\Remaster\\scripts\\REMA_theme_script.lvl"
	else
		return "..\\..\\addon\\" .. modID .. "\\scripts\\" .. modID .. "_theme_script.lvl"
	end
end

function swbf2Remaster_loadTheme()
	print("load theme:", swbf2Remaster_getGTPath(rema_database.scripts_GT[rema_database.themeIdx]), rema_database.scripts_GT[rema_database.themeIdx] .. "_theme_script")
	ReadDataFile(swbf2Remaster_getGTPath(rema_database.scripts_GT[rema_database.themeIdx]))
	ScriptCB_DoFile(rema_database.scripts_GT[rema_database.themeIdx] .. "_theme_script")
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
	
	local temp = {}
	temp.scripts_OP = {}
	temp.scripts_IF = {}
	temp.scripts_IG = {}
	temp.scripts_GT = { "REMA" }

	--[[local index = {}
	index[0] = {}
	index[1] = {}
	index[2] = {}
	index[3] = {}
	index[0][0] = 0
	index[0][1] = 1
	index[1][0] = 0
	index[1][1] = 1
	index[2][0] = 0
	index[2][1] = 1
	index[3][0] = 0
	index[3][1] = 2--]]

	for x = 1, 36 do
		for y = 1, 36 do
			for z = 1, 36 do
				
				local modID = base36[x] .. base36[y] .. base36[z]
				
				if exists("..\\..\\addon\\" .. modID .. "\\scripts") ~= 0 then
					--[[local modIDpath =  "..\\..\\addon\\" .. modID .. "\\scripts\\" .. modID
					
					local scriptExists = exists(modIDpath .. "_option_script.lvl")
					temp.scripts_OP[index[0][scriptExists] ] = modID
					index[0][1] = index[0][1] + scriptExists
					
					local scriptExists = exists(modIDpath .. "_interface_script.lvl")
					temp.scripts_IF[index[0][scriptExists] ] = modID
					index[0][1] = index[0][1] + scriptExists
					
					local scriptExists = exists(modIDpath .. "_game_script.lvl")
					temp.scripts_IG[index[0][scriptExists] ] = modID
					index[0][1] = index[0][1] + scriptExists
					
					local scriptExists = exists(modIDpath .. "_theme_script.lvl")
					temp.scripts_GT[index[0][scriptExists] ] = {modID = modID, filePath = modIDpath .. "_theme_script.lvl"}
					index[0][1] = index[0][1] + scriptExists
				--]]
				
				--local modID =  base36[x] .. base36[y] .. base36[z]
				local opPath = swbf2Remaster_getOPPath(modID)
				local ifPath = swbf2Remaster_getIFPath(modID)
				local igPath = swbf2Remaster_getIGPath(modID)
				local gtPath = swbf2Remaster_getGTPath(modID)
				
				if exists(opPath) ~= 0 then
					temp.scripts_OP[table.getn(temp.scripts_OP) + 1] = modID
				end
				
				if exists(ifPath) ~= 0 then
					temp.scripts_IF[table.getn(temp.scripts_IF) + 1] = modID
				end
				
				if exists(igPath) ~= 0 then
					temp.scripts_IG[table.getn(temp.scripts_IG) + 1] = modID
				end
				
				if exists(gtPath) ~= 0 then
					temp.scripts_GT[table.getn(temp.scripts_GT) + 1] = modID
				end
				
				end
			end
		end
	end

	--temp.scripts_OP[0] = nil
	--temp.scripts_IF[0] = nil
	--temp.scripts_IG[0] = nil
	--temp.scripts_GT[0] = nil
	rema_database.scripts_OP = temp.scripts_OP
	rema_database.scripts_IF = temp.scripts_IF
	rema_database.scripts_IG = temp.scripts_IG
	rema_database.scripts_GT = temp.scripts_GT
	
end

function swbf2Remaster_registerCGCButton(tag, label, func)
	if ifs_sp_gc_main.funclist[tag] then
		print("registerCGCButton: failed " .. tag .. " already exists")
	else
		ifs_sp_gc_main.funclist[tag] = func
		table.insert(ifs_sp_gc_main.datalist, 1,{tag = tag, string = label})
	end
end
