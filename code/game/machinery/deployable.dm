#define SINGLE "single"
#define VERTICAL "vertical"
#define HORIZONTAL "horizontal"

#define METAL 1
#define WOOD 2
#define SAND 3

//Barricades/cover

/obj/structure/barricade
	name = "chest high wall"
	desc = "Looks like this would make good cover."
	anchored = TRUE
	density = TRUE
	max_integrity = 100
	var/proj_pass_rate = 50 //How many projectiles will pass the cover. Lower means stronger cover
	var/bar_material = METAL
	var/drop_amount = 3
	var/stacktype = /obj/item/stack/sheet/metal

/obj/structure/barricade/blob_act(obj/structure/blob/B) //TO-DO-OBJECT-DAMAGE: Kill off when everything is damageable
	take_damage(400, BRUTE, "melee", 0, get_dir(src, B))

/obj/structure/barricade/ex_act(severity) //TO-DO-OBJECT-DAMAGE: Kill off when everything is damageable
	if(resistance_flags & INDESTRUCTIBLE)
		return
	switch(severity)
		if(1)
			obj_integrity = 0
			qdel(src)
		if(2)
			take_damage(rand(100, 250), BRUTE, "bomb", 0)
		if(3)
			take_damage(rand(10, 90), BRUTE, "bomb", 0)

/obj/structure/barricade/mech_melee_attack(obj/mecha/M) //TO-DO-OBJECT-DAMAGE: Kill off when everything is damageable
	M.do_attack_animation(src)
	var/play_soundeffect = 0
	var/mech_damtype = M.damtype
	if(M.selected)
		mech_damtype = M.selected.damtype
		play_soundeffect = 1
	else
		switch(M.damtype)
			if(BRUTE)
				playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
			if(BURN)
				playsound(src, 'sound/items/welder.ogg', 50, 1)
			if(TOX)
				playsound(src, 'sound/effects/spray2.ogg', 50, 1)
				return 0
			else
				return 0
	visible_message("<span class='danger'>[M.name] has hit [src].</span>")
	return take_damage(M.force*3, mech_damtype, "melee", play_soundeffect, get_dir(src, M)) // multiplied by 3 so we can hit objs hard but not be overpowered against mobs.

/obj/structure/barricade/deconstruct(disassembled = TRUE)
	make_debris()
	qdel(src)

/obj/structure/barricade/proc/make_debris()
	if(stacktype)
		new stacktype(get_turf(src), drop_amount)

/obj/structure/barricade/attackby(obj/item/I, mob/user, params)
	if(iswelder(I) && user.a_intent != INTENT_HARM && bar_material == METAL)
		var/obj/item/weldingtool/WT = I
		if(obj_integrity < max_integrity)
			if(WT.remove_fuel(0, user))
				to_chat(user, "<span class='notice'>You begin repairing [src]...</span>")
				playsound(loc, WT.usesound, 40, 1)
				if(do_after(user, 40 * I.toolspeed, target = src))
					obj_integrity = Clamp(obj_integrity + 20, 0, max_integrity)
	else
		return ..()

/obj/structure/barricade/CanPass(atom/movable/mover, turf/target)//So bullets will fly over and stuff.
	if(locate(/obj/structure/barricade) in get_turf(mover))
		return TRUE
	else if(istype(mover, /obj/item/projectile))
		if(!anchored)
			return TRUE
		var/obj/item/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob(proj_pass_rate))
			return TRUE
		return FALSE
	else
		return !density



/////BARRICADE TYPES///////

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	bar_material = WOOD
	stacktype = /obj/item/stack/sheet/wood
	burn_state = FLAMMABLE
	burntime = 25

/obj/structure/barricade/wooden/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/W = I
		if(W.amount < 5)
			to_chat(user, "<span class='warning'>You need at least five wooden planks to make a wall!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You start adding [I] to [src]...</span>")
			if(do_after(user, 50, target = src))
				W.use(5)
				new /turf/simulated/wall/mineral/wood/nonmetal(get_turf(src))
				qdel(src)
				return
	return ..()

