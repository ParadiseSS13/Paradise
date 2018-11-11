/datum/chemical_reaction/explosion_potassium
	name = "Explosion"
	id = "explosion_potassium"
	result = null
	required_reagents = list("water" = 1, "potassium" = 1)
	result_amount = 2
	mix_message = "The mixture explodes!"

/datum/chemical_reaction/explosion_potassium/on_reaction(datum/reagents/holder, created_volume)
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(round (created_volume/10, 1), holder.my_atom, 0, 0)
	e.start()
	holder.clear_reagents()

/datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	result = null
	required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	result_amount = 2

/datum/chemical_reaction/emp_pulse/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
	// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
	empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
	holder.clear_reagents()

/datum/chemical_reaction/beesplosion
	name = "Bee Explosion"
	id = "beesplosion"
	result = null
	required_reagents = list("honey" = 1, "strange_reagent" = 1, "radium" = 1)
	result_amount = 1

/datum/chemical_reaction/beesplosion/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	if(created_volume < 5)
		playsound(location,'sound/effects/sparks1.ogg', 100, 1)
	else
		playsound(location,'sound/creatures/bee.ogg', 100, 1)
		var/list/beeagents = list()
		for(var/X in holder.reagent_list)
			var/datum/reagent/R = X
			if(R.id in required_reagents)
				continue
			if(!R.can_synth)
				continue
			beeagents += R
		var/bee_amount = round(created_volume * 0.2)
		for(var/i in 1 to bee_amount)
			var/mob/living/simple_animal/hostile/poison/bees/new_bee = new(location)
			if(LAZYLEN(beeagents))
				new_bee.assign_reagent(pick(beeagents))

/datum/chemical_reaction/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	result = "nitroglycerin"
	required_reagents = list("glycerol" = 1, "facid" = 1, "sacid" = 1)
	result_amount = 2

/datum/chemical_reaction/nitroglycerin/on_reaction(datum/reagents/holder, created_volume)
	var/datum/effect_system/reagents_explosion/e = new()
	e.set_up(round(created_volume/2, 1), holder.my_atom, 0, 0)
	e.start()
	holder.clear_reagents()

/datum/chemical_reaction/stabilizing_agent
	name = "stabilizing_agent"
	id = "stabilizing_agent"
	result = "stabilizing_agent"
	required_reagents = list("iron" = 1, "oxygen" = 1, "hydrogen" = 1)
	result_amount = 2
	mix_message = "The mixture becomes a yellow liquid!"

/datum/chemical_reaction/clf3
	name = "Chlorine Trifluoride"
	id = "clf3"
	result = "clf3"
	required_reagents = list("chlorine" = 1, "fluorine" = 3)
	result_amount = 2
	min_temp = 424

/datum/chemical_reaction/clf3/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/turf in range(1,T))
		new /obj/effect/hotspot(turf)

/datum/chemical_reaction/sorium
	name = "Sorium"
	id = "sorium"
	result = "sorium"
	required_reagents = list("mercury" = 1, "oxygen" = 1, "nitrogen" = 1, "carbon" = 1)
	result_amount = 4

/datum/chemical_reaction/sorium/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 1, min(10, created_volume), min(11, created_volume + 1))
	holder.remove_reagent("sorium", created_volume)

/datum/chemical_reaction/sorium_vortex
	name = "sorium_vortex"
	id = "sorium_vortex"
	result = "sorium_vortex"
	required_reagents = list("sorium" = 1)
	result_amount = 1
	min_temp = 474

/datum/chemical_reaction/sorium_vortex/on_reaction(datum/reagents/holder, created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 1, min(10, created_volume), min(11, created_volume + 1))
	holder.remove_reagent("sorium_vortex", created_volume)

/datum/chemical_reaction/liquid_dark_matter
	name = "Liquid Dark Matter"
	id = "liquid_dark_matter"
	result = "liquid_dark_matter"
	required_reagents = list("plasma" = 1, "radium" = 1, "carbon" = 1)
	result_amount = 3

/datum/chemical_reaction/liquid_dark_matter/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 0, min(10, created_volume), min(11, created_volume + 1))
	holder.remove_reagent("liquid_dark_matter", created_volume)

/datum/chemical_reaction/ldm_vortex
	name = "LDM Vortex"
	id = "ldm_vortex"
	result = "ldm_vortex"
	required_reagents = list("liquid_dark_matter" = 1)
	result_amount = 1
	min_temp = 474

/datum/chemical_reaction/ldm_vortex/on_reaction(datum/reagents/holder, created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 0, min(10, created_volume), min(11, created_volume + 1))
	holder.remove_reagent("ldm_vortex", created_volume)

