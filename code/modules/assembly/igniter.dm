/obj/item/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustible substances."
	icon_state = "igniter"
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	origin_tech = "magnets=1"
	var/datum/effect_system/spark_spread/sparks

/obj/item/assembly/igniter/Initialize(mapload)
	. = ..()
	sparks = new /datum/effect_system/spark_spread
	sparks.set_up(2, 0, src)
	sparks.attach(src)

/obj/item/assembly/igniter/Destroy()
	QDEL_NULL(sparks)
	return ..()

/obj/item/assembly/igniter/examine(mob/user)
	. = ..()
	. += "The igniter is [secured ? "secured." : "unsecured."]"


/obj/item/assembly/igniter/activate()
	if(!..())
		return FALSE //Cooldown check

	var/turf/location = get_turf(loc)
	if(location)
		location.hotspot_expose(1000, 1000)

	sparks.start()

	if(istype(loc, /obj/item/assembly_holder))
		var/locloc = loc.loc
		if(istype(locloc, /obj/structure/reagent_dispensers/fueltank))
			var/obj/structure/reagent_dispensers/fueltank/tank = locloc
			if(tank)
				tank.boom(TRUE)  // this qdel's `src`

		if(istype(locloc, /obj/item/onetankbomb))
			var/obj/item/onetankbomb/bomb = locloc
			if(bomb?.bombtank)
				bomb.bombtank.detonate()

		else if(istype(locloc, /obj/item/reagent_containers/glass/beaker))
			var/obj/item/reagent_containers/glass/beaker/beakerbomb = locloc
			if(beakerbomb)
				beakerbomb.heat_beaker()

		else if(istype(locloc, /obj/item/grenade/chem_grenade))
			var/obj/item/grenade/chem_grenade/CG = locloc
			CG.prime()

	return TRUE


/obj/item/assembly/igniter/attack_self(mob/user)
	if(!istype(loc, /obj/item/assembly_holder))
		activate()
	add_fingerprint(user)
