------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------


-- adjust some globals depending on screen values ----------------
-- adjusting global variables
local w, h = ScriptCB_GetScreenInfo()
local zoomFactor = 1
if(h ~= 600) then
	zoomFactor = 1.152
end

-- stock variables
--gButtonHeightPad = h/100					-- button hight
gButtonGutter = w/200 * zoomFactor			-- button spacing
gListboxSliderWidth =  16 * zoomFactor		-- slider width

-- v1.3 patch variables
custom_location_era_y = h * 353/600 + (h/600 - 1) * 20		-- y position of era buttons
custom_max_eras = math.floor(5 * h/600 + 0.5)				-- maximum displayed eras
custom_max_modes = math.floor(14 * h/600 + 0.5)				-- maximum displayed game mods

-- own global helper variable
remaGUI_onInstantActionScreen = false

------------------------------------------------------------------
-- Helper functions

function ifs_rema_gc_lisbox_CreateItem(layout)
	local Temp = NewIFContainer { x = layout.x - 0.5 * layout.width, y=layout.y - 0.5 * layout.height}

	local UseFont = layout.listboxlayout.FontStr
	local width = layout.listboxlayout.width
	local yHeight = layout.listboxlayout.iFontHeight

	Temp.button = NewRoundIFButton { 
		x = -20,
		y = yHeight / 2, 
		btnw = width, 
		btnh = yHeight,
		font = UseFont, 
		bg_flipped = nil, -- bLastItem,
		startdelay = 1*flashySpeed, 
		bg_width = width, 
		flashy = true,
		nocreatebackground = false,
		rightjustifybackground = false,
		bRightJustify = false,
	}
	
	Temp.button.label.x = 0
	Temp.button.label.bHotspot = 1
	Temp.button.label.fHotspotW = width + 16
	Temp.button.label.fHotspotH = yHeight
	
	Temp.button.label.bgexpandx = 0
	Temp.button.label.bgexpandy = gButtonHeightPad * 0.5
	
	Temp.button.label.bgleft = "bf2_buttons_midleft"
	Temp.button.label.bgmid = "bf2_buttons_items_center"
	Temp.button.label.bgright = "bf2_buttons_midright"
	
	Temp.button.font = nil
	RoundIFButtonLabel_fnSetString(Temp.button,"XXXX")
	Temp.button.tag = "button_tag"
	
	return Temp
end

function ifs_rema_gc_lisbox_PopulateItem(Dest, Data, bSelected, iColorR, iColorG, iColorB, fAlpha)
	if(Data) then
		local text = ScriptCB_getlocalizestr(Data.string)
		if text == ScriptCB_tounicode("[NULL]") then
			text = ScriptCB_tounicode(Data.string)
		end
		
		IFText_fnSetUString(Dest.button.label,text)
		Dest.button.tag = Data.tag
	else
		IFObj_fnSetVis(Dest, nil)
		Dest.button.tag = nil
	end
end

function ifs_rema_gc_getListboxLineNumber()
	local w, h = ScriptCB_GetScreenInfo()
	
	-- 60% of screenheight devided by line height and 3 (there are 3 boxes) + 0.5 to round off
	return math.floor(h * 0.4 / 35 + 0.5)
end

------------------------------------------------------------------
-- wrapper and overwrite

-- overwrite ScriptCB_GetCurrentPCTitleVersion, no need to backup, we don't need the old version
ScriptCB_GetCurrentPCTitleVersion = function ()
		
	return ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.version"))
end


-- try to overwrite ifelem_tabmanager_DoCreateTabs ---------------
-- include zoomFactor in all calculations
if ifelem_tabmanager_DoCreateTabs then
	
	-- overwrite ifelem_tabmanager_DoCreateTabs, no need to backup, we don't need the old version
	function ifelem_tabmanager_DoCreateTabs( aLayout )
		local w,aw,h,ah
		w,h = ScriptCB_GetSafeScreenInfo()
		aw,ah = ScriptCB_GetScreenInfo()
		local zoomFactor = 1
		if(ah ~= 600) then
			zoomFactor = 1.152
		end
		
		aw = aw - (20 * zoomFactor)
		
		if( not aLayout ) then
			return nil
		end
		
		mTabs = NewIFContainer { --container for all the backgrounds
			ScreenRelativeX = 0.0,
			ScreenRelativeY = 0.0,--(ah/600 - 1) * 0.025, --0.0375
			ZPos = 60,
			UseSafezone = 0, 
		}

		local tabheight = 18
		--if(ah ~= 600) then
		--	tabheight = tabheight * (ah / 600)
		--end

		local i
		local NUM_TABS = table.getn(aLayout)
		local xWidth = 800 / NUM_TABS
		local deltaXPos = math.floor(xWidth) - 5
		
		local xPos = 10		--deltaXPos / 2 --(xWidth * 0.65) + 30
		local yPos = 15
		
		local yOffset =  yPos * (1 - zoomFactor) - 50 * (ah/600 - 1.28)
		
		if aLayout[1].yPos and ah ~= 600 then
			yOffset = aLayout[1].yPos * (1 - zoomFactor)
			
			if aLayout[1].tag == "_tab_mini" or aLayout[1].tag == "_tab_single" or
			   aLayout[1].tag == "_tab_campaign" or aLayout[1].tag == "_tab_join" or aLayout[1].tag == "_tab_general" then
				yOffset = yOffset - 50 * (ah/600 - 1.28)
			end
			
			if aLayout[1].tag == "_opt_playlist" then
				yOffset = yOffset - 125 * (ah/600 - 1.28)
			end
			
			-- unchanged _tab_soldier and _tab_fleet
		end
		
		aLayout.reMaGUI_yOffset = yOffset
		

	-- Loadspam commented out NM 9/8/05. Re-enable locally if you need it
	--	print( "w=", w, "aw=", aw, "NUM_TABS=", NUM_TABS, "xWidth=", xWidth, "xPos=", xPos )
		for i=1, NUM_TABS do
			local TagName = aLayout[i].tag
			local width = deltaXPos
			--xPos = deltaXPos + i * deltaXPos
			if( aLayout[i].width ) then
				width = aLayout[i].width
			end 	
			
			if((aw ~= 800)) then
				local scaleX = (aw / 800 )
				width = width * scaleX
			end
			
			xPos = xPos + (width/2) -- carryover from last time, if our xPos isn't set...
			
			local manualXPos = false
			if( aLayout[i].xPos ) then
				xPos = aLayout[i].xPos
				manualXPos = true
			end 		
			local manualYPos = false
			if( aLayout[i].yPos ) then
				yPos = aLayout[i].yPos
				manualYPos = true
			end 	
			
			-- attempt at screen-relative everything - GAW, the things that people request...
			if((aw ~= 800) or (ah ~= 600)) then
				local scaleX = (aw / 800)
				local scaleY = (ah / 600)
				
				if(manualXPos) then
					xPos = xPos * scaleX
				end
				--if(manualYPos) then
				--	yPos = yPos * scaleY
				--end
			end
			
			local hotspotX = width / 2 - 4 -- yay for magic numbers!
			local hotspotY = 6 -- yay again!
			if( aLayout[i].hotspot_x ) then
				hotspotX = aLayout[i].hotspot_x
			end 		
			if( aLayout[i].hotspot_y ) then
				hotspotY = aLayout[i].hotspot_y
			end 		

			local hotspotW = width
			local hotspotH = tabheight
			if( aLayout[i].hotspot_width ) then
				hotspotW = aLayout[i].hotspot_width
			end 		
			if( aLayout[i].hotspot_height ) then
				hotspotH = aLayout[i].hotspot_height
			end

	-- Loadspam commented out NM 9/8/05. Re-enable locally if you need it
	--		print( "xPos", i, " = ", xPos, aLayout[i].tag )
			mTabs[TagName] = NewClickableIFButton {
				tag = TagName,
				font = aLayout.font or "gamefont_medium",
				ZPos = 50,
				x = xPos,
				y = yPos - yPos * (1 - zoomFactor) - yOffset,
				btnw = width,
				btnh = tabheight,
				string = aLayout[i].string,
				bg_width = width - (20 * zoomFactor),
				bStyleTabbed = 1,
				halign = "hcenter", 
				hotspot_x = hotspotX,
				hotspot_y = hotspotY,
				hotspot_width = width,
				hotspot_height = hotspotH,
				--bHidden = 1,
			}

			--mTabs[TagName].label.string = aLayout[i].string
			--mTabs[TagName].label.bgleft = "BF2_radiobutton_on"
			--mTabs[TagName].label.bgright = ""
			--mTabs[TagName].label.bgmid = "border_dropdown"
			--RoundIFButtonLabel_fnSetString(mTabs[TagName], aLayout[i].string)
	--		IFObj_fnSetVis( mTabs[TagName], nil )
			xPos = xPos + (width/2)
		end
		
		return mTabs
	end
