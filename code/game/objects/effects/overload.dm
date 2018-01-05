
/obj/structure/fusionreactor
	name = "syndicate fusion reactor"
	desc = ""
	icon = 'icons/obj/singularity.dmi'
	icon_state = "beaconsynd1"
	//icon = 'icons/obj/device.dmi'
	//icon_state = "powersink1"
	anchored = 1
	var/health = 30
	var/area/syndicate_depot/depotarea

/obj/structure/fusionreactor/New()
	..()
	depotarea = areaMaster
	if(depotarea)
		depotarea.reactor = src

/obj/structure/fusionreactor/ex_act(severity)
	health -= 10 * severity
	healthcheck()

/obj/structure/fusionreactor/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()

/obj/structure/fusionreactor/proc/healthcheck()
	if(health <= 0)
		overload(FALSE)

/obj/structure/fusionreactor/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		playsound(loc, I.usesound, 50, 1)
		to_chat(user, "<span class='notice'>The [src] is too well secured to the floor.</span>")
	else if(isscrewdriver(I))
		to_chat(user, "<span class='notice'>You try to screwdriver open [src], but accidentally release some radiation!</span>")
		if(prob(50))
			empulse(src, 4, 10)
		else
			for(var/mob/living/M in range(10, loc))
				M.apply_effect(rand(5, 25), IRRADIATE)
	else
		return ..(I, user, params)

/obj/structure/fusionreactor/proc/overload(var/deliberate)
	var/obj/effect/overload/O = new /obj/effect/overload(get_turf(src))
	if(deliberate)
		O.deliberate = TRUE
		O.max_cycles = 7
	qdel(src)

/obj/effect/overload
	icon = 'icons/obj/tesla_engine/energy_ball.dmi'
	icon_state = "energy_ball"
	pixel_x = -32
	pixel_y = -32
	anchored = 1
	var/cycles = 0
	var/beepsound = 'sound/items/timer.ogg'
	var/deliberate = FALSE
	var/max_cycles = 15

/obj/effect/overload/New()
	..()
	processing_objects.Add(src)

/obj/effect/overload/process()
	if(cycles < max_cycles)
		if(!deliberate)
			playsound(loc, beepsound, 50, 0)
		cycles++
		var/fire_range = cycles
		if(fire_range > 3)
			fire_range = 5
		var/turf/T = get_turf(src)
		for(var/turf/simulated/turf in range(fire_range, T))
			new /obj/effect/hotspot(turf)
		return

	if(areaMaster.fire)
		areaMaster.fire_reset()
	explosion(get_turf(src), 20, 30, 40, 50, 1, 1, 40, 0, 1)
	processing_objects.Remove(src)
	qdel(src)
