------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

------------------------------------------------------------------
-- utility functions

function ifs_opt_remaster_getListboxLineNumber()
	local w, h = ScriptCB_GetScreenInfo()
	
	-- 60% of screenheight devided by line height and 3 (there are 3 boxes) + 0.5 to round off
	return math.floor(h * 0.6 / (3 * 35) + 0.5)
end

function ifs_opt_remaster_getRadioListLineNumber()
	local w, h = ScriptCB_GetScreenInfo()
	
	-- 60% of screenheight devided by line height + 0.5 to round off
	return math.floor(h * 0.6 / (ScriptCB_GetFontHeight("gamefont_medium") + 10) + 0.5)
end

function ifs_opt_remaster_showLoading(this, bool)

	IFObj_fnSetVis(this.group_scriptManager,not bool)
	IFObj_fnSetVis(this.group_radios,not bool)
	IFObj_fnSetVis(this._Tabs, not bool)
	IFObj_fnSetVis(this._Tabs1, not bool)
	IFObj_fnSetVis(this.PCTitleText_Profile, not bool)
	IFObj_fnSetVis(this.PCTitleText_Title, not bool)
	IFObj_fnSetVis(this.group_loadscreen, bool)
	
	if bool == true then
		this:Disable_Saving()
	else
		this:Enable_Saving()
	end

end

function ifs_opt_remaster_loadingScripts(this)

	swbf2Remaster_loadScripts()
	
	ifs_opt_remaster_showLoading(this, false)
	
	ifs_opt_remaster_fillScriptLists(this)
	ifs_opt_remaster_ok_Pressed(this)
end

------------------------------------------------------------------
-- Button events

function ifs_opt_remaster_loadScripts_Pressed(this)
	
	ifs_opt_remaster_showLoading(this, true)
	
	this.delayedFunc = ifs_opt_remaster_loadingScripts
	this.delayTimer = 1
end

function ifs_opt_remaster_ok_Pressed(this)

	-- forget instant options if they shouldn't be saved
	if this.settings.radios.saveSpOptions == false then
		this.settings.instOp = { }
	end

	-- save global
	rema_database = this.settings
	
	-- save to the disk
	this.Disable_Saving()
	swbf2Remaster_settingsManager("save", this.Enable_Saving)
end

function ifs_opt_remaster_reset_Pressed(this)
	
	-- restore default settings
	this.settings = swbf2Remaster_getDefaultSettings()
	
	-- save global
	rema_database = this.settings
	
	-- save to the disk
	this.Disable_Saving()
	swbf2Remaster_settingsManager("save", this.Enable_Saving)
end

function ifs_opt_remaster_callbackToggle(buttongroup, btnNum)
	
	ifs_opt_remaster.settings.radios[buttongroup.tag] = btnNum
end

------------------------------------------------------------------
-- Listbox

function ifs_opt_remaster_listbox_CreateItem(layout)
	-- Make a coordinate system pegged to the top-left of where the cursor would go.
	local Temp = NewIFContainer { x = layout.x - 0.5 * layout.width, y=layout.y - 0.5 * layout.height}

	local LineFont = ifs_opt_remaster_listbox_layout.FontStr
	local FontHeight = ifs_opt_remaster_listbox_layout.iFontHeight

	local XLeft = 10

	Temp.NameStr = NewIFText { 
		x = XLeft, y = 0, 
		halign = "left", textw = layout.width - 20,
		valign = "vcenter", texth = FontHeight,
		font = LineFont,
		nocreatebackground=1, startdelay=math.random()*0.5,
		string = "XXX",
	}
	
	return Temp
end

