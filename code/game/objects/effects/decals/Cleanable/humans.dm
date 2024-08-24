#define DRYING_TIME 5 MINUTES //for 1 unit of depth in puddle (amount var)
#define ALWAYS_IN_GRAVITY 2

/obj/effect/decal/cleanable/blood
	name = "blood"
	var/dryname = "dried blood"
	desc = "It's thick and gooey. Perhaps it's the chef's cooking?"
	var/drydesc = "It's dry and crusty. Someone is not doing their job."
	gender = PLURAL
	density = FALSE
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	blood_DNA = list()
	var/base_icon = 'icons/effects/blood.dmi'
	var/blood_state = BLOOD_STATE_HUMAN
	bloodiness = BLOOD_AMOUNT_PER_DECAL
	var/basecolor = "#A10808" // Color when wet.
	var/amount = 5
	var/dry_timer = 0
	var/off_floor = FALSE
	var/image/weightless_image
	inertia_move_delay = 1 // so they dont collide with who emitted them

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	if(C == src)
		return FALSE
	if(C.blood_DNA)
		blood_DNA |= C.blood_DNA.Copy()
	if(bloodiness)
		if(C.bloodiness < MAX_SHOE_BLOODINESS)
			C.bloodiness += bloodiness
	return ..()

/obj/effect/decal/cleanable/blood/Initialize(mapload)
	. = ..()
	weightless_image = new()
	update_icon()

	if(!gravity_check)
		//weightless blood cannot dry
		return

	if(!. && !QDELETED(src))
		dry_timer = addtimer(CALLBACK(src, PROC_REF(dry)), DRYING_TIME * (amount+1), TIMER_STOPPABLE)

/obj/effect/decal/cleanable/blood/Destroy()
	if(dry_timer)
		deltimer(dry_timer)
	return ..()

/obj/effect/decal/cleanable/blood/update_icon()
	var/turf/T = get_turf(src)
	check_gravity(T)

	if((T && (T.density)) || !gravity_check || locate(/obj/structure/window/) in T || locate(/obj/structure/grille/) in T)
		off_floor = TRUE
		layer = ABOVE_MOB_LAYER
		plane = GAME_PLANE

	if(basecolor == "rainbow")
		basecolor = "#[pick("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF")]"

	color = basecolor

	if(!gravity_check)
		if(prob(50))
			animate_float(src, -1, rand(30,120))
		else
			animate_levitate(src, -1, rand(30,120))

		if(weightless_image.icon_state)
			icon_state = weightless_image.icon_state

		overlays -= weightless_image
		color = "#FFFFFF"
		icon = 'icons/effects/blood_weightless.dmi'
		weightless_image = image(icon, icon_state)
		icon_state = "empty"
		weightless_image.icon += basecolor
		overlays += weightless_image
	else
		overlays.Cut()
	..()

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

/obj/effect/decal/cleanable/blood/ex_act()
	. = ..()
	update_icon()

/obj/effect/decal/cleanable/blood/proc/splat(atom/AT)
	if(gravity_check) //only floating blood can splat :C
		return
	var/turf/T = get_turf(AT)
	if(try_merging_decal(T))
		return
	if(loc != T)
		forceMove(T) //move to the turf to splatter on
	animate(src) //stop floating
	gravity_check = ALWAYS_IN_GRAVITY
	icon = initial(icon)
	icon_state = weightless_image.icon_state
	layer = initial(layer)
	plane = initial(plane)
	update_icon()

/obj/effect/decal/cleanable/blood/try_merging_decal(turf/T)
	..()

/obj/effect/decal/cleanable/blood/Process_Spacemove(movement_dir)
	if(gravity_check)
		return TRUE

	if(has_gravity(src))
		if(!gravity_check)
			splat(get_step(src, movement_dir))
		return TRUE

	if(pulledby && !pulledby.pulling)
		return TRUE

	if(throwing)
		return TRUE

	return FALSE


/obj/effect/decal/cleanable/blood/Bump(atom/A, yes)
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

	..()

/obj/effect/decal/cleanable/blood/proc/bloodyify_human(mob/living/carbon/human/H)
	if(inertia_dir && H.inertia_dir == inertia_dir) //if they are moving the same direction we are, no collison
		return

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
	gender = PLURAL
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
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	desc = "Your instincts say you shouldn't be following these."
	gender = PLURAL
	density = FALSE
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
	gender = PLURAL
	density = FALSE
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
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
	set waitfor = 0
	var/direction = pick(directions)
	for(var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
		sleep(3)
		if(i > 0)
			var/obj/effect/decal/cleanable/blood/b = new /obj/effect/decal/cleanable/blood/splatter(loc)
			b.basecolor = src.basecolor
			b.update_icon()
		if(step_to(src, get_step(src, direction), 0))
			break


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
