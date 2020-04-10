------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

ifelem_minipage_tables = { { tabID = "_tab_1", screen = "ifs_opt_remaster", }, }

------------------------------------------------------------------
-- ifelem_minipage_getSize()
-- returns the absolute size of the minipage
--
--	parameter: none
--
--	return: width, heigh
--
function ifelem_minipage_getSize()
	return gSafeW * 0.75, gSafeH * 0.8
end

------------------------------------------------------------------
-- ifelem_minipage_setRelativePos(dest, relX, relY)
-- sets position values relative to minipage size
--
--	parameter:	dest - object to position
--				relX - relative x-coordinate, float[0..1]
--				relY - relative y-coordinate, float[0..1]
--
--	return: none
--
function ifelem_minipage_setRelativePos(dest, relX, relY)
	
	local width, heigh = ifelem_minipage_getSize()
	local oldX = dest.x or 0
	local oldY = dest.y or 0
	
	dest.x = width * relX + oldX
	dest.y = heigh * relY + oldY
end

------------------------------------------------------------------
-- ifelem_minipage_add(modID, elements, fnEnter, fnExit, fnInputAccept, fnUpdate)
-- creates a new minipage from given elements
--
--	parameter:	modID			- mod's 3-letter ID, string
--				elements		- table with graphic elements, NewIFContainer
--				fnEnter			- callback for enter event, function
--				fnExit			- callback for exit event, function
--				fnInputAccept	- callback for Input_Accept event, function
--				fnUpdate		- callback for Update event, function
--
function ifelem_minipage_add(modID, elements, fnEnter, fnExit, fnInputAccept, fnUpdate)
	
	local screen = NewIFShellScreen {
		nologo = 1,
		movieIntro      = nil, -- played before the screen is displayed
		movieBackground = nil, -- played while the screen is displayed
		bNohelptext_backPC = 1,
		bNohelptext_accept = 1,
		bg_texture = "iface_bg_1",
		minipage = elements,
		modID = modID,
		
		Enter = function(this, bFwd)
			ifs_opt_remaster_Enter(this, bFwd)
			
			if fnEnter then
				fnEnter(this, bFwd)
			end
		end,
		
		Exit = function(this)
			ifs_opt_remaster_Exit(this)
			
			if fnExit then
				fnExit(this)
			end
		end,

		Input_Accept = function(this)
			ifs_opt_remaster_Input_Accept(this)
			
			if fnInputAccept then
				fnInputAccept(this)
			end
		end,
		
		Update = function(this, fDt)
			ifs_opt_remaster_Update(this, fDt)
			
			if fnUpdate then
				fnUpdate(this, fDt)
			end
		end
	}
	
	-- header and tabs
	AddPCTitleText(screen)
	ifelem_tabmanager_Create(screen, gPCMainTabsLayout, gPCOptionsTabsLayout, remaTabsLayout)
	
	-- set minipage position
	screen.minipage.ScreenRelativeX = 0.25
	screen.minipage.ScreenRelativeY = 0.1
	
	-- bottom buttons
	local BackButtonW = 150 -- made 130 to fix 6198 on PC - NM 8/18/04
	local BackButtonH = 25
	
	screen.resetbutton = NewPCIFButton {
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
	
	screen.donebutton = NewPCIFButton {
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
	
	-- set unique tabID
	local idx = table.getn(ifelem_minipage_tables) + 1
	screen.tabIdx = "_tab_" .. tostring(idx)
	ifelem_minipage_tables[idx] = { tabID = screen.tabIdx, screen = "minipage_" .. modID, }
	
	-- build the screen
	AddIFScreen(screen, "minipage_" .. modID)
	screen = DoPostDelete(screen)
	_G["minipage_" .. modID] = screen
end
