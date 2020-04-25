------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

-- TODO:
-- in ifs_opt_remaster_Input_Accept how does nextscreen work can we use this for save?

ScriptCB_DoFile("ifelem_minipage")
ScriptCB_DoFile("ifs_minipage_script")

------------------------------------------------------------------
-- shared with ifs_minipage_script and ifelem_minipage 

-- utility functions

function ifs_opt_remaster_updateTabNames(this)
	local i
	local NUM_TABS = table.getn(remaTabsLayout)
	
	for i=1, NUM_TABS do
		local curTag = remaTabsLayout[i].tag
		local j
		local values
		-- set invisible
		IFObj_fnSetVis(this._Tabs2[curTag], false)
		
		for j, values in ipairs(ifelem_minipage_tables) do
			if curTag == values.tabID then
				-- found tab, set name and visible
				local tempName = ScriptCB_getlocalizestr("rema.modName." .. _G[values.screen].modID)
				if tempName == ScriptCB_tounicode("[NULL]") then
					tempName = ScriptCB_tounicode(_G[values.screen].modID)
				end
				IFText_fnSetUString(this._Tabs2[curTag].label, tempName)
				IFObj_fnSetVis(this._Tabs2[curTag], true)
			end
		end
	end
end


-- button press functions

function ifs_opt_remaster_fnClickTabButtons(this, screen)
	local i, values
	for i, values in ipairs(ifelem_minipage_tables) do
		if this.CurButton == values.tabID then
			ScriptCB_SetIFScreen(values.screen)
			break
		end
	end
end

function ifs_opt_remaster_ok_Pressed(this)

	-- forget instant options if they shouldn't be saved
	if this.settings.data.saveSpOptions == false then
		this.settings.instOp = { }
	end

	-- save global
	rema_database = this.settings
	
	-- save to the disk
	--this.Disable_Saving()
	swbf2Remaster_settingsManager("save", function(...) end)--, this.Enable_Saving)
end

function ifs_opt_remaster_reset_Pressed(this)

	-- restore default settings
	this.settings = swbf2Remaster_getDefaultSettings()

	-- save global
	rema_database = this.settings

	-- save to the disk
	--this.Disable_Saving()
	swbf2Remaster_settingsManager("save", function(...) end)--, this.Enable_Saving)
end


-- screen event functions

function ifs_opt_remaster_Enter(this, bFwd)

	UpdatePCTitleText(this)
	ifelem_tabmanager_SetSelected(this, gPCMainTabsLayout, "_tab_options")
	ifelem_tabmanager_SetSelected(this, gPCOptionsTabsLayout, "_tab_remaster", 1)
	ifelem_tabmanager_SetSelected(this, remaTabsLayout, this.tabIdx, 2)
	
	ifs_opt_remaster_updateTabNames(this)

	if bFwd then
		if not rema_database then
			print("Houston, we got a problem!!")
		end

		this.settings = rema_database
	end
	
	gIFShellScreenTemplate_fnEnter(this, bFwd) -- call default enter function
end

function ifs_opt_remaster_Exit(this)
end

function ifs_opt_remaster_Input_Accept(this)
	-- if default handles this, we are done
	if gShellScreen_fnDefaultInputAccept(this, true) then
		return
	end

	-- If the tab manager handled this event, then we're done
	if(gPlatformStr == "PC") then
		-- Check tabs to see if we have a hit
		this.NextScreen = ifelem_tabmanager_HandleInputAccept(this, gPCOptionsTabsLayout, 1, 1)
		if(not this.NextScreen) then
			this.NextScreen = ifelem_tabmanager_HandleInputAccept(this, gPCMainTabsLayout, nil, 1)
		end
		ifelem_tabmanager_HandleInputAccept(this, remaTabsLayout, 2, 1)

		-- If nextscreen was handled via a callback, we're done
		if(this.NextScreen == -1) then
			this.NextScreen = nil
			return
		end
		
		-- TODO: Where is this handled??
		if(this.NextScreen) then
			-- if something changed, save, and return
			ScriptCB_SetIFScreen(this.NextScreen)
			this.NextScreen = nil
			return
		end -- this.Nextscreen is valid (i.e. clicked on a tab)
	end -- cur platform == PC

	-- bottom buttons
	if this.CurButton == "_ok" then
		ifs_opt_remaster_ok_Pressed(this)
		ifelm_shellscreen_fnPlaySound(this.acceptSound)
	elseif this.CurButton == "_reset" then
		ifs_opt_remaster_reset_Pressed(this)
		ifelm_shellscreen_fnPlaySound(this.acceptSound)
	end
end

function ifs_opt_remaster_Update(this, fDt)
	gIFShellScreenTemplate_fnUpdate(this, fDt)
end


-- Layouts

remaTabsLayout = {	
}


------------------------------------------------------------------
-- ifs_opt_remaster

-- button press functions

