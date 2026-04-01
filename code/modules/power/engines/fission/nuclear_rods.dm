/obj/item/nuclear_rod
	name = "Nuclear Control Rod"
	desc = ABSTRACT_TYPE_DESC
	icon = 'icons/obj/fission/reactor_rods.dmi'
	icon_state = "fuel_238"
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
	var/degradation_speed = 1
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
	/// Modified the reactor's overheat threshold
	var/reactor_overheat_modifier = 0
	/// holds our component to modify
	var/datum/component/inherent_radioactivity/rad_component
	/// Is this rod craftable at all via fabricators, or do they require other means?
	var/craftable = FALSE
	/// Does this rod require a science-upgraded fabricator?
	var/upgrade_required = FALSE

/obj/item/nuclear_rod/Initialize(mapload)
	. = ..()
	durability = max_durability

/obj/item/nuclear_rod/examine(mob/user)
	. = ..()
	if(length(adjacent_requirements))
		var/list/templist = list()
		for(var/obj/item/nuclear_rod/requirement as anything in adjacent_requirements)
			templist += initial(requirement.name)
		var/requirement_list = english_list(templist, and_text = ", ")
		. += "This rod has the following neighbor requirements: [requirement_list]"
	else
		. += "This rod has no neighbor requirements."

/obj/item/nuclear_rod/proc/get_durability_mod()
	var/temp_mod
	temp_mod = clamp(1.5 * (durability / max_durability) - 0.25, 0.25, 1)
	return temp_mod

/obj/item/nuclear_rod/proc/calc_stat_decrease()
	// Formula: y = (x * A) + (1 - A)
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
	if(!T || !loc)
		stop_rads()
		return
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

/obj/item/nuclear_rod/fuel/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/structure/closet/crate))
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

// MARK: Fuel Rods

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
	power_enrich_threshold = 6.4 // all graphite rods surrounding: 1.6 x 1.6 x 1.6 x 1.6
	heat_enrich_result = /obj/item/nuclear_rod/fuel/weak_thorium
	power_enrich_result = /obj/item/nuclear_rod/fuel/weak_plutonium
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	craftable = TRUE
	materials = list(MAT_METAL = 2000, MAT_URANIUM = 1000)

/obj/item/nuclear_rod/fuel/weak_thorium
	name = "weak thorium fuel rod"
	desc = "A specialized fuel rod refined from uranium 238. This rod will last longer than normal, and won't generate as much heat."
	icon_state = "fuel_weakthor"
	heat_amount = 5
	power_amount = 20 KW
	heat_amp_mod = 1.6
	power_amp_mod = 1.1
	max_durability = 5000
	beta_rad = 100
	gamma_rad = 100
	power_enrich_threshold = 8
	power_enrich_result = /obj/item/nuclear_rod/fuel/uranium_235
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/coolant,
	)

/obj/item/nuclear_rod/fuel/weak_plutonium
	name = "weak plutonium fuel rod"
	desc = "A specialized fuel rod refined from uranium 238. This rod produces twice as much power as standard uranium 238 fuel, but has higher operating requirements."
	icon_state = "fuel_weakplut"
	heat_amount = 10
	power_amount = 40 KW
	heat_amp_mod = 1.6
	power_amp_mod = 1.1
	max_durability = 3500
	gamma_rad = 100
	heat_enrich_threshold = 14
	heat_enrich_result = /obj/item/nuclear_rod/fuel/uranium_235
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/coolant,
	)

/obj/item/nuclear_rod/fuel/uranium_235
	name = "uranium 235 fuel rod"
	desc = "An advanced fuel rod for most NGCR reactors, formed from high-density uranium 235 isotopes."
	icon_state = "fuel_235"
	heat_amount = 20
	power_amount = 50 KW
	heat_amp_mod = 2.2
	power_amp_mod = 1.3
	max_durability = 5000
	alpha_rad = 150
	beta_rad = 100
	heat_enrich_threshold = 25
	power_enrich_threshold = 18
	heat_enrich_result = /obj/item/nuclear_rod/fuel/thorium_salts
	power_enrich_result = /obj/item/nuclear_rod/fuel/enriched_plutonium
	origin_tech = "toxins=2"
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/plasma_injector,
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/moderator,
	)
	materials = list(MAT_METAL = 4000, MAT_URANIUM = 4000)

/obj/item/nuclear_rod/fuel/thorium_salts
	name = "thorium salts fuel rod"
	desc = "A specialized fuel rod refined from uranium 235. While this rod doesn't have any notable power boosts, its amazingly large integrity makes it virtually impossible to deplete in a single shift, if one can manage its heat."
	icon_state = "fuel_richthor"
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
	desc = "A specialized fuel rod refined from uranium 235. This rod is extremely powerful, boasting high power outputs and moderate durability. However, its heat presents an exceptional danger."
	icon_state = "fuel_richplut"
	heat_amount = 60
	power_amount = 75 KW
	heat_amp_mod = 4
	power_amp_mod = 1.6
	max_durability = 5000
	beta_rad = 250
	power_enrich_threshold = 25
	power_enrich_result = /obj/item/nuclear_rod/fuel/americium
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator/plasma_agitator,
		/obj/item/nuclear_rod/fuel/thorium_salts,
	)

