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
	armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	max_integrity = 50
	integrity_failure = 20
	var/rods_type = /obj/item/stack/rods
	var/rods_amount = 2
	var/rods_broken = 1
	var/grille_type
	var/broken_type = /obj/structure/grille/broken
	var/shockcooldown = 0
	var/my_shockcooldown = 1 SECONDS

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

/obj/structure/grille/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon()

/obj/structure/grille/examine(mob/user)
	. = ..()
	if(anchored)
		. += "<span class='notice'>It's secured in place with <b>screws</b>. The rods look like they could be <b>cut</b> through.</span>"
	if(!anchored)
		. += "<span class='notice'>The anchoring screws are <i>unscrewed</i>. The rods look like they could be <b>cut</b> through.</span>"

/obj/structure/grille/ratvar_act()
	if(broken)
		new /obj/structure/grille/ratvar/broken(loc)
	else
		new /obj/structure/grille/ratvar(loc)
	qdel(src)

/obj/structure/grille/Bumped(atom/user)
	if(ismob(user))
		if(!(shockcooldown <= world.time))
			return
		shock(user, 70)
		shockcooldown = world.time + my_shockcooldown

/obj/structure/grille/attack_animal(mob/user)
	. = ..()
	if(. && !QDELETED(src) && !shock(user, 70))
		take_damage(rand(5,10), BRUTE, "melee", 1)

/obj/structure/grille/hulk_damage()
	return 60

/obj/structure/grille/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		if(!shock(user, 70))
			..(user, TRUE)
		return TRUE

/obj/structure/grille/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message("<span class='warning'>[user] hits [src].</span>")
	if(!shock(user, 70))
		take_damage(rand(5,10), BRUTE, "melee", 1)

/obj/structure/grille/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='warning'>[user] mangles [src].</span>")
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

/obj/structure/grille/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(istype(W, /obj/item/stack/rods) && broken)
		var/obj/item/stack/rods/R = W
		if(!shock(user, 90))
			user.visible_message("<span class='notice'>[user] rebuilds the broken grille.</span>", \
								 "<span class='notice'>You rebuild the broken grille.</span>")
			new grille_type(loc)
			R.use(1)
			qdel(src)
			return

//window placing begin
	else if(is_glass_sheet(W))
		build_window(W, user)
		return
//window placing end

	else if(istype(W, /obj/item/shard) || !shock(user, 70))
		return ..()

/obj/structure/grille/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(shock(user, 100))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct()

/obj/structure/grille/screwdriver_act(mob/user, obj/item/I)
	if(!(istype(loc, /turf/simulated) || anchored))
		return
	. = TRUE
	if(shock(user, 90))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	anchored = !anchored
	user.visible_message("<span class='notice'>[user] [anchored ? "fastens" : "unfastens"] [src].</span>", \
							"<span class='notice'>You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor.</span>")

/obj/structure/grille/proc/build_window(obj/item/stack/sheet/S, mob/user)
	var/dir_to_set = NORTH
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
	if(loc == user.loc)
		dir_to_set = user.dir
	else
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
	for(var/obj/structure/window/WINDOW in loc)
		if(WINDOW.dir == dir_to_set)
			to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
			return
	to_chat(user, "<span class='notice'>You start placing the window...</span>")
	if(do_after(user, 20, target = src))
		if(!loc || !anchored) //Grille destroyed or unanchored while waiting
			return
		for(var/obj/structure/window/WINDOW in loc)
			if(WINDOW.dir == dir_to_set)//checking this for a 2nd time to check if a window was made while we were waiting.
				to_chat(user, "<span class='notice'>There is already a window facing this way there.</span>")
				return
		var/obj/structure/window/W = new S.created_window(get_turf(src))
		S.use(1)
		W.setDir(dir_to_set)
		W.ini_dir = dir_to_set
		W.anchored = FALSE
		W.state = WINDOW_OUT_OF_FRAME
		to_chat(user, "<span class='notice'>You place the [W] on [src].</span>")
		W.update_nearby_icons()


/obj/structure/grille/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/grillehit.ogg', 80, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 80, TRUE)

/obj/structure/grille/deconstruct(disassembled = TRUE)
	if(!loc) //if already qdel'd somehow, we do nothing
		return
	if(!(flags & NODECONSTRUCT))
		var/obj/R = new rods_type(drop_location(), rods_amount)
		transfer_fingerprints_to(R)
		qdel(src)
	..()

/obj/structure/grille/obj_break()
	if(!broken && !(flags & NODECONSTRUCT))
		new broken_type(loc)
		var/obj/R = new rods_type(drop_location(), rods_broken)
		transfer_fingerprints_to(R)
		qdel(src)

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || broken)		// unanchored/broken grilles are never connected
		return FALSE
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src, 1, TRUE))
			do_sparks(3, 1, src)
			return TRUE
		else
			return FALSE
	return FALSE

/obj/structure/grille/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(!broken)
		if(exposed_temperature > T0C + 1500)
			take_damage(1, BURN, 0, 0)

/obj/structure/grille/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		if(prob(50) && anchored && !broken)
			var/obj/O = AM
			if(O.throwforce != 0)//don't want to let people spam tesla bolts, this way it will break after time
				var/turf/T = get_turf(src)
				var/obj/structure/cable/C = T.get_cable_node()
				if(C)
					playsound(src, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
					tesla_zap(src, 3, C.newavail() * 0.01) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
					C.add_delayedload(C.newavail() * 0.0375) // you can gain up to 3.5 via the 4x upgrades power is halved by the pole so thats 2x then 1X then .5X for 3.5x the 3 bounces shock.
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
