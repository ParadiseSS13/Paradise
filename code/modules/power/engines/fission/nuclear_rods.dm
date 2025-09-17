/obj/item/nuclear_rod
	name = "Nuclear Control Rod"
	desc = "You shouldnt be seeing this. Contact a developer"
	icon = 'icons/obj/fission/rods.dmi'
	icon_state = "irradiated"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE
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
	/// How much power does this rod add by default in watts
	var/power_amount = 0
	/// How does this rod affect its neighbors power production
	var/power_amp_mod = 1
	/// What type of radiation is emitted by this rod
	var/list/rad_type
	/// What items need to be adjacent to this rod for it to function properly
	var/list/adjacent_requirements = list()
	/// Is this design visible on the rod fabricator
	var/craftable = TRUE

/obj/item/nuclear_rod/Initialize(mapload)
	. = ..()
	durability = max_durability

/obj/item/nuclear_rod/examine(mob/user)
	. = ..()
	if(length(adjacent_requirements))
		var/list/templist = list()
		for(var/obj/item/nuclear_rod/requirement in adjacent_requirements)
			templist += requirement::name
		var/requirement_list = english_list(adjacent_requirements, and_text = ", ")
		. += "This rod has the following neighbor requirements: [requirement_list]"
	else
		. += "This rod has no neighbor requirements."

/obj/item/nuclear_rod/proc/get_durability_mod()
	var/temp_mod
	temp_mod = clamp(1.5 * (durability / max_durability) - 0.25, 0.25, 1)
	return temp_mod

/obj/item/nuclear_rod/fuel
	name = "any fuel rod"
	desc = "This is a base item and should not be found. Alert a developer!"
	rad_type = ALPHA_RAD

	/// the amount of cycles needed to complete enrichment. 30 = ~1 minute
	var/enrichment_cycles = 15
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

/obj/item/nuclear_rod/fuel/uranium_238
	name = "uranium 235 fuel rod"
	desc = "A standard fuel rod for most NGCR reactors. Has just barely enough Uranium 235 to be useful."
	heat_amount = 5
	power_amount = 20 KW
	heat_amp_mod = 1.8
	power_amp_mod = 1.1
	rad_type = BETA_RAD
	heat_enrich_threshold = 10 // all uranium rods surrounding: 1.8 x 1.8 x 1.8 x 1.8
	power_enrich_threshold = 6.5 // all graphite rods surrounding: 1.6 x 1.6 x 1.6 x 1.6
	heat_enrich_result = /obj/item/nuclear_rod/fuel/weak_thorium
	power_enrich_result = /obj/item/nuclear_rod/fuel/weak_plutonium
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator,)
	materials = list(MAT_METAL = 2000, MAT_URANIUM = 1000)

/obj/item/nuclear_rod/fuel/weak_thorium
	name = "weak thorium fuel rod"
	desc = "A specialized fuel rod bred from uranium 238. This rod will last longer than normal, and wont generate as much heat."
	heat_amount = 5
	power_amount = 20 KW
	heat_amp_mod = 1.6
	power_amp_mod = 1.1
	durability = 10000
	rad_type = ALPHA_RAD
	craftable = FALSE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/coolant,
		)

/obj/item/nuclear_rod/fuel/weak_plutonium
	name = "weak plutonium fuel rod"
	heat_amount = 10
	power_amount = 30 KW
	heat_amp_mod = 1.6
	power_amp_mod = 1.1
	max_durability = 5000
	rad_type = ALPHA_RAD
	craftable = FALSE
	adjacent_requirements = list(
		/obj/item/nuclear_rod/moderator,
		/obj/item/nuclear_rod/coolant,
		)

/obj/item/nuclear_rod/moderator
	name = "any moderator rod"
	desc = "This is a base item and should not be found. Alert a developer!"
	icon_state = "normal"

/obj/item/nuclear_rod/moderator/heavy_water
	name = "heavy water moderator"
	desc = "A basic moderation rod filled with a varint of water comprised of deuterium instead of hydrogen atoms."
	heat_amp_mod = 1.1
	power_amp_mod = 1.4
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)

/obj/item/nuclear_rod/moderator/graphite
	name = "graphite moderator"
	desc = "A nuclear moderation rod comprised of primarily of layered graphite. A staple of fission reactor operation through the ages."
	heat_amp_mod = 1.1
	power_amp_mod = 1.4
	materials = list(MAT_METAL = 4000, MAT_PLASMA = 2000)

/obj/item/nuclear_rod/coolant
	name = "any coolant rod"
	desc = "This is a base item and should not be found. Alert a developer!"
	icon_state = "bananium"


/obj/item/nuclear_rod/coolant/light_water
	name = "light water circulator"
	desc = "A basic coolant rod that circulates distilled water through critical reactor components."
	heat_amount = -10
	heat_amp_mod = 1
	power_amount = -10 KW
	adjacent_requirements = list(/obj/item/nuclear_rod/moderator)
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
