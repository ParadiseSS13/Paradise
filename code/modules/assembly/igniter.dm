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

// For lighting cigarettes.
/obj/item/assembly/igniter/attack(mob/living/M, mob/living/user)
	var/obj/item/clothing/mask/cigarette/cig = M?.wear_mask
	if(!istype(cig) || user.zone_selected != "mouth" || user.a_intent != INTENT_HELP) 
		return ..()
	cigarette_lighter_act(user, M)

/obj/item/assembly/igniter/cigarette_lighter_act(mob/living/user, mob/living/target, obj/item/direct_attackby_item)
	var/obj/item/clothing/mask/cigarette/I = target?.wear_mask
	if(direct_attackby_item)
		I = direct_attackby_item

	if(!I.handle_cigarette_lighter_act(user, src))
		return

	if(target == user)
		user.visible_message(
			"<span class='notice'>[user] presses [src] against [I] and activates it, lighting [I] in a shower of sparks!</span>",
			"<span class='notice'>You press [src] against [I] and activates it, lighting [I] in a shower of sparks!</span>",
			"<span class='warning'>You hear a shower of sparks shooting out from something!</span>"
			)
	else
		user.visible_message(
			"<span class='notice'>[user] presses [src] against [I] and activates it, lighting [I] for [target] in a shower of sparks!</span>",
			"<span class='notice'>You press [src] against [I] and activate it, lighting [I] in a shower of sparks!</span>",
			"<span class='warning'>You hear a shower of sparks shooting out from something!</span>"
			)
	sparks.start()	// Make sparks fly!
	I.light(user, target)

/obj/item/assembly/igniter/attack_self(mob/user)
	if(!istype(loc, /obj/item/assembly_holder))
		activate()
	add_fingerprint(user)

/obj/item/assembly/igniter/get_heat()
	return 2000
