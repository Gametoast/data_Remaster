-- STAR WARS BATTLEFRONT II - REMASTER
-- Developer Documentation by Anakin

-----------------------------------------------------------------------------------------------------------
-- Quicksettings

-- add our custom strings
ReadDataFile("..\\..\\addon\\RTP\\localize.lvl")

-- Remaster will call this function to get the settings parameter
function swbf2Remaster_getCustomQuickSettings()
	
	-- here we define our settings
	local customSettings = {
		{
			-- we need a individual tag. Make sure it's unique, because every tag can only exist once.
			tag = "cusTag1",
			-- Our two options 
			buttonStrings = {
				ScriptCB_ununicode(ScriptCB_getlocalizestr("common.off")),
				ScriptCB_ununicode(ScriptCB_getlocalizestr("common.on")),
			},
			-- The default value.
			default = 1,
		},	
		{
			tag = "cusTag2",
			-- Those two can be anything
			buttonStrings = {"Republic", "Rebels"},
			default = 2,
		},
	}
	
	-- pass our settings to who ever is interessted in it
	return customSettings
end


-----------------------------------------------------------------------------------------------------------
-- Custom Minipage


function rtp_minipage_updateDropdownList(this)

	local dest = this.minipage.mySection.dropdown
	local stringlist = {
		"First String",
		"Another One",
		"it's enought now",
	}
	
	if dest.expanded == true then
		IFObj_fnSetVis(dest.listbox, true)
		ListManager_fnAutoscroll(dest.listbox, stringlist, rtp_minipag_dropdown_layout.lst)
		RoundIFButtonLabel_fnSetString(dest.button, "")
	else
		IFObj_fnSetVis(dest.listbox, false)
		local selectedString = stringlist[rema_database.data.rtpDropIdx]
		RoundIFButtonLabel_fnSetString(dest.button, selectedString)
	end
end

function rtp_minipage_enter(this, bFwd)
	
	-- init default value if nothing is saved
	-- remember this value will be available ingame
	if rema_database.data.rtpDropIdx == nil then
		rema_database.data.rtpDropIdx = 1
	end
	
	-- let's fill our dropdown with data
	rtp_minipage_updateDropdownList(this)
end

function rtp_minipage_exit(this)
	print("I want to say thank you and good bye")
end

function rtp_handle_input(this)
	
	-- Dropdown list element hit
	if gMouseListBox == this.minipage.mySection.dropdown.listbox then
		-- close dropdown
		this.minipage.mySection.dropdown.expanded = false
		
		local newIdx = gMouseListBox.Layout.CursorIdx
		if newIdx and not (newIdx > 3) then
			if newIdx ~= rema_database.data.rtpDropIdx then
				rema_database.data.rtpDropIdx = newIdx
			end
		end
		
		rtp_minipage_updateDropdownList(this)
	end

	-- default handle (listbox scrolls for example)
	if gShellScreen_fnDefaultInputAccept(this, false) then
		return
	end

	if this.CurButton == "_aSimpleTag" then
		print("Do something simple")
	elseif this.CurButton ~= nil and string.find(this.CurButton, "_ifeDropBtn_") == 1 then
		this.minipage.mySection.dropdown.expanded = not this.minipage.mySection.dropdown.expanded
		rtp_minipag_dropdown_layout.lst.SelectedIdx = rema_database.data.rtpDropIdx
		rtp_minipag_dropdown_layout.lst.CursorIdx = rema_database.data.rtpDropIdx
		rtp_minipag_dropdown_layout.lst.FirstShownIdx = rema_database.data.rtpDropIdx
		rtp_minipage_updateDropdownList(this)
	elseif this.minipage.mySection.dropdown.expanded == true then
		this.minipage.mySection.dropdown.expanded = false
		rtp_minipage_updateDropdownList(this)	
	end
end

rtp_minipag_dropdown_layout = {
	tag = "dropMyLife",
	string = "button",
	btnw = 200,
	x = 0,
	y = 0,
	btnFont = "gamefont_medium_rema",
	lstHeight = 150,
	lst = {
		ySpacing = 0,
		font = "gamefont_small_rema",
		halign = "left",
		valign = "vcenter",
		flashy = 0,
		slider = 1,
-- Those are optional and only needed if you want to change something on the
-- list item's layout. Maybe add tick boxes or what ever.
--		cbCreate = ifs_minipage_script_listbox_CreateItem,
--		cbPopulate = ifs_minipage_script_listbox_PopulateItem,
	},
}

function rtp_fnBuildMinipage()
	-- The 3-letter ID, we need this to generate the minipage
	local modID = "RTP"
	
	-- if you need the minipage absolut size for some decisions or calculations 
	local width, height = ifelem_minipage_getSize()
	
	-- this table holds all graphic elements we want to show on the minipage
	local elements = {
		mySection = NewIFContainer{
			title = NewIFText {
				x = 0,
				y = -2 * ScriptCB_GetFontHeight("gamefont_large_rema"),
				halign = "left",
				textw = 200,
				nocreatebackground = 1,
				font = "gamefont_large_rema",
				string = "Hard Coded String",
			},
			-- There is already a add drop down button function in the stock
			-- assets. But since it is very complicate to use i wrote a new
			-- function that is this simple. By default it just displays a list
			-- of strings, but you can adjust this to your wishes. 
			dropdown = ifelem_minipage_NewDropDownButton(rtp_minipag_dropdown_layout),
		},
		aSimpleButton = NewPCIFButton {
			-- button origin is in it's center. Move it to upper left corner this way
			y = ScriptCB_GetFontHeight("gamefont_medium_rema") * 0.5,
			x = -150 * 0.5,
			btnw = 150, 
			btnh = ScriptCB_GetFontHeight("gamefont_medium_rema"),
			font = "gamefont_medium_rema", 
			bg_width = 150, 
			noTransitionFlash = 1,
			tag = "_aSimpleTag",
			string = "rema.ifs.opt.RTP.btnSimple",
		},
	}
	
	-- ScreenRelativeX and ScreenRelativeY work only once in a child/parent tree
	-- since remaster already needs this to position the minipage container, there
	-- is a helper function to set element's relative position on the minipage.
	ifelem_minipage_setRelativePos(elements.aSimpleButton, 0.25, 0.5)
	ifelem_minipage_setRelativePos(elements.mySection, 0.5, 0.1)
	
	-- put all callback functions in this table. Those can be stock shell callbacks
	-- or your own functions you want to add to your screen.
	-- this is optional
	local callbackTable = {
		Enter = rtp_minipage_enter,
		Exit = rtp_minipage_exit,
		Input_Accept = rtp_handle_input,
	}
	
	ifelem_minipage_add(modID, elements, callbackTable)
end

rtp_fnBuildMinipage()