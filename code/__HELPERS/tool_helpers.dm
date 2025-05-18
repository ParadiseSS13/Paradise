//Quick type checks for some tools

// Why are these not defines?

/proc/iswrench(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_WRENCH

/proc/iswelder(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_WELDER

/proc/iswirecutter(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_WIRECUTTER

/proc/isscrewdriver(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_SCREWDRIVER

/proc/ismultitool(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_MULTITOOL

/proc/iscrowbar(obj/item/O)
	return istype(O) && O.tool_behaviour == TOOL_CROWBAR

/proc/iscoil(O)
	return istype(O, /obj/item/stack/cable_coil)

/proc/ispowertool(O)//used to check if a tool can force powered doors
	if(istype(O, /obj/item/crowbar/power) || istype(O, /obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw))
		return TRUE
	return FALSE

/proc/is_surgery_tool(obj/item/W as obj)
	return (	\
	istype(W, /obj/item/scalpel)			||	\
	istype(W, /obj/item/hemostat)		||	\
	istype(W, /obj/item/retractor)		||	\
	istype(W, /obj/item/cautery)			||	\
	istype(W, /obj/item/bonegel)			||	\
	istype(W, /obj/item/bonesetter)
	)

/proc/is_surgery_tool_by_behavior(obj/item/W)
	if(!istype(W))
		return FALSE
	var/tool_behavior = W.tool_behaviour
	return tool_behavior in list(
		TOOL_BONEGEL,
		TOOL_BONESET,
		TOOL_CAUTERY,
		TOOL_DRILL,
		TOOL_FIXOVEIN,
		TOOL_HEMOSTAT,
		TOOL_RETRACTOR,
		TOOL_SAW,
		TOOL_SCALPEL,
		TOOL_SCREWDRIVER,
		TOOL_DISSECTOR,
	)
