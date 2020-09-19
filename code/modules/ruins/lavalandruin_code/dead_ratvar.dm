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

/obj/effect/clockwork/overlay/floor/bloodcult //this is used by BLOOD CULT, it shouldn't use such a path...
	icon_state = "cult"

// Wall gears
//A massive gear, effectively a girder for clocks.
/obj/structure/clockwork/wall_gear
	name = "massive gear"
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "wall_gear"
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
	if(istype(I, /obj/item/stack/tile/brass))
		var/obj/item/stack/tile/brass/W = I
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
		if(do_after(user, 20, target = src))
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
		return 1
	return ..()

/obj/structure/clockwork/wall_gear/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT) && disassembled)
		new /obj/item/stack/tile/brass(loc, 3)
	return ..()

//The base clockwork item. Can have an alternate desc and will show up in the list of clockwork objects.
/obj/item/clockwork
	resistance_flags = FIRE_PROOF | ACID_PROOF

//Shards of Alloy, suitable only as a source of power for a replica fabricator.
/obj/item/clockwork/alloy_shards
	name = "replicant alloy shards"
	desc = "Broken shards of some oddly malleable metal. They occasionally move and seem to glow."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "alloy_shards"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/randomsinglesprite = FALSE
	var/randomspritemax = 2
	var/sprite_shift = 9

/obj/item/clockwork/alloy_shards/Initialize()
	. = ..()
	if(randomsinglesprite)
		replace_name_desc()
		icon_state = "[icon_state][rand(1, randomspritemax)]"
		pixel_x = rand(-sprite_shift, sprite_shift)
		pixel_y = rand(-sprite_shift, sprite_shift)

/obj/item/clockwork/alloy_shards/proc/replace_name_desc()
	name = "replicant alloy shard"
	desc = "A broken shard of some oddly malleable metal. It occasionally moves and seems to glow."

/obj/item/clockwork/alloy_shards/clockgolem_remains
	name = "clockwork golem scrap"
	desc = "A pile of scrap metal. It seems damaged beyond repair."
	icon_state = "clockgolem_dead"
	sprite_shift = 0

/obj/item/clockwork/alloy_shards/large
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	icon_state = "shard_large"
	sprite_shift = 9

/obj/item/clockwork/alloy_shards/medium
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	icon_state = "shard_medium"
	sprite_shift = 10

/obj/item/clockwork/alloy_shards/medium/gear_bit
	randomspritemax = 4
	icon_state = "gear_bit"
	sprite_shift = 12

/obj/item/clockwork/alloy_shards/medium/gear_bit/replace_name_desc()
	name = "gear bit"
	desc = "A broken chunk of a gear. You want it."

/obj/item/clockwork/alloy_shards/medium/gear_bit/large //gives more power

/obj/item/clockwork/alloy_shards/medium/gear_bit/large/replace_name_desc()
	..()
	name = "complex gear bit"

/obj/item/clockwork/alloy_shards/small
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	randomspritemax = 3
	icon_state = "shard_small"
	sprite_shift = 12

/obj/item/clockwork/alloy_shards/pinion_lock
	name = "pinion lock"
	desc = "A dented and scratched gear. It's very heavy."
	icon_state = "pinion_lock"

//Components: Used in scripture.
/obj/item/clockwork/component
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clockwork/component/belligerent_eye
	name = "belligerent eye"
	desc = "A brass construct with a rotating red center. It's as though it's looking for something to hurt."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "belligerent_eye"

/obj/item/clockwork/component/belligerent_eye/blind_eye
	name = "blind eye"
	desc = "A heavy brass eye, its red iris fallen dark."
	icon_state = "blind_eye"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/geis_capacitor/fallen_armor
	name = "fallen armor"
	desc = "Lifeless chunks of armor. They're designed in a strange way and won't fit on you."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "fallen_armor"
	w_class = WEIGHT_CLASS_NORMAL

//Ratvarian spear
/obj/item/clockwork/weapon/ratvarian_spear
	name = "ratvarian spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "ratvarian_spear"
	item_state = "ratvarian_spear"
	force = 15 //Extra damage is dealt to targets in attack()
	throwforce = 25
	armour_penetration = 10
	sharp = TRUE
	attack_verb = list("stabbed", "poked", "slashed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY
	var/bonus_burn = 5
