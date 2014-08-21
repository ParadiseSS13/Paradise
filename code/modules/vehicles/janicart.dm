/obj/vehicle/train/janitor/engine
	name = "janitor train tug"
	desc = "A ridable electric car designed for pulling janitor trolleys."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "pussywagon"			//mulebot icons until I get some proper icons
	on = 0
	powered = 1
	locked = 0
	layer = MOB_LAYER + 0.1
	load_item_visible = 1
	load_offset_x = 0
	load_offset_y = 7

	var/car_limit = 3		//how many cars an engine can pull before performance degrades
	active_engines = 1
	var/obj/item/weapon/key/janitor_train/key
	flags = OPENCONTAINER
	var/amount_per_transfer_from_this = 5 //shit I dunno, adding this so syringes stop runtime erroring. --NeoFite
	var/obj/item/weapon/storage/bag/trash/mybag	= null

/obj/item/weapon/key/janitor_train
	name = "key"
	desc = "A keyring with a small steel key, and a yellow fob reading \"Choo Choo!\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys"
	w_class = 1

/obj/vehicle/train/janitor/trolley
	name = "janitor train trolley"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashcart"
	anchored = 0
	passenger_allowed = 0
	locked = 0
	load_item_visible = 1
	load_offset_x = 1
	load_offset_y = 7

	var/openTop = 0
	var/organs = 0
//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/train/janitor/engine/New()
	..()
	cell = new /obj/item/weapon/cell/high
	verbs -= /atom/movable/verb/pull
	key = new()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

/obj/vehicle/train/janitor/engine/Move()
	if(on && cell.charge < charge_use)
		turn_off()
		update_stats()
		if(load && is_train_head())
			load << "The drive motor briefly whines, then drones to a stop."

	if(is_train_head() && !on)
		return 0

	handle_rotation()
	update_mob()

	return ..()

/obj/vehicle/train/janitor/trolley/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(openTop)
		W.loc = src
		user.visible_message("<span class='notice'>[user] puts [W] in [src].</span>","<span class='notice'>You put [W] in [src].</span>")
		if(istype(W,/obj/item/weapon/organ))
			organs = 1
			update_icon()
	else
		user << "The top is closed!"

/obj/vehicle/train/janitor/trolley/attack_hand(mob/user)
	openTop = !openTop
	user.visible_message("<span class='notice'>[user] [openTop ? "opens" : "closes"] the top of [src].</span>","<span class='notice'>You [openTop ? "open" : "close"] the the top of [src].</span>")
	update_icon()
	..()

/obj/vehicle/train/janitor/trolley/update_icon()
	if(openTop)
		if(organs)
			icon_state = "trashcartopengib"
		else
			icon_state = "trashcartopen"
	else
		if(organs)
			icon_state = "trashcartgib"
		else
			icon_state = "trashcart"

/obj/vehicle/train/janitor/engine/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/key/janitor_train))
		if(!key)
			user.drop_item()
			key = W
			W.loc = src
			verbs += /obj/vehicle/train/janitor/engine/verb/remove_key
		return
	else if(istype(W, /obj/item/weapon/mop))
		if(reagents.total_volume >= 2)
			reagents.trans_to(W, 2)
			user << "<span class='notice'>You wet the mop in the pimpin' ride.</span>"
			playsound(src.loc, 'sound/effects/slosh.ogg', 25, 1)
		if(reagents.total_volume < 1)
			user << "<span class='notice'>This pimpin' ride is out of water!</span>"
		return
	else if(istype(W, /obj/item/weapon/storage/bag/trash))
		user << "<span class='notice'>You hook the trashbag onto the pimpin' ride.</span>"
		user.drop_item()
		W.loc = src
		mybag = W
		return
	..()

/obj/vehicle/train/janitor/engine/attack_hand(mob/user)
	if(mybag)
		mybag.loc = get_turf(user)
		user.put_in_hands(mybag)
		mybag = null
	else
		..()

/obj/vehicle/train/janitor/update_icon()
	if(open)
		icon_state = "mulebot-hatch"
	else
		icon_state = initial(icon_state)

/obj/vehicle/train/janitor/engine/Emag(mob/user as mob)
	..()
	flick("mulebot-emagged", src)

/obj/vehicle/train/janitor/trolley/insert_cell(var/obj/item/weapon/cell/C, var/mob/living/carbon/human/H)
	return

/obj/vehicle/train/janitor/engine/insert_cell(var/obj/item/weapon/cell/C, var/mob/living/carbon/human/H)
	..()
	update_stats()

/obj/vehicle/train/janitor/engine/remove_cell(var/mob/living/carbon/human/H)
	..()
	update_stats()

/obj/vehicle/train/janitor/engine/Bump(atom/Obstacle)
	var/obj/machinery/door/D = Obstacle
	var/mob/living/carbon/human/H = load
	if(istype(D) && istype(H))
		D.Bumped(H)		//a little hacky, but hey, it works, and repects access rights

	..()

/obj/vehicle/train/janitor/trolley/Bump(atom/Obstacle)
	if(!lead)
		return //so people can't knock others over by pushing a trolley around
	..()

