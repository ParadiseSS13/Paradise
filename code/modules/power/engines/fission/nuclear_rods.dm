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
	/// How fast does this rod decay its neighbors
	var/neighbor_decay_mod = 1
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

/// After all status have been in determined the main reactor process(), this runs.
/obj/item/nuclear_rod/proc/do_special_effect()
	return

/// Called when the rod chamber updates its statistics for any reason
/obj/item/nuclear_rod/proc/on_calculate_stats(obj/machinery/atmospherics/reactor_chamber/chamber)
	return FALSE

/obj/item/nuclear_rod/proc/on_lower(obj/machinery/atmospherics/reactor_chamber/chamber)
	return

/obj/item/nuclear_rod/proc/on_raise(obj/machinery/atmospherics/reactor_chamber/chamber)
	return

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
	/// Have we proc'd the on_enrich process?
	var/enriched = FALSE

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
	if(!enriched && power_enrich_progress >= enrichment_cycles || heat_enrich_progress >= enrichment_cycles)
		enriched = TRUE
		on_enrich()
	return successful_enrichment

/// Called when the a rod has successfully been enriched
/obj/item/nuclear_rod/fuel/proc/on_enrich()
	return

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

/obj/item/nuclear_rod/fuel/uranium_238/spiders
	name = "spider-clan uranium 238 fuel rod"
	desc = "A small fuel rod for most NGCR reactors. This one was green webs coating its surface, with tiny spiders skittering along them."
	w_class = WEIGHT_CLASS_NORMAL
	craftable = FALSE
	adjacent_requirements = list()

/obj/item/nuclear_rod/fuel/uranium_238/spiders/do_special_effect()
	if(prob(5))
		new /mob/living/basic/spiderling(get_turf(src))

/obj/item/nuclear_rod/fuel/weak_thorium
	name = "weak thorium fuel rod"
	desc = "A specialized fuel rod refined from uranium 238. This rod will last longer than normal, and won't generate as much heat."
	icon_state = "fuel_weakthor"
	heat_amount = 5
	power_amount = 20 KW
	heat_amp_mod = 1.4
	power_amp_mod = 1.1
	max_durability = 5000
	beta_rad = 100
	gamma_rad = 100
	heat_enrich_threshold = 20
	heat_enrich_result = /obj/item/nuclear_rod/fuel/neptunium
	power_enrich_threshold = 8
	power_enrich_result = /obj/item/nuclear_rod/fuel/uranium_235
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/coolant,
	)

/obj/item/nuclear_rod/fuel/neptunium
	name = "neptunium fuel rod"
	desc = "Although not powerful on its own, the stability of neptunium makes it a wonderful rod for any stable reaction chains."
	icon_state = "fuel_nept"
	heat_amount = 30
	power_amount = 40 KW
	heat_amp_mod = 2.1
	power_amp_mod = 1.8
	neighbor_decay_mod = 0.85
	max_durability = 8000
	beta_rad = 100
	gamma_rad = 100

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
	heat_enrich_threshold = 40
	heat_enrich_result = /obj/item/nuclear_rod/fuel/protactinium
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/fuel/uranium_235,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/fuel/protactinium
	name = "protactinium fuel rod"
	desc = "A highly efficient nuclear fuel, protactinium boasts very high overall stats while being able to assist with keeping many reactors highly stable."
	icon_state = "fuel_prot"
	heat_amount = 40
	power_amount = 70 KW
	heat_amp_mod = 2.4
	power_amp_mod = 1.5
	neighbor_decay_mod = 0.8
	max_durability = 20000
	beta_rad = 250

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
	heat_enrich_threshold = 80
	heat_enrich_result = /obj/item/nuclear_rod/fuel/weapons_grade_plutonium
	power_enrich_threshold = 40
	power_enrich_result = /obj/item/nuclear_rod/fuel/americium
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator/plasma_agitator,
		/obj/item/nuclear_rod/fuel/thorium_salts,
	)

/obj/item/nuclear_rod/fuel/weapons_grade_plutonium
	name = "weapons grade plutonium fuel"
	desc = "A highly dangerous fuel commonly used to create cores for nuclear devices. While not the most powerful on its own, its high neutron count makes it ideal for agitating other fuel rods!"
	icon_state = "fuel_wg_plut"
	heat_amount = 150
	power_amount = 120 KW
	max_durability = 6000
	gamma_rad = 300
	beta_rad = 250
	heat_amp_mod = 10
	power_amp_mod = 5
	neighbor_decay_mod = 1.3
	adjacent_requirements = list(/obj/item/nuclear_rod/fuel/weapons_grade_plutonium)

