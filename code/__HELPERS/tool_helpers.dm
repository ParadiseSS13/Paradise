
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
		TOOL_SCREWDRIVER
	)
