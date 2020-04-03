------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

local w, h = ScriptCB_GetScreenInfo()
local zoomFactor = 1
if(h ~= 600) then
	zoomFactor = 1.152
end

-- try to wrap AddIFScreen ---------------------------------------
-- do some graphic cosmetic
-- fix gc result boxes
-- improve versus gc setup interaction
-- improve gc sideselect interaction
-- fix Enter buy card when on placing them
if AddIFScreen then
	
	-- backup old function
	local remaGC_AddIFScreen = AddIFScreen
	
	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()
	
	-- wrap AddIFScreen
	AddIFScreen = function(table, name,...)

		-- do some graphic cosmetic
		if name == "ifs_freeform_main" then
			
			-- change the team colors
			ifs_freeform_main.InitTeamColor = function(this)
				-- precomputed colors
				local colorWhite = { r=255, g=255, b=255 }
				local colorBlue = { r=0, g=97, b=101 }
				local colorRed = { r=161, g=16, b=53 }
				
				-- if AI versus team 2...
				this.teamColor = {}
				if not this.teamController[1] and this.teamController[2] then
					-- swapped colors: 1=red, 2=blue
					this.teamColor[1] = { [0] = colorWhite, [1] = colorRed, [2] = colorBlue }
					this.teamColor[2] = { [0] = colorWhite, [1] = colorRed, [2] = colorBlue }
				else
					-- absolute colors: 1=blue, 2=red
					this.teamColor[1] = { [0] = colorWhite, [1] = colorBlue, [2] = colorRed }
					this.teamColor[2] = { [0] = colorWhite, [1] = colorBlue, [2] = colorRed }
				end
				
			end
			
			-- increase planet visibility through extra planetgraphic_halo
			ifs_freeform_main.DrawPlanetIcons = function(this, alpha)
				alpha = alpha or this.renderAlpha
				-- draw planet icons
				for planet, _ in pairs(this.planetDestination) do
					local team = this.planetTeam[planet] or 0
					local matrix = this.planetMatrix[planet][0]
					local r,g,b = this:GetTeamColor(team)
					if team ~= 0 then
						DrawParticleAt(matrix, "planetgraphic_halo", 75, r, g, b, 20 * alpha, 0.0)
						DrawParticleAt(matrix, "planetgraphic_halo", 10, r, g, b, 255 * alpha, 0.0)
					else
						DrawParticleAt(matrix, "planetgraphic_halo", 3, r, g, b, 192 * alpha, 0.0)
					end
					if planet == this.planetSelected then
						local size = ScriptCB_GetMissionTime()
						size = size - math.floor(size)
						local a = 224 * (1 - size * size)
						size = 14 * size + 4
						DrawParticleAt(matrix, "planetgraphic_cursor", size, r, g, b, a * alpha, 0.0)
		--			elseif team ~= 0 then
		--				DrawParticleAt(matrix, "planetgraphic_cursor", 16, r, g, b, 192, 0.0)
					end
					
					if team ~= 0 then
						local base = planet == this.planetBase[team]
						
						local size = base and 24 or 16
						DrawParticleAt(matrix, "star_flare", size, r, g, b, 128 * alpha, 0.0)
						DrawParticleAt(matrix, "star_flare", size * 0.5, 255, 255, 255, 255 * alpha, 0.0)
						
						if base then
							local matrix = this.planetMatrix[planet][3]
							local side = this.teamCode[team]
							DrawParticleAt(matrix, "seal_" .. side, 12, r, g, b, 192 * alpha, 0.0)
						end
					end
				end
			end
			
		end

		-- fix gc result boxes
		if name == "ifs_freeform_result" then
			local screenW, screenH = ScriptCB_GetScreenInfo()
			local AR = screenH / screenW
			ifs_freeform_result.player_result.y = ifs_freeform_result.player_result.y * 4 / 3 * AR
			ifs_freeform_result.enemy_result.y = ifs_freeform_result.enemy_result.y * 4 / 3 * AR
		end
		
		-- improve versus gc setup interaction
		if name == "ifs_freeform_customsetup" then

			ifs_freeform_customsetup.bg.texture = "single_player_conquest"
			
			local BackButtonW = 150 -- made 130 to fix 6198 on PC - NM 8/18/04
			local BackButtonH = 25
			
			ifs_freeform_customsetup.nextButton = NewPCIFButton {
				ScreenRelativeX = 1.0, -- right
				ScreenRelativeY = 1.0, -- bottom
				y = -15, -- just above bottom
				x = -BackButtonW * 0.5,
				btnw = BackButtonW, 
				btnh = BackButtonH,
				font = "gamefont_medium", 
				bg_width = BackButtonW, 
				noTransitionFlash = 1,
				tag = "_next",
				string = "ifs.mp.leaderboard.next",
			}
			
			-- show left right option only for value, not era
			local cgcPopItem = ifs_freeform_customsetup_PopulateItem
			ifs_freeform_customsetup_PopulateItem = function(Dest, Tag, bSelected, iColorR, iColorG, iColorB, fAlpha, ...)
				local returnValues = {cgcPopItem(Dest, Tag, bSelected, iColorR, iColorG, iColorB, fAlpha,unpack(arg))}
				
				if Tag == "era" then
					local CWUStr = ScriptCB_getlocalizestr("common.era.cw")
					local GCWUStr = ScriptCB_getlocalizestr("common.era.gcw")
					local ValUStr
					if(ifs_freeform_customsetup.Prefs.iEra == 1) then
						ValUStr = CWUStr
					else
						ValUStr = GCWUStr
					end
					IFText_fnSetUString(Dest.textitem,ScriptCB_usprintf("rema.cgcEra", ValUStr))
				end
				
				return unpack(returnValues)
			end
			
			ifs_freeform_customsetup_layout.PopulateFn = ifs_freeform_customsetup_PopulateItem
			
			-- Input accept fix
			local cgcInputAcc = ifs_freeform_customsetup.Input_Accept
			ifs_freeform_customsetup.Input_Accept = function(this,...)
				
				-- install changes only for PC
				if(gPlatformStr == "PC") then

					if gMouseListBox == this.listbox then
						
						local focusIdx = gMouseListBox.Layout.SelectedIdx
						local curIdx = gMouseListBox.Layout.CursorIdx
						
						-- change focusIdx
						if focusIdx ~= curIdx then
							ifelm_shellscreen_fnPlaySound("shell_select_change")
							gMouseListBox.Layout.SelectedIdx = curIdx
							ListManager_fnAutoscroll(gMouseListBox, gMouseListBox.Contents, gMouseListBox.Layout)
						else -- action belongs on the position that was triggered
							local tag = this.CurTags[focusIdx]
							if curIdx == 1 or curIdx == 2 then
								ifs_freeform_customsetup_fnAdjustValue(this, tag, 1)							
							elseif curIdx == 3 then
								this.Prefs.iVictoryType = math.mod(this.Prefs.iVictoryType,4) + 1
								-- Fix for 9397 - NM 8/9/05 - Ken says that base conquest no longer
								-- a valid setup type. So, do this again to skip over the option
								if(this.Prefs.iVictoryType == 2) then
									this.Prefs.iVictoryType = math.mod(this.Prefs.iVictoryType,4) + 1
								end
							end
							
							ifs_freeform_customsetup_fnSetListboxContents(this)
						end
						
						return
					end
					
					-- handle button press
					if this.CurButton == "_back" then
						ScriptCB_SndPlaySound("shell_menu_exit")
						ScriptCB_PopScreen()
						return
					elseif this.CurButton == "_next" then
						return cgcInputAcc(this, unpack(arg))
					end
				else
					return cgcInputAcc(this, unpack(arg))
				end
			end
		end
		
		-- improve gc sideselect interaction
		if name == "ifs_freeform_sides" then
		
			this = ifs_freeform_sides
			
			-- delete old stuff
			this.action = nil
			this.bgImage = nil
			
			-- new buttons and info stuff
			local BackButtonW = 150 -- made 130 to fix 6198 on PC - NM 8/18/04
			local BackButtonH = 25
			
			this.btnBack = NewPCIFButton {
				ScreenRelativeX = 0.0, -- left
				ScreenRelativeY = 1.0, -- bottom
				y = -15, -- just above bottom
				x = BackButtonW * 0.5,
				btnw = BackButtonW, 
				btnh = BackButtonH,
				font = "gamefont_medium", 
				bg_width = BackButtonW, 
				noTransitionFlash = 1,
				tag = "_back",
				string = "common.back",
			}
	
			this.infoTxt = NewIFText {
				ScreenRelativeX = 0.5, -- center
				ScreenRelativeY = 1, -- bottom
				font = "gamefont_medium",
				string = "rema.cgcControl",
				textw = 400,
				valign = "top",
				halign = "hcenter",
				nocreatebackground = 1,
				tag = "_infoTxt",
				y = -25, -- just above bottom
				x = 42 - 200,
			}

			this.btnStart = NewPCIFButton {
				ScreenRelativeX = 1.0, -- right
				ScreenRelativeY = 1.0, -- bottom
				y = -15, -- just above bottom
				x = -BackButtonW * 0.5,
				btnw = BackButtonW, 
				btnh = BackButtonH,
				font = "gamefont_medium", 
				bg_width = BackButtonW, 
				noTransitionFlash = 1,
				tag = "_start",
				string = "ifs.missionselect.buttons.text.launch",
			}
			
			-- Input accept fix
			local cgcInputAcc = this.Input_Accept
			this.Input_Accept = function(this,joystick, ...)
				
				-- install changes only for PC
				if(gPlatformStr == "PC") then

					-- handle button press
					if this.CurButton == "_back" then
						ScriptCB_SndPlaySound("shell_menu_exit")
						
						ScriptCB_SetQuitPlayer(1)
						Popup_YesNo.calledFrom = this
						Popup_YesNo.CurButton = "no" -- default
						Popup_YesNo.fnDone = function(bResult)
							
							if bResult then
								Popup_YesNo.fnDone = nil
								ScriptCB_ClearCampaignState()
								ScriptCB_ClearMetagameState()
								ScriptCB_ClearMissionSetup()
								-- disable metagame rules
								ScriptCB_SetGameRules("instantaction")
								-- restart the shell (HACK)
								SetState("shell")
							else
								Popup_YesNo.fnDone = nil
							end
						end
						Popup_YesNo:fnActivate(1)
						gPopup_fnSetTitleStr(Popup_YesNo, "ifs.pause.warn_quit")
	
						return
					elseif this.CurButton == "_start" then
						return cgcInputAcc(this, joystick, unpack(arg))
					else
						local newTeam = 3 - this.controllerTeam[joystick]
						this.controllerTeam[joystick] = newTeam
						IFObj_fnSetPos(this.players[joystick], this.players.side_x[newTeam], this.players.name_y[joystick])
					end
				else
					return cgcInputAcc(this, joystick, unpack(arg))
				end
			end
		end
		
		-- fix Enter buy card when on placing them
		if name == "ifs_freeform_purchase_tech" then
			this = ifs_freeform_purchase_tech

			
			
