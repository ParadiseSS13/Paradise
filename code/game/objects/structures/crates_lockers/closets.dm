/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/hispania/obj/closet.dmi'
	icon_state = "closed"
	density = 1
	max_integrity = 200
	integrity_failure = 50
	armor = list("melee" = 20, "bullet" = 10, "laser" = 10, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 60)
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	var/large = TRUE
	var/can_be_emaged = FALSE
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/lastbang
	var/open_sound = 'sound/machines/closet_open.ogg'
	var/close_sound = 'sound/machines/closet_close.ogg'
	var/open_sound_volume = 35
	var/close_sound_volume = 50
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/material_drop = /obj/item/stack/sheet/metal
	var/material_drop_amount = 2
	drag_slowdown = 1.5

// Please dont override this unless you absolutely have to
/obj/structure/closet/Initialize(mapload)
	. = ..()
	if(!opened)
		// Youre probably asking, why is this a 0 seconds timer AA?
		// Well, I will tell you. One day, all /obj/effect/spawner will use Initialize
		// This includes maint loot spawners. The problem with that is if a closet loads before a spawner,
		// the loot will just be in a pile. Adding a timer with 0 delay will cause it to only take in contents once the MC has loaded,
		// therefore solving the issue on mapload. During rounds, everything will happen as normal
		addtimer(CALLBACK(src, .proc/take_contents), 0)
	update_icon() // Set it to the right icon if needed
	populate_contents() // Spawn all its stuff

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
/obj/structure/closet/Destroy()
	dump_contents()
	return ..()

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0 || wall_mounted)
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

	return TRUE

/obj/structure/closet/proc/dump_contents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in src)
		AM.forceMove(T)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/proc/open()
	if(opened)
		return FALSE

	if(!can_open())
		return FALSE

	dump_contents()

	icon_state = icon_opened
	opened = TRUE
	playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	density = 0
	return TRUE

/obj/structure/closet/proc/close()
	if(!opened)
		return FALSE
	if(!can_close())
		return FALSE

	var/itemcount = 0

	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in loc)
		if(itemcount >= storage_capacity)
			break
		AD.forceMove(src)
		itemcount++

	for(var/obj/item/I in loc)
		if(itemcount >= storage_capacity)
			break
		if(!I.anchored)
			I.forceMove(src)
			itemcount++

	for(var/mob/M in loc)
		if(itemcount >= storage_capacity)
			break
		if(istype(M, /mob/dead/observer))
			continue
		if(istype(M, /mob/living/simple_animal/bot/mulebot))
			continue
		if(M.buckled || M.anchored || M.has_buckled_mobs())
			continue
		if(isAI(M))
			continue

		M.forceMove(src)
		itemcount++

	icon_state = icon_closed
	opened = FALSE
	playsound(loc, close_sound, close_sound_volume, TRUE, -3)
	density = 1
	return TRUE

/obj/structure/closet/proc/toggle(mob/user)
	if(!(opened ? close() : open()))
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

/obj/structure/closet/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcs) && !opened)
		var/obj/item/rcs/E = W
		E.try_send_container(user, src)
		return

	if(opened)
		if(istype(W, /obj/item/grab))
			var/obj/item/grab/G = W
			if(large)
				MouseDrop_T(G.affecting, user)      //act like they were dragged onto the closet
			else
				to_chat(user, "<span class='notice'>[src] is too small to stuff [G.affecting] into!</span>")
		if(istype(W, /obj/item/tk_grab))
			return FALSE
		if(user.a_intent != INTENT_HELP) // Stops you from putting your baton in the closet on accident
			return
		if(isrobot(user))
			return
		if(!user.drop_item()) //couldn't drop the item
			to_chat(user, "<span class='notice'>\The [W] is stuck to your hand, you cannot put it in \the [src]!</span>")
			return
		if(W)
			W.forceMove(loc)
			return TRUE // It's resolved. No afterattack needed. Stops you from emagging lockers when putting in an emag
	else if(can_be_emaged && (istype(W, /obj/item/card/emag) || istype(W, /obj/item/melee/energy/blade) && !broken))
		emag_act(user)
	else if(istype(W, /obj/item/stack/packageWrap))
		return
	else if(user.a_intent != INTENT_HARM)
		closed_item_click(user)
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

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/user)
	..()
	if(istype(O, /obj/screen))	//fix for HUD elements making their way into the world	-Pete
		return
	if(O.loc == user)
		return
	if(user.restrained() || user.stat || user.IsWeakened() || user.stunned || user.paralysis || user.lying)
		return
	if((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)))
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(!opened)
		return
	if(istype(O, /obj/structure/closet))
		return
	step_towards(O, loc)
	if(user != O)
		user.visible_message("<span class='danger'>[user] stuffs [O] into [src]!</span>", "<span class='danger'>You stuff [O] into [src]!</span>")
	add_fingerprint(user)

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
				to_chat(M, text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M))))
			spawn(30)
				lastbang = 0

