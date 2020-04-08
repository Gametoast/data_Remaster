------------------------------------------------------------------
-- SWBF 2 Remaster by Anakin
------------------------------------------------------------------


------------------------------------------------------------------
-- utility functions

function ifelem_minipage_update(this)

	-- hide all screens
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