/obj/item/nuclear_rod/fuel/supermatter
	name = "supermatter fuel rod"
	desc = "A dangerous fuel rod made entirely of supermatter, contained safely in a specialized housing case. Due to its unusual properties, it completely neutralizes any potential power from nearby rods."
	icon_state = "fuel_sm"
	heat_amount = 1200
	power_amount = 800 KW
	heat_amp_mod = 8
	power_amp_mod = 0.1
	neighbor_decay_mod = 1.5
	max_durability = INFINITY
	gamma_rad = 300
	adjacent_requirements = list(
		/obj/item/nuclear_rod/coolant/steam_hammerjet,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/moderator,
	)

// Supermatter has a special enrichment process
/obj/item/nuclear_rod/fuel/supermatter/enrich(power_mod, heat_mod)
	var/successful_enrichment = FALSE
	var/needed_supermatters = 2
	var/needed_francium = 2

	if(!istype(loc, /obj/machinery/atmospherics/reactor_chamber))
		return

	var/obj/machinery/atmospherics/reactor_chamber/source_chamber = loc
	for(var/obj/machinery/atmospherics/reactor_chamber/neighbor in source_chamber.neighbors)
		if(istype(neighbor.held_rod, /obj/item/nuclear_rod/fuel/supermatter))
			needed_supermatters--
		if(istype(neighbor.held_rod, /obj/item/nuclear_rod/fuel/francium))
			needed_francium--

	if(!needed_supermatters && !needed_francium)
		power_enrich_progress++
		heat_enrich_progress++
		successful_enrichment = TRUE

	if(!enriched && power_enrich_progress >= enrichment_cycles || heat_enrich_progress >= enrichment_cycles)
		enriched = TRUE
		on_enrich()
		return TRUE

	if(successful_enrichment)
		return TRUE

	return FALSE

/obj/item/nuclear_rod/fuel/supermatter/on_enrich()
	goonchem_vortex(get_turf(loc), FALSE, 50)
	if(!istype(loc, /obj/machinery/atmospherics/reactor_chamber))
		return
	var/obj/machinery/atmospherics/reactor_chamber/chamber = loc
	var/obj/item/nuclear_rod/moderator/antimatter/new_rod = new(chamber)
	chamber.held_rod = new_rod
	chamber.raise() // This is way easier than forcing everything to manually update.
	qdel(src)

/obj/item/nuclear_rod/fuel/americium
	name = "americium fuel rod"
	desc = "A specialized fuel rod refined from enriched plutonium. A pinnacle of power generation, this rod's power generation is nearly unmatched if one can tame its vicious heat output."
	icon_state = "fuel_americium"
	heat_amount = 100
	power_amount = 200 KW
	heat_amp_mod = 6
	power_amp_mod = 3
	max_durability = 5000
	gamma_rad = 300
	neighbor_decay_mod = 1.2
	power_enrich_threshold = 120
	power_enrich_result = /obj/item/nuclear_rod/fuel/francium
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/fuel/francium
	name = "francium fuel rod"
	desc = "A highly refined isotopse that can only be described as 'screamingly radioactive' over anything else. Its high radioactivity comes at the cost of a very short lifespan."
	icon_state = "fuel_franc"
	max_durability = 1800
	gamma_rad = 1000
	heat_amount = 600
	power_amount = 3000 KW
	heat_amp_mod = 8
	power_amp_mod = 4
	neighbor_decay_mod = 1.3
	adjacent_requirements = list(/obj/item/nuclear_rod/fuel/americium)

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
	neighbor_decay_mod = rand(1, 4) / 10
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
	neighbor_decay_mod = 0.9

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

/obj/item/nuclear_rod/moderator/steel
	name = "steel moderator"
	desc = "A crude and cheap moderator rod. Its not very good at much and is harsh on other nearby rods, however it does not have many requirements to operate."
	icon_state = "mod_steel"
	max_durability = 8000
	heat_amp_mod = 3
	power_amp_mod = 1.2
	neighbor_decay_mod = 1.6
	craftable = TRUE
	materials = list(MAT_METAL = 1000)

/obj/item/nuclear_rod/moderator/lead
	name = "lead moderator"
	desc = "An exceptionally dense, toxic rod that is highly effective at halting nuclear reactions. It is not likely to find much use in most nuclear setups due to its effect on neutron chain reactions."
	icon_state = "mod_lead"
	max_durability = 5500
	heat_amp_mod = 0.1
	power_amp_mod = 0.3
	neighbor_decay_mod = 0.2
	craftable = TRUE
	upgrade_required = TRUE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 2000)
	adjacent_requirements = list(/obj/item/nuclear_rod/coolant)