function ifs_opt_remaster_listbox_PopulateItem(Dest, Data, bSelected, iColorR, iColorG, iColorB, fAlpha)
	if(Data) then

		IFObj_fnSetVis(Dest.NameStr, 1)

		IFText_fnSetFont(Dest.NameStr, ifs_opt_remaster_listbox_layout.FontStr)

		IFText_fnSetUString(Dest.NameStr,Data)
		
		IFObj_fnSetColor(Dest.NameStr, iColorR, iColorG, iColorB)
		IFObj_fnSetAlpha(Dest.NameStr, fAlpha)

	else
		-- Blank this entry
		IFText_fnSetString(Dest.NameStr,"")
	end

end

function ifs_opt_remaster_fillScriptLists(this)

	-- some help variables
	local dest = this.group_scriptManager
	
	local opStrings = {}
	local ifStrings = {}
	local igStrings = {}
	
	for i = 1, table.getn(rema_database.scripts_OP) do
		opStrings[i] = ScriptCB_tounicode(rema_database.scripts_OP[i])
	end
	
	for i = 1, table.getn(rema_database.scripts_IF) do
		ifStrings[i] = ScriptCB_tounicode(rema_database.scripts_IF[i])
	end
	
	for i = 1, table.getn(rema_database.scripts_IG) do
		igStrings[i] = ScriptCB_tounicode(rema_database.scripts_IG[i])
	end
	
	ListManager_fnFillContents(dest.opScripts.list, opStrings, ifs_opt_remaster_listbox_layout)
	ListManager_fnFillContents(dest.ifScripts.list, ifStrings, ifs_opt_remaster_listbox_layout)
	ListManager_fnFillContents(dest.igScripts.list, igStrings, ifs_opt_remaster_listbox_layout)
	
end

function ifs_opt_remaster_radiolist_CreateItem(layout)

	-- Make a coordinate system pegged to the top-left of where the cursor would go.
	local Temp = NewIFContainer { x = layout.x - 0.5 * layout.width, y=layout.y - 0.5 * layout.height}

	local LineFont = ifs_opt_remaster_listbox_layout.FontStr
	local FontHeight = ifs_opt_remaster_listbox_layout.iFontHeight

	local XLeft = 10

	Temp.NameStr = NewIFText { 
		x = XLeft, y = 0, 
		halign = "left", textw = layout.width - 20,
		valign = "vcenter", texth = FontHeight,
		font = LineFont,
		nocreatebackground=1, startdelay=math.random()*0.5,
		string = "XXX",
	}
	
	local radioX = 0
	local radioY = 0
	local radioTag = "1"
	local ifs_opt_remaster_radio_layout = {
		spacing = 75,
		font = "gamefont_medium",
		strings = {"placeholderNo", "placeholderYes"}, --
		x = 0,
		callback = ifs_opt_remaster_callbackToggle
	}
	
	Temp.radiobuttons = NewIFContainer {
		x = 250,
		y = 10,
	}
	
	ifelem_AddRadioButtonGroup(Temp, radioX, radioY, ifs_opt_remaster_radio_layout, radioTag)
	
	return Temp
end

function ifs_opt_remaster_radiolist_PopulateItem(Dest, Data, bSelected, iColorR, iColorG, iColorB, fAlpha)
	if(Data) then

		-- set visible
		IFObj_fnSetVis(Dest, 1)

		-- set strings
		IFText_fnSetUString(Dest.NameStr,ScriptCB_tounicode(Data.title))
		IFText_fnSetUString(Dest.radiobuttons["1"][1].radiotext, ScriptCB_tounicode(Data.buttonStrings[1]))
		IFText_fnSetUString(Dest.radiobuttons["1"][2].radiotext, ScriptCB_tounicode(Data.buttonStrings[2]))
		
		-- select correct value
		ifelem_SelectRadioButton(Dest.radiobuttons["1"], ifs_opt_remaster.settings.radios[Data.tag], true)
		
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
	
	local dest = this.group_radios.list
	ListManager_fnFillContents(dest, rema_database.regSet.radios, ifs_opt_remaster_radiolist_layout)
end

------------------------------------------------------------------
-- Theme

