//Quick type checks for some tools

/proc/iswrench(O)
	if(istype(O, /obj/item/wrench))
		return TRUE
	return FALSE

/proc/iswelder(O)
	if(istype(O, /obj/item/weldingtool))
		return TRUE
	return FALSE

/proc/iswirecutter(O)
	if(istype(O, /obj/item/wirecutters))
		return TRUE
	return FALSE

/proc/isscrewdriver(O)
	if(istype(O, /obj/item/screwdriver))
		return TRUE
	return FALSE

/proc/ismultitool(O)
	if(istype(O, /obj/item/multitool))
		return TRUE
	return FALSE

/proc/iscrowbar(O)
	if(istype(O, /obj/item/crowbar))
		return TRUE
	return FALSE

/proc/iscoil(O)
	if(istype(O, /obj/item/stack/cable_coil))
		return TRUE
	return FALSE

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
