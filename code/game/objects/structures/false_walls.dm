/*
 * False Walls
 */

// Minimum pressure difference to fail building falsewalls.
// Also affects admin alerts.
#define FALSEDOOR_MAX_PRESSURE_DIFF 25.0

/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	anchored = TRUE
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	flags_2 = RAD_PROTECT_CONTENTS_2 | RAD_NO_CONTAMINATE_2
	rad_insulation = RAD_MEDIUM_INSULATION
	layer = TURF_LAYER

	var/mineral = /obj/item/stack/sheet/metal
	var/mineral_amount = 2
	var/walltype = /turf/simulated/wall
	var/girder_type = /obj/structure/girder/displaced
	var/opening = FALSE
	/// Minimum environment smash level (found on simple animals) to break through this instantly
	var/env_smash_level = ENVIRONMENT_SMASH_STRUCTURES

	density = TRUE
	opacity = TRUE
	max_integrity = 100

	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_SIMULATED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_REGULAR_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_REGULAR_WALLS, SMOOTH_GROUP_REINFORCED_WALLS)

/obj/structure/falsewall/Initialize(mapload)
	. = ..()
	air_update_turf(1)

/obj/structure/falsewall/examine_status(mob/user)
	var/healthpercent = (obj_integrity/max_integrity) * 100
	switch(healthpercent)
		if(100)
			. += "<span class='notice'>It looks fully intact.</span>"
		if(70 to 99)
			. +=  "<span class='warning'>It looks slightly damaged.</span>"
		if(40 to 70)
			. +=  "<span class='warning'>It looks moderately damaged.</span>"
		if(0 to 40)
			. += "<span class='danger'>It looks heavily damaged.</span>"
	. += "<br><span class='notice'>Using a lit welding tool on this item will allow you to slice through it, eventually removing the outer layer.</span>"

/obj/structure/falsewall/Destroy()
	density = FALSE
	air_update_turf(1)
	return ..()

/obj/structure/falsewall/CanAtmosPass(turf/T)
	return !density

/obj/structure/falsewall/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		toggle(user)

/obj/structure/falsewall/attack_hand(mob/user)
	toggle(user)

/obj/structure/falsewall/proc/toggle(mob/user)
	if(opening)
		return
	opening = TRUE
	if(density)
		flick("fwall_opening", src)
		density = FALSE
		set_opacity(FALSE)
		clear_smooth_overlays()
		icon_state = "fwall_opening"
	else
		var/srcturf = get_turf(src)
		for(var/mob/living/obstacle in srcturf) //Stop people from using this as a shield
			opening = FALSE
			return
		flick("fwall_closing", src)
		density = TRUE
		set_opacity(TRUE)
		icon_state = "fwall_closing"
	air_update_turf(TRUE)
	opening = FALSE
	update_icon()

/obj/structure/falsewall/update_icon_state()
	if(opening)
		smoothing_flags = NONE
		clear_smooth_overlays()
		if(density)
			icon_state = "fwall_opening"
			return
		icon_state = "fwall_closing"
		return
	if(!density)
		icon_state = "fwall_open"
		return
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_OBJ
	icon_state = initial(icon_state)
	icon_state = "[base_icon_state]-[smoothing_junction]"
	QUEUE_SMOOTH(src)

/obj/structure/falsewall/proc/ChangeToWall(delete = TRUE)
	var/turf/T = get_turf(src)
	T.ChangeTurf(walltype)
	if(delete)
		qdel(src)
	return T

/obj/structure/falsewall/attackby(obj/item/W, mob/user, params)
	if(opening)
		to_chat(user, "<span class='warning'>You must wait until the door has stopped moving.</span>")
		return

	if(istype(W, /obj/item/gun/energy/plasmacutter) || istype(W, /obj/item/pickaxe/drill/diamonddrill) || istype(W, /obj/item/pickaxe/drill/jackhammer) || istype(W, /obj/item/melee/energy/blade) || istype(W, /obj/item/pyro_claws))
		dismantle(user, TRUE)

/obj/structure/falsewall/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(. && M.environment_smash >= env_smash_level)
		deconstruct(FALSE)
		to_chat(M, "<span class='info'>You smash through the wall.</span>")