function ifs_opt_remaster_updatelThemeList(this)
	local dest = this.group_scriptManager.theme
	
	local themeStrings = {}
	
	for i = 1, table.getn(rema_database.scripts_GT) do
		local temp = ScriptCB_getlocalizestr("rema.modName." .. rema_database.scripts_GT[i].modID)
		if temp == ScriptCB_tounicode("[NULL]") then
			temp = ScriptCB_tounicode(rema_database.scripts_GT[i].modID)
		end
		
		themeStrings[i] = temp
	end
	
	if dest.dropdown.expanded == true then
		IFObj_fnSetVis(dest.dropdown.listbox, true)
		ListManager_fnFillContents(dest.dropdown.listbox, themeStrings, ifs_opt_remaster_dropdown_layout)
		RoundIFButtonLabel_fnSetString(dest.dropdown.button, "")
		IFObj_fnSetVis(this.group_scriptManager.opScripts.list, false)
	else
		IFObj_fnSetVis(dest.dropdown.listbox, false)
		local temp = ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.modName." .. rema_database.scripts_GT[rema_database.themeIdx].modID))
		if temp == "[NULL]" then
			temp = rema_database.scripts_GT[rema_database.themeIdx].modID
		end
		RoundIFButtonLabel_fnSetString(dest.dropdown.button, temp)
		IFObj_fnSetVis(this.group_scriptManager.opScripts.list, true)
	end
	

end

function ifs_opt_remaster_processThemeChange(this, newIdx)
	
	-- close the dropbox when done
	this.group_scriptManager.theme.dropdown.expanded = false
	
	-- only if something changed we need to do something
	--print(newIdx, )
	if newIdx and not (newIdx > table.getn(rema_database.scripts_GT)) then
		if newIdx ~= rema_database.themeIdx then
			print("indexes:", newIdx, rema_database.themeIdx)
			rema_database.themeIdx = newIdx
			swbf2Remaster_loadTheme()
		end
	end
	
	ifs_opt_remaster_updatelThemeList(this)
end

------------------------------------------------------------------
-- Layouts

ifs_opt_remaster_listbox_layout = {
	showcount = ifs_opt_remaster_getListboxLineNumber(),
	yHeight = ScriptCB_GetFontHeight("gamefont_small"),
	ySpacing  = 34 - ScriptCB_GetFontHeight("gamefont_small"),
	width = 80,
	x = 0,
	FontStr = "gamefont_small",
	iFontHeight = ScriptCB_GetFontHeight("gamefont_small"),
	slider = 1,
	CreateFn = ifs_opt_remaster_listbox_CreateItem,
	PopulateFn = ifs_opt_remaster_listbox_PopulateItem,
}

ifs_opt_remaster_radiolist_layout = {
	showcount = ifs_opt_remaster_getRadioListLineNumber(),
	yHeight = ScriptCB_GetFontHeight("gamefont_medium") + 10,
	ySpacing  = 0, --34 - ScriptCB_GetFontHeight("gamefont_medium"),
	width = 425,
	x = 0,
	FontStr = "gamefont_medium",
	iFontHeight = ScriptCB_GetFontHeight("gamefont_medium"),
	slider = 1,
	CreateFn = ifs_opt_remaster_radiolist_CreateItem,
	PopulateFn = ifs_opt_remaster_radiolist_PopulateItem,
}

ifs_opt_remaster_dropdown_layout = {
	showcount = 10,
	yHeight = ScriptCB_GetFontHeight("gamefont_small"),
	ySpacing = 0,
	width = 130,
	flashy = 0,
	CreateFn = ifs_opt_remaster_listbox_CreateItem,
	PopulateFn = ifs_opt_remaster_listbox_PopulateItem,
	font = "gamefont_small",
	halign = "left",
	slider = 1,
}

------------------------------------------------------------------
-- Build

