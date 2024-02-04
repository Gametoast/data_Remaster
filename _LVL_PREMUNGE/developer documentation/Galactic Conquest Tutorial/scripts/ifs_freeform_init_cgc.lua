-- STAR WARS BATTLEFRONT II - REMASTER
-- Developer Documentation by Anakin

ifs_freeform_init_cgc = function (this, ALL, IMP)
	
	-- common init
	ifs_freeform_init_common(this)

	-- default victory condition (take all planets)
	this:SetVictoryPlanetLimit(nil)
	
	-- associate codes with teams
	this.teamCode = {
		[ALL] = "all",
		[IMP] = "imp"
	}
	
	-- use adjusted setup
	this.Setup = function(this)
	
		-- remove unused planets
		DeleteEntity("geo")
		DeleteEntity("kam")
		DeleteEntity("kam_system")
		DeleteEntity("geo_system")
		DeleteEntity("end_star")
		DeleteEntity("hot_star")
		DeleteEntity("tantive")
		--DeleteEntity("cor")
		DeleteEntity("dag")
		DeleteEntity("end")
		DeleteEntity("fel")
		DeleteEntity("hot")
		DeleteEntity("kas")
		--DeleteEntity("mus")
		DeleteEntity("myg")
		--DeleteEntity("nab")
		DeleteEntity("pol")
		DeleteEntity("tat")
		DeleteEntity("uta")
		DeleteEntity("yav")
		DeleteEntity("star02")
		DeleteEntity("star03")
		DeleteEntity("star04")
		DeleteEntity("star05")
		DeleteEntity("star06")
		DeleteEntity("star07")
		DeleteEntity("star10")
		DeleteEntity("star12")
		DeleteEntity("star13")
		DeleteEntity("star14")
		DeleteEntity("star15")
		DeleteEntity("star17")
		DeleteEntity("star18")
		DeleteEntity("star20")
		
		-- create the connectivity graph
		this.planetDestination = {
			["cor"] = { "mus", "nab" },
			["mus"] = { "cor", "nab" },
			["nab"] = { "cor", "mus" },

		}

		-- resource value for each planet
		this.planetValue = {
			["cor"] = { victory = 200, defeat = 50, turn = 3 },
			["mus"] = { victory = 20, defeat = 80, turn = 5 },
			["nab"] = { victory = 200, defeat = 50, turn = 3 },
		}
		
		this.spaceValue = {
			victory = 30, defeat = 10,
		}
		
		-- mission to launch for each planet
		this.spaceMission = {
			["con"] = { "spa1g_ass", "spa8g_ass", "spa9g_ass" }
		}
		this.planetMission = {
			["cor"] = {
				["con"] = "cor1g_con",
				["ctf"] = "cor1g_ctf",
			},
			["mus"] = {
				["con"] = "mus1g_con",
				["ctf"] = "mus1g_ctf",
			},
			["nab"] = {
				["con"] = "nab2g_con",
				["ctf"] = "nab2g_ctf",
			},
		}
		
		-- associate names with teams
		this.teamName = {
			[0] = "",
			[ALL] = "common.sides.all.name",
			[IMP] = "common.sides.imp.name"
		}
		
		-- associate names with team bases
		this.baseName = {
			[ALL] = "ifs.freeform.base.all",
			[IMP] = "ifs.freeform.base.imp"
		}
		
		-- associate names with team fleets
		this.fleetName = {
			[0] = "",
			[ALL] = "ifs.freeform.fleet.all",
			[IMP] = "ifs.freeform.fleet.imp"
		}
		
		-- associate entity class with team fleets
		this.fleetClass = {
			[ALL] = "gal_prp_moncalamaricruiser",
			[IMP] = "gal_prp_stardestroyer"
		}
		
		-- associate icon textures with team fleets
		this.fleetIcon = {
			[ALL] = "all_fleet_normal_icon",
			[IMP] = "imp_fleet_normal_icon"
		}
		this.fleetStroke = {
			[ALL] = "all_fleet_normal_stroke",
			[IMP] = "imp_fleet_normal_stroke"
		}
		
		-- set the explosion effect for each team
		this.fleetExplosion = {
			[ALL] = "gal_sfx_moncalamaricruiser_exp",
			[IMP] = "gal_sfx_stardestroyer_exp"
		}
		
		-- team base planets
		this.planetBase = {
			[ALL] = "cor",
			[IMP] = "nab"
		}
		
		-- team potential starting locations
		this.planetStart = {
			[ALL] = { "cor" },
			[IMP] = { "nab" }
		}
	end

end