-------------------------------------------------------------------------------------			
		---------------------------------------------------------------------
		
		
			
			this.Input_Accept = function(this, joystick)
			if(gPlatformStr == "PC") then
				if ifelem_tabmanager_HandleInputAccept(this, ifs_freeform_tab_layout) then
					return
				end
				print( "this.CurButton = ", this.CurButton )
				if( this.CurButton == "_accept" ) then
					-- purchase the item
  				elseif( this.CurButton == "_back" ) then
  					-- handle in Input_Back
  					this:Input_Back(joystick)
  					return
  				elseif( this.CurButton == "_help" ) then
  					-- handle in Input_Misc2
  					this:Input_Misc2(joystick)
  					return
				elseif( this.CurButton == "_next" ) then
					if this.miscScreen then
--						-- go to end
--						ScriptCB_SetIFScreen(this.miscScreen)
					end
				else
					-- check double click
					if( this.lastDoubleClickTime and ScriptCB_GetMissionTime()<this.lastDoubleClickTime+0.4 ) then
						this.bDoubleClicked = 1
					else
						this.lastDoubleClickTime = ScriptCB_GetMissionTime()
					end
					local ScreenW,ScreenH = ScriptCB_GetScreenInfo()
					local box_l = ScreenW * 343 / 800
					local box_t = ScreenH * 279 / 600
					local box_r = ScreenW * 457 / 800
					local box_b = ScreenH * 405 / 600
					if( this.bDoubleClicked == 1 ) then
						this.bDoubleClicked = nil
						if( ( this.iMouse_x >= box_l ) and ( this.iMouse_x <= box_r ) and
							( this.iMouse_y >= box_t ) and ( this.iMouse_y <= box_b ) ) then
							-- if click on the card
							print( "this DoubleClicked!" )
						else
							-- do nothing if not click on the unit
							return	
						end						
					else
						--print( "mouse x,y = ", this.iMouse_x, this.iMouse_y )
						-- move card if single click
						-- move card in focus mode
						if( this.focus == ifs_purchase_tech_focus_cards ) then
							if( ( this.iMouse_y >= box_t ) and ( this.iMouse_y <= box_b ) ) then
								if( this.iMouse_x < box_l ) then
									this:Input_GeneralLeft()
								elseif( this.iMouse_x > box_r ) then
									this:Input_GeneralRight()
								end
							end
							return
						end
					end
				end				
			end
			
			-- If base class handled this work, then we're done
			if(gShellScreen_fnDefaultInputAccept(this)) then
				return
			end
			
			print("marker i come here", this.focus, this.CurButton)
			
			local team = this.main.playerTeam

			-- if focused on cards			
			if ( this.focus == ifs_purchase_tech_focus_cards ) then
				local cur = this.purchaseItems[this.selected]
				local cur_rot = cur.spin_interpolator:value()

				local owned = ifs_purchase_tech_cards[team][this.selected]
				
				-- if enough resources...
				local tech = ifs_purchase_tech_table[this.selected]
				local cost = tech.cost[owned]
				if this.main:SpendResources(nil, cost) then
					this.main:UpdatePlayerText(this.player)
			 		ifelm_shellscreen_fnPlaySound(this.acceptSound)
			 		this.main:PlayVoice(string.format(ifs_purchase_tech_bought_sound[owned], this.main.playerSide, owned and tech.bonus or tech.name))
					-- if the technology is not owned...
					if not owned then
						-- purchase the technology
						owned = true
						ifs_purchase_tech_cards[team][this.selected] = owned
						cur.spin_interpolator = make_purchase_interpolator(cur_rot, ifs_purchase_tech_rotate[owned], ifs_purchase_tech_spin_time)
						this:UpdateActionCarousel()
					else
						-- purchase the enhancement
						IFModel_fnSetMsh(this.useItems.cursor.card, tech.mesh)
						IFObj_fnSetColor(this.useItems.cursor.card, 255, 255, 255)

						this.useItems.cursor.index = this.selected
						
						-- find a free slot (if any)
						local slot = 1
						for i, using in ipairs(ifs_purchase_tech_using[team]) do
							if using == 0 then
								slot = i
								break
							end
						end
						this:SetCursor(slot)
						
						this:FocusUsing()
					end
				else
					-- not enough resources
			 		ifelm_shellscreen_fnPlaySound(this.cancelSound)
					this.main:PlayVoice(string.format(ifs_purchase_tech_broke_sound[owned], this.main.playerSide))
				end
			else
		 		ifelm_shellscreen_fnPlaySound(this.acceptSound)
		 		local position = this.useItems.cursor.position
		 		local index = this.useItems.cursor.index
		 		
		 		-- if there is no card there...
		 		if ifs_purchase_tech_using[team][position] == 0 then
		 			-- place the card
		 			this:PlaceUsing(team, position, index)
				else
					-- pop up a yes/no request
					this:PromptReplace(team, position, index)
				end
			end

		end
		
		
		---------------------------------------------------------------------
