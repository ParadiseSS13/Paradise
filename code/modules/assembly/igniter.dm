/obj/item/device/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustable substances."
	icon_state = "igniter"
	m_amt = 500
	g_amt = 50
	w_amt = 10
	origin_tech = "magnets=1"

	describe()
		return "The igniter is [secured?"secured.":"unsecured."]"

	activate()
		if(!..())	return 0//Cooldown check
		var/turf/location = get_turf(loc)
		if(location)	location.hotspot_expose(1000,1000)
		if (istype(src.loc,/obj/item/device/assembly_holder))
			if (istype(src.loc.loc, /obj/structure/reagent_dispensers/fueltank/))
				var/obj/structure/reagent_dispensers/fueltank/tank = src.loc.loc
				if (tank)
					tank.explode()
			if (istype(src.loc.loc, /obj/item/weapon/reagent_containers/glass/beaker/))
				var/obj/item/weapon/reagent_containers/glass/beaker/beakerbomb = src.loc.loc
				if(beakerbomb)
					beakerbomb.heat_beaker()

		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(3, 1, src)
		s.start()

		return 1


	attack_self(mob/user as mob)
		activate()
		add_fingerprint(user)
		return