/datum/chemical_reaction/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	result = "blackpowder"
	required_reagents = list("saltpetre" = 1, "charcoal" = 1, "sulfur" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/blackpowder_explosion
	name = "Black Powder Kaboom"
	id = "blackpowder_explosion"
	result = null
	required_reagents = list("blackpowder" = 1)
	result_amount = 1
	min_temp = 474
	no_message = 1
	mix_sound = null

/datum/chemical_reaction/blackpowder_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	do_sparks(2, 1, location)
	sleep(rand(20,30))
	blackpowder_detonate(holder, created_volume)

/proc/blackpowder_detonate(datum/reagents/holder, created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	var/ex_severe = round(created_volume / 100)
	var/ex_heavy = round(created_volume / 42)
	var/ex_light = round(created_volume / 20)
	var/ex_flash = round(created_volume / 8)
	explosion(T,ex_severe,ex_heavy,ex_light,ex_flash, 1)
	// If this black powder is in a decal, remove the decal, because it just exploded
	if(istype(holder.my_atom, /obj/effect/decal/cleanable/dirt/blackpowder))
		spawn(0)
			qdel(holder.my_atom)

datum/chemical_reaction/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	result = "flash_powder"
	required_reagents = list("aluminum" = 1, "potassium" = 1, "sulfur" = 1, "chlorine" = 1)
	result_amount = 3

/datum/chemical_reaction/flash_powder/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	var/location = get_turf(holder.my_atom)
	do_sparks(2, 1, location)
	for(var/mob/living/carbon/C in viewers(5, location))
		if(C.flash_eyes())
			if(get_dist(C, location) < 4)
				C.Weaken(5)
				continue
			C.Stun(5)
	holder.remove_reagent("flash_powder", created_volume)

/datum/chemical_reaction/flash_powder_flash
	name = "Flash powder activation"
	id = "flash_powder_flash"
	result = null
	required_reagents = list("flash_powder" = 1)
	min_temp = 374

/datum/chemical_reaction/flash_powder_flash/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	do_sparks(2, 1, location)
	for(var/mob/living/carbon/C in viewers(5, location))
		if(C.flash_eyes())
			if(get_dist(C, location) < 4)
				C.Weaken(5)
				continue
			C.Stun(5)

/datum/chemical_reaction/smoke_powder
	name = "smoke_powder"
	id = "smoke_powder"
	result = "smoke_powder"
	required_reagents = list("stabilizing_agent" = 1, "potassium" = 1, "sugar" = 1, "phosphorus" = 1)
	result_amount = 3
	mix_message = "The mixture sets into a greyish powder!"

/datum/chemical_reaction/smoke
	name = "smoke"
	id = "smoke"
	result = null
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)
	result_amount = 1
	mix_message = "The mixture quickly turns into a pall of smoke!"
	var/forbidden_reagents = list("sugar", "phosphorus", "potassium", "stimulants") //Do not transfer this stuff through smoke.

/datum/chemical_reaction/smoke/on_reaction(datum/reagents/holder, created_volume)
	for(var/f_reagent in forbidden_reagents)
		if(holder.has_reagent(f_reagent))
			holder.remove_reagent(f_reagent, holder.get_reagent_amount(f_reagent))
	var/location = get_turf(holder.my_atom)
	var/datum/effect_system/smoke_spread/chem/S = new
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	if(S)
		S.set_up(holder, 10, 0, location)
		if(created_volume < 5)
			S.start(1)
		if(created_volume >=5 && created_volume < 10)
			S.start(2)
		if(created_volume >= 10 && created_volume < 15)
			S.start(3)
		if(created_volume >=15)
			S.start(4)
	if(holder && holder.my_atom)
		holder.clear_reagents()

/datum/chemical_reaction/smoke/smoke_powder
	name = "smoke_powder_smoke"
	id = "smoke_powder_smoke"
	required_reagents = list("smoke_powder" = 1)
	min_temp = 374
	secondary = 1
	result_amount = 1
	forbidden_reagents = list("stimulants")
	mix_sound = null

/datum/chemical_reaction/sonic_powder
	name = "sonic_powder"
	id = "sonic_powder"
	result = "sonic_powder"
	required_reagents = list("oxygen" = 1, "cola" = 1, "phosphorus" = 1)
	result_amount = 3

/datum/chemical_reaction/sonic_powder/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, 1)
	for(var/mob/living/M in hearers(5, location))
		var/ear_safety = 0
		var/distance = max(1,get_dist(src,T))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if((H.r_ear && (H.r_ear.flags & EARBANGPROTECT)) || (H.l_ear && (H.l_ear.flags & EARBANGPROTECT)) || (H.head && (H.head.flags & HEADBANGPROTECT)))
					ear_safety++
			to_chat(C, "<span class='warning'>BANG</span>")
		if(!ear_safety)
			M.Stun(max(10/distance, 3))
			M.Weaken(max(10/distance, 3))
			M.AdjustEarDamage(rand(0, 5), 15)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
				if(istype(ears))
					if(ears.ear_damage >= 15)
						to_chat(M, "<span class='warning'>Your ears start to ring badly!</span>")
						if(prob(ears.ear_damage - 5))
							to_chat(M, "<span class='warning'>You can't hear anything!</span>")
							M.BecomeDeaf()
					else
						if(ears.ear_damage >= 5)
							to_chat(M, "<span class='warning'>Your ears start to ring!</span>")
	holder.remove_reagent("sonic_powder", created_volume)

