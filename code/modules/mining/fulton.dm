GLOBAL_LIST_EMPTY(total_extraction_beacons)

/obj/item/extraction_pack
	name = "fulton extraction pack"
	desc = "A balloon that can be used to extract equipment or personnel to a Fulton Recovery Beacon. Anything not bolted down can be moved. Link the pack to a beacon by using the pack in hand."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_pack"
	flags = NOBLUDGEON
	new_attack_chain = TRUE
	var/obj/structure/extraction_point/beacon
	var/list/beacon_networks = list("station")
	var/uses_left = 3
	var/can_use_indoors
	var/safe_for_living_creatures = TRUE
	var/max_force_fulton = MOVE_FORCE_STRONG

/obj/item/extraction_pack/examine(mob/user)
	. = ..()
	. += "It has [uses_left] use\s remaining."

/obj/item/extraction_pack/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	var/list/possible_beacons = list()
	for(var/B in GLOB.total_extraction_beacons)
		var/obj/structure/extraction_point/EP = B
		if(EP.beacon_network in beacon_networks)
			possible_beacons += EP

	if(!length(possible_beacons))
		to_chat(user, "There are no extraction beacons in existence!")
		return FINISH_ATTACK

	else
		var/A

		A = tgui_input_list(user, "Select a beacon to connect to", "Balloon Extraction Pack", possible_beacons)

		if(!A)
			return FINISH_ATTACK
		beacon = A
		to_chat(user, "You link the extraction pack to the beacon system.")
		return FINISH_ATTACK

/obj/item/extraction_pack/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	var/atom/movable/A = target
	if(!istype(A))
		return ITEM_INTERACT_COMPLETE

	playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), TRUE, -1)
	user.do_attack_animation(A)
	user.changeNext_move(CLICK_CD_MELEE)
	if(!beacon)
		to_chat(user, "<span class='warning'>[src] is not linked to a beacon, and cannot be used!</span>")
		return ITEM_INTERACT_COMPLETE
	if(!can_use_indoors)
		var/area/area = get_area(A)
		if(!area.outdoors)
			to_chat(user, "<span class='warning'>[src] can only be used on things that are outdoors!</span>")
			return ITEM_INTERACT_COMPLETE
		if(area.tele_proof || !is_teleport_allowed(A.z))
			to_chat(user, "<span class='warning'>Bluespace distortions prevent the fulton from inflating!</span>")
			return ITEM_INTERACT_COMPLETE
	if(!istype(A))
		return ITEM_INTERACT_COMPLETE
	else
		if(!safe_for_living_creatures && check_for_living_mobs(A))
			to_chat(user, "<span class='warning'>[src] is not safe for use with living creatures, they wouldn't survive the trip back!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!isturf(A.loc)) // no extracting stuff inside other stuff
			return ITEM_INTERACT_COMPLETE
		if(A.anchored || (A.move_resist > max_force_fulton))
			return ITEM_INTERACT_COMPLETE
		if(ismegafauna(A))
			to_chat(user, "<span class='warning'>[src] is too heavy to retrieve!</span>")
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "<span class='notice'>You start attaching the pack to [A]...</span>")
		if(do_after(user, 50, target = A))
			to_chat(user, "<span class='notice'>You attach the pack to [A] and activate it.</span>")
			user.equip_to_slot_if_possible(src, ITEM_SLOT_IN_BACKPACK, FALSE, TRUE)
			uses_left--
			if(uses_left <= 0)
				user.drop_item(src)
				forceMove(A)
			var/mutable_appearance/balloon
			var/mutable_appearance/balloon2
			var/mutable_appearance/balloon3
			if(isliving(A))
				var/mob/living/M = A
				M.Weaken(32 SECONDS) // Keep them from moving during the duration of the extraction
				unbuckle_mob(M, force = TRUE) // Unbuckle them to prevent anchoring problems
			else
				A.anchored = TRUE
				A.density = FALSE
			var/obj/effect/extraction_holder/holder_obj = new(A.loc)
			holder_obj.appearance = A.appearance
			A.forceMove(holder_obj)
			balloon2 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_expand")
			balloon2.pixel_y = 10
			balloon2.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.add_overlay(balloon2)
			sleep(4)
			balloon = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_balloon")
			balloon.pixel_y = 10
			balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.cut_overlay(balloon2)
			holder_obj.add_overlay(balloon)
			playsound(holder_obj.loc, 'sound/items/fultext_deploy.ogg', 50, TRUE, -3)
			animate(holder_obj, pixel_z = 10, time = 20)
			sleep(20)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			playsound(holder_obj.loc, 'sound/items/fultext_launch.ogg', 50, TRUE, -3)
			animate(holder_obj, pixel_z = 1000, time = 30)
			if(ishuman(A))
				var/mob/living/carbon/human/L = A
				L.SetParalysis(0)
				L.SetDrowsy(0)
				L.SetSleeping(0)
			sleep(30)
			var/list/flooring_near_beacon = list()
			for(var/turf/floor in orange(1, beacon))
				if(floor.density)
					continue
				flooring_near_beacon += floor
			if(!length(flooring_near_beacon))
				to_chat(user, "<span class='notice'>Your fulton pack slowly brings you back down, it seems that the linked beacon has stopped functioning!</span>")
				flooring_near_beacon = get_turf(user)
			holder_obj.forceMove(pick(flooring_near_beacon))
			animate(holder_obj, pixel_z = 10, time = 50)
			sleep(50)
			animate(holder_obj, pixel_z = 15, time = 10)
			sleep(10)
			animate(holder_obj, pixel_z = 10, time = 10)
			sleep(10)
			balloon3 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_retract")
			balloon3.pixel_y = 10
			balloon3.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
			holder_obj.cut_overlay(balloon)
			holder_obj.add_overlay(balloon3)
			sleep(4)
			holder_obj.cut_overlay(balloon3)
			A.anchored = FALSE // An item has to be unanchored to be extracted in the first place.
			A.density = initial(A.density)
			animate(holder_obj, pixel_z = 0, time = 5)
			sleep(5)
			A.forceMove(holder_obj.loc)
			qdel(holder_obj)
			if(uses_left <= 0)
				qdel(src)

		return ITEM_INTERACT_COMPLETE

