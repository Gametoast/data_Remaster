------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------


-- utility functions

function ifs_minipage_script_showLoading(this, bool)

	IFObj_fnSetVis(this.minipage.loadscreen, bool)
	IFObj_fnSetVis(this.minipage.scripts,not bool)
	IFObj_fnSetVis(this.minipage.theme,not bool)
	IFObj_fnSetVis(this.minipage.loadScriptsButton,not bool)
	IFObj_fnSetVis(this.donebutton,not bool)
	IFObj_fnSetVis(this.resetbutton,not bool)
	IFObj_fnSetVis(this._Tabs, not bool)
	IFObj_fnSetVis(this._Tabs1, not bool)
	IFObj_fnSetVis(this._Tabs2, not bool)
	IFObj_fnSetVis(this.PCTitleText_Profile, not bool)
	IFObj_fnSetVis(this.PCTitleText_Title, not bool)
end

function ifs_minipage_script_loadingScripts(this)

	swbf2Remaster_loadScripts()
	
	ifs_minipage_script_showLoading(this, false)
	
	ifs_minipage_script_fillScriptLists(this)
	--ifs_opt_remaster_ok_Pressed(this)
end

function ifs_minipage_script_loadScripts_Pressed(this)
	ifs_minipage_script_showLoading(this, true)
	
	this.delayedFunc = ifs_minipage_script_loadingScripts
	this.delayTimer = 1
end

function ifs_minipage_script_processThemeChange(this, newIdx)
	
	-- close the dropbox when done
	this.minipage.theme.dropdown.expanded = false
	
	-- only if something changed we need to do something
	if newIdx and not (newIdx > table.getn(rema_database.scripts_GT)) then
		if newIdx ~= rema_database.themeIdx then
			rema_database.themeIdx = newIdx
			swbf2Remaster_loadTheme()
		end
	end
	
	ifs_minipage_script_updateThemeList(this)
end


-- Listbox

function ifs_minipage_script_listbox_CreateItem(layout)
	-- Make a coordinate system pegged to the top-left of where the cursor would go.
	local Temp = NewIFContainer { x = layout.x - 0.5 * layout.width, y = layout.y - 0.5 * layout.height}

	local LineFont = layout.listboxlayout.font
	local FontHeight = ScriptCB_GetFontHeight(LineFont)

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

function ifs_minipage_script_listbox_PopulateItem(Dest, Data, bSelected, iColorR, iColorG, iColorB, fAlpha)
	if(Data) then

		IFObj_fnSetVis(Dest.NameStr, 1)

		IFText_fnSetFont(Dest.NameStr, ifs_minipage_script_scriptListbox_layout.FontStr)

		IFText_fnSetUString(Dest.NameStr,Data)
		
		IFObj_fnSetColor(Dest.NameStr, iColorR, iColorG, iColorB)
		IFObj_fnSetAlpha(Dest.NameStr, fAlpha)

	else
		-- Blank this entry
		IFText_fnSetString(Dest.NameStr,"This is a very long text to fill the whole box")
	end

end

function ifs_minipage_script_fillScriptLists(this)

	-- some help variables
	local dest = this.minipage.scripts
	
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
	
	ListManager_fnFillContents(dest.opScripts.list, opStrings, ifs_minipage_script_scriptListbox_layout)
	ListManager_fnFillContents(dest.ifScripts.list, ifStrings, ifs_minipage_script_scriptListbox_layout)
	ListManager_fnFillContents(dest.igScripts.list, igStrings, ifs_minipage_script_scriptListbox_layout)
	
end

function ifs_minipage_script_updateThemeList(this)
	local dest = this.minipage.theme
	local themeStrings = {}
	
	-- generate list with theme names
	for i = 1, table.getn(rema_database.scripts_GT) do
		local modID = rema_database.scripts_GT[i].modID
		local modName = " - " .. ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.modName." .. modID))
		if modName == " - [NULL]" then
			modName = ""
		end
		themeStrings[i] = modID .. modName
	end
	
	if dest.dropdown.expanded == true then
		IFObj_fnSetVis(dest.dropdown.listbox, true)
		ListManager_fnFillContents(dest.dropdown.listbox, themeStrings, ifs_minipage_script_theme_layout.lst)
		RoundIFButtonLabel_fnSetString(dest.dropdown.button, "")
	else
		IFObj_fnSetVis(dest.dropdown.listbox, false)
		local modID = rema_database.scripts_GT[rema_database.themeIdx].modID
		local modName = ScriptCB_ununicode(ScriptCB_getlocalizestr("rema.modName." .. modID))
		if modName == "[NULL]" then
			modName = modID
		end
		RoundIFButtonLabel_fnSetString(dest.dropdown.button, modName)
	end
	

end


