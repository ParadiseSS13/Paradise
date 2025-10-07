#define SINGLE "single"
#define VERTICAL "vertical"
#define HORIZONTAL "horizontal"

#define METAL 1
#define WOOD 2
#define SAND 3

#define DROPWALL_UPTIME 1 MINUTES

#define AUTO "automatic"

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

/obj/structure/barricade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/debris, DEBRIS_WOOD, -20, 10)

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

/obj/structure/barricade/CanPass(atom/movable/mover, border_dir)//So bullets will fly over and stuff.
	if(locate(/obj/structure/barricade) in get_turf(mover))
		return TRUE
	else if(istype(mover) && mover.checkpass(PASSBARRICADE))
		return TRUE
	else if(isprojectile(mover))
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
	icon_state = "woodenbarricade"
	bar_material = WOOD
	stacktype = /obj/item/stack/sheet/wood

/obj/structure/barricade/wooden/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(istype(I,/obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/W = I
		if(W.get_amount() < 5)
			to_chat(user, "<span class='warning'>You need at least five wooden planks to make a wall!</span>")
			return ITEM_INTERACT_COMPLETE
		else
			to_chat(user, "<span class='notice'>You start adding [I] to [src]...</span>")
			if(do_after(user, 50, target = src))
				if(!W.use(5))
					return ITEM_INTERACT_COMPLETE
				var/turf/T = get_turf(src)
				T.ChangeTurf(/turf/simulated/wall/mineral/wood/nonmetal)
				qdel(src)
			return ITEM_INTERACT_COMPLETE
	return ..()

/obj/structure/barricade/wooden/crowbar_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	user.visible_message("<span class='notice'>[user] starts ripping [src] down!</span>", "<span class='notice'>You struggle to pull [src] apart...</span>", "<span class='warning'>You hear wood splintering...</span>")
	if(!I.use_tool(src, user, 6 SECONDS, volume = I.tool_volume))
		return
	new /obj/item/stack/sheet/wood(get_turf(src), 5)
	qdel(src)

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
	pass_flags_self = LETPASSTHROW | PASSTAKE
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
	armor = list(MELEE = 10, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, RAD = 100, FIRE = 10, ACID = 0)
	stacktype = null
	var/deploy_time = 40
	var/deploy_message = TRUE

/obj/structure/barricade/security/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(deploy)), deploy_time)

/obj/structure/barricade/security/proc/deploy()
	icon_state = "barrier1"
	density = TRUE
	anchored = TRUE
	if(deploy_message)
		visible_message("<span class='warning'>[src] deploys!</span>")


/obj/item/grenade/barrier
	name = "barrier grenade"
	desc = "Instant cover."
	icon_state = "wallbang"
	worn_icon_state = "flashbang"
	inhand_icon_state = "flashbang"
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
			var/turf/target_turf = get_step(src, NORTH)
			if(!(target_turf.is_blocked_turf()))
				new /obj/structure/barricade/security(target_turf)

			var/turf/target_turf2 = get_step(src, SOUTH)
			if(!(target_turf2.is_blocked_turf()))
				new /obj/structure/barricade/security(target_turf2)
		if(HORIZONTAL)
			var/turf/target_turf = get_step(src, EAST)
			if(!(target_turf.is_blocked_turf()))
				new /obj/structure/barricade/security(target_turf)

			var/turf/target_turf2 = get_step(src, WEST)
			if(!(target_turf2.is_blocked_turf()))
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
	armor = list(MELEE = 0, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, RAD = 100, FIRE = 10, ACID = 0) // Copied from the security barrier, but no melee armor
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
		icon_state = "[dir2text(dir_1)][dir2text(dir_1 + dir_2)]"
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
	icon = 'icons/obj/dropwall.dmi'
	icon_state = "dropwall"
	worn_icon_state = "grenade"
	inhand_icon_state = "grenade"
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	mode = AUTO
	var/generator_type = /obj/structure/dropwall_generator
	var/uptime = DROPWALL_UPTIME
	/// If this is true we do not arm again, due to the sleep
	var/deployed = FALSE
	/// Mob who armed it. Needed for the get_dir proc
	var/armer

/obj/item/grenade/barrier/dropwall/toggle_mode(mob/user)
	switch(mode)
		if(AUTO)
			mode = NORTH
		if(NORTH)
			mode = EAST
		if(EAST)
			mode = SOUTH
		if(SOUTH)
			mode = WEST
		if(WEST)
			mode = AUTO

	to_chat(user, "[src] is now in [mode == AUTO ? mode : dir2text(mode)] mode.")

/obj/item/grenade/barrier/dropwall/attack_self__legacy__attackchain(mob/user)
	. = ..()
	armer = user


/obj/item/grenade/barrier/dropwall/end_throw()
	if(active)
		addtimer(CALLBACK(src, PROC_REF(prime)), 1) //Wait for the throw to fully end

/obj/item/grenade/barrier/dropwall/prime()
	if(deployed)
		return
	if(mode == AUTO)
		mode = angle2dir_cardinal(get_angle(armer, get_turf(src)))
	new generator_type(get_turf(loc), mode, uptime)
	deployed = TRUE
	armer = null
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
	/// The type of dropwall
	var/barricade_type = /obj/structure/barricade/dropwall

/obj/structure/dropwall_generator/Initialize(mapload, direction, uptime)
	. = ..()
	if(direction)
		deploy(direction, uptime)

