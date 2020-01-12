------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

-- TEST ----------------------------------------------------------
ScriptCB_DoFile("ui_testscript")
--ReadDataFile("REMASTER\\fontHD.lvl")
------------------------------------------------------------------

rema_firstLoad = true

-- load strings
ReadDataFile("REMASTER\\swbf2remaster_localize.lvl")

-- run script manager
ScriptCB_DoFile("swbf2Remaster_script_manager")

-- init load/store functions
-- delayed run interface scripts
-- delayed load theme
-- delayed continue push ifs_boot
ScriptCB_DoFile("swbf2Remaster_loadSave")

-- run GUI upgrade
ScriptCB_DoFile("swbf2Remaster_guiUpgrade")

-- add v1.3 options
ScriptCB_DoFile("swbf2Remaster_v13_options")

-- upgrade galactic conquest
ScriptCB_DoFile("swbf2Remaster_galactic_conquest")

-- searching database, do this delayed to avoid bugs
local remaUI_doFile = ScriptCB_DoFile
ScriptCB_DoFile = function(...)
	
	if arg[1] == "ifs_credits" then

		if ScriptCB_IsMetagameStateSaved() then
			
			-- load all data
			local temp = {ScriptCB_LoadMetagameState()}
			
			-- if it is the database
			if temp[1] and temp[1].isRemaDatabase then
				rema_database = temp[1]
				
				if not (next(temp, 1) == nil) then
					-- there is more, push it back to the pipe
					ScriptCB_SaveMetagameState(
						temp[2],
						temp[3],
						temp[4],
						temp[5],
						temp[6],
						temp[7],
						temp[8],
						temp[9],
						temp[10],
						temp[11],
						temp[12],
						temp[13],
						temp[14],
						temp[15],
						temp[16],
						temp[17],
						temp[18],
						temp[19],
						temp[20],
						temp[21],
						temp[22],
						temp[23],
						temp[24],
						temp[25],
						temp[26],
						temp[27]
					)
				else
					-- there is only the database, clean up
					ScriptCB_ClearMetagameState()
				end
				swbf2Remaster_runInterfaceScripts()
			end
		end
		
		-- we need to do this only once. release the hook
		ScriptCB_DoFile = remaUI_doFile
	end
	
	return remaUI_doFile(unpack(arg))
end

-- hook ScriptCB_EnterMission to push important information to the game
local rema_EnterMission = ScriptCB_EnterMission
ScriptCB_EnterMission = function(...)
	
	-- we don't need those infos ingame
	rema_database.instOp = nil
	rema_database.scripts_GT = nil
	rema_database.themeIdx = nil
	rema_database.regSet = nil
	rema_database.scripts_OP = nil
	
	if ScriptCB_IsMetagameStateSaved() then
		-- there is old data
		local temp = {ScriptCB_LoadMetagameState()}

		ScriptCB_SaveMetagameState(
			rema_database,
			temp[1],
			temp[2],
			temp[3],
			temp[4],
			temp[5],
			temp[6],
			temp[7],
			temp[8],
			temp[9],
			temp[10],
			temp[11],
			temp[12],
			temp[13],
			temp[14],
			temp[15],
			temp[16],
			temp[17],
			temp[18],
			temp[19],
			temp[20],
			temp[21],
			temp[22],
			temp[23],
			temp[24],
			temp[25],
			temp[26]
		)
		
	else
		-- there is no old data
		ScriptCB_SaveMetagameState(rema_database)
	end
	
	-- let the original function happen
	return rema_EnterMission(unpack(arg))
end

print("Remaster: ui upgrade complete")
print("")