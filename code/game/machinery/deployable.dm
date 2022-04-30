#define SINGLE "single"
#define VERTICAL "vertical"
#define HORIZONTAL "horizontal"

#define METAL 1
#define WOOD 2
#define SAND 3

#define DROPWALL_UPTIME 12

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
	/// This variable is used to allow projectiles to always shoot through a barrier from a certain direction
	var/directional_blockage = FALSE
	//The list of directions to block a projectile from
	var/list/directional_list = list()

/obj/structure/barricade/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		make_debris()
	qdel(src)

/obj/structure/barricade/proc/make_debris()
	if(stacktype)
		new stacktype(get_turf(src), drop_amount)

/obj/structure/barricade/welder_act(mob/user, obj/item/I)
	if(bar_material != METAL)
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
		return
	if(user.a_intent == INTENT_HARM)
		return
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_REPAIR_SUCCESS_MESSAGE
		obj_integrity = clamp(obj_integrity + 20, 0, max_integrity)
		update_icon()
	return TRUE

/obj/structure/barricade/CanPass(atom/movable/mover, turf/target)//So bullets will fly over and stuff.
	if(locate(/obj/structure/barricade) in get_turf(mover))
		return TRUE
	else if(istype(mover, /obj/item/projectile))
		if(!anchored)
			return TRUE
		var/obj/item/projectile/proj = mover
		if(directional_blockage)
			if(one_eighty_check(mover))
				return FALSE
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob(proj_pass_rate))
			return TRUE
		return FALSE
	if(isitem(mover)) //thrown items with the dropwall
		if(directional_blockage)
			if(one_eighty_check(mover))
				return FALSE
	return !density

/obj/structure/barricade/proc/one_eighty_check(atom/movable/mover)
	return turn(mover.dir, 180) in directional_list

/////BARRICADE TYPES///////

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	bar_material = WOOD
	stacktype = /obj/item/stack/sheet/wood


/obj/structure/barricade/wooden/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/W = I
		if(W.get_amount() < 5)
			to_chat(user, "<span class='warning'>You need at least five wooden planks to make a wall!</span>")
			return
		else
			to_chat(user, "<span class='notice'>You start adding [I] to [src]...</span>")
			if(do_after(user, 50, target = src))
				if(!W.use(5))
					return
				var/turf/T = get_turf(src)
				T.ChangeTurf(/turf/simulated/wall/mineral/wood/nonmetal)
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
	icon_state = "sandbags-0"
	base_icon_state = "sandbags"
	max_integrity = 280
	proj_pass_rate = 20
	pass_flags = LETPASSTHROW
	bar_material = SAND
	climbable = TRUE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_SANDBAGS)
	canSmoothWith = list(SMOOTH_GROUP_SANDBAGS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_SECURITY_BARRICADE)
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
	armor = list(melee = 10, bullet = 50, laser = 50, energy = 50, bomb = 10, bio = 100, rad = 100, fire = 10, acid = 0)
	stacktype = null
	var/deploy_time = 40
	var/deploy_message = TRUE

/obj/structure/barricade/security/Initialize(mapload)
	. = ..()
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
	. += "<span class='notice'>Alt-click to toggle modes.</span>"

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

/obj/structure/barricade/dropwall
	name = "dropwall"
	desc = "A temporary deployable energy shield powered by a generator. Breaking the generator will destroy all the shields connected to it."
	icon = 'icons/obj/dropwall.dmi'
	icon_state = "dropwall_dead" //sprite chosen in init
	density = FALSE
	directional_blockage = TRUE
	proj_pass_rate = 100 //don't worry about it, covered by directional blockage.
	stacktype = null
	/// This variable is used to tell the shield to ping it's owner when it is broke.
	var/core_shield = FALSE
	/// This variable is to tell the shield what it's source is.
	var/obj/structure/dropwall_generator/source = null
	explosion_block = 8 //should be enough for a potasium water nade that isn't a maxcap. If you stand next to a maxcap with this however, it will end poorly

/obj/structure/barricade/dropwall/Initialize(mapload, owner, core, dir_1, dir_2)
	. = ..()
	source = owner
	core_shield = core
	directional_list += dir_1
	directional_list += dir_2
	if(dir_2)
		icon_state = "[dir2text(dir_1 + dir_2)]"
	else
		icon_state = "[dir2text(dir_1)]"

/obj/structure/barricade/dropwall/Destroy()
	if(core_shield)
		source.protected = FALSE
	source = null
	return ..()

/obj/structure/barricade/dropwall/emp_act(severity)
	..()
	take_damage(40 / severity, BRUTE) //chances are the EMP will also hit the generator, we don't want it to double up too heavily

/obj/structure/barricade/dropwall/bullet_act(obj/item/projectile/P)
	if(P.shield_buster)
		qdel(src)
	else
		return ..()