-------------------------------------------------------------------------------------

		
			-- Input accept fix
			local cgcInputAcc = this.Input_Accept
			this.Input_Accept = function(this,joystick, ...)
				
				print(">>> Accept", joystick, unpack(arg))

				if this.Remaster then
					print("this was a keypress")
					this.Remaster = nil
				end
				--print("marker accepted", joystick)
				--tprint(this)
				return cgcInputAcc(this, joystick, unpack(arg))
			end
			
			local cgcKeyDown = this.Input_KeyDown
			this.Input_KeyDown = function(this, iKey, ...)
				print(">>> Keypress", iKey, this.focus)
				
				if (iKey == 10 or iKey == 13) then
					this.Remaster = 1
				end
					--print("marker using this way")
					--return
					--this.CurButton = nil
					--this:Input_Accept(-1)
				--else
					cgcKeyDown(this, iKey, unpack(arg))
				--end
			end
		end

		-- let the original function happen
	    return remaGC_AddIFScreen(table, name, unpack(arg))
	end
else
	print("Remaster: Error")
	print("        : AddIFScreen() not found!")
end

-- try to wrap ReadDataFile --------------------------------------
if ReadDataFile then

	-- backup old function
	local remaGC_ReadDataFile = ReadDataFile

	-- wrap ReadDataFile
	ReadDataFile = function(...)

		-- load meshes faster than the stock game
		if arg[1] == "gal\\gal1.lvl" then
			ReadDataFile("REMASTER\\swbf2Remaster_gal_meshs.lvl")
		end
		
		-- let the original function happen
		local retval = {remaGC_ReadDataFile(unpack(arg))}
		
		-- overwrite existing textures
		if arg[1] == "gal\\gal1.lvl" then
			ReadDataFile("REMASTER\\swbf2Remaster_gal_textures.lvl")
		end
			
		-- return unmodified return values
		return unpack(retval)
	end

