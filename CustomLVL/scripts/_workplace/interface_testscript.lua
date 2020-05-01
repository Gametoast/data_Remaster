------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------
print("interface_testscript: entered")


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


do return end
print("marker")
print(ScriptCB_IsFileExist("..\\..\\addon\\RCM\\scripts"))

print(ScriptCB_IsFileExist("..\\..\\addon\\ABC\\scripts"))

--do return end
print("marker test")
local exists = ScriptCB_IsFileExist
local myScriptTable = {}

local base36 = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", 
                 "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", 
                 "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", 
                 "U", "V", "W", "X", "Y", "Z" }
				 
				 
testTable = {}
local index = {}
index[0] = 0
index[1] = 1

for x = 1, 36 do
	for y = 1, 36 do
		for z = 1, 36 do
			local modID = base36[x] .. base36[y] .. base36[z]
			
			--if exists("..\\..\\addon\\" .. modID .. "\\scripts") ~= 0 then
				local temp = exists("..\\..\\addon\\" .. modID .."\\scripts\\scripts.lvl")
				local pos = index[temp]
				testTable[pos] = modID
				index[1] = index[1] + temp
			--end
		end
	end
end

testTable[0] = nil

tprint(testTable)

print("marker load dll")

local test = loadfile("test.lua")

if test then
	test()
end

--loadlib([[remaster_IO.dll]], "luaopen_remaster_IO")()

--require 'remaster_IO.dll'

print("marker done")

do return end

local testPush = ScriptCB_PushScreen

ScriptCB_PushScreen = function(name,...)
	
	print("marker push", name)
	
	if name == "ifs_boot" then
		swbf2Remaster_settingsManager("load", function(failure) swbf2Remaster_dataIntegrityTest(failure) testPush("ifs_boot") end)
	else
		testPush(name, unpack(arg))
	end
end



do return end

-- try to wrap AddIFScreen ---------------------------------------
print("                        : searching AddIFScreen()..")
if AddIFScreen then
	print("                        : success")
	
	-- backup old function
	local remaGUI_AddIFScreen = AddIFScreen
	
	-- some variables
	local screenW, screenH = ScriptCB_GetScreenInfo()
	
	-- wrap AddIFScreen
	print("                        : wrap AddIFScreen()")
	AddIFScreen = function(table, name,...)

		--backupVertical = AddVerticalButtons
		-- waiting for ifs_login (profile select screen)
		
		if name == "xxx" then
		
		end

		-- let the original function happen
	    return remaGUI_AddIFScreen(table, name, unpack(arg))
	end
else
	print("                        : AddIFScreen() not found!")
end





--[[local back1 = ScriptCB_SetMissionNames

ScriptCB_SetMissionNames = function(gPickedMapList,bRandomOrder)
	print("ScriptCB_SetMissionNames")
	local data = gPickedMapList[1]
	print(data.Map)
	print(data.dnldable)
	print(data.Side)
	print(data.SideChar)
	print(data.Team1)
	print(data.Team2)
	--tprint(data)
	print(bRandomOrder)
	
	--return back1(gPickedMapList,bRandomOrder)
end

local back2 = ScriptCB_SetTeamNames

ScriptCB_SetTeamNames = function(t1, t2)
	print("ScriptCB_SetTeamNames")
	print(t1, t2)
	
	--return back2(t1, t2)
end


ScriptCB_EnterMission = function()
	print("Enter")
end--]]


--[[
--ScriptCB_usprintf

local backupSet = ScriptCB_SetIFScreen
ScriptCB_SetIFScreen = function(screen,...)
	print("SetIFScreen", screen)
	
	return backupSet(screen, unpack(arg))
end


local backPush = ScriptCB_PushScreen
ScriptCB_PushScreen = function(screen, ...)
	print("PushScreen", screen)
	
	return backPush(screen, unpack(arg))

end

print("interface_testscript: searching AddIFScreen()..")
if AddIFScreen then
	print("interface_testscript: success")
	
	-- backup old function
	local remaTEST_AddIFScreen = AddIFScreen

	-- wrap AddIFScreen
	print("interface_testscript: wrap AddIFScreen()")
	AddIFScreen = function(table, name,...)

		-- let the original function happen
	    return remaTEST_AddIFScreen(table, name, unpack(arg))
	end
else
	print("interface_testscript: AddIFScreen() not found!")
end
--]]
--ifs_instant_options.set_defaults(this)
--ifs_instant_options.push_prefs(this)

--ScriptCB_SetNetGameDefaults
--ScriptCB_GetNetGameDefaults

--if number of frames = 0 reanable input
--ScriptCB_SetIgnoreInputs(number of frames)

--int = 0 or 1
--ScriptCB_EnableCursor(int)

--ScriptCB_tounicode
--ifs_login_Done

--ScriptCB_UpdateScreen()

--ReadDataFileInGame
--ScriptCB_GetGameRules 
--ScriptCB_SetGameRules 
--ScriptCB_GetOnlineOpts 
--ScriptCB_SetOnlineOpts 
--ScriptCB_GetControlMode 
--ScriptCB_SetControlMode 
--ScriptCB_SetGeneralOptions 
--ScriptCB_GetGeneralOptions

--"ClearTempHeap"
--"ScriptCB_PostLoadHack"
--"SetupTempHeap"
--[[if showLoadDisplay then
	-- stop any streaming
	ScriptCB_StopMovie()
	ScriptCB_CloseMovie()
	ScriptCB_SetShellMusic()
			
	-- do loading
	SetupTempHeap(2 * 1024 * 1024)
	ScriptCB_ShowLoadDisplay(true)
end
			
-- load sides
ifs_purchase_load_data(this.teamCode[1], this.teamCode[2])

-- read the galaxy map level
ReadDataFile("gal\\gal1.lvl")
			
-- read the galaxy map level
ReadDataFile("sound\\gal.lvl;gal_vo")
			
this.streamVoice = OpenAudioStream("sound\\gal.lvl",  "gal_vo_slow")
this.streamMusic = OpenAudioStream("sound\\gal.lvl",  "gal_music")

ScriptCB_PostLoadHack()

-- hide the load display
if showLoadDisplay then
	ScriptCB_ShowLoadDisplay(false)
	ClearTempHeap()
end	--]]


--"ScriptCB_usprintf"
--"ScriptCB_OpenPopup"
--"ScriptCB_ClosePopup"
--"ScriptCB_OpenErrorBox"
--"ScriptCB_CloseErrorBox"
--"ScriptCB_MrMrsEval"
--"ScriptCB_IsInShell"
--"ScriptCB_SetFunctionIdForAnalogId"
--"ScriptCB_GetFunctionIdForAnalogId"
--"ScriptCB_SetFunctionIdForButtonId"
--"ScriptCB_GetFunctionIdForButtonId"

--[[
local base36 = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", 
                 "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", 
                 "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", 
                 "U", "V", "W", "X", "Y", "Z" }
local exists = ScriptCB_IsFileExist -- Store the function into a local for performance.

for x = 1, 36 do 
   for y = 1, 36 do 
      for z = 1, 36 do 
         exists("user_script_" .. base36[x] .. base36[y] .. base36[z])
      end
   end
end
--]]

print("interface_testscript: exited")