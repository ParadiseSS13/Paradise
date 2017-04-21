/obj/structure/grille
	desc = "A flimsy lattice of metal rods, with screws to secure it to the floor."
	name = "grille"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = 1
	anchored = 1
	flags = CONDUCT
	pressure_resistance = 5*ONE_ATMOSPHERE
	layer = BELOW_OBJ_LAYER
	level = 3
	var/health = 10
	var/broken = 0
	var/can_deconstruct = TRUE
	var/rods_type = /obj/item/stack/rods
	var/rods_amount = 2
	var/rods_broken = 1
	var/grille_type = null
	var/broken_type = /obj/structure/grille/broken

/obj/structure/grille/fence/
	var/width = 3
	health = 50

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
		take_damage(5)
	else
		take_damage(rand(1,2))

/obj/structure/grille/attack_alien(mob/living/user)
	if(istype(user, /mob/living/carbon/alien/larva))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>", \
						 "<span class='warning'>You mangle [src].</span>", \
						 "You hear twisting metal.")

	if(!shock(user, 70))
		take_damage(5)

/obj/structure/grille/attack_slime(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	var/mob/living/carbon/slime/S = user
	if(!S.is_adult)
		return

	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	user.visible_message("<span class='warning'>[user] smashes against [src].</span>", \
						 "<span class='warning'>You smash against [src].</span>", \
						 "You hear twisting metal.")

	take_damage(rand(1,2))

/obj/structure/grille/attack_animal(mob/living/simple_animal/M)
	if(M.melee_damage_upper == 0 || (M.melee_damage_type != BRUTE && M.melee_damage_type != BURN))
		return
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
	M.visible_message("<span class='warning'>[M] smashes against [src].</span>", \
					  "<span class='warning'>You smash against [src].</span>", \
					  "You hear twisting metal.")

	take_damage(rand(M.melee_damage_lower,M.melee_damage_upper), M.melee_damage_type)

/obj/structure/grille/mech_melee_attack(obj/mecha/M)
	if(..())
		take_damage(M.force * 0.5, M.damtype)

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

/obj/structure/grille/bullet_act(obj/item/projectile/Proj)
	. = ..()
	take_damage(Proj.damage*0.3, Proj.damage_type)

/obj/structure/grille/attackby(obj/item/weapon/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(iswirecutter(W))
		if(!shock(user, 100))
			playsound(loc, W.usesound, 100, 1)
			deconstruct()
	else if((isscrewdriver(W)) && (istype(loc, /turf/simulated) || anchored))
		if(!shock(user, 90))
			playsound(loc, W.usesound, 100, 1)
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
		if(!broken)
			var/obj/item/stack/ST = W
			if (ST.get_amount() < 1)
				to_chat(user, "<span class='warning'>You need at least one sheet of glass for that!</span>")
				return
			var/dir_to_set = NORTH
			if(!anchored)
				to_chat(user, "<span class='warning'>[src] needs to be fastened to the floor first!</span>")
				return
			if(loc == user.loc)
				dir_to_set = user.dir
			else
				if((x == user.x) || (y == user.y)) //Only supposed to work for cardinal directions.
					if(x == user.x)
						if(y > user.y)
							dir_to_set = SOUTH
						else
							dir_to_set = NORTH
					else if(y == user.y)
						if(x > user.x)
							dir_to_set = WEST
						else
							dir_to_set = EAST
				else
					to_chat(user, "<span class='notice'>You can't reach.</span>")
					return //Only works for cardinal direcitons, diagonals aren't supposed to work like this.
			for(var/obj/structure/window/WINDOW in loc)
				if(WINDOW.dir == dir_to_set)
					to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
					return
			to_chat(user, "<span class='notice'>You start placing the window...</span>")
			if(do_after(user, 20 * W.toolspeed, target = src))
				if(!loc || !anchored) //Grille destroyed or unanchored while waiting
					return
				for(var/obj/structure/window/WINDOW in loc)
					if(WINDOW.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
						to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
						return
				var/obj/structure/window/WD
				if(istype(W,/obj/item/stack/sheet/rglass))
					WD = new/obj/structure/window/reinforced(loc) //reinforced window
				else if(istype(W,/obj/item/stack/sheet/glass))
					WD = new/obj/structure/window/basic(loc) //normal window
				else if(istype(W,/obj/item/stack/sheet/plasmaglass))
					WD = new/obj/structure/window/plasmabasic(loc) //basic plasma window
				else
					WD = new/obj/structure/window/plasmareinforced(loc) //reinforced plasma window
				WD.setDir(dir_to_set)
				WD.ini_dir = dir_to_set
				WD.anchored = 0
				WD.state = 0
				ST.use(1)
				to_chat(user, "<span class='notice'>You place the [WD] on [src].</span>")
				WD.update_icon()
			return
//window placing end
	else if(istype(W, /obj/item/weapon/shard) || !shock(user, 70))
		return attacked_by(W, user)

/obj/structure/grille/proc/attacked_by(obj/item/I, mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(!(I.flags&NOBLUDGEON))
		if(I.force)
			visible_message("<span class='danger'>[user] has hit [src] with [I]!</span>")
	take_damage(I.force * 0.3, I.damtype)

/obj/structure/grille/proc/deconstruct(disassembled = TRUE)
	if(!loc) //if already qdel'd somehow, we do nothing
		return
	if(can_deconstruct)
		var/obj/R = new rods_type(loc, rods_amount)
		transfer_fingerprints_to(R)
		qdel(src)

/obj/structure/grille/proc/obj_break()
	if(!broken && can_deconstruct)
		new broken_type(loc)
		var/obj/R = new rods_type(loc, rods_broken)
		transfer_fingerprints_to(R)
		qdel(src)

/obj/structure/grille/proc/take_damage(damage, damage_type = BRUTE, sound_effect = 1)
	switch(damage_type)
		if(BURN)
			if(sound_effect)
				playsound(loc, 'sound/items/welder.ogg', 80, 1)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		else
			return
	health -= damage
	if(health <= 0)
		if(!broken)
			obj_break()
		else
			if(health <= -6)
				deconstruct()

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
			var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			return 1
		else
			return 0
	return 0

/obj/structure/grille/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!broken)
		if(exposed_temperature > T0C + 1500)
			take_damage(1)
	..()

/obj/structure/grille/hitby(atom/movable/AM)
	..()
	var/tforce = 0
	if(ismob(AM))
		tforce = 5
	else if(isobj(AM))
		if(prob(50))
			var/obj/item/I = AM
			tforce = max(0, I.throwforce * 0.5)
		else if(anchored && !broken)
			var/turf/T = get_turf(src)
			var/obj/structure/cable/C = T.get_cable_node()
			if(C)
				playsound(loc, 'sound/magic/LightningShock.ogg', 100, 1, extrarange = 5)
				tesla_zap(src, 3, C.powernet.avail * 0.01) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
				C.powernet.load += C.powernet.avail * 0.0375 // you can gain up to 3.5 via the 4x upgrades power is halved by the pole so thats 2x then 1X then .5X for 3.5x the 3 bounces shock.
	take_damage(tforce)

/obj/structure/grille/broken // Pre-broken grilles for map placement
	icon_state = "brokengrille"
	density = 0
	health = 0
	broken = 1
	rods_amount = 1
	rods_broken = 0
	grille_type = /obj/structure/grille
	broken_type = null
