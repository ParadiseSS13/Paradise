/obj/item/grenade/smokebomb
	name = "smoke bomb"
	desc = "A grenade filled with chemical agents that will turn into a dense smoke when detonated, making it impossible to see through without specialised optics."
	icon_state = "smoke"
	inhand_icon_state = "smoke"
	det_time = 2 SECONDS
	modifiable_timer = FALSE
	var/datum/effect_system/smoke_spread/bad/smoke

/obj/item/grenade/smokebomb/Initialize(mapload)
	. = ..()
	smoke = new /datum/effect_system/smoke_spread/bad
	smoke.attach(src)

/obj/item/grenade/smokebomb/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/grenade/smokebomb/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, TRUE, -3)
	smoke.set_up(10, FALSE)
	// The grenade is deleted straight away, so the smoke is moved to this tile and let go so Destroy() doesn't stop the later puffs.
	smoke.attach(get_turf(src))
	smoke.start()
	for(var/puff in 1 to 3)
		addtimer(CALLBACK(smoke, TYPE_PROC_REF(/datum/effect_system/smoke_spread, start)), puff SECONDS)
	smoke = null
	qdel(src)
