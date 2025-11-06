#define DRYING_TIME 5 MINUTES //for 1 unit of depth in puddle (amount var)
#define ALWAYS_IN_GRAVITY 2

/obj/effect/decal/cleanable/blood
	name = "blood"
	var/dryname = "dried blood"
	desc = "It's thick and gooey. Perhaps it's the chef's cooking?"
	var/drydesc = "It's dry and crusty. Someone is not doing their job."
	gender = PLURAL
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	blood_DNA = list()
	var/base_icon = 'icons/effects/blood.dmi'
	base_icon_state = "mfloor1"
	var/blood_state = BLOOD_STATE_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	var/basecolor = "#A10808" // Color when wet.
	var/amount = 5
	var/dry_timer = 0
	var/off_floor = FALSE
	var/image/weightless_image
	var/weightless_icon = 'icons/effects/blood_weightless.dmi'

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	if(C == src)
		return FALSE
	if(C.blood_DNA)
		blood_DNA |= C.blood_DNA.Copy()
	if(bloodiness)
		if(C.bloodiness < MAX_SHOE_BLOODINESS)
			C.bloodiness += bloodiness
	return ..()

/obj/effect/decal/cleanable/blood/Initialize(mapload, decal_color)
	. = ..()
	if(decal_color)
		basecolor = decal_color
	else
		if(basecolor == "rainbow")
			basecolor = "#[pick("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF")]"

	color = basecolor
	base_icon_state = icon_state

	var/turf/T = get_turf(src)
	check_gravity(T)
	update_icon()

	if(gravity_check)
		if(!. && !QDELETED(src))
			dry_timer = addtimer(CALLBACK(src, PROC_REF(dry)), DRYING_TIME * (amount+1), TIMER_STOPPABLE)
	else
		if(prob(50))
			animate_float(src, -1, rand(30,120))
		else
			animate_levitate(src, -1, rand(30,120))
		//weightless blood cannot dry
		return

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_atom_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/cleanable/blood/Destroy()
	if(dry_timer)
		deltimer(dry_timer)
	QDEL_NULL(weightless_image)
	return ..()

/obj/effect/decal/cleanable/blood/update_overlays()
	. = ..()

	if(gravity_check)
		return

	if(!weightless_image)
		color = COLOR_WHITE
		weightless_image = image(weightless_icon, base_icon_state)
		weightless_image.icon += basecolor

	. += weightless_image

/obj/effect/decal/cleanable/blood/update_icon()
	if(should_be_off_floor())
		off_floor = TRUE
		layer = ABOVE_MOB_LAYER
		plane = GAME_PLANE

	if(gravity_check)
		icon = initial(icon)
		icon_state = base_icon_state
		color = basecolor
	else
		icon_state = null

	..()

/obj/effect/decal/cleanable/blood/proc/should_be_off_floor()
	var/turf/T = get_turf(src)
	return ((T && T.density) || !gravity_check || (locate(/obj/structure/window/full) in T) || (locate(/obj/structure/grille) in T))

/obj/effect/decal/cleanable/blood/proc/dry()
	name = dryname
	desc = drydesc
	color = adjust_brightness(color, -50)
	amount = 0
	gravity_check = ALWAYS_IN_GRAVITY
	animate(src)

	if(isspaceturf(loc))
		var/turf/T = get_turf(src)
		if(!locate(/obj/structure/grille/) in T && !locate(/obj/structure/window/) in T)
			qdel(src) //no free floating dried blood in space, thatd look weird

/obj/effect/decal/cleanable/blood/proc/splat(atom/AT)
	if(gravity_check) //only floating blood can splat :C
		return
	var/turf/T = get_turf(AT)
	if(should_merge_decal(T))
		qdel(src)
		return
	if(loc != T)
		forceMove(T) //move to the turf to splatter on
	gravity_check = ALWAYS_IN_GRAVITY
	layer = initial(layer)
	plane = initial(plane)
	animate(src)
	update_icon()

/obj/effect/decal/cleanable/blood/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	if(gravity_check)
		return TRUE

	return ..()

/obj/effect/decal/cleanable/blood/Bump(atom/A)
	if(gravity_check)
		return ..()

	if(iswallturf(A) || istype(A, /obj/structure/window))
		splat(A)
		return

	else if(A.density)
		splat(get_turf(A))
		return

	if(ishuman(A))
		bloodyify_human(A)
		return

	return ..()

/obj/effect/decal/cleanable/blood/proc/bloodyify_human(mob/living/carbon/human/H)
	// Originally this code would check to see if both us and the human
	// we collided with had inertia in the same direction, and avoided collision
	// if so. This might be possible with movement loops but, realistically,
	// if we've gotten here, the objects have collided no matter what direction
	// they were going in.

	var/list/obj/item/things_to_potentially_bloody = list()
	var/count = amount + 1

	for(var/obj/item/i in H.contents)
		things_to_potentially_bloody += i

	if(length(things_to_potentially_bloody))
		for(var/i in 1 to count)
			things_to_potentially_bloody[rand(1, length(things_to_potentially_bloody))].add_blood(blood_DNA, basecolor)
			count--
		qdel(src)
	else
		splat(get_turf(H))