function ifs_opt_remaster_callbackToggle(buttongroup, btnNum)
	ifs_opt_remaster.settings.data[buttongroup.tag] = btnNum
end


-- Listbox

function ifs_opt_remaster_radiolist_CreateItem(layout)

	-- Make a coordinate system pegged to the top-left of where the cursor would go.
	local Temp = NewIFContainer { x = layout.x - 0.5 * layout.width, y=layout.y - 0.5 * layout.height}

	local LineFont = layout.listboxlayout.font
	local xSpacing = 0.1
	
	-- Text right aligned - spacing 0.1 rel - radiobuttons 200 abs - spacing 0.1 rel
	local offsetX = layout.width * (xSpacing + xSpacing) + 200
	
	Temp.NameStr = NewIFText { 
		x = 0, y = 0, 
		halign = "right", textw = layout.width - offsetX,
		valign = "vcenter", texth = layout.height,
		font = LineFont,
		nocreatebackground=1, startdelay=math.random()*0.5,
		string = "XXX",
	}

	local radioTag = "1"
	
	local ifs_opt_remaster_radio_layout = {
		spacing = 100 - 19,
		font = "gamefont_medium_rema",
		strings = {"placeholderNo", "placeholderYes"}, --
		x = 0,
		callback = ifs_opt_remaster_callbackToggle
	}
	
	offsetX = Temp.NameStr.textw + layout.width * xSpacing
	
	Temp.radiobuttons = NewIFContainer {
		x = offsetX,
		y = layout.height * 0.5,
	}
	
	ifelem_AddRadioButtonGroup(Temp, 0, 0, ifs_opt_remaster_radio_layout, radioTag)
	
	return Temp
end

function ifs_opt_remaster_radiolist_PopulateItem(Dest, Data, bSelected, iColorR, iColorG, iColorB, fAlpha)
	if(Data) then

		-- set visible
		IFObj_fnSetVis(Dest, 1)

		-- set strings
		IFText_fnSetUString(Dest.NameStr,ScriptCB_getlocalizestr("rema.ifs.opt.REMA1." .. Data.tag))
		IFText_fnSetUString(Dest.radiobuttons["1"][1].radiotext, ScriptCB_tounicode(Data.buttonStrings[1]))
		IFText_fnSetUString(Dest.radiobuttons["1"][2].radiotext, ScriptCB_tounicode(Data.buttonStrings[2]))
		
		-- select correct value
		ifelem_SelectRadioButton(Dest.radiobuttons["1"], ifs_opt_remaster.settings.data[Data.tag], true)
		
		-- need this to identify the button group.numChildren
		Dest.radiobuttons["1"].tag = Data.tag

	else
		-- clear strings
		IFText_fnSetString(Dest.NameStr,"")
		IFText_fnSetUString(Dest.radiobuttons["1"][1].radiotext, "")
		IFText_fnSetUString(Dest.radiobuttons["1"][2].radiotext, "")
		
		-- clear the tag if disabled
		Dest.radiobuttons["1"].tag = nil
		
		-- set invisible
		IFObj_fnSetVis(Dest, nil)
	end

end

function ifs_opt_remaster_fillRadioList(this)
	local dest = this.minipage.list
	ListManager_fnFillContents(dest, rema_database.qs, ifs_opt_remaster_radiolist_layout)
end


-- Layouts

ifs_opt_remaster_radiolist_layout = {
	x = 0,
	ySpacing  = 0,
	width = ifelem_minipage_getSize(), -- 1st return value is width, 2nd not used
	font = "gamefont_medium_rema",
	yHeight = ScriptCB_GetFontHeight("gamefont_medium_rema") + 10,
	slider = 1,
	CreateFn = ifs_opt_remaster_radiolist_CreateItem,
	PopulateFn = ifs_opt_remaster_radiolist_PopulateItem,
}


-- Build

function ifs_opt_remaster_fnBuildTabsLayout()
	
	remaTabsLayout.yHeight = 25
	remaTabsLayout.font = "gamefont_medium_rema"
	
	local w, h = ifelem_minipage_getSize()
	local max_tabs = ifelem_minipage_getLineCount(remaTabsLayout.yHeight, h * 0.9) - 1
	local i
	local j = 1
	local setting_width = 170
	local setting_x_pos = 100
	local setting_y_pos = 120
	local setting_y_offset = remaTabsLayout.yHeight

	-- init all tabs
	for i = 1, max_tabs do
		if i > 2 then
			j = 0
		end
		
		remaTabsLayout[i] = {	tag = "_tab_" .. tostring(i),
								string = "Tab",
								screen = nil,
								callback = ifs_opt_remaster_fnClickTabButtons,
								width = setting_width,
								xPos = setting_x_pos,
								yPos = setting_y_pos + (i - j) * setting_y_offset
							}
	end
end

