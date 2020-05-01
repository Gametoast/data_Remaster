------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
-- Sound Fix by Rayman1103
------------------------------------------------------------------
--[[
remaSndStack = {}

function remaSndStackAdd(str)
	table.insert(remaSndStack, 1, str)
end

function remaSndStackClear()
	remaSndStackAdd = nil
	
	if remaSndStack ~= nil and table.getn(remaSndStack) > 0 then
		for i, v in ipairs(remaSndStack) do
			ReadDataFile(v)
		end
	
	end
	remaSndStack = nil
end
--]]
-- try to wrap ReadDataFile --------------------------------------
if ReadDataFile then
	
	-- backup old function
	local soundFix_ReadDataFile = ReadDataFile
	
	-- wrap ReadDataFile
	ReadDataFile = function(...)
		
		-- fixing Tatooine music bug
		if string.find(arg[1], "sound\\tat.lvl") ~= nil then 
		--if arg[1] == "TAT\\tat2.lvl" or arg[1] == "TAT\\tat3.lvl" then
			soundFix_ReadDataFile("..\\..\\addon\\Remaster\\_LVL_PREMUNGE\\tatmusicfix.lvl;tat_music_fix")
		end
		
--[[		if remaSndStackAdd ~= nil and string.len(arg[1]) > 5 and string.sub(arg[1], 1, 5) == "sound" then
			remaSndStackAdd(arg[1])
			return
		end
--]]		
		-- fixing ki adi mundi
		--[[if arg[1] == "SIDE\\rep.lvl" then

			local list = {unpack(arg)}
			
			for i, item in ipairs(list) do
				if item == "rep_hero_kiyadimundi" then
					soundFix_ReadDataFile("REMASTER\\sounds\\Mundi.lvl;mundifix")
--					remaSndStackClear()
				end
			end
		end
		
		-- fixing natives
		if arg[1] == "SIDE\\des.lvl" or arg[1] == "SIDE\\gar.lvl" or arg[1] == "SIDE\\gun.lvl" or arg[1] == "SIDE\\wok.lvl" then
			soundFix_ReadDataFile("REMASTER\\sounds\\Natives.lvl;nativesfix")
--			remaSndStackClear()
		end--]]

		return soundFix_ReadDataFile(unpack(arg))
	end
else
	print("Remaster: Error")
	print("        : ReadDataFile() not found!")
end
--[[
-- try to wrap ScriptPostLoad ------------------------------------
if ScriptPostLoad then
	
	-- backup old function
	local NativeSoundFix_ScriptPostLoad = ScriptPostLoad
	
	-- wrap ScriptPostLoad
	ScriptPostLoad = function(...)
		
		-- let the original function happen and catch the return value
		local nativeSoundFix_SPLreturn = {NativeSoundFix_ScriptPostLoad(unpack(arg))}
		
		-- changes by Rayman1103
		SetClassProperty("gun_inf_defender", "AcquiredTargetSound", "gungan_chatter_acquired")
		SetClassProperty("gun_inf_defender", "HidingSound", "gungan_chatter_hide")
		SetClassProperty("gun_inf_defender", "ApproachingTargetSound", "gungan_chatter_approach")
		SetClassProperty("gun_inf_defender", "FleeSound", "gungan_chatter_flee")
		SetClassProperty("gun_inf_defender", "PreparingForDamageSound", "gungan_chatter_predamage")
		SetClassProperty("gun_inf_defender", "HeardEnemySound", "gungan_chatter_heard")
		SetClassProperty("gun_inf_defender", "LowHealthSound", "gungan_chatter_heartbeat")
		
		SetClassProperty("gun_inf_rider", "AcquiredTargetSound", "gungan_chatter_acquired")
		SetClassProperty("gun_inf_rider", "HidingSound", "gungan_chatter_hide")
		SetClassProperty("gun_inf_rider", "ApproachingTargetSound", "gungan_chatter_approach")
		SetClassProperty("gun_inf_rider", "FleeSound", "gungan_chatter_flee")
		SetClassProperty("gun_inf_rider", "PreparingForDamageSound", "gungan_chatter_predamage")
		SetClassProperty("gun_inf_rider", "HeardEnemySound", "gungan_chatter_heard")
		SetClassProperty("gun_inf_rider", "LowHealthSound", "gungan_chatter_heartbeat")
		
		SetClassProperty("gun_inf_soldier", "AcquiredTargetSound", "gungan_chatter_acquired")
		SetClassProperty("gun_inf_soldier", "HidingSound", "gungan_chatter_hide")
		SetClassProperty("gun_inf_soldier", "ApproachingTargetSound", "gungan_chatter_approach")
		SetClassProperty("gun_inf_soldier", "FleeSound", "gungan_chatter_flee")
		SetClassProperty("gun_inf_soldier", "PreparingForDamageSound", "gungan_chatter_predamage")
		SetClassProperty("gun_inf_soldier", "HeardEnemySound", "gungan_chatter_heard")
		SetClassProperty("gun_inf_soldier", "LowHealthSound", "gungan_chatter_heartbeat")
		
		SetClassProperty("wok_inf_mechanic", "HidingSound", "all_inf_com_chatter_hide_wookie")
		SetClassProperty("wok_inf_mechanic", "ApproachingTargetSound", "all_inf_com_chatter_approach_wookie")
		SetClassProperty("wok_inf_mechanic", "FleeSound", "all_inf_com_chatter_flee_wookie")
		SetClassProperty("wok_inf_mechanic", "PreparingForDamageSound", "all_inf_com_chatter_predamage_wookie")
		SetClassProperty("wok_inf_mechanic", "HeardEnemySound", "all_inf_com_chatter_heard_wookie")
		
		SetClassProperty("wok_inf_rocketeer", "HidingSound", "all_inf_com_chatter_hide_wookie")
		SetClassProperty("wok_inf_rocketeer", "ApproachingTargetSound", "all_inf_com_chatter_approach_wookie")
		SetClassProperty("wok_inf_rocketeer", "FleeSound", "all_inf_com_chatter_flee_wookie")
		SetClassProperty("wok_inf_rocketeer", "PreparingForDamageSound", "all_inf_com_chatter_predamage_wookie")
		SetClassProperty("wok_inf_rocketeer", "HeardEnemySound", "all_inf_com_chatter_heard_wookie")
		
		SetClassProperty("wok_inf_warrior", "HidingSound", "all_inf_com_chatter_hide_wookie")
		SetClassProperty("wok_inf_warrior", "ApproachingTargetSound", "all_inf_com_chatter_approach_wookie")
		SetClassProperty("wok_inf_warrior", "FleeSound", "all_inf_com_chatter_flee_wookie")
		SetClassProperty("wok_inf_warrior", "PreparingForDamageSound", "all_inf_com_chatter_predamage_wookie")
		SetClassProperty("wok_inf_warrior", "HeardEnemySound", "all_inf_com_chatter_heard_wookie")
		
		-- return the unmanipulated values
		return unpack(nativeSoundFix_SPLreturn)
	end
else
	print("Remaster: Error")
	print("        : ScriptPostLoad() not found!")
end--]]
