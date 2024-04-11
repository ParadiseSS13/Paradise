#define DEFAULT_METEOR_LIFETIME 3 MINUTES
#define MAP_EDGE_PAD 5

//Meteors probability of spawning during a given wave
GLOBAL_LIST_INIT(meteors_normal, list(/obj/effect/meteor/dust = 3, /obj/effect/meteor/medium = 8, /obj/effect/meteor/big = 3,
						/obj/effect/meteor/flaming = 1, /obj/effect/meteor/irradiated = 3)) //for normal meteor event

GLOBAL_LIST_INIT(meteors_threatening, list(/obj/effect/meteor/medium = 4, /obj/effect/meteor/big = 8,
						/obj/effect/meteor/flaming = 3, /obj/effect/meteor/irradiated = 3, /obj/effect/meteor/bananium = 1)) //for threatening meteor event

GLOBAL_LIST_INIT(meteors_catastrophic, list(/obj/effect/meteor/medium = 3, /obj/effect/meteor/big = 10,
						/obj/effect/meteor/flaming = 10, /obj/effect/meteor/irradiated = 10, /obj/effect/meteor/bananium = 2, /obj/effect/meteor/meaty = 2, /obj/effect/meteor/meaty/xeno = 2, /obj/effect/meteor/tunguska = 1)) //for catastrophic meteor event

GLOBAL_LIST_INIT(meteors_gore, list(/obj/effect/meteor/meaty = 5, /obj/effect/meteor/meaty/xeno = 1)) //for meaty ore event

GLOBAL_LIST_INIT(meteors_ops, list(/obj/effect/meteor/goreops)) //Meaty Ops

///////////////////////////////
//Meteor spawning global procs
///////////////////////////////

/proc/spawn_meteors(number = 10, list/meteortypes)
	for(var/i = 0; i < number; i++)
		spawn_meteor(meteortypes)

/proc/spawn_meteor(list/meteortypes, mob/ling)
	var/turf/pickedstart
	var/turf/pickedgoal
	var/max_i = 10 //number of tries to spawn meteor.
	while(!isspaceturf(pickedstart))
		var/startSide = pick(GLOB.cardinal)
		var/startZ = level_name_to_num(MAIN_STATION)
		pickedstart = spaceDebrisStartLoc(startSide, startZ)
		pickedgoal = spaceDebrisFinishLoc(startSide, startZ)
		max_i--
		if(max_i <= 0)
			return
	var/Me = pickweight(meteortypes)
	var/obj/effect/meteor/M = new Me(pickedstart, pickedgoal)
	M.dest = pickedgoal

	if(istype(M, /obj/effect/meteor/meaty/ling) && ling != null)
		var/obj/effect/meteor/meaty/ling/L = M
		L.ling_inside = ling

/proc/spaceDebrisStartLoc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD)
			startx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(EAST)
			starty = rand((TRANSITIONEDGE + MAP_EDGE_PAD),world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			startx = world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD)
		if(SOUTH)
			starty = (TRANSITIONEDGE + MAP_EDGE_PAD)
			startx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(WEST)
			starty = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			startx = (TRANSITIONEDGE + MAP_EDGE_PAD)
	. = locate(startx, starty, Z)

/proc/spaceDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	switch(startSide)
		if(NORTH)
			endy = (TRANSITIONEDGE + MAP_EDGE_PAD)
			endx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(EAST)
			endy = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			endx = (TRANSITIONEDGE + MAP_EDGE_PAD)
		if(SOUTH)
			endy = world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD)
			endx = rand((TRANSITIONEDGE + MAP_EDGE_PAD), world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD))
		if(WEST)
			endy = rand((TRANSITIONEDGE + MAP_EDGE_PAD),world.maxy-(TRANSITIONEDGE + MAP_EDGE_PAD))
			endx = world.maxx-(TRANSITIONEDGE + MAP_EDGE_PAD)
	. = locate(endx, endy, Z)

///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "\proper the concept of meteor"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small"
	density = TRUE
	var/hits = 4
	var/hitpwr = EXPLODE_HEAVY //Level of ex_act to be called on hit.
	var/dest
	pass_flags = PASSTABLE
	var/heavy = FALSE
	var/meteorsound = 'sound/effects/meteorimpact.ogg'
	var/z_original
	var/lifetime = DEFAULT_METEOR_LIFETIME
	var/timerid = null
	var/list/meteordrop = list(/obj/item/stack/ore/iron)
	var/dropamt = 2