-- Layouts

ifs_minipage_script_scriptListbox_layout = {
	x = 0,
	ySpacing = 0,
	width = ifelem_minipage_getSize() * 0.3,
	font = "gamefont_small_rema",
	yHeight = ScriptCB_GetFontHeight("gamefont_small_rema"),
	slider = 1,
	CreateFn = ifs_minipage_script_listbox_CreateItem,
	PopulateFn = ifs_minipage_script_listbox_PopulateItem,
}

ifs_minipage_script_dropdown_layout = {
	showcount = 10,
	ySpacing = 0,
	width = 130,
	flashy = 0,
	slider = 1,
	halign = "left",
	font = "gamefont_small_rema",
	yHeight = ScriptCB_GetFontHeight("gamefont_small_rema"),
	CreateFn = ifs_minipage_script_listbox_CreateItem,
	PopulateFn = ifs_minipage_script_listbox_PopulateItem,
}

ifs_minipage_script_theme_layout = {
	tag = "theme",
	string = "button",
	btnw = ifelem_minipage_getSize() * 0.25,
	x = 0,
	y = 0,
	btnFont = "gamefont_medium_rema",
	lstHeight = 200,
	lst = {
		ySpacing = 0,
		font = "gamefont_small_rema",
		halign = "right",
		valign = "vcenter",
		flashy = 0,
		slider = 1,
--		cbCreate = ifs_minipage_script_listbox_CreateItem,
--		cbPopulate = ifs_minipage_script_listbox_PopulateItem,
	},
}


-- event functions

function ifs_minipage_script_scriptManger_Enter(this)

	ifs_minipage_script_fillScriptLists(this)
	ifs_minipage_script_updateThemeList(this)
end

function ifs_minipage_script_scriptManger_Input_Accept(this)
	
	if gMouseListBox == this.minipage.theme.dropdown.listbox then
		ifs_minipage_script_processThemeChange(this, gMouseListBox.Layout.CursorIdx)
	end

	-- check default again but with listboxes this time
	if gShellScreen_fnDefaultInputAccept(this, false) then
		return
	end
	

	if this.CurButton == "_loadScripts" then
		ifs_minipage_script_loadScripts_Pressed(this)
		ifelm_shellscreen_fnPlaySound(this.acceptSound)
	elseif this.CurButton ~= nil and string.find(this.CurButton, "_ifeDropBtn_") == 1 then
		this.minipage.theme.dropdown.expanded = not this.minipage.theme.dropdown.expanded
		ifs_minipage_script_theme_layout.SelectedIdx = rema_database.themeIdx
		ifs_minipage_script_theme_layout.CursorIdx = rema_database.themeIdx
		ifs_minipage_script_theme_layout.FirstShownIdx = rema_database.themeIdx
		ifs_minipage_script_updateThemeList(this)
	elseif this.minipage.theme.dropdown.expanded == true then
		this.minipage.theme.dropdown.expanded = false
		ifs_minipage_script_updateThemeList(this)	
	end
end


-- Build

