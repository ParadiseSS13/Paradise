/obj/item/grenade/chem_grenade/large/explosionslime
	payload_name = "oil slime"
	desc = "A standard grenade containing weaponized slime extract."
	stage = 2

/obj/item/grenade/chem_grenade/large/explosionslime/New()
	..()
	var/obj/item/slime_extract/oil/B1 = new(src)
	B1.Uses = rand(1,3)
	var/obj/item/reagent_containers/glass/beaker/B2 = new(src)
	B2.reagents.add_reagent("plasma_dust",5 * B1.Uses)
	beakers += B1
	beakers += B2

/obj/item/grenade/chem_grenade/large/explosionslime/prox/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/prox_sensor)

/obj/item/grenade/chem_grenade/large/explosionslime/mine/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/mousetrap)

/obj/item/grenade/chem_grenade/large/explosionslime/remote/New()
	..()
	CreateDefaultTrigger(/obj/item/assembly/signaler)
