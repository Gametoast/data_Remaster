-- STAR WARS BATTLEFRONT II - REMASTER
-- Developer Documentation by Anakin

-- Change this to your mission name and munge the script
local mission = "cor1c_con"


-----------------------------------------------------------------------------------------------------------
-- DANGER ZONE -- DANGER ZONE -- DANGER ZONE -- DANGER ZONE -- DANGER ZONE -- DANGER ZONE -- DANGER ZONE --
-----------------------------------------------------------------------------------------------------------
-- you'll become crazy looking at this code no need to burden yourself with the following
--
local originalPush = ScriptCB_PushScreen
ScriptCB_PushScreen = function(name, ...)
	
	if name == "ifs_legal" then
		ScriptCB_SetMissionNames({{Map = mission, dnldable = nil, Side = 1, SideChar = nil, Team1 = "team1", Team2 = "team2"}}, false)
		ScriptCB_SetTeamNames(0,0)
		ScriptCB_EnterMission()
	end
	
	return originalPush(name, unpack(arg))
end
-- now you are crazy!!
-----------------------------------------------------------------------------------------------------------
-- DANGER ZONE -- DANGER ZONE -- DANGER ZONE -- DANGER ZONE -- DANGER ZONE -- DANGER ZONE -- DANGER ZONE --
-----------------------------------------------------------------------------------------------------------