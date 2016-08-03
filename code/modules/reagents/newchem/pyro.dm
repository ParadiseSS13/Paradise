#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

/datum/reagent/stabilizing_agent
	name = "Stabilizing Agent"
	id = "stabilizing_agent"
	description = "A chemical that stabilises normally volatile compounds, preventing them from reacting immediately."
	reagent_state = LIQUID
	color = "#FFFF00"

/datum/chemical_reaction/stabilizing_agent
	name = "stabilizing_agent"
	id = "stabilizing_agent"
	result = "stabilizing_agent"
	required_reagents = list("iron" = 1, "oxygen" = 1, "hydrogen" = 1)
	result_amount = 2
	mix_message = "The mixture becomes a yellow liquid!"

/datum/reagent/clf3
	name = "Chlorine Trifluoride"
	id = "clf3"
	description = "An extremely volatile substance, handle with the utmost care."
	reagent_state = LIQUID
	color = "#FF0000"
	metabolization_rate = 4
	process_flags = ORGANIC | SYNTHETIC

/datum/chemical_reaction/clf3
	name = "Chlorine Trifluoride"
	id = "clf3"
	result = "clf3"
	required_reagents = list("chlorine" = 1, "fluorine" = 3)
	result_amount = 2
	min_temp = 424

/datum/reagent/clf3/on_mob_life(mob/living/M)
	M.adjust_fire_stacks(2)
	var/burndmg = max(0.3*M.fire_stacks, 0.3)
	M.adjustFireLoss(burndmg)
	..()

/datum/chemical_reaction/clf3/on_reaction(datum/reagents/holder, created_volume)
	var/turf/T = get_turf(holder.my_atom)
	for(var/turf/turf in range(1,T))
		new /obj/effect/hotspot(turf)

/datum/reagent/clf3/reaction_turf(turf/simulated/T, volume)
	if(istype(T, /turf/simulated/floor/plating))
		var/turf/simulated/floor/plating/F = T
		if(prob(1))
			F.ChangeTurf(/turf/space)
	if(istype(T, /turf/simulated/floor/))
		var/turf/simulated/floor/F = T
		if(prob(volume/10))
			F.make_plating()
		if(istype(F, /turf/simulated/floor/))
			new /obj/effect/hotspot(F)
	if(istype(T, /turf/simulated/wall/))
		var/turf/simulated/wall/W = T
		if(prob(volume/10))
			W.ChangeTurf(/turf/simulated/floor)
	if(istype(T, /turf/simulated/shuttle/))
		new /obj/effect/hotspot(T)

/datum/reagent/clf3/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		M.adjust_fire_stacks(min(volume/5, 10))
		M.IgniteMob()
		M.bodytemperature += 30

/datum/reagent/sorium
	name = "Sorium"
	id = "sorium"
	description = "Sends everything flying from the detonation point."
	reagent_state = LIQUID
	color = "#FFA500"

/datum/chemical_reaction/sorium
	name = "Sorium"
	id = "sorium"
	result = "sorium"
	required_reagents = list("mercury" = 1, "oxygen" = 1, "nitrogen" = 1, "carbon" = 1)
	result_amount = 4

/datum/chemical_reaction/sorium_vortex
	name = "sorium_vortex"
	id = "sorium_vortex"
	result = null
	required_reagents = list("sorium" = 1)
	min_temp = 474

/datum/chemical_reaction/sorium_vortex/on_reaction(datum/reagents/holder, created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 1, 5, 6)

/datum/chemical_reaction/sorium/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("sorium", created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 1, 5, 6)

/datum/reagent/liquid_dark_matter
	name = "Liquid Dark Matter"
	id = "liquid_dark_matter"
	description = "Sucks everything into the detonation point."
	reagent_state = LIQUID
	color = "#800080"