/obj/structure/closet/attack_hand(mob/user)
	add_fingerprint(user)
	toggle(user)

/obj/structure/closet/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		toggle(user)

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	add_fingerprint(user)
	if(!toggle())
		to_chat(usr, "<span class='notice'>It won't budge!</span>")

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = null
	set name = "Toggle Open"

	if(usr.incapacitated())
		return

	if(ishuman(usr))
		add_fingerprint(usr)
		toggle(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

/obj/structure/closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	overlays.Cut()
	if(!opened)
		icon_state = icon_closed
		if(welded)
			overlays += "welded"
	else
		icon_state = icon_opened

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/AM)
	open()
	if(AM.loc == src)
		return FALSE
	return TRUE

/obj/structure/closet/container_resist(mob/living/L)
	var/breakout_time = 2 //2 minutes by default
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
	to_chat(L, "<span class='warning'>You lean on the back of \the [src] and start pushing the door open. (this will take about [breakout_time] minutes)</span>")
	for(var/mob/O in viewers(usr.loc))
		O.show_message("<span class='danger'>The [src] begins to shake violently!</span>", 1)


	spawn(0)
		if(do_after(L,(breakout_time*60*10), target = src)) //minutes * 60seconds * 10deciseconds
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
			if(istype(loc, /obj/structure/bigDelivery)) //nullspace ect.. read the comment above
				var/obj/structure/bigDelivery/BD = loc
				BD.attack_hand(usr)
			open()

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 1)

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


/obj/structure/closet/bluespace
	name = "bluespace closet"
	desc = "A storage unit that moves and stores through the fourth dimension."
	density = 0
	icon_state = "bluespace"
	icon_closed = "bluespace"
	icon_opened = "bluespaceopen"
	storage_capacity = 60
	var/materials = list(MAT_METAL = 5000, MAT_PLASMA = 2500, MAT_TITANIUM = 500, MAT_BLUESPACE = 500)
	drag_slowdown = 0

/obj/structure/closet/bluespace/CheckExit(atom/movable/AM)
	UpdateTransparency(AM, loc)
	return TRUE

/obj/structure/closet/bluespace/proc/UpdateTransparency(atom/movable/AM, atom/location)
	var/transparent = FALSE
	for(var/atom/A in location)
		if(A.density && A != src && A != AM)
			transparent = TRUE
			break
	icon_opened = transparent ? "bluespaceopentrans" : "bluespaceopen"
	icon_closed = transparent ? "bluespacetrans" : "bluespace"
	icon_state = opened ? icon_opened : icon_closed

/obj/structure/closet/bluespace/Crossed(atom/movable/AM, oldloc)
	if(AM.density)
		icon_state = opened ? "bluespaceopentrans" : "bluespacetrans"

/obj/structure/closet/bluespace/Move(NewLoc, direct) // Allows for "phasing" throug objects but doesn't allow you to stuff your EOC homebois in one of these and push them through walls.
	var/turf/T = get_turf(NewLoc)
	if(T.density)
		return
	for(var/atom/A in T.contents)
		if(A.density && istype(A, /obj/machinery/door))
			return
	UpdateTransparency(src, NewLoc)
	forceMove(NewLoc)

/obj/structure/closet/bluespace/close()
	. = ..()
	density = 0