else
	print("Remaster: Error")
	print("        : ifelem_tabmanager_DoCreateTabs() not found!")
end

-- try to wrap ifelem_tabmanager_SetPos --------------------------
-- manipulate y values to insert remaster tab
if ifelem_tabmanager_SetPos then
	
	-- backup old function
	local remaGUI_ifelem_tabmanager_SetPos = ifelem_tabmanager_SetPos

	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()
	
	-- wrap ifelem_tabmanager_SetPos
	ifelem_tabmanager_SetPos = function(this, aLayout, Tag, useTab, x, y,...)
		
		-- get custom offset for the layout
		local yOffset = aLayout.reMaGUI_yOffset or 0		
		
		-- manipulate old y value
		if y then
			y = y  - y * (1 - zoomFactor) - yOffset
		end
		
		-- let the original function happen
		return remaGUI_ifelem_tabmanager_SetPos(this, aLayout, Tag, useTab, x, y, unpack(arg))
	end
else
	print("Remaster: Error")
	print("        : ifelem_tabmanager_SetPos() not found!")
end

-- try to wrap ScriptCB_DoFile -----------------------------------
-- set global identifier helper variables for other fix functions
-- add splashscreen
-- insert remaster option page
if ScriptCB_DoFile then
	
	-- backup old function
	local remaGUI_ScriptCB_DoFile = ScriptCB_DoFile
	
	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()

	-- wrap ScriptCB_DoFile
	ScriptCB_DoFile = function(...)

		-- set global identifier helper variables true 
		if arg[1] == "ifs_missionselect_pcMulti" or arg[1] == "ifs_missionselect" then
			remaGUI_onInstantActionScreen = true
		end
		
		-- let the original function happen and catch the return value
	    local remaGUI_SCBDFreturn = {remaGUI_ScriptCB_DoFile(unpack(arg))}

		-- reset global identifier helper variables 
		if arg[1] == "ifs_missionselect_pcMulti" or arg[1] == "ifs_missionselect" then
			remaGUI_onInstantActionScreen = false
		end
		
		-- insert splash screen
		if arg[1] == "ifs_legal" then
			gLegalScreenList[table.getn(gLegalScreenList) + 1] = {texture = "swbf2Remaster_splash", time = 3, bSkippable = 1, }
		end
		
		-- insert option screen
		if arg[1] == "pctabs_options" then
			local tabWidth = 0
			for i in pairs(gPCOptionsTabsLayout) do --[1].width * table.getn(gPCOptionsTabsLayout)
				tabWidth = tabWidth + gPCOptionsTabsLayout[i].width
			end
			
			tabWidth = tabWidth / (table.getn(gPCOptionsTabsLayout) + 1)
			
			for i in pairs(gPCOptionsTabsLayout) do --[1].width * table.getn(gPCOptionsTabsLayout)
				gPCOptionsTabsLayout[i].width = tabWidth
			end
			
			gPCOptionsTabsLayout[1].xPos = gPCOptionsTabsLayout[1].xPos - 14
			
			table.insert(gPCOptionsTabsLayout, 2, {tag = "_tab_remaster", string = "REMASTER", screen = "ifs_opt_remaster", yPos = 45, width = tabWidth})
		elseif arg[1] == "ifs_opt_sound" then 
			ScriptCB_DoFile("ifs_opt2_remaster")
		end
		
		-- return the original values
	    return unpack(remaGUI_SCBDFreturn)
	end
else
	print("Remaster: Error")
	print("        : ScriptCB_DoFile() not found!")
end

-- try to wrap ScriptCB_GetScreenInfo ----------------------------
-- global fix by setting widescreen value always to 1
if ScriptCB_GetScreenInfo then
	
	-- backup old function
	local remaGUI_ScriptCB_GetScreenInfo = ScriptCB_GetScreenInfo
	
	-- wrap ScriptCB_GetScreenInfo
	ScriptCB_GetScreenInfo = function(...)
		-- let the original function happen and catch the return value
		local remaGUI_SCBGSIreturn = {remaGUI_ScriptCB_GetScreenInfo(unpack(arg))}
		
		-- manipulate the wide-screen value
		if remaGUI_SCBGSIreturn[4] > 1 then
			remaGUI_SCBGSIreturn[4] = 1
		end
		
		-- return the manipulated values
		return unpack(remaGUI_SCBGSIreturn)
	end
else
	print("Remaster: Error")
	print("        : ScriptCB_GetScreenInfo() not found!")
end