/obj/effect/meteor/Move()
	if(z != z_original || loc == dest)
		qdel(src)
		return FALSE

	. = ..() //process movement...

	if(.)//.. if did move, ram the turf we get in
		var/turf/T = get_turf(loc)
		ram_turf(T)

		if(prob(10) && !ispassmeteorturf(T))//randomly takes a 'hit' from ramming
			get_hit()

/obj/effect/meteor/Destroy()
	if(timerid)
		deltimer(timerid)
	GLOB.meteor_list -= src
	walk(src, 0) //this cancels the walk_towards() proc
	return ..()

/obj/effect/meteor/Initialize(mapload, target)
	. = ..()
	z_original = z
	GLOB.meteor_list += src
	SpinAnimation()
	timerid = QDEL_IN(src, lifetime)
	chase_target(target)

	if(istype(src, /obj/effect/meteor/meaty/ling))
		var/list/turfs = list()
		for(var/area/station/S in world)
			for(var/turf/T in S)
				turfs += T

		chase_target(pick(turfs))

/obj/effect/meteor/Bump(atom/A)
	if(A)
		ram_turf(get_turf(A))
		playsound(loc, meteorsound, 40, TRUE)
		if(!istype(A, /obj/structure/railing))
			get_hit()

/obj/effect/meteor/proc/ram_turf(turf/T)
	//first bust whatever is in the turf
	for(var/thing in T)
		var/atom/A = thing
		if(thing == src)
			continue
		if(isliving(thing))
			var/mob/living/living_thing = thing
			living_thing.visible_message("<span class='warning'>[src] slams into [living_thing].</span>", "<span class='userdanger'>[src] slams into you!</span>")
		A.ex_act(hitpwr)

	//then, ram the turf if it still exists
	if(T)
		T.ex_act(hitpwr)

//process getting 'hit' by colliding with a dense object
//or randomly when ramming turfs
/obj/effect/meteor/proc/get_hit()
	hits--
	if(hits <= 0)
		make_debris()
		meteor_effect()
		qdel(src)

/obj/effect/meteor/ex_act()
	return

/obj/effect/meteor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pickaxe))
		make_debris()
		qdel(src)
		return
	return ..()

/obj/effect/meteor/proc/make_debris()
	for(var/throws = dropamt, throws > 0, throws--)
		var/thing_to_spawn = pick(meteordrop)
		new thing_to_spawn(get_turf(src))

/obj/effect/meteor/proc/chase_target(atom/chasing, delay = 1)
	set waitfor = FALSE
	if(chasing)
		walk_towards(src, chasing, delay)

/obj/effect/meteor/proc/meteor_effect()
	if(heavy)
		var/sound/meteor_sound = sound(meteorsound)
		var/random_frequency = get_rand_frequency()

		for(var/P in GLOB.player_list)
			var/mob/M = P
			var/turf/T = get_turf(M)
			if(!T || T.z != z)
				continue
			var/dist = get_dist(M.loc, loc)
			shake_camera(M, dist > 20 ? 2 : 4, dist > 20 ? 1 : 3)
			M.playsound_local(loc, null, 50, TRUE, random_frequency, 10, S = meteor_sound)

///////////////////////
//Meteor types
///////////////////////

//Dust
/obj/effect/meteor/dust
	name = "space dust"
	icon_state = "dust"
	pass_flags = PASSTABLE | PASSGRILLE
	hits = 1
	hitpwr = EXPLODE_LIGHT
	meteorsound = 'sound/weapons/gunshots/gunshot_smg.ogg'
	meteordrop = list(/obj/item/stack/ore/glass)

//Medium-sized
/obj/effect/meteor/medium
	name = "meteor"
	dropamt = 3

/obj/effect/meteor/medium/meteor_effect()
	..()
	explosion(loc, 0, 1, 2, 3, 0)

//Large-sized
/obj/effect/meteor/big
	name = "big meteor"
	icon_state = "large"
	hits = 6
	heavy = TRUE
	dropamt = 4

/obj/effect/meteor/big/meteor_effect()
	..()
	explosion(loc, 1, 2, 3, 4, 0)

//Flaming meteor
/obj/effect/meteor/flaming
	name = "flaming meteor"
	icon_state = "flaming"
	hits = 5
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)

/obj/effect/meteor/flaming/meteor_effect()
	..()
	explosion(loc, 1, 2, 3, 4, 0, 0, 5)

//Radiation meteor
/obj/effect/meteor/irradiated
	name = "glowing meteor"
	icon_state = "glowing"
	heavy = TRUE
	meteordrop = list(/obj/item/stack/ore/uranium)


