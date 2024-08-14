/obj/item/grenade/chem_grenade/dirt
	payload_name = "dirt"
	desc = "From the makers of BLAM! brand foaming space cleaner, this bomb guarantees steady work for any janitor."
	stage = 2

/obj/item/grenade/chem_grenade/dirt/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/list/muck = list("blood","carbon","flour")
	var/filth = pick(muck)
	muck -= filth

	B1.reagents.add_reagent(filth, 25)
	if(prob(25))
		muck += "radium"
		B1.reagents.add_reagent(pick(muck), 25)

	beakers += B1


/obj/item/grenade/chem_grenade/meat
	payload_name = "meat"
	desc = "Not always as messy as the name implies."
	stage = 2


/obj/item/grenade/chem_grenade/meat/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("blood",60)
	if(prob(5))
		B1.reagents.add_reagent("blood",1) // Quality control problems, causes a mess
	B2.reagents.add_reagent("cryoxadone",30)

	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/holywater
	payload_name = "holy water"
	desc = "Then shalt thou count to three, no more, no less."
	stage = 2
	det_time = 3 SECONDS

/obj/item/grenade/chem_grenade/holywater/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/B = new(src)
	B.reagents.add_reagent("holywater",100)
	beakers += B

/obj/item/grenade/chem_grenade/drugs
	payload_name = "miracle"
	desc = "How does it work?"
	stage = 2

/obj/item/grenade/chem_grenade/drugs/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

	B1.reagents.add_reagent("space_drugs", 25)
	B1.reagents.add_reagent("lsd", 25)
	B1.reagents.add_reagent("potassium", 25)
	B2.reagents.add_reagent("phosphorus", 25)
	B2.reagents.add_reagent("sugar", 25)

	beakers += B1
	beakers += B2
	update_icon()

/obj/item/grenade/chem_grenade/ethanol
	payload_name = "ethanol"
	desc = "Ach, that hits the spot."
	stage = 2

/obj/item/grenade/chem_grenade/ethanol/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)

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
/obj/item/grenade/chem_grenade/lube
	payload_name = "lubricant"
	stage = 2

/obj/item/grenade/chem_grenade/lube/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	B1.reagents.add_reagent("lube",50)
	beakers += B1

/obj/item/grenade/chem_grenade/lube/remote/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)

/obj/item/grenade/chem_grenade/lube/prox/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)

/obj/item/grenade/chem_grenade/lube/tripwire/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/infra)


// Basic explosion grenade
/obj/item/grenade/chem_grenade/explosion
	payload_name = "conventional"
	stage = 2

/obj/item/grenade/chem_grenade/explosion/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)
	B1.reagents.add_reagent("glycerol",30) // todo: someone says NG is overpowered, test.
	B1.reagents.add_reagent("sacid",15)
	B2.reagents.add_reagent("sacid",15)
	B2.reagents.add_reagent("facid",30)
	beakers += B1
	beakers += B2

// Assembly Variants
/obj/item/grenade/chem_grenade/explosion/remote/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)

/obj/item/grenade/chem_grenade/explosion/prox/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)

/obj/item/grenade/chem_grenade/explosion/mine/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/mousetrap)

/obj/item/grenade/chem_grenade/explosion/mine_armed/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/mousetrap/armed)


// Water + Potassium = Boom

/obj/item/grenade/chem_grenade/waterpotassium
	payload_name = "chem explosive"
	stage = 2

/obj/item/grenade/chem_grenade/waterpotassium/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/B2 = new(src)
	B1.reagents.add_reagent("water",100)
	B2.reagents.add_reagent("potassium",100)
	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/waterpotassium/remote/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)

/obj/item/grenade/chem_grenade/waterpotassium/prox/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)


/obj/item/grenade/chem_grenade/waterpotassium/tripwire/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/infra)

/obj/item/grenade/chem_grenade/waterpotassium/tripwire_armed/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/infra/armed)

/obj/item/grenade/chem_grenade/waterpotassium/tripwire_armed_stealth/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/infra/armed/stealth)




// Basic EMP grenade
/obj/item/grenade/chem_grenade/emp
	payload_name = "EMP"
	stage = 2

/obj/item/grenade/chem_grenade/emp/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/B1 = new(src)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)
	B1.reagents.add_reagent("uranium",50)
	B2.reagents.add_reagent("iron",50)
	beakers += B1
	beakers += B2

// Assembly Variants
/obj/item/grenade/chem_grenade/emp/remote/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)

/obj/item/grenade/chem_grenade/emp/prox/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)

/obj/item/grenade/chem_grenade/emp/mine/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/mousetrap)

/obj/item/grenade/chem_grenade/large/monster
	payload_name = "gold slime"
	desc = "A standard grenade containing weaponized slime extract."
	stage = 2

/obj/item/grenade/chem_grenade/large/monster/Initialize(mapload)
	. = ..()
	var/obj/item/slime_extract/gold/B1 = new(src)
	B1.Uses = rand(1,3)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)
	B2.reagents.add_reagent("plasma",5 * B1.Uses)
	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/large/monster/prox/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)

/obj/item/grenade/chem_grenade/large/monster/mine/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/mousetrap)

/obj/item/grenade/chem_grenade/large/monster/remote/Initialize(mapload)
	. = ..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)

/obj/item/grenade/chem_grenade/large/feast
	payload_name = "silver slime"
	desc = "A standard grenade containing weaponized slime extract."
	stage = 2

/obj/item/grenade/chem_grenade/large/feast/Initialize(mapload)
	. = ..()
	var/obj/item/slime_extract/silver/B1 = new(src)
	B1.Uses = rand(1,3)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)
	B2.reagents.add_reagent("plasma",5 * B1.Uses)
	beakers += B1
	beakers += B2

// --------------------------------------
//  Syndie Kits
// --------------------------------------

/obj/item/storage/box/syndie_kit/remotegrenade
	name = "remote grenade kit"

/obj/item/storage/box/syndie_kit/remotegrenade/populate_contents()
	new /obj/item/grenade/chem_grenade/explosion/remote(src)
	new /obj/item/multitool(src) // used to adjust the chemgrenade's signaller
	new /obj/item/assembly/signaler(src)

/obj/item/storage/box/syndie_kit/remoteemp
	name = "remote EMP kit"

/obj/item/storage/box/syndie_kit/remoteemp/populate_contents()
	new /obj/item/grenade/chem_grenade/emp/remote(src)
	new /obj/item/multitool(src) // used to adjust the chemgrenade's signaller
	new /obj/item/assembly/signaler(src)

/obj/item/storage/box/syndie_kit/remotelube
	name = "remote lube kit"

/obj/item/storage/box/syndie_kit/remotelube/populate_contents()
	new /obj/item/grenade/chem_grenade/lube(src)
	new /obj/item/multitool(src) // used to adjust the chemgrenade's signaller
	new /obj/item/assembly/signaler(src)
