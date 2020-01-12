------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
-- TODO: Hack ScriptCB_GetSavedMetagameList to not show the settings
------------------------------------------------------------------

local remaIOfilename = "RemasterSettings"

------------------------------------------------------------------
-- wrap AddIFScreen
-- wrap ifs_instant_options.push_prefs to save to database, too
-- install backdoor in ifs_saveop.Exit
local remaIO_AddIFScreen = AddIFScreen

AddIFScreen = function(table, name,...)
	
	-- waiting for ifs_instant_options, need to save options here
	if name == "ifs_instant_options" then
		
		-- backup old function
		local remaIO_instOpPush = ifs_instant_options.push_prefs
		
		-- wrap ifs_instant_options.push_prefs
		ifs_instant_options.push_prefs = function(this)
			-- if the setting is activated, backup the data
			if rema_database.radios.saveSpOptions == 2 then
				rema_database.instOp.GamePrefs = this.GamePrefs
				rema_database.instOp.HeroPrefs = this.HeroPrefs
			end
			
			-- let the original function happen
			return remaIO_instOpPush(this)
		end
		
		-- backup old function
		local remaIO_instOpDefault = ifs_instant_options.set_defaults
		
		-- wrap ifs_instant_options.set_defaults
		ifs_instant_options.set_defaults = function(this)
			
			-- let the original function happen, but catch return values
			local remaIO_returnVal = {remaIO_instOpDefault(this)}
			
			-- if setting is activated..
			if rema_database.radios.saveSpOptions == 2 then

				-- ..and the values are known, restore them
				if rema_database.instOp.GamePrefs ~= nil then
					this.GamePrefs = rema_database.instOp.GamePrefs
				end
				
				if rema_database.instOp.HeroPrefs ~= nil then
					this.HeroPrefs = rema_database.instOp.HeroPrefs
				end
			end
			
			-- return the original return values
			return unpack(remaIO_returnVal)
		end
	end
	
	-- waiting for ifs_saveop, need a backdoor here
	if name == "ifs_saveop" then
					
		-- backup old function
		local remaIO_saveopExit = ifs_saveop.Exit
		
		-- wrap ifs_saveop.Exit
		ifs_saveop.Exit = function(this, bFwd)
			
			--rema_pauseHook = false
			--rema_SaveSettingState()
			
			-- instal backdoor
			if this.beSneaky then
			
				local b1 = this.NoPromptSave
				local b2 = this.profile1
				local b3 = this.profile2
				local b4 = this.profile3
				local b5 = this.profile4
				local b6 = this.filename1	
				local b7 = this.bFromCancel
				local b8 = this.FromOverwrite
				local b9 = this.ForceSaveFailedMessage
				local b10 = this.saveProfileNum
				local b11 = this.saveName
				local b12 = this.OnSuccess
				local b13 = this.OnCancel
				local b14 = this.doOp
				
				-- let the original function happen..
				local remaIO_return = {remaIO_saveopExit(this, bFwd)}
			
				this.NoPromptSave = b1
				this.profile1 = b2
				this.profile2 = b3
				this.profile3 = b4
				this.profile4 = b5
				this.filename1 = b6		
				this.bFromCancel = b7
				this.FromOverwrite = b8
				this.ForceSaveFailedMessage = b9
				this.saveProfileNum = b10
				this.saveName = b11
				this.OnSuccess = b12
				this.OnCancel = b13
				this.doOp = b14
				
				-- ..but restore the data before return
				return unpack(remaIO_return)
			end
			
			-- let the original function happen
			return remaIO_saveopExit(this, bFwd)
		end
		
		-- overwrite ifs_saveop_StartPromptMetagameOverwrite()
		function ifs_saveop_StartPromptMetagameOverwrite()

			local this = ifs_saveop
			
			-- is there a current metagame filename?
			local metagame_exist = nil
			if( this.filename1 ) then
				metagame_exist = ScriptCB_DoesMetagameExistOnCard(this.filename1)
			end
				
			if( (not this.filename1) or (not metagame_exist) or ifs_saveop.beSneaky) then
				-- nope, just skip the confirmation
				ifs_saveop_MetagameOverwritePromptDone(1)
				return		
			end
			
			-- show the yes/no popup
			Popup_YesNo.CurButton = "no" -- default
			Popup_YesNo.fnDone = ifs_saveop_MetagameOverwritePromptDone
			Popup_YesNo:fnActivate(1)
			gPopup_fnSetTitleStr(Popup_YesNo, ifs_saveop.PlatformBaseStr .. ".save25")
		end
		
	
	end

	-- let the original function happen
	return remaIO_AddIFScreen(table, name, unpack(arg))
