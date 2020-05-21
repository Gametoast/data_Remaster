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
				print("Remaster: This shouldn't happen. Please contact Anakin!!")
			end
			
			if rema_database.data.customColor == 2 then
				return 0
			else
				return 1
			end
		end
	end
else
	print("Remaster: Error")
	print("        : ScriptCB_IsFileExist() not found!")
end