-- try to wrap ScriptCB_GetNetGameDefaults ----------------------------
-- change instant options
-- increase max AI bots
if ScriptCB_GetNetGameDefaults then
	
	-- backup old function
	local remaGUI_ScriptCB_GetNetGameDefaults = ScriptCB_GetNetGameDefaults
	
	-- wrap ScriptCB_GetNetGameDefaults
	ScriptCB_GetNetGameDefaults = function(...)
		-- let the original function happen and catch the return value
		local defaultTable = remaGUI_ScriptCB_GetNetGameDefaults(unpack(arg))
		
		-- increase max AI bots
		defaultTable.iMaxBots = 64
		
		-- return the manipulated values
		return defaultTable
	end
else
	print("Remaster: Error")
	print("        : ScriptCB_GetNetGameDefaults() not found!")
end

-- try to wrap AddIFScreen ---------------------------------------
-- fix profile select screen
-- fix multiplayer current online match screen
-- fixing mulitplayer create session screen
-- fix general option screen
-- fix graphic option screen
-- fix sound option screen
-- fix online option screen
-- change buttons from buttonlist on gc screen
if AddIFScreen then
	
	-- backup old function
	local remaGUI_AddIFScreen = AddIFScreen
	
	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()
	
	-- wrap AddIFScreen
	AddIFScreen = function(ifsTable, name,...)

		-- fix profile select screen
		if name == "ifs_login" then
			
			-- fixing y positions
			ifs_login.profile_button.ScreenRelativeY = 0.4
			ifs_login.profile_button.y = 0

			ifs_login.select_profile.ScreenRelativeY = 0.4
			ifs_login.select_profile.y = -30

			ifs_login.listbox.ScreenRelativeY = 0.4
			ifs_login.listbox.y = 70

			ifs_login.select_diff.ScreenRelativeY = 0.4
			ifs_login.select_diff.y = 70

			ifs_login.diff_button.ScreenRelativeY = 0.4
			ifs_login.diff_button.y = 100

			ifs_login.diff_listbox.ScreenRelativeY = 0.4
			ifs_login.diff_listbox.y = 140

			ifs_login.NewBox.ScreenRelativeY = 0.4
			ifs_login.NewBox.y = 0
		end
		
		-- fix multiplayer current online match screen
		if name == "ifs_mp_sessionlist" then
	
			-- fixing server and player info
			ifs_mp_sessionlist.serverinfo.y = ifs_mp_sessionlist.serverinfo.y * screenH/600
			ifs_mp_sessionlist.playerlist.y = ifs_mp_sessionlist.playerlist.y * screenH/600
			
			-- fixing server list
			ifs_mp_sessionlist.listbox.titleBarElement.y = -125.5
			ifs_mp_sessionlist.listbox.skin.y = (screenH/600 - 1) * 100
			ifs_mp_sessionlist.listbox.y = 175
			ifs_mp_sessionlist.listbox.ScreenRelativeY = 0.07
			
			-- fixing server header text
			ifs_mp_sessionlist.ResortButtons.y = 60-- 32
			ifs_mp_sessionlist.ResortButtons.mapnameLabel.y = 0
			ifs_mp_sessionlist.ResortButtons.numplayersLabel.y = 0
			ifs_mp_sessionlist.ResortButtons.favoriteLabel.y = 0
			ifs_mp_sessionlist.ResortButtons.pingLabel.y = 0
			ifs_mp_sessionlist.ResortButtons.eraLabel.y = 0
			ifs_mp_sessionlist.ResortButtons.gamemodeLabel.y = 0
			ifs_mp_sessionlist.ResortButtons.gamenameLabel.y = 0
			ifs_mp_sessionlist.ResortButtons.servertypeLabelLabel.y = 0
			ifs_mp_sessionlist.ResortButtons.ScreenRelativeY = 0.07
			
			-- fixing filter bar
			ifs_mp_sessionlist.DropBoxes.y = 32
			ifs_mp_sessionlist.DropBoxes.ScreenRelativeY = 0.07
			
			-- fixing LAN/Internet dropdown
			ifs_mp_sessionlist.source_button.ScreenRelativeX = 0.1
			ifs_mp_sessionlist.source_button.x = 0
			ifs_mp_sessionlist.source_button.ScreenRelativeY = 0.07
			ifs_mp_sessionlist.source_button.y = 0
			
			ifs_mp_sessionlist.source_listbox.ScreenRelativeX = 0.1
			ifs_mp_sessionlist.source_listbox.x = 0
			ifs_mp_sessionlist.source_listbox.ScreenRelativeY = 0.07
			ifs_mp_sessionlist.source_listbox.y = 35
			ifs_mp_sessionlist.source_listbox[1].text.textw = 150
			ifs_mp_sessionlist.source_listbox[1].text.x = 10
			ifs_mp_sessionlist.source_listbox[1].text.y = -4.5
			ifs_mp_sessionlist.source_listbox[2].text.textw = 150
			ifs_mp_sessionlist.source_listbox[2].text.x = 10
			ifs_mp_sessionlist.source_listbox[2].text.y = -4.5
			
			-- fixing login text
			ifs_mp_sessionlist.LoginAsText1.y = 510 * screenH/600
			ifs_mp_sessionlist.LoginAsText2.y = (510 + 12) * screenH/600
		end
		
		-- fixing mulitplayer create session screen
		if name == "ifs_missionselect_pcMulti" then
		
			-- fixing servername and passwort position and name length
			ifs_missionselect_pcMulti.EditContainer.ScreenRelativeY = 0.05
			ifs_missionselect_pcMulti.EditContainer.ScreenRelativeX = 0.8
			ifs_missionselect_pcMulti.EditContainer.EditGameText.y = 0
			ifs_missionselect_pcMulti.EditContainer.EditGameText.halign = "left"
			ifs_missionselect_pcMulti.EditContainer.EditGameText.x = -ifs_missionselect_pcMulti.EditContainer.EditGameName.w * 0.9
			ifs_missionselect_pcMulti.EditContainer.EditGameName.y = 10
			ifs_missionselect_pcMulti.EditContainer.EditGameName.MaxChars = math.floor(ifs_missionselect_pcMulti.EditContainer.EditGameName.MaxLen * 0.098)
			
			ifs_missionselect_pcMulti.EditPwdContainer.ScreenRelativeY = 0.05
			ifs_missionselect_pcMulti.EditPwdContainer.ScreenRelativeX = 0.8
			ifs_missionselect_pcMulti.EditPwdContainer.y = 25
			ifs_missionselect_pcMulti.EditPwdContainer.EditPassText.y = 0
			ifs_missionselect_pcMulti.EditPwdContainer.EditPassText.halign = "left"
			ifs_missionselect_pcMulti.EditPwdContainer.EditPassText.x = -ifs_missionselect_pcMulti.EditPwdContainer.EditPass.w * 0.9
			ifs_missionselect_pcMulti.EditPwdContainer.EditPass.y = 10
			ifs_missionselect_pcMulti.EditPwdContainer.EditPass.MaxChars = math.floor(ifs_missionselect_pcMulti.EditPwdContainer.EditPass.MaxLen * 0.098)

			-- fixing login text
			ifs_missionselect_pcMulti.LoginAsText1.y = 510 * screenH/600
			ifs_missionselect_pcMulti.LoginAsText2.y = (510 + 12) * screenH/600
			
			-- fixing LAN/Internet dropdown
			ifs_missionselect_pcMulti.source_button.ScreenRelativeX = 0.1
			ifs_missionselect_pcMulti.source_button.x = 0
			ifs_missionselect_pcMulti.source_button.ScreenRelativeY = 0.07
			ifs_missionselect_pcMulti.source_button.y = 0
			
			ifs_missionselect_pcMulti.source_listbox.ScreenRelativeX = 0.1
			ifs_missionselect_pcMulti.source_listbox.x = 0
			ifs_missionselect_pcMulti.source_listbox.ScreenRelativeY = 0.07
			ifs_missionselect_pcMulti.source_listbox.y = 35
			ifs_missionselect_pcMulti.source_listbox[1].text.textw = 150
			ifs_missionselect_pcMulti.source_listbox[1].text.x = 10
			ifs_missionselect_pcMulti.source_listbox[1].text.y = -4.5
			ifs_missionselect_pcMulti.source_listbox[2].text.textw = 150
			ifs_missionselect_pcMulti.source_listbox[2].text.x = 10
			ifs_missionselect_pcMulti.source_listbox[2].text.y = -4.5
		end
		
		-- fix general option screen
		if name == "ifs_opt_general" then
		
			-- fixing slider's value text
			ifs_opt_general.formcontainergeneral.form.buttons.reticulealpha.label.x = 0.25 * (ifs_opt_general.formcontainergeneral.form.sliders.reticulealpha.width - 180)
		end

		-- fix graphic option screen
		if name == "ifs_opt_pcvideo" then
			
			-- some values
			local offset = 120 * (1 - (800 / 600 * screenH / screenW))
			local width = ifs_opt_pcvideo.formcontainergeneral.form.dropdowns.overallquality.listbox.width
			
			-- set main container relative and adjust offset from center
			ifs_opt_pcvideo.formcontainergeneral.ScreenRelativeY = 0.5
			ifs_opt_pcvideo.formcontainergeneral.y = ifs_opt_pcvideo.formcontainergeneral.y - 270
			
			-- fix the dropbox's positions, hilights and cursors
			ifs_opt_pcvideo.formcontainergeneral.form.dropdowns.overallquality.button.x = ifs_opt_pcvideo.formcontainergeneral.form.dropdowns.overallquality.button.x + offset
			ifs_opt_pcvideo.formcontainergeneral.form.dropdowns.overallquality.listbox.cursor.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainergeneral.form.dropdowns.overallquality.listbox.cursor.skin.localpos_l = -width / 2
			ifs_opt_pcvideo.formcontainergeneral.form.dropdowns.overallquality.listbox.hilight.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainergeneral.form.dropdowns.overallquality.listbox.hilight.skin.localpos_l = -width / 2
			for i, item in ipairs(ifs_opt_pcvideo.formcontainergeneral.form.dropdowns.overallquality.listbox) do
				item.fHotspotW = width - 12
				item.fHotspotX = - offset + 12
			end
		
			ifs_opt_pcvideo.formcontainercustom.ScreenRelativeY = 0.5
			ifs_opt_pcvideo.formcontainercustom.y = ifs_opt_pcvideo.formcontainercustom.y - 270
			
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.multisample.button.x = ifs_opt_pcvideo.formcontainercustom.form.dropdowns.multisample.button.x + offset
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.multisample.listbox.cursor.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.multisample.listbox.cursor.skin.localpos_l = -width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.multisample.listbox.hilight.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.multisample.listbox.hilight.skin.localpos_l = -width / 2
			for i, item in ipairs(ifs_opt_pcvideo.formcontainercustom.form.dropdowns.multisample.listbox) do
				item.fHotspotW = width - 12
				item.fHotspotX = - offset + 12
			end
			
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.lightingquality.button.x = ifs_opt_pcvideo.formcontainercustom.form.dropdowns.lightingquality.button.x + offset
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.lightingquality.listbox.cursor.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.lightingquality.listbox.cursor.skin.localpos_l = -width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.lightingquality.listbox.hilight.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.lightingquality.listbox.hilight.skin.localpos_l = -width / 2
			for i, item in ipairs(ifs_opt_pcvideo.formcontainercustom.form.dropdowns.lightingquality.listbox) do
				item.fHotspotW = width - 12
				item.fHotspotX = - offset + 12
			end
			
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.specularquality.button.x = ifs_opt_pcvideo.formcontainercustom.form.dropdowns.specularquality.button.x + offset
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.specularquality.listbox.cursor.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.specularquality.listbox.cursor.skin.localpos_l = -width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.specularquality.listbox.hilight.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.specularquality.listbox.hilight.skin.localpos_l = -width / 2
			for i, item in ipairs(ifs_opt_pcvideo.formcontainercustom.form.dropdowns.specularquality.listbox) do
				item.fHotspotW = width - 12
				item.fHotspotX = - offset + 12
			end
			
			local width_offset = 2 * ifs_opt_pcvideo.formcontainercustom.form.dropdowns.resolution.listbox.sliderbg.localpos_r
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.resolution.button.x = ifs_opt_pcvideo.formcontainercustom.form.dropdowns.resolution.button.x + offset
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.resolution.listbox.cursor.skin.localpos_r = (width - width_offset) / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.resolution.listbox.cursor.skin.localpos_l = -(width - width_offset) / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.resolution.listbox.hilight.skin.localpos_r = (width - width_offset) / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.resolution.listbox.hilight.skin.localpos_l = -(width - width_offset) / 2
			for i, item in ipairs(ifs_opt_pcvideo.formcontainercustom.form.dropdowns.resolution.listbox) do
				item.x = item.x + (width_offset / 2)
				item.fHotspotW = (width - width_offset) - 12
				item.fHotspotX = - offset - (width_offset / 2) + 12
			end
			
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.shadowquality.button.x = ifs_opt_pcvideo.formcontainercustom.form.dropdowns.shadowquality.button.x + offset
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.shadowquality.listbox.cursor.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.shadowquality.listbox.cursor.skin.localpos_l = -width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.shadowquality.listbox.hilight.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.shadowquality.listbox.hilight.skin.localpos_l = -width / 2
			for i, item in ipairs(ifs_opt_pcvideo.formcontainercustom.form.dropdowns.shadowquality.listbox) do
				item.fHotspotW = width - 12
				item.fHotspotX = - offset + 12
			end
			
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.particlequality.button.x = ifs_opt_pcvideo.formcontainercustom.form.dropdowns.particlequality.button.x + offset
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.particlequality.listbox.cursor.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.particlequality.listbox.cursor.skin.localpos_l = -width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.particlequality.listbox.hilight.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.particlequality.listbox.hilight.skin.localpos_l = -width / 2
			for i, item in ipairs(ifs_opt_pcvideo.formcontainercustom.form.dropdowns.particlequality.listbox) do
				item.fHotspotW = width - 12
				item.fHotspotX = - offset + 12
			end
			
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.waterquality.button.x = ifs_opt_pcvideo.formcontainercustom.form.dropdowns.waterquality.button.x + offset
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.waterquality.listbox.cursor.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.waterquality.listbox.cursor.skin.localpos_l = -width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.waterquality.listbox.hilight.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.waterquality.listbox.hilight.skin.localpos_l = -width / 2
			for i, item in ipairs(ifs_opt_pcvideo.formcontainercustom.form.dropdowns.waterquality.listbox) do
				item.fHotspotW = width - 12
				item.fHotspotX = - offset + 12
			end
			
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.texturedetail.button.x = ifs_opt_pcvideo.formcontainercustom.form.dropdowns.texturedetail.button.x + offset
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.texturedetail.listbox.cursor.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.texturedetail.listbox.cursor.skin.localpos_l = -width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.texturedetail.listbox.hilight.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.texturedetail.listbox.hilight.skin.localpos_l = -width / 2
			for i, item in ipairs(ifs_opt_pcvideo.formcontainercustom.form.dropdowns.texturedetail.listbox) do
				item.fHotspotW = width - 12
				item.fHotspotX = - offset + 12
			end
			
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.terrainquality.button.x = ifs_opt_pcvideo.formcontainercustom.form.dropdowns.terrainquality.button.x + offset
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.terrainquality.listbox.cursor.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.terrainquality.listbox.cursor.skin.localpos_l = -width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.terrainquality.listbox.hilight.skin.localpos_r = width / 2
			ifs_opt_pcvideo.formcontainercustom.form.dropdowns.terrainquality.listbox.hilight.skin.localpos_l = -width / 2
			for i, item in ipairs(ifs_opt_pcvideo.formcontainercustom.form.dropdowns.terrainquality.listbox) do
				item.fHotspotW = width - 12
				item.fHotspotX = - offset + 12
			end
		end
		
		-- fix sound option screen
		if name == "ifs_opt_sound" then
			
			-- save bar width, function will return different value after relative changes
			local barWidth = ifs_opt_sound_getBarSize(ifs_opt_sound)
			
			-- move everything to center
			ifs_opt_sound.buttonlabels.ScreenRelativeX = 0.5
			ifs_opt_sound.buttons.ScreenRelativeX = 0.5
			ifs_opt_sound.radiobuttons.ScreenRelativeX = 0.5
			ifs_opt_sound.sliders.ScreenRelativeX = 0.5
			ifs_opt_sound.res_dropdown_btn.ScreenRelativeX = 0.5
			ifs_opt_sound.mixer_dropdown_btn.ScreenRelativeX = 0.5
			ifs_opt_sound.modelist_listbox.ScreenRelativeX = 0.5
			ifs_opt_sound.mixerlist_listbox.ScreenRelativeX = 0.5
			
			ifs_opt_sound.buttonlabels.ScreenRelativeY = 0.5
			ifs_opt_sound.buttons.ScreenRelativeY = 0.5
			ifs_opt_sound.radiobuttons.ScreenRelativeY = 0.5
			ifs_opt_sound.sliders.ScreenRelativeY = 0.5
			ifs_opt_sound.res_dropdown_btn.ScreenRelativeY = 0.5
			ifs_opt_sound.mixer_dropdown_btn.ScreenRelativeY = 0.5
			ifs_opt_sound.modelist_listbox.ScreenRelativeY = 0.5
			ifs_opt_sound.mixerlist_listbox.ScreenRelativeY = 0.5
			
			-- adjust position offset from center
			ifs_opt_sound.buttonlabels.x = -72
			ifs_opt_sound.buttons.x = barWidth + (48 * screenW / 800)
			ifs_opt_sound.radiobuttons.x = -72 * 800 / screenW
			ifs_opt_sound.sliders.x = (barWidth - 178) * (800 / 600 * screenH / screenW )
			ifs_opt_sound.res_dropdown_btn.x = (barWidth - 178) * (800 / 600 * screenH / screenW )
			ifs_opt_sound.mixer_dropdown_btn.x = (barWidth - 178) * (800 / 600 * screenH / screenW )
			ifs_opt_sound.modelist_listbox.x = (barWidth - 178) * (800 / 600 * screenH / screenW )
			ifs_opt_sound.mixerlist_listbox.x = (barWidth - 178) * (800 / 600 * screenH / screenW )
			
			ifs_opt_sound.buttonlabels.y = -270
			ifs_opt_sound.buttons.y = -270
			ifs_opt_sound.radiobuttons.y = -3 -270
			ifs_opt_sound.sliders.y = -270
			ifs_opt_sound.res_dropdown_btn.y = ifs_opt_sound.res_dropdown_btn.y -270
			ifs_opt_sound.mixer_dropdown_btn.y = ifs_opt_sound.mixer_dropdown_btn.y -270
			ifs_opt_sound.modelist_listbox.y = ifs_opt_sound.modelist_listbox.y -270
			ifs_opt_sound.mixerlist_listbox.y = ifs_opt_sound.mixerlist_listbox.y -270
			
			-- fix dropbox element's hotspots
			for i = 1, ifs_opt_sound.modelist_listbox.Layout.showcount do
				ifs_opt_sound.modelist_listbox[i].fHotspotW = barWidth - 12
				ifs_opt_sound.modelist_listbox[i].x = - 0.5 * (barWidth - 12)
				ifs_opt_sound.modelist_listbox[i].text.x = 10
			end
			
			for i = 1, ifs_opt_sound.mixerlist_listbox.Layout.showcount do
				ifs_opt_sound.mixerlist_listbox[i].fHotspotW = barWidth - 12
				ifs_opt_sound.mixerlist_listbox[i].x = - 0.5 * (barWidth - 12)
				ifs_opt_sound.mixerlist_listbox[i].text.x = 10
			end
		
			-- fix dropbox cursor and hilight
			ifs_opt_sound.modelist_listbox.cursor.width = barWidth
			ifs_opt_sound.modelist_listbox.cursor.w = barWidth
			ifs_opt_sound.modelist_listbox.cursor.skin.localpos_r = (barWidth - 12) * 0.5
			ifs_opt_sound.modelist_listbox.cursor.skin.localpos_l = - (barWidth - 12) * 0.5
			ifs_opt_sound.modelist_listbox.hilight.width = barWidth
			ifs_opt_sound.modelist_listbox.hilight.w = barWidth
			ifs_opt_sound.modelist_listbox.hilight.skin.localpos_r = (barWidth - 12) * 0.5
			ifs_opt_sound.modelist_listbox.hilight.skin.localpos_l = - (barWidth - 12) * 0.5
			
			ifs_opt_sound.mixerlist_listbox.cursor.width = barWidth
			ifs_opt_sound.mixerlist_listbox.cursor.w = barWidth
			ifs_opt_sound.mixerlist_listbox.cursor.skin.localpos_r = (barWidth - 12) * 0.5
			ifs_opt_sound.mixerlist_listbox.cursor.skin.localpos_l = - (barWidth - 12) * 0.5
			ifs_opt_sound.mixerlist_listbox.hilight.width = barWidth
			ifs_opt_sound.mixerlist_listbox.hilight.w = barWidth
			ifs_opt_sound.mixerlist_listbox.hilight.skin.localpos_r = (barWidth - 12) * 0.5
			ifs_opt_sound.mixerlist_listbox.hilight.skin.localpos_l = - (barWidth - 12) * 0.5
		end
		
		-- fix online option screen
		if name == "ifs_opt_mp" then
		
			-- some values
			local offset = 120 * (1 - (800 / 600 * screenH / screenW))
			local width = ifs_opt_mp.formcontainer.form.dropdowns.players.listbox.width - 12
			
			-- fixing dropdown
			ifs_opt_mp.formcontainer.form.dropdowns.players.listbox.skin.x = -offset
			ifs_opt_mp.formcontainer.form.dropdowns.players.listbox.cursor.skin.x = -offset
			ifs_opt_mp.formcontainer.form.dropdowns.players.listbox.cursor.skin.localpos_r = width / 2
			ifs_opt_mp.formcontainer.form.dropdowns.players.listbox.cursor.skin.localpos_l = -width / 2
			
			ifs_opt_mp.formcontainer.form.dropdowns.players.listbox.hilight.skin.x = -offset
			ifs_opt_mp.formcontainer.form.dropdowns.players.listbox.hilight.skin.localpos_r = width / 2
			ifs_opt_mp.formcontainer.form.dropdowns.players.listbox.hilight.skin.localpos_l = -width / 2
			
			for i, item in ipairs(ifs_opt_mp.formcontainer.form.dropdowns.players.listbox) do
				item.fHotspotW = ifs_opt_mp.formcontainer.form.dropdowns.players.listbox.width - 12
				item.fHotspotX = - offset + 12
				item.x =item.x - offset
			end
		end
		
		-- change buttons from buttonlist on gc screen
		if name == "ifs_sp_campaign" then
		
			local ifs_rema_gc_lisbox_layout = {
				showcount = ifs_rema_gc_getListboxLineNumber(),
				yHeight = ScriptCB_GetFontHeight("gamefont_large") + 14,
				ySpacing  = 0,
				width = 300,
				x = 0,
				FontStr = "gamefont_large",
				iFontHeight = ScriptCB_GetFontHeight("gamefont_large"),
				slider = 0,
				CreateFn = ifs_rema_gc_lisbox_CreateItem,
				PopulateFn = ifs_rema_gc_lisbox_PopulateItem,
			}
			
			-- add new things to ifs
			ifs_sp_gc_main.datalist = custom_GetGCButtonList()
			ifs_sp_gc_main.funclist = {}
			
			ifs_sp_gc_main.buttonlist = NewButtonWindow {
				ScreenRelativeX = 0,
				ScreenRelativeY = 0.3,
				x = 200,
				y = ifs_rema_gc_lisbox_layout.yHeight * ifs_rema_gc_lisbox_layout.showcount / 2,
				width = ifs_rema_gc_lisbox_layout.width,
				height = ifs_rema_gc_lisbox_layout.yHeight * ifs_rema_gc_lisbox_layout.showcount,
			}
			
			ListManager_fnInitList(ifs_sp_gc_main.buttonlist, ifs_rema_gc_lisbox_layout)
			
			ifs_sp_gc_main.buttonlist.skin = nil
			ifs_sp_gc_main.buttonlist.hilight.skin = nil
			ifs_sp_gc_main.buttonlist.cursor.skin = nil
			ifs_sp_gc_main.buttonlist.sliderbg.x = -210
			ifs_sp_gc_main.buttonlist.sliderfg.x = -210
			
			-- delete old buttons
			ifs_sp_gc_main.buttons = nil
			
			-- hook enter function
			local gcEnter = ifs_sp_gc_main.Enter
			ifs_sp_gc_main.Enter = function(this, bFwd)
				if bFwd then
					ListManager_fnFillContents(ifs_sp_gc_main.buttonlist, ifs_sp_gc_main.datalist, ifs_rema_gc_lisbox_layout)
				end
				return gcEnter(this)
			end
			
			-- hook visible function
			local gcUpdateButton = ifs_sp_gc_fnUpdateButtonVis
			ifs_sp_gc_fnUpdateButtonVis = function(this)
				if this.buttons == nil then
					return
				end
				return gcUpdateButton(this)
			end
			
			-- overwrite input accept function
			ifs_sp_gc_main.Input_Accept = function(this)
				
				-- tab manager
				if(gPlatformStr == "PC") then
					-- If the tab manager handled this event, then we're done
					if( ifelem_tabmanager_HandleInputAccept(this, gPCMainTabsLayout) or
						ifelem_tabmanager_HandleInputAccept(this, gPCSinglePlayerTabsLayout, 1) ) then			
						return
					end
				end
				
				-- default buttons
				local ScreenToPush = nil
				
				if (this.CurButton == "custom") then
					ScreenToPush = ifs_freeform_customsetup
				elseif (this.CurButton == "load") then
					ifs_freeform_load.Mode = "Load"
					ScreenToPush = ifs_freeform_load
				else
					-- always clear the quit player here
					ScriptCB_SetQuitPlayer(1)
					ScreenToPush = ifs_freeform_main
					if (this.CurButton == "1") then
						-- rebel scenario
						ifs_freeform_start_all(ifs_freeform_main)
					elseif (this.CurButton == "2") then
						-- cis scenario
						ifs_freeform_start_cis(ifs_freeform_main)
					elseif (this.CurButton == "3") then
						-- republic scenario
						ifs_freeform_start_rep(ifs_freeform_main)
					elseif (this.CurButton == "4") then
						-- empire scenario
						ifs_freeform_start_imp(ifs_freeform_main)
					else
						-- process rema gc buttons
						if ifs_sp_gc_main.funclist[this.CurButton] then
							ifs_sp_gc_main.funclist[this.CurButton](ifs_freeform_main)
						elseif custom_PressedGCButton(this.CurButton) then

						else
							ScreenToPush = nil
						end
					end
				end

				if(ScreenToPush) then
					ifelm_shellscreen_fnPlaySound(this.acceptSound)
					-- Fix for 4903 - don't prompt to save right before a load.
					if((ScriptCB_IsCurProfileDirty()) and (this.CurButton ~= "load")) then
						this.NextScreenAfterSave = ScreenToPush
						ifs_sp_campaign_StartSaveProfile()
					else
						ifs_movietrans_PushScreen(ScreenToPush)
					end
				end -- have a ScreenToPush

				-- If base class handled this work, then we're done
				if(gShellScreen_fnDefaultInputAccept(this)) then
					return
				end
				
			end
		end
		
		-- let the original function happen
	    return remaGUI_AddIFScreen(ifsTable, name, unpack(arg))
	end
