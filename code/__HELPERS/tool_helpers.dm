//Quick type checks for some tools
var/global/list/common_tools = list(
/obj/item/stack/cable_coil,
/obj/item/wrench,
/obj/item/weldingtool,
/obj/item/screwdriver,
/obj/item/wirecutters,
/obj/item/multitool,
/obj/item/crowbar)

/proc/istool(O)
	if(O && is_type_in_list(O, common_tools))
		return 1
	return 0

/proc/iswrench(O)
	if(istype(O, /obj/item/wrench))
		return 1
	return 0

/proc/iswelder(O)
	if(istype(O, /obj/item/weldingtool))
		return 1
	return 0

/proc/iswirecutter(O)
	if(istype(O, /obj/item/wirecutters))
		return 1
	return 0

/proc/isscrewdriver(O)
	if(istype(O, /obj/item/screwdriver))
		return 1
	return 0

/proc/ismultitool(O)
	if(istype(O, /obj/item/multitool))
		return 1
	return 0

/proc/iscrowbar(O)
	if(istype(O, /obj/item/crowbar))
		return 1
	return 0

/proc/iscoil(O)
	if(istype(O, /obj/item/stack/cable_coil))
		return 1
	return 0


/proc/iswire(O)
	if(istype(O, /obj/item/stack/cable_coil))
		return 1
	return 0

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
