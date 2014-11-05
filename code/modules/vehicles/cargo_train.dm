/obj/vehicle/train/cargo/engine
	name = "cargo train tug"
	desc = "A ridable electric car designed for pulling cargo trolleys."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "cargo_engine"
	on = 0
	powered = 1
	locked = 0

	load_item_visible = 1
	load_offset_x = 0
	mob_offset_y = 7

	var/car_limit = 3		//how many cars an engine can pull before performance degrades
	active_engines = 1
	var/obj/item/weapon/key/cargo_train/key

/obj/item/weapon/key/cargo_train
	name = "key"
	desc = "A keyring with a small steel key, and a yellow fob reading \"Choo Choo!\"."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "train_keys"
	w_class = 1

/obj/vehicle/train/cargo/trolley
	name = "cargo train trolley"
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "cargo_trailer"
	anchored = 0
	passenger_allowed = 0
	locked = 0

	load_item_visible = 1
	load_offset_x = 0
	load_offset_y = 4
	mob_offset_y = 8

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/train/cargo/engine/New()
	..()
	cell = new /obj/item/weapon/cell/high
	verbs -= /atom/movable/verb/pull
	key = new()
	var/image/I = new(icon = 'icons/obj/vehicles.dmi', icon_state = "cargo_engine_overlay", layer = src.layer + 0.2) //over mobs
	overlays += I
	turn_off()	//so engine verbs are correctly set

/obj/vehicle/train/cargo/engine/Move()
	if(on && cell.charge < charge_use)
		turn_off()
		update_stats()
		if(load && is_train_head())
			load << "The drive motor briefly whines, then drones to a stop."

	if(is_train_head() && !on)
		return 0

	return ..()

/obj/vehicle/train/cargo/trolley/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(open && istype(W, /obj/item/weapon/wirecutters))
		passenger_allowed = !passenger_allowed
		user.visible_message("<span class='notice'>[user] [passenger_allowed ? "cuts" : "mends"] a cable in [src].</span>","<span class='notice'>You [passenger_allowed ? "cut" : "mend"] the load limiter cable.</span>")
	else
		..()

/obj/vehicle/train/cargo/engine/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/key/cargo_train))
		if(!key)
			user.drop_item()
			W.forceMove(src)
			key = W
			verbs += /obj/vehicle/train/cargo/engine/verb/remove_key
		return
	..()

/obj/vehicle/train/cargo/update_icon()
	if(open)
		icon_state = initial(icon_state) + "_open"
	else
		icon_state = initial(icon_state)

/obj/vehicle/train/cargo/trolley/insert_cell(var/obj/item/weapon/cell/C, var/mob/living/carbon/human/H)
	return

/obj/vehicle/train/cargo/engine/insert_cell(var/obj/item/weapon/cell/C, var/mob/living/carbon/human/H)
	..()
	update_stats()

/obj/vehicle/train/cargo/engine/remove_cell(var/mob/living/carbon/human/H)
	..()
	update_stats()

/obj/vehicle/train/cargo/engine/Bump(atom/Obstacle)
	var/obj/machinery/door/D = Obstacle
	var/mob/living/carbon/human/H = load
	if(istype(D) && istype(H))
		D.Bumped(H)		//a little hacky, but hey, it works, and respects access rights

	..()

/obj/vehicle/train/cargo/trolley/Bump(atom/Obstacle)
	if(!lead)
		return //so people can't knock others over by pushing a trolley around
	..()

//-------------------------------------------
// Train procs
//-------------------------------------------
/obj/vehicle/train/cargo/engine/turn_on()
	if(!key)
		return
	else
		..()
		update_stats()

		verbs -= /obj/vehicle/train/cargo/engine/verb/stop_engine
		verbs -= /obj/vehicle/train/cargo/engine/verb/start_engine

		if(on)
			verbs += /obj/vehicle/train/cargo/engine/verb/stop_engine
		else
			verbs += /obj/vehicle/train/cargo/engine/verb/start_engine