/obj/item/nuclear_rod/fuel/supermatter
	name = "supermatter fuel rod"
	desc = "A dangerous fuel rod made entirely of supermatter, contained safely in a specialized housing case. Due to its unusual properties, it completely neutralizes any potential power from nearby rods."
	icon_state = "fuel_sm"
	heat_amount = 1200
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
	desc = "A specialized fuel rod refined from enriched plutonium. A pinnacle of power generation, this rod's power generation is nearly unmatched if one can tame its vicious heat output."
	icon_state = "fuel_americium"
	heat_amount = 100
	power_amount = 200 KW
	heat_amp_mod = 6
	power_amp_mod = 3
	max_durability = 4000
	gamma_rad = 300
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/fuel/bananium
	name = "bananium fuel rod"
	desc = "The funniest of all fuel rods with no solidified properties. Who knows what you might get out of it!"
	icon_state = "fuel_clown"
	gamma_rad = 300
	craftable = TRUE
	upgrade_required = TRUE
	materials = list(MAT_TITANIUM = 2000, MAT_BANANIUM = 2000)

/obj/item/nuclear_rod/fuel/bananium/Initialize(mapload)
	max_durability = rand(1000, 10000)
	power_amp_mod = rand(1, 40) / 10
	heat_amp_mod = rand(5, 80) / 10
	power_amount = rand(10 KW, 200 KW)
	heat_amount = rand(10, 500)
	return ..()

/obj/item/nuclear_rod/fuel/meltdown
	name = "meltdown rod"
	desc = "A Syndicate-crafted rod capable of generating massive amounts of heat, leading to an eventual meltdown."
	icon_state = "fuel_syndie"
	heat_amount = 2000
	max_durability = INFINITY
	minimum_temp_modifier = 4000 // BIG hot
	reactor_overheat_modifier = -400
	alpha_rad = 250
	beta_rad = 250
	gamma_rad = 250

// MARK: Moderator Rods

/obj/item/nuclear_rod/moderator
	name = "any moderator rod"
	icon_state = "mod_water"

/obj/item/nuclear_rod/moderator/heavy_water
	name = "heavy water moderator"
	desc = "A basic moderation rod filled with a variant of water comprised of deuterium instead of hydrogen atoms."
	heat_amp_mod = 1.1
	power_amp_mod = 1.4
	craftable = TRUE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/moderator/graphite
	name = "graphite moderator"
	desc = "A nuclear moderation rod comprised primarily of layered graphite. A staple of fission reactor operation through the ages."
	icon_state = "mod_graphite"
	heat_amp_mod = 1.3
	power_amp_mod = 1.6
	craftable = TRUE
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 2000)
	adjacent_requirements = list(/obj/item/nuclear_rod/coolant)

/obj/item/nuclear_rod/moderator/titanium
	name = "titanium moderator"
	desc = "A nuclear moderation rod comprised primarily of cast titanium. For what it lacks in power amplification, it makes up for in versatility and durability."
	icon_state = "mod_titanium"
	max_durability = 5500
	heat_amp_mod = 0.7
	power_amp_mod = 1.5
	craftable = TRUE
	materials = list(MAT_METAL = 2000, MAT_TITANIUM = 2000)

/obj/item/nuclear_rod/moderator/plasma_agitator
	name = "plasma agitator"
	desc = "A specialized moderator rod capable of inducing higher fission rates in fuel rods through a series of micro-burns. It doesn't last long."
	icon_state = "mod_plasma"
	max_durability = 2250
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
	icon_state = "mod_aluminium"
	max_durability = 6000
	power_amount = -15 KW
	heat_amp_mod = 5
	power_amp_mod = 3
	minimum_temp_modifier = 400
	reactor_overheat_modifier = 100
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/nitrogen_circulator,
		/obj/item/nuclear_rod/moderator,
	)

/obj/item/nuclear_rod/moderator/bluespace_agitator
	name = "bluespace crystal agitator"
	desc = "An advanced moderator rod that will pull extra neutrons out of bluespace to bombard local fuel rods. The result is a massive increase of power and heat generation. It is exceptionally versatile; however, its power requirements limit its uses."
	icon_state = "mod_bluespace"
	max_durability = 4000
	power_amount = -30 KW
	heat_amp_mod = 12
	power_amp_mod = 5
	upgrade_required = TRUE
	craftable = TRUE
	materials = list(MAT_METAL = 2000, MAT_TITANIUM = 1000, MAT_BLUESPACE = 1000)

