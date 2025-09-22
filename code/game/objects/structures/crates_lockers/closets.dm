/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "generic"
	density = TRUE
	max_integrity = 200
	integrity_failure = 50
	armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 0, BOMB = 10, RAD = 0, FIRE = 70, ACID = 60)
	var/icon_closed
	var/icon_opened
	/// Overwrites icon_state for the opened door sprite. Only necessary if the opened door sprite has a different name than the icon_state.
	var/opened_door_sprite
	/// Overwrites icon_state for the closed door sprite. Only necessary if the closed door sprite has a different name than the icon_state.
	var/closed_door_sprite
	/// Added to initial(icon_state) if not null. Used for IC customization, e.g. when painting cardboard boxes.
	var/custom_skin
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	var/large = TRUE
	var/can_be_emaged = FALSE
	var/wall_mounted //never solid (You can always pass over it)
	var/lastbang
	var/open_sound = 'sound/machines/closet_open.ogg'
	var/close_sound = 'sound/machines/closet_close.ogg'
	var/open_sound_volume = 35
	var/close_sound_volume = 50
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/material_drop = /obj/item/stack/sheet/metal
	var/material_drop_amount = 2
	var/transparent
	var/secure = FALSE

	/// The overlay for the closet's door
	var/obj/effect/overlay/closet_door/door_obj
	/// Whether or not this door is being animated
	var/is_animating_door = FALSE
	/// Vertical squish of the door
	var/door_anim_squish = 0.30
	/// The maximum angle the door will be drawn at
	var/door_anim_angle = 136
	/// X position of the closet door hinge
	var/door_hinge_x = -6.5
	/// Amount of time it takes for the door animation to play
	var/door_anim_time = 2.0 // set to 0 to make the door not animate at all
	/// Whether this closet uses a door overlay at all. If `FALSE`, it'll switch to a system where the entire icon_state is replaced with `[icon_state]_open` instead.
	var/enable_door_overlay = TRUE
	/// Whether this closet uses a door overlay for when it is opened
	var/has_opened_overlay = TRUE
	/// Whether this closet uses a door overlay for when it is closed
	var/has_closed_overlay = TRUE

// Please dont override this unless you absolutely have to
/obj/structure/closet/Initialize(mapload)
	. = ..()
	if(mapload && !opened)
		// Youre probably asking, why is this a 0 seconds timer AA?
		// Well, I will tell you. One day, all /obj/effect/spawner will use Initialize
		// This includes maint loot spawners. The problem with that is if a closet loads before a spawner,
		// the loot will just be in a pile. Adding a timer with 0 delay will cause it to only take in contents once the MC has loaded,
		// therefore solving the issue on mapload. During rounds, everything will happen as normal
		END_OF_TICK(CALLBACK(src, PROC_REF(take_contents)))
	populate_contents() // Spawn all its stuff
	update_icon() // Set it to the right icon if needed

/obj/structure/closet/update_icon()
	. = ..()
	if(!enable_door_overlay)
		if(opened)
			icon_state = "[initial(icon_state)][custom_skin]_open"
		else
			icon_state = "[initial(icon_state)][custom_skin]"

/obj/structure/closet/proc/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(enable_door_overlay && !is_animating_door)
		if(opened && has_opened_overlay)
			var/mutable_appearance/door_overlay = mutable_appearance(icon, "[opened_door_sprite || icon_state]_opened", alpha = src.alpha)
			. += door_overlay
			door_overlay.overlays += emissive_blocker(door_overlay.icon, door_overlay.icon_state, alpha = door_overlay.alpha) // If we don't do this the door doesn't block emissives and it looks weird.
		else if(!opened && has_closed_overlay)
			. += "[closed_door_sprite || icon_state]_closed"

	if(opened)
		return

	if(welded)
		. += "welded"

	if(broken || !secure || is_animating_door)
		return

	//Overlay is similar enough for both that we can use the same mask for both
	. += emissive_appearance(icon, "locked", alpha = src.alpha)
	. += locked ? "locked" : "unlocked"

