/obj/item/weapon/grenade/chem_grenade/dirt
	payload_name = "dirt"
	desc = "From the makers of BLAM! brand foaming space cleaner, this bomb guarantees steady work for any janitor."
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/list/muck = list("blood","carbon","flour","radium")
		var/filth = pick(muck - "radium") // not usually radioactive

		B1.reagents.add_reagent(filth,25)
		if(prob(25))
			B1.reagents.add_reagent(pick(muck - filth,25)) // but sometimes...

		beakers += B1


/obj/item/weapon/grenade/chem_grenade/meat
	payload_name = "meat"
	desc = "Not always as messy as the name implies."
	stage = 2


	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B2 = new(src)

		B1.reagents.add_reagent("blood",60)
		if(prob(5))
			B1.reagents.add_reagent("blood",1) // Quality control problems, causes a mess
		B2.reagents.add_reagent("clonexadone",30)

		beakers += B1
		beakers += B2

/obj/item/weapon/grenade/chem_grenade/holywater
	payload_name = "holy water"
	desc = "Then shalt thou count to three, no more, no less."
	stage = 2
	det_time = 30

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B = new(src)
		B.reagents.add_reagent("holywater",100)
		beakers += B

/obj/item/weapon/grenade/chem_grenade/soap
	payload_name = "soap"
	desc = "Not necessarily as clean as the name implies."
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("cornoil",60)
		B2.reagents.add_reagent("enzyme",5)
		B2.reagents.add_reagent("ammonia",30)

		beakers += B1
		beakers += B2
		update_icon()

/obj/item/weapon/grenade/chem_grenade/drugs
	payload_name = "miracle"
	desc = "How does it work?"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B2 = new(src)

		B1.reagents.add_reagent("space_drugs", 25)
		B1.reagents.add_reagent("mindbreaker", 25)
		B1.reagents.add_reagent("potassium", 25)
		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("sugar", 25)

		beakers += B1
		beakers += B2
		update_icon()

/obj/item/weapon/grenade/chem_grenade/ethanol
	payload_name = "ethanol"
	desc = "Ach, that hits the spot."
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B2 = new(src)

		B1.reagents.add_reagent("ethanol", 75)
		B1.reagents.add_reagent("potassium", 25)
		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("sugar", 25)
		B2.reagents.add_reagent("ethanol", 25)

		beakers += B1
		beakers += B2
		update_icon()

// -------------------------------------
// Grenades using new grenade assemblies
// -------------------------------------
/obj/item/weapon/grenade/chem_grenade/lube
	payload_name = "lubricant"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		B1.reagents.add_reagent("lube",50)
		beakers += B1
/obj/item/weapon/grenade/chem_grenade/lube/remote
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/signaler)
/obj/item/weapon/grenade/chem_grenade/lube/prox
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/prox_sensor)
/obj/item/weapon/grenade/chem_grenade/lube/tripwire
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/infra)


// Basic explosion grenade
/obj/item/weapon/grenade/chem_grenade/explosion
	payload_name = "conventional"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B1.reagents.add_reagent("glycerol",30) // todo: someone says NG is overpowered, test.
		B1.reagents.add_reagent("sacid",15)
		B2.reagents.add_reagent("sacid",15)
		B2.reagents.add_reagent("pacid",30)
		beakers += B1
		beakers += B2

// Assembly Variants
/obj/item/weapon/grenade/chem_grenade/explosion/remote
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/signaler)

/obj/item/weapon/grenade/chem_grenade/explosion/prox
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/prox_sensor)

/obj/item/weapon/grenade/chem_grenade/explosion/mine
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/mousetrap)

// Basic EMP grenade
/obj/item/weapon/grenade/chem_grenade/emp
	payload_name = "EMP"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B1.reagents.add_reagent("uranium",50)
		B2.reagents.add_reagent("iron",50)
		beakers += B1
		beakers += B2

// Assembly Variants
/obj/item/weapon/grenade/chem_grenade/emp/remote
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/signaler)

/obj/item/weapon/grenade/chem_grenade/emp/prox
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/prox_sensor)

/obj/item/weapon/grenade/chem_grenade/emp/mine
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/mousetrap)

// --------------------------------------
//  Dangerous slime core grenades
// --------------------------------------
/*
/obj/item/weapon/grenade/chem_grenade/large/bluespace
	payload_name = "bluespace slime"
	desc = "A standard grenade casing containing weaponized slime extract."
	stage = 2

	New()
		..()
		var/obj/item/slime_extract/bluespace/B1 = new(src)
		B1.Uses = rand(1,3)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B2.reagents.add_reagent("plasma",5 * B1.Uses)
		beakers += B1
		beakers += B2

/obj/item/weapon/grenade/chem_grenade/large/bluespace/prox
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/prox_sensor)

/obj/item/weapon/grenade/chem_grenade/large/bluespace/mine
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/mousetrap)

/obj/item/weapon/grenade/chem_grenade/large/bluespace/remote
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/signaler)
*/