else
	print("Remaster: Error")
	print("        : ReadDataFile() not found!")
end

-- try to wrap ScriptCB_DoFile -----------------------------------
if ScriptCB_DoFile then

	-- backup old function
	local remaGC_ScriptCB_DoFile = ScriptCB_DoFile

	-- wrap ScriptCB_DoFile
	ScriptCB_DoFile = function(...)
		
		-- let the original function happen
		local retval = {remaGC_ScriptCB_DoFile(unpack(arg))}
		
		-- add the missing bonus and fix positioning
		if arg[1] == "ifs_freeform_purchase_tech" then
			table.insert(
				ifs_purchase_tech_table_freeform,
				1,
				{
					mesh = "gal_shell_surveillance",
					name = "surveillance",
					cost = { [false] = 100, [true] = 20 },
					bonus = "sensor_array",
					hints = {
						{ "ctf$", 3 },
						{ "^tan", 2 },
						{ "^pol", 2 },
						{ "^dea", 2 },
						{ "^kam", 2 },
						{ "^mus", 2 },
						{ "^nab", 2 },
						{ ".*", 1 }}
				}
			)
			
			ifs_purchase_tech_spacing = 0.25 * zoomFactor
			ifs_purchase_tech_use_spacing = 5.75 * zoomFactor
			ifs_purchase_tech_use_x = -2 * ifs_purchase_tech_use_spacing
			ifs_purchase_tech_use_y = 4.5 / zoomFactor
		end

		-- return unmodified return values
		return unpack(retval)
	end

else
	print("Remaster: Error")
	print("        : ScriptCB_DoFile() not found!")
end

