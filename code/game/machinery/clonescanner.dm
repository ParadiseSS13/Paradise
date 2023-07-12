#define HEALTHY_LIMB list(0, 0, 0, FALSE)
#define HEALTHY_ORGAN list(0, 0, FALSE)

//A datum to store the information gained by scanning a patient OR the fixes to be made to their body.
/datum/cloning_data
	//The patient's name.
	var/name
	//The patient's mind.
	var/datum/mind/mind

	//The patient's external organs (limbs) and their data, stored as an associated list of lists.
	//List format: limb = list(brute, burn, status, missing)
	var/list/limbs = list()

	//The patient's internal organs and their data, stored as an associated list of lists.
	//List format: organ = list(damage, status, missing)
	var/list/organs = list()

	//The patient's DNA
	var/datum/dna/genetic_info

//this is mostly an example
/datum/cloning_data/healthy

	limbs = list(
		"head"   = HEALTHY_LIMB,
		"torso"  = HEALTHY_LIMB,
		"groin"  = HEALTHY_LIMB,
		"r_arm"  = HEALTHY_LIMB,
		"r_hand" = HEALTHY_LIMB,
		"l_arm"  = HEALTHY_LIMB,
		"l_hand" = HEALTHY_LIMB,
		"r_leg"  = HEALTHY_LIMB,
		"r_foot" = HEALTHY_LIMB,
		"l_leg"  = HEALTHY_LIMB,
		"l_foot" = HEALTHY_LIMB
	)

	organs = list(
		"heart"    = HEALTHY_ORGAN,
		"lungs"    = HEALTHY_ORGAN,
		"liver"    = HEALTHY_ORGAN,
		"kidneys"  = HEALTHY_ORGAN,
		"brain"    = HEALTHY_ORGAN,
		"appendix" = HEALTHY_ORGAN,
		"eyes"     = HEALTHY_ORGAN
	)

//The cloning scanner itself.
/obj/machinery/clonescanner
	name = "cloning scanner"
	desc = "An advanced machine that thoroughly scans the current state of a cadaver for use in cloning."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "scanner_0" //temp.. maybe? probably? i dunno
	density = TRUE
	anchored = TRUE

	//The linked cloning console.
	var/obj/machinery/computer/cloning/console
	//The scanner's occupant.
	var/mob/living/carbon/human/occupant

/obj/machinery/clonescanner/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonescanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	update_icon()


/obj/machinery/clonescanner/MouseDrop_T(atom/movable/O, mob/user)
	if(!(ishuman(user) || issilicon(user)) || user.incapacitated())
		return
	if(!ishuman(O))
		return
	var/mob/living/carbon/human/H = O
	if(!(H.stat == DEAD))
		to_chat(user, "<span class='warning'>You don't think it'd be wise to scan a living being.</span>")
		return TRUE
	if(occupant)
		to_chat(user, "<span class='warning'>[src] is already occupied!</span>")
		return TRUE

	to_chat(user, "<span class='notice'>You put [H] into the cloning scanner.</span>")
	insert(H)
	return TRUE

/obj/machinery/clonescanner/AltClick(mob/user)
	if(!occupant)
		return
	if(issilicon(user))
		remove(occupant)
		return
	if(!Adjacent(user) || !ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	remove(occupant)

/obj/machinery/clonescanner/proc/insert(mob/living/carbon/human/inserted)
	inserted.forceMove(src)
	occupant = inserted
	occupant.notify_ghost_cloning()

/obj/machinery/clonescanner/proc/remove(mob/living/carbon/human/removed)
	removed.forceMove(loc)
	occupant = null

/obj/machinery/clonescanner/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)

#undef HEALTHY_LIMB
#undef HEALTHY_ORGAN
