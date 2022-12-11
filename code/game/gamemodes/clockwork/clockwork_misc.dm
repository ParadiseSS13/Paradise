// Dead Ratvar
/obj/structure/dead_ratvar
	name = "hulking wreck"
	desc = "The remains of a monstrous war machine."
	icon = 'icons/obj/lavaland/dead_ratvar.dmi'
	icon_state = "dead_ratvar"
	flags = ON_BORDER
	appearance_flags = 0
	layer = FLY_LAYER
	anchored = TRUE
	density = TRUE
	bound_width = 416
	bound_height = 64
	pixel_y = -10
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/clockwork
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

// An "overlay" used by clockwork walls and floors to appear normal to mesons.
/obj/effect/clockwork/overlay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/atom/linked

/obj/effect/clockwork/overlay/examine(mob/user)
	if(linked)
		return linked.examine(user)

/obj/effect/clockwork/overlay/ex_act()
	return FALSE

/obj/effect/clockwork/overlay/singularity_act()
	return

/obj/effect/clockwork/overlay/singularity_pull()
	return

/obj/effect/clockwork/overlay/singularity_pull(S, current_size)
	return

/obj/effect/clockwork/overlay/Destroy()
	if(linked)
		linked = null
	. = ..()

/obj/effect/clockwork/overlay/wall
	name = "clockwork wall"
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall"
	canSmoothWith = list(/obj/effect/clockwork/overlay/wall, /obj/structure/falsewall/brass)
	smooth = SMOOTH_TRUE
	layer = CLOSED_TURF_LAYER

/obj/effect/clockwork/overlay/wall/Initialize(mapload)
	. = ..()
	queue_smooth_neighbors(src)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/queue_smooth, src), 1)

/obj/effect/clockwork/overlay/wall/Destroy()
	queue_smooth_neighbors(src)
	return ..()

/obj/effect/clockwork/overlay/floor
	icon = 'icons/turf/floors.dmi'
	icon_state = "clockwork_floor"
	layer = TURF_LAYER
	plane = FLOOR_PLANE

/obj/item/clockwork/clockgolem_remains
	name = "clockwork golem scrap"
	desc = "A pile of scrap metal. It seems damaged beyond repair."
	icon_state = "clockgolem_dead"

/obj/item/clockwork/fallen_armor
	name = "fallen armor"
	desc = "Lifeless chunks of armor. They're designed in a strange way and won't fit on you."
	icon_state = "fallen_armor"
	w_class = WEIGHT_CLASS_NORMAL

// Gibs
/obj/effect/decal/cleanable/blood/gibs/clock
	name = "clockwork debris"
	desc = "Some useless mass of gears and junk."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "gib1"
	basecolor = "#B18B25"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/blood/gibs/clock/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/clock/update_icon()
	color = "#FFFFFF"

/obj/effect/decal/cleanable/blood/gibs/clock/dry()
	return

/obj/effect/decal/cleanable/blood/gibs/clock/streak(var/list/directions)
	set waitfor = FALSE
	var/direction = pick(directions)
	for(var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
		sleep(0.3 SECONDS)
		if(i > 0)
			if(prob(40))
				var/obj/effect/decal/cleanable/blood/clock/streak = new(src.loc)
				streak.update_icon()
			else if(prob(10))
				do_sparks(3, 1, src)
		if(step_to(src, get_step(src, direction), 0))
			break

/obj/effect/decal/cleanable/blood/clock
	name = "strange liquid"
	desc = "It's yellow with orange tint. It looks like an oil."
	basecolor = "#B18B25"
	bloodiness = MAX_SHOE_BLOODINESS

/obj/effect/decal/cleanable/blood/clock/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/clock/dry()
	return

/obj/effect/decal/cleanable/blood/clock/streak
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

// Walls, Gears, Windows

// Wall gears
//A massive gear, effectively a girder for clocks.
/obj/structure/clockwork/wall_gear
	name = "massive gear"
	icon_state = "gear"
	climbable = TRUE
	max_integrity = 100
	anchored = TRUE
	density = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	desc = "A massive brass gear. You could probably secure or unsecure it with a wrench, or just climb over it."

/obj/structure/clockwork/wall_gear/displaced
	anchored = FALSE

/obj/structure/clockwork/wall_gear/Initialize()
	. = ..()
	new /obj/effect/temp_visual/ratvar/gear(get_turf(src))

/obj/structure/clockwork/wall_gear/emp_act(severity)
	return

/obj/structure/clockwork/wall_gear/narsie_act()
	if(prob(25))
		new /obj/structure/girder/cult(loc)
		qdel(src)

/obj/structure/clockwork/wall_gear/ratvar_act()
	return

/obj/structure/clockwork/wall_gear/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(anchored)
		to_chat(user, "<span class='warning'>[src] needs to be unsecured to disassemble it!</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(TRUE)

/obj/structure/clockwork/wall_gear/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I, 10)

/obj/structure/clockwork/wall_gear/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/brass))
		var/obj/item/stack/sheet/brass/W = I
		if(W.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one brass sheet to do this!</span>")
			return
		var/turf/T = get_turf(src)
		if(iswallturf(T))
			to_chat(user, "<span class='warning'>There is already a wall present!</span>")
			return
		if(!isfloorturf(T))
			to_chat(user, "<span class='warning'>A floor must be present to build a [anchored ? "false ":""]wall!</span>")
			return
		if(locate(/obj/structure/falsewall) in T.contents)
			to_chat(user, "<span class='warning'>There is already a false wall present!</span>")
			return
		to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
		if(do_after(user, 2 SECONDS, target = src))
			var/brass_floor = FALSE
			if(istype(T, /turf/simulated/floor/clockwork)) //if the floor is already brass, costs less to make(conservation of masssssss)
				brass_floor = TRUE
			if(W.use(2 - brass_floor))
				if(anchored)
					T.ChangeTurf(/turf/simulated/wall/clockwork)
				else
					T.ChangeTurf(/turf/simulated/floor/clockwork)
					new /obj/structure/falsewall/brass(T)
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You need more brass to make a [anchored ? "false ":""]wall!</span>")
		return TRUE
	return ..()

/obj/structure/clockwork/wall_gear/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT) && disassembled)
		new /obj/item/stack/sheet/brass(loc, 1)
	return ..()
