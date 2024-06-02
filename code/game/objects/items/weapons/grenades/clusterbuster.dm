#define RANDOM_DETONATE_MIN_TIME (1.5 SECONDS)
#define RANDOM_DETONATE_MAX_TIME (6 SECONDS)

////////////////////
//Clusterbang
////////////////////
/obj/item/grenade/clusterbuster
	desc = "Use of this weapon may constitute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"
	/// Base icon_state of the entire
	var/base_state = "clusterbang"
	/// The payload type that's delivered by each segment
	var/payload = /obj/item/grenade/flashbang/cluster
	/// The spawner that actually spawns each grenade
	var/payload_spawner = /obj/effect/payload_spawner
	/// Lower bound of times to roll for spawning a segment
	var/min_spawned = 4
	/// Upper bound of times to roll for spawning a segment
	var/max_spawned = 8
	/// The chance of a segment spawning on initial detonation
	var/segment_chance = 35


/obj/item/grenade/clusterbuster/detonate()
	. = ..()
	if(!.)
		return

	update_mob()
	var/numspawned = rand(min_spawned, max_spawned)
	var/again = 0

	// Roll for number of segments to spawn
	for(var/_ in 1 to numspawned)
		if(prob(segment_chance))
			again++
			numspawned--

	for(var/loop in 1 to again)
		new /obj/item/grenade/clusterbuster/segment(loc, src)//Creates 'segments' that launches a few more payloads

	new /obj/effect/payload_spawner(loc, payload, numspawned)//Launches payload
	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	qdel(src)


//////////////////////
//Clusterbang segment
//////////////////////
/obj/item/grenade/clusterbuster/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"
	base_state = "clusterbang_segment"

/obj/item/grenade/clusterbuster/segment/Initialize(mapload, obj/item/grenade/clusterbuster/base)
	. = ..()
	if(base)
		name = "[base.name] segment"
		base_state = "[base.base_state]_segment"
		icon_state = base_state
		payload_spawner = base.payload_spawner
		payload = base.payload
		min_spawned = base.min_spawned
		max_spawned = base.max_spawned
	icon_state = "[base_state]_active"
	active = TRUE

	// move each spawned segment a random distance away from their initial location
	walk_away(src, loc, rand(1,4))

	// detonate each segment at a random time in the future
	addtimer(CALLBACK(src, PROC_REF(detonate)), rand(RANDOM_DETONATE_MIN_TIME, RANDOM_DETONATE_MAX_TIME))


/obj/item/grenade/clusterbuster/segment/detonate()
	new payload_spawner(loc, payload, rand(min_spawned, max_spawned))
	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	qdel(src)

//////////////////////////////////
//The payload spawner effect
/////////////////////////////////
/obj/effect/payload_spawner/Initialize(mapload, type, numspawned)
	..()

	if(type && isnum(numspawned))
		spawn_payload(type, numspawned)

	return INITIALIZE_HINT_QDEL

/obj/effect/payload_spawner/proc/spawn_payload(type, numspawned)
	for(var/_ in 1 to numspawned)
		var/obj/item/grenade/grenade = new type(loc)

		if(istype(grenade))
			grenade.active = TRUE
			addtimer(CALLBACK(grenade, TYPE_PROC_REF(/obj/item/grenade, detonate)), rand(RANDOM_DETONATE_MIN_TIME, RANDOM_DETONATE_MAX_TIME))

		walk_away(grenade, loc, rand(1,4))

#undef RANDOM_DETONATE_MIN_TIME
#undef RANDOM_DETONATE_MAX_TIME

//////////////////////////////////
//Custom payload clusterbusters
/////////////////////////////////
/obj/item/grenade/flashbang/cluster
	icon_state = "flashbang_active"

/obj/item/grenade/clusterbuster/emp
	name = "Electromagnetic Storm"
	payload = /obj/item/grenade/empgrenade

/obj/item/grenade/clusterbuster/metalfoam
	name = "Instant Concrete"
	payload = /obj/item/grenade/chem_grenade/metalfoam

/obj/item/grenade/clusterbuster/inferno
	name = "Inferno"
	payload = /obj/item/grenade/chem_grenade/incendiary

/obj/item/grenade/clusterbuster/cleaner
	name = "Mr. Proper"
	payload = /obj/item/grenade/chem_grenade/cleaner

/obj/item/grenade/clusterbuster/facid
	name = "Aciding Rain"
	payload = /obj/item/grenade/chem_grenade/facid

/obj/item/grenade/clusterbuster/syndieminibomb
	name = "SyndiWrath"
	payload = /obj/item/grenade/syndieminibomb

/obj/item/grenade/clusterbuster/spawner_manhacks
	name = "iViscerator"
	payload = /obj/item/grenade/spawnergrenade/manhacks

/obj/item/grenade/clusterbuster/spawner_spesscarp
	name = "Invasion of the Space Carps"
	payload = /obj/item/grenade/spawnergrenade/spesscarp

/obj/item/grenade/clusterbuster/monster
	name = "\improper Monster Megabomb"
	payload = /obj/item/grenade/chem_grenade/large/monster

