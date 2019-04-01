#define DRYING_TIME 5 * 60 * 10 //for 1 unit of depth in puddle (amount var)

var/global/list/image/splatter_cache = list()

/obj/effect/decal/cleanable/blood
	name = "blood"
	var/dryname = "dried blood"
	desc = "It's thick and gooey. Perhaps it's the chef's cooking?"
	var/drydesc = "It's dry and crusty. Someone is not doing their job."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	appearance_flags = NO_CLIENT_COLOR
	blood_DNA = list()
	var/base_icon = 'icons/effects/blood.dmi'
	var/blood_state = BLOOD_STATE_HUMAN
	var/bloodiness = MAX_SHOE_BLOODINESS
	var/basecolor = "#A10808" // Color when wet.
	var/amount = 5
	var/dry_timer = 0
	var/off_floor = FALSE

/obj/effect/decal/cleanable/blood/Initialize()
	. = ..()
	update_icon()
	if(GAMEMODE_IS_CULT)
		var/datum/game_mode/cult/mode_ticker = ticker.mode
		var/turf/T = get_turf(src)
		if(T && (is_station_level(T.z)))//F I V E   T I L E S
			if(!(T in mode_ticker.bloody_floors))
				mode_ticker.bloody_floors += T
				mode_ticker.bloody_floors[T] = T
				mode_ticker.blood_check()
	if(type == /obj/effect/decal/cleanable/blood/gibs)
		return
	if(type == /obj/effect/decal/cleanable/blood)
		if(loc && isturf(loc))
			for(var/obj/effect/decal/cleanable/blood/B in loc)
				if(B != src)
					if(B.blood_DNA)
						blood_DNA |= B.blood_DNA.Copy()
					qdel(B)
	dry_timer = addtimer(CALLBACK(src, .proc/dry), DRYING_TIME * (amount+1), TIMER_STOPPABLE)

/obj/effect/decal/cleanable/blood/Destroy()
	if(GAMEMODE_IS_CULT)
		var/datum/game_mode/cult/mode_ticker = ticker.mode
		var/turf/T = get_turf(src)
		if(T && (is_station_level(T.z)))
			mode_ticker.bloody_floors -= T
			mode_ticker.blood_check()
	if(dry_timer)
		deltimer(dry_timer)
	return ..()

/obj/effect/decal/cleanable/blood/update_icon()
	if(basecolor == "rainbow")
		basecolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	color = basecolor

/obj/effect/decal/cleanable/blood/proc/dry()
	name = dryname
	desc = drydesc
	color = adjust_brightness(color, -50)
	amount = 0

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
		user.hand_blood_color = basecolor
		user.update_inv_gloves(1)
		user.verbs += /mob/living/carbon/human/proc/bloody_doodle

/obj/effect/decal/cleanable/blood/can_bloodcrawl_in()
	return TRUE

//Add "bloodiness" of this blood's type, to the human's shoes
/obj/effect/decal/cleanable/blood/Crossed(atom/movable/O)
	if(!off_floor && ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/organ/external/l_foot = H.get_organ("l_foot")
		var/obj/item/organ/external/r_foot = H.get_organ("r_foot")
		var/hasfeet = TRUE
		if(!l_foot && !r_foot)
			hasfeet = FALSE
		if(H.shoes && blood_state && bloodiness)
			var/obj/item/clothing/shoes/S = H.shoes
			var/add_blood = 0
			if(bloodiness >= BLOOD_GAIN_PER_STEP)
				add_blood = BLOOD_GAIN_PER_STEP
			else
				add_blood = bloodiness
			bloodiness -= add_blood
			S.bloody_shoes[blood_state] = min(MAX_SHOE_BLOODINESS, S.bloody_shoes[blood_state] + add_blood)
			if(blood_DNA && blood_DNA.len)
				S.add_blood(H.blood_DNA, basecolor)
			S.blood_state = blood_state
			S.blood_color = basecolor
			update_icon()
			H.update_inv_shoes()
		else if(hasfeet && blood_state && bloodiness)//Or feet
			var/add_blood = 0
			if(bloodiness >= BLOOD_GAIN_PER_STEP)
				add_blood = BLOOD_GAIN_PER_STEP
			else
				add_blood = bloodiness
			bloodiness -= add_blood
			H.bloody_feet[blood_state] = min(MAX_SHOE_BLOODINESS, H.bloody_feet[blood_state] + add_blood)
			if(!H.feet_blood_DNA)
				H.feet_blood_DNA = list()
			H.blood_state = blood_state
			H.feet_blood_DNA |= blood_DNA.Copy()
			H.feet_blood_color = basecolor
			update_icon()
			H.update_inv_shoes()

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	gender = PLURAL
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	random_icon_states = list("1", "2", "3", "4", "5")
	amount = 0
	bloodiness = 0
	var/drips = 1

/obj/effect/decal/cleanable/blood/drip/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/trail_holder //not a child of blood on purpose
	name = "blood"
	icon_state = "ltrails_1"
	desc = "Your instincts say you shouldn't be following these."
	gender = PLURAL
	density = FALSE
	layer = TURF_LAYER
	random_icon_states = null
	blood_DNA = list()
	appearance_flags = NO_CLIENT_COLOR
	var/list/existing_dirs = list()

/obj/effect/decal/cleanable/trail_holder/can_bloodcrawl_in()
	return TRUE

/obj/effect/decal/cleanable/blood/writing
	icon_state = "tracks"
	desc = "It looks like a writing in blood."
	gender = NEUTER
	random_icon_states = list("writing1", "writing2", "writing3", "writing4", "writing5")
	amount = 0
	var/message

/obj/effect/decal/cleanable/blood/writing/Initialize()
	. = ..()
	if(random_icon_states.len)
		for(var/obj/effect/decal/cleanable/blood/writing/W in loc)
			random_icon_states.Remove(W.icon_state)
		icon_state = pick(random_icon_states)
	else
		icon_state = "writing1"

/obj/effect/decal/cleanable/blood/writing/examine(mob/user)
	..(user)
	to_chat(user, "<span class='notice'>It reads: <font color='[basecolor]'>\"[message]\"<font></span>")

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	no_clear = TRUE
	var/fleshcolor = "#FFFFFF"

/obj/effect/decal/cleanable/blood/gibs/update_icon()
	var/image/giblets = new(base_icon, "[icon_state]_flesh", dir)
	if(!fleshcolor || fleshcolor == "rainbow")
		fleshcolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	giblets.color = fleshcolor
	var/icon/blood = new(base_icon,"[icon_state]",dir)

	icon = blood
	overlays.Cut()
	overlays += giblets
	. = ..()

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


/obj/effect/decal/cleanable/blood/gibs/cleangibs //most ironic name ever...
	scoop_reagents = null

/obj/effect/decal/cleanable/blood/gibs/proc/streak(var/list/directions)
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


/obj/effect/decal/cleanable/blood/old/Initialize()
	. = ..()
	bloodiness = 0
	dry()

/obj/effect/decal/cleanable/blood/old/can_bloodcrawl_in()
	return FALSE

/obj/effect/decal/cleanable/blood/gibs/old/Initialize()
	. = ..()
	bloodiness = 0
	dry()

/obj/effect/decal/cleanable/blood/gibs/old/can_bloodcrawl_in()
	return FALSE

#undef DRYING_TIME
