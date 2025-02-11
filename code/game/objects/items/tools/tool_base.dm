/obj/item/tool
	name = "tool"
	desc = "Shouldn't ever see this. Notify the development team."
	icon = 'icons/obj/tools.dmi'
	/// What kind of tool are we?
	var/tool_behaviour = NONE
	/// If we can turn on or off, are we currently active? Mostly for welders and this will normally be TRUE
	var/tool_enabled = TRUE

