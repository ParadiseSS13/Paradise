/datum/reagent/phlogiston
	name = "phlogiston"
	id = "phlogiston"
	description = "It appears to be liquid fire."
	reagent_state = LIQUID
	color = "#FFAF00"
	process_flags = ORGANIC | SYNTHETIC
	var/temp_fire = 4000
	var/temp_deviance = 1000
	var/size_divisor = 40
	var/mob_burning =  6.6 // 33

/datum/reagent/phlogiston/reaction_turf(turf/T, volume)
	if(holder.chem_temp <= T0C - 50)
		return
	var/radius = min(max(0, volume / size_divisor), 8)
	fireflash_sm(T, radius, rand(temp_fire - temp_deviance, temp_fire + temp_deviance), 500)

/datum/reagent/phlogiston/reaction_mob(mob/living/M, method = TOUCH, volume)
	if(holder.chem_temp <= T0C - 50)
		return
	M.adjust_fire_stacks(mob_burning)
	M.IgniteMob()
	if(method == INGEST)
		M.adjustFireLoss(min(max(10, volume * 2), 45))
		to_chat(M, "<span class='warning'>It burns!</span>")
		M.emote("scream")

/datum/reagent/phlogiston/on_mob_life(mob/living/M)
	if(holder.chem_temp <= T0C - 50)
		return
	M.adjust_fire_stacks(0.4)
	M.IgniteMob()
	return ..()

/datum/reagent/phlogiston/firedust
	name = "phlogiston dust"
	id = "phlogiston_dust"
	description = "And this is solid fire. However that works."
	temp_fire = 1500
	temp_deviance = 500
	size_divisor = 80
	mob_burning = 3 // 15

/datum/reagent/napalm
	name = "napalm"
	id = "napalm"
	description = "A highly flammable jellied fuel."
	reagent_state = LIQUID
	process_flags = ORGANIC | SYNTHETIC
	color = "#C86432"

/datum/reagent/napalm/reaction_temperature(exposed_temperature, exposed_volume)
	if(exposed_temperature > T0C + 100)
		var/radius = min(max(0, volume * 0.15), 8)
		fireflash_sm(get_turf(holder.my_atom), radius, rand(3000, 6000), 500)
		if(holder)
			holder.del_reagent(id)

/datum/reagent/napalm/reaction_turf(turf/T, volume)
	if(isspaceturf(T))
		return
	if(!T.reagents)
		T.create_reagents(volume)
	T.reagents.add_reagent("napalm", volume)

/datum/reagent/napalm/reaction_mob(mob/living/M, method = TOUCH, volume)
	if(method == TOUCH)
		if(M.on_fire)
			M.adjust_fire_stacks(14)
			M.emote("scream")

/datum/reagent/napalm/on_mob_life(mob/living/M)
	if(M.on_fire)
		M.adjust_fire_stacks(2)
	return ..()

/datum/reagent/fuel
	name = "Welding fuel"
	id = "fuel"
	description = "A highly flammable blend of basic hydrocarbons, mostly Acetylene. Useful for both welding and organic chemistry, and can be fortified into a heavier oil."
	reagent_state = LIQUID
	color = "#060606"
	drink_icon = "dr_gibb_glass"
	drink_name = "Glass of welder fuel"
	drink_desc = "Unless you are an industrial tool, this is probably not safe for consumption."
	taste_message = "mistakes"
	process_flags = ORGANIC | SYNTHETIC
	var/max_radius = 7
	var/min_radius = 0
	var/volume_radius_modifier = -0.15
	var/volume_radius_multiplier = 0.09
	var/explosion_threshold = 100
	var/min_explosion_radius = 0
	var/max_explosion_radius = 4
	var/volume_explosion_radius_multiplier = 0.005
	var/volume_explosion_radius_modifier = 0
	var/combustion_temp = T0C + 200

/datum/reagent/fuel/on_mob_life(mob/living/M)
	if(M.on_fire)
		M.adjust_fire_stacks(0.4)
	return ..()

