#define DRYING_TIME 5 * 60*10			//for 1 unit of depth in puddle (amount var)


/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's red and gooey. Perhaps it's the chef's cooking?"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	var/list/viruses = list()
	blood_DNA = list()
	var/list/datum/disease2/disease/virus2 = list()
	var/amount = 5

/obj/effect/decal/cleanable/blood/New()
	..()
	if(istype(src, /obj/effect/decal/cleanable/blood/gibs))
		return
	if(istype(src, /obj/effect/decal/cleanable/blood/tracks))
		return // We handle our own drying.
	if(src.type == /obj/effect/decal/cleanable/blood)
		if(src.loc && isturf(src.loc))
			for(var/obj/effect/decal/cleanable/blood/B in src.loc)
				if(B != src)
					if (B.blood_DNA)
						blood_DNA |= B.blood_DNA.Copy()
					del(B)
	spawn(DRYING_TIME * (amount+1))
		dry()

/obj/effect/decal/cleanable/blood/Crossed(mob/living/carbon/human/perp)
	if (!istype(perp))
		return
	if(amount < 1)
		return

	var/datum/organ/external/l_foot = perp.get_organ("l_foot")
	var/datum/organ/external/r_foot = perp.get_organ("r_foot")
	var/hasfeet = 1
	if((!l_foot || l_foot.status & ORGAN_DESTROYED) && (!r_foot || r_foot.status & ORGAN_DESTROYED))
		hasfeet = 0
	if(perp.shoes && !perp.buckled)//Adding blood to shoes
		perp.shoes:track_blood = max(amount,perp.shoes:track_blood)		//Adding blood to shoes
		if(!perp.shoes.blood_overlay)
			perp.shoes.generate_blood_overlay()
		if(!perp.shoes.blood_DNA)
			perp.shoes.blood_DNA = list()
			perp.shoes.overlays += perp.shoes.blood_overlay
			perp.update_inv_shoes(1,0)
		perp.shoes.blood_DNA |= blood_DNA.Copy()
	else if (hasfeet)//Or feet
		perp.track_blood = max(amount,perp.track_blood)				//Or feet
		if(!perp.feet_blood_DNA)
			perp.feet_blood_DNA = list()
		perp.feet_blood_DNA |= blood_DNA.Copy()
	else if (perp.buckled && istype(perp.buckled, /obj/structure/stool/bed/chair/wheelchair))
		var/obj/structure/stool/bed/chair/wheelchair/W = perp.buckled
		W.bloodiness = 4

	amount--

/obj/effect/decal/cleanable/blood/proc/dry()
	name = "dried [src]"
	desc = "It's dark red and crusty. Someone is not doing their job."
	var/icon/I = icon(icon,icon_state)
	I.SetIntensity(0.7)
	icon = I
	amount = 0
	spawn(DRYING_TIME)
		Destroy()

/obj/effect/decal/cleanable/blood/attack_hand(mob/living/carbon/human/user)
	..()
	if (amount && istype(user))
		add_fingerprint(user)
		if (user.gloves)
			return
		var/taken = rand(1,amount)
		amount -= taken
		user << "<span class='notice'>You get some blood on your hands.</span>"
		if (!user.blood_DNA)
			user.blood_DNA = list()
		user.blood_DNA |= blood_DNA.Copy()
		user.bloody_hands += taken
		user.update_inv_gloves(1)
		user.verbs += /mob/living/carbon/human/proc/bloody_doodle

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/writing
	icon_state = "tracks"
	desc = "It looks like a writing in blood."
	gender = NEUTER
	random_icon_states = list("writing1","writing2","writing3","writing4","writing5")
	amount = 0
	var/message

/obj/effect/decal/cleanable/blood/writing/New()
	..()
	for(var/obj/effect/decal/cleanable/blood/writing/W in loc)
		random_icon_states.Remove(W.icon_state)
	icon_state = pick(random_icon_states)

/obj/effect/decal/cleanable/blood/writing/examine()
	..()
	usr << "It reads: <font color='#600000'>\"[message]\"<font>"


/obj/effect/decal/cleanable/blood/green
	name = "green blood"
	desc = "It's green and gooey. Perhaps it's the chef's cooking?"
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")