/obj/structure/falsewall/screwdriver_act(mob/living/user, obj/item/I)
	if(opening)
		to_chat(user, "<span class='warning'>You must wait until the door has stopped moving.</span>")
		return TRUE
	if(!density)
		to_chat(user, "<span class='warning'>You can't reach, close it first!</span>")
		return TRUE
	var/turf/T = get_turf(src)
	if(T.density)
		to_chat(user, "<span class='warning'>[src] is blocked!</span>")
		return TRUE

	if(!isfloorturf(T))
		to_chat(user, "<span class='warning'>[src] bolts must be tightened on the floor!</span>")
		return TRUE
	user.visible_message("<span class='notice'>[user] tightens some bolts on the wall.</span>", "<span class='warning'>You tighten the bolts on the wall.</span>")
	ChangeToWall()
	return TRUE

/obj/structure/falsewall/welder_act(mob/user, obj/item/I)
	if(!density)
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	dismantle(user, TRUE)

/obj/structure/falsewall/proc/dismantle(mob/user, disassembled = TRUE)
	user.visible_message("<span class='notice'>[user] dismantles the false wall.</span>", "<span class='warning'>You dismantle the false wall.</span>")
	playsound(src, 'sound/items/welder.ogg', 100, TRUE)
	deconstruct(disassembled)

/obj/structure/falsewall/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(disassembled)
			new girder_type(loc)
		if(mineral_amount)
			for(var/i in 1 to mineral_amount)
				new mineral(loc)
	qdel(src)

/*
 * False R-Walls
 */

/obj/structure/falsewall/reinforced
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	walltype = /turf/simulated/wall/r_wall
	mineral = /obj/item/stack/sheet/plasteel
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_SIMULATED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_REINFORCED_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_REGULAR_WALLS, SMOOTH_GROUP_REINFORCED_WALLS)

/obj/structure/falsewall/reinforced/examine_status(mob/user)
	. = ..()
	. += "<br><span class='notice'>The outer <b>grille</b> is fully intact.</span>"	//not going to fake other states of disassembly

/obj/structure/falsewall/reinforced/ChangeToWall(delete = 1)
	var/turf/T = get_turf(src)
	T.ChangeTurf(/turf/simulated/wall/r_wall)
	if(delete)
		qdel(src)
	return T

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium_wall-0"
	base_icon_state = "uranium_wall"
	mineral = /obj/item/stack/sheet/mineral/uranium
	walltype = /turf/simulated/wall/mineral/uranium
	var/active = FALSE
	var/last_event = 0
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_URANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_URANIUM_WALLS)

/obj/structure/falsewall/uranium/attackby(obj/item/W as obj, mob/user as mob, params)
	radiate()
	..()

/obj/structure/falsewall/uranium/attack_hand(mob/user as mob)
	radiate()
	..()

/obj/structure/falsewall/uranium/proc/radiate()
	if(!active)
		if(world.time > last_event + 1.5 SECONDS)
			active = TRUE
			radiation_pulse(src, 150)
			for(var/turf/simulated/wall/mineral/uranium/T in orange(1, src))
				T.radiate()
			last_event = world.time
			active = FALSE
/*
 * Other misc falsewall types
 */

/obj/structure/falsewall/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon = 'icons/turf/walls/gold_wall.dmi'
	icon_state = "gold_wall-0"
	base_icon_state = "gold_wall"
	mineral = /obj/item/stack/sheet/mineral/gold
	walltype = /turf/simulated/wall/mineral/gold
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_GOLD_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_GOLD_WALLS)

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver_wall-0"
	base_icon_state = "silver_wall"
	mineral = /obj/item/stack/sheet/mineral/silver
	walltype = /turf/simulated/wall/mineral/silver
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_SILVER_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_SILVER_WALLS)

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond_wall-0"
	base_icon_state = "diamond_wall"
	mineral = /obj/item/stack/sheet/mineral/diamond
	walltype = /turf/simulated/wall/mineral/diamond
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_DIAMOND_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_DIAMOND_WALLS)
	max_integrity = 800


/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definitely a bad idea."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma_wall-0"
	base_icon_state = "plasma_wall"
	mineral = /obj/item/stack/sheet/mineral/plasma
	walltype = /turf/simulated/wall/mineral/plasma
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_PLASMA_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_PLASMA_WALLS)