end


------------------------------------------------------------------
-- wrap ScriptCB_PushScreen
-- load settings before ifs_boot
local remaIO_PushScreen = ScriptCB_PushScreen

ScriptCB_PushScreen = function(name,...)

	if name == "ifs_boot" then
		swbf2Remaster_settingsManager("load",
			function(failure)
				swbf2Remaster_dataIntegrityTest(failure)
				swbf2Remaster_loadTheme()
				remaIO_PushScreen("ifs_boot")
				end)
	else
		remaIO_PushScreen(name, unpack(arg))
	end

end


------------------------------------------------------------------
-- wrap SetState
-- put database on the pipe
if SetState then
	
	local remaIO_setState = SetState
		
		SetState = function(...)
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
			
			return remaIO_setState(unpack(arg))
		end
else
	print("Remaster: Error")
	print("        : SetState not found")
end


------------------------------------------------------------------
-- new functions

function swbf2Remaster_settingExists(tag)
	for i = 1, table.getn(rema_database.regSet.radios) do
		if rema_database.regSet.radios[i].tag == tag then
			return true
		end
	end
	
	return false
end

function swbf2Remaster_dataIntegrityTest(failure)

	-- if there were any errors while loading, print them
	if failure then
		print("Remaster: settings error, ", failure)
	end
	
	-- check if all data is there
	if rema_database.isRemaDatabase == nil or 
		rema_database.radios == nil or
		rema_database.instOp == nil or
		rema_database.scripts_IF == nil or
		rema_database.scripts_IG == nil or
		rema_database.scripts_OP == nil or
		rema_database.scripts_GT == nil or
		rema_database.themeIdx == nil or
		rema_database.regSet == nil then
		
		print("Remaster: data integrity test failed, loading default..")
		rema_database = swbf2Remaster_getDefaultSettings()
	end
	
	-- Check if scripts do no longer exist
	local exists = ScriptCB_IsFileExist
	for i = 1, table.getn(rema_database.scripts_OP) do
		if exists(swbf2Remaster_getOPPath(rema_database.scripts_OP[i])) == 0 then
			rema_database.scripts_OP[i] = nil
		end
	end
	for i = 1, table.getn(rema_database.scripts_IF) do
		if exists(swbf2Remaster_getIFPath(rema_database.scripts_IF[i])) == 0 then
			rema_database.scripts_IF[i] = nil
		end
	end
	for i = 1, table.getn(rema_database.scripts_IG) do
		if exists(swbf2Remaster_getIGPath(rema_database.scripts_IG[i])) == 0 then
			rema_database.scripts_IG[i] = nil
		end
	end
	for i = 1, table.getn(rema_database.scripts_GT) do
		if exists(rema_database.scripts_GT[i].filePath) == 0 then
			rema_database.scripts_GT[i] = nil
		end
	end
	-- clean registered settings
	rema_database.regSet.radios = nil
	rema_database.regSet.radios = {}

	-- load default registered settings
	local regSet = swbf2Remaster_getDefRegSettings()
	for i = 1, table.getn(regSet.radios) do
		local values = regSet.radios[i]
		local tag = values.tag

		rema_database.regSet.radios[table.getn(rema_database.regSet.radios) + 1] = values
	end

	-- load custom registered settings
	for i = 1, table.getn(rema_database.scripts_OP) do
	
		-- force garbage collection
		swbf2Remaster_getCustomSettings = nil
		
		-- run the settings script that defines swbf2Remaster_getCustomSettings
		local modID = rema_database.scripts_OP[i]
		ReadDataFile(swbf2Remaster_getOPPath(modID))
		ScriptCB_DoFile(modID .. "_option_script")
		
		-- get the custom settings and forget about the getter function
		local customSettings = swbf2Remaster_getCustomSettings()
		swbf2Remaster_getCustomSettings = nil
		
		-- process the custom settings
		for i = 1, table.getn(customSettings.radios) do
			
			local values = customSettings.radios[i]
			local tag = values.tag
			
			-- continue only if tag does not already exists
			if not swbf2Remaster_settingExists(tag) then
				rema_database.regSet.radios[table.getn(rema_database.regSet.radios) + 1] = values
			end
		end
	end

	-- In case there is a registered settings that was not
	-- loaded use the default value instead
	for i = 1, table.getn(rema_database.regSet.radios) do
	
		local values = rema_database.regSet.radios[i]
		local tag = values.tag
		
		if rema_database.radios[tag] == nil then
			rema_database.radios[tag] = values.default
		end
	end

	-- In case there are more settings saved than registered
	-- clean up the global settings. Next save will clean the file
	for tag, values in pairs(rema_database.radios) do
		
		-- the registered setting does not exist
		if not swbf2Remaster_settingExists(tag) then
			rema_database.radios[tag] = nil
		end
	end

	-- Run interface scripts after data integrity test
	swbf2Remaster_runInterfaceScripts()

