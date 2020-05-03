------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

ifelem_minipage_tables = { { tabID = "_tab_1", screen = "ifs_opt_remaster", }, }

------------------------------------------------------------------
-- ifelem_minipage_getLineCount(elementHeight, boxHeight)
-- calculactes the number of elements that fit on the screen
--
--	parameter:	elementHeight	- height of one list element, int
--				boxHeight		- height of the list area, int
--
--	return:		lineCount		- number of elements fiting in the area, int
--
function ifelem_minipage_getLineCount(elementHeight, boxHeight)
	return math.floor(boxHeight / elementHeight + 0.5)
end

------------------------------------------------------------------
-- ifelem_minipage_getSize()
-- returns the absolute size of the minipage
--
--	parameter:	none
--
--	return:		width, height
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
--	return:		none
--
function ifelem_minipage_setRelativePos(dest, relX, relY)
	
	local width, height = ifelem_minipage_getSize()
	local oldX = dest.x or 0
	local oldY = dest.y or 0
	
	dest.x = width * relX + oldX
	dest.y = height * relY + oldY
end


------------------------------------------------------------------
-- Helper functions
function dropdown_lst_CreateItem(layout)
	-- Make a coordinate system pegged to the top-left of where the cursor would go.
	local Temp = NewIFContainer { x = layout.x - 0.5 * layout.width, y = layout.y - 0.5 * layout.height}
	Temp.cbPopulate = layout.listboxlayout.cbPopulate
	
	Temp.NameStr = NewIFText { 
		x = 7,
		y = 3,
		textw = layout.width - 14,
		texth = layout.listboxlayout.yHeight,
		valign = layout.listboxlayout.valign or "vcenter",
		halign = layout.listboxlayout.halign,
		font = layout.listboxlayout.font,
		nocreatebackground=1,
		startdelay = math.random() * 0.5,
		string = "XXX",
	}
	
	-- callback if it exists
	if layout.listboxlayout.cbCreate then
		layout.listboxlayout.cbCreate(layout, Temp)
	end
	
	return Temp
end

function dropdown_lst_PopulateItem(Dest, Data, bSelected, iColorR, iColorG, iColorB, fAlpha)
	
	-- maybe custom data, or nil
	if type(Data) == "string" then
		IFObj_fnSetVis(Dest, true)
		
		-- maybe a custom layout and the string does not exist
		if Dest.NameStr then
			IFText_fnSetString(Dest.NameStr,Data)
			IFObj_fnSetColor(Dest.NameStr, iColorR, iColorG, iColorB)
			IFObj_fnSetAlpha(Dest.NameStr, fAlpha)
		end
	else
		IFObj_fnSetVis(Dest, false)
	end
	
	-- callback if it exists
	if Dest.cbPopulate then
		Dest.cbPopulate(Dest, Data, bSelected, iColorR, iColorG, iColorB, fAlpha)
	end
end

--	layout = {
--		tag = string				- Dropdown tag
--		string = string				- Button Displayname
--		btnw = int					- Button width
--		x = int						- Position X
--		y = int						- Position Y
--		btnFont = string			- Button Font
--		lstHeight = int				- height of droplist
--		lst = {						- list layout
--			ySpacing = int			- spacing between the rows
--			font = string			- Dropdownlist Font
--			halign = string			- align of list item text
--			falshy = int			- falshy or not
--			slider = int			- scrollable or not
--			cbCreate = function		- callback function on create a list item
--			cbPopulate = function	- callback function on populate the list items
--		}
--	}
function ifelem_minipage_NewDropDownButton(layout)
	
	-- calculacte some additional values for the layout
	layout.btnh = ScriptCB_GetFontHeight(layout.btnFont)
	layout.lst.width = layout.btnw - gListboxSliderWidth * 0.5 - 14	-- border
	layout.lst.yHeight = ScriptCB_GetFontHeight(layout.lst.font)
	layout.lst.showcount = ifelem_minipage_getLineCount(layout.lst.yHeight + layout.lst.ySpacing, layout.lstHeight - 14)
	layout.lst.CreateFn = dropdown_lst_CreateItem
	layout.lst.PopulateFn = dropdown_lst_PopulateItem
	layout.lst.x = 0
	
	local container = NewIFContainer{
		x = layout.x + layout.btnw * 0.5,
		y = layout.y + layout.btnh * 0.5,
		expanded = false,
		tag = "_dropdown_" .. layout.tag,
		button = NewPCDropDownButton {
			x = 12,							-- always 12, no idea why
			btnw = layout.btnw,
			btnh = layout.btnh,
			font = layout.btnFont,
			string = layout.string,
			tag = "_ifeDropBtn_" .. layout.tag,
		},
		listbox = NewButtonWindow {
			x = layout.btnh * 0.5,			-- button is wider 
			y = (layout.lstHeight + layout.btnh) * 0.5,
			width = layout.btnw,
			height = layout.lstHeight,
			font = layout.lst.font,
			halign = layout.lst.halign,
			tag = "list_" .. layout.tag,
			bg_texture = "border_dropdown",
			buttonGutter = 50,
		},
	}
	
	ListManager_fnInitList(container.listbox, layout.lst)
	
	local i, v 
	for i, v in ipairs(container.listbox) do
		v.fHotspotY = 0
	end
	
	return container
end

------------------------------------------------------------------
-- ifelem_minipage_add(modID, elements, callbackTable)
-- creates a new minipage from given elements
--
--	parameter:	modID			- mod's 3-letter ID, string
--				elements		- table with graphic elements, NewIFContainer
--				callbackTable	- table with name and function that should be added, table
--
--	return:		none
--
function ifelem_minipage_add(modID, elements, callbackTable)
	
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
			
			if callbackTable.Enter then
				callbackTable.Enter(this, bFwd)
			end
		end,
		
		Exit = function(this)
			ifs_opt_remaster_Exit(this)
			
			if callbackTable.Exit then
				callbackTable.Exit(this)
			end
		end,

		Input_Accept = function(this)
			ifs_opt_remaster_Input_Accept(this)
			
			if callbackTable.Input_Accept then
				callbackTable.Input_Accept(this)
			end
		end,
		
		Update = function(this, fDt)
			ifs_opt_remaster_Update(this, fDt)
			
			if callbackTable.Update then
				callbackTable.Update(this, fDt)
			end
		end
	}
	
	-- add additional callbacks
	for name, func in pairs(callbackTable) do
		-- already handled those function names
		if name ~= "Enter" and name ~= "Exit" and name ~= "Input_Accept" and name ~= "Update" then
			screen[name] = func
		end
	end
	
	-- header and tabs
	AddPCTitleText(screen)
	ifelem_tabmanager_Create(screen, gPCMainTabsLayout, gPCOptionsTabsLayout, remaTabsLayout)
	
	-- set minipage position
	screen.minipage.ScreenRelativeX = 0.25
	screen.minipage.ScreenRelativeY = 0.1
	
	-- bottom buttons
	local BackButtonW = 150 -- made 130 to fix 6198 on PC - NM 8/18/04
	local BackButtonH = ScriptCB_GetFontHeight("gamefont_medium_rema")
	
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
	screen.resetbutton.label.textw = 1.5 * screen.resetbutton.label.textw
	screen.resetbutton.label.x = -screen.resetbutton.label.textw * 0.5
	
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

