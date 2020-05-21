------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

-- TEST ----------------------------------------------------------
--ScriptCB_DoFile("ingame_testscript")

------------------------------------------------------------------

-- load fonts
local w, h = ScriptCB_GetScreenInfo()

if h >= 2000 then
	ReadDataFile("..\\..\\addon\\Remaster\\Fonts\\arialblack_4k.lvl")
elseif h >= 1000 then
	ReadDataFile("..\\..\\addon\\Remaster\\Fonts\\arialblack_2k.lvl")
else
	ReadDataFile("..\\..\\addon\\Remaster\\Fonts\\arialblack_default.lvl")
end

-- wait for interface_util to be loaded and swap stock fonts
-- with new, bigger font files
if ScriptCB_DoFile then
	
	-- backup old function
	local remaGUI_ScriptCB_DoFile = ScriptCB_DoFile

	-- wrap ScriptCB_DoFile
	ScriptCB_DoFile = function(...)

		-- let the original function happen and catch the return value
	    local remaGUI_SCBDFreturn = {remaGUI_ScriptCB_DoFile(unpack(arg))}

		if arg[1] == "interface_util" then

			if NewIFText then
				
				-- backup old function
				local remaGUI_NewIFText = NewIFText

				-- wrap NewIFText
				NewIFText = function(Template,...)
					
					if Template.font then
						if Template.font == "gamefont_small" then Template.font = "gamefont_small_rema"
						elseif Template.font == "gamefont_medium" then Template.font = "gamefont_medium_rema"
						elseif Template.font == "gamefont_large" then Template.font = "gamefont_large_rema"
						end
					end
					
					-- let the original function happen
					return remaGUI_NewIFText(Template, unpack(arg))
				end
			else
				print("Remaster: Error")
				print("        : NewIFText() not found!")
			end
		end
		-- return the original values
	    return unpack(remaGUI_SCBDFreturn)
	end
else
	print("Remaster: Error")
	print("        : ScriptCB_DoFile() not found!")
end

-- load hud if not deactivated
if not rema_noHUD then

	local screenWidth, screenHeight = ScriptCB_GetScreenInfo()
	local aspectRatio = screenWidth / screenHeight

	if aspectRatio >= 1.63 and aspectRatio <= 1.9 then
		ReadDataFile("..\\..\\addon\\Remaster\\HUD\\hud_16x09.lvl")
	elseif aspectRatio >= 1.4 and aspectRatio <= 1.63 then
		ReadDataFile("..\\..\\addon\\Remaster\\HUD\\hud_16x10.lvl")
	else
		ReadDataFile("..\\..\\addon\\Remaster\\HUD\\hud_04x03.lvl")
	end

end

-- run script manager
ScriptCB_DoFile("script_manager")

-- fixing missing sounds
ScriptCB_DoFile("sound_fixes")

-- load v1.3 options
ScriptCB_DoFile("uop13_effects")

-- searching database
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
		swbf2Remaster_runGameScripts()
	end
end

-- hook ScriptCB_QuitFromStats to give data back
local rema_QuitFromStats = ScriptCB_QuitFromStats
ScriptCB_QuitFromStats = function(...)

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
	return rema_QuitFromStats(unpack(arg))
end

-- hook ScriptCB_QuitToShell to give data back
local rema_QuitToShell = ScriptCB_QuitToShell
ScriptCB_QuitToShell = function(...)

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
		
		if rema_database then 
			ScriptCB_SaveMetagameState(rema_database)
		end
	end
	
	-- let the original function happen
	return rema_QuitToShell(unpack(arg))
end

-- options that are only for singleplayer
if not ScriptCB_InMultiplayer() then

	-- load ai heros if enabled in settings
	if rema_database.data.aihero == 2 then
		ScriptCB_DoFile("aihero_insert")
	end
	
	-- disable award weapons if enabled in the settings
	if rema_database.data.awardWeapons == 1 then
		ScriptCB_DoFile("remove_award_weapons")
	end
end

print("Remaster: game upgrade complete")
print("")