/obj/structure/falsewall/plasma/attackby(obj/item/W, mob/user, params)
	if(is_hot(W) > 300)
		var/turf/T = locate(user)
		message_admins("Plasma falsewall ignited by [key_name_admin(user)] in [ADMIN_VERBOSEJMP(T)]")
		log_game("Plasma falsewall ignited by [key_name(user)] in [AREACOORD(T)]")
		investigate_log("was <font color='red'><b>ignited</b></font> by [key_name(user)]","atmos")
		burnbabyburn()
	else
		return ..()

/obj/structure/falsewall/plasma/proc/burnbabyburn(user)
	playsound(src, 'sound/items/welder.ogg', 100, 1)
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 400)
	new /obj/structure/girder/displaced(loc)
	qdel(src)

/obj/structure/falsewall/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		burnbabyburn()

/obj/structure/falsewall/alien
	name = "alien wall"
	desc = "A strange-looking alien wall."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor_wall-0"
	base_icon_state = "abductor_wall"
	mineral = /obj/item/stack/sheet/mineral/abductor
	walltype = /turf/simulated/wall/mineral/abductor
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_ABDUCTOR_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ABDUCTOR_WALLS)


/obj/structure/falsewall/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium_wall-0"
	base_icon_state = "bananium_wall"
	mineral = /obj/item/stack/sheet/mineral/bananium
	walltype = /turf/simulated/wall/mineral/bananium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_BANANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_BANANIUM_WALLS)

/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone_wall-0"
	base_icon_state = "sandstone_wall"
	mineral = /obj/item/stack/sheet/mineral/sandstone
	walltype = /turf/simulated/wall/mineral/sandstone
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_SANDSTONE_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_SANDSTONE_WALLS)

/obj/structure/falsewall/wood
	name = "wooden wall"
	desc = "A wall with wooden plating. Stiff."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	mineral = /obj/item/stack/sheet/wood
	walltype = /turf/simulated/wall/mineral/wood
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_WOOD_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WOOD_WALLS)

/obj/structure/falsewall/iron
	name = "rough metal wall"
	desc = "A wall with rough metal plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron_wall-0"
	base_icon_state = "iron_wall"
	mineral = /obj/item/stack/rods
	mineral_amount = 5
	walltype = /turf/simulated/wall/mineral/iron
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_IRON_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_IRON_WALLS)

/obj/structure/falsewall/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor_wall-0"
	base_icon_state = "abductor_wall"
	mineral = /obj/item/stack/sheet/mineral/abductor
	walltype = /turf/simulated/wall/mineral/abductor
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_ABDUCTOR_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ABDUCTOR_WALLS)

/obj/structure/falsewall/titanium
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/plastinum_wall.dmi'
	icon_state = "plastinum_wall-0"
	base_icon_state = "plastinum_wall"
	mineral = /obj/item/stack/sheet/mineral/titanium
	walltype = /turf/simulated/wall/mineral/titanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_TITANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_TITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS)

/obj/structure/falsewall/plastitanium
	desc = "An evil wall of plasma and titanium."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	mineral = /obj/item/stack/sheet/mineral/plastitanium
	walltype = /turf/simulated/wall/mineral/plastitanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_PLASTITANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_PLASTITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS)

/obj/structure/falsewall/brass
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall-0"
	base_icon_state = "clockwork_wall"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	mineral_amount = 1
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_BRASS_WALL)
	canSmoothWith = list(SMOOTH_GROUP_BRASS_WALL)
	girder_type = /obj/structure/clockwork/wall_gear/displaced
	walltype = /turf/simulated/wall/clockwork
	mineral = /obj/item/stack/tile/brass

/obj/structure/falsewall/brass/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/ratvar/wall/false(T)
	new /obj/effect/temp_visual/ratvar/beam/falsewall(T)

/obj/structure/falsewall/rock_ancient
	name = "ancient rock"
	desc = "A rare asteroid rock that appears to be resistant to all mining tools except pickaxes!"
	icon = 'icons/turf/walls/smoothrocks.dmi'
	icon_state = "smoothrocks-0"
	base_icon_state = "smoothrocks"
	color = COLOR_ANCIENT_ROCK
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_ASTEROID_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_ASTEROID_WALLS)
	mineral = /obj/item/stack/ore/glass/basalt/ancient
	walltype = /turf/simulated/mineral/ancient