/obj/vehicle/train/cargo/engine/turn_off()
	..()

	verbs -= /obj/vehicle/train/cargo/engine/verb/stop_engine
	verbs -= /obj/vehicle/train/cargo/engine/verb/start_engine

	if(!on)
		verbs += /obj/vehicle/train/cargo/engine/verb/start_engine
	else
		verbs += /obj/vehicle/train/cargo/engine/verb/stop_engine

/obj/vehicle/train/cargo/RunOver(var/mob/living/carbon/human/H)
	var/list/parts = list("head", "chest", "l_leg", "r_leg", "l_arm", "r_arm")

	H.apply_effects(5, 5)
	for(var/i = 0, i < rand(1,3), i++)
		H.apply_damage(rand(1,5), BRUTE, pick(parts))

/obj/vehicle/train/cargo/trolley/RunOver(var/mob/living/carbon/human/H)
	..()
	attack_log += text("\[[time_stamp()]\] <font color='red'>ran over [H.name] ([H.ckey])</font>")

/obj/vehicle/train/cargo/engine/RunOver(var/mob/living/carbon/human/H)
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
/obj/vehicle/train/cargo/engine/relaymove(mob/user, direction)
	if(user != load)
		return 0

	if(is_train_head())
		if(direction == reverse_direction(dir) && tow)
			return 0
		if(Move(get_step(src, direction)))
			return 1
		return 0
	else
		return ..()

/obj/vehicle/train/cargo/engine/examine()
	..()

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(get_dist(usr,src) <= 1)
		usr << "The power light is [on ? "on" : "off"].\nThere are[key ? "" : " no"] keys in the ignition."
		usr << "The charge meter reads [cell? round(cell.percent(), 0.01) : 0]%"

/obj/vehicle/train/cargo/engine/verb/start_engine()
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

/obj/vehicle/train/cargo/engine/verb/stop_engine()
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

/obj/vehicle/train/cargo/engine/verb/remove_key()
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

	verbs -= /obj/vehicle/train/cargo/engine/verb/remove_key

//-------------------------------------------
// Loading/unloading procs
//-------------------------------------------
/obj/vehicle/train/cargo/trolley/load(var/atom/movable/C)
	if(ismob(C) && !passenger_allowed)
		return 0
	if(!istype(C,/obj/machinery) && !istype(C,/obj/structure/closet) && !istype(C,/obj/structure/largecrate) && !istype(C,/obj/structure/reagent_dispensers) && !istype(C,/obj/structure/ore_box) && !istype(C, /mob/living/carbon/human))
		return 0

	..()

	if(load)
		return 1

/obj/vehicle/train/cargo/engine/load(var/atom/movable/C)
	if(!istype(C, /mob/living/carbon/human))
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
/obj/vehicle/train/cargo/engine/update_car(var/train_length, var/active_engines)
	src.train_length = train_length
	src.active_engines = active_engines

	//Update move delay
	if(!is_train_head() || !on)
		move_delay = initial(move_delay)		//so that engines that have been turned off don't lag behind
	else
		move_delay = max(0, (-car_limit * active_engines) + train_length - active_engines)	//limits base overweight so you cant overspeed trains
		move_delay *= (1 / max(1, active_engines)) * 2 										//overweight penalty (scaled by the number of engines)
		move_delay += config.run_speed 														//base reference speed
		move_delay *= 1.1																	//makes cargo trains 10% slower than running when not overweight

/obj/vehicle/train/cargo/trolley/update_car(var/train_length, var/active_engines)
	src.train_length = train_length
	src.active_engines = active_engines

	if(!lead && !tow)
		anchored = 0
		if(verbs.Find(/atom/movable/verb/pull))
			return
		else
			verbs += /atom/movable/verb/pull
	else
		anchored = 1
		verbs -= /atom/movable/verb/pull
