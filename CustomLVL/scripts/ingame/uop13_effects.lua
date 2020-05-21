------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------

-- try to wrap ScriptCB_IsFileExist ------------------------------
if ScriptCB_IsFileExist then
	
	-- backup old function
	local remaV13_ScriptCB_IsFileExist = ScriptCB_IsFileExist

	-- wrap ScriptCB_IsFileExist
	ScriptCB_IsFileExist = function(...)
	
		if arg[1] == "..\\..\\addon\\AAA-v1.3patch\\settings\\noAwards.txt" then
			print("Remaster: don't care about award settings file. I handle this.")
			return 0
		else
			return remaV13_ScriptCB_IsFileExist(unpack(arg))
		end
	end
else
	print("Remaster: Error")
	print("        : ScriptCB_IsFileExist() not found!")
end


-- try to wrap ScriptPostLoad ------------------------------------
if ScriptPostLoad then
	-- backup old function
	local remaV13_ScriptPostLoad = ScriptPostLoad

	-- wrap ScriptPostLoad

	ScriptPostLoad = function(...)

		if not rema_database then
			print("Remaster: This shouldn't happen. Please contact Anakin!!")
		end
		
		if rema_database.data.awardEffects == 1 and ff_awardEffectsOn == 1 then
			ff_CommandRemoveAwardEffects()
		end
		
		return remaV13_ScriptPostLoad(unpack(arg))
	end
else
	print("Remaster: Error")
	print("        : ScriptPostLoad() not found!")
end