function ifs_opt_remaster_fnBuildScriptScreen()

	local scrnW, scrnH = ifelem_minipage_getSize()
	local BackButtonW = 150 -- made 130 to fix 6198 on PC - NM 8/18/04
	local yOffset = 25 + ScriptCB_GetFontHeight("gamefont_small_rema")
	ifs_minipage_script_scriptListbox_layout.showcount = ifelem_minipage_getLineCount(ifs_minipage_script_scriptListbox_layout.yHeight, scrnH - (ScriptCB_GetFontHeight("gamefont_medium_rema") * 1.5 + yOffset))
	local listHeight = ifs_minipage_script_scriptListbox_layout.showcount * ifs_minipage_script_scriptListbox_layout.yHeight
	local xListOffset = ifs_minipage_script_scriptListbox_layout.width / 2
	local yListOffset = listHeight / 2 + ScriptCB_GetFontHeight("gamefont_medium_rema") * 1.5 + yOffset
	
	local dropListHeight = ifs_minipage_script_dropdown_layout.showcount * (ifs_minipage_script_dropdown_layout.yHeight + ifs_minipage_script_dropdown_layout.ySpacing)
	local dropListWidth = ifs_minipage_script_dropdown_layout.width + 10
	
	local elements = NewIFContainer {
		loadscreen = NewIFContainer {
			x = -gSafeW * 0.25,
			y = -gSafeH*0.1,
			Image = NewIFImage {
				texture = "swbf2Remaster_loading",
				x = -0.5 * (gScrnW - gSafeW),
				y = -0.5 * (gScrnH - gSafeH),
				localpos_l = 0,
				localpos_r = gScrnW,
				localpos_t = 0,
				localpos_b = gScrnH,
				ZPos = 100,
			},
			Text = NewIFText {
				string = "rema.ifs.opt.REMA2.loadingMsg",
				font = "gamefont_medium_rema",
				halign = "hcenter",
				valign = "vcenter",
				textw = gScrnW,
				texth = gScrnH,
				x = -0.5 * (gScrnW - gSafeW),
				y = -0.5 * (gScrnH - gSafeH),
				ZPos = 50,
				nocreatebackground = 1,
			},
		},
		theme = NewIFContainer {
			title = NewIFText {
				x = -scrnW * 0.33,
				y = 0,
				halign = "hcenter",
				textw = scrnW * 0.33,
				nocreatebackground = 1,
				font = "gamefont_medium_rema",
				string = "Theme:",
			},
			dropdown = ifelem_minipage_NewDropDownButton(ifs_minipage_script_theme_layout)
		},
		loadScriptsButton = NewPCIFButton {
			y = ScriptCB_GetFontHeight("gamefont_medium_rema") * 0.5,
			x = scrnW * 0.3 * 0.5,
			btnw = BackButtonW, 
			btnh = ScriptCB_GetFontHeight("gamefont_medium_rema"),
			font = "gamefont_medium_rema", 
			bg_width = BackButtonW, 
			noTransitionFlash = 1,
			tag = "_loadScripts",
			string = "rema.ifs.opt.REMA2.btnLoad",
		},
		scripts = NewIFContainer {
			opScripts = NewIFContainer {
				title = NewIFText {
					x = 0,
					y = yOffset,
					textw = scrnW * 0.3,
					halign = "hcenter",
					nocreatebackground = 1,
					font = "gamefont_medium_rema",
					string = "rema.ifs.opt.REMA2.lblLstOS",
				},
				list = NewButtonWindow {
					x = xListOffset,
					y = yListOffset,
					width = 100,
					height = listHeight,
					font = "gamefont_small_rema",
				},
			},
			ifScripts = NewIFContainer {
				title = NewIFText {
					x = 0,
					y = yOffset,
					textw = scrnW * 0.3,
					halign = "hcenter",
					nocreatebackground = 1,
					font = "gamefont_medium_rema",
					string = "rema.ifs.opt.REMA2.lblLstIS",
				},
				list = NewButtonWindow {
					x = xListOffset,
					y = yListOffset,
					width = 100,
					height = listHeight,
					font = "gamefont_small_rema",
				},
			},
			igScripts = NewIFContainer {
				title = NewIFText {
					x = 0,
					y = yOffset,
					textw = scrnW * 0.3,
					halign = "hcenter",
					nocreatebackground = 1,
					font = "gamefont_medium_rema",
					string = "rema.ifs.opt.REMA2.lblLstGS",
				},
				list = NewButtonWindow {
					x = xListOffset,
					y = yListOffset,
					width = 100,
					height = listHeight,
					font = "gamefont_small_rema",
				},
			},
		},
	}

	-- option scripts clean bg, cursors and build list
	ifelem_minipage_setRelativePos(elements.scripts.opScripts, 0, 0)
	elements.scripts.opScripts.list.skin = nil
	ListManager_fnInitList(elements.scripts.opScripts.list, ifs_minipage_script_scriptListbox_layout)
	elements.scripts.opScripts.list.hilight.skin = nil
	elements.scripts.opScripts.list.cursor.skin = nil

	-- interface scripts clean bg, cursors and build list
	ifelem_minipage_setRelativePos(elements.scripts.ifScripts, 0.33, 0)
	elements.scripts.ifScripts.list.skin = nil
	ListManager_fnInitList(elements.scripts.ifScripts.list, ifs_minipage_script_scriptListbox_layout)
	elements.scripts.ifScripts.list.hilight.skin = nil
	elements.scripts.ifScripts.list.cursor.skin = nil
	
	-- game scripts clean bg, cursors and build list
	ifelem_minipage_setRelativePos(elements.scripts.igScripts, 0.66, 0)
	elements.scripts.igScripts.list.skin = nil
	ListManager_fnInitList(elements.scripts.igScripts.list, ifs_minipage_script_scriptListbox_layout)
	elements.scripts.igScripts.list.hilight.skin = nil
	elements.scripts.igScripts.list.cursor.skin = nil
	
	-- load button
	ifelem_minipage_setRelativePos(elements.loadScriptsButton, 0.66, 0)
	
	-- theme
	ifelem_minipage_setRelativePos(elements.theme, 0.33, 0)
	
	-- loadscreen
	IFObj_fnSetVis(elements.loadscreen, false)
	
	-- build screen
	ifelem_minipage_add("REMA2", elements, ifs_minipage_script_scriptManger_Enter, nil, ifs_minipage_script_scriptManger_Input_Accept, nil)
end

