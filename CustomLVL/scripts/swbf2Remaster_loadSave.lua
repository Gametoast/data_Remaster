------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
-- TODO: Hack ScriptCB_GetSavedMetagameList to not show the settings
------------------------------------------------------------------

local remaIOfilename = "RemasterGlobalSettings"
local remaInstFilename = "RemasterInstOpt"

------------------------------------------------------------------
-- wrap AddIFScreen
-- install backdoor in ifs_saveop.Exit
local remaIO_AddIFScreen = AddIFScreen
AddIFScreen = function(table, name,...)
		
	-- instal backdoor to avoid errors
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
-- wrap ScriptCB_Set/GetNetGame/HeroDefaults
-- grap settings when pushed
-- give saved settings back when asked for

local remaIO_SetGameDefaults = ScriptCB_SetNetGameDefaults
ScriptCB_SetNetGameDefaults = function(defaults, ...)
	-- if we have a database..
	if rema_database then
		-- ..and option is active..
		if rema_database.data.saveSpOptions == 2 then
			-- ..save new settings
			rema_database.instOp.GamePrefs = defaults
		end
	end

	-- let ScriptCB save, too
	return remaIO_SetGameDefaults(defaults, unpack(arg))
end

local remaIO_SetHeroDefaults = ScriptCB_SetNetHeroDefaults
ScriptCB_SetNetHeroDefaults = function(defaults, ...)
	-- if we have a database..
	if rema_database then
		-- ..and option is active..
		if rema_database.data.saveSpOptions == 2 then
			-- ..save new settings
			rema_database.instOp.HeroPrefs = defaults
		end
	end

	-- let ScriptCB save, too
	return remaIO_SetHeroDefaults(defaults, unpack(arg))
end

local remaIO_GetGameDefaults = ScriptCB_GetNetGameDefaults
ScriptCB_GetNetGameDefaults = function(...)
	-- if there is a database..
	if rema_database then
		-- ..and the option is active..
		if rema_database.data.saveSpOptions == 2 then
			-- ..and we have the data..
			if rema_database.instOp.GamePrefs ~= nil then
				-- ..return it
				return rema_database.instOp.GamePrefs
			end
		end
	end

	-- in any other cases, return the scriptCB data
	return remaIO_GetGameDefaults(unpack(arg))
end

local remaIO_GetHeroDefaults = ScriptCB_GetNetHeroDefaults
ScriptCB_GetNetHeroDefaults = function(...)
	-- if there is a database..
	if rema_database then
		-- ..and the option is active..
		if rema_database.data.saveSpOptions == 2 then
			-- ..and we have the data..
			if rema_database.instOp.HeroPrefs ~= nil then
			-- ..return it
				return rema_database.instOp.HeroPrefs
			end
		end
	end
	
	-- in any other cases, return the scriptCB data
	return remaIO_GetHeroDefaults(unpack(arg))
end


------------------------------------------------------------------
-- wrap ScriptCB_SetIFScreen
-- push to options on entering instant action to set settings
local remaIO_SetIFScreen = ScriptCB_SetIFScreen
ScriptCB_SetIFScreen = function(screenName, ...)
	
	if screenName == "ifs_missionselect" then
		remaIO_SetIFScreen("ifs_instant_options")
	end
	
	-- let the original function happen
	return remaIO_SetIFScreen(screenName, unpack(arg))
end