/obj/item/grenade/clusterbuster/meat
	name = "\improper Mega Meat Grenade"
	payload = /obj/item/grenade/chem_grenade/meat

/obj/item/grenade/clusterbuster/megadirt
	name = "\improper Megamaid's Revenge Grenade"
	payload = /obj/item/grenade/chem_grenade/dirt

/obj/item/grenade/clusterbuster/ultima
	name = "\improper Earth Shattering Kaboom"
	desc = "Contains one Aludium Q-36 explosive space modulator."
	payload = /obj/item/grenade/chem_grenade/explosion

/obj/item/grenade/clusterbuster/lube
	name = "Newton's First Law"
	desc = "An object in motion remains in motion."
	payload = /obj/item/grenade/chem_grenade/lube

/obj/item/grenade/clusterbuster/holy
	name = "\improper Purification Grenade"
	desc = "Blessed excessively."
	payload = /obj/item/grenade/chem_grenade/holywater

/obj/item/grenade/clusterbuster/booze
	name = "\improper Booze Grenade"
	payload = /obj/item/reagent_containers/drinks/bottle/random_drink

/obj/item/grenade/clusterbuster/honk
	name = "\improper Mega Honk Grenade"
	payload = /obj/item/grown/bananapeel

/obj/item/grenade/clusterbuster/honk_evil
	name = "\improper Evil Mega Honk Grenade"
	payload = /obj/item/grenade/clown_grenade

/obj/item/grenade/clusterbuster/xmas
	name = "\improper Christmas Miracle"
	payload = /obj/item/a_gift

/obj/item/grenade/clusterbuster/dirt
	name = "\improper Megamaid's Job Security Grenade"
	payload = /obj/effect/decal/cleanable/random

/obj/item/grenade/clusterbuster/apocalypsefake
	name = "\improper Fun Bomb"
	desc = "Not like the other bomb."
	payload = /obj/item/toy/spinningtoy

/obj/item/grenade/clusterbuster/apocalypse
	name = "\improper Apocalypse Bomb"
	desc = "No matter what, do not EVER use this."
	payload = /obj/singularity

/obj/item/grenade/clusterbuster/tools
	name = "\improper Engineering Deployment Platfom"
	desc = "For the that time when gearing up was just too hard."
	payload = /obj/random/tech_supply

/obj/item/grenade/clusterbuster/tide
	name = "\improper Quick Repair Grenade"
	desc = "An assistant's every dream."
	payload = /obj/random/tool

/obj/item/grenade/clusterbuster/toys
	name = "\improper Toy Delivery System"
	desc = "Who needs skill at arcades anyway?"
	payload = /obj/item/toy/random

/obj/item/grenade/clusterbuster/banquet
	name = "\improper Bork Bork Bonanza"
	desc = "Bork bork bork."
	payload = /obj/item/grenade/clusterbuster/banquet/child

/obj/item/grenade/clusterbuster/banquet/child
	payload = /obj/item/grenade/chem_grenade/large/feast

/obj/item/grenade/clusterbuster/aviary
	name = "\improper Poly-Poly Grenade"
	desc = "That's an uncomfortable number of birds."
	payload = /mob/living/simple_animal/parrot

/obj/item/grenade/clusterbuster/monkey
	name = "\improper Barrel of Monkeys"
	desc = "Not really that much fun."
	payload = /mob/living/carbon/human/monkey

/obj/item/grenade/clusterbuster/fluffy
	name = "\improper Fluffy Love Bomb"
	desc = "Exactly as snuggly as it sounds."
	payload = /mob/living/simple_animal/pet/dog/corgi/puppy

/obj/item/grenade/clusterbuster/fox
	name = "\improper Troublemaking Grenade"
	desc = "More trouble than two foxes combined."
	payload = /mob/living/simple_animal/pet/dog/fox

/obj/item/grenade/clusterbuster/crab
	name = "\improper Crab Grenade"
	desc = "Reserved for those pesky request."
	payload = /mob/living/simple_animal/crab

/obj/item/grenade/clusterbuster/plasma
	name = "\improper Plasma Cluster Grenade"
	desc = "For when everything needs to die in a fire."
	payload = /obj/item/grenade/gas

/obj/item/grenade/clusterbuster/n2o
	name = "\improper N2O Cluster Grenade"
	desc = "For when you need to knock out EVERYONE."
	payload = /obj/item/grenade/gas/knockout

/obj/item/grenade/clusterbuster/ied
	name = "\improper IED Cluster Grenade"
	desc = "For when you need to do something between everything and nothing."
	payload = /obj/item/grenade/iedcasing

////////////Clusterbuster of Clusterbusters////////////
//As a note: be extrodinarily careful about make the payload clusterbusters as it can quickly destroy the MC/Server

/obj/item/grenade/clusterbuster/mega_bang
	name = "For when stunlocking is just too short."
	payload = /obj/item/grenade/clusterbuster

/obj/item/grenade/clusterbuster/mega_syndieminibomb
	name = "Mega SyndiWrath."
	payload = /obj/item/grenade/clusterbuster/syndieminibomb