/datum/reagent/fuel/reaction_temperature(exposed_temperature, exposed_volume)
	if(exposed_temperature > combustion_temp)
		if(volume < 1)
			if(holder)
				holder.del_reagent(id)
			return
		var/turf/T = get_turf(holder.my_atom)
		var/radius = min(max(min_radius, volume * volume_radius_multiplier + volume_radius_modifier), max_radius)
		fireflash_sm(T, radius, 2200 + radius * 250, radius * 50)
		if(holder && volume >= explosion_threshold)
			if(holder.my_atom)
				holder.my_atom.visible_message("<span class='danger'>[holder.my_atom] explodes!</span>")
				message_admins("Fuel explosion ([holder.my_atom], reagent type: [id]) at [COORD(holder.my_atom.loc)]. Last touched by: [holder.my_atom.fingerprintslast ? "[holder.my_atom.fingerprintslast]" : "*null*"].")
				log_game("Fuel explosion ([holder.my_atom], reagent type: [id]) at [COORD(holder.my_atom.loc)]. Last touched by: [holder.my_atom.fingerprintslast ? "[holder.my_atom.fingerprintslast]" : "*null*"].")
				holder.my_atom.investigate_log("A fuel explosion, last touched by [holder.my_atom.fingerprintslast ? "[holder.my_atom.fingerprintslast]" : "*null*"], triggered at [COORD(holder.my_atom.loc)].", INVESTIGATE_BOMB)
			var/boomrange = min(max(min_explosion_radius, round(volume * volume_explosion_radius_multiplier + volume_explosion_radius_modifier)), max_explosion_radius)
			explosion(T, -1, -1, boomrange, 1)
		if(holder)
			holder.del_reagent(id)

/datum/reagent/fuel/reaction_turf(turf/T, volume) //Don't spill the fuel, or you'll regret it
	if(isspaceturf(T))
		return
	if(!T.reagents)
		T.create_reagents(50)
	T.reagents.add_reagent("fuel", volume)

/datum/reagent/fuel/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with welding fuel to make them easy to ignite!
	if(method == TOUCH)
		if(M.on_fire)
			M.adjust_fire_stacks(6)

/datum/reagent/plasma
	name = "Plasma"
	id = "plasma"
	description = "The liquid phase of an unusual extraterrestrial compound."
	reagent_state = LIQUID
	color = "#7A2B94"
	taste_message = "corporate assets going to waste"

/datum/reagent/plasma/reaction_temperature(exposed_temperature, exposed_volume)
	if(exposed_temperature >= T0C + 100)
		fireflash(get_turf(holder.my_atom), min(max(0, volume / 10), 8))
		if(holder)
			holder.del_reagent(id)

/datum/reagent/plasma/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	if(holder.has_reagent("epinephrine"))
		holder.remove_reagent("epinephrine", 2)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjustPlasma(10)
	return ..() | update_flags

/datum/reagent/plasma/reaction_mob(mob/living/M, method = TOUCH, volume)//Splashing people with plasma is stronger than fuel!
	if(method == TOUCH)
		if(M.on_fire)
			M.adjust_fire_stacks(6)


/datum/reagent/thermite
	name = "Thermite"
	id = "thermite"
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16
	process_flags = ORGANIC | SYNTHETIC
	taste_message = "rust"

/datum/reagent/thermite/reaction_mob(mob/living/M, method= TOUCH, volume)
	if(method == TOUCH)
		if(M.on_fire)
			M.adjust_fire_stacks(20)

/datum/reagent/thermite/reaction_temperature(exposed_temperature, exposed_volume)
	var/turf/simulated/S = holder.my_atom
	if(!istype(S))
		return

	if(exposed_temperature >= T0C + 100)
		var/datum/reagents/Holder = holder
		var/Id = id
		var/Volume = volume
		Holder.del_reagent(Id)
		fireflash_sm(S, 0, rand(20000, 25000) + Volume * 2500, 0, 0, 1)

