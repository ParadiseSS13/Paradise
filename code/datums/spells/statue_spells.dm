// Flicker lights
/obj/effect/proc_holder/spell/aoe_turf/flicker_lights
	name = "Flicker Lights"
	desc = "You will trigger a large amount of lights around you to flicker."

	charge_max = 300
	clothes_req = 0
	range = 14

/obj/effect/proc_holder/spell/aoe_turf/flicker_lights/cast(list/targets)
	for(var/turf/T in targets)
		for(var/obj/machinery/light/L in T)
			L.flicker()
	return

//Blind AOE
/obj/effect/proc_holder/spell/aoe_turf/blindness
	name = "Blindness"
	desc = "Your prey will be momentarily blind for you to advance on them."

	message = "<span class='notice'>You glare your eyes.</span>"
	charge_max = 600
	clothes_req = 0
	range = 10

/obj/effect/proc_holder/spell/aoe_turf/blindness/cast(list/targets)
	for(var/mob/living/L in living_mob_list)
		if(L == usr)
			continue
		var/turf/T = get_turf(L.loc)
		if(T && T in targets)
			L.EyeBlind(4)
	return

//Toggle Night Vision
/obj/effect/proc_holder/spell/targeted/night_vision
	name = "Toggle Nightvision \[ON\]"
	desc = "Toggle your nightvision mode."

	charge_max = 10
	clothes_req = 0

	message = "<span class='notice'>You toggle your night vision!</span>"
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/night_vision/cast(list/targets)

	for(var/mob/living/target in targets)
		if(target.see_invisible == SEE_INVISIBLE_LIVING)
			target.see_invisible = SEE_INVISIBLE_NOLIGHTING
			name = "Toggle Nightvision \[ON\]"
		else
			target.see_invisible = SEE_INVISIBLE_LIVING
			name = "Toggle Nightvision \[OFF\]"
	return
