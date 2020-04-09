------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

ScriptCB_DoFile("ifelem_minipage")


testscreen = NewIFShellScreen{
	bg_texture = nil,
	movieIntro      = nil,
	movieBackground = nil,
    music           = "shell_soundtrack",
    bNohelptext_backPC = 1,
	
	Enter = function(this, bFwd)
		print("marker Enter testscreen", bFwd)
		
		this.timer = 0
		
		if ScriptCB_IsScreenInStack("ifs_opt_remaster") then
			print("ifs_opt_remaster on stack")
		else
			print("ifs_opt_remaster not on stack")
		end
	end,
	
	Exit = function(this, bFwd)
		print("marker Exit testscreen", bFwd)
	end,
	
	Update = function(this)
		
		if this.timer then
			if this.timer > 50 then
				--ScriptCB_EndIFScreen("testscreen")
				ScriptCB_SetIFScreen("ifs_opt_remaster")
				--ScriptCB_PopScreen()
			else
				this.timer = this.timer + 1
			end
		else
			this.timer = 0
		end
		
	end,
	
	setVisible = function(this)
	
		IFObj_fnSetVis(this, true)
		IFObj_fnSetVis(this.screens, true)
		IFObj_fnSetVis(this.screens.txt, true)
	end,
}

function build_testscreen(this)

	this.screens = NewIFContainer{
		ScreenRelativeX = 0.5,
		ScreenRelativeY = 0.5,
	}
	
	this.screens.txt = NewIFText {
		halign = "left", valign = "top",
		x = 0,
		y = 0,
		font = "gamefont_medium_rema", 
		textw = 300, texth = 100,
		flashy = 0,
		string = "Testscreen",
	}
	
end

build_testscreen(testscreen)
build_testscreen = nil
AddIFScreen(testscreen,"testscreen")
ifs_opt_remaster = DoPostDelete(testscreen)


function dummyAddTabData()

	print("marker size screens", table.getn(ifs_opt_remaster.screens))
	ifs_opt_remaster.screens[1] = { modID = "ABC", screen = "testscreen"}
	ifs_opt_remaster.screens[2] = { modID = "XYZ", screen = "testscreen"}
end


------------------------------------------------------------------
-- utility functions

function ifs_opt_remaster_getLineCount(layout)
	local w, h = ifelem_minipage_getSize()
	
	-- 90% of screenheight devided by elemet height + 0.5 to round off
	return math.floor(h * 0.9 / (layout.yHeight) + 0.5)
end

function ifs_opt_remaster_getListboxLineNumber()
	local w, h = ScriptCB_GetScreenInfo()
	
	-- 60% of screenheight devided by line height and 3 (there are 3 boxes) + 0.5 to round off
	return math.floor(h * 0.6 / (3 * 35) + 0.5)
end


------------------------------------------------------------------
-- Tab functions
function ifs_opt_remaster_fnClickTabButtons(this, screen)
	print("Tab was klicked", this.CurButton, screen)
	ifelem_tabmanager_SetSelected(this, remaTabsLayout, this.CurButton, 2)
	
	if this.CurButton == "_tab_1" then
		this.curMinipage = "general"
	elseif this.CurButton == "_tab_2" then
		this.curMinipage = "scripts"
	elseif this.CurButton == "_tab_3" then
		this.curMinipage = "tab_screen"
	end
	
	ifelem_minipage_update(this)
	
	--ScriptCB_PushScreen("testscreen")
	--ScriptCB_IsScreenInStack("testscreen")
	--ScriptCB_SetIFScreen("testscreen")
end

function ifs_opt_remaster_fnSetupTabsLayout()
	
	remaTabsLayout.yHeight = 25
	remaTabsLayout.font = "gamefont_medium_rema"
	
	local max_tabs = ifs_opt_remaster_getLineCount(remaTabsLayout) - 1
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
	
	remaTabsLayout[1].string = "rema.settings"
	remaTabsLayout[2].string = "rema.scriptManager"
	
	-- TODO: fill tabs with data and hide ununsed
	dummyAddTabData()
	
	--[[for i = 1, table.getn( remaTabsLayout ) do
		remaTabsLayout[i].callback = ifs_opt_remaster_fnClickTabButtons
		remaTabsLayout[i].width = setting_width
		remaTabsLayout[i].xPos = setting_x_pos
		remaTabsLayout[i].yPos = setting_y_pos
		if( i > 1 ) then
			remaTabsLayout[i].yPos = setting_y_pos + setting_y_offset + (i - 2) * setting_y_offset1
		end
	end--]]
