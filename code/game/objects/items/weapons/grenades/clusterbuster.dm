////////////////////
//Clusterbang
////////////////////
/obj/item/grenade/clusterbuster
	name = "clusterbang"
	desc = "Use of this weapon may constitute a war crime in your area, consult your local captain."
	icon_state = "clusterbang"
	worn_icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	var/payload = /obj/item/grenade/flashbang/cluster

/obj/item/grenade/clusterbuster/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Upon detonating, this grenade will explode into a shower of bomblets that will all explode individually. Be ready to run away very fast.</span>"

/obj/item/grenade/clusterbuster/prime()
	update_mob()
	var/numspawned = rand(4,8)
	var/again = 0

	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			again++
			numspawned--

	for(var/loop = again ,loop > 0, loop--)
		new /obj/item/grenade/clusterbuster/segment(loc, payload)//Creates 'segments' that launches a few more payloads

	new /obj/effect/payload_spawner(loc, payload, numspawned)//Launches payload

	playsound(loc, 'sound/weapons/armbomb.ogg', 75, TRUE, -3)

	qdel(src)


//////////////////////
//Clusterbang segment
//////////////////////
/obj/item/grenade/clusterbuster/segment
	name = "clusterbang bomblet"
	desc = "A bomblet released by a clusterbang. Better run!"
	icon_state = "clusterbang_segment"

/obj/item/grenade/clusterbuster/segment/Initialize(mapload, payload_type = /obj/item/grenade/flashbang/cluster)
	. = ..()
	icon_state = "clusterbang_segment_active"
	payload = payload_type
	active = TRUE
	GLOB.move_manager.move_away(src, loc, rand(1, 4), timeout = 20)
	spawn(rand(15,60))
		prime()


/obj/item/grenade/clusterbuster/segment/prime()

	new /obj/effect/payload_spawner(loc, payload, rand(4,8))

	playsound(loc, 'sound/weapons/armbomb.ogg', 75, TRUE, -3)

	qdel(src)

//////////////////////////////////
//The payload spawner effect
/////////////////////////////////
/obj/effect/payload_spawner/New(turf/newloc, type, numspawned as num)
	. = ..()
	for(var/loop = numspawned ,loop > 0, loop--)
		var/obj/item/grenade/P = new type(loc)
		if(istype(P, /obj/item/grenade))
			P.active = TRUE
		GLOB.move_manager.move_away(P, loc, rand(1, 4), timeout = 20)

		spawn(rand(15,60))
			if(!QDELETED(P))
				if(istype(P, /obj/item/grenade))
					P.prime()
			qdel(src)


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

/obj/item/grenade/clusterbuster/toys
	name = "\improper Toy Delivery System"
	desc = "Who needs skill at arcades anyway?"
	payload = /obj/item/toy/random

/obj/item/grenade/clusterbuster/random_toys
	name = "\improper Toy Delivery System"
	desc = "Who needs skill at arcades anyway?"
	payload = /obj/effect/spawner/random/toy/clusterbuster

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
	payload = /mob/living/basic/crab

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

/obj/item/grenade/clusterbuster/tar
	name = "\improper Sticky Tar Cluster Grenade"
	desc = "Speed limit enforced by goop."
	payload = /obj/item/grenade/chem_grenade/tar

////////////Clusterbuster of Clusterbusters////////////
//As a note: be extrodinarily careful about make the payload clusterbusters as it can quickly destroy the MC/Server

/obj/item/grenade/clusterbuster/mega_bang
	name = "For when stunlocking is just too short."
	desc = "Simply owning one of these makes you an active war criminal in all Nian jurisdictions."
	payload = /obj/item/grenade/clusterbuster

/obj/item/grenade/clusterbuster/mega_syndieminibomb
	name = "Mega SyndiWrath."
	desc = "Proving once and for all that the maximum bomb explosion radius is just a suggestion."
	payload = /obj/item/grenade/clusterbuster/syndieminibomb

/obj/item/grenade/clusterbuster/admincleaner
	desc = "For cleaning <b>really</b> big messes."
	payload = /obj/item/grenade/chem_grenade/cleaner/everything

/obj/item/grenade/clusterbuster/admincleaner/organic
	desc = "For cleaning remnants of many, many crime scenes."
	payload = /obj/item/grenade/chem_grenade/cleaner/organic

/obj/item/grenade/clusterbuster/admincleaner/object
	desc = "For cleaning up after a typical Nanotrasen office party."
	payload = /obj/item/grenade/chem_grenade/cleaner/object