else
	print("Remaster: Error")
	print("        : AddIFScreen() not found!")
end

-- try to wrap NewButtonWindow -----------------------------------
-- fixing size + position of map-, era-, mod- and play-list and mp session infos
-- fixing info-box size
if NewButtonWindow then
	
	-- backup old function
	local remaGUI_NewButtonWindow = NewButtonWindow
	
	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()
	
	-- wrap NewButtonWindow
	NewButtonWindow = function(...)
		local temp = arg[1]

		-- fixing size and position of the map-, era-, mod- and play-list and the mp session infos
		if temp.titleText == "ifs.controls.General.map" or temp.titleText == "ifs.missionselect.selectera" or temp.titleText == "ifs.missionselect.playlist" then
			temp.x = screenW * temp.x/800
			temp.y = screenH * temp.y/600
			temp.width = screenW * temp.width/800
			temp.height = screenH * temp.height/600
		elseif temp.titleText == "ifs.missionselect.selectmode" then
			temp.x = screenW * temp.x/800
			temp.y = screenH * (temp.y + 1)/600
			temp.width = screenW * temp.width/800
			temp.height = screenH * temp.height/600
		end

		-- fixing info-box size
		if remaGUI_onInstantActionScreen == true then
			if temp.alpha then
				temp.x = screenW * temp.x/800
				temp.y = screenH * temp.y/600
				temp.width = screenW * temp.width/800
				temp.height = screenH * temp.height/600
			end
		end

		-- let the original function happen
		return remaGUI_NewButtonWindow(unpack(arg))
	end
