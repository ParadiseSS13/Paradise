/obj/item/nuclear_rod
	name = "Nuclear Control Rod"
	desc = "You shouldnt be seeing this. Contact a developer"
	icon = 'icons/obj/fission/rods.dmi'
	icon_state = "irradiated"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	force = 15
	throwforce = 10
	/// The path of the object required to fabricate this rod. leave null for nothing
	var/required_object
	/// How much durability is left before the rod is useless
	var/durability
	/// The maximum amount of durability for this rod. Used for percentage calculations
	var/max_durability = 3000
	/// How fast does this rod degrade? higher = faster
	var/degredation_speed = 1
	/// How much heat does this rod add by default
	var/heat_amount = 0
	/// How does this rod affect its neighbors heating
	var/heat_amp_mod = 1
	/// Holds the current heat mod after durability loss
	var/current_heat_mod
	/// How much power does this rod add by default in watts
	var/power_amount = 0
	/// How does this rod affect its neighbors power production
	var/power_amp_mod = 1
	/// Holds the current power mod after durability loss
	var/current_power_mod
	/// How much Alpha Rad is emitted by this rod
	var/alpha_rad = 0
	/// How much Beta Rad is emitted by this rod
	var/beta_rad = 0
	/// How much Gamma Rad is emitted by this rod
	var/gamma_rad = 0
	/// What items need to be adjacent to this rod for it to function properly
	var/list/adjacent_requirements = list()
	/// Modifies the reactor's minimum operating temperature.
	var/minimum_temp_modifier = 0
	/// holds our component to modify
	var/datum/component/inherent_radioactivity/rad_component


/obj/item/nuclear_rod/Initialize(mapload)
	. = ..()
	durability = max_durability

/obj/item/nuclear_rod/examine(mob/user)
	. = ..()
	if(length(adjacent_requirements))
		var/list/templist = list()
		for(var/obj/item/nuclear_rod/requirement as anything in adjacent_requirements)
			templist += requirement::name
		var/requirement_list = english_list(templist, and_text = ", ")
		. += "This rod has the following neighbor requirements: [requirement_list]"
	else
		. += "This rod has no neighbor requirements."

/obj/item/nuclear_rod/proc/get_durability_mod()
	var/temp_mod
	temp_mod = clamp(1.5 * (durability / max_durability) - 0.25, 0.25, 1)
	return temp_mod

/obj/item/nuclear_rod/proc/calc_stat_decrease()
	// Formula: y =stat (x * A) + (1 - A)
	var/durability_stat = get_durability_mod()
	current_power_mod = (power_amp_mod * durability_stat) + (1 - durability_stat)
	current_heat_mod = (heat_amp_mod * durability_stat) + (1 - durability_stat)

/obj/item/nuclear_rod/proc/start_rads(power_modifier = 1)
	var/new_alpha_rad = alpha_rad * power_modifier
	var/new_beta_rad = beta_rad * power_modifier
	var/new_gamma_rad = gamma_rad * power_modifier
	rad_component = AddComponent(/datum/component/inherent_radioactivity, new_alpha_rad, new_beta_rad, new_gamma_rad, 1)
	START_PROCESSING(SSradiation, rad_component)

/obj/item/nuclear_rod/proc/stop_rads()
	if(!rad_component)
		return
	rad_component.RemoveComponent()
	QDEL_NULL(rad_component)

/obj/item/nuclear_rod/proc/change_rad_intensity(power_modifier = 1)
	rad_component.radioactivity_alpha = alpha_rad * power_modifier
	rad_component.radioactivity_beta = beta_rad * power_modifier
	rad_component.radioactivity_gamma = gamma_rad * power_modifier

/obj/item/nuclear_rod/proc/check_rad_shield()
	var/turf/T = get_turf(src)
	if(istype(T, /turf/simulated/floor/plasteel/reactor_pool))
		if(!rad_component)
			return
		else
			stop_rads()
	else if(istype(loc, /obj/machinery/atmospherics/reactor_chamber))
		stop_rads()
	else if(!rad_component)
		start_rads()

/obj/item/nuclear_rod/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	check_rad_shield()

/obj/item/nuclear_rod/fuel
	name = "any fuel rod"
	desc = "This is a base item and should not be found. Alert a developer!"
	alpha_rad = 50

	/// the amount of cycles needed to complete enrichment. 30 = ~1 minute
	var/enrichment_cycles = 25
	/// the total power amp mod needed to enrich
	var/power_enrich_threshold = 0
	/// How far we have progressed from to power enrichment
	var/power_enrich_progress = 0
	/// What power enrichment results in
	var/power_enrich_result
	/// the total heat amp mod needed to enrich
	var/heat_enrich_threshold = 0
	/// How far we have progressed from to power enrichment
	var/heat_enrich_progress = 0
	/// What heat enrichment results in
	var/heat_enrich_result
	var/craftable = FALSE

