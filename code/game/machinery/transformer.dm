/obj/machinery/transformer
	name = "Automatic Robotic Factory 5000"
	desc = "A large metallic machine with an entrance and an exit. A sign on the side reads, 'human go in, robot come out'. Has a cooldown between each use."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-b1"
	layer = MOB_LAYER+1 // Overhead
	anchored = TRUE
	density = TRUE
	/// TRUE if the factory can transform dead mobs.
	var/transform_dead = TRUE
	/// TRUE if the mob can be standing and still be transformed.
	var/transform_standing = TRUE
	/// Cooldown between each transformation, in deciseconds.
	var/cooldown_duration = 30 SECONDS
	/// If the factory is currently on cooldown from its last transformation.
	var/is_on_cooldown = FALSE
	/// The type of cell that newly created borgs get.
	var/robot_cell_type = /obj/item/stock_parts/cell/high/plus
	/// The direction that mobs must moving in to get transformed.
	var/acceptdir = EAST
	/// The AI who placed this factory.
	var/mob/living/silicon/ai/masterAI

/obj/machinery/transformer/Initialize(mapload, mob/living/silicon/ai/_ai = null)
	. = ..()
	if(_ai)
		masterAI = _ai
	initialize_belts()

/// Used to create all of the belts the transformer will be using. All belts should be pushing `WEST`.
/obj/machinery/transformer/proc/initialize_belts()
	var/turf/T = get_turf(src)
	if(!T)
		return

	// Belt under the factory.
	new /obj/machinery/conveyor/auto(T, WEST)

	// Get the turf 1 tile to the EAST.
	var/turf/east = locate(T.x + 1, T.y, T.z)
	if(isfloorturf(east))
		new /obj/machinery/conveyor/auto(east, WEST)

	// Get the turf 1 tile to the WEST.
	var/turf/west = locate(T.x - 1, T.y, T.z)
	if(isfloorturf(west))
		new /obj/machinery/conveyor/auto(west, WEST)

/obj/machinery/transformer/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/transformer/update_icon_state()
	if(is_on_cooldown || stat & (BROKEN|NOPOWER))
		icon_state = "grinder-b0"
	else
		icon_state = initial(icon_state)

/obj/machinery/transformer/setDir(newdir)
	. = ..()
	var/obj/machinery/conveyor/C = locate() in loc
	C.setDir(newdir)
	acceptdir = turn(newdir, 180)

/// Resets `is_on_cooldown` to `FALSE` and updates our icon. Used in a callback after the transformer does a transformation.
/obj/machinery/transformer/proc/reset_cooldown()
	is_on_cooldown = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/transformer/Bumped(atom/movable/AM)
	// They have to be human to be transformed.
	if(is_on_cooldown || !ishuman(AM))
		return

	var/mob/living/carbon/human/H = AM
	var/move_dir = get_dir(loc, H.loc)

	if((transform_standing || IS_HORIZONTAL(H)) && move_dir == acceptdir)
		H.forceMove(drop_location())
		do_transform(H)

/// Transforms a human mob into a cyborg, connects them to the malf AI which placed the factory.
/obj/machinery/transformer/proc/do_transform(mob/living/carbon/human/H)
	if(is_on_cooldown || stat & (BROKEN|NOPOWER))
		return

	if(!transform_dead && H.stat == DEAD)
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return

	playsound(loc, 'sound/items/welder.ogg', 50, 1)
	use_power(5000) // Use a lot of power.

	// Activate the cooldown
	is_on_cooldown = TRUE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), cooldown_duration)
	addtimer(CALLBACK(null, GLOBAL_PROC_REF(playsound), loc, 'sound/machines/ping.ogg', 50, 0), 3 SECONDS)

	H.emote("scream")
	if(!masterAI) // If the factory was placed via admin spawning or other means, it wont have an owner_AI.
		var/mob/living/silicon/robot/R = H.Robotize(robot_cell_type)
		R.emagged = TRUE
		return

	var/mob/living/silicon/robot/R = H.Robotize(robot_cell_type, FALSE, masterAI)
	R.emagged = TRUE
	if(R.mind && !R.client && !R.grab_ghost()) // Make sure this is an actual player first and not just a humanized monkey or something.
		message_admins("[key_name_admin(R)] was just transformed by a borg factory, but they were SSD. Polling ghosts for a replacement.")
		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a malfunctioning cyborg?", ROLE_TRAITOR, poll_time = 15 SECONDS)
		if(!length(candidates) || QDELETED(R))
			return
		var/mob/dead/observer/O = pick(candidates)
		R.key = O.key

/obj/machinery/transformer/mime
	name = "Mimetech Greyscaler"
	desc = "Turns anything placed inside black and white."

/obj/machinery/transformer/mime/Bumped(atom/movable/AM)
	if(is_on_cooldown)
		return

	// Crossed didn't like people lying down.
	if(istype(AM))
		AM.forceMove(drop_location())
		do_transform_mime(AM)
	else
		to_chat(AM, "Only items can be greyscaled.")
		return

/obj/machinery/transformer/proc/do_transform_mime(obj/item/I)
	if(is_on_cooldown || stat & (BROKEN|NOPOWER))
		return

	playsound(loc, 'sound/items/welder.ogg', 50, 1)
	use_power(5000) // Use a lot of power.

	var/icon/newicon = new(I.icon, I.icon_state)
	newicon.GrayScale()
	I.icon = newicon

	// Activate the cooldown
	is_on_cooldown = TRUE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), cooldown_duration)

/obj/machinery/transformer/xray
	name = "Automatic X-Ray 5000"
	desc = "A large metalic machine with an entrance and an exit. A sign on the side reads, 'backpack go in, backpack come out', 'human go in, irradiated human come out'."
	acceptdir = WEST

