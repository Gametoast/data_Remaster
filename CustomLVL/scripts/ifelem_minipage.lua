------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------


------------------------------------------------------------------
-- utility functions

function ifelem_minipage_update(this)

	-- hide all screens
	IFObj_fnSetVis(this.screens.test, false)
	IFObj_fnSetVis(this.screens.general, false)
	IFObj_fnSetVis(this.screens.scripts, false)
	
	if this.curMinipage == "general" then
		IFObj_fnSetVis(this.screens.general, true)
	elseif this.curMinipage == "scripts" then
		IFObj_fnSetVis(this.screens.scripts, true)
	else
		-- TODO: ScriptCB_SetIFScreen("tab_screen")
	end
end

function ifelem_minipage_getSize()
	return gSafeW * 0.75, gSafeH * 0.8
end

function ifelem_minipage_setRelativePos(dest, relX, relY)
	
	local width, heigh = ifelem_minipage_getSize()
	dest.x = width * relX
	dest.y = heigh * relY
end

------------------------------------------------------------------
-- Tab functions


------------------------------------------------------------------
-- Button events


------------------------------------------------------------------
-- Listbox


------------------------------------------------------------------
-- Theme


------------------------------------------------------------------
-- Layouts


------------------------------------------------------------------
-- Build