/obj/item/nuclear_rod/fuel/Initialize(mapload)
	. = ..()
	if(!(istype(loc, /obj/structure/closet/crate/engineering)))
		check_rad_shield()

/obj/item/nuclear_rod/fuel/proc/enrich(power_mod, heat_mod)
	var/successful_enrichment = FALSE
	if(power_enrich_result)
		if(power_mod > power_enrich_threshold && power_enrich_progress < enrichment_cycles)
			power_enrich_progress++
			successful_enrichment = TRUE
	if(heat_enrich_result)
		if(heat_mod > heat_enrich_threshold && heat_enrich_progress < enrichment_cycles)
			heat_enrich_progress++
			successful_enrichment = TRUE
	return successful_enrichment

/// MARK: Fuel Rods

/obj/item/nuclear_rod/fuel/uranium_238
	name = "uranium 238 fuel rod"
	desc = "A standard fuel rod for most NGCR reactors. Has just barely enough Uranium 235 to be useful."
	heat_amount = 5
	power_amount = 20 KW
	heat_amp_mod = 1.8
	power_amp_mod = 1.1
	alpha_rad = 200
	beta_rad = 100
	heat_enrich_threshold = 10 // all uranium rods surrounding: 1.8 x 1.8 x 1.8 x 1.8
	power_enrich_threshold = 6.5 // all graphite rods surrounding: 1.6 x 1.6 x 1.6 x 1.6
	heat_enrich_result = /obj/item/nuclear_rod/fuel/weak_thorium
	power_enrich_result = /obj/item/nuclear_rod/fuel/weak_plutonium
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	materials = list(MAT_METAL = 2000, MAT_URANIUM = 1000)
	craftable = TRUE

/obj/item/nuclear_rod/fuel/weak_thorium
	name = "weak thorium fuel rod"
	desc = "A specialized fuel rod bred from uranium 238. This rod will last longer than normal, and wont generate as much heat."
	heat_amount = 5
	power_amount = 20 KW
	heat_amp_mod = 1.6
	power_amp_mod = 1.1
	durability = 5000
	beta_rad = 100
	gamma_rad = 100
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/coolant,
		)

/obj/item/nuclear_rod/fuel/weak_plutonium
	name = "weak plutonium fuel rod"
	desc = "A specialized fuel rod bred from uranium 238. This rod produces twice as much power as standard urnaium 238 fuel, but has higher operating requirements."
	heat_amount = 10
	power_amount = 40 KW
	heat_amp_mod = 1.6
	power_amp_mod = 1.1
	max_durability = 3500
	gamma_rad = 100
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/coolant,
		)

/obj/item/nuclear_rod/fuel/uranium_235
	name = "uranium 235 fuel rod"
	desc = "An advanced fuel rod for most NGCR reactors, formed from high-density ueanium 235 isotopes."
	heat_amount = 20
	power_amount = 50 KW
	heat_amp_mod = 2.2
	power_amp_mod = 1.3
	max_durability = 5000
	alpha_rad = 150
	beta_rad = 100
	heat_enrich_threshold = 16
	power_enrich_threshold = 10
	heat_enrich_result = /obj/item/nuclear_rod/fuel/thorium_salts
	power_enrich_result = /obj/item/nuclear_rod/fuel/enriched_plutonium
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/plasma_injector,
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/moderator,
		)
	materials = list(MAT_METAL = 4000, MAT_URANIUM = 4000)
	craftable = TRUE

/obj/item/nuclear_rod/fuel/thorium_salts
	name = "thorium salts fuel rod"
	desc = "A specialized fuel rod bred from uranium 235. While this rod doesnt have any notable power boosts, its amazingly large integrity makes it vitually impossible to deplete in a single shift if one can manage its heat."
	heat_amount = 40
	power_amount = 35 KW
	heat_amp_mod = 2.2
	power_amp_mod = 1.3
	max_durability = 15000
	beta_rad = 250
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/fuel/uranium_235,
		/obj/item/nuclear_rod/fuel,
		)

/obj/item/nuclear_rod/fuel/enriched_plutonium
	name = "enriched plutonium fuel rod"
	desc = "A specialized fuel rod bred from uranium 235. This rod is extremely powerful, boasting high  power outputs and moderate durability. However, its heat presents an exceptional danger."
	heat_amount = 60
	power_amount = 75 KW
	heat_amp_mod = 4
	power_amp_mod = 1.6
	max_durability = 5000
	beta_rad = 250
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator/plasma_agitator,
		/obj/item/nuclear_rod/fuel/thorium_salts,
		)

