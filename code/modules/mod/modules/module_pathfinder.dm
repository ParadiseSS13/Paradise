///Pathfinder - Can fly the suit from a long distance to an implant installed in someone.
/obj/item/mod/module/pathfinder
	name = "MOD pathfinder module"
	desc = "This module, brought to you by Paizo Productions, has two components. \
		The first component is a series of thrusters and a computerized location subroutine installed into the \
		very control unit of the suit, allowing it flight at highway speeds using the suit's access locks \
		to navigate through the station, and to be able to locate the second part of the system; \
		a pathfinding implant installed into the base of the user's spine, \
		broadcasting their location to the suit and allowing them to recall it to their person at any time. \
		The implant is stored in the module and needs to be injected in a human to function. \
		Paizo Productions swears up and down there's airbrakes."
	icon_state = "pathfinder"
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 200
	incompatible_modules = list(/obj/item/mod/module/pathfinder)
	/// The pathfinding implant.
	var/obj/item/bio_chip/mod/implant

/obj/item/mod/module/pathfinder/Initialize(mapload)
	. = ..()
	implant = new(src)

/obj/item/mod/module/pathfinder/Destroy()
	implant = null
	return ..()

/obj/item/mod/module/pathfinder/examine(mob/user)
	. = ..()
	if(implant)
		. += "<span class='notice'>Use it on a human to implant them.</span>"
	else
		. += "<span class='warning'>The implant is missing.</span>"

/obj/item/mod/module/pathfinder/attack__legacy__attackchain(mob/living/target, mob/living/user, params)
	if(!ishuman(target) || !implant)
		return
	if(!do_after(user, 1.5 SECONDS, target = target))
		return
	if(!implant.implant(target, user))
		to_chat(user, "<span class='warning'>Unable to implant [target]!</span>")
		return
	if(target == user)
		to_chat(user, "<span class='notice'>You implant yourself with [implant].</span>")
	else
		target.visible_message("<span class='notice'>[user] implants [target].</span>", "<span class='notice'>[user] implants you with [implant].</span>")
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
	icon_state = "pathfinder_empty"
	implant = null

/obj/item/mod/module/pathfinder/proc/attach(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.get_item_by_slot(ITEM_SLOT_BACK) && !human_user.drop_item_to_ground(human_user.get_item_by_slot(ITEM_SLOT_BACK)))
		return
	if(!human_user.equip_to_slot_if_possible(mod, ITEM_SLOT_BACK, disable_warning = TRUE))
		return
	mod.quick_deploy(user)
	human_user.update_action_buttons(TRUE)
	playsound(mod, 'sound/machines/ping.ogg', 50, TRUE)
	drain_power(use_power_cost)

/obj/item/bio_chip/mod
	name = "MOD pathfinder implant"
	desc = "Lets you recall a MODsuit to you at any time."
	implant_data = /datum/implant_fluff/pathfinder
	actions_types = list(/datum/action/item_action/mod_recall)
	/// The pathfinder module we are linked to.
	var/obj/item/mod/module/pathfinder/module
	/// The jet icon we apply to the MOD.
	var/image/jet_icon
	/// List of turfs through which a mod 'steps' to reach the waypoint
	var/list/path = list()
	/// The target turf we are after
	var/turf/target
	/// How many times have we tried to move?
	var/tries = 0


/obj/item/bio_chip/mod/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/mod/module/pathfinder))
		return INITIALIZE_HINT_QDEL
	module = loc
	jet_icon = image(icon = 'icons/obj/clothing/modsuit/mod_modules.dmi', icon_state = "mod_jet", layer = LOW_ITEM_LAYER)

/obj/item/bio_chip/mod/Destroy()
	if(path)
		end_recall(successful = FALSE)
	module = null
	jet_icon = null
	return ..()