------------------------------------------------------------------
-- wrap ScriptCB_PushScreen
-- load settings before ifs_boot
-- refresh instant options 
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
		
			-- we only need this data
			local lite_databse = {
				isRemaDatabase = true,
				data = rema_database.data,
				scripts_IF = rema_database.scripts_IF,
				scripts_IG = rema_database.scripts_IG,
			}
			
			if ScriptCB_IsMetagameStateSaved() then
				-- there is old data
				local temp = {ScriptCB_LoadMetagameState()}

				ScriptCB_SaveMetagameState(
					lite_databse,
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
				ScriptCB_SaveMetagameState(lite_databse)
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
	if rema_database.data == nil or
		rema_database.instOp == nil or
		rema_database.scripts_IF == nil or
		rema_database.scripts_IG == nil or
		rema_database.scripts_OP == nil or
		rema_database.scripts_GT == nil or
		type(rema_database.scripts_GT[1]) == "table" or		-- old database structure
		rema_database.themeIdx == nil or
		rema_database.regSet == nil then
		
		print("Remaster: data integrity test failed, loading default..")
		rema_database = swbf2Remaster_getDefaultSettings()
	end
	
	-- Check if scripts do no longer exist
	local exists = ScriptCB_IsFileExist
	for i = 1, table.getn(rema_database.scripts_OP) do
		if exists(swbf2Remaster_getOPPath(rema_database.scripts_OP[i])) == 0 then
			table.remove(rema_database.scripts_OP, i)
		end
	end
	for i = 1, table.getn(rema_database.scripts_IF) do
		if exists(swbf2Remaster_getIFPath(rema_database.scripts_IF[i])) == 0 then
			table.remove(rema_database.scripts_IF, i)
		end
	end
	for i = 1, table.getn(rema_database.scripts_IG) do
		if exists(swbf2Remaster_getIGPath(rema_database.scripts_IG[i])) == 0 then
			table.remove(rema_database.scripts_IG, i)
		end
	end
	for i = 1, table.getn(rema_database.scripts_GT) do
		if exists(swbf2Remaster_getGTPath(rema_database.scripts_GT[i])) == 0 then
			table.remove(rema_database.scripts_GT, i)
			rema_database.themeIdx = 1
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
		
		if rema_database.data[tag] == nil then
			rema_database.data[tag] = values.default
		end
	end

	-- In case there are more settings saved than registered
	-- clean up the global settings. Next save will clean the file
	for tag, values in pairs(rema_database.data) do
		
		-- the registered setting does not exist
		if not swbf2Remaster_settingExists(tag) then
			rema_database.data[tag] = nil
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
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.no")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.yes"))},
				default = 2
			},
			{
				tag = "heroVO",
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.no")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.yes"))},
				default = 2
			},
			{
				tag = "customColor",
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.off")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.on"))},
				default = 2
			},
			{
				tag = "awardEffects",
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.off")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.on"))},
				default = 1
			},
			{
				tag = "awardWeapons",
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.off")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.on"))},
				default = 2
			},
			{
				tag = "saveSpOptions",
				buttonStrings = {ScriptCB_ununicode(ScriptCB_getlocalizestr("common.no")), ScriptCB_ununicode(ScriptCB_getlocalizestr("common.yes"))},
				default = 1
			},
		}
	}
	
	return regSet
end

function swbf2Remaster_getDefaultSettings()

	local defaultSettings = {
		data = {},
		instOp = {},
		scripts_IF = {},
		scripts_IG = {},
		scripts_OP = {},
		scripts_GT = { "REMA" },
		themeIdx = 1,
		regSet = swbf2Remaster_getDefRegSettings(),
	}

	for i = 1, table.getn(defaultSettings.regSet.radios) do
	
		local values = defaultSettings.regSet.radios[i]
		local tag = values.tag
		
		if defaultSettings.data[tag] == nil then
			defaultSettings.data[tag] = values.default
		end
	end

	return defaultSettings
end

function swbf2Remaster_loadSettings(nameIO, nameInst, funcDone, loadInstOpt)
		
	ifs_saveop.doOp = "LoadMetagame"
	ifs_saveop.NoPromptSave = 1
	ifs_saveop.beSneaky = 1
	
	if loadInstOpt == nil then

		ifs_saveop.filename1 = nameIO
	
		ifs_saveop.OnSuccess = function()

			ScriptCB_PopScreen()
			
			rema_database = ScriptCB_LoadMetagameState()
			ScriptCB_ClearMetagameState()
			
			ifs_saveop.OnSuccess = ifs_saveop_Success
			ifs_saveop.OnCancel = ifs_saveop_Cancel
			ifs_saveop.beSneaky = nil
			swbf2Remaster_loadSettings(nameIO, nameInst, funcDone, true)
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
		
	else

		if nameInst == nil then
			print("Remaster: missing instant options, loading defaults..")
			ifs_saveop.OnSuccess = ifs_saveop_Success
			ifs_saveop.OnCancel = ifs_saveop_Cancel
			ifs_saveop.beSneaky = nil
			funcDone(nil)
			return
		else
		
			ifs_saveop.filename1 = nameInst
			
			ifs_saveop.OnSuccess = function()
				
				ScriptCB_PopScreen()
				rema_database.instOp = ScriptCB_LoadMetagameState()
				ScriptCB_ClearMetagameState()
				
				ifs_saveop.OnSuccess = ifs_saveop_Success
				ifs_saveop.OnCancel = ifs_saveop_Cancel
				ifs_saveop.beSneaky = nil
				funcDone(nil)
			end
			
			ifs_saveop.OnCancel = function()
				print("Remaster: loading instant options failed, loading defaults..")
				ScriptCB_PopScreen()
				
				ifs_saveop.OnSuccess = ifs_saveop_Success
				ifs_saveop.OnCancel = ifs_saveop_Cancel
				ifs_saveop.beSneaky = nil
				funcDone(nil)
			end
		end
	end
	
	ScriptCB_PushScreen("ifs_saveop")