end

------------------------------------------------------------------
-- Button events

function ifs_opt_remaster_callbackToggle(buttongroup, btnNum)
	
	ifs_opt_remaster.settings.radios[buttongroup.tag] = btnNum
end


------------------------------------------------------------------
-- Listbox

function ifs_opt_remaster_radiolist_CreateItem(layout)

	-- Make a coordinate system pegged to the top-left of where the cursor would go.
	local Temp = NewIFContainer { x = layout.x - 0.5 * layout.width, y=layout.y - 0.5 * layout.height}

	local LineFont = ifs_opt_remaster_radiolist_layout.FontStr
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
		y = layout.height / 2,
	}
	
	ifelem_AddRadioButtonGroup(Temp, 0, 0, ifs_opt_remaster_radio_layout, radioTag)
	
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
	
	local dest = this.screens.general.list
	ListManager_fnFillContents(dest, rema_database.regSet.radios, ifs_opt_remaster_radiolist_layout)
end


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
	local dest = this.screens.scripts
	
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


------------------------------------------------------------------
-- Theme


------------------------------------------------------------------
-- Layouts

remaTabsLayout = {	
}

ifs_opt_remaster_radiolist_layout = {
	x = 0,
	ySpacing  = 0,
	width = ifelem_minipage_getSize(), -- 1st return value is width, 2nd not used
	FontStr = "gamefont_medium_rema",
	yHeight = ScriptCB_GetFontHeight("gamefont_medium_rema") + 10,
	slider = 1,
	CreateFn = ifs_opt_remaster_radiolist_CreateItem,
	PopulateFn = ifs_opt_remaster_radiolist_PopulateItem,
}

ifs_opt_remaster_listbox_layout = {
	showcount = ifs_opt_remaster_getListboxLineNumber(),
	yHeight = ScriptCB_GetFontHeight("gamefont_small_rema"),
	ySpacing  = 34 - ScriptCB_GetFontHeight("gamefont_small_rema"),
	width = 80,
	x = 0,
	FontStr = "gamefont_small_rema",
	iFontHeight = ScriptCB_GetFontHeight("gamefont_small_rema"),
	slider = 1,
	CreateFn = ifs_opt_remaster_listbox_CreateItem,
	PopulateFn = ifs_opt_remaster_listbox_PopulateItem,
}


------------------------------------------------------------------
-- Build

function ifs_opt_remaster_fnBuildTestScreen(this)

	this.screens.test = NewIFContainer{
		txt = NewIFText {
			string = "Teststring",
			font = "gamefont_medium_rema",
			valign = "top",
			halign = "left",
			ScreenRelativeX = 0.5,
			ScreenRelativeY = 0.5,
			textw = 200,
			texth = 30,
			x = 0,
			y = 0,
			bgleft = "",
			bgmid = "",
			bgright = "",
		},
	}
	
	ifelem_minipage_setRelativePos(this.screens.test.txt, 0.5, 0.5)
end

function ifs_opt_remaster_fnBuildGeneralScreen(this)
	
	ifs_opt_remaster_radiolist_layout.showcount = ifs_opt_remaster_getLineCount(ifs_opt_remaster_radiolist_layout)
	
	this.screens.general = NewIFContainer{
		list = NewButtonWindow {
			x = 0,
			y = ifs_opt_remaster_radiolist_layout.yHeight * ifs_opt_remaster_radiolist_layout.showcount / 2,
			width = ifs_opt_remaster_radiolist_layout.width,
			height = ifs_opt_remaster_radiolist_layout.yHeight * ifs_opt_remaster_radiolist_layout.showcount,
		},
	}
	
	ifelem_minipage_setRelativePos(this.screens.general, 0.5, 0.1)
	
	ListManager_fnInitList(this.screens.general.list, ifs_opt_remaster_radiolist_layout)
	
	this.screens.general.list.skin = nil
	this.screens.general.list.hilight.skin = nil
	this.screens.general.list.cursor.skin = nil