else
	print("Remaster: Error")
	print("        : NewButtonWindow() not found!")
end

-- try to wrap ListManager_fnInitList ----------------------------
-- adjust number of elements and width of the map- and play-list content
if ListManager_fnInitList then
	
	-- backup old function
	local remaGUI_ListManager_fnInitList = ListManager_fnInitList
	
	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()
	
	-- wrap ListManager_fnInitList
	ListManager_fnInitList = function(Dest, Layout,...)
		
		
		-- adjust number of elements and width of the map- and play-list content
		if Dest.titleText == "ifs.controls.General.map" or Dest.titleText == "ifs.missionselect.playlist" then
			--uf_print(Layout, true, 0)
			--Dest.font = "gamefont_large"
			Layout.width = Layout.width * screenW/800
			Layout.showcount = math.floor(22 * screenH/600 + 0.5)
		end

		-- let the original function happen
		return remaGUI_ListManager_fnInitList(Dest, Layout, unpack(arg))
	end
else
	print("Remaster: Error")
	print("        : ListManager_fnInitList() not found!")
end

-- try to overwrite custom_AddCheatBox ---------------------------
-- fixing cheatbox (and boarder) position
if custom_AddCheatBox then
	
	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()
	
	-- overwrite custom_AddCheatBox, no need to backup, we don't need the old version
	function custom_AddCheatBox( this )
		-- cheat bits
		local cheatBoxY = 400 * screenH/600
		local cheatBoxX = 30 * screenW/800
		local cheatBoxW = 121 * screenW/800
		local cheatBoxH = 77 * screenH/600
		
		local cheatBorderX = 57 * screenW/800
		local cheatBorderY = 420 * screenH/600
		local cheatBorderW = 160 * screenH/600--screenW/800
		local cheatBorderH = 160 * screenH/600

		this.cheatOutput = NewIFText {
				x = cheatBoxX-28,
				y = cheatBoxY+40,
				halign = "left", valign = "vcenter",
				font = "gamefont_small",
				textw = 120, texth = 90,
				font = "gamefont_tiny",
				nocreatebackground=1,
				string = "",
		}

		this.cheatBox = NewEditbox {
				ScreenRelativeX = 0,
				ScreenRelativeY = 0,
				y = cheatBoxY,
				x = cheatBoxX,

				width = cheatBoxW,
				height = cheatBoxH,
				font = "gamefont_tiny",
				--		string = "Player 1",
				MaxLen = nil,
				MaxChars = 60,
				bKeepsFocus = nil,
				bSilentAndInvisible = 1,
				bClearOnHilightChange = 1,
				noChangeSound = 1,
				bIsTheCheatBox = 1,
		}
		
		--Note: this is more of the flyby movie border than a border for the cheat box
		this.cheatBorder = NewButtonWindow {
			ZPos = 250,
			ScreenRelativeX = 0, -- left side of screen
			ScreenRelativeY = 0, -- top
			x = cheatBorderX,
			y = cheatBorderY,
			width = cheatBorderW,
			height = cheatBorderH,
			--titleText = "ifs.missionselect.playlist",
			font = "gamefont_small"
		}
	end