/obj/item/weapon/grenade/chem_grenade/large/monster
	payload_name = "gold slime"
	desc = "A standard grenade containing weaponized slime extract."
	stage = 2

	New()
		..()
		var/obj/item/slime_extract/gold/B1 = new(src)
		B1.Uses = rand(1,3)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B2.reagents.add_reagent("plasma",5 * B1.Uses)
		beakers += B1
		beakers += B2

/obj/item/weapon/grenade/chem_grenade/large/monster/prox
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/prox_sensor)

/obj/item/weapon/grenade/chem_grenade/large/monster/mine
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/mousetrap)

/obj/item/weapon/grenade/chem_grenade/large/monster/remote
	New()
		..()
		CreateDefaultTrigger(/obj/item/device/assembly/signaler)

/obj/item/weapon/grenade/chem_grenade/large/feast
	payload_name = "silver slime"
	desc = "A standard grenade containing weaponized slime extract."
	stage = 2

	New()
		..()
		var/obj/item/slime_extract/silver/B1 = new(src)
		B1.Uses = rand(1,3)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)
		B2.reagents.add_reagent("plasma",5 * B1.Uses)
		beakers += B1
		beakers += B2

// Slime Clusterbusters
/*/obj/item/weapon/grenade/clusterbuster/bluespace
	name = "Bluespace Megabomb"
	desc = "Widely regarded as proof that while there is a God, He is Insane."
	payload = /obj/item/weapon/grenade/chem_grenade/large/bluespace*/

/obj/item/weapon/grenade/clusterbuster/monster
	name = "Monster Megabomb"
	desc = "Widely regarded as proof that there is no God."
	payload = /obj/item/weapon/grenade/chem_grenade/large/monster

// --------------------------------------
//  Syndie Kits
// --------------------------------------

/obj/item/weapon/storage/box/syndie_kit/remotegrenade
	name = "Remote Grenade Kit"
	New()
		..()
		new /obj/item/weapon/grenade/chem_grenade/explosion/remote(src)
		new /obj/item/device/multitool(src) // used to adjust the chemgrenade's signaller
		new /obj/item/device/assembly/signaler(src)
		return
/obj/item/weapon/storage/box/syndie_kit/remoteemp
	name = "Remote EMP Kit"
	New()
		..()
		new /obj/item/weapon/grenade/chem_grenade/emp/remote(src)
		new /obj/item/device/multitool(src) // used to adjust the chemgrenade's signaller
		new /obj/item/device/assembly/signaler(src)
		return
/obj/item/weapon/storage/box/syndie_kit/remotelube
	name = "Remote Lube Kit"
	New()
		..()
		new /obj/item/weapon/grenade/chem_grenade/lube(src)
		new /obj/item/device/multitool(src) // used to adjust the chemgrenade's signaller
		new /obj/item/device/assembly/signaler(src)
		return
// --------------------------------------
// Clusterbuster Variable Payload Grenade
//   Adapted from flashbang/clusterbang
// --------------------------------------

/obj/item/weapon/grenade/clusterbuster
	desc = "This highly intimidating bunch of hardware seems eager to be let loose."
	name = "Clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"
	var/payload = /obj/item/weapon/grenade/flashbang


// Subtypes

// Serious grenades
/obj/item/weapon/grenade/clusterbuster/explosion
	name = "Cluster Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/explosion
/obj/item/weapon/grenade/clusterbuster/emp
	name = "Electromagnetic Storm"
	payload = /obj/item/weapon/grenade/chem_grenade/emp
/obj/item/weapon/grenade/clusterbuster/smoke
	name = "Ninja Vanish"
	payload = /obj/item/weapon/grenade/smokebomb

// Not serious grenades
/obj/item/weapon/grenade/clusterbuster/meat
	name = "Mega Meat Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/meat
/obj/item/weapon/grenade/clusterbuster/booze
	name = "Booze Grenade"
	payload = /obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink
/obj/item/weapon/grenade/clusterbuster/honk
	name = "Mega Honk Grenade"
	payload = /obj/item/weapon/bananapeel
/obj/item/weapon/grenade/clusterbuster/xmas
	name = "Christmas Miracle"
	payload = /obj/item/weapon/a_gift
/obj/item/weapon/grenade/clusterbuster/soap
	name = "Megamaid's Passive-Aggressive Soap-creation Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/soap
/obj/item/weapon/grenade/clusterbuster/dirt
	name = "Megamaid's Job Security Grenade"
	payload = /obj/effect/decal/cleanable/random