/obj/item/grenade/barrier/dropwall
	name = "dropwall shield generator"
	desc = "This generator designed by Shellguard Munitions's spartan division is used to deploy a temporary cover that blocks projectiles and explosions from a direction, while allowing projectiles to pass freely from behind."
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	icon = 'icons/obj/dropwall.dmi'
	icon_state = "dropwall"
	mode = NORTH
	var/uptime = DROPWALL_UPTIME SECONDS

/obj/item/grenade/barrier/dropwall/toggle_mode(mob/user)
	switch(mode)
		if(NORTH)
			mode = EAST
		if(EAST)
			mode = SOUTH
		if(SOUTH)
			mode = WEST
		if(WEST)
			mode = NORTH

	to_chat(user, "[src] is now in [dir2text(mode)] mode.")

/obj/item/grenade/barrier/dropwall/prime()
	new /obj/structure/dropwall_generator(get_turf(loc), mode, uptime)
	qdel(src)

/obj/structure/dropwall_generator
	name = "deployed dropwall shield generator"
	desc = "This generator designed by Shellguard Munitions's spartan division is used to deploy a temporary cover that blocks projectiles and explosions from a direction, while allowing projectiles to pass freely from behind."
	icon = 'icons/obj/dropwall.dmi'
	icon_state = "dropwall_deployed"
	max_integrity = 25 // 2 shots
	var/list/connected_shields = list()
	/// This variable is used to prevent damage to it's core shield when it is up.
	var/protected = FALSE
	///The core shield that protects the generator
	var/obj/structure/barricade/dropwall/core_shield = null

/obj/structure/dropwall_generator/Initialize(mapload, direction, uptime)
	. = ..()
	if(direction)
		deploy(direction, uptime)

/obj/structure/dropwall_generator/Destroy()
	QDEL_LIST(connected_shields)
	core_shield = null
	return ..()

/obj/structure/dropwall_generator/proc/deploy(direction, uptime)
	anchored = TRUE
	protected = TRUE
	addtimer(CALLBACK(src, .proc/power_out), uptime)
	timer_overlay_proc(uptime/10)

	connected_shields += new /obj/structure/barricade/dropwall(get_turf(loc), src, TRUE, direction)
	core_shield = connected_shields[1]

	var/dir_left = turn(direction, -90)
	var/dir_right = turn(direction, 90)
	var/target_turf = get_step(src, dir_left)
	if(!is_blocked_turf(target_turf))
		connected_shields += new /obj/structure/barricade/dropwall(target_turf, src, FALSE, direction, dir_left)

	var/target_turf2 = get_step(src, dir_right)
	if(!is_blocked_turf(target_turf2))
		connected_shields += new /obj/structure/barricade/dropwall(target_turf2, src, FALSE, direction, dir_right)


/obj/structure/dropwall_generator/attacked_by(obj/item/I, mob/living/user) //No, you can not just go up to the generator and whack it. Central shield needs to go down first.
	if(protected)
		visible_message("<span class='warning'>[src]'s shield absorbs the blow!</span>")
		core_shield.take_damage(I.force, I.damtype, MELEE, TRUE)
	else
		return ..()

/obj/structure/dropwall_generator/bullet_act(obj/item/projectile/P)
	if(!protected)
		return ..()
	else
		visible_message("<span class='warning'>[src]'s shield absorbs the blow!</span>")
		core_shield.take_damage(P.damage, P.damage_type, P.flag)

/obj/structure/dropwall_generator/emp_act(severity)
	..()
	if(protected)
		for(var/obj/structure/barricade/dropwall/O in connected_shields)
			O.emp_act(severity)
	else
		qdel(src)

/obj/structure/dropwall_generator/proc/power_out()
	visible_message("<span class='warning'>[src] runs out of power, causing its shields to fail!</span>")
	new /obj/item/used_dropwall(get_turf(src))
	qdel(src)

/obj/structure/dropwall_generator/proc/timer_overlay_proc(uptime) // This proc will make the timer on the generator tick down like a clock, over 12 equally sized portions (12 times over 12 seconds, every second by default)
	var/cycle = DROPWALL_UPTIME + 1 - uptime
	add_overlay("[cycle]")
	if(cycle != 1)
		cut_overlay("[(cycle - 1)]")
	if(cycle < 12)
		addtimer(CALLBACK(src, .proc/timer_overlay_proc, uptime - 1), DROPWALL_UPTIME / 12 SECONDS)


/obj/item/used_dropwall
	name = "broken dropwall generator"
	desc = "This dropwall has ran out of charge, but some materials could possibly be reclamed."
	icon = 'icons/obj/dropwall.dmi'
	icon_state = "dropwall_dead"
	item_state = "flashbang"
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2500) //plasma burned up for power or something, plus not that much to reclaim


/obj/item/storage/box/syndie_kit/dropwall
	name = "dropwall generator box"

/obj/item/storage/box/syndie_kit/dropwall/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/barrier/dropwall(src)

#undef SINGLE
#undef VERTICAL
#undef HORIZONTAL

#undef METAL
#undef WOOD
#undef SAND


#undef DROPWALL_UPTIME