/obj/item/nuclear_rod/fuel/supermatter
	name = "supermatter fuel rod"
	desc = "A fuel rod made entirely of supermatter, contained safely in a specialized housing case. Due to its unusual properties, it completely neutralizes any potential power from nearby rods."
	heat_amount = 800
	power_amount = 800 KW
	heat_amp_mod = 8
	power_amp_mod = 0.1
	max_durability = INFINITY
	gamma_rad = 300
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/steam_hammerjet,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/moderator,
		)

/obj/item/nuclear_rod/fuel/americium
	name = "americium fuel rod"
	desc = "A specialized fuel rod bred from enriched plutonium. A pinnacle of power generation, this rod's power generation is nearly unmatched if one can tame its viscious heat output."
	heat_amount = 100
	power_amount = 200 KW
	heat_amp_mod = 6
	power_amp_mod = 1.6
	max_durability = 4000
	gamma_rad = 300
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		)

/obj/item/nuclear_rod/fuel/bananium
	name = "bananium fuel rod"
	desc = "The funniest of all fuel rods. Who knows what you might get out of it!"
	gamma_rad = 300

/obj/item/nuclear_rod/fuel/bananium/Initialize(mapload)
	max_durability = rand(1000, 10000)
	power_amp_mod = rand(1, 30) / 10
	heat_amp_mod = rand(1, 80) / 10
	power_amount = rand(10 KW, 100 KW)
	heat_amount = rand(10, 200)
	return ..()

/obj/item/nuclear_rod/fuel/meltdown
	name = "meltdown rod"
	desc = "A syndicate crafted rod capable of generating massive amounts of heat, and leading to an eventual meltdown."
	heat_amount = 2000
	max_durability = INFINITY
	minimum_temp_modifier = 4000 // BIG hot
	alpha_rad = 250
	beta_rad = 250
	gamma_rad = 250
	craftable = FALSE

/// MARK: Moderator Rods

/obj/item/nuclear_rod/moderator
	name = "any moderator rod"
	desc = "This is a base item and should not be found. Alert a developer!"
	icon_state = "normal"
	var/craftable = FALSE

/obj/item/nuclear_rod/moderator/heavy_water
	name = "heavy water moderator"
	desc = "A basic moderation rod filled with a varint of water comprised of deuterium instead of hydrogen atoms."
	heat_amp_mod = 1.1
	power_amp_mod = 1.4
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	craftable = TRUE

/obj/item/nuclear_rod/moderator/graphite
	name = "graphite moderator"
	desc = "A nuclear moderation rod comprised of primarily of layered graphite. A staple of fission reactor operation through the ages."
	heat_amp_mod = 1.3
	power_amp_mod = 1.6
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 2000)
	adjacent_requirements = list(/obj/item/nuclear_rod/coolant)
	craftable = TRUE

/obj/item/nuclear_rod/moderator/titanium
	name = "titanium moderator"
	desc = "A nuclear moderation rod comprised of primarily of cast titanium. For what it makes up in power amplification, it make up in versatility and durability."
	max_durability = 5000
	heat_amp_mod = 1.1
	power_amp_mod = 1.3
	materials = list(MAT_METAL = 2000, MAT_TITANIUM = 2000)
	craftable = TRUE

/obj/item/nuclear_rod/moderator/plasma_agitator
	name = "plasma agitator"
	desc = "A specialized moderator rod capable of inducing higher fissionr rates in fuel rods through a series of micro-burns. It doesnt last long"
	max_durability = 2500
	heat_amount = 20
	heat_amp_mod = 5
	power_amp_mod = 3
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/moderator,
		)

/obj/item/nuclear_rod/moderator/aluminum_reflector
	name = "liquid aluminum plate reflector"
	desc = "A specialized moderator rod for amplifying the power output of nearby fuel rods. However, the temperature of the liquid aluminum will force the reactor to run hot."
	max_durability = 6000
	power_amount = -15
	heat_amp_mod = 5
	power_amp_mod = 3
	minimum_temp_modifier = 400
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/nitrogen_circulator,
		/obj/item/nuclear_rod/moderator,
		)

/obj/item/nuclear_rod/moderator/bluespace_agitator
	name = "bluespace crystal agitator"
	desc = "An advanced moderator rod that will pull extra neutrons out of bluespace to bombard local fuel rods. The result is a massive increase of power and heat generation. It is exceptionally versatile, however its power requirements limit its uses."
	max_durability = 4000
	power_amount = -30
	heat_amp_mod = 12
	power_amp_mod = 5
	materials = list(MAT_METAL = 2000, MAT_TITANIUM = 1000, MAT_BLUESPACE = 1000)
	craftable = TRUE

/obj/item/nuclear_rod/moderator/diamond_plate
	name = "diamond reflector plates"
	desc = "An advanced moderator rod that can reflect nearly all neutrons back to their point of origin. Simple, stable, reliable."
	max_durability = 6000
	heat_amp_mod = 6
	power_amp_mod = 3.3
	materials = list(MAT_METAL = 2000, MAT_TITANIUM = 1000, MAT_DIAMOND = 1000)
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		)
	craftable = TRUE