/obj/item/weapon/grenade/clusterbuster/megadirt
	name = "Megamaid's Revenge Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/dirt
/obj/item/weapon/grenade/clusterbuster/inferno
	name = "Little Boy"
	payload = /obj/item/weapon/grenade/chem_grenade/incendiary
/obj/item/weapon/grenade/clusterbuster/apocalypsefake
	name = "Fun Bomb"
	desc = "Not like the other bomb."
	payload = /obj/item/toy/spinningtoy

// Grenades that should never see the light of day
/obj/item/weapon/grenade/clusterbuster/apocalypse
	name = "Apocalypse Bomb"
	desc = "No matter what, do not EVER use this."
	payload = /obj/machinery/singularity

/obj/item/weapon/grenade/clusterbuster/ultima
	name = "Earth Shattering Kaboom"
	desc = "Contains one Aludium Q-36 explosive space modulator."
	payload = /obj/item/weapon/grenade/chem_grenade/explosion

/obj/item/weapon/grenade/clusterbuster/lube
	name = "Newton's First Law"
	desc = "An object in motion remains in motion."
	payload = /obj/item/weapon/grenade/chem_grenade/lube


/*/obj/item/weapon/grenade/clusterbuster/bluespace
	name = "Maximum Warp"
	desc = "Spacetime: Nice job breaking it, hero."
	payload = /obj/item/weapon/grenade/chem_grenade/large/bluespace*/
/obj/item/weapon/grenade/clusterbuster/monster
	name = "The Monster Mash"
	desc = "It's a graveyeard smash."
	payload = /obj/item/weapon/grenade/chem_grenade/large/monster
/obj/item/weapon/grenade/clusterbuster/banquet
	name = "Bork Bork Bonanza"
	desc = "Bork bork bork."
	payload = /obj/item/weapon/grenade/clusterbuster/banquet/child
	child
		payload = /obj/item/weapon/grenade/chem_grenade/large/feast

// Mob spawning grenades
/obj/item/weapon/grenade/clusterbuster/aviary
	name = "Poly-Poly Grenade"
	desc = "That's an uncomfortable number of birds."
	payload = /mob/living/simple_animal/parrot
/obj/item/weapon/grenade/clusterbuster/monkey
	name = "Barrel of Monkeys"
	desc = "Not really that much fun."
	payload = /mob/living/carbon/monkey
/obj/item/weapon/grenade/clusterbuster/fluffy
	name = "Fluffy Love Bomb"
	desc = "Exactly as snuggly as it sounds."
	payload = /mob/living/simple_animal/corgi/puppy

/obj/item/weapon/grenade/clusterbuster/prime()
	var/numspawned = rand(4,8)
	var/again = 0
	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			again++
			numspawned --

	for(,numspawned > 0, numspawned--)
		spawn(0)
			new /obj/item/weapon/grenade/clusterbuster/node(src.loc,payload,name)//Launches payload
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	for(,again > 0, again--)
		spawn(0)
			new /obj/item/weapon/grenade/clusterbuster/segment(src.loc,payload,name)//Creates a 'segment' that launches more payloads
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	spawn(0)
		del(src)
		return

/obj/item/weapon/grenade/clusterbuster/segment
	desc = "What's happening? Aaah!"
	name = "clusterbuster segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"

/obj/item/weapon/grenade/clusterbuster/segment/New(var/turf/newloc,var/T,var/N)//Segments should never exist except part of the clusterbang, since these immediately 'do their thing' and asplode
	icon_state = "clusterbang_segment_active"
	active = 1
	payload = T
	name = N
	var/stepdist = rand(1,5)		//How far to step
	var/temploc = src.loc			//Saves the current location to know where to step away from
	walk_away(src,temploc,stepdist)	//I must go, my people need me
	var/dettime = rand(15,60)
	spawn(dettime)
		prime()

/obj/item/weapon/grenade/clusterbuster/segment/prime()
	var/numspawned = rand(4,8)
	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			numspawned --

	for(,numspawned > 0, numspawned--)
		new /obj/item/weapon/grenade/clusterbuster/node(src.loc,payload)
		spawn(0)
			playsound(src.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	del(src)
	return

/obj/item/weapon/grenade/clusterbuster/node/New(var/turf/newloc,var/T,var/N)
	icon_state = "flashbang_active"
	active = 1
	payload = T
	name = N
	var/stepdist = rand(1,4)
	var/temploc = src.loc
	walk_away(src,temploc,stepdist)
	var/dettime = rand(15,60)
	spawn(dettime)
		var/atom/A = new payload(loc)
		if(istype(A,/obj/item/weapon/grenade))
			A:prime()
		if(istype(A,/obj/machinery/singularity)) // I can't emphasize enough how much you should never use this grenade
			A:energy = 200
		del src