/obj/item/nuclear_rod/moderator/diamond_plate
	name = "diamond reflector plates"
	desc = "An advanced moderator rod that can reflect nearly all neutrons back to their point of origin. Simple, stable, reliable."
	icon_state = "mod_diamond"
	max_durability = 6000
	heat_amp_mod = 6.5
	power_amp_mod = 3.3
	reactor_overheat_modifier = 100
	craftable = TRUE
	upgrade_required = TRUE
	materials = list(MAT_METAL = 2000, MAT_TITANIUM = 1000, MAT_DIAMOND = 1000)
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/moderator/platinum_plating
	name = "platinum reflector plating"
	desc = "An advanced moderator similar to diamond plates, but improved with precious space metals."
	icon_state = "mod_platinum"
	max_durability = 8000
	heat_amp_mod = 8
	power_amp_mod = 3.9
	reactor_overheat_modifier = 300
	adjacent_requirements = list(/obj/item/nuclear_rod/fuel/americium)

/// MARK: Coolant Rods

/obj/item/nuclear_rod/coolant
	name = "any coolant rod"
	icon_state = "coolant_water"

/obj/item/nuclear_rod/coolant/light_water
	name = "light water circulator"
	desc = "A basic coolant rod that circulates distilled water through critical reactor components."
	heat_amount = -10
	power_amount = -10 KW
	reactor_overheat_modifier = 25
	craftable = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/co2_regulator
	name = "carbon dioxide regulator"
	desc = "A specialized coolant rod filled with carbon dioxide gas, capable of regulating temperature spikes in fuel rods. However, it's very energy inefficient."
	icon_state = "coolant_carbon"
	heat_amount = -4
	heat_amp_mod = 0.6
	power_amount = -15 KW
	craftable = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/plasma_injector
	name = "plasma injector"
	desc = "A specialized coolant rod filled with gaseous plasma. By taking advantage of plasma's unique heat-absorbent properties, small amounts injected around fuel rods neutralize excess heat. However, the tank runs out quickly this way."
	icon_state = "coolant_plasma"
	max_durability = 1900
	heat_amp_mod = 0.5
	power_amp_mod = 1.5
	craftable = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/coolant)
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/nitrogen_circulator
	name = "nitrogen circulator"
	desc = "A specialized coolant rod filled with nitrogen gas. While not as powerful as similar alternatives, this rod is exceptionally stable and will last longer."
	icon_state = "coolant_nitrogen"
	max_durability = 3500
	heat_amount = -10
	power_amp_mod = 0.9
	heat_amp_mod = 0.7
	craftable = TRUE
	reactor_overheat_modifier = 50
	power_amount = -5 KW
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/molten_salt
	name = "molten salt circulator"
	desc = "A specialized coolant rod that circulates molten salts through the core of the reactor. Despite forcing the reactor to run exceptionally hot, this rod provides top-notch cooling potential above its resting temperature."
	icon_state = "coolant_salt"
	power_amount = -20 KW
	heat_amount = -60
	heat_amp_mod = 0.8
	max_durability = 8000
	minimum_temp_modifier = 750
	reactor_overheat_modifier = 100
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/nitrogen_circulator,
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/coolant/steam_hammerjet
	name = "steam hammerjet"
	desc = "A specialized coolant rod that injects distilled steam throughout the reactor's critical components. Although it makes the reactor run warm, it's very good at suppressing heat buildup."
	icon_state = "coolant_steam"
	power_amount = -10 KW
	heat_amount = -40
	heat_amp_mod = 0.4
	max_durability = 6000
	minimum_temp_modifier = 450
	reactor_overheat_modifier = 100
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/light_water,
		/obj/item/nuclear_rod/coolant/light_water,
	)

/obj/item/nuclear_rod/coolant/bluespace_displacer
	name = "bluespace heat displacer"
	desc = "An advanced coolant rod capable of pulling heat directly out of neighboring rods and sending it... somewhere."
	icon_state = "coolant_bluespace"
	power_amount = -40 KW
	heat_amount = -100
	heat_amp_mod = 0.8
	power_amp_mod = 1.3
	max_durability = INFINITY
	reactor_overheat_modifier = 200
	craftable = TRUE
	upgrade_required = TRUE
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_BLUESPACE = 1000)
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator/bluespace_agitator)

/obj/item/nuclear_rod/coolant/iridium_conductor
	name = "iridium conductor coolant rod"
	desc = "A dazzlingly beautiful rod with exceptionally powerful thermal conductivity. A highly sought after piece of equipment for its simplicity and potency."
	icon_state = "coolant_iridium"
	heat_amp_mod = 0.1
	max_durability = 10000
	reactor_overheat_modifier = 300
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator/aluminum_reflector,
		/obj/item/nuclear_rod/fuel/uranium_235,
	)

/obj/item/nuclear_rod/coolant/condensed_spacematter
	name = "condensed spacematter coolant rod"
	desc = "While it's unknown quite what the rod is filled with, there's no questioning its heat-suppressing efficiency. However, it violently disintegrates in contact with anything that isn't its housing."
	icon_state = "coolant_spacematter"
	heat_amount = -1500
	heat_amp_mod = 0.2
	materials = list(MAT_METAL = 6000, MAT_PLASMA = 4000, MAT_TITANIUM = 2000)
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel/enriched_plutonium,
		/obj/item/nuclear_rod/fuel/thorium_salts,
	)