else 
	print("Remaster: Error")
	print("        : custom_AddCheatBox() not found!")
end

-- try to overwrite custom_SetMovieLocation ----------------------
-- fixing movie position
if custom_SetMovieLocation then
	
	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()
	
	-- overwrite custom_SetMovieLocation, no need to backup, we don't need the old version
	function custom_SetMovieLocation( this )
	    print("custom_SetMovieLocation()")

		local xPosition = 21
		if screenW / screenH == 16 / 9 then
			xPosition = 40
		elseif screenW / screenH == 16 / 10 then
			xPosition = 33
		end

		this.movieW = 150 * screenH/600 + (screenH/600 - 1) * 7.5 --screenW/800
		this.movieH = 150 * screenH/600 + (screenH/600 - 1) * 7.5
		this.movieX = 375 * screenH/600 - (screenH/600 - 1) * 3.75 -- y position
		this.movieY = xPosition * screenW/800  -- x position
	end
else 
	print("Remaster: Error")
	print("        : custom_SetMovieLocation() not found!")
end

-- try to wrap NewIFContainer ------------------------------------
-- Fixing instant action button position
-- fixing the era button x position
-- fixing info-box position
-- fixing game mod position
if NewIFContainer then
	
	-- backup old function
	local remaGUI_NewIFContainer = NewIFContainer
	
	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()
	
	-- wrap NewIFContainer
	NewIFContainer = function(temp,...)
		-- let the original function happen and catch the return value
		local remaGUI_NIFCreturn = {remaGUI_NewIFContainer(temp, unpack(arg))}
		
		-- fixing instant action buttons position
		if remaGUI_NIFCreturn[1].launch_btn then
			remaGUI_NIFCreturn[1].x = remaGUI_NIFCreturn[1].x * screenW/800 + (screenW/800 - 1) * 140
			remaGUI_NIFCreturn[1].y = remaGUI_NIFCreturn[1].y * screenH/600 + (screenH/600 - 1) * 30
			
		--fixing the era button x position
		elseif remaGUI_NIFCreturn[1].Check_Era then
			remaGUI_NIFCreturn[1].x = remaGUI_NIFCreturn[1].x * screenW/800 + (screenW/800 - 1) * 10
			
		-- fixing info-box position
		elseif remaGUI_NIFCreturn[1].InfoListbox then
			remaGUI_NIFCreturn[1].x = remaGUI_NIFCreturn[1].x * screenW/800
			remaGUI_NIFCreturn[1].y = remaGUI_NIFCreturn[1].y * screenH/600		
		
		-- fixing game mod position
		elseif remaGUI_onInstantActionScreen == true and not remaGUI_NIFCreturn[1].checkbox and remaGUI_NIFCreturn[1].ZPos == 180 then
			remaGUI_NIFCreturn[1].x = remaGUI_NIFCreturn[1].x * screenW/800 + (screenW/800 - 1) * 10
			remaGUI_NIFCreturn[1].y = remaGUI_NIFCreturn[1].y * screenH/600	+ (h/600 - 1) * 30
		end
		
		-- return the manipulated values
		return unpack(remaGUI_NIFCreturn)
	end
