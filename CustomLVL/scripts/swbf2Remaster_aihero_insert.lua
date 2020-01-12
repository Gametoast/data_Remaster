------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
-- AIHeroScript by Rayman1103
------------------------------------------------------------------

ScriptCB_DoFile("AIHeroScript")

local AIHeroClasses = {}
local AIHeroNumTeams = 0
local AIHeroVOEnabled = true
local AIHeroDisableForce = false

-- try to wrap ScriptPostLoad ------------------------------------
if ScriptPostLoad then

	-- backup old function
	local remaAIhero_ScriptPostLoad = ScriptPostLoad
	
	ScriptPostLoad = function(...)
		
		-- let the original function happen
		local returnValue = {remaAIhero_ScriptPostLoad(unpack(arg))}
		
		-- now add some fancy stuff
		-- changes by Rayman1103
		if not IsCampaign() and not AIHeroSupport then
			local GameData = ScriptCB_GetNetGameDefaults()
			
			if GameData.bHeroesEnabled then
				local HeroData = ScriptCB_GetNetHeroDefaults()
				local heroScriptMode = "unknown"
				local heroScriptSpawnDelay = 5
				local heroScriptRespawnTime = HeroData.iHeroRespawnVal
				
				if HeroData.iHeroUnlock == 5 then
					heroScriptSpawnDelay = HeroData.iHeroUnlockVal
				end
				
				if ObjectiveConquest then
					heroScriptMode = "conquest"
				elseif ObjectiveCTF or ObjectiveOneFlagCTF then
					heroScriptMode = "ctf"
				elseif ObjectiveTDM and TDM then
					if TDM.isUberMode then
						heroScriptMode = "xl"
					end
				end
				
				if AIHeroNumTeams > 0 then
					AIHeroScript:New{gameMode = heroScriptMode, heroClassName = AIHeroClasses, numTeams = AIHeroNumTeams,
										heroBroadcastVO = (rema_database.radios.heroVO == 2), heroSpawnDelay = heroScriptSpawnDelay, heroRespawnTime = heroScriptRespawnTime,}:Start()
				end
			end
		end
		
		-- return unmanipulated return values
		return unpack(returnValue)
	end
else
	print("Remaster: Error")
	print("        : ScriptPostLoad() not found!")
end

-- try to wrap SetHeroClass --------------------------------------
if SetHeroClass then

	-- backup old function
	local remaAIhero_SetHeroClass = SetHeroClass
	
	SetHeroClass = function(teamPtr, heroClassName,...)
	
		-- let the original function happen and catch the return value
		local aiHero_SHCreturn = {remaAIhero_SetHeroClass(teamPtr, heroClassName,unpack(arg))}
		
		-- changes by Rayman1103
		if heroClassName ~= "" then
			AIHeroClasses[teamPtr] = heroClassName
			
			if teamPtr > AIHeroNumTeams then
				AIHeroNumTeams = teamPtr
			end
		end
		
		-- return the unmanipulated values
		return unpack(aiHero_SHCreturn)
	end
else
	print("Remaster: Error")
	print("        : SetHeroClass() not found!")
end
