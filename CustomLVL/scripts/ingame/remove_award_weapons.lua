------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
-- NoAwardWeapon script by Rayman1103
------------------------------------------------------------------

--attempt to take control of (or listen to the calls of) the ReadDataFile function
if ReadDataFile then
	if ScriptCB_IsFileExist("..\\..\\addon\\Remaster\\_LVL_PREMUNGE\\noawardweapons.lvl") == 1 then
		
		local hasReadAwardData = false
		
		--backup the current ReadDataFile function
		local NoAwardWeapons_ReadDataFile = ReadDataFile

		--this is our new ReadDataFile function
		ReadDataFile = function(sourceFilename, ...)

			if string.find(string.lower(sourceFilename), "side\\") and not hasReadAwardData then
				hasReadAwardData = true

				ReadDataFile("..\\..\\addon\\Remaster\\_LVL_PREMUNGE\\noawardweapons.lvl",
								"com_weap_award_pistol",
								"com_weap_award_rifle",
								"com_weap_award_rocket_launcher",
								"com_weap_award_shotgun",
								"com_weap_award_sniper_rifle",
								"com_weap_inf_commando_pistol",
								"com_weap_inf_pistol",
								"com_weap_inf_rifle",
								"com_weap_inf_rocket_launcher",
								"com_weap_inf_shotgun",
								"com_weap_inf_sniper_rifle")
			end
			
			-- let the original function happen and catch the return value
			local noAwardWeapons_RDFreturn = {NoAwardWeapons_ReadDataFile(sourceFilename, unpack(arg))}
			
			-- return the unmanipulated values
			return unpack(noAwardWeapons_RDFreturn)
		end

	end
else
	print("Remaster: Error")
	print("        : ReadDataFile() not found!")
end