ifs_opt_remaster = NewIFShellScreen {
    nologo = 1,
    movieIntro      = nil, -- played before the screen is displayed
    movieBackground = nil, -- played while the screen is displayed
    bNohelptext_backPC = 1,
    bNohelptext_accept = 1,
	bg_texture = "iface_bg_1",
	tabIdx = "_tab_1",
	modID = "REMA1",
	
	debuglog = NewIFText{
		string = "Debuglog",
		textcolorr = 255,
		textcolorg = 0,
		textcolorb = 0,
		font = "gamefont_medium_rema",
		valign = "top",
		halign = "left",
		ScreenRelativeX = 0,
		ScreenRelativeY = 0,
		textw = 400,
		texth = 200,
		x = 0,
		y = 0,
		ZPos = 5,
		bgleft = "",
		bgmid = "",
		bgright = "",
	},
	
	minipage = NewIFContainer {
		ScreenRelativeX = 0.25,
		ScreenRelativeY = 0.1,
	},

    Enter = function(this, bFwd)
		ifs_opt_remaster_Enter(this, bFwd)
		ifs_opt_remaster_fillRadioList(this)
    end,
    
    Exit = function(this)
        ifs_opt_remaster_Exit(this)
    end,

    Input_Accept = function(this)

		ifs_opt_remaster_Input_Accept(this)
		
		-- Check radio buttons
		for i = 1, table.getn(this.minipage.list) do
			if ( ifelem_HandleRadioButtonInputAccept(this.minipage.list[i]) ) then
				return
			end
		end

		-- check default again but with listboxes this time
		if gShellScreen_fnDefaultInputAccept(this, false) then
			return
		end
    end,
	
	Update = function(this, fDt)
        ifs_opt_remaster_Update(this, fDt)
	end
}

function ifs_opt_remaster_fnBuildScreen(this)

	-- Debuglog
	IFText_fnSetUString(this.debuglog, ScriptCB_tounicode(tostring(gScrnW) .. "x" .. tostring(gScrnH) .. "\n" .. tostring(gSafeW) .. "x" .. tostring(gSafeH)))
	IFObj_fnSetVis(this.debuglog, false)

	-- header and tabs
	AddPCTitleText(this) 
	ifelem_tabmanager_Create(this, gPCMainTabsLayout, gPCOptionsTabsLayout, remaTabsLayout)


	-- some variables need to be set up
	local BackButtonW = 150 -- made 130 to fix 6198 on PC - NM 8/18/04
	local BackButtonH = ScriptCB_GetFontHeight("gamefont_medium_rema")
	local w, h = ifelem_minipage_getSize()
	ifs_opt_remaster_radiolist_layout.showcount = ifelem_minipage_getLineCount(ifs_opt_remaster_radiolist_layout.yHeight, h * 0.9)


	-- radio buttons
	this.minipage.list = NewButtonWindow {
		x = 0,
		y = ifs_opt_remaster_radiolist_layout.yHeight * ifs_opt_remaster_radiolist_layout.showcount / 2,
		width = ifs_opt_remaster_radiolist_layout.width,
		height = ifs_opt_remaster_radiolist_layout.yHeight * ifs_opt_remaster_radiolist_layout.showcount,
	}

	ifelem_minipage_setRelativePos(this.minipage.list, 0.5, 0.1)
	
	ListManager_fnInitList(this.minipage.list, ifs_opt_remaster_radiolist_layout)
	
	-- don't show the cursor or background
	this.minipage.list.skin = nil
	this.minipage.list.hilight.skin = nil
	this.minipage.list.cursor.skin = nil


	-- bottom buttons
	this.resetbutton = NewPCIFButton {
		ScreenRelativeX = 0.5, -- center
		ScreenRelativeY = 1.0, -- bottom
		y = -15, -- just above bottom						
		btnw = BackButtonW * 1.5,
		btnh = BackButtonH,
		font = "gamefont_medium_rema",
		noTransitionFlash = 1,
		tag = "_reset",
		string = "common.reset",
	}
	
	this.donebutton = NewPCIFButton {
		ScreenRelativeX = 1.0, -- right
		ScreenRelativeY = 1.0, -- bottom
		y = -15, -- just above bottom
		x = -BackButtonW * 0.5,
		btnw = BackButtonW, 
		btnh = BackButtonH,
		font = "gamefont_medium_rema", 
		bg_width = BackButtonW, 
		noTransitionFlash = 1,
		tag = "_ok",
		string = "common.accept",
	}

end

ifs_opt_remaster_fnBuildTabsLayout()
ifs_opt_remaster_fnBuildScreen(ifs_opt_remaster)
ifs_opt_remaster_fnBuildScreen = nil
AddIFScreen(ifs_opt_remaster,"ifs_opt_remaster")
ifs_opt_remaster = DoPostDelete(ifs_opt_remaster)
ifs_opt_remaster_fnBuildScriptScreen()
