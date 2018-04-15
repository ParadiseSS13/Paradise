/obj/structure/grille
	desc = "A flimsy framework of metal rods."
	name = "grille"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = TRUE
	anchored = TRUE
	flags = CONDUCT
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = BELOW_OBJ_LAYER
	level = 3
	armor = list(melee = 50, bullet = 70, laser = 70, energy = 100, bomb = 10, bio = 100, rad = 100)
	max_integrity = 50
	integrity_failure = 20
	var/rods_type = /obj/item/stack/rods
	var/rods_amount = 2
	var/rods_broken = 1
	var/grille_type
	var/broken_type = /obj/structure/grille/broken

/obj/structure/grille/fence/
	var/width = 3

/obj/structure/grille/fence/New()
	if(width > 1)
		if(dir in list(EAST, WEST))
			bound_width = width * world.icon_size
			bound_height = world.icon_size
		else
			bound_width = world.icon_size
			bound_height = width * world.icon_size

/obj/structure/grille/fence/east_west
	//width=80
	//height=42
	icon='icons/fence-ew.dmi'

/obj/structure/grille/fence/north_south
	//width=80
	//height=42
	icon='icons/fence-ns.dmi'

/obj/structure/grille/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		else
			take_damage(rand(5,10), BRUTE, 0)

/obj/structure/grille/blob_act()
	if(!broken)
		obj_break()

/obj/structure/grille/examine(mob/user)
	..()
	if(anchored)
		to_chat(user, "<span class='notice'>It's secured in place with <b>screws</b>. The rods look like they could be <b>cut</b> through.</span>")
	if(!anchored)
		to_chat(user, "<span class='notice'>The anchoring screws are <i>unscrewed</i>. The rods look like they could be <b>cut</b> through.</span>")

/obj/structure/grille/ratvar_act()
	if(broken)
		new /obj/structure/grille/ratvar/broken(loc)
	else
		new /obj/structure/grille/ratvar(loc)
	qdel(src)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user))
		shock(user, 70)

/obj/structure/grille/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='warning'>[user] kicks [src].</span>", \
						 "<span class='warning'>You kick [src].</span>", \
						 "You hear twisting metal.")

	if(shock(user, 70))
		return
	if(HULK in user.mutations)
		take_damage(60, BRUTE, "melee", 1)
	else
		take_damage(rand(5,10), BRUTE, "melee", 1)

/obj/structure/grille/attack_alien(mob/living/user)
	if(istype(user, /mob/living/carbon/alien/larva))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>", \
						 "<span class='warning'>You mangle [src].</span>", \
						 "You hear twisting metal.")

	if(!shock(user, 70))
		take_damage(20, BRUTE, "melee", 1)

/obj/structure/grille/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0)
		return 1
	if(istype(mover) && mover.checkpass(PASSGRILLE))
		return 1
	else
		if(istype(mover, /obj/item/projectile))
			return prob(30)
		else
			return !density

/obj/structure/grille/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || mover.checkpass(PASSGRILLE)

/obj/structure/grille/attackby(obj/item/weapon/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(iswirecutter(W))
		if(!shock(user, 100))
			playsound(loc, W.usesound, 100, 1)
			deconstruct()
	else if((isscrewdriver(W)) && (istype(loc, /turf/simulated) || anchored))
		if(!shock(user, 90))
			playsound(src, W.usesound, 100, 1)
			anchored = !anchored
			user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] [src].</span>", \
								 "<span class='notice'>You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor.</span>")
			return
	else if(istype(W, /obj/item/stack/rods) && broken)
		var/obj/item/stack/rods/R = W
		if(!shock(user, 90))
			user.visible_message("<span class='notice'>[user] rebuilds the broken grille.</span>", \
								 "<span class='notice'>You rebuild the broken grille.</span>")
			new grille_type(loc)
			R.use(1)
			qdel(src)
			return

//window placing begin
	else if(istype(W,/obj/item/stack/sheet/rglass) || istype(W,/obj/item/stack/sheet/glass) || istype(W,/obj/item/stack/sheet/plasmaglass) || istype(W,/obj/item/stack/sheet/plasmarglass))
		build_window(W, user)
		return
//window placing end

	else if(istype(W, /obj/item/weapon/shard) || !shock(user, 70))
		return ..()