/obj/item/nuclear_rod/moderator/beryllium
	name = "beryllium moderator"
	desc = "A common standard for nuclear enrichment and fission processes, known for its use in processing uranium isotopes."
	icon_state = "mod_beryllium"
	heat_amount = 40
	max_durability = 6000
	heat_amp_mod = 7.2
	power_amp_mod = 3.4
	craftable = TRUE
	materials = list(MAT_METAL = 4000, MAT_SILVER = 2000, MAT_TITANIUM = 4000)
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel/uranium_238,
		/obj/item/nuclear_rod/fuel/uranium_238,
		/obj/item/nuclear_rod/fuel/uranium_235,
		/obj/item/nuclear_rod/coolant,
		)

/obj/item/nuclear_rod/moderator/plasma_agitator
	name = "plasma agitator"
	desc = "A specialized moderator rod capable of inducing higher fission rates in fuel rods through a series of micro-burns. It doesn't last long."
	icon_state = "mod_plasma"
	max_durability = 2000
	heat_amount = 20
	heat_amp_mod = 6
	power_amp_mod = 4
	neighbor_decay_mod = 1.8
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
	neighbor_decay_mod = 1.1
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
	neighbor_decay_mod = 1.2
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
	neighbor_decay_mod = 1.1
	craftable = TRUE
	upgrade_required = TRUE
	materials = list(MAT_METAL = 2000, MAT_TITANIUM = 1000, MAT_DIAMOND = 1000)
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/moderator/antimatter
	name = "antimatter cluster"
	desc = "A product of unstable supermatter enrichment processes, antimatter holds untold amounts of energy at the cost of nullifying most other reactions near it. Should it be released from its casing, the result would likely demolish half a station.<br> \
			<span class='danger'>It would be a <b>VERY BAD IDEA</b> to put two of these next to eachother.</span>"
	icon_state = "mod_antimatter"
	max_durability = INFINITY
	power_amp_mod = 0 // Yummy, eating all your power!
	neighbor_decay_mod = 2
	alpha_rad = 250
	beta_rad = 250
	gamma_rad = 250
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
		/obj/item/nuclear_rod/fuel,
	)

/obj/item/nuclear_rod/moderator/antimatter/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/machinery/atmospherics/reactor_chamber)) // This shouldnt be possible but check anyways
		collision_check(loc)

/obj/item/nuclear_rod/moderator/antimatter/on_calculate_stats(obj/machinery/atmospherics/reactor_chamber/chamber)
	chamber.power_mod_total = chamber.power_mod_total ** 1.5 // EXPONENTIAL GOODNESS
	chamber.heat_mod_total =  chamber.heat_mod_total ** 1.75 // Uh oh exponential goodness
	return TRUE

/obj/item/nuclear_rod/moderator/antimatter/on_lower(obj/machinery/atmospherics/reactor_chamber/chamber)
	collision_check(chamber)

/obj/item/nuclear_rod/moderator/antimatter/proc/collision_check(obj/machinery/atmospherics/reactor_chamber/chamber)
	for(var/obj/machinery/atmospherics/reactor_chamber/neighbor in chamber.neighbors)
		neighbor.suppressed = TRUE
		if(neighbor.chamber_state == CHAMBER_DOWN && neighbor.held_rod && istype(neighbor.held_rod, /obj/item/nuclear_rod/moderator/antimatter))
			QDEL_NULL(neighbor.held_rod) // uh oh big bad swirly time
			neighbor.weld_shut()
			chamber.weld_shut()
			var/obj/effect/temp_visual/telekinesis/antimatter_rod/effect = new(get_turf(chamber))
			effect.duration = 20 SECONDS
			addtimer(CALLBACK(src, PROC_REF(detonate), chamber), 20 SECONDS)
			playsound(loc, 'sound/effects/eleczap.ogg', 60, TRUE)
			if(chamber.linked_reactor)
				playsound(chamber.linked_reactor, 'sound/machines/engine_alert1.ogg', 100, FALSE, 40, 30, falloff_distance = 10)
				chamber.linked_reactor.radio.autosay(SPAN_BIG("ALERT! Antimatter collision detected in chamber housing. Event Horizon formation expected in 20 seconds without intervention."), name, null)

/obj/item/nuclear_rod/moderator/antimatter/proc/detonate(obj/machinery/atmospherics/reactor_chamber/chamber)
	if(chamber.held_rod != src)
		return
	var/turf/T = get_turf(src)
	var/antimatter_collapse_sound = sound('sound/magic/charge.ogg')
	for(var/player in GLOB.player_list)
		var/mob/M = player
		var/turf/mob_turf = get_turf(M)
		if(atoms_share_level(T, mob_turf))
			SEND_SOUND(M, antimatter_collapse_sound)
	investigate_log("has collapsed into a singularity from having an antimatter neighbor.", INVESTIGATE_REACTOR)
	var/obj/singularity/S = new(T)
	S.energy = 250 // Lets get it started!
	S.consume(chamber)


/obj/item/nuclear_rod/moderator/antimatter/on_raise(obj/machinery/atmospherics/reactor_chamber/chamber)
	for(var/obj/machinery/atmospherics/reactor_chamber/neighbor in chamber.neighbors)
		neighbor.suppressed = FALSE

