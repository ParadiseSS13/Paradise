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
		B2.reagents.add_reagent("cryoxadone",30)

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


/obj/item/weapon/grenade/chem_grenade/drugs
	payload_name = "miracle"
	desc = "How does it work?"
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/large/B2 = new(src)

		B1.reagents.add_reagent("space_drugs", 25)
		B1.reagents.add_reagent("lsd", 25)
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
		B2.reagents.add_reagent("facid",30)
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
////////////////////
//Clusterbang
////////////////////
/obj/item/weapon/grenade/clusterbuster
	desc = "Use of this weapon may constiute a war crime in your area, consult your local captain."
	name = "clusterbang"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang"
	var/payload = /obj/item/weapon/grenade/flashbang/cluster

/obj/item/weapon/grenade/clusterbuster/prime()
	update_mob()
	var/numspawned = rand(4,8)
	var/again = 0

	for(var/more = numspawned,more > 0,more--)
		if(prob(35))
			again++
			numspawned--

	for(var/loop = again ,loop > 0, loop--)
		new /obj/item/weapon/grenade/clusterbuster/segment(loc, payload)//Creates 'segments' that launches a few more payloads

	new /obj/effect/payload_spawner(loc, payload, numspawned)//Launches payload

	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	qdel(src)


//////////////////////
//Clusterbang segment
//////////////////////
/obj/item/weapon/grenade/clusterbuster/segment
	desc = "A smaller segment of a clusterbang. Better run."
	name = "clusterbang segment"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "clusterbang_segment"

/obj/item/weapon/grenade/clusterbuster/segment/New(var/loc, var/payload_type = /obj/item/weapon/grenade/flashbang/cluster)
	..()
	icon_state = "clusterbang_segment_active"
	payload = payload_type
	active = 1
	walk_away(src,loc,rand(1,4))
	spawn(rand(15,60))
		prime()


/obj/item/weapon/grenade/clusterbuster/segment/prime()

	new /obj/effect/payload_spawner(loc, payload, rand(4,8))

	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)

	qdel(src)

//////////////////////////////////
//The payload spawner effect
/////////////////////////////////
/obj/effect/payload_spawner/New(var/turf/newloc,var/type, var/numspawned as num)

	for(var/loop = numspawned ,loop > 0, loop--)
		var/obj/item/weapon/grenade/P = new type(loc)
		P.active = 1
		walk_away(P,loc,rand(1,4))

		spawn(rand(15,60))
			if(P && isnull(P.gcDestroyed))
				P.prime()
			qdel(src)


//////////////////////////////////
//Custom payload clusterbusters
/////////////////////////////////
/obj/item/weapon/grenade/flashbang/cluster
	icon_state = "flashbang_active"
	banglet = 1

/obj/item/weapon/grenade/clusterbuster/emp
	name = "Electromagnetic Storm"
	payload = /obj/item/weapon/grenade/empgrenade

/obj/item/weapon/grenade/clusterbuster/smoke
	name = "Ninja Vanish"
	payload = /obj/item/weapon/grenade/smokebomb

/obj/item/weapon/grenade/clusterbuster/metalfoam
	name = "Instant Concrete"
	payload = /obj/item/weapon/grenade/chem_grenade/metalfoam

/obj/item/weapon/grenade/clusterbuster/inferno
	name = "Inferno"
	payload = /obj/item/weapon/grenade/chem_grenade/incendiary

/obj/item/weapon/grenade/clusterbuster/antiweed
	name = "RoundDown"
	payload = /obj/item/weapon/grenade/chem_grenade/antiweed

/obj/item/weapon/grenade/clusterbuster/cleaner
	name = "Mr. Proper"
	payload = /obj/item/weapon/grenade/chem_grenade/cleaner

/obj/item/weapon/grenade/clusterbuster/teargas
	name = "Oignon Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/teargas

/obj/item/weapon/grenade/clusterbuster/facid
	name = "Aciding Rain"
	payload = /obj/item/weapon/grenade/chem_grenade/facid

/obj/item/weapon/grenade/clusterbuster/syndieminibomb
	name = "SyndiWrath"
	payload = /obj/item/weapon/grenade/syndieminibomb

/obj/item/weapon/grenade/clusterbuster/spawner_manhacks
	name = "iViscerator"
	payload = /obj/item/weapon/grenade/spawnergrenade/manhacks

/obj/item/weapon/grenade/clusterbuster/spawner_spesscarp
	name = "Invasion of the Space Carps"
	payload = /obj/item/weapon/grenade/spawnergrenade/spesscarp

/obj/item/weapon/grenade/clusterbuster/monster
	name = "Monster Megabomb"
	payload = /obj/item/weapon/grenade/chem_grenade/large/monster

/obj/item/weapon/grenade/clusterbuster/meat
	name = "Mega Meat Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/meat

/obj/item/weapon/grenade/clusterbuster/megadirt
	name = "Megamaid's Revenge Grenade"
	payload = /obj/item/weapon/grenade/chem_grenade/dirt

/obj/item/weapon/grenade/clusterbuster/inferno
	name = "Little Boy"
	payload = /obj/item/weapon/grenade/chem_grenade/incendiary

/obj/item/weapon/grenade/clusterbuster/ultima
	name = "Earth Shattering Kaboom"
	desc = "Contains one Aludium Q-36 explosive space modulator."
	payload = /obj/item/weapon/grenade/chem_grenade/explosion

/obj/item/weapon/grenade/clusterbuster/lube
	name = "Newton's First Law"
	desc = "An object in motion remains in motion."
	payload = /obj/item/weapon/grenade/chem_grenade/lube