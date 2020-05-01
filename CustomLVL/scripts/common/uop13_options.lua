------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

-- try to wrap ScriptCB_IsFileExist ------------------------------
if ScriptCB_IsFileExist then
	
	-- backup old function
	local remaV13_ScriptCB_IsFileExist = ScriptCB_IsFileExist
	
	-- wrap ScriptCB_IsFileExist
	ScriptCB_IsFileExist = function(...)
	
		if arg[1] == "..\\..\\addon\\AAA-v1.3patch\\settings\\noColors.txt" then

			if not rema_database then
				print("Houston, we got a problem!!")
			end
			
			if rema_database.data.customColor == 2 then
				return 0
			else
				return 1
			end
			
		elseif arg[1] == "..\\..\\addon\\AAA-v1.3patch\\settings\\noAwards.txt" then

			if not rema_database then
				print("Houston, we got a problem!!")
			end
			
			if rema_database.data.awardEffects == 2 then
				return 0
			else
				return 1
			end
			
		else
			return remaV13_ScriptCB_IsFileExist(unpack(arg))
		end
		
	end
else
	print("Remaster: Error")
	print("        : ScriptCB_IsFileExist() not found!")
end