/datum/chemical_reaction/liquid_dark_matter
	name = "Liquid Dark Matter"
	id = "liquid_dark_matter"
	result = "liquid_dark_matter"
	required_reagents = list("plasma" = 1, "radium" = 1, "carbon" = 1)
	result_amount = 3

/datum/chemical_reaction/ldm_vortex
	name = "LDM Vortex"
	id = "ldm_vortex"
	result = null
	required_reagents = list("liquid_dark_matter" = 1)
	min_temp = 474

/datum/chemical_reaction/ldm_vortex/on_reaction(datum/reagents/holder, created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 0, 5, 6)

/datum/chemical_reaction/liquid_dark_matter/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	holder.remove_reagent("liquid_dark_matter", created_volume)
	var/turf/simulated/T = get_turf(holder.my_atom)
	goonchem_vortex(T, 0, 5, 6)

/proc/goonchem_vortex(turf/simulated/T, setting_type, range, pull_times)
	for(var/atom/movable/X in orange(range, T))
		if(istype(X, /obj/effect))
			continue  //stop pulling smoke and hotspots please
		if(istype(X, /atom/movable))
			if((X) && !X.anchored)
				if(setting_type)
					playsound(T, 'sound/effects/bang.ogg', 25, 1)
					for(var/i = 0, i < pull_times, i++)
						step_away(X,T)
				else
					playsound(T, 'sound/effects/whoosh.ogg', 25, 1) //credit to Robinhood76 of Freesound.org for this.
					for(var/i = 0, i < pull_times, i++)
						step_towards(X,T)

/datum/reagent/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	description = "Explodes. Violently."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.05
	penetrates_skin = 1

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

/datum/reagent/blackpowder/reaction_turf(turf/T, volume) //oh shit
	if(volume >= 5 && !istype(T, /turf/space))
		if(!locate(/obj/effect/decal/cleanable/dirt/blackpowder) in T) //let's not have hundreds of decals of black powder on the same turf
			new /obj/effect/decal/cleanable/dirt/blackpowder(T)

/datum/chemical_reaction/blackpowder_explosion/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	sleep(rand(20,30))
	blackpowder_detonate(holder, created_volume)

/*
/datum/reagent/blackpowder/on_ex_act()
	var/location = get_turf(holder.my_atom)
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	sleep(rand(10,15))
	blackpowder_detonate(holder, volume)
	holder.remove_reagent("blackpowder", volume)
	return */

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

/datum/reagent/flash_powder
	name = "Flash Powder"
	id = "flash_powder"
	description = "Makes a very bright flash."
	reagent_state = LIQUID
	color = "#FFFF00"

/datum/chemical_reaction/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	result = "flash_powder"
	required_reagents = list("aluminum" = 1, "potassium" = 1, "sulfur" = 1, "chlorine" = 1)
	result_amount = 3

/datum/chemical_reaction/flash_powder_flash
	name = "Flash powder activation"
	id = "flash_powder_flash"
	result = null
	required_reagents = list("flash_powder" = 1)
	min_temp = 374

/datum/chemical_reaction/flash_powder_flash/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	for(var/mob/living/carbon/C in viewers(5, location))
		if(C.flash_eyes())
			if(get_dist(C, location) < 4)
				C.Weaken(5)
				continue
			C.Stun(5)


/datum/chemical_reaction/flash_powder/on_reaction(datum/reagents/holder, created_volume)
	if(holder.has_reagent("stabilizing_agent"))
		return
	var/location = get_turf(holder.my_atom)
	var/datum/effect/system/spark_spread/s = new /datum/effect/system/spark_spread
	s.set_up(2, 1, location)
	s.start()
	for(var/mob/living/carbon/C in viewers(5, location))
		if(C.flash_eyes())
			if(get_dist(C, location) < 4)
				C.Weaken(5)
				continue
			C.Stun(5)
	holder.remove_reagent("flash_powder", created_volume)