else
	print("Remaster: Error")
	print("        : NewIFContainer() not found!")
end

-- try to wrap ScriptCB_GetFontHeight ----------------------------------------
-- return font height of the new fonts 
if ScriptCB_GetFontHeight then
	
	-- backup old function
	local remaGUI_GetFontHeight = ScriptCB_GetFontHeight
	
	-- wrap NewIFImage
	ScriptCB_GetFontHeight = function(font,...)
		
		-- change font names
		if font == "gamefont_small" then font = "gamefont_small_rema"
		elseif font == "gamefont_medium" then font = "gamefont_medium_rema"
		elseif font == "gamefont_large" then font = "gamefont_large_rema"
		end
		
		-- let the original function happen
		return remaGUI_GetFontHeight(font, unpack(arg))
	end
else
	print("Remaster: Error")
	print("        : ScriptCB_GetFontHeight() not found!")
end

-- try to wrap NewIFImage ----------------------------------------
-- Fix gamespy logo
if NewIFImage then
	
	-- backup old function
	local remaGUI_NewIFImage = NewIFImage
	
	-- wrap NewIFImage
	NewIFImage = function(temp,...)
		-- let the original function happen and catch the return value
		local remaGUI_NIFIreturn = {remaGUI_NewIFImage(temp, unpack(arg))}
		
		-- fix gamespy logo position
		if remaGUI_NIFIreturn[1].texture == "gamespy_logo_128x32r" or remaGUI_NIFIreturn[1].texture == "gamespy_logo_128x32l" then
			remaGUI_NIFIreturn[1].ScreenRelativeX = 0 --1
			remaGUI_NIFIreturn[1].ScreenRelativeY = 1 --0
			remaGUI_NIFIreturn[1].x = 27 -- -693
			remaGUI_NIFIreturn[1].y = 27 -- 567
		end
		
		-- return the manipulated values
		return unpack(remaGUI_NIFIreturn)
	end