end

function swbf2Remaster_saveSettings(nameIO, nameInst, funcDone, skipInst)
	
	if not rema_database then
		print("Remaster: saving settings failed, no settings found..")
		ifs_saveop.OnSuccess = ifs_saveop_Success
		ifs_saveop.OnCancel = ifs_saveop_Cancel
		ifs_saveop.beSneaky = nil
		funcDone("settings do not exist")
		return
	end
	
	-- save instant options?
	local saveInstOpt = false
	
	if rema_database.data.saveSpOptions == 2 and rema_database.instOp.GamePrefs ~= nil and skipInst == nil then
		saveInstOpt = true
	end
	
	-- splitt instant options from database
	local temp = rema_database.instOp
	rema_database.instOp = {}
	
	ifs_saveop.doOp = "SaveMetagame"
	ifs_saveop.NoPromptSave = 1
	ifs_saveop.beSneaky = 1
	
	if saveInstOpt then
		ScriptCB_SaveMetagameState(temp)
		
		ifs_saveop.filename1 = nameInst
		ifs_saveop.filename2 = ScriptCB_tounicode(remaInstFilename)
		
		ifs_saveop.OnSuccess = function()
			ScriptCB_PopScreen()
			ScriptCB_ClearMetagameState()
			
			ifs_saveop.OnSuccess = ifs_saveop_Success
			ifs_saveop.OnCancel = ifs_saveop_Cancel
			ifs_saveop.beSneaky = nil
			swbf2Remaster_saveSettings(nameIO, nameInst, funcDone, true)
		end
		
		ifs_saveop.OnCancel = function()
			print("Remaster: saving instant options failed..")
			print("        : trying to save database anyway..")
			ScriptCB_PopScreen()
			ScriptCB_ClearMetagameState()
			
			ifs_saveop.OnSuccess = ifs_saveop_Success
			ifs_saveop.OnCancel = ifs_saveop_Cancel
			ifs_saveop.beSneaky = nil
			swbf2Remaster_saveSettings(nameIO, nameInst, funcDone, true)
		end
	else
		ScriptCB_SaveMetagameState(rema_database)
		
		ifs_saveop.filename1 = nameIO
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
	end
	
	-- merge instant options and database
	rema_database.instOp = temp
	temp = nil
	
	-- let the magic happen
	ScriptCB_PushScreen("ifs_saveop")
	
end

function swbf2Remaster_getFilename(filelist, name1, name2)
	if not filelist then
		return nil, nil
	end
	
	local i, currentFilename
	local foundFilenames = { nil, nil}
	
	for i = 1, table.getn(filelist) do
		currentFilename = ScriptCB_ununicode(filelist[i].filename)
		
		if string.find(currentFilename, name1) == 1 then
			foundFilenames[1] = filelist[i].filename
		elseif string.find(currentFilename, name2) == 1 then
			foundFilenames[2] = filelist[i].filename
		end
	end
	
	return unpack(foundFilenames)
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
			local filenameIO, filenameInst = swbf2Remaster_getFilename(filelist, remaIOfilename, remaInstFilename)
			
			if not filenameIO then
				ifs_saveop.OnSuccess = ifs_saveop_Success
				ifs_saveop.OnCancel = ifs_saveop_Cancel
				ifs_saveop.beSneaky = nil
				rema_database = swbf2Remaster_getDefaultSettings()
				funcDone("unable to find settings file, loading default settings")
				return
			end
			
			-- now load the data
			swbf2Remaster_loadSettings(filenameIO, filenameInst, funcDone)
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
			local filenameIO, filenameInst = swbf2Remaster_getFilename(filelist, remaIOfilename, remaInstFilename)
			
			-- now save the data
			swbf2Remaster_saveSettings(filenameIO, filenameInst, funcDone)
		end
		
		ifs_saveop.OnCancel = function()
			print("Remaster: loading filelist failed, try to save anyway..")
			ScriptCB_PopScreen()
			
			-- we failed, but try to save the data anyway
			swbf2Remaster_saveSettings(nil, nil, funcDone)
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
