/// A datum to store the information gained by scanning a patient OR the fixes to be made to their body.
/datum/cloning_data
	/// The patient's name.
	var/name
	/// A reference to the patient's mind.
	var/mindUID

	/// The patient's external organs (limbs) and their data, stored as an associated list of lists.
	/// List format: limb = list(brute, burn, status, missing, name, max damage)
	var/list/limbs = list()

	/// The patient's internal organs and their data, stored as an associated list of lists.
	/// List format: organ = list(damage, status, missing, name, max damage, organ tag)
	var/list/organs = list()

	/// The patient's DNA
	var/datum/dna/genetic_info

//The cloning scanner itself.
/obj/machinery/clonescanner
	name = "cloning scanner"
	desc = "An advanced machine that thoroughly scans the current state of a cadaver for use in cloning."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "scanner_open"
	density = TRUE
	anchored = TRUE

	/// The linked cloning console.
	var/obj/machinery/computer/cloning/console
	/// The tier of scan we can perform. Tier 2 parts and up can scan husks - or a tier 4 scanner and tier 1 laser.
	var/scanning_tier
	/// The scanner's occupant.
	var/mob/living/carbon/human/occupant
	/// The scanner's latest scan result
	var/datum/cloning_data/last_scan
	/// Whether or not we've tried to scan the current patient
	var/has_scanned = FALSE

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
	scanning_tier = 0
	for(var/obj/item/stock_parts/scanning_module/SP in component_parts)
		scanning_tier += SP.rating

/obj/machinery/clonescanner/Destroy()
	if(console)
		console.scanner = null
	if(occupant)
		remove_mob()
	return ..()

/obj/machinery/clonescanner/MouseDrop_T(atom/movable/O, mob/user)
	if(!(ishuman(user) || issilicon(user)) || user.incapacitated())
		return
	if(!ishuman(O))
		return
	var/mob/living/carbon/human/H = O
	if(H.stat != DEAD)
		to_chat(user, "<span class='warning'>You don't think it'd be wise to scan a living being.</span>")
		return TRUE
	if(occupant)
		to_chat(user, "<span class='warning'>[src] is already occupied!</span>")
		return TRUE

	to_chat(user, "<span class='notice'>You put [H] into the cloning scanner.</span>")
	insert_mob(H)
	return TRUE

/obj/machinery/clonescanner/AltClick(mob/user)
	if(!occupant)
		return
	if(issilicon(user))
		remove_mob()
		return
	if(!Adjacent(user) || !ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	remove_mob()

/obj/machinery/clonescanner/relaymove(mob/user)
	if(user.stat)
		return
	remove_mob()

/obj/machinery/clonescanner/proc/try_scan(mob/living/carbon/human/scanned)
	if(!scanned)
		return

	has_scanned = TRUE

	if(console.selected_pod?.currently_cloning)
		return SCANNER_POD_IN_PROGRESS
	if(!scanned.dna || HAS_TRAIT(scanned, TRAIT_GENELESS))
		return SCANNER_MISC
	if(HAS_TRAIT(scanned, TRAIT_BADDNA) && scanning_tier < 4)
		return SCANNER_ABSORBED
	if(HAS_TRAIT(scanned, TRAIT_HUSK) && scanning_tier < 4)
		return SCANNER_HUSKED
	if(NO_CLONESCAN in scanned.dna.species.species_traits)
		return SCANNER_UNCLONEABLE_SPECIES
	if(!scanned.ckey || !scanned.client || IS_CHANGELING(scanned))
		return SCANNER_NO_SOUL
	if(scanned.suiciding || !scanned.get_int_organ(/obj/item/organ/internal/brain))
		return SCANNER_BRAIN_ISSUE

	return scan(scanned)

/obj/machinery/clonescanner/proc/scan(mob/living/carbon/human/scanned)
	var/datum/cloning_data/scan_result = new

	scan_result.name = scanned.dna.real_name
	scan_result.mindUID = scanned.mind.UID()
	scan_result.genetic_info = scanned.dna.Clone()

	for(var/limb in scanned.dna.species.has_limbs)
		if(scanned.bodyparts_by_name[limb])
			var/obj/item/organ/external/active_limb = scanned.bodyparts_by_name[limb]
			scan_result.limbs[limb] = list(active_limb.brute_dam,
											active_limb.burn_dam,
											active_limb.status,
											FALSE,
											active_limb.name,
											active_limb.max_damage)
		else
			scan_result.limbs[limb] = list(0, 0, 0, TRUE, scanned.dna.species.has_limbs[limb]["descriptor"], 0) //no damage if it's missing!

	for(var/organ in scanned.dna.species.has_organ)
		var/obj/item/organ/internal/active_organ = scanned.get_int_organ(scanned.dna.species.has_organ[organ]) //this is icky
		if(!istype(active_organ))
			scan_result.organs[organ] = list(0, 0, TRUE, organ, 0, organ)
			continue

		scan_result.organs[organ] = list(active_organ.damage,
										active_organ.status,
										FALSE,
										active_organ.name,
										active_organ.max_damage,
										active_organ.organ_tag)

	last_scan = scan_result
	return scan_result

/obj/machinery/clonescanner/proc/insert_mob(mob/living/carbon/human/inserted)
	if(!istype(inserted))
		return
	inserted.forceMove(src)
	occupant = inserted
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/clonescanner/proc/remove_mob()
	if(!occupant)
		return
	occupant.forceMove(get_turf(loc))
	occupant = null
	update_scan_status()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/clonescanner/proc/update_scan_status()
	last_scan = null
	has_scanned = FALSE

/obj/machinery/clonescanner/update_icon_state()
	if(panel_open)
		icon_state = "scanner" + (occupant ? "" : "_open") + "_maintenance"
		return
	if(stat & NOPOWER)
		icon_state = "scanner"
		return
	if(!occupant)
		icon_state = "scanner_open"
		return
	icon_state = "scanner_occupied"
	return


/obj/machinery/clonescanner/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)

/obj/machinery/clonescanner/force_eject_occupant(mob/target)
	remove_mob()

/obj/machinery/clonescanner/crowbar_act(mob/user, obj/item/I)
	if(!panel_open)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	default_deconstruction_crowbar(user, I)

/obj/machinery/clonescanner/screwdriver_act(mob/user, obj/item/I)
	if(occupant)
		to_chat(user, "<span class='notice'>The maintenance panel is locked.</span>")
		return TRUE
	if(default_deconstruction_screwdriver(user, "[icon_state]_maintenance", "[initial(icon_state)]", I))
		return TRUE
