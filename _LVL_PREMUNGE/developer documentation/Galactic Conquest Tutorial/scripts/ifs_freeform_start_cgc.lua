-- STAR WARS BATTLEFRONT II - REMASTER
-- Developer Documentation by Anakin

function ifs_freeform_start_cgc(this)

	-- save scenario type
	this.scenario = "cgc"
	
	-- assigned teams
	local ALL = 1
	local IMP = 2
	
	-- init our custom defined gc match
	ifs_freeform_init_cgc(this, ALL, IMP)

	-- set to versus play
	ifs_freeform_controllers(this, { [0] = ALL, [1] = ALL, [2] = ALL, [3] = ALL })

	-- ALL start
	this.Start = function(this)
		-- perform common start
		ifs_freeform_start_common(this)

	   	-- set team for each planet
   		this.planetTeam = {
			["cor"] = ALL,
			["mus"] = IMP,
			["nab"] = IMP,
		}
		
		-- create starting fleets for each team
		this.planetFleet = {}
		for team, start in pairs(this.planetStart) do
			local planet = start[math.random(table.getn(start))]
			this.planetFleet[planet] = team
		end
	end
end