/obj/vehicle/train/janitor/engine/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

/obj/vehicle/train/janitor/engine/proc/update_mob()
	if(load)
		load.dir = dir
		switch(dir)
			if(SOUTH)
				load.pixel_x = 0
				load.pixel_y = 7
			if(WEST)
				load.pixel_x = 13
				load.pixel_y = 7
			if(NORTH)
				load.pixel_x = 0
				load.pixel_y = 4
			if(EAST)
				load.pixel_x = -13
				load.pixel_y = 7


//-------------------------------------------
// Train procs
//-------------------------------------------
/obj/vehicle/train/janitor/engine/turn_on()
	if(!key)
		return
	else
		..()
		update_stats()

/obj/vehicle/train/janitor/RunOver(var/mob/living/carbon/human/H)
	var/list/parts = list("head", "chest", "l_leg", "r_leg", "l_arm", "r_arm")

	H.apply_effects(5, 5)
	for(var/i = 0, i < rand(1,3), i++)
		H.apply_damage(rand(1,5), BRUTE, pick(parts))

/obj/vehicle/train/janitor/trolley/RunOver(var/mob/living/carbon/human/H)
	..()
	attack_log += text("\[[time_stamp()]\] <font color='red'>ran over [H.name] ([H.ckey])</font>")

/obj/vehicle/train/janitor/engine/RunOver(var/mob/living/carbon/human/H)
	..()

	if(is_train_head() && istype(load, /mob/living/carbon/human))
		var/mob/living/carbon/human/D = load
		D << "\red \b You ran over [H]!"
		visible_message("<B>\red \The [src] ran over [H]!</B>")
		attack_log += text("\[[time_stamp()]\] <font color='red'>ran over [H.name] ([H.ckey]), driven by [D.name] ([D.ckey])</font>")
		msg_admin_attack("[D.name] ([D.ckey]) ran over [H.name] ([H.ckey]). (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")
	else
		attack_log += text("\[[time_stamp()]\] <font color='red'>ran over [H.name] ([H.ckey])</font>")


//-------------------------------------------
// Interaction procs
//-------------------------------------------
/obj/vehicle/train/janitor/engine/relaymove(mob/user, direction)
	if(user != load)
		return 0

	if(is_train_head())
		if(direction == reverse_direction(dir))
			return 0
		if(Move(get_step(src, direction)))
			return 1
		return 0
	else
		return ..()


/obj/vehicle/train/janitor/engine/examine()
	..()

	usr << "\icon[src] This [name] contains [reagents.total_volume] unit\s of [reagents]!"
	if(mybag)
		usr << "\A [mybag] is hanging on the [name]."

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(get_dist(usr,src) <= 1)
		usr << "The power light is [on ? "on" : "off"].\nThere are[key ? "" : " no"] keys in the ignition."

/obj/vehicle/train/janitor/engine/verb/check_power()
	set name = "Check power level"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(!cell)
		usr << "There is no power cell installed in [src]."
		return

	usr << "The power meter reads [round(cell.percent(), 0.01)]%"

/obj/vehicle/train/janitor/engine/verb/start_engine()
	set name = "Start engine"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(on)
		usr << "The engine is already running."
		return

	turn_on()
	if (on)
		usr << "You start [src]'s engine."
	else
		if(cell.charge < charge_use)
			usr << "[src] is out of power."
		else
			usr << "[src]'s engine won't start."

/obj/vehicle/train/janitor/engine/verb/stop_engine()
	set name = "Stop engine"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(!on)
		usr << "The engine is already stopped."
		return

	turn_off()
	if (!on)
		usr << "You stop [src]'s engine."

/obj/vehicle/train/janitor/engine/verb/remove_key()
	set name = "Remove key"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(!key || (load && load != usr))
		return

	if(on)
		turn_off()

	key.loc = usr.loc
	if(!usr.get_active_hand())
		usr.put_in_hands(key)
	key = null

	verbs -= /obj/vehicle/train/janitor/engine/verb/remove_key

//-------------------------------------------
// Loading/unloading procs
//-------------------------------------------
/obj/vehicle/train/janitor/trolley/load(var/atom/movable/C)
	return 0

/obj/vehicle/train/janitor/engine/load(var/atom/movable/C)
	if(!ismob(C))
		return 0

	return ..()


//-------------------------------------------------------
// Stat update procs
//
// Update the trains stats for speed calculations.
// The longer the train, the slower it will go. car_limit
// sets the max number of cars one engine can pull at
// full speed. Adding more cars beyond this will slow the
// train proportionate to the length of the train. Adding
// more engines increases this limit by car_limit per
// engine.
//-------------------------------------------------------

/obj/vehicle/train/janitor/engine/proc/update_move_delay()
	if(!is_train_head() || !on)
		move_delay = initial(move_delay)		//so that engines that have been turned off don't lag behind
	else
		move_delay = max(0, (-car_limit * active_engines) + train_length - active_engines)	//limits base overweight so you cant overspeed trains
		move_delay *= (1 / max(1, active_engines)) * 2 										//overweight penalty (scaled by the number of engines)
		move_delay += config.run_speed 														//base reference speed
		move_delay *= 1.05
