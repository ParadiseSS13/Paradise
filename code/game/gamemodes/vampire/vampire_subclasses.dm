/datum/vampire_subclass
	var/list/standard_powers
	var/list/fully_powered_abilities
	/// whether or not a vampire heals more based on damage taken.
	var/improved_rejuv_healing = FALSE
	var/full_power_override = FALSE

/datum/vampire_subclass/proc/add_subclass_ability(datum/vampire/vamp)
	for(var/thing in standard_powers)
		if(vamp.bloodtotal >= standard_powers[thing])
			vamp.add_ability(thing)

/datum/vampire_subclass/proc/add_full_power_abilities(datum/vampire/vamp)
	for(var/thing in fully_powered_abilities)
		vamp.add_ability(thing)

/datum/vampire_subclass/umbrae
	standard_powers = list(/obj/effect/proc_holder/spell/self/cloak = 150,
							/obj/effect/proc_holder/spell/targeted/click/shadow_snare = 250,
							/obj/effect/proc_holder/spell/targeted/click/dark_passage = 400,
							/obj/effect/proc_holder/spell/aoe_turf/vamp_extinguish = 600)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/obj/effect/proc_holder/spell/self/eternal_darkness,
								/datum/vampire_passive/xray)

/datum/vampire_subclass/hemomancer
	standard_powers = list(/obj/effect/proc_holder/spell/self/vamp_claws = 150,
							/obj/effect/proc_holder/spell/targeted/click/blood_tendrils = 250,
							/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/blood_pool = 400,
							/obj/effect/proc_holder/spell/blood_eruption = 600)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/obj/effect/proc_holder/spell/self/blood_spill)

/datum/vampire_subclass/gargantua
	standard_powers = list(/obj/effect/proc_holder/spell/self/blood_swell = 150,
							/obj/effect/proc_holder/spell/self/blood_rush = 250,
							/datum/vampire_passive/blood_swell_upgrade = 400,
							/obj/effect/proc_holder/spell/self/overwhelming_force = 600)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/obj/effect/proc_holder/spell/targeted/click/charge)
	improved_rejuv_healing = TRUE

/datum/vampire_subclass/ancient
	standard_powers = list(/obj/effect/proc_holder/spell/self/vamp_claws,
							/obj/effect/proc_holder/spell/self/blood_swell,
							/obj/effect/proc_holder/spell/self/cloak,
							/obj/effect/proc_holder/spell/targeted/click/blood_tendrils,
							/obj/effect/proc_holder/spell/self/blood_rush,
							/obj/effect/proc_holder/spell/targeted/click/shadow_snare,
							/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/blood_pool,
							/datum/vampire_passive/blood_swell_upgrade,
							/obj/effect/proc_holder/spell/targeted/click/dark_passage,
							/obj/effect/proc_holder/spell/blood_eruption,
							/obj/effect/proc_holder/spell/self/overwhelming_force,
							/obj/effect/proc_holder/spell/aoe_turf/vamp_extinguish,
							/obj/effect/proc_holder/spell/targeted/shapeshift/bats,
							/obj/effect/proc_holder/spell/targeted/shapeshift/hellhound,
							/obj/effect/proc_holder/spell/targeted/raise_vampires,
							/obj/effect/proc_holder/spell/targeted/enthrall,
							/datum/vampire_passive/full,
							/obj/effect/proc_holder/spell/self/blood_spill,
							/obj/effect/proc_holder/spell/targeted/click/charge,
							/obj/effect/proc_holder/spell/self/eternal_darkness,
							/datum/vampire_passive/xray)
	improved_rejuv_healing = TRUE