/datum/reagent/smoke_powder
	name = "Smoke Powder"
	id = "smoke_powder"
	description = "Makes a large cloud of smoke that can carry reagents."
	reagent_state = LIQUID
	color = "#808080"

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
	var/datum/effect/system/chem_smoke_spread/S = new /datum/effect/system/chem_smoke_spread
	S.attach(location)
	playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
	spawn(0)
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

/datum/reagent/sonic_powder
	name = "Sonic Powder"
	id = "sonic_powder"
	description = "Makes a deafening noise."
	reagent_state = LIQUID
	color = "#0000FF"

/datum/chemical_reaction/sonic_powder
	name = "sonic_powder"
	id = "sonic_powder"
	result = "sonic_powder"
	required_reagents = list("oxygen" = 1, "cola" = 1, "phosphorus" = 1)
	result_amount = 3


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
			M.setEarDamage(M.ear_damage + rand(0, 5), max(M.ear_deaf,15))
			if(M.ear_damage >= 15)
				to_chat(M, "<span class='warning'>Your ears start to ring badly!</span>")
				if(prob(M.ear_damage - 10 + 5))
					to_chat(M, "<span class='warning'>You can't hear anything!</span>")
					M.disabilities |= DEAF
			else
				if(M.ear_damage >= 5)
					to_chat(M, "<span class='warning'>Your ears start to ring!</span>")

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
			M.setEarDamage(M.ear_damage + rand(0, 5), max(M.ear_deaf,15))
			if(M.ear_damage >= 15)
				to_chat(M, "<span class='warning'>Your ears start to ring badly!</span>")
				if(prob(M.ear_damage - 10 + 5))
					to_chat(M, "<span class='warning'>You can't hear anything!</span>")
					M.disabilities |= DEAF
			else
				if(M.ear_damage >= 5)
					to_chat(M, "<span class='warning'>Your ears start to ring!</span>")
	holder.remove_reagent("sonic_powder", created_volume)

/datum/reagent/phlogiston
	name = "Phlogiston"
	id = "phlogiston"
	description = "Catches you on fire and makes you ignite."
	reagent_state = LIQUID
	color = "#FF9999"
	process_flags = ORGANIC | SYNTHETIC

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

/datum/reagent/phlogiston/reaction_mob(mob/living/M, method=TOUCH, volume)
	M.IgniteMob()
	..()

/datum/reagent/phlogiston/on_mob_life(mob/living/M)
	M.adjust_fire_stacks(1)
	var/burndmg = max(0.3*M.fire_stacks, 0.3)
	M.adjustFireLoss(burndmg)
	..()

/datum/reagent/napalm
	name = "Napalm"
	id = "napalm"
	description = "Very flammable."
	reagent_state = LIQUID
	color = "#FF9999"
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/napalm/on_mob_life(mob/living/M)
	M.adjust_fire_stacks(1)
	..()

/datum/reagent/napalm/reaction_mob(mob/living/M, method=TOUCH, volume)
	if(method == TOUCH)
		M.adjust_fire_stacks(min(volume/4, 20))

/datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	result = "napalm"
	required_reagents = list("sugar" = 1, "fuel" = 1, "ethanol" = 1 )
	result_amount = 1

/datum/reagent/cryostylane
	name = "Cryostylane"
	id = "cryostylane"
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Cryostylane slowly cools all other reagents in the mob down to 0K."
	color = "#B2B2FF" // rgb: 139, 166, 233
	process_flags = ORGANIC | SYNTHETIC

/datum/chemical_reaction/cryostylane
	name = "cryostylane"
	id = "cryostylane"
	result = "cryostylane"
	required_reagents = list("water" = 1, "plasma" = 1, "nitrogen" = 1)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/cryostylane/on_mob_life(mob/living/M) //TODO: code freezing into an ice cube
	if(M.reagents.has_reagent("oxygen"))
		M.reagents.remove_reagent("oxygen", 1)
		M.bodytemperature -= 30
	..()