/// Animates the closet door opening and closing
/obj/structure/closet/proc/animate_door(closing = FALSE)
	if(!door_anim_time)
		return
	if(!door_obj)
		door_obj = new
	var/default_door_icon = "[closed_door_sprite || icon_state]_closed"
	vis_contents += door_obj
	door_obj.icon = icon
	door_obj.icon_state = default_door_icon
	is_animating_door = TRUE
	var/num_steps = door_anim_time / world.tick_lag

	for(var/step in 0 to num_steps)
		var/angle = door_anim_angle * (closing ? 1 - (step / num_steps) : (step / num_steps))
		var/matrix/door_transform = get_door_transform(angle)
		var/door_state
		var/door_layer

		if(angle >= 90)
			door_state = "[opened_door_sprite || icon_state]_back"
			door_layer = FLOAT_LAYER
		else
			door_state = "[closed_door_sprite || icon_state]_closed"
			door_layer = ABOVE_MOB_LAYER

		if(step == 0)
			door_obj.transform = door_transform
			door_obj.icon_state = door_state
			door_obj.layer = door_layer
		else if(step == 1)
			animate(door_obj, transform = door_transform, icon_state = door_state, layer = door_layer, time = world.tick_lag, flags = ANIMATION_END_NOW)
		else
			animate(transform = door_transform, icon_state = door_state, layer = door_layer, time = world.tick_lag)
	addtimer(CALLBACK(src, PROC_REF(end_door_animation)), door_anim_time, TIMER_UNIQUE|TIMER_OVERRIDE)

/// Ends the door animation and removes the animated overlay
/obj/structure/closet/proc/end_door_animation()
	is_animating_door = FALSE
	vis_contents -= door_obj
	update_icon()
	COMPILE_OVERLAYS(src)

/// Calculates the matrix to be applied to the animated door overlay
/obj/structure/closet/proc/get_door_transform(angle)
	var/matrix/door_matrix = matrix()
	door_matrix.Translate(-door_hinge_x, 0)
	door_matrix.Multiply(matrix(cos(angle), 0, 0, -sin(angle) * door_anim_squish, 1, 0))
	door_matrix.Translate(door_hinge_x, 0)
	return door_matrix

// Override this to spawn your things in. This lets you use probabilities, and also doesnt cause init overrides
/obj/structure/closet/proc/populate_contents()
	return

// This is called on Initialize to add contents on the tile
/obj/structure/closet/proc/take_contents()
	var/itemcount = 0
	for(var/obj/item/I in loc)
		if(I.density || I.anchored || I == src) continue
		I.forceMove(src)
		// Ensure the storage cap is respected
		if(++itemcount >= storage_capacity)
			break

// Fix for #383 - C4 deleting fridges with corpses
/obj/structure/closet/Destroy(force)
	if(!force)
		dump_contents()
	QDEL_NULL(door_obj)
	return ..()

/obj/structure/closet/CanPass(atom/movable/mover, border_dir)
	if(wall_mounted)
		return TRUE
	return (!density)

/obj/structure/closet/proc/can_open()
	if(welded)
		return FALSE
	return TRUE

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src && closet.anchored != 1)
			return FALSE
	for(var/mob/living/simple_animal/hostile/megafauna/M in get_turf(src))
		return FALSE
	return TRUE

/obj/structure/closet/proc/dump_contents()
	var/turf/T = get_turf(src)
	for(var/mob/AM1 in src) //Does the same as below but removes the mobs first to avoid forcing players to step on items in the locker (e.g. soap) when opened.
		AM1.forceMove(T)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM1, dir)
	for(var/atom/movable/AM2 in src)
		AM2.forceMove(T)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM2, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/extinguish_light(force)
	for(var/atom/A in contents)
		A.extinguish_light(force)

/obj/structure/closet/proc/open(mob/user)
	if(!can_open())
		return
	if(opened)
		return
	welded = FALSE
	locked = FALSE
	playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	opened = TRUE
	density = FALSE
	dump_contents()
	if(enable_door_overlay)
		animate_door(FALSE)
	update_appearance()
	return TRUE

/obj/structure/closet/proc/close(mob/user)
	if(!opened)
		return FALSE
	if(!can_close())
		return FALSE

	var/itemcount = 0
	var/temp_capacity = storage_capacity
	if(user && user.mind && HAS_TRAIT(user.mind, TRAIT_PACK_RAT))
		temp_capacity *= 1.5
	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in loc)
		if(itemcount >= temp_capacity)
			break
		AD.forceMove(src)
		itemcount++

	for(var/obj/item/I in loc)
		if(itemcount >= temp_capacity)
			break
		if(!I.anchored)
			I.forceMove(src)
			itemcount++

	for(var/mob/M in loc)
		if(itemcount >= temp_capacity)
			break
		if(isobserver(M))
			continue
		if(istype(M, /mob/living/simple_animal/bot/mulebot) || iscameramob(M))
			continue
		if(M.buckled || M.anchored || M.has_buckled_mobs())
			continue
		if(is_ai(M))
			continue

		M.forceMove(src)
		itemcount++
	opened = FALSE
	playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	if(enable_door_overlay)
		animate_door(TRUE)
	update_appearance()
	density = TRUE

	return TRUE

/obj/structure/closet/proc/toggle(mob/user)
	if(!(opened ? close(user) : open()))
		to_chat(user, "<span class='notice'>It won't budge!</span>")