/obj/item/fulton_core
	name = "extraction beacon assembly kit"
	desc = "When built, emits a signal which fulton recovery devices can lock onto. Activate in hand to unfold into a beacon."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "folded_extraction"

/obj/item/fulton_core/attack_self__legacy__attackchain(mob/user)
	if(do_after(user, 15, target = user) && !QDELETED(src))
		new /obj/structure/extraction_point(get_turf(user))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
		qdel(src)

/obj/structure/extraction_point
	name = "fulton recovery beacon"
	desc = "A beacon for the fulton recovery system. Activate a pack in your hand to link it to a beacon."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_point"
	anchored = TRUE
	var/beacon_network = "station"

/obj/structure/extraction_point/Initialize(mapload)
	. = ..()
	name += " ([rand(100,999)]) ([get_location_name(src)])"
	GLOB.total_extraction_beacons += src
	update_icon(UPDATE_OVERLAYS)

/obj/structure/extraction_point/Destroy()
	GLOB.total_extraction_beacons -= src
	return ..()

/obj/effect/extraction_holder
	name = "extraction holder"
	desc = "You shouldnt see this."
	var/atom/movable/stored_obj

/obj/effect/extraction_holder/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_EFFECT_CAN_TELEPORT, ROUNDSTART_TRAIT)

/obj/item/extraction_pack/proc/check_for_living_mobs(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		if(L.stat != DEAD)
			return TRUE
	for(var/thing in A.GetAllContents())
		if(isliving(A))
			var/mob/living/L = A
			if(L.stat != DEAD)
				return TRUE
	return FALSE

/obj/structure/extraction_point/update_overlays()
	. = ..()
	underlays += emissive_appearance(icon, "[icon_state]_light", src, alpha = src.alpha)

/obj/effect/extraction_holder/singularity_act()
	return

/obj/effect/extraction_holder/singularity_pull()
	return