/obj/effect/decal/cleanable/blood/green/Crossed(mob/living/carbon/human/perp)
	if (!istype(perp))
		return
	if(amount < 1)
		return

	var/datum/organ/external/l_foot = perp.get_organ("l_foot")
	var/datum/organ/external/r_foot = perp.get_organ("r_foot")
	var/hasfeet = 1
	if((!l_foot || l_foot.status & ORGAN_DESTROYED) && (!r_foot || r_foot.status & ORGAN_DESTROYED))
		hasfeet = 0
	if(perp.shoes && !perp.buckled)//Adding blood to shoes
		perp.shoes:track_blood_green= max(amount,perp.shoes:track_blood_green)		//Adding blood to shoes
		if(!perp.shoes.blood_overlay)
			perp.shoes.blood_overlay_color = 1
			perp.shoes.generate_blood_overlay()
		if(!perp.shoes.blood_DNA)
			perp.shoes.blood_DNA = list()
			perp.shoes.overlays += perp.shoes.blood_overlay
			perp.update_inv_shoes(1,1)
		perp.shoes.blood_DNA |= blood_DNA.Copy()
	else if (hasfeet)//Or feet
		perp.track_blood_green = max(amount,perp.track_blood_green)				//Or feet
		if(!perp.feet_blood_DNA)
			perp.feet_blood_DNA = list()
		perp.feet_blood_DNA |= blood_DNA.Copy()
	else if (perp.buckled && istype(perp.buckled, /obj/structure/stool/bed/chair/wheelchair))
		var/obj/structure/stool/bed/chair/wheelchair/W = perp.buckled
		W.bloodiness = 4

	amount--

/obj/effect/decal/cleanable/blood/drip/green
	name = "drips of blood"
	desc = "It's green."
	gender = PLURAL
	icon = 'icons/effects/drip.dmi'
	icon_state = "g1"
	amount = 0

// The idea is to have 4 bits for coming and 4 for going.
#define TRACKS_COMING_NORTH 1
#define TRACKS_COMING_SOUTH 2
#define TRACKS_COMING_EAST  4
#define TRACKS_COMING_WEST  8
#define TRACKS_GOING_NORTH  16
#define TRACKS_GOING_SOUTH  32
#define TRACKS_GOING_EAST   64
#define TRACKS_GOING_WEST   128
// 5 seconds
#define TRACKS_CRUSTIFY_TIME   50