/obj/structure/dropwall_generator/Destroy()
	QDEL_LIST_CONTENTS(connected_shields)
	core_shield = null
	return ..()

/obj/structure/dropwall_generator/proc/deploy(direction, uptime)
	anchored = TRUE
	protected = TRUE
	addtimer(CALLBACK(src, PROC_REF(power_out)), uptime)
	timer_overlay_proc(1)

	connected_shields += new barricade_type(get_turf(loc), src, TRUE, direction)
	core_shield = connected_shields[1]

	var/dir_left = turn(direction, -90)
	var/dir_right = turn(direction, 90)
	var/turf/target_turf = get_step(src, dir_left)
	if(!target_turf.is_blocked_turf())
		connected_shields += new barricade_type(target_turf, src, FALSE, direction, dir_left)

	var/turf/target_turf2 = get_step(src, dir_right)
	if(!target_turf2.is_blocked_turf())
		connected_shields += new barricade_type(target_turf2, src, FALSE, direction, dir_right)

/obj/structure/dropwall_generator/attacked_by(obj/item/I, mob/living/user)
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

/obj/structure/dropwall_generator/ex_act(severity)
	if(protected && severity > EXPLODE_DEVASTATE) //We would throw the explosion at the shield, but it is already getting hit
		return
	qdel(src)

/obj/structure/dropwall_generator/proc/power_out()
	visible_message("<span class='warning'>[src] runs out of power, causing its shields to fail!</span>")
	new /obj/item/used_dropwall(get_turf(src))
	qdel(src)

/obj/structure/dropwall_generator/proc/timer_overlay_proc(loops) // This proc will make the timer on the generator tick down like a clock, over 12 equally sized portions (12 times over 60 seconds, every 5 seconds by default)
	add_overlay("[loops]")
	if(loops != 1)
		cut_overlay("[(loops - 1)]")
	if(loops < 12)
		addtimer(CALLBACK(src, PROC_REF(timer_overlay_proc), loops + 1), DROPWALL_UPTIME / 12)

/obj/item/used_dropwall
	name = "broken dropwall generator"
	desc = "This dropwall has ran out of charge, but some materials could possibly be reclaimed."
	icon = 'icons/obj/dropwall.dmi'
	icon_state = "dropwall_dead"
	inhand_icon_state = "grenade"
	materials = list(MAT_METAL = 500, MAT_GLASS = 300) //plasma burned up for power or something, plus not that much to reclaim

/obj/item/storage/box/syndie_kit/dropwall
	name = "dropwall generator box"

/obj/item/storage/box/syndie_kit/dropwall/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/barrier/dropwall(src)

/obj/item/grenade/barrier/dropwall/firewall
	name = "firewall shield generator"
	generator_type = /obj/structure/dropwall_generator/firewall

/obj/structure/dropwall_generator/firewall
	name = "deployed firewall shield generator"
	barricade_type = /obj/structure/barricade/dropwall/firewall

/obj/structure/barricade/dropwall/firewall

/obj/structure/barricade/dropwall/firewall/Initialize(mapload, owner, core, dir_1, dir_2)
	. = ..()
	var/target_matrix = list(
		2, 0, 0, 0,
		0, 1, 0, 0,
		2, 0, 0, 0,
		0, 0, 0, 1
	)
	color = target_matrix
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/barricade/dropwall/firewall/proc/on_atom_entered(datum/source, atom/movable/entered)
	if(!isprojectile(entered))
		return
	var/obj/item/projectile/P = entered
	P.immolate ++

/obj/item/grenade/turret
	name = "Pop-Up Turret grenade"
	desc = "Inflates into a Pop-Up turret, shoots everyone on sight who wasn't the primer."
	icon_state = "wallbang"
	worn_icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	var/owner_uid

/obj/item/grenade/turret/attack_self__legacy__attackchain(mob/user)
	owner_uid = user.UID()
	return ..()

/obj/item/grenade/turret/prime()
	var/obj/machinery/porta_turret/inflatable_turret/turret = new(get_turf(loc))
	turret.owner_uid = owner_uid
	qdel(src)

/obj/structure/barricade/foam
	name = "foam blockage"
	desc = "This foam blocks the airlock from being opened."
	icon = 'icons/obj/foam_blobs.dmi'
	icon_state = "foamed_1"
	layer = DOOR_HELPER_LAYER
	// The integrity goes up with 25 per level, with an extra 25 when going from 4 to 5
	obj_integrity = 25
	max_integrity = 25
	/// What level is the foam at?
	var/foam_level = 1

/obj/structure/barricade/foam/Destroy()
	for(var/obj/machinery/door/airlock in loc.contents)
		airlock.foam_level = 0
	return ..()

/obj/structure/barricade/foam/examine(mob/user)
	. = ..()
	. += "It would need [(5 - foam_level)] more blobs of foam to fully block the airlock."

/obj/structure/barricade/foam/CanPass(atom/movable/mover, border_dir)
	return istype(mover, /obj/item/projectile/c_foam) // Only c_foam blobs hit the airlock underneat/pass through the foam. The rest is hitting the barricade

/obj/structure/barricade/foam/welder_act(mob/user, obj/item/I)
	return FALSE

#undef SINGLE
#undef VERTICAL
#undef HORIZONTAL

#undef METAL
#undef WOOD
#undef SAND


#undef DROPWALL_UPTIME

#undef AUTO