/datum/reagent/thermite/reaction_turf(turf/simulated/S, volume)
	if(istype(S))
		if(!S.reagents)
			S.create_reagents(volume)
		S.reagents.add_reagent("thermite", volume)
		S.overlays.Cut()
		S.overlays = image('icons/effects/effects.dmi', icon_state = "thermite")
		if(S.active_hotspot)
			S.reagents.temperature_reagents(S.active_hotspot.temperature, 10, 300)

/datum/reagent/glycerol
	name = "Glycerol"
	id = "glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	reagent_state = LIQUID
	color = "#808080" // rgb: 128, 128, 128
	taste_message = "sweetness"

/datum/reagent/stabilizing_agent
	name = "Stabilizing Agent"
	id = "stabilizing_agent"
	description = "A chemical that stabilises normally volatile compounds, preventing them from reacting immediately."
	reagent_state = LIQUID
	color = "#FFFF00"
	taste_message = "long-term stability"

/datum/reagent/clf3
	name = "Chlorine Trifluoride"
	id = "clf3"
	description = "An extremely volatile substance, handle with the utmost care."
	reagent_state = LIQUID
	color = "#FF0000"
	metabolization_rate = 4
	process_flags = ORGANIC | SYNTHETIC
	taste_message = null

/datum/reagent/clf3/on_mob_life(mob/living/M)
	if(M.on_fire)
		M.adjust_fire_stacks(1)
	return ..()

/datum/reagent/clf3/reaction_turf(turf/T, volume)
	if(volume < 3)
		return
	var/radius = min((volume - 3) * 0.15, 3)
	fireflash_sm(T, radius, 4500 + volume * 500, 350)

/datum/reagent/clf3/reaction_mob(mob/living/M, method = TOUCH, volume)
	if(method == TOUCH || method == INGEST)
		M.adjust_fire_stacks(10)
		M.IgniteMob()
	if(method == INGEST)
		M.adjustFireLoss(min(max(15, volume * 2.5), 90))
		to_chat(M, "<span class='warning'>It burns!</span>")
		M.emote("scream")

/datum/reagent/sorium
	name = "Sorium"
	id = "sorium"
	description = "Sends everything flying from the detonation point."
	reagent_state = LIQUID
	color = "#FFA500"

/datum/reagent/sorium/reaction_turf(turf/T, volume) // oh no
	if(prob(75))
		return
	if(isspaceturf(T))
		return
	if(!T.reagents)
		T.create_reagents(50)
	T.reagents.add_reagent("sorium", 5)

/datum/reagent/liquid_dark_matter
	name = "Liquid Dark Matter"
	id = "liquid_dark_matter"
	description = "Sucks everything into the detonation point."
	reagent_state = LIQUID
	color = "#800080"
	taste_message = "the end of the world"

/datum/reagent/liquid_dark_matter/reaction_turf(turf/T, volume) //Oh gosh, why
	if(prob(75))
		return
	if(isspaceturf(T))
		return
	if(!T.reagents)
		T.create_reagents(50)
	T.reagents.add_reagent("liquid_dark_matter", 5)

/datum/reagent/blackpowder
	name = "Black Powder"
	id = "blackpowder"
	description = "Explodes. Violently."
	reagent_state = LIQUID
	color = "#000000"
	metabolization_rate = 0.05
	penetrates_skin = TRUE
	taste_message = "explosions"

/datum/reagent/blackpowder/reaction_turf(turf/T, volume) //oh shit
	if(volume >= 5 && !isspaceturf(T))
		if(!locate(/obj/effect/decal/cleanable/dirt/blackpowder) in T) //let's not have hundreds of decals of black powder on the same turf
			new /obj/effect/decal/cleanable/dirt/blackpowder(T)

/datum/reagent/flash_powder
	name = "Flash Powder"
	id = "flash_powder"
	description = "Makes a very bright flash."
	reagent_state = LIQUID
	color = "#FFFF00"
	penetrates_skin = TRUE

