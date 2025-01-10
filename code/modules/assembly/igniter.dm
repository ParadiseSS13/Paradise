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
		location.hotspot_expose(1000, 1)
	visible_message(
		"<span class='notice'>Sparks shoot out of [src].</span>",
		"<span class='warning'>You hear a shower of sparks shooting out from something!</span>"
		)
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

/obj/item/assembly/igniter/attack__legacy__attackchain(mob/living/target, mob/living/user)
	if(!cigarette_lighter_act(user, target))
		return ..()

/obj/item/assembly/igniter/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/cig = ..()
	if(!cig)
		return !isnull(cig)

	if(target == user)
		user.visible_message(
			"<span class='notice'>[user] presses [src] against [cig] and activates it, lighting [cig] in a shower of sparks!</span>",
			"<span class='notice'>You press [src] against [cig] and activates it, lighting [cig] in a shower of sparks!</span>",
			"<span class='warning'>You hear a shower of sparks shooting out from something!</span>"
		)
	else
		user.visible_message(
			"<span class='notice'>[user] presses [src] against [cig] and activates it, lighting [cig] for [target] in a shower of sparks!</span>",
			"<span class='notice'>You press [src] against [cig] and activate it, lighting [cig] in a shower of sparks!</span>",
			"<span class='warning'>You hear a shower of sparks shooting out from something!</span>"
		)
	sparks.start()	// Make sparks fly!
	cig.light(user, target)
	return TRUE

/obj/item/assembly/igniter/attack_self__legacy__attackchain(mob/user)
	if(!istype(loc, /obj/item/assembly_holder))
		activate()
	add_fingerprint(user)

/obj/item/assembly/igniter/get_heat()
	return 2000