/obj/structure/closet/proc/bust_open()
	welded = FALSE //applies to all lockers
	locked = FALSE //applies to critter crates and secure lockers only
	broken = TRUE //applies to secure lockers only
	open()

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(flags & NODECONSTRUCT))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/closet/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		bust_open()

/obj/structure/closet/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(istype(W, /obj/item/rcs) && !opened)
		var/obj/item/rcs/E = W
		E.try_send_container(user, src)
		return ITEM_INTERACT_COMPLETE

	if(opened)
		if(istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if(large)
				MouseDrop_T(G.affecting, user)      //act like they were dragged onto the closet
			else
				to_chat(user, "<span class='notice'>[src] is too small to stuff [G.affecting] into!</span>")
		if(istype(W, /obj/item/tk_grab))
			return // passthrough
		if(user.a_intent != INTENT_HELP) // Stops you from putting your baton in the closet on accident
			return ITEM_INTERACT_COMPLETE
		if(isrobot(user) && !istype(W.loc, /obj/item/gripper))
			return ITEM_INTERACT_COMPLETE
		if(!user.drop_item()) //couldn't drop the item
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in \the [src]!</span>")
			return ITEM_INTERACT_COMPLETE
		if(W.loc != user.loc)
			// It went somewhere else, don't teleport it back.
			return ITEM_INTERACT_COMPLETE
		if(W)
			W.forceMove(loc)
			return ITEM_INTERACT_COMPLETE
	else if(can_be_emaged && (istype(W, /obj/item/card/emag) || istype(W, /obj/item/melee/energy/blade) && !broken))
		emag_act(user)
		return ITEM_INTERACT_COMPLETE
	else if(istype(W, /obj/item/stack/package_wrap))
		return
	else if(user.a_intent != INTENT_HARM)
		closed_item_click(user)
		return ITEM_INTERACT_COMPLETE
	else
		return ..()

// What happens when the closet is attacked by a random item not on harm mode
/obj/structure/closet/proc/closed_item_click(mob/user)
	attack_hand(user)

/obj/structure/closet/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!opened && user.loc == src)
		to_chat(user, "<span class='warning'>You can't weld [src] from inside!</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	if(opened)
		WELDER_ATTEMPT_SLICING_MESSAGE
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			WELDER_SLICING_SUCCESS_MESSAGE
			deconstruct(TRUE)
			return
	else
		var/adjective = welded ? "open" : "shut"
		user.visible_message("<span class='notice'>[user] begins welding [src] [adjective]...</span>", "<span class='notice'>You begin welding [src] [adjective]...</span>", "<span class='warning'>You hear welding.</span>")
		if(I.use_tool(src, user, 15, volume = I.tool_volume))
			if(opened)
				to_chat(user, "<span class='notice'>Keep [src] shut while doing that!</span>")
				return
			user.visible_message("<span class='notice'>[user] welds [src] [adjective]!</span>", "<span class='notice'>You weld [src] [adjective]!</span>")
			welded = !welded
			update_icon()
			return

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/living/user)
	..()
	if(is_screen_atom(O))	//fix for HUD elements making their way into the world	-Pete
		return
	if(O.loc == user)
		return
	if(user.restrained() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if((!istype(O, /atom/movable) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts, you cannot shove people into fucking lockers
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!isturf(user.loc)) // are you in a container/closet/pod/etc?
		return
	if(!opened)
		return
	if(istype(O, /obj/structure/closet))
		return
	step_towards(O, loc)
	if(user != O)
		user.visible_message("<span class='danger'>[user] stuffs [O] into [src]!</span>", "<span class='danger'>You stuff [O] into [src]!</span>")
	add_fingerprint(user)
	return TRUE

/obj/structure/closet/attack_ai(mob/user)
	if(isrobot(user) && Adjacent(user)) //Robots can open/close it, but not the AI
		attack_hand(user)

/obj/structure/closet/relaymove(mob/user)
	if(user.stat || !isturf(loc))
		return

	if(!open())
		to_chat(user, "<span class='notice'>It won't budge!</span>")
		if(!lastbang)
			lastbang = 1
			for(var/mob/M in hearers(src, null))
				to_chat(M, "<FONT size=[max(0, 5 - get_dist(src, M))]>BANG, bang!</FONT>")
			spawn(30)
				lastbang = 0

/obj/structure/closet/attack_hand(mob/user)
	add_fingerprint(user)
	toggle(user)

/obj/structure/closet/attack_animal(mob/living/user)
	if(user.a_intent == INTENT_HARM || welded || locked)
		return ..()
	if(!user.mind) // Stops mindless mobs from opening lockers + endlessly opening/closing crates instead of attacking
		return ..()
	if(user.mob_size < MOB_SIZE_HUMAN)
		return ..()
	add_fingerprint(user)
	toggle(user)

/obj/structure/closet/attack_alien(mob/user)
	if(user.a_intent == INTENT_HARM || welded || locked)
		return ..()
	if(!user.mind)
		return ..()
	add_fingerprint(user)
	toggle(user)

/obj/structure/closet/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		toggle(user)

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	add_fingerprint(user)
	toggle(user)

/obj/structure/closet/update_overlays()
	. = ..()
	closet_update_overlays(.)

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/AM)
	open()
	if(AM.loc == src)
		return FALSE
	return TRUE

/obj/structure/closet/container_resist(mob/living/L)
	var/breakout_time = 2 MINUTES
	if(opened)
		if(L.loc == src)
			L.forceMove(get_turf(src)) // Let's just be safe here
		return //Door's open... wait, why are you in it's contents then?
	if(!welded)
		open() //for cardboard boxes
		return //closed but not welded...
	//	else Meh, lets just keep it at 2 minutes for now
	//		breakout_time++ //Harder to get out of welded lockers than locked lockers

	//okay, so the closet is either welded or locked... resist!!!
	to_chat(L, "<span class='warning'>You lean on the back of \the [src] and start pushing the door open. (this will take about [breakout_time / 600] minutes)</span>")
	for(var/mob/O in viewers(usr.loc))
		O.show_message("<span class='danger'>[src] begins to shake violently!</span>", 1)


	spawn(0)
		if(do_after(L, breakout_time, target = src, allow_moving = TRUE, allow_moving_target = TRUE))
			if(!src || !L || L.stat != CONSCIOUS || L.loc != src || opened) //closet/user destroyed OR user dead/unconcious OR user no longer in closet OR closet opened
				return

			//Perform the same set of checks as above for weld and lock status to determine if there is even still a point in 'resisting'...
			if(!welded)
				return

			//Well then break it!
			welded = FALSE
			update_icon()
			to_chat(usr, "<span class='warning'>You successfully break out!</span>")
			for(var/mob/O in viewers(L.loc))
				O.show_message("<span class='danger'>\the [usr] successfully broke out of \the [src]!</span>", 1)
			if(istype(loc, /obj/structure/big_delivery)) //nullspace ect.. read the comment above
				var/obj/structure/big_delivery/BD = loc
				BD.attack_hand(usr)
			open()

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/stretch/impaired, 1)