/datum/reagent/smoke_powder
	name = "Smoke Powder"
	id = "smoke_powder"
	description = "Makes a large cloud of smoke that can carry reagents."
	reagent_state = LIQUID
	color = "#808080"

/datum/reagent/sonic_powder
	name = "Sonic Powder"
	id = "sonic_powder"
	description = "Makes a deafening noise."
	reagent_state = LIQUID
	color = "#0000FF"
	penetrates_skin = TRUE

/datum/reagent/cryostylane
	name = "Cryostylane"
	id = "cryostylane"
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Cryostylane slowly cools all other reagents in the mob down to 0K."
	color = "#B2B2FF" // rgb: 139, 166, 233
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/cryostylane/on_mob_life(mob/living/M) //TODO: code freezing into an ice cube
	if(M.reagents.has_reagent("oxygen"))
		M.reagents.remove_reagent("oxygen", 1)
		M.bodytemperature -= 30
	return ..()

/datum/reagent/cryostylane/on_tick()
	if(holder.has_reagent("oxygen"))
		holder.remove_reagent("oxygen", 2)
		holder.remove_reagent("cryostylane", 2)
		holder.temperature_reagents(holder.chem_temp - 200)
		holder.temperature_reagents(holder.chem_temp - 200)
	..()

/datum/reagent/cryostylane/reaction_mob(mob/living/M, method = TOUCH, volume)
	if(method == TOUCH)
		M.ExtinguishMob()

/datum/reagent/cryostylane/reaction_turf(turf/T, volume)
	if(volume >= 5)
		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(15,30))

/datum/reagent/pyrosium
	name = "Pyrosium"
	id = "pyrosium"
	description = "Comes into existence at 20K. As long as there is sufficient oxygen for it to react with, Pyrosium slowly heats all other reagents."
	color = "#B20000" // rgb: 139, 166, 233
	process_flags = ORGANIC | SYNTHETIC

/datum/reagent/pyrosium/on_mob_life(mob/living/M)
	if(M.reagents.has_reagent("oxygen"))
		M.reagents.remove_reagent("oxygen", 1)
		M.bodytemperature += 30
	return ..()

/datum/reagent/pyrosium/on_tick()
	if(holder.has_reagent("oxygen"))
		holder.remove_reagent("oxygen", 2)
		holder.remove_reagent("pyrosium", 2)
		holder.temperature_reagents(holder.chem_temp + 200)
		holder.temperature_reagents(holder.chem_temp + 200)
	..()

/datum/reagent/firefighting_foam
	name = "Firefighting foam"
	id = "firefighting_foam"
	description = "Carbon Tetrachloride is a foam used for fire suppression."
	reagent_state = LIQUID
	color = "#A0A090"
	var/cooling_temperature = 3 // more effective than water

/datum/reagent/firefighting_foam/reaction_mob(mob/living/M, method=TOUCH, volume)
// Put out fire
	if(method == TOUCH)
		M.adjust_fire_stacks(-10) // more effective than water

/datum/reagent/firefighting_foam/reaction_obj(obj/O, volume)
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

/datum/reagent/plasma_dust
	name = "Plasma Dust"
	id = "plasma_dust"
	description = "A fine dust of plasma. This chemical has unusual mutagenic properties for viruses and slimes alike."
	color = "#500064" // rgb: 80, 0, 100
	taste_message = "corporate assets going to waste"

/datum/reagent/plasma_dust/reaction_temperature(exposed_temperature, exposed_volume)
	if(exposed_temperature >= T0C + 100)
		fireflash(get_turf(holder.my_atom), min(max(0, volume / 10), 8))
		if(holder)
			holder.del_reagent(id)

/datum/reagent/plasma_dust/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(3, FALSE)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjustPlasma(20)
	return ..() | update_flags

/datum/reagent/plasma_dust/reaction_mob(mob/living/M, method=TOUCH, volume)//Splashing people with plasma dust is stronger than fuel!
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 5)
		return
	..()
