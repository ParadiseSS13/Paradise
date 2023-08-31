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

#define SCANNER_UNCLONEABLE_SPECIES "uncloneable"
#define SCANNER_HUSKED "husked"
#define SCANNER_NO_SOUL "soulless"
#define SCANNER_MISC "miscellanious"

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
	//The tier of scan we can perform. Tier 2 parts and up can scan husks - or a tier 4 scanner and tier 1 laser.
	var/scanning_tier
	//The scanner's occupant.
	var/mob/living/carbon/human/occupant
	//The scanner's latest scan result
	var/datum/cloning_data/last_scan

/obj/machinery/clonescanner/Initialize(mapload)
	. = ..()

	if(!console && mapload) //this could be varedited in in mapping, maybe?
		console = pick(locate(/obj/machinery/computer/cloning, orange(5, src))) //yes, it's random, but there shouldn't be multiple consoles anyways

	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonescanner(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	update_icon()
	RefreshParts()

/obj/machinery/clonescanner/RefreshParts()
	for(var/part in component_parts)
		var/obj/item/stock_parts/SP = part
		if(istype(SP))
			scanning_tier += SP.rating


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

/obj/machinery/clonescanner/relaymove(mob/user)
	if(user.stat)
		return
	remove(user)

/obj/machinery/clonescanner/proc/can_scan(mob/living/carbon/human/scanned)
	if(!scanned.dna || HAS_TRAIT(scanned, TRAIT_GENELESS))
		return SCANNER_MISC
	if(HAS_TRAIT(scanned, TRAIT_BADDNA) && scanning_tier < 4)
		return SCANNER_HUSKED
	if(NO_CLONESCAN in scanned.dna.species.species_traits)
		return SCANNER_UNCLONEABLE_SPECIES

	return TRUE

/obj/machinery/clonescanner/proc/scan(mob/living/carbon/human/scanned)
	var/datum/cloning_data/scan_result = new /datum/cloning_data

	scan_result.name = scanned.dna.real_name
	scan_result.mind = scanned.mind
	scan_result.genetic_info = scanned.dna.Clone()

	for(var/limb in scanned.dna.species.has_limbs)
		if(scanned.bodyparts_by_name[limb])
			var/obj/item/organ/external/active_limb = scanned.bodyparts_by_name[limb]
			scan_result.limbs[limb] = list(active_limb.brute_dam,
											active_limb.burn_dam,
											active_limb.status,
											FALSE)
		else
			scan_result.limbs[limb] = list(0, 0, 0, TRUE) //no damage if it's missing!

	for(var/organ in scanned.dna.species.has_organ)
		var/obj/item/organ/internal/active_organ = scanned.get_int_organ(scanned.dna.species.has_organ[organ]) //this is icky
		if(istype(active_organ))
			scan_result.organs[organ] = list(active_organ.damage,
											active_organ.status,
											FALSE)
		else
			scan_result.organs[organ] = list(0, 0, TRUE)

	last_scan = scan_result
	return scan_result

/obj/machinery/clonescanner/proc/insert(mob/living/carbon/human/inserted)
	if(!istype(inserted))
		return
	inserted.forceMove(src)
	occupant = inserted
	if(last_scan?.name != inserted.dna?.real_name)
		last_scan = null
	occupant.notify_ghost_cloning()

/obj/machinery/clonescanner/proc/remove(mob/living/carbon/human/removed)
	if(!istype(removed))
		return
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
