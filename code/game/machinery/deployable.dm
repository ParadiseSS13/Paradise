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
			if(direction_check(turn(proj.dir, 180)))
				return FALSE
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob(proj_pass_rate))
			return TRUE
		return FALSE
	else
		return !density

/obj/structure/barricade/proc/direction_check(angle)
	for(var/i in directional_list)
		if(i == angle)
			return TRUE
	return FALSE

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
	desc = "pipis"
	icon = 'icons/effects/effects.dmi'
	icon_state = "m_shield"
	directional_blockage = TRUE
	proj_pass_rate = 100 //don't worry about it, covered by directional blockage.
	stacktype = null
	/// This variable is used to tell the shield to ping it's owner when it is broke.
	var/core_shield = FALSE
	/// This variable is to tell the shield what it's source is.
	var/obj/item/grenade/dropwall/source = null

/obj/structure/barricade/dropwall/Initialize(mapload, owner, core, dir_1, dir_2)
	. = ..()
	source = owner
	core_shield = core
	directional_list += dir_1
	directional_list += dir_2

/obj/structure/barricade/dropwall/Destroy()
	if(core_shield)
		source.protected = FALSE
	return ..()

/obj/item/grenade/dropwall //gonna be one of those days TODO MAKE THIS ATTACKABLE SO YOU CAN WACK IT
	name = "dropwall generator thing"
	desc = "the pipis powered cells keep the shield running yaya"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	item_state = "flashbang"
	max_integrity = 25 // 2 shots
	var/list/connected_shields = list()
	/// This variable is used to prevent damage to it's core shield when it is up.
	var/protected = FALSE
	///The core shield that protects the generator
	var/obj/structure/barricade/dropwall/core_shield = null

/obj/item/grenade/dropwall/prime()
	anchored = 1
	protected = TRUE
	connected_shields += new /obj/structure/barricade/dropwall(get_turf(loc), src, TRUE, NORTH)
	for(var/i in connected_shields)
		core_shield = i

	var/target_turf = get_step(src, EAST)
	if(!(is_blocked_turf(target_turf)))
		connected_shields += new /obj/structure/barricade/dropwall(target_turf, src, FALSE, NORTH, EAST)

	var/target_turf2 = get_step(src, WEST)
	if(!(is_blocked_turf(target_turf2)))
		connected_shields += new /obj/structure/barricade/dropwall(target_turf2, src, FALSE, NORTH, WEST)
			//var/target_turf = get_step(src, EAST)
			//if(!(is_blocked_turf(target_turf)))
				//new /obj/structure/barricade/security(target_turf)

			//var/target_turf2 = get_step(src, WEST)
			//if(!(is_blocked_turf(target_turf2)))
				//new /obj/structure/barricade/security(target_turf2)

/obj/item/grenade/dropwall/deconstruct(disassembled = TRUE) // No. Do not prime again when destroyed.
	if(!QDELETED(src))
		qdel(src)

/obj/item/grenade/dropwall/attacked_by(obj/item/I, mob/living/user) //No, you can not just go up to the generator and whack it. Central shield needs to go down first.
	if(protected)
		visible_message("<span class='warning'>[src]'s shield absorbs the blow!</span>")
		core_shield.take_damage(I.force, I.damtype, MELEE, 1)
	else
		. = ..()

/obj/item/grenade/dropwall/bullet_act(obj/item/projectile/P)
	if(protected)
		visible_message("<span class='warning'>[src]'s shield absorbs the blow!</span>")
		core_shield.take_damage(P.damage, P.damage_type, P.flag)
	else
		. = ..()

/obj/item/grenade/dropwall/Destroy()
	QDEL_NULL(connected_shields)

#undef SINGLE
#undef VERTICAL
#undef HORIZONTAL

#undef METAL
#undef WOOD
#undef SAND