end

function swbf2Remaster_getDefRegSettings()
	
	-- default registered settings
	local regSet = {
		radios = {
			{
				tag = "aihero",
				title = ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.radio.aihero")),
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.no")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.yes"))},
				default = 2
			},
			{
				tag = "heroVO",
				title = ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.radio.herovo")),
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.no")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.yes"))},
				default = 2
			},
			{
				tag = "customColor",
				title = ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.radio.customcolor")),
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.off")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.on"))},
				default = 2
			},
			{
				tag = "awardEffects",
				title = ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.radio.awardeffects")),
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.off")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.on"))},
				default = 1
			},
			{
				tag = "awardWeapons",
				title = ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.radio.awardweapons")),
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.off")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.on"))},
				default = 2
			},
			{
				tag = "saveSpOptions",
				title = ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.radio.saveopt")),
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.no")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.yes"))},
				default = 1
			},
		}
	}
	
	return regSet
end

function swbf2Remaster_getDefaultSettings()

	local defaultSettings = {
		isRemaDatabase = true,
		radios = {},
		instOp = {},
		scripts_IF = {},
		scripts_IG = {},
		scripts_OP = {},
		scripts_GT = {
			{modID = "Remaster", filePath = "REMASTER\\swbf2Remaster_theme.lvl"},
		},
		themeIdx = 1,
		regSet = swbf2Remaster_getDefRegSettings(),
	}

	return defaultSettings
end

function swbf2Remaster_loadSettings(filename, funcDone)

	ifs_saveop.doOp = "LoadMetagame"
	ifs_saveop.NoPromptSave = 1
	ifs_saveop.filename1 = filename
	
	ifs_saveop.OnSuccess = function()

		ScriptCB_PopScreen()
		
		rema_database = ScriptCB_LoadMetagameState()
		ScriptCB_ClearMetagameState()
		
		ifs_saveop.OnSuccess = ifs_saveop_Success
		ifs_saveop.OnCancel = ifs_saveop_Cancel
		ifs_saveop.beSneaky = nil
		funcDone(nil)
	end
	
	ifs_saveop.OnCancel = function()
		print("Remaster: loading settings failed, loading default..")
		ScriptCB_PopScreen()
		
		rema_database = swbf2Remaster_getDefaultSettings()
		
		ifs_saveop.OnSuccess = ifs_saveop_Success
		ifs_saveop.OnCancel = ifs_saveop_Cancel
		ifs_saveop.beSneaky = nil
		funcDone("loading failed, loading default instead")
	end
	
	ScriptCB_PushScreen("ifs_saveop")
end