/obj/structure/barricade/wooden/crude
	name = "crude plank barricade"
	desc = "This space is blocked off by a crude assortment of planks."
	icon_state = "woodenbarricade-old"
	drop_amount = 1
	max_integrity = 50
	proj_pass_rate = 65

/obj/structure/barricade/wooden/crude/snow
	desc = "This space is blocked off by a crude assortment of planks. It seems to be covered in a layer of snow."
	icon_state = "woodenbarricade-snow-old"
	max_integrity = 75

/obj/structure/barricade/sandbags
	name = "sandbags"
	desc = "Bags of sand. Self explanatory."
	icon = 'icons/obj/smooth_structures/sandbags.dmi'
	icon_state = "sandbags"
	max_integrity = 280
	proj_pass_rate = 20
	pass_flags = LETPASSTHROW
	bar_material = SAND
	climbable = TRUE
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/barricade/sandbags, /turf/simulated/wall, /turf/simulated/wall/r_wall, /obj/structure/falsewall, /obj/structure/falsewall/reinforced, /turf/simulated/wall/rust, /turf/simulated/wall/r_wall/rust, /obj/structure/barricade/security)
	stacktype = null

/obj/structure/barricade/security
	name = "security barrier"
	desc = "A deployable barrier. Provides good cover in fire fights."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	density = FALSE
	anchored = FALSE
	max_integrity = 180
	proj_pass_rate = 20
	armor = list(melee = 10, bullet = 50, laser = 50, energy = 50, bomb = 10, bio = 100, rad = 100)
	stacktype = null
	var/deploy_time = 40
	var/deploy_message = TRUE

/obj/structure/barricade/security/New()
	..()
	addtimer(CALLBACK(src, .proc/deploy), deploy_time)

/obj/structure/barricade/security/proc/deploy()
	icon_state = "barrier1"
	density = TRUE
	anchored = TRUE
	if(deploy_message)
		visible_message("<span class='warning'>[src] deploys!</span>")


/obj/item/grenade/barrier
	name = "barrier grenade"
	desc = "Instant cover."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	item_state = "flashbang"
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	var/mode = SINGLE

/obj/item/grenade/barrier/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Alt-click to toggle modes.</span>")

/obj/item/grenade/barrier/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.Adjacent(src) || user.incapacitated())
		return
	toggle_mode(user)

/obj/item/grenade/barrier/proc/toggle_mode(mob/user)
	switch(mode)
		if(SINGLE)
			mode = VERTICAL
		if(VERTICAL)
			mode = HORIZONTAL
		if(HORIZONTAL)
			mode = SINGLE

	to_chat(user, "[src] is now in [mode] mode.")

/obj/item/grenade/barrier/prime()
	new /obj/structure/barricade/security(get_turf(loc))
	switch(mode)
		if(VERTICAL)
			var/target_turf = get_step(src, NORTH)
			if(!(is_blocked_turf(target_turf)))
				new /obj/structure/barricade/security(target_turf)

			var/target_turf2 = get_step(src, SOUTH)
			if(!(is_blocked_turf(target_turf2)))
				new /obj/structure/barricade/security(target_turf2)
		if(HORIZONTAL)
			var/target_turf = get_step(src, EAST)
			if(!(is_blocked_turf(target_turf)))
				new /obj/structure/barricade/security(target_turf)

			var/target_turf2 = get_step(src, WEST)
			if(!(is_blocked_turf(target_turf2)))
				new /obj/structure/barricade/security(target_turf2)
	qdel(src)

/obj/item/grenade/barrier/ui_action_click(mob/user)
	toggle_mode(user)


/obj/structure/barricade/mime
	name = "floor"
	desc = "Is... this a floor?"
	icon = 'icons/effects/water.dmi'
	icon_state = "wet_floor_static"
	stacktype = /obj/item/stack/sheet/mineral/tranquillite

/obj/structure/barricade/mime/mrcd
	stacktype = null

#undef SINGLE
#undef VERTICAL
#undef HORIZONTAL

#undef METAL
#undef WOOD
#undef SAND