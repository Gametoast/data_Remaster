------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------



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
		font = "gamefont_medium", 
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


------------------------------------------------------------------
-- Tab functions
function ifs_opt_remaster_fnClickTabButtons(this, screen)
	print("Tab was klicked", this.CurButton, screen)
	ifelem_tabmanager_SetSelected(this, remaTabsLayout, this.CurButton, 2)
	
	--IFObj_fnSetVis(this.screens[1].screen, false)
	--IFObj_fnSetVis(this.screens[2].screen, false)
	--IFObj_fnSetVis(remaTabsLayout[3].screen, false)
	
	if this.CurButton == "_tab_1" then
		--IFObj_fnSetVis(this.screens[1].screen, true)
		--IFObj_fnSetVis(this.screens[1].screen.txt, true)
	elseif this.CurButton == "_tab_2" then
		--IFObj_fnSetVis(this.screens[2].screen, true)
		--IFObj_fnSetVis(this.screens[2].screen.txt, true)
		ScriptCB_PushScreen("testscreen")
	elseif this.CurButton == "_tab_3" then
		--testscreen:setVisible()
		if ScriptCB_IsScreenInStack("testscreen") then
			print("testscreen on stack")
		else
			print("testscreen not on stack")
		end
		
		ScriptCB_SetIFScreen("testscreen")
		--ScriptCB_EndIFScreen
		--IFObj_fnSetVis(remaTabsLayout[3].screen, true)
		--IFObj_fnSetVis(remaTabsLayout[3].screen.txt, true)
	end
	print("marker ========")
	print("1")
	--tprint(this.screens[1].screen)
	print("2")
	--tprint(this.screens[2].screen)
	print("3")
	--tprint(remaTabsLayout[3].screen)
	
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
	print("marker 2")
	--[[
	this.screens[1] = {}
	this.screens[2] = {}
	
	this.screens[1].screen = NewIFContainer{
		ScreenRelativeX = 0.5,
		ScreenRelativeY = 0.5,
	}
	
	this.screens[1].screen.txt = NewIFText {
		halign = "left", valign = "top",
		x = 0,
		y = 0,
		font = "gamefont_medium", 
		textw = 300, texth = 100,
		flashy = 0,
		string = "screen 1",
	}
	
	this.screens[2].screen = NewIFContainer{
		ScreenRelativeX = 0.5,
		ScreenRelativeY = 0.9,
	}

	this.screens[2].screen.txt = NewIFText {
		halign = "left", valign = "top",
		x = 0,
		y = 0,
		font = "gamefont_medium", 
		textw = 300, texth = 100,
		flashy = 0,
		string = "screen 2",
	}
	
	remaTabsLayout[3].screen = NewIFContainer{
		ScreenRelativeX = 0.5,
		ScreenRelativeY = 0.1,
	}
	
	remaTabsLayout[3].screen.txt = NewIFText {
		halign = "left", valign = "top",
		bInertPos = true,
		x = 0,
		y = 0,
		font = "gamefont_medium", 
		textw = 300, texth = 100,
		flashy = 0,
		string = "screen 3",
	}
	--]]
end

------------------------------------------------------------------
-- Button events


------------------------------------------------------------------
-- Listbox


------------------------------------------------------------------
-- Theme


------------------------------------------------------------------
-- Layouts

remaTabsLayout = {
	font = "gamefont_medium",
	{ tag = "_tab_1", string = "1st Tab", screen = nil, },
	{ tag = "_tab_2", string = "2nd Tab", screen = nil, },
	{ tag = "_tab_3", string = "3rd Tab", screen = nil, },	
}

------------------------------------------------------------------
-- Build

ifs_opt2_remaster = NewIFShellScreen {
    nologo = 1,
    movieIntro      = nil, -- played before the screen is displayed
    movieBackground = nil, -- played while the screen is displayed
    bNohelptext_backPC = 1,
    bNohelptext_accept = 1,
	--bDimBackdrop = 1,
	bg_texture = "iface_bg_1",

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
			
			this.settings = rema_database
		end
		
        gIFShellScreenTemplate_fnEnter(this, bFwd) -- call default enter function

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
	
	--this.screens = NewIFContainer{
	--	ScreenRelativeX = 0,
	--	ScreenRelativeY = 0,
	--}

	-- default stuff
	AddPCTitleText(this) 
	ifs_opt_remaster_fnChangeTabsLayout(this)
	ifelem_tabmanager_Create(this, gPCMainTabsLayout, gPCOptionsTabsLayout, remaTabsLayout)


	-- Buttons
	local BackButtonW = 150 -- made 130 to fix 6198 on PC - NM 8/18/04
	local BackButtonH = 25

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

ifs_opt_remaster_fnBuildScreen(ifs_opt2_remaster)
ifs_opt_remaster_fnBuildScreen = nil
AddIFScreen(ifs_opt2_remaster,"ifs_opt2_remaster")
ifs_opt_remaster = DoPostDelete(ifs_opt2_remaster)

--AddIFScreen(remaTabsLayout[1].screen, "rema_tab_1")
--AddIFScreen(remaTabsLayout[2].screen, "rema_tab_2")
--AddIFObjContainer(remaTabsLayout[3].screen, "rema_tab_3")