/obj/effect/decal/cleanable/blood/attack_hand(mob/living/carbon/human/user)
	..()
	if(amount && istype(user))
		add_fingerprint(user)
		if(user.gloves)
			return
		var/taken = rand(1,amount)
		amount -= taken
		to_chat(user, "<span class='notice'>You get some of \the [src] on your hands.</span>")
		if(!user.blood_DNA)
			user.blood_DNA = list()
		user.blood_DNA |= blood_DNA.Copy()
		user.bloody_hands += taken
		if(isnull(basecolor))
			user.hand_blood_color = "#A10808"
		else
			user.hand_blood_color = basecolor
		user.update_inv_gloves()
		add_verb(user, /mob/living/carbon/human/proc/bloody_doodle)

/obj/effect/decal/cleanable/blood/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "A drop of blood in an ocean of mess."
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	random_icon_states = list("1", "2", "3", "4", "5")
	amount = 0
	bloodiness = 0
	var/drips = 1

/obj/effect/decal/cleanable/blood/drip/can_bloodcrawl_in()
	return TRUE

/// not a child of blood on purpose
/obj/effect/decal/cleanable/trail_holder
	name = "blood"
	icon_state = "nothing"
	desc = "Your instincts say you shouldn't be following these."
	gender = PLURAL
	layer = TURF_LAYER
	random_icon_states = null
	blood_DNA = list()
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/trail_holder/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/blood/writing
	icon_state = "writing1"
	desc = "It looks like a writing in blood."
	gender = NEUTER
	random_icon_states = list("writing1", "writing2", "writing3", "writing4", "writing5")
	amount = 0
	var/message

/obj/effect/decal/cleanable/blood/writing/Initialize(mapload)
	. = ..()
	if(length(random_icon_states))
		for(var/obj/effect/decal/cleanable/blood/writing/W in loc)
			random_icon_states.Remove(W.icon_state)
		icon_state = pick(random_icon_states)
	else
		icon_state = "writing1"

/obj/effect/decal/cleanable/blood/writing/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It reads: <font color='[basecolor]'>\"[message]\"<font></span>"

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	icon_state = "mgibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	no_clear = TRUE
	mergeable_decal = FALSE
	var/image/giblets
	var/fleshcolor = "#FFFFFF"
	gravity_check = ALWAYS_IN_GRAVITY

/obj/effect/decal/cleanable/blood/gibs/Destroy()
	giblets = null
	return ..()

/obj/effect/decal/cleanable/blood/gibs/update_icon(updates = ALL)
	if(!updates)
		return
	giblets = new(base_icon, "[icon_state]_flesh", dir)
	if(!fleshcolor || fleshcolor == "rainbow")
		fleshcolor = "#[pick("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF")]"
	giblets.color = fleshcolor
	var/icon/blood = new(base_icon,"[icon_state]",dir)
	icon = blood
	. = ..()

/obj/effect/decal/cleanable/blood/gibs/update_overlays()
	. = ..()
	. += giblets

/obj/effect/decal/cleanable/blood/gibs/ex_act(severity)
	return

/obj/effect/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gibup1", "gibup1", "gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gibdown1", "gibdown1", "gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")
	scoop_reagents = list("liquidgibs" = 5)


/// most ironic name ever...
/obj/effect/decal/cleanable/blood/gibs/cleangibs
	scoop_reagents = null
	mergeable_decal = TRUE

/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions)
	var/delay = 2
	var/range = pick(1, 200; 2, 150; 3, 50; 4)
	var/direction = pick(directions)

	var/datum/move_loop/loop = GLOB.move_manager.move_to(src, get_step(src, direction), delay = delay, timeout = range * delay, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	RegisterSignal(loop, COMSIG_MOVELOOP_POSTPROCESS, PROC_REF(spread_movement_effects))

/obj/effect/decal/cleanable/blood/gibs/proc/spread_movement_effects(datum/move_loop/has_target/source)
	SIGNAL_HANDLER // COMSIG_MOVELOOP_POSTPROCESS
	var/obj/effect/decal/cleanable/blood/target = source.target
	var/obj/effect/decal/cleanable/blood/splatter/splatter = new(loc, istype(target) ? target.basecolor : basecolor)

	if(istype(target))
		splatter.basecolor = target.basecolor
		splatter.update_icon()

/obj/effect/decal/cleanable/blood/old/Initialize(mapload)
	. = ..()
	bloodiness = 0
	dry()

/obj/effect/decal/cleanable/blood/old/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/old/Initialize(mapload)
	. = ..()
	bloodiness = 0
	dry()

/obj/effect/decal/cleanable/blood/gibs/old/can_bloodcrawl_in()
	return FALSE

#undef DRYING_TIME
#undef ALWAYS_IN_GRAVITY