/datum/reagent/cryostylane/on_tick()
	if(holder.has_reagent("oxygen"))
		holder.remove_reagent("oxygen", 1)
		holder.chem_temp -= 10
		holder.handle_reactions()
	..()

/datum/reagent/cryostylane/reaction_turf(turf/T, volume)
	if(volume >= 5)
		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(15,30))

/datum/reagent/pyrosium
	name = "Pyrosium"
	id = "pyrosium"
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Pyrosium slowly cools all other reagents in the mob down to 0K."
	color = "#B20000" // rgb: 139, 166, 233
	process_flags = ORGANIC | SYNTHETIC

/datum/chemical_reaction/pyrosium
	name = "pyrosium"
	id = "pyrosium"
	result = "pyrosium"
	required_reagents = list("plasma" = 1, "radium" = 1, "phosphorus" = 1)
	result_amount = 3

/datum/reagent/pyrosium/on_mob_life(mob/living/M)
	if(M.reagents.has_reagent("oxygen"))
		M.reagents.remove_reagent("oxygen", 1)
		M.bodytemperature += 30
	..()

/datum/reagent/pyrosium/on_tick()
	if(holder.has_reagent("oxygen"))
		holder.remove_reagent("oxygen", 1)
		holder.chem_temp += 10
		holder.handle_reactions()
	..()

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

/datum/reagent/firefighting_foam
	name = "Firefighting foam"
	id = "firefighting_foam"
	description = "Carbon Tetrachloride is a foam used for fire suppression."
	reagent_state = LIQUID
	color = "#A0A090"
	var/cooling_temperature = 3 // more effective than water

/datum/chemical_reaction/firefighting_foam
	name = "firefighting_foam"
	id = "firefighting_foam"
	result = "firefighting_foam"
	required_reagents = list("carbon" = 1, "chlorine" = 1, "sulfur" = 1)
	result_amount = 3
	mix_message = "The mixture bubbles gently."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/reagent/firefighting_foam/reaction_mob(mob/living/M, method=TOUCH, volume)
// Put out fire
	if(method == TOUCH)
		M.adjust_fire_stacks(-(volume / 5)) // more effective than water
		M.ExtinguishMob()

/datum/reagent/firefighting_foam/reaction_obj(obj/O, volume)
	if(istype(O))
		O.extinguish()

/datum/reagent/firefighting_foam/reaction_turf(turf/simulated/T, volume)
	if(!istype(T))
		return
	var/CT = cooling_temperature
	new /obj/effect/decal/cleanable/flour/foam(T) //foam mess; clears up quickly.
	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air(T.air.total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-(CT*1000), lowertemp.temperature / CT), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

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
	for(var/mob/living/carbon/C in view(6, T))
		C.Beam(T,icon_state="lightning[rand(1,12)]",icon='icons/effects/effects.dmi',time=5) //What? Why are we beaming from the mob to the turf? Turf to mob generates really odd results.
		C.electrocute_act(3.5, "electrical blast")
	holder.del_reagent("teslium") //Clear all remaining Teslium and Uranium, but leave all other reagents untouched.
	holder.del_reagent("uranium")

/datum/reagent/plasma_dust
	name = "Plasma Dust"
	id = "plasma_dust"
	description = "A fine dust of plasma. This chemical has unusual mutagenic properties for viruses and slimes alike."
	color = "#500064" // rgb: 80, 0, 100

/datum/reagent/plasma_dust/on_mob_life(mob/living/M)
	M.adjustToxLoss(3)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjustPlasma(20)
	..()

/datum/reagent/plasma_dust/reaction_obj(obj/O, volume)
	if((!O) || (!volume))
		return 0
	O.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C, volume)

/datum/reagent/plasma_dust/reaction_turf(turf/simulated/T, volume)
	if(istype(T))
		T.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C, volume)

/datum/reagent/plasma_dust/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with plasma dust is stronger than fuel!
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 5)
		return
	..()