// Footprints, tire trails...
/obj/effect/decal/cleanable/blood/tracks
	amount = 0
	random_icon_states = null
	var/dirs=0
	icon='icons/effects/footprints.dmi'
	var/coming_state="blood1"
	var/going_state="blood2"


	var/newtracks=0 // Cleared after every icon_update
	var/crustytracks=0 // Cleared after every icon_update

	// dir = last wetting
	var/list/wet=list(
		"1"=0,
		"2"=0,
		"4"=0,
		"8"=0,
		"16"=0,
		"32"=0,
		"64"=0,
		"128"=0
	)

	/**
	* Add tracks to an existing trail.
	*
	* @param DNA bloodDNA to add to collection.
	* @param comingdir Direction tracks come from, or 0.
	* @param goingdir Direction tracks are going to (or 0).
	*/
	proc/AddTracks(var/mob/living/carbon/human/H, var/list/DNA, var/comingdir, var/goingdir,var/typepath)
		if(typepath == /obj/effect/decal/cleanable/blood/tracks/footprints)
			if(H.species.bodyflags & FEET_CLAWS)
				coming_state="bloodclaw1"
				going_state="bloodclaw2"
			if(H.species.bodyflags & FEET_PADDED)
				coming_state="bloodpaw1"
				going_state="bloodpaw2"
		if(typepath == /obj/effect/decal/cleanable/blood/tracks/footprints/green)
			if(H.species.bodyflags & FEET_CLAWS)
				coming_state="xenoclaw1"
				going_state="xenoclaw2"
			if(H.species.bodyflags & FEET_PADDED)
				coming_state="xenopaw1"
				going_state="xenopaw2"
			else
				coming_state="xeno1"
				going_state="xeno2"


		var/updated=0
		// Shift our goingdir 4 spaces to the left so it's in the GOING bitblock.
		var/realgoing=goingdir<<4

		// Current bit
		var/b=0

		// When tracks will start to dry out
		var/t=world.time + TRACKS_CRUSTIFY_TIME

		// Process 4 bits
		for(var/bi=0;bi<4;bi++)
			b=1<<bi
			// COMING BIT
			if(comingdir&b && wet["[b]"]!=t)
				if(!(dirs&b))
					newtracks|=b
				wet["[b]"]=t
				updated=1
			else
				if(wet["[b]"]<world.time && !(crustytracks&b))
					updated=1

			// GOING BIT (shift up 4)
			b=b<<4
			if(realgoing&b && wet["[b]"]!=t)
				if(!(dirs&b))
					newtracks|=b
				wet["[b]"]=t
				updated=1
			else
				if(wet["[b]"]<world.time && !(crustytracks&b))
					updated=1

		dirs |= comingdir|realgoing
		blood_DNA |= DNA.Copy()
		if(updated)
			update_icon()

	process()
		return PROCESS_KILL // Do not process us or we'll lag like hell.

	update_icon()
		// Clear everything.
		//overlays.Cut()
		var/b=0

		var/t=world.time
		var/crusty=0
		// Clear out any images that have been wetted or have crustified.
		for(var/image/overlay in overlays)
			b=overlay.dir
			if(overlay.icon_state==going_state)
				b=b<<4
			if(wet["[b]"]<t && !(crustytracks&b)) // NEW crusty ones get special treatment
				crusty|=b
			if(wet["[b]"]>t || crusty&b) // Wet or crusty?  Nuke'em either way.
				overlays.Remove(overlay)
				newtracks |= b // Mark as needing an update.

		// Update ONLY the overlays that have changed.
		for(var/bi=0;bi<4;bi++)
			// COMING
			b=1<<bi
			// New or crusty
			if(newtracks&b)
				var/icon/I= new /icon(icon, icon_state=coming_state, dir=num2dir(b))
				// If crusty, make them look crusty.
				if(crusty&b)
					I.SetIntensity(0.7)
					crustytracks |= b // Crusty? Don't update unless wetted again.
				else
					crustytracks &= ~b // Unmark as crusty.
				// Add to overlays
				overlays += I
			// GOING
			b=b<<4
			if(newtracks&b)
				var/icon/I= new /icon(icon, icon_state=going_state, dir=num2dir(b>>4))
				if(crusty&b)
					I.SetIntensity(0.7)
					crustytracks |= b // Crusty? Don't update unless wetted again.
				else
					crustytracks &= ~b // Unmark as crusty.
				overlays += I
		newtracks=0 // Clear our memory of updated tracks.

/obj/effect/decal/cleanable/blood/tracks/footprints
	name = "bloody footprints"
	desc = "Whoops..."

/obj/effect/decal/cleanable/blood/tracks/footprints/green
	name = "bloody green footprints"
	desc = "Whoops..."


/obj/effect/decal/cleanable/blood/tracks/wheels
	icon_state = "tracks"
	desc = "They look like tracks left by wheels."
	icon = 'icons/effects/blood.dmi'
	gender = PLURAL
	random_icon_states = null
	amount = 0

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	gender = PLURAL
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	amount = 0

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")

/obj/effect/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")


/obj/effect/decal/cleanable/blood/gibs/proc/streak(var/list/directions)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
			sleep(3)
			if (i > 0)
				new /obj/effect/decal/cleanable/blood/splatter(src.loc)

			if (step_to(src, get_step(src, direction), 0))
				break


/obj/effect/decal/cleanable/mucus
	name = "mucus"
	desc = "Disgusting mucus."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "mucus"
	random_icon_states = list("mucus")
	var/list/datum/disease2/disease/virus2 = list()
	var/dry=0 // Keeps the lag down

/obj/effect/decal/cleanable/mucus/New()
	spawn(DRYING_TIME * 2)
		dry=1

/obj/effect/decal/cleanable/blood/viralsputum
	name = "viral sputum"
	desc = "It's black and nasty."
//	basecolor="#030303"
	icon = 'icons/mob/robots.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")