/obj/effect/meteor/irradiated/meteor_effect()
	..()
	explosion(loc, 0, 0, 4, 3, 0)
	new /obj/effect/decal/cleanable/greenglow(get_turf(src))
	radiation_pulse(src, 5000, 7)
	//Hot take on this one. This often hits walls. It really has to breach into somewhere important to matter. This at leats makes the area slightly dangerous for a bit

/obj/effect/meteor/bananium
	name = "bananium meteor"
	desc = "Well this would be just an awful way to die."
	icon_state = "clownish"
	heavy = TRUE
	meteordrop = list(/obj/item/stack/ore/bananium)

/obj/effect/meteor/bananium/meteor_effect()
	..()
	explosion(loc, 0, 0, 3, 2, 0)
	var/turf/current_turf = get_turf(src)
	new /obj/item/grown/bananapeel(current_turf)
	for(var/obj/target in range(4, current_turf))
		if(prob(15))
			target.cmag_act()

//Station buster Tunguska
/obj/effect/meteor/tunguska
	name = "tunguska meteor"
	icon_state = "flaming"
	desc = "Your life briefly passes before your eyes the moment you lay them on this monstrosity."
	hits = 30
	hitpwr = EXPLODE_DEVASTATE
	heavy = TRUE
	meteorsound = 'sound/effects/bamf.ogg'
	meteordrop = list(/obj/item/stack/ore/plasma)

/obj/effect/meteor/tunguska/Move()
	. = ..()
	if(.)
		new /obj/effect/temp_visual/revenant(get_turf(src))

/obj/effect/meteor/tunguska/meteor_effect()
	..()
	explosion(loc, 5, 10, 15, 20, 0)

/obj/effect/meteor/tunguska/Bump()
	..()
	if(prob(20))
		explosion(loc, 2, 4, 6, 8)

//Meaty Ore
/obj/effect/meteor/meaty
	name = "meaty ore"
	icon_state = "meateor"
	desc = "Just... don't think too hard about where this thing came from."
	hits = 2
	heavy = TRUE
	meteorsound = 'sound/effects/blobattack.ogg'
	meteordrop = list(/obj/item/food/snacks/meat/human, /obj/item/organ/internal/heart, /obj/item/organ/internal/lungs, /obj/item/organ/internal/appendix)
	var/meteorgibs = /obj/effect/gibspawner/generic

/obj/effect/meteor/meaty/make_debris()
	..()
	new meteorgibs(get_turf(src))


/obj/effect/meteor/meaty/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/blood(T)

/obj/effect/meteor/meaty/Bump(atom/A)
	A.ex_act(hitpwr)
	get_hit()

//Meaty Ore Xeno edition
/obj/effect/meteor/meaty/xeno
	color = "#5EFF00"
	meteordrop = list(/obj/item/food/snacks/monstermeat/xenomeat)
	meteorgibs = /obj/effect/gibspawner/xeno

/obj/effect/meteor/meaty/xeno/Initialize(mapload, target)
	meteordrop += subtypesof(/obj/item/organ/internal/alien)
	return ..()

/obj/effect/meteor/meaty/xeno/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/blood/xeno(T)

/obj/effect/meteor/meaty/ling
	name = "suspicous meaty ore"
	icon_state = "meateor"
	hits = 1
	heavy = FALSE
	var/mob/ling_inside
	dropamt = 1
	hitpwr = EXPLODE_LIGHT

/obj/effect/meteor/meaty/ling/examine(mob/user)
	. = ..()
	if(ling_inside == user && istype(user, /mob/dead/observer))
		. += "<span class='changeling'>Right now it's us inside.</span>"