ifs_opt_remaster = NewIFShellScreen {
    nologo = 1,
    movieIntro      = nil, -- played before the screen is displayed
    movieBackground = nil, -- played while the screen is displayed
    bNohelptext_backPC = 1,
    bNohelptext_accept = 1,
	--bDimBackdrop = 1,
	bg_texture = "iface_bg_1",
	settings = nil,
	delayedFunc = nil,
	delayTimer = 0,
	
	group_loadscreen = NewIFContainer {
		ScreenRelativeX = 0,
		ScreenRelativeY = 0,
	},
	
	group_scriptManager = NewIFContainer {
		ScreenRelativeX = 0.25,
		ScreenRelativeY = 0.2,
		Title = NewIFText {
			string = "Script Manager",
			font = "gamefont_large",
			textw = 250,
			texth = 30,
			y = -50,
			bgleft = "",
			bgmid = "",
			bgright = "",
		},
		theme = NewIFContainer {
			y = -12,
		},
		opScripts = NewIFContainer {
			y = 35 + 0 * 35 * ifs_opt_remaster_listbox_layout.showcount - 12,
		},
		ifScripts = NewIFContainer {
			y = 35 + 1 * 35 * ifs_opt_remaster_listbox_layout.showcount - 12,
		},
		igScripts = NewIFContainer {
			y = 35 + 2 * 35 * ifs_opt_remaster_listbox_layout.showcount - 12,
		},
	},
	
	group_radios = NewIFContainer {
		ScreenRelativeX = 0.75,
		ScreenRelativeY = 0.2,
		Title = NewIFText {
			string = "rema.settings",
			font = "gamefont_large",
			textw = 250,
			texth = 30,
			y = -50,
			bgleft = "",
			bgmid = "",
			bgright = "",
		},
		buttonlabels = NewIFContainer {
		},
		--radiobuttons = NewIFContainer {
		--},
	},
	
    -- When entering this screen, check if we need to save (triggered
    -- by a subscreen or something). If so, start that process.
    Enter = function(this, bFwd)

		UpdatePCTitleText(this)
		ifelem_tabmanager_SetSelected(this, gPCMainTabsLayout, "_tab_options")
		ifelem_tabmanager_SetSelected(this, gPCOptionsTabsLayout, "_tab_remaster", 1)
		
		if bFwd then
			if not rema_database then
				print("Houston, we got a problem!!")
			end
			
			this.settings = rema_database
		end
		
        gIFShellScreenTemplate_fnEnter(this, bFwd) -- call default enter function
		
		-- script manager
		ifs_opt_remaster_fillScriptLists(this)
		ifs_opt_remaster_updatelThemeList(this)
		ifs_opt_remaster_fillRadioList(this)
		
		
		
		--[[local layout = {
			yTop = 0,
			yHeight = 35,
			ySpacing = 0,
			width = 300,
			sliderheight = 24,
			font = "gamefont_medium",
			RightJustify = 1,
			bRightJustifyText = 1,
			bRightJustifyButton = 1,
			buttonlist = {{ tag = "test", title = "Test", string = "", noCreateHotspot = true }},
			flashy = 0,
		}
		
		local layout2 = {
			spacing = 75,
			font = "gamefont_medium",
			strings = {"common.no", "common.yes"}, --
			x = 25,
			y = 35 * (7 - 1),
			callback = ifs_opt_remaster_callbackToggle
		}
		
		ifelem_AddRadioButtonGroup(this.group_radios, layout2.x, layout2.y, layout2, test)
		
		AddVerticalText(this.group_radios.buttonlabels,layout)--]]

    end, -- function Enter()
    
    Exit = function(this)
        
    end,
	
	Disable_Saving = function(this)
		IFObj_fnSetVis(ifs_opt_remaster.donebutton, false)
		IFObj_fnSetVis(ifs_opt_remaster.resetbutton, false)
		IFObj_fnSetVis(ifs_opt_remaster.loadScriptsButton, false)
	end,
	
	Enable_Saving = function(this)
		IFObj_fnSetVis(ifs_opt_remaster.donebutton, true)
		IFObj_fnSetVis(ifs_opt_remaster.resetbutton, true)
		IFObj_fnSetVis(ifs_opt_remaster.loadScriptsButton, true)
	end,

    Input_Accept = function(this)
		
		if gMouseListBox == this.group_scriptManager.theme.dropdown.listbox then
			ifs_opt_remaster_processThemeChange(this, gMouseListBox.Layout.CursorIdx)
		end
		
		-- Check radio buttons
		for i = 1, table.getn(this.group_radios.list) do
			if ( ifelem_HandleRadioButtonInputAccept(this.group_radios.list[i]) ) then
				return
			end
		end
		
		-- if default handles this, we are done
		if(gShellScreen_fnDefaultInputAccept(this)) then
			return
		end
		
		-- If the tab manager handled this event, then we're done
		if(gPlatformStr == "PC") then
			-- Check tabs to see if we have a hit
			this.NextScreen = ifelem_tabmanager_HandleInputAccept(this, gPCOptionsTabsLayout, 1, 1)
			if(not this.NextScreen) then
				this.NextScreen = ifelem_tabmanager_HandleInputAccept(this, gPCMainTabsLayout, nil, 1)
			end

			-- If nextscreen was handled via a callback, we're done
			if(this.NextScreen == -1) then
				this.NextScreen = nil
				return
			end

			if(this.NextScreen) then
				-- if something changed, save, and return
				ScriptCB_SetIFScreen(this.NextScreen)
				this.NextScreen = nil
				return
			end -- this.Nextscreen is valid (i.e. clicked on a tab)
		end -- cur platform == PC
		
		if this.CurButton == "_ok" then
			ifs_opt_remaster_ok_Pressed(this)
			ifelm_shellscreen_fnPlaySound(this.acceptSound)
		elseif this.CurButton == "_reset" then
			ifs_opt_remaster_reset_Pressed(this)
			ifelm_shellscreen_fnPlaySound(this.acceptSound)
		elseif this.CurButton == "_loadScripts" then
			ifs_opt_remaster_loadScripts_Pressed(this)
			ifelm_shellscreen_fnPlaySound(this.acceptSound)
		elseif this.CurButton == "button_theme" then
			this.group_scriptManager.theme.dropdown.expanded = not this.group_scriptManager.theme.dropdown.expanded
			ifs_opt_remaster_dropdown_layout.SelectedIdx = rema_database.themeIdx
			ifs_opt_remaster_dropdown_layout.CursorIdx = rema_database.themeIdx
			ifs_opt_remaster_dropdown_layout.FirstShownIdx = rema_database.themeIdx
			ifs_opt_remaster_updatelThemeList(this)
		elseif this.group_scriptManager.theme.dropdown.expanded == true then
			this.group_scriptManager.theme.dropdown.expanded = false
			ifs_opt_remaster_updatelThemeList(this)	
		end
		
		
    end,

    Input_GeneralLeft = function(this)

    end,

    Input_Back = function(this)
		if (gPlatformStr == "PC") and ScriptCB_GetShellActive() then
			-- rethink interface state, but don't leave
			this:Exit(false)
			this:Enter(true)
		else
			ScriptCB_PopScreen()
		end
    end,

    Input_GeneralRight = function(this)
       
    end,

    Input_GeneralUp = function(this)
        if(gShellScreen_fnDefaultInputUp(this)) then
            return
        end
    end,

    Input_GeneralDown = function(this)
        if(gShellScreen_fnDefaultInputDown(this)) then
            return
        end
    end,
	
	Update = function(this, fDt)
        gIFShellScreenTemplate_fnUpdate(this, fDt)
		
		if this.delayedFunc then
			if this.delayTimer > 0 then
				this.delayTimer = this.delayTimer - 1
			else
				this.delayedFunc(this)
				this.delayedFunc = nil
			end
		end
	end

}