/obj/machinery/transformer/xray/initialize_belts()
	var/turf/T = get_turf(src)
	if(T)
		// This handles the belt under the transformer and 1 tile to the left and right.
		. = ..()

		// Get the turf 2 tiles to the EAST.
		var/turf/east2 = locate(T.x + 2, T.y, T.z)
		if(isfloorturf(east2))
			new /obj/machinery/conveyor/auto(east2, EAST)

		// Get the turf 2 tiles to the WEST.
		var/turf/west2 = locate(T.x - 2, T.y, T.z)
		if(isfloorturf(west2))
			new /obj/machinery/conveyor/auto(west2, EAST)

/obj/machinery/transformer/xray/power_change()
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/transformer/xray/update_icon_state()
	if(stat & (BROKEN|NOPOWER))
		icon_state = "grinder-b0"
	else
		icon_state = initial(icon_state)

/obj/machinery/transformer/xray/Bumped(atom/movable/AM)
	if(is_on_cooldown)
		return

	// Crossed didn't like people lying down.
	if(ishuman(AM))
		// Only humans can enter from the west side, while lying down.
		var/mob/living/carbon/human/H = AM
		var/move_dir = get_dir(loc, H.loc)

		if(IS_HORIZONTAL(H) && move_dir == acceptdir)
			H.forceMove(drop_location())
			irradiate(H)

	else if(istype(AM))
		AM.forceMove(drop_location())
		scan(AM)

/obj/machinery/transformer/xray/proc/irradiate(mob/living/carbon/human/H)
	if(stat & (BROKEN|NOPOWER))
		return

	flick("grinder-b0",src)
	playsound(loc, 'sound/effects/alert.ogg', 50, 0)
	sleep(5)
	H.rad_act(rand(150, 200))
	if(prob(5))
		if(prob(75))
			randmutb(H) // Applies bad mutation
			domutcheck(H, MUTCHK_FORCED)
		else
			randmutg(H) // Applies good mutation
			domutcheck(H, MUTCHK_FORCED)


/obj/machinery/transformer/xray/proc/scan(obj/item/I)
	if(scan_rec(I))
		playsound(loc, 'sound/effects/alert.ogg', 50, 0)
		flick("grinder-b0",src)
	else
		playsound(loc, 'sound/machines/ping.ogg', 50, 0)
		sleep(30)

/obj/machinery/transformer/xray/proc/scan_rec(obj/item/I)
	if(istype(I, /obj/item/gun))
		return TRUE
	if(istype(I, /obj/item/transfer_valve))
		return TRUE
	if(istype(I, /obj/item/kitchen/knife))
		return TRUE
	if(istype(I, /obj/item/grenade/plastic/c4))
		return TRUE
	if(istype(I, /obj/item/melee))
		return TRUE
	for(var/obj/item/C in I.contents)
		if(scan_rec(C))
			return TRUE
	return FALSE

/obj/machinery/transformer/equipper
	name = "Auto-equipper 9000"
	desc = "Either in employ of people who cannot dress themselves, or Wallace and Gromit."
	var/selected_outfit = /datum/outfit/job/assistant
	var/prestrip = TRUE

/obj/machinery/transformer/equipper/do_transform(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!ispath(selected_outfit, /datum/outfit))
		to_chat(H, "<span class='warning'>This equipper is not properly configured! 'selected_outfit': '[selected_outfit]'</span>")
		return

	if(prestrip)
		for(var/obj/item/I in H)
			if(istype(I, /obj/item/implant))
				continue
			qdel(I)

	H.equipOutfit(selected_outfit)
	H.dna.species.after_equip_job(null, H)

/obj/machinery/transformer/transmogrifier
	name = "species transmogrifier"
	desc = "As promoted in Calvin & Hobbes!"
	var/datum/species/target_species = /datum/species/human


/obj/machinery/transformer/transmogrifier/do_transform(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!ispath(target_species))
		to_chat(H, "<span class='warning'>'[target_species]' is not a valid species!</span>")
		return
	H.set_species(target_species)


/obj/machinery/transformer/dnascrambler
	name = "genetic scrambler"
	desc = "Step right in and become a new you!"


/obj/machinery/transformer/dnascrambler/do_transform(mob/living/carbon/human/H)
	if(!istype(H))
		return

	scramble(1, H, 100)
	H.generate_name()
	H.sync_organ_dna(assimilate = 1)
	H.update_body()
	H.reset_hair()
	H.dna.ResetUIFrom(H)


/obj/machinery/transformer/gene_applier
	name = "genetic blueprint applier"
	desc = "Here begin the clone wars. Upload a template by using a genetics disk on this machine."
	var/datum/dna/template
	var/locked = FALSE // For admins sealing the deal

/obj/machinery/transformer/gene_applier/do_transform(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(!istype(template))
		to_chat(H, "<span class='warning'>No genetic template configured!</span>")
		return
	var/prev_ue = H.dna.unique_enzymes
	H.set_species(template.species.type)
	H.dna = template.Clone()
	H.real_name = template.real_name
	H.sync_organ_dna(assimilate = 0, old_ue = prev_ue)
	H.UpdateAppearance()
	domutcheck(H, MUTCHK_FORCED)
	H.update_mutations()

/obj/machinery/transformer/gene_applier/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/disk/data))
		if(locked)
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return FALSE
		var/obj/item/disk/data/D = I
		if(!D.buf)
			to_chat(user, "<span class='warning'>Error: No data found.</span>")
			return FALSE
		template = D.buf.dna.Clone()
		to_chat(user, "<span class='notice'>Upload of gene template for '[template.real_name]' complete!</span>")
		return TRUE
	else
		return ..()