/obj/effect/meteor/meaty/ling/Destroy()
	var/turf/T = get_turf(src)
	..()
	var/mob/living/carbon/human/H = new(T)
	var/list/all_organic_species = list(/datum/species/human, /datum/species/unathi, /datum/species/skrell, /datum/species/tajaran, /datum/species/kidan, /datum/species/diona,
	/datum/species/moth, /datum/species/slime, /datum/species/grey, /datum/species/vulpkanin)
	var/obj/item/organ/external/head/he = H.get_organ("head")

	H.set_species(pick(all_organic_species))
	H.change_gender(pick(MALE, FEMALE))
	var/random_name = random_name(H.gender, H.dna.species.name)
	H.rename_character(H.real_name, random_name)
	H.cleanSE()

	he.facial_colour = rand_hex_color()
	he.sec_facial_colour = rand_hex_color()
	he.hair_colour = rand_hex_color()
	he.sec_hair_colour = rand_hex_color()
	H.change_eye_color(rand_hex_color())

	if(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE|HAS_SKIN_TONE)
		H.s_tone = random_skin_tone(H.dna.species.name)
	if(H.dna.species.bodyflags & HAS_SKIN_COLOR)
		H.skin_colour = rand_hex_color()
		if(istype(H.dna.species, /datum/species/slime))
			var/datum/species/slime/S = H.dna.species
			S.blend(H)
	if(H.dna.species.bodyflags & HAS_HEAD_ACCESSORY)
		if(prob(40))
			he.ha_style = random_head_accessory(H.gender, H.dna.species.name)
			he.headacc_colour = rand_hex_color()

	if(prob(90))
		he.h_style = random_hair_style(H.gender, H.dna.species.name)
	if(prob(30))
		he.f_style = random_facial_hair_style(H.gender, H.dna.species.name)

	H.height = pick(GLOB.character_heights)
	H.physique = pick(GLOB.character_physiques)

	H.regenerate_icons()
	H.update_body()
	H.update_dna()
	H.UpdateAppearance()
	H.overlays.Cut()
	H.update_mutantrace()

	var/obj/item/thing1 = pick(meteordrop) //This two gibs things need to move to the station, if there's no objects to hook up.
	var/obj/item/thing2 = pick(meteordrop)

	H.equip_to_slot_or_del(new thing1(H), SLOT_HUD_RIGHT_HAND)
	H.equip_to_slot_or_del(new thing2(H), SLOT_HUD_LEFT_HAND)

	H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/changeling(H), SLOT_HUD_OUTER_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/changeling(H), SLOT_HUD_HEAD)

	H.key = ling_inside.key

	H.mind.add_antag_datum(/datum/antagonist/changeling)
	var/datum/antagonist/changeling/cling = H.mind.has_antag_datum(/datum/antagonist/changeling)

	var/datum/action/changeling/suit/organic_space_suit/space = new()
	space.dna_cost = 0 // just A LITTLE BUFF and necessity
	space.power_type = CHANGELING_INNATE_POWER

	var/list/some_powers = list() //can be removed by discussing with other coders

	var/datum/action/changeling/chameleon_skin/CH = new()
	var/datum/action/changeling/headslug/HE = new()
	var/datum/action/changeling/contort_body/CB = new()
	var/datum/action/changeling/weapon/shield/OS = new()

	some_powers += CH
	some_powers += HE
	some_powers += CB
	some_powers += OS

	for(var/datum/action/changeling/C as anything in some_powers)
		C.dna_cost = 0
		C.power_type = CHANGELING_INNATE_POWER
		cling.give_power(C, H, FALSE)

	cling.give_power(space, H, FALSE)
	cling.genetic_points += 4 //harder to blend in crew.

	notify_ghosts("Stowaway Changeling [H.real_name] has arrived..", source = H, action = NOTIFY_FOLLOW)

//Meteor Ops
/obj/effect/meteor/goreops
	name = "MeteorOps"
	icon = 'icons/mob/animal.dmi'
	icon_state = "syndicaterangedpsace"
	hits = 10
	hitpwr = EXPLODE_DEVASTATE
	meteorsound = 'sound/effects/blobattack.ogg'
	meteordrop = list(/obj/item/food/snacks/meat)
	var/meteorgibs = /obj/effect/gibspawner/generic

/obj/effect/meteor/goreops/make_debris()
	..()
	new meteorgibs(get_turf(src))


/obj/effect/meteor/goreops/ram_turf(turf/T)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/blood(T)

/obj/effect/meteor/goreops/Bump(atom/A)
	A.ex_act(hitpwr)
	get_hit()

//////////////////////////
//Spookoween meteors
/////////////////////////

/obj/effect/meteor/pumpkin
	name = "PUMPKING"
	desc = "THE PUMPKING'S COMING!"
	icon = 'icons/obj/meteor_spooky.dmi'
	icon_state = "pumpkin"
	hits = 10
	heavy = TRUE
	dropamt = 1
	meteordrop = list(/obj/item/clothing/head/hardhat/pumpkinhead, /obj/item/food/snacks/grown/pumpkin)

/obj/effect/meteor/pumpkin/Initialize(mapload, target)
	. = ..()
	meteorsound = pick('sound/hallucinations/im_here1.ogg','sound/hallucinations/im_here2.ogg')

//////////////////////////
#undef DEFAULT_METEOR_LIFETIME
#undef MAP_EDGE_PAD
