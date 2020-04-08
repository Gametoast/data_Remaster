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
		
		if ScriptCB_IsScreenInStack("ifs_opt2_remaster") then
			print("ifs_opt2_remaster on stack")
		else
			print("ifs_opt2_remaster not on stack")
		end
	end,
	
	Exit = function(this, bFwd)
		print("marker Exit testscreen", bFwd)
	end,
	
	Update = function(this)
		
		if this.timer then
			if this.timer > 50 then
				--ScriptCB_EndIFScreen("testscreen")
				ScriptCB_SetIFScreen("ifs_opt2_remaster")
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

------------------------------------------------------------------
-- utility functions

function ifs_opt_remaster_getRadioListLineNumber()
	local w, h = ScriptCB_GetScreenInfo()
	
	-- 60% of screenheight devided by line height + 0.5 to round off
	return math.floor(h * 0.6 / (ScriptCB_GetFontHeight("gamefont_medium_rema") + 10) + 0.5)
end


------------------------------------------------------------------
-- Tab functions
function ifs_opt_remaster_fnClickTabButtons(this, screen)
	print("Tab was klicked", this.CurButton, screen)
	ifelem_tabmanager_SetSelected(this, remaTabsLayout, this.CurButton, 2)
	
	if this.CurButton == "_tab_1" then
		IFObj_fnSetVis(this.screens.general, true)
	elseif this.CurButton == "_tab_2" then
		IFObj_fnSetVis(this.screens.general, false)
	elseif this.CurButton == "_tab_3" then
		IFObj_fnSetVis(this.screens.general, false)
	end

	--ScriptCB_PushScreen("testscreen")
	--ScriptCB_IsScreenInStack("testscreen")
	--ScriptCB_SetIFScreen("testscreen")
	
end

function ifs_opt_remaster_fnChangeTabsLayout(this)
	local i
	print("marker 1")
	local setting_width = 170
	local setting_x_pos = 100
	local setting_y_pos = 120
	local setting_y_offset = 50
	local setting_y_offset1 = 30
	
	for i = 1, table.getn( remaTabsLayout ) do
		remaTabsLayout[i].callback = ifs_opt_remaster_fnClickTabButtons
		remaTabsLayout[i].width = setting_width
		remaTabsLayout[i].xPos = setting_x_pos
		remaTabsLayout[i].yPos = setting_y_pos
		if( i > 1 ) then
			remaTabsLayout[i].yPos = setting_y_pos + setting_y_offset + (i - 2) * setting_y_offset1
		end
	end
end

------------------------------------------------------------------
-- Button events

function ifs_opt_remaster_callbackToggle(buttongroup, btnNum)
	
	ifs_opt2_remaster.settings.radios[buttongroup.tag] = btnNum
end


------------------------------------------------------------------
-- Listbox

function ifs_opt_remaster_radiolist_CreateItem(layout)

	-- Make a coordinate system pegged to the top-left of where the cursor would go.
	local Temp = NewIFContainer { x = layout.x - 0.5 * layout.width, y=layout.y - 0.5 * layout.height}

	local LineFont = ifs_opt_remaster_radiolist_layout.FontStr
	local FontHeight = ifs_opt_remaster_radiolist_layout.iFontHeight

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
		font = "gamefont_medium_rema",
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
		ifelem_SelectRadioButton(Dest.radiobuttons["1"], ifs_opt2_remaster.settings.radios[Data.tag], true)
		
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


------------------------------------------------------------------
-- Theme


------------------------------------------------------------------
-- Layouts

remaTabsLayout = {
	font = "gamefont_medium_rema",
	{ tag = "_tab_1", string = "1st Tab", screen = nil, },
	{ tag = "_tab_2", string = "2nd Tab", screen = nil, },
	{ tag = "_tab_3", string = "3rd Tab", screen = nil, },	
}

ifs_opt_remaster_radiolist_layout = {
	showcount = ifs_opt_remaster_getRadioListLineNumber(),
	yHeight = ScriptCB_GetFontHeight("gamefont_medium_rema") + 10,
	ySpacing  = 0, --34 - ScriptCB_GetFontHeight("gamefont_medium_rema"),
	width = 425,
	x = 0,
	FontStr = "gamefont_medium_rema",
	iFontHeight = ScriptCB_GetFontHeight("gamefont_medium_rema"),
	slider = 1,
	CreateFn = ifs_opt_remaster_radiolist_CreateItem,
	PopulateFn = ifs_opt_remaster_radiolist_PopulateItem,
}

------------------------------------------------------------------
-- Build

ifs_opt2_remaster = NewIFShellScreen {
    nologo = 1,
    movieIntro      = nil, -- played before the screen is displayed
    movieBackground = nil, -- played while the screen is displayed
    bNohelptext_backPC = 1,
    bNohelptext_accept = 1,
	bg_texture = "iface_bg_1",
	
	screens = {
		ScreenRelativeX = 0.75,
		ScreenRelativeY = 0.2,
		--bCreateHidden = true,
	},

    -- When entering this screen, check if we need to save (triggered
    -- by a subscreen or something). If so, start that process.
    Enter = function(this, bFwd)
		print(">>> Hello there", bFwd)
		
		UpdatePCTitleText(this)
		ifelem_tabmanager_SetSelected(this, gPCMainTabsLayout, "_tab_options")
		ifelem_tabmanager_SetSelected(this, gPCOptionsTabsLayout, "_tab_remaster", 1)
		ifelem_tabmanager_SetSelected(this, remaTabsLayout, "_tab_1", 2)
		
		if bFwd then
			if not rema_database then
				print("Houston, we got a problem!!")
			end
			print("Data is here and this.settings, too")
			this.settings = rema_database
		end
		
        gIFShellScreenTemplate_fnEnter(this, bFwd) -- call default enter function
		
		ifs_opt_remaster_fillRadioList(this)
		
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
	
	if rema_database then
		print("We have data!")
	else
		print("marker no data")
	end
	
	-- default stuff
	AddPCTitleText(this) 
	ifs_opt_remaster_fnChangeTabsLayout(this)
	ifelem_tabmanager_Create(this, gPCMainTabsLayout, gPCOptionsTabsLayout, remaTabsLayout)

	-- General Screen rema.settings
	this.screens.general = NewIFContainer{
		list = NewButtonWindow {
			x = 0,
			y = ifs_opt_remaster_radiolist_layout.yHeight * ifs_opt_remaster_radiolist_layout.showcount / 2,
			width = ifs_opt_remaster_radiolist_layout.width,
			height = ifs_opt_remaster_radiolist_layout.yHeight * ifs_opt_remaster_radiolist_layout.showcount,
		}
	}
	
	ListManager_fnInitList(this.screens.general.list, ifs_opt_remaster_radiolist_layout)
	
	this.screens.general.list.skin = nil
	this.screens.general.list.hilight.skin = nil
	this.screens.general.list.cursor.skin = nil
	
	
	-- Script Screen rema.scriptManager
	this.screens.scripts = NewIFContainer{
		
	}

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

ifs_opt_remaster_fnBuildScreen(ifs_opt2_remaster)
ifs_opt_remaster_fnBuildScreen = nil
AddIFScreen(ifs_opt2_remaster,"ifs_opt2_remaster")
ifs_opt_remaster = DoPostDelete(ifs_opt2_remaster)

--AddIFScreen(remaTabsLayout[1].screen, "rema_tab_1")
--AddIFScreen(remaTabsLayout[2].screen, "rema_tab_2")
--AddIFObjContainer(remaTabsLayout[3].screen, "rema_tab_3")