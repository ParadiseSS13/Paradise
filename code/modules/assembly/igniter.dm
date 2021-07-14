/obj/item/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustable substances."
	icon_state = "igniter"
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	origin_tech = "magnets=1"
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread

/obj/item/assembly/igniter/New()
	..()
	sparks.set_up(2, 0, src)
	sparks.attach(src)

/obj/item/assembly/igniter/Destroy()
	QDEL_NULL(sparks)
	return ..()


/obj/item/assembly/igniter/describe()
	return "The igniter is [secured ? "secured." : "unsecured."]"


/obj/item/assembly/igniter/activate()
	if(!..())
		return FALSE//Cooldown check
	var/turf/location = get_turf(loc)
	if(location)
		location.hotspot_expose(1000,1000)
	if(istype(loc, /obj/item/assembly_holder))
		if(istype(loc.loc, /obj/structure/reagent_dispensers/fueltank))
			var/obj/structure/reagent_dispensers/fueltank/tank = loc.loc
			if(tank)
				tank.boom(TRUE)
		if(istype(loc.loc, /obj/item/reagent_containers/glass/beaker))
			var/obj/item/reagent_containers/glass/beaker/beakerbomb = loc.loc
			if(beakerbomb)
				beakerbomb.heat_beaker()
	sparks.start()
	return TRUE


/obj/item/assembly/igniter/attack_self(mob/user)
	activate()
	add_fingerprint(user)
	return