/obj/item/bio_chip/mod/proc/recall()
	target = get_turf(imp_in)
	if(!module?.mod)
		to_chat(imp_in, "<span class='warning'>Module is not attached to a suit!</span>")
		return FALSE
	if(module.mod.open)
		to_chat(imp_in, "<span class='warning'>Suit is open!</span>")
		return FALSE
	if(length(path))
		to_chat(imp_in, "<span class='warning'>Suit is already on the way!</span>")
		return FALSE
	if(ismob(get_atom_on_turf(module.mod)))
		to_chat(imp_in, "<span class='warning'>Suit is being worn!</span>")
		return FALSE
	if(module.mod.loc != get_turf(module.mod))
		to_chat(imp_in, "<span class='warning'>Suit contained inside of something!</span>")
		return FALSE
	if(module.z != z || get_dist(imp_in, module.mod) > 150)
		to_chat(imp_in, "<span class='warning'>Suit is too far away!</span>")
		return FALSE
	if(!ishuman(imp_in)) //Need to be specific
		to_chat(imp_in, "<span class='warning'>The implant does not recognize you as a known species!</span>")
		return FALSE
	var/mob/living/carbon/human/H = imp_in
	set_path(get_path_to(module.mod, target, 150, access = H?.wear_id.GetAccess(), simulated_only = FALSE)) //Yes, science proves jetpacks work in space. More at 11.
	if(!length(path)) //Cannot reach target. Give up and announce the issue.
		to_chat(H, "<span class='warning'>No viable path found!</span>")
		return FALSE
	to_chat(H, "<span class='notice'>Suit on route!</span>")
	animate(module.mod, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)
	module.mod.add_overlay(jet_icon)
	RegisterSignal(module.mod, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	mod_move(target)
	return TRUE

/obj/item/bio_chip/mod/proc/set_path(list/newpath)
	if(newpath == null)
		end_recall(FALSE)
	path = newpath ? newpath : list()

/obj/item/bio_chip/mod/proc/end_recall(successful = TRUE)
	if(!module?.mod)
		return
	module.mod.cut_overlay(jet_icon)
	module.mod.transform = matrix()
	UnregisterSignal(module.mod, COMSIG_MOVABLE_MOVED)
	if(!successful)
		to_chat(imp_in, "<span class='warning'>Lost connection to suit!</span>")
		path = list() //Stopping endless end_recall with luck.

/obj/item/bio_chip/mod/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	var/matrix/mod_matrix = matrix()
	mod_matrix.Turn(get_angle(source, imp_in))
	source.transform = mod_matrix

/obj/item/bio_chip/mod/proc/mod_move(dest)
	dest = get_turf(dest) //We must always compare turfs, so get the turf of the dest var if dest was originally something else.
	if(get_turf(module.mod) == dest) //We have arrived, no need to move again.
		for(var/mob/living/carbon/human/H in range(1, module.mod))
			if(H == imp_in)
				module.attach(imp_in)
				end_recall()
				return TRUE
		end_recall(FALSE)
		return FALSE


	if(!dest || !path || !length(path)) //A-star failed or a path/destination was not set.
		set_path(null)
		return FALSE

	var/turf/last_node = get_turf(path[length(path)]) //This is the turf at the end of the path, it should be equal to dest.
	if(dest != last_node) //The path should lead us to our given destination. If this is not true, we must stop.
		set_path(null)
		return FALSE

	var/step_count = 3 //Temp speed for now

	if(step_count >= 1 && tries < 5)
		for(var/step_number in 1 to step_count)
			// Hopefully this wont fill the buckets too much
			addtimer(CALLBACK(src, PROC_REF(mod_step)), 2 * (step_number - 1))
	if(tries >= 5)
		set_path(null)
	var/target = get_turf(imp_in)
	var/mob/living/carbon/human/H = imp_in
	set_path(get_path_to(module.mod, target, 150, access = H?.wear_id.GetAccess(), simulated_only = FALSE)) //Yes, science proves jetpacks work in space. More at 11.
	addtimer(CALLBACK(src, PROC_REF(mod_move), target), 6) //I'll value this properly soon

	return TRUE

/obj/item/bio_chip/mod/proc/mod_step() //Step,increase tries if failed
	if(!path || !length(path))
		return FALSE
	for(var/obj/machinery/door/D in range(2, module.mod))
		if(D.operating || D.emagged)
			continue
		if(D.requiresID() && D.allowed(imp_in))
			if(D.density)
				D.open()


	if(!step_towards(module.mod, path[1]))
		tries++
		return FALSE

	increment_path()
	tries = 0
	return TRUE

/obj/item/bio_chip/mod/proc/increment_path()
	if(!path || !length(path))
		return
	path.Cut(1, 2)

/datum/action/item_action/mod_recall
	name = "Recall MOD"
	desc = "Recall a MODsuit anyplace, anytime."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_mod.dmi'
	button_icon_state = "recall"
	background_icon = 'icons/mob/actions/actions_mod.dmi'
	background_icon_state = "bg_mod"
	/// The cooldown for the recall.
	COOLDOWN_DECLARE(recall_cooldown)

/datum/action/item_action/mod_recall/New(Target)
	..()
	if(!istype(Target, /obj/item/bio_chip/mod))
		qdel(src)
		return

/datum/action/item_action/mod_recall/Trigger(left_click)
	. = ..()
	if(!.)
		return
	var/obj/item/bio_chip/mod/implant = target
	if(!COOLDOWN_FINISHED(src, recall_cooldown))
		to_chat(usr, "<span class='warning'>On cooldown!</span>")
		return
	if(implant.recall())
		COOLDOWN_START(src, recall_cooldown, 15 SECONDS)