function swbf2Remaster_saveSettings(filename, funcDone)
	
	if not rema_database then
		print("Remaster: saving settings failed, no settings found..")
		ifs_saveop.OnSuccess = ifs_saveop_Success
		ifs_saveop.OnCancel = ifs_saveop_Cancel
		ifs_saveop.beSneaky = nil
		funcDone("settings do not exist")
		return
	end

	ScriptCB_SaveMetagameState(rema_database)
	
	ifs_saveop.doOp = "SaveMetagame"
	ifs_saveop.NoPromptSave = 1
	ifs_saveop.filename1 = filename
	ifs_saveop.filename2 = ScriptCB_tounicode(remaIOfilename)
	
	ifs_saveop.OnSuccess = function()
		ScriptCB_PopScreen()
		ScriptCB_ClearMetagameState()
		
		ifs_saveop.OnSuccess = ifs_saveop_Success
		ifs_saveop.OnCancel = ifs_saveop_Cancel
		ifs_saveop.beSneaky = nil
		funcDone(nil)
	end
	
	ifs_saveop.OnCancel = function()
		print("Remaster: saving settings failed..")
		ScriptCB_PopScreen()
		ScriptCB_ClearMetagameState()
		
		ifs_saveop.OnSuccess = ifs_saveop_Success
		ifs_saveop.OnCancel = ifs_saveop_Cancel
		ifs_saveop.beSneaky = nil
		funcDone("saving failed")
	end
	
	ScriptCB_PushScreen("ifs_saveop")
end

function swbf2Remaster_getFilename(filelist)
	if not filelist then
		return nil
	end
	
	local i, currentFilename
	local foundFilename = nil
	
	for i = 1, table.getn(filelist) do
		currentFilename = ScriptCB_ununicode(filelist[i].filename)
		
		if string.find(currentFilename, remaIOfilename) == 1 then
			foundFilename = filelist[i].filename
			break
		end
	end
	
	return foundFilename
end

-- operation = "save" or "load"
-- settings loaded into rema_database
-- settings saved from rema_database
-- funcDone(failure))
-- failure = nil if successfull or error string
function swbf2Remaster_settingsManager(operation, funcDone)

	ifs_saveop.doOp = "LoadFileList"
	ifs_saveop.OnSuccess = nil --ifs_saveop_Success
	ifs_saveop.OnCancel = nil --ifs_saveop_Cancel
	ifs_saveop.beSneaky = 1
	
	if operation == "load" then
	
		ifs_saveop.OnSuccess = function()

			ScriptCB_PopScreen()
			
			-- find the filename
			local filelist, maxSaves = ScriptCB_GetSavedMetagameList(false)
			local filename = swbf2Remaster_getFilename(filelist)
			
			if not filename then
				ifs_saveop.OnSuccess = ifs_saveop_Success
				ifs_saveop.OnCancel = ifs_saveop_Cancel
				ifs_saveop.beSneaky = nil
				rema_database = swbf2Remaster_getDefaultSettings()
				funcDone("unable to find settings file, loading default settings")
				return
			end
			
			-- now load the data
			swbf2Remaster_loadSettings(filename, funcDone)
		end
		
		ifs_saveop.OnCancel = function()
			print("Remaster: loading filelist failed..")
			ScriptCB_PopScreen()
			
			-- cannot load the data. Load default instead(?)
			rema_database = swbf2Remaster_getDefaultSettings()
			ifs_saveop.OnSuccess = ifs_saveop_Success
			ifs_saveop.OnCancel = ifs_saveop_Cancel
			ifs_saveop.beSneaky = nil
			funcDone("unable to load filelist, loading default settings")
		end
		
	elseif operation == "save" then
	
		ifs_saveop.OnSuccess = function()

			ScriptCB_PopScreen()
			
			-- clean up first manuel to avoid pop ups
			local filelist, maxSaves = ScriptCB_GetSavedMetagameList(false)
			local filename = swbf2Remaster_getFilename(filelist)
			
			-- now save the data
			swbf2Remaster_saveSettings(filename, funcDone)
		end
		
		ifs_saveop.OnCancel = function()
			print("Remaster: loading filelist failed, try to save anyway..")
			ScriptCB_PopScreen()
			
			-- we failed, but try to save the data anyway
			swbf2Remaster_saveSettings(nil, funcDone)
		end
	
	else
		print("Remaster: undefined settings operation..")
		ifs_saveop.doOp = nil
		ifs_saveop.OnSuccess = ifs_saveop_Success
		ifs_saveop.OnCancel = ifs_saveop_Cancel
		ifs_saveop.beSneaky = nil
		funcDone("undefined settings operation")
		return
	end
	
	ScriptCB_PushScreen("ifs_saveop");
end
