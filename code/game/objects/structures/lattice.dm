/obj/structure/lattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice"
	density = FALSE
	anchored = TRUE
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	var/number_of_rods = 1
	canSmoothWith = list(/obj/structure/lattice,
						/turf/simulated/floor,
						/turf/simulated/wall,
						/obj/structure/falsewall,
						/obj/structure/lattice/fireproof)
	smooth = SMOOTH_MORE

/obj/structure/lattice/Initialize(mapload)
	. = ..()
	for(var/obj/structure/lattice/LAT in loc)
		if(LAT != src)
			QDEL_IN(LAT, 0)

/obj/structure/lattice/examine(mob/user)
	. = ..()
	. += deconstruction_hints(user)

/obj/structure/lattice/proc/deconstruction_hints(mob/user)
	return "<span class='notice'>The rods look like they could be <b>cut</b>. There's space for more <i>rods</i> or a <i>tile</i>.</span>"

/obj/structure/lattice/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	new /obj/item/stack/rods(get_turf(src), number_of_rods)
	deconstruct()

/obj/structure/lattice/catwalk/deconstruct()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()

/obj/structure/lattice/attackby(obj/item/C, mob/user, params)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	else
		var/turf/T = get_turf(src)
		return T.attackby(C, user) //hand this off to the turf instead (for building plating, catwalks, etc)

/obj/structure/lattice/ratvar_act()
	new /obj/structure/lattice/clockwork(loc)
	qdel(src)

/obj/structure/lattice/blob_act(obj/structure/blob/B)
	return

/obj/structure/lattice/singularity_pull(S, current_size)
	if(current_size >= STAGE_FOUR)
		deconstruct()

/obj/structure/lattice/rcd_construct_act(mob/user, obj/item/rcd/our_rcd, rcd_mode)
	. = ..()
	if(rcd_mode != RCD_MODE_TURF)
		return RCD_NO_ACT
	if(our_rcd.useResource(1, user))
		to_chat(user, "Building Floor...")
		playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
		var/turf/AT = get_turf(src)
		add_attack_logs(user, AT, "Constructed floor with RCD")
		AT.ChangeTurf(our_rcd.floor_type)
		return RCD_ACT_SUCCESSFULL
	to_chat(user, span_warning("ERROR! Not enough matter in unit to construct this floor!"))
	playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
	return RCD_ACT_FAILED

/obj/structure/lattice/clockwork
	name = "cog lattice"
	desc = "A lightweight support lattice. These hold the Justicar's station together."
	icon = 'icons/obj/smooth_structures/lattice_clockwork.dmi'

/obj/structure/lattice/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()

/obj/structure/lattice/clockwork/ratvar_act()
	if((x + y) % 2 != 0)
		icon = 'icons/obj/smooth_structures/lattice_clockwork_large.dmi'
		pixel_x = -9
		pixel_y = -9
	else
		icon = 'icons/obj/smooth_structures/lattice_clockwork.dmi'
		pixel_x = 0
		pixel_y = 0
	return TRUE

/obj/structure/lattice/catwalk
	name = "catwalk"
	desc = "A catwalk for easier EVA maneuvering and cable placement."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk"
	number_of_rods = 2
	smooth = SMOOTH_TRUE
	canSmoothWith = null

/obj/structure/lattice/catwalk/deconstruction_hints(mob/user)
	to_chat(user, "<span class='notice'>The supporting rods look like they could be <b>cut</b>.</span>")

/obj/structure/lattice/catwalk/Move()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()

/obj/structure/lattice/catwalk/ratvar_act()
	new /obj/structure/lattice/catwalk/clockwork(loc)
	qdel(src)

/obj/structure/lattice/catwalk/clockwork
	name = "clockwork catwalk"
	icon = 'icons/obj/smooth_structures/catwalk_clockwork.dmi'
	canSmoothWith = list(/obj/structure/lattice,
	/turf/simulated/floor,
	/turf/simulated/wall,
	/obj/structure/falsewall)
	smooth = SMOOTH_MORE

/obj/structure/lattice/catwalk/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	if(!mapload)
		new /obj/effect/temp_visual/ratvar/floor/catwalk(loc)
		new /obj/effect/temp_visual/ratvar/beam/catwalk(loc)

/obj/structure/lattice/catwalk/clockwork/ratvar_act()
	if((x + y) % 2 != 0)
		icon = 'icons/obj/smooth_structures/catwalk_clockwork_large.dmi'
		pixel_x = -9
		pixel_y = -9
	else
		icon = 'icons/obj/smooth_structures/catwalk_clockwork.dmi'
		pixel_x = 0
		pixel_y = 0
	return TRUE

/obj/structure/lattice/fireproof
	name = "fireproof lattice"
	desc = "A lightweight support lattice made of heat-resistance alloy."
	icon = 'icons/obj/smooth_structures/lattice_f.dmi'
	icon_state = "lattice"
	smooth = SMOOTH_TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	canSmoothWith = list(/obj/structure/lattice,
						/turf/simulated/floor,
						/turf/simulated/wall,
						/obj/structure/falsewall,
						/obj/structure/lattice/fireproof,
						/obj/structure/lattice/catwalk/fireproof,
						/turf/simulated/floor/plating)
	armor = list("melee" = 70, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70)
	max_integrity = 100

/obj/structure/lattice/fireproof/wirecutter_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>Вы начали срезать усиленные прутья, это займёт некоторое время...</span>")
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		to_chat(user, "<span class='warning'>Вам необходимо не прерывать процесс.</span>")
		return
	to_chat(user, "<span class='notice'>Вы срезали усиленные прутья!</span>")
	new /obj/item/stack/fireproof_rods(get_turf(src), 1)
	deconstruct()

/obj/structure/lattice/catwalk/fireproof
	name = "strong catwalk"
	desc = "Усиленный мостик, способный выдерживать высокие температуры и сильные нагрузки."
	icon_state = "catwalk"
	armor = list("melee" = 70, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	max_integrity = 150
	icon = 'icons/obj/smooth_structures/strong_catwalk.dmi'
	icon_state = "catwalk"
	smooth = SMOOTH_TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	canSmoothWith = list(/turf/simulated/floor,
						/turf/simulated/wall,
						/obj/structure/falsewall,
						/obj/structure/lattice/fireproof,
						/obj/structure/lattice/catwalk/fireproof)
	number_of_rods = 3

/obj/structure/lattice/catwalk/fireproof/wirecutter_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>Вы начали срезать усиленные прутья, это займёт некоторое время...</span>")
	if(!I.use_tool(src, user, 80, volume = I.tool_volume))
		to_chat(user, "<span class='warning'>Вам необходимо не прерывать процесс.</span>")
		return
	to_chat(user, "<span class='notice'>Вы срезали усиленный мостик!</span>")
	new /obj/item/stack/fireproof_rods(get_turf(src), 3)
	deconstruct()