function ifs_opt_remaster_fnBuildScreen(this)
	local w
    local h
    w,h = ScriptCB_GetSafeScreenInfo()

	-- default stuff
	AddPCTitleText(this) 
	ifelem_tabmanager_Create(this, gPCMainTabsLayout, gPCOptionsTabsLayout)
	
	-- custom radio settings
	local y_spacing = 35
	local dest = this.group_radios
	
	dest.list = NewButtonWindow {
		x = 0,
		y = ifs_opt_remaster_radiolist_layout.yHeight * ifs_opt_remaster_radiolist_layout.showcount / 2,
		width = ifs_opt_remaster_radiolist_layout.width,
		height = ifs_opt_remaster_radiolist_layout.yHeight * ifs_opt_remaster_radiolist_layout.showcount,
	}
	
	ListManager_fnInitList(dest.list, ifs_opt_remaster_radiolist_layout)
	
	dest.list.skin = nil
	dest.list.hilight.skin = nil
	dest.list.cursor.skin = nil
	
	
	-- loadscreen
	dest = this.group_loadscreen
	local realWidth, realHeight = ScriptCB_GetScreenInfo()
	dest.Image = NewIFImage {
		texture = "swbf2Remaster_loading",
		x = -0.5 * (realWidth - w),
		y = -0.5 * (realHeight - h),
		localpos_l = 0,
		localpos_r = realWidth,
		localpos_t = 0,
		localpos_b = realHeight,
		ZPos = 100,
	}
	
	dest.Text = NewIFText {
		string = "rema.loadingMsg",
		font = "gamefont_medium",
		halign = "hcenter",
		valign = "vcenter",
		textw = realWidth,
		texth = realHeight,
		x = -0.5 * (realWidth - w),
		y = -0.5 * (realHeight - h),
		ZPos = 50,
		bgleft = "",
		bgmid = "",
		bgright = "",
	}
	IFObj_fnSetVis(dest, false)
	
	-- Settings Manager
	
	-- Theme
	dest = this.group_scriptManager.theme
	local dropListHeight = ifs_opt_remaster_dropdown_layout.showcount * (ifs_opt_remaster_dropdown_layout.yHeight + ifs_opt_remaster_dropdown_layout.ySpacing)
	local dropListWidth = ifs_opt_remaster_dropdown_layout.width + 10
	dest.title = NewIFText {
		string = "Theme:",
		font = "gamefont_medium",
		halign = "right",
		textw = 100,
		texth = 30,
		x = -100,
		y = 0,
		bgleft = "",
		bgmid = "",
		bgright = "",
	}
	
	dest.dropdown = NewIFContainer {
		x = dropListWidth/2 + 20,
		y = 35 * 3/8,
		expanded = false,
		tag = "dropdown_theme"
	}
	
	dest.dropdown.button = NewPCDropDownButton {
		x = 0,
		y = 0,
		btnw = 150,
		btnh = 35,
		font = "gamefont_medium",
		halign = "center",
		string = "",
		tag = "button_theme",
	}
	
	dest.dropdown.listbox = NewButtonWindow {
		x = -5,
		y = 20 + 0.5 * dropListHeight,
		width = 20 + dropListWidth,
		height = 20 + dropListHeight,
		font = ifs_opt_remaster_dropdown_layout.font,
		halign = ifs_opt_remaster_dropdown_layout.halign,
		tag = "list_theme",
		bg_texture = "border_dropdown",
	}
	
	ListManager_fnInitList(dest.dropdown.listbox, ifs_opt_remaster_dropdown_layout)
	
	IFObj_fnSetVis(dest.dropdown.listbox, false)

	-- settings scripts
	dest = this.group_scriptManager.opScripts
	dest.title = NewIFText {
		string = "rema.Labels.setScript",
		font = "gamefont_medium",
		halign = "right",
		textw = 200,
		texth = 30,
		x = - 200,
		y = 0,
		bgleft = "",
		bgmid = "",
		bgright = "",
	}
	
	dest.list = NewButtonWindow {
		x = 70,
		y = y_spacing * ifs_opt_remaster_listbox_layout.showcount / 2,
		width = 100,
		height = y_spacing * ifs_opt_remaster_listbox_layout.showcount,
		font = "gamefont_small",
	}
	dest.list.skin = nil
	
	ListManager_fnInitList(dest.list, ifs_opt_remaster_listbox_layout)
	
	dest.list.hilight.skin = nil
	dest.list.cursor.skin = nil

	-- interface scripts
	dest = this.group_scriptManager.ifScripts
	dest.title = NewIFText {
		string = "rema.Labels.infScript",
		font = "gamefont_medium",
		halign = "right",
		textw = 200,
		texth = 30,
		x = - 200,
		y = 0,
		bgleft = "",
		bgmid = "",
		bgright = "",
	}
	
	dest.list = NewButtonWindow {
		x = 70,
		y = y_spacing * ifs_opt_remaster_listbox_layout.showcount / 2,
		width = 100,
		height = y_spacing * ifs_opt_remaster_listbox_layout.showcount,
		font = "gamefont_small",
	}
	dest.list.skin = nil
	
	ListManager_fnInitList(dest.list, ifs_opt_remaster_listbox_layout)
	
	dest.list.hilight.skin = nil
	dest.list.cursor.skin = nil
	
	-- game scripts
	dest = this.group_scriptManager.igScripts
	dest.title = NewIFText {
		string = "rema.Labels.gmScript",
		font = "gamefont_medium",
		halign = "right",
		textw = 200,
		texth = 30,
		x = - 200,
		y = 0,
		bgleft = "",
		bgmid = "",
		bgright = "",
	}
	
	dest.list = NewButtonWindow {
		x = 70,
		y = y_spacing * ifs_opt_remaster_listbox_layout.showcount / 2,
		width = 100,
		height = y_spacing * ifs_opt_remaster_listbox_layout.showcount,
		font = "gamefont_small",
	}
	dest.list.skin = nil
	
	ListManager_fnInitList(dest.list, ifs_opt_remaster_listbox_layout)
	
	dest.list.hilight.skin = nil
	dest.list.cursor.skin = nil
	
	-- Buttons
	local BackButtonW = 150 -- made 130 to fix 6198 on PC - NM 8/18/04
	local BackButtonH = 25
	
	this.loadScriptsButton = NewPCIFButton {
		ScreenRelativeX = 0.0, -- left
		ScreenRelativeY = 1.0, -- bottom
		y = -15, -- just above bottom
		x = BackButtonW * 0.5,
		btnw = BackButtonW, 
		btnh = BackButtonH,
		font = "gamefont_medium", 
		bg_width = BackButtonW, 
		noTransitionFlash = 1,
		tag = "_loadScripts",
		string = "rema.btnLoad",
	}
	
	this.resetbutton = NewPCIFButton {
		ScreenRelativeX = 0.5, -- center
		ScreenRelativeY = 1.0, -- bottom
		y = -15, -- just above bottom						
		btnw = BackButtonW * 1.5,
		btnh = BackButtonH,
		font = "gamefont_medium",
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
		font = "gamefont_medium", 
		bg_width = BackButtonW, 
		noTransitionFlash = 1,
		tag = "_ok",
		string = "common.accept",
	}
	
end

ifs_opt_remaster_fnBuildScreen(ifs_opt_remaster)
ifs_opt_remaster_fnBuildScreen = nil
AddIFScreen(ifs_opt_remaster,"ifs_opt_remaster")
ifs_opt_remaster = DoPostDelete(ifs_opt_remaster)