/obj/structure/closet/ex_act(severity)
	for(var/atom/A in contents)
		A.ex_act(severity)
		CHECK_TICK
	..()

/obj/structure/closet/singularity_act()
	dump_contents()
	..()

/obj/structure/closet/AllowDrop()
	return TRUE

/obj/structure/closet/force_eject_occupant(mob/target)
	// Its okay to silently teleport mobs out of lockers, since the only thing affected is their contents list.
	return

/obj/structure/closet/shove_impact(mob/living/target, mob/living/attacker)
	if(opened && can_close())
		target.forceMove(src)
		visible_message("<span class='danger'>[attacker] shoves [target] inside [src]!</span>", "<span class='warning'>You hear a thud, and something clangs shut.</span>")
		close(attacker)
		add_attack_logs(attacker, target, "shoved into [src]")
		return TRUE

	if(!opened && can_open())
		open()
		visible_message("<span class='danger'>[attacker] shoves [target] against [src], knocking it open!</span>")
		target.KnockDown(3 SECONDS)
		return TRUE

	return ..()

/obj/structure/closet/bluespace
	name = "bluespace closet"
	desc = "An experimental storage unit which defies several conventional laws of physics. It appears to only tenuously exist on this plane of reality, allowing it to phase through anything less solid than a wall."
	density = FALSE
	icon_state = "bluespace"
	storage_capacity = 60
	var/materials = list(MAT_METAL = 5000, MAT_PLASMA = 2500, MAT_TITANIUM = 500, MAT_BLUESPACE = 500)

/obj/structure/closet/bluespace/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(UpdateTransparency),
		COMSIG_ATOM_EXITED = PROC_REF(UpdateTransparency),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/closet/bluespace/proc/UpdateTransparency()
	SIGNAL_HANDLER  // COMSIG_ATOM_ENTERED + COMSIG_ATOM_EXITED
	transparent = FALSE
	if(!get_turf(loc))
		return

	for(var/atom/A in loc)
		if(A.density && A != src)
			transparent = TRUE
			alpha = 180
			update_icon()
			return
	alpha = 255
	update_icon()

/obj/structure/closet/bluespace/Move(NewLoc, direct) // Allows for "phasing" throug objects but doesn't allow you to stuff your EOC homebois in one of these and push them through walls.
	var/turf/T = get_turf(NewLoc)
	if(T.density)
		return
	for(var/atom/A in T.contents)
		if(A.density && isairlock(A))
			return

	. = ..()

	UpdateTransparency()

/obj/structure/closet/bluespace/close()
	. = ..()
	density = FALSE