/datum/chemical_reaction/sonic_powder_deafen
	name = "sonic_powder_deafen"
	id = "sonic_powder_deafen"
	result = null
	required_reagents = list("sonic_powder" = 1)
	min_temp = 374

/datum/chemical_reaction/sonic_powder_deafen/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	playsound(location, 'sound/effects/bang.ogg', 25, 1)
	for(var/mob/living/M in hearers(5, location))
		var/ear_safety = 0
		var/distance = max(1,get_dist(src,T))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if((H.r_ear && (H.r_ear.flags & EARBANGPROTECT)) || (H.l_ear && (H.l_ear.flags & EARBANGPROTECT)) || (H.head && (H.head.flags & HEADBANGPROTECT)))
					ear_safety++
		to_chat(M, "<span class='warning'>BANG</span>")
		if(!ear_safety)
			M.Stun(max(10/distance, 3))
			M.Weaken(max(10/distance, 3))
			M.AdjustEarDamage(rand(0, 5), 15)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
				if(istype(ears))
					if(ears.ear_damage >= 15)
						to_chat(M, "<span class='warning'>Your ears start to ring badly!</span>")
						if(prob(ears.ear_damage - 5))
							to_chat(M, "<span class='warning'>You can't hear anything!</span>")
							M.BecomeDeaf()
					else
						if(ears.ear_damage >= 5)
							to_chat(M, "<span class='warning'>Your ears start to ring!</span>")


/datum/chemical_reaction/phlogiston
	name = "phlogiston"
	id = "phlogiston"
	result = "phlogiston"
	required_reagents = list("phosphorus" = 1, "sacid" = 1, "plasma" = 1)
	result_amount = 3

/datum/chemical_reaction/phlogiston/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	var/turf/simulated/T = get_turf(holder.my_atom)
	for(var/turf/simulated/turf in range(min(created_volume/10,4),T))
		new /obj/effect/hotspot(turf)

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	result = "napalm"
	required_reagents = list("sugar" = 1, "fuel" = 1, "ethanol" = 1 )
	result_amount = 1

/datum/chemical_reaction/cryostylane
	name = "cryostylane"
	id = "cryostylane"
	result = "cryostylane"
	required_reagents = list("water" = 1, "plasma" = 1, "nitrogen" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/pyrosium
	name = "pyrosium"
	id = "pyrosium"
	result = "pyrosium"
	required_reagents = list("plasma" = 1, "radium" = 1, "phosphorus" = 1)
	result_amount = 3

/datum/chemical_reaction/azide
	name = "azide"
	id = "azide"
	result = null
	required_reagents = list("chlorine" = 1, "oxygen" = 1, "nitrogen" = 1, "ammonia" = 1, "sodium" = 1, "silver" = 1)
	result_amount = 1
	mix_message = "The substance violently detonates!"
	mix_sound = 'sound/effects/bang.ogg'

/datum/chemical_reaction/azide/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	explosion(location, 0, 1, 4)

/datum/chemical_reaction/firefighting_foam
	name = "firefighting_foam"
	id = "firefighting_foam"
	result = "firefighting_foam"
	required_reagents = list("carbon" = 1, "chlorine" = 1, "sulfur" = 1)
	result_amount = 3
	mix_message = "The mixture bubbles gently."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/clf3_firefighting
	name = "clf3_firefighting"
	id = "clf3_firefighting"
	result = null
	required_reagents = list("firefighting_foam" = 1, "clf3" = 1)
	result_amount = 1
	mix_message = "The substance violently detonates!"
	mix_sound = 'sound/effects/bang.ogg'

/datum/chemical_reaction/clf3_firefighting/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	explosion(location, -1, 0, 2)

/datum/chemical_reaction/shock_explosion
	name = "shock_explosion"
	id = "shock_explosion"
	result = null
	required_reagents = list("teslium" = 5, "uranium" = 5) //uranium to this so it can't be spammed like no tomorrow without mining help.
	result_amount = 1
	mix_message = "<span class='danger'>The reaction releases an electrical blast!</span>"
	mix_sound = 'sound/magic/lightningbolt.ogg'

/datum/chemical_reaction/shock_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/mob/living/carbon/C in view(min(8, round(created_volume * 2)), T))
		C.Beam(T,icon_state="lightning[rand(1,12)]",icon='icons/effects/effects.dmi',time=5) //What? Why are we beaming from the mob to the turf? Turf to mob generates really odd results.
		C.electrocute_act(3.5, "electrical blast")
	holder.del_reagent("teslium") //Clear all remaining Teslium and Uranium, but leave all other reagents untouched.
	holder.del_reagent("uranium")

/datum/chemical_reaction/thermite
	name = "Thermite"
	id = "thermite"
	result = "thermite"
	required_reagents = list("aluminum" = 1, "iron" = 1, "oxygen" = 1)
	result_amount = 3
