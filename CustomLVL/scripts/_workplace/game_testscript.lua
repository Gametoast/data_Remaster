------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------
print("game_testscript: entered")

function getn(v)
    local v_type = type(v);
    if v_type == "table" then
        return table.getn(v);
    elseif v_type == "string" then
        return string.len(v);
    else
        return;
    end
end

function string.starts(str, Start)
    return string.sub(str, 1, getn(Start)) == Start;
end

function tprint(t, indent)
    if not indent then indent = 1, print(tostring(t) .. " {") end
    if t then
        for key,value in pairs(t) do
            if not string.starts(tostring(key), "__") then
                local formatting = string.rep("    ", indent) .. tostring(key) .. ": ";
                if value and type(value) == "table" then
					print(formatting .. tostring(value) .. " {")
                    tprint(value, indent+1);
				else
					print(formatting .. tostring(value))
                end
            end
        end
		print(string.rep("    ", indent - 1) .. "}")
    end
end

-- helper function from Zerted to print all contents of a table
function uf_print( data, nested, depth )
	if (not data) then return end	--must have something to print
	if (not type) then return end	--must have something to print
	if depth == 0 then
		print(depth..": uf_print(): Starting: ", data, type, nested, depth)
	end

	--for each pair in the given table, 
	for key,value in pairs(data) do

		--check for nils
		if key == nil and value == nil then
			print(depth..": uf_print(): Both the key and value are nil")
		elseif key == nil then
			print(depth..": uf_print(): Nil key, but value is:", value)
		elseif value == nil then
			print(depth..": uf_print(): Nil value, but key is:", key)
		else
			--have no nils (but a continue keyword would have been nice...)
			
			--display the key, value pair if possible
			if key ~= "mapluafile" then
				--normal display
				print(depth..": Key, Value: ", key, value)
			else
				--have to format map lua file values to prevent crash when outputting the value
				local map = string.format(value, "<A>", "<B>")
				print(depth..": Key, Formated Value: ", key, map)
			end
	
			--if nested, search deeper, but don't recurse into the global table or our starting table
			if nested and key ~= "_G" and key ~= data then
			
				--the developers didn't include type(), so have to use this hack to determine if the value represents a table
				local result = pcall(function(array)
					table.getn(array)
				end, value)
				
				--can only process tables
				if result then
					uf_print(value, nested, depth+1)
				end
			end
		end
	end
	
	if depth == 0 then
		print(depth..": uf_print(): Finished: ", data, nested, depth)
	else
		print()
	end
end


if ScriptCB_DoFile then
	
	-- backup old function
	local remaGUI_ScriptCB_DoFile = ScriptCB_DoFile

	-- wrap ScriptCB_DoFile
	ScriptCB_DoFile = function(...)

		-- let the original function happen and catch the return value
	    local remaGUI_SCBDFreturn = {remaGUI_ScriptCB_DoFile(unpack(arg))}

		if arg[1] == "interface_util" then
			-- try to wrap NewIFText -----------------------------------------
			-- Zoom all text
			if NewIFText then
				
				-- backup old function
				local remaGUI_NewIFText = NewIFText

				-- wrap NewIFText
				NewIFText = function(Template,...)
					
					if Template.font then
						if Template.font == "gamefont_small" then Template.font = "gamefont_small_rema"
						elseif Template.font == "gamefont_medium" then Template.font = "gamefont_medium_rema"
						elseif Template.font == "gamefont_large" then Template.font = "gamefont_large_rema"
						end
					end
					
					-- let the original function happen
					return remaGUI_NewIFText(Template, unpack(arg))
				end
			else
				print("Remaster: Error")
				print("        : NewIFText() not found!")
			end
		end
		-- return the original values
	    return unpack(remaGUI_SCBDFreturn)
	end
else
	print("Remaster: Error")
	print("        : ScriptCB_DoFile() not found!")
end


print("gametest read font")
local w, h = ScriptCB_GetScreenInfo()

if h >= 2000 then
	ReadDataFile("REMASTER\\Fonts\\arialblack_4k.lvl")
elseif h >= 1000 then
	ReadDataFile("REMASTER\\Fonts\\arialblack_2k.lvl")
else
	ReadDataFile("REMASTER\\Fonts\\arialblack_default.lvl")
end

do return end

uf_print(_G, false, 0)



print("marker", gcinfo())
print(GetWorldFilename())
print(ScriptCB_GetGameName())

--uf_print(_G, true, 0)

do return end

if ScriptCB_IsMetagameStateSaved() then
	
	-- load all data
	local temp = {ScriptCB_LoadMetagameState()}
	
	-- if it is the database
	if temp[1] and temp[1].isRemaDatabase then
		
		print("                             : found..")
		rema_database = temp[1]
		
		tprint(temp)
		if not (next(temp, 1) == nil) then
			tprint(temp)
			-- there is more, push it back to the pipe
			ScriptCB_SaveMetagameState(
				temp[2],
				temp[3],
				temp[4],
				temp[5],
				temp[6],
				temp[7],
				temp[8],
				temp[9],
				temp[10],
				temp[11],
				temp[12],
				temp[13],
				temp[14],
				temp[15],
				temp[16],
				temp[17],
				temp[18],
				temp[19],
				temp[20],
				temp[21],
				temp[22],
				temp[23],
				temp[24],
				temp[25],
				temp[26],
				temp[27]
			)
		else
			-- there is only the database, clean up
			ScriptCB_ClearMetagameState()
		end
	
		print("                             : run game scripts..")
		swbf2Remaster_runGameScripts()
	end
end

ScriptCB_MinimizeWindow()
--spawn
do
return
end

function testsection()
	ScriptCB_DoFile("ifs_rema_spawnselect")


	--ifs_sideselect_fnEnter
	
	--local test = ifs_pc_SpawnSelect.Enter
	
	ifs_pc_SpawnSelect = nil
	ifs_pc_SpawnSelect = ifs_rema_SpawnSelect
	
	
	--ifs_pc_SpawnSelect.Enter = function(this, bFwd)
	--	print("Here we go!!")
		
	--	return test(this, bFwd)
	--end

end


if ScriptCB_DoFile then
	print("                             : success")
	
	-- backup old function
	local swbf2Remaster_gc_ScriptCB_DoFile = ScriptCB_DoFile
	
	-- wrap ScriptCB_DoFile
	print("                             : wrap ScriptCB_DoFile()")
	ScriptCB_DoFile = function(...)

		
		if arg[1] == "ifs_mapselect" then
		
			testsection()

			
			
			
		end
		-- let the original function happen
	    return swbf2Remaster_gc_ScriptCB_DoFile(unpack(arg))
	end
else
	print("                             : ScriptCB_DoFile() not found!")
end



print("game_testscript: exited")