else
	print("Remaster: Error")
	print("        : NewIFImage() not found!")
end

-- try to wrap NewIFText -----------------------------------------
-- replace font names
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
		end--]]
		
		--[[old and outdated version. Now using zoom factor instead of switched fonts
		-- if screen hight greater then 900 adjust the used fonts
		if screenH/600 >= 1.5 then 
			if Template.font then
				if Template.font == "gamefont_tiny" or "gamefont_super_tiny" then Template.font = "gamefont_small"
				elseif Template.font == "gamefont_small" then Template.font = "gamefont_medium"
				elseif Template.font == "gamefont_medium" then Template.font = "gamefont_large"
				end
			end
		end--]]
		
		-- zoom every font by zoomFactor
		--IFText_fnSetScale(Template, zoomFactor, zoomFactor)
		
		-- let the original function happen
		return remaGUI_NewIFText(Template, unpack(arg))
	end
else
	print("Remaster: Error")
	print("        : NewIFText() not found!")
end

-- try to wrap IFText_fnSetString --------------------------------
-- increase text width to fit the zoomed size
-- fix position bug caused by this fix, too
if IFText_fnSetString then
	
	-- backup old function
	local remaGUI_setIFTextString = IFText_fnSetString

	-- wrap IFText_fnSetString
	IFText_fnSetString = function(this, str, case)
		-- increase width to display the zoomed text
		-- this causes a position bug. So fix this, too
		if this.textw and this.HScale then
			this.textw = this.textw * this.HScale
			this.x = this.x - (this.textw * (this.HScale - 1)) / 2
		end
		
		-- let the original function happen
		return remaGUI_setIFTextString(this, str, case)
	end
else
	print("Remaster: Error")
	print("        : IFText_fnSetString() not found!")
end

-- try to wrap NewPCIFButton -------------------------------------
-- Fixing Rest buttons width to display whole string
if NewPCIFButton then
	
	-- backup old function
	local remaGUI_NewPCIFButton = NewPCIFButton
	
	-- wrap NewPCIFButton
	NewPCIFButton = function(Template,...)
		
		-- fix reset button width to display whole text
		if Template.string and Template.string == "common.reset" then
			Template.btnw = Template.btnw * zoomFactor
		end

		-- let the original function happen
		return remaGUI_NewPCIFButton(Template, unpack(arg))
	end
else
	print("Remaster: Error")
	print("        : NewPCIFButton() not found!")
end
