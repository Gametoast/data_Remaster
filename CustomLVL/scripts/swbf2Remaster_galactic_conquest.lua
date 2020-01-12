------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

local w, h = ScriptCB_GetScreenInfo()
local zoomFactor = 1
if(h ~= 600) then
	zoomFactor = 1.152
end

-- try to wrap AddIFScreen ---------------------------------------
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

