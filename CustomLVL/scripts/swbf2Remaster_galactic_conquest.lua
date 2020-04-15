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
-- fix double accept event for Enter bug (bonus and unit purchase)
if AddIFScreen then
	
	-- backup old function
	local remaGC_AddIFScreen = AddIFScreen
	
	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()
	
	-- wrap AddIFScreen
	AddIFScreen = function(screenTable, name,...)

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
					IFText_fnSetUString(Dest.textitem,ScriptCB_usprintf("rema.ifs.cgc.era", ValUStr))
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
				string = "rema.ifs.cgc.control",
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
		
		-- fix double accept event for Enter bug (bonus)
		if name == "ifs_freeform_purchase_tech" then
			this = ifs_freeform_purchase_tech

			-- Input accept fix
			local cgcInputAcc = this.Input_Accept
			this.Input_Accept = function(this,joystick, ...)

				-- There is a timeStamp, potentially a critical action was performed earlier
				if this.timeStamp then
					local timeDiff = ScriptCB_GetMissionTime() - this.timeStamp
					this.timeStamp = nil
					
					if timeDiff < 0.000001 then
						-- First accept was triggered by Enter, this is the 2nd call
						
						-- First rotated, correct this
						if this.movedWheel then
							if this.movedWheel == -1 then
								this:Input_GeneralRight()
							else
								this:Input_GeneralLeft()
							end
						-- First placed, do nothing
						elseif this.placedCard then
							this.placedCard = nil
							this.CurButton = nil
							return
						-- First did nothing
						else
							-- let this happen
						end
					end
					
					-- First critical action has been long enough ago, so continue
					this.placedCard = nil
					this.movedWheel = nil
				end
				
				local returnValue = {cgcInputAcc(this, joystick, unpack(arg))}
				
				-- if we come from keypress, reset the current button
				if joystick == -1 then
					this.CurButton = nil
				end
				
				return unpack(returnValue)
			end
			
			-- set marker that card was placed
			local cgcPlaceUsing = this.PlaceUsing
			this.PlaceUsing = function(this,...)
				this.timeStamp = ScriptCB_GetMissionTime()
				this.placedCard = true
				
				cgcPlaceUsing(this, unpack(arg))
			end
			
			-- set marker that it was rotated left
			local cgcGeneralLeft = this.Input_GeneralLeft
			this.Input_GeneralLeft = function(this, joystick, ...)
				
				if this.selected > 1 then
					this.timeStamp = ScriptCB_GetMissionTime()
					this.movedWheel = -1
				end
				
				cgcGeneralLeft(this, joystick, unpack(arg))
			end
			
			-- set marker that it was rotated right
			local cgcGeneralRight = this.Input_GeneralRight
			this.Input_GeneralRight = function(this, joystick, ...)
			
				if this.selected < table.getn(ifs_purchase_tech_table) then
					this.timeStamp = ScriptCB_GetMissionTime()
					this.movedWheel = 1
				end
				
				cgcGeneralRight(this, joystick, unpack(arg))
			end
		end

		-- fix double accept event for Enter bug (unit)
		if name == "ifs_freeform_purchase_unit" then
			this = ifs_freeform_purchase_unit

			-- Input accept fix
			local cgcInputAcc = this.Input_Accept
			this.Input_Accept = function(this,joystick, ...)

				-- There is a timeStamp, potentially a critical action was performed earlier
				if this.timeStamp then
					local timeDiff = ScriptCB_GetMissionTime() - this.timeStamp
					this.timeStamp = nil
					
					if timeDiff < 0.000001 then
						-- First accept was triggered by Enter, this is the 2nd call
						
						-- First rotated, correct this
						if this.movedWheel then
							if this.movedWheel == -1 then
								this:Input_GeneralRight()
							else
								this:Input_GeneralLeft()
							end
						-- First did nothing
						else
							-- let this happen
						end
					end
					
					-- First critical action has been long enough ago, so continue
					this.movedWheel = nil
				end
				
				local returnValue = {cgcInputAcc(this, joystick, unpack(arg))}
				
				-- if we come from keypress, reset the current button
				if joystick == -1 then
					this.CurButton = nil
				end
				
				return unpack(returnValue)
			end
			
			-- set marker that it was rotated left
			local cgcGeneralLeft = this.Input_GeneralLeft
			this.Input_GeneralLeft = function(this, joystick, ...)
				
				if this.selected > 1 then
					this.timeStamp = ScriptCB_GetMissionTime()
					this.movedWheel = -1
				end
				
				cgcGeneralLeft(this, joystick, unpack(arg))
			end
			
			-- set marker that it was rotated right
			local cgcGeneralRight = this.Input_GeneralRight
			this.Input_GeneralRight = function(this, joystick, ...)
			
				if this.selected < table.getn(this.purchaseItems) then
					this.timeStamp = ScriptCB_GetMissionTime()
					this.movedWheel = 1
				end
				
				cgcGeneralRight(this, joystick, unpack(arg))
			end
		end

		-- let the original function happen
	    return remaGC_AddIFScreen(screenTable, name, unpack(arg))
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