/obj/item/nuclear_rod/moderator/meaty
	name = "meat-based rod"
	desc = "This should not be visible. Contact a developer."
	max_durability = INFINITY
	heat_amount = 50

/obj/item/nuclear_rod/moderator/platinum_plating
	name = "platinum reflector plating"
	desc = "An advanced moderator similar to diamond plates, but improved with precious space metals."
	icon_state = "mod_platinum"
	max_durability = 8000
	heat_amp_mod = 8
	power_amp_mod = 3.9
	neighbor_decay_mod = 1.3
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
	neighbor_decay_mod = 0.9
	craftable = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/co2_regulator
	name = "carbon dioxide regulator"
	desc = "A specialized coolant rod filled with carbon dioxide gas, capable of regulating temperature spikes in fuel rods. However, it's very energy inefficient."
	icon_state = "coolant_co2"
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
	neighbor_decay_mod = 0.75
	craftable = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/coolant)
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/boron
	name = "boron-doped graphite rod"
	desc = "While similar in appearance to a graphite moderator, this rod has been doped with incredibly heavy boron molecules. Added to a reactor, it can break the chain of nearby fissile reactions."
	icon_state = "coolant_boron"
	max_durability = 6000
	heat_amp_mod = 0.1
	power_amp_mod = 0.4
	neighbor_decay_mod = 0.2
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 2000, MAT_GLASS = 2000)

/obj/item/nuclear_rod/coolant/graphene
	name = "graphene coolant rod"
	desc = "A more advanced form of graphite, graphene is incredibly stable and highly durable. However, unlike graphite, graphene's strong structure make it more hesitant to excite neutrons."
	icon_state = "coolant_boron"
	max_durability = 10000
	heat_amp_mod = 1.3
	power_amp_mod = 1.5
	neighbor_decay_mod = 0.5
	craftable = TRUE
	upgrade_required = TRUE
	materials = list(MAT_METAL = 4000, MAT_GOLD = 1000, MAT_GLASS = 4000)

/obj/item/nuclear_rod/coolant/nitrogen_circulator
	name = "nitrogen circulator"
	desc = "A specialized coolant rod filled with nitrogen gas. While not as powerful as similar alternatives, this rod is exceptionally stable and will last longer."
	icon_state = "coolant_nitrogen"
	max_durability = 3500
	heat_amount = -10
	power_amp_mod = 0.9
	heat_amp_mod = 0.7
	neighbor_decay_mod = 0.85
	craftable = TRUE
	reactor_overheat_modifier = 50
	power_amount = -5 KW
	materials = list(MAT_METAL = 2000, MAT_PLASMA = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/coolant/molten_salt
	name = "molten salt circulator"
	desc = "A specialized coolant rod that circulates molten salts through the core of the reactor. Despite forcing the reactor to run exceptionally hot, this rod provides top-notch cooling potential above its resting temperature."
	icon_state = "coolant_salt"
	power_amount = -20 KW
	heat_amount = -200
	heat_amp_mod = 0.7
	max_durability = 8000
	minimum_temp_modifier = 750
	reactor_overheat_modifier = 300
	neighbor_decay_mod = 1.2
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
	neighbor_decay_mod = 0.9
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
	power_amp_mod = 1.5
	neighbor_decay_mod = 0.8
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
	neighbor_decay_mod = 1.5
	materials = list(MAT_METAL = 6000, MAT_PLASMA = 4000, MAT_TITANIUM = 2000)
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel/enriched_plutonium,
		/obj/item/nuclear_rod/fuel/thorium_salts,
	)

/obj/item/nuclear_rod/coolant/hydrogen
	name = "hydrogen circulator"
	desc = "A swirling container of pure hydrogen. Its high thermal conductivity allow it to easily rip away heat from the core, though most reactions phase straight through its light atomic mass."
	icon_state = "coolant_hydrogen"
	heat_amount = -5000
	heat_amp_mod = 0.9
	materials = list(MAT_METAL = 6000, MAT_PLASMA = 4000, MAT_TITANIUM = 2000)
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(/obj/item/nuclear_rod/fuel/uranium_235)

/obj/item/nuclear_rod/coolant/tritium
	name = "tritium circulator"
	desc = "While almost entirely similar to hydrogen, placing it near an intense radiation source can unlock its true potential."
	icon_state = "coolant_tritium"
	heat_amount = -10000
	heat_amp_mod = 0.8
	neighbor_decay_mod = 0.8
	materials = list(MAT_METAL = 6000, MAT_PLASMA = 4000, MAT_TITANIUM = 2000)
	craftable = TRUE
	upgrade_required = TRUE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/fuel/francium,
		/obj/item/nuclear_rod/fuel/francium,
	)