/obj/item/nuclear_rod/moderator/platinum_plating
	name = "platinum reflector plating"
	desc = "An advanced moderator similar to diamond plates, but improved with precious space metals."
	max_durability = 8000
	heat_amp_mod = 8
	power_amp_mod = 3.9
	adjacent_requirements = list(/obj/item/nuclear_rod/fuel/americium)

/// MARK: Coolant Rods

/obj/item/nuclear_rod/coolant
	name = "any coolant rod"
	desc = "This is a base item and should not be found. Alert a developer!"
	icon_state = "bananium"
	var/craftable = FALSE


/obj/item/nuclear_rod/coolant/light_water
	name = "light water circulator"
	desc = "A basic coolant rod that circulates distilled water through critical reactor components."
	heat_amount = -10
	power_amount = -10 KW
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	craftable = TRUE

/obj/item/nuclear_rod/coolant/co2_regulator
	name = "carbon dioxide regulator"
	desc = "A specialized coolant rod filled with carbon dioxide gas, capable of regulating temperature spikes in fuel rods. However, its very energy inefficient."
	heat_amount = -4
	heat_amp_mod = 0.6
	power_amount = -15 KW
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)
	craftable = TRUE

/obj/item/nuclear_rod/coolant/plasma_injector
	name = "plasma injector"
	desc = "A specialized coolant rod filled with gaseous plasma. By feeding taking advantage of plasma's unique heat absorband properties, injecting it in small amounts around fuel rods neutralizes excess heat. However, the tank runs out quickly this way."
	heat_amp_mod = 0.3
	power_amp_mod = 1.2
	adjacent_requirements = list(/obj/item/nuclear_rod/coolant)
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)
	craftable = TRUE

/obj/item/nuclear_rod/coolant/nitrogen_circulator
	name = "nitrogen circulator"
	desc = "A specialized coolant rod filled with nitrogen gas. While not as powerful as similar alternatives, this rod is exceptionally stable and will last longer."
	heat_amount = -10
	power_amp_mod = 0.9
	heat_amp_mod = 0.7
	power_amount = -5 KW
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)
	craftable = TRUE

/obj/item/nuclear_rod/coolant/molten_salt
	name = "molten salt circulator"
	desc = "A specialized coolant rod that circulates molten salts through the core of the reactor. Despite forcing the reactor to run exceptionally hot, this rod provides top-notch cooling potential above its resting temperature."
	power_amount = -20 KW
	heat_amount = -60
	heat_amp_mod = 0.8
	max_durability = 8000
	minimum_temp_modifier = 750
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/nitrogen_circulator,
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		)
	craftable = TRUE

/obj/item/nuclear_rod/coolant/steam_hammerjet
	name = "steam hammerjet"
	desc = "A specialized coolant rod that injects distilled steam throughout the reactor's critical components. Although it makes the reactor run warm, its very good at suppressing heat buildup"
	power_amount = -10 KW
	heat_amount = -40
	heat_amp_mod = 0.4
	max_durability = 6000
	minimum_temp_modifier = 450
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/light_water,
		/obj/item/nuclear_rod/coolant/light_water,
		)

/obj/item/nuclear_rod/coolant/bluespace_displacer
	name = "bluespace heat displacer"
	desc = "An advanced coolant rod capable of pulling heat directly out of neighboring rods and sending it... somewhere"
	power_amount = -40 KW
	heat_amount = -100
	heat_amp_mod = 0.8
	power_amp_mod = 1.3
	max_durability = INFINITY
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_BLUESPACE = 1000)
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator/bluespace_agitator)
	craftable = TRUE

/obj/item/nuclear_rod/coolant/iridium_conductor
	name = "iridium conductor coolant rod"
	desc = "A dazzlingly beautiful rod with exceptionally powerful thermal conductivity. A highly sought after piece of equipment for its simplicity and potency."
	heat_amp_mod = 0.1
	max_durability = 10000
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator/aluminum_reflector,
		/obj/item/nuclear_rod/fuel/uranium_235,
		)

/obj/item/nuclear_rod/coolant/condensed_spacematter
	name = "condensed spacematter coolant rod"
	desc = "While its unknown quite what the rod is filled with, theres no questioning its efficiency in the amount of heat its capable of suppressing. However, it violently dissentigrates in contact with anything that isnt its housing."
	heat_amp_mod = 0.2
	max_durability = 2500
	materials = list(MAT_METAL = 6000, MAT_PLASMA = 4000, MAT_TITANIUM = 2000)
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel/enriched_plutonium,
		/obj/item/nuclear_rod/fuel/thorium_salts,
		)
	craftable = TRUE