/obj/structure/grille/proc/build_window(obj/item/stack/sheet/S, mob/user)
	if(!istype(S) || !user)
		return
	if(broken)
		to_chat(user, "<span class='warning'>You must repair or replace [src] first!</span>")
		return
	if(S.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need at least one sheet of glass for that!</span>")
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] needs to be fastened to the floor first!</span>")
		return
	if(!getRelativeDirection(src, user) && (user.loc != loc))	//essentially a cardinal direction adjacent or sharing same loc check
		to_chat(user, "<span class='warning'>You can't reach.</span>")
		return
	if(/obj/structure/window/full in loc)	//check for a full window already present (blocks the whole tile)
		to_chat(user, "<span class='warning'>There is already a full window there.</span>")
		return
	var/selection = alert(user, "What type of window would you like to place?", "Window Construction", "One Direction", "Full", "Cancel")
	if(selection == "Cancel")
		return
	if(selection == "Full")
		if(S.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two sheets of glass for that!</span>")
			return
		if(do_after(user, 20, target = src))	//glass doesn't have a toolspeed, so no multiplier
			if(broken || !anchored || !src)		//make sure the grille is still intact, anchored, and exists!
				return
			if(S.get_amount() < 2)				//make sure we still have enough for this!
				return
			if(!getRelativeDirection(src, user) && (user.loc != loc))	//make sure we can still do this from our location
				return
			var/obj/structure/window/W = new S.full_window(get_turf(src))
			S.use(2)
			W.anchored = 0
			W.state = 0
			to_chat(user, "<span class='notice'>You place [W] on [src].</span>")
			W.update_icon()
		return
	if(selection == "One Direction")
		var/dir_selection = input("Which direction will this window face?", "Direction") as null|anything in list("north", "east", "south", "west")
		if(!dir_selection)
			return
		var/temp_dir = text2dir(dir_selection)
		for(var/obj/structure/window/W in loc)
			if(istype(W, /obj/structure/window/full))	//double checking in case a full window was created while selecting direction
				to_chat(user, "<span class='warning'>There is already a full window there.</span>")
				return
			if(W.dir == temp_dir)	//to avoid building a window on top of an existing window
				to_chat(user, "<span class='warning'>There is already a window facing this direction there.</span>")
				return
		if(do_after(user, 20, target = src))
			if(broken || !anchored || !src)		//make sure the grille is still intact, anchored, and exists!
				return
			if(S.get_amount() < 1)				//make sure we still have enough fir this!
				to_chat(user, "<span class='warning'>You need at least one sheet of glass for that!</span>")
				return
			if(!getRelativeDirection(src, user) && (user.loc != loc))	//make sure we can still do this from our location
				return
			var/obj/structure/window/W = new S.created_window(get_turf(src))
			S.use(1)
			W.setDir(temp_dir)
			W.ini_dir = temp_dir
			W.anchored = 0
			W.state = 0
			to_chat(user, "<span class='notice'>You place [W] on [src].</span>")
			W.update_icon()
		return

/obj/structure/grille/attacked_by(obj/item/I, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(!(I.flags&NOBLUDGEON))
		if(I.force)
			visible_message("<span class='danger'>[user] has hit [src] with [I]!</span>")
	take_damage(I.force * 0.3, I.damtype)

/obj/structure/grille/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/grillehit.ogg', 80, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 80, 1)

/obj/structure/grille/deconstruct(disassembled = TRUE)
	if(!loc) //if already qdel'd somehow, we do nothing
		return
	if(can_deconstruct)
		var/obj/R = new rods_type(loc, rods_amount)
		transfer_fingerprints_to(R)
		qdel(src)
	..()

/obj/structure/grille/obj_break()
	if(!broken && can_deconstruct)
		new broken_type(loc)
		var/obj/R = new rods_type(loc, rods_broken)
		transfer_fingerprints_to(R)
		qdel(src)

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || broken)		// unanchored/broken grilles are never connected
		return 0
	if(!prob(prb))
		return 0
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return 0
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			return 1
		else
			return 0
	return 0

/obj/structure/grille/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!broken)
		if(exposed_temperature > T0C + 1500)
			take_damage(1, BURN, 0, 0)
	..()

/obj/structure/grille/hitby(atom/movable/AM)
	if(istype(AM, /obj))
		if(prob(50) && anchored && !broken)
			var/turf/T = get_turf(src)
			var/obj/structure/cable/C = T.get_cable_node()
			if(C)
				playsound(loc, 'sound/magic/LightningShock.ogg', 100, 1, extrarange = 5)
				tesla_zap(src, 3, C.powernet.avail * 0.01) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
				C.powernet.load += C.powernet.avail * 0.0375 // you can gain up to 3.5 via the 4x upgrades power is halved by the pole so thats 2x then 1X then .5X for 3.5x the 3 bounces shock.
	return ..()

/obj/structure/grille/broken // Pre-broken grilles for map placement
	icon_state = "brokengrille"
	density = 0
	obj_integrity = 20
	broken = 1
	rods_amount = 1
	rods_broken = 0
	grille_type = /obj/structure/grille
	broken_type = null

/obj/structure/grille/ratvar
	icon_state = "ratvargrille"
	name = "cog grille"
	desc = "A strangely-shaped grille."
	broken_type = /obj/structure/grille/ratvar/broken

/obj/structure/grille/ratvar/New()
	..()
	if(broken)
		new /obj/effect/temp_visual/ratvar/grille/broken(get_turf(src))
	else
		new /obj/effect/temp_visual/ratvar/grille(get_turf(src))
		new /obj/effect/temp_visual/ratvar/beam/grille(get_turf(src))

/obj/structure/grille/ratvar/narsie_act()
	take_damage(rand(1, 3), BRUTE)
	if(src)
		var/previouscolor = color
		color = "#960000"
		animate(src, color = previouscolor, time = 8)

/obj/structure/grille/ratvar/ratvar_act()
	return

/obj/structure/grille/ratvar/broken
	icon_state = "brokenratvargrille"
	density = FALSE
	obj_integrity = 20
	broken = TRUE
	rods_amount = 1
	rods_broken = 0
	grille_type = /obj/structure/grille/ratvar
	broken_type = null
