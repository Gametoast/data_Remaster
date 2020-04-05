------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

------------------------------------------------------------------
-- utility functions


------------------------------------------------------------------
-- Tab functions
function ifs_opt_remaster_fnClickTabButtons(this)
	print("Tab was klicked", this.CurButton)
	ifelem_tabmanager_SetSelected(this, remaTabsLayout, this.CurButton, 2)
end

function ifs_opt_remaster_fnChangeTabsLayout(this)
	local i
	
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


------------------------------------------------------------------
-- Listbox


------------------------------------------------------------------
-- Theme


------------------------------------------------------------------
-- Layouts

remaTabsLayout = {
	font = "gamefont_medium",
	{tag = "_tab_1", string = "1st Tab",},
	{tag = "_tab_2", string = "2nd Tab",},
	{tag = "_tab_3", string = "3rd Tab",},
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
			print("We have data!")
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