end

function ifs_opt_remaster_fnBuildScriptsScreen(this)

	local y_spacing = 35
	
	this.screens.scripts = NewIFContainer {
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
	}
	
	-- settings scripts
	dest = this.screens.scripts.opScripts
	dest.title = NewIFText {
		string = "rema.Labels.setScript",
		font = "gamefont_medium_rema",
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
	dest = this.screens.scripts.ifScripts
	dest.title = NewIFText {
		string = "rema.Labels.infScript",
		font = "gamefont_medium_rema",
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
	dest = this.screens.scripts.igScripts
	dest.title = NewIFText {
		string = "rema.Labels.gmScript",
		font = "gamefont_medium_rema",
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
end

ifs_opt_remaster = NewIFShellScreen {
    nologo = 1,
    movieIntro      = nil, -- played before the screen is displayed
    movieBackground = nil, -- played while the screen is displayed
    bNohelptext_backPC = 1,
    bNohelptext_accept = 1,
	bg_texture = "iface_bg_1",
	curMinipage = nil,
	
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
	
	screens = {
		ScreenRelativeX = 0.25,
		ScreenRelativeY = 0.1,
	},

    -- When entering this screen, check if we need to save (triggered
    -- by a subscreen or something). If so, start that process.
    Enter = function(this, bFwd)
		print(">>> Hello there", bFwd)

		UpdatePCTitleText(this)
		ifelem_tabmanager_SetSelected(this, gPCMainTabsLayout, "_tab_options")
		ifelem_tabmanager_SetSelected(this, gPCOptionsTabsLayout, "_tab_remaster", 1)
		ifelem_tabmanager_SetSelected(this, remaTabsLayout, "_tab_1", 2)
		
		if not this.curMinipage then
			this.curMinipage = "general"
		end

		if bFwd then
			if not rema_database then
				print("Houston, we got a problem!!")
			end
			print("Data is here and this.settings, too")
			this.settings = rema_database
		end
		
        gIFShellScreenTemplate_fnEnter(this, bFwd) -- call default enter function
		
		ifs_opt_remaster_fillRadioList(this)
		ifs_opt_remaster_fillScriptLists(this)

		ifelem_minipage_update(this)
		
    end, -- function Enter()
    
    Exit = function(this)
        print(">>> Bye Bye")
    end,

    Input_Accept = function(this)

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
			ifelem_tabmanager_HandleInputAccept(this, remaTabsLayout, 2, 1)

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

    end,
	
	Update = function(this, fDt)
        gIFShellScreenTemplate_fnUpdate(this, fDt)

	end

}

function ifs_opt_remaster_fnBuildScreen(this)
	local w
    local h
    w,h = ScriptCB_GetSafeScreenInfo()
	
	-- Debuglog
	IFText_fnSetUString(this.debuglog, ScriptCB_tounicode(tostring(gScrnW) .. "x" .. tostring(gScrnH) .. "\n" .. tostring(gSafeW) .. "x" .. tostring(gSafeH)))
	
	-- default stuff
	AddPCTitleText(this) 
	ifs_opt_remaster_fnSetupTabsLayout()
	ifelem_tabmanager_Create(this, gPCMainTabsLayout, gPCOptionsTabsLayout, remaTabsLayout)

	-- Testscreen
	ifs_opt_remaster_fnBuildTestScreen(this)

	-- General Screen rema.settings
	ifs_opt_remaster_fnBuildGeneralScreen(this)
	
	-- Script Screen rema.scriptManager
	ifs_opt_remaster_fnBuildScriptsScreen(this)	

	-- Buttons
	local BackButtonW = 150 -- made 130 to fix 6198 on PC - NM 8/18/04
	local BackButtonH = 25

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

ifs_opt_remaster_fnBuildScreen(ifs_opt_remaster)
ifs_opt_remaster_fnBuildScreen = nil
AddIFScreen(ifs_opt_remaster,"ifs_opt_remaster")
ifs_opt_remaster = DoPostDelete(ifs_opt_remaster)
