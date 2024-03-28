/datum/vampire_subclass
	/// The subclass' name. Used for blackbox logging.
	var/name = "yell at coderbus"
	/// A list of powers that a vampire unlocks. The value of the list entry is equal to the blood total required for the vampire to unlock it.
	var/list/standard_powers
	/// A list of the powers a vampire unlocks when it reaches full power.
	var/list/fully_powered_abilities
	/// Whether or not a vampire heals more based on damage taken.
	var/improved_rejuv_healing = FALSE
	/// maximun number of thralls a vampire may have at a time. incremented as they grow stronger, up to a cap at full power.
	var/thrall_cap = 1
	/// If true, lets the vampire have access to their full power abilities without meeting the blood requirement, or needing a certain number of drained humans.
	var/full_power_override = FALSE

/datum/vampire_subclass/proc/add_subclass_ability(datum/antagonist/vampire/vamp)
	for(var/thing in standard_powers)
		if(vamp.bloodtotal >= standard_powers[thing])
			vamp.add_ability(thing)

/datum/vampire_subclass/proc/add_full_power_abilities(datum/antagonist/vampire/vamp)
	for(var/thing in fully_powered_abilities)
		vamp.add_ability(thing)

/datum/vampire_subclass/umbrae
	name = "umbrae"
	standard_powers = list(/datum/spell/vampire/self/cloak = 150,
							/datum/spell/vampire/shadow_snare = 250,
							/datum/spell/vampire/soul_anchor = 250,
							/datum/spell/vampire/dark_passage = 400,
							/datum/spell/vampire/vamp_extinguish = 600,
							/datum/spell/vampire/shadow_boxing = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/vampire_passive/vision/full,
								/datum/spell/vampire/self/eternal_darkness,
								/datum/vampire_passive/vision/xray)

/datum/vampire_subclass/hemomancer
	name = "hemomancer"
	standard_powers = list(/datum/spell/vampire/self/vamp_claws = 150,
							/datum/spell/vampire/blood_tendrils = 250,
							/datum/spell/vampire/blood_barrier = 250,
							/datum/spell/ethereal_jaunt/blood_pool = 400,
							/datum/spell/vampire/predator_senses = 600,
							/datum/spell/vampire/blood_eruption = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/vampire_passive/vision/full,
								/datum/spell/vampire/self/blood_spill)

/datum/vampire_subclass/gargantua
	name = "gargantua"
	standard_powers = list(/datum/spell/vampire/self/blood_swell = 150,
							/datum/spell/vampire/self/blood_rush = 250,
							/datum/spell/vampire/self/stomp = 250,
							/datum/vampire_passive/blood_swell_upgrade = 400,
							/datum/spell/vampire/self/overwhelming_force = 600,
							/datum/spell/vampire/charge = 800,
							/datum/spell/fireball/demonic_grasp = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/vampire_passive/vision/full,
								/datum/spell/vampire/arena)
	improved_rejuv_healing = TRUE

/datum/vampire_subclass/dantalion
	name = "dantalion"
	standard_powers = list(/datum/spell/vampire/enthrall = 150,
							/datum/spell/vampire/thrall_commune = 150,
							/datum/spell/vampire/pacify = 250,
							/datum/spell/vampire/switch_places = 250,
							/datum/spell/vampire/self/decoy = 400,
							/datum/vampire_passive/increment_thrall_cap = 400,
							/datum/spell/vampire/rally_thralls = 600,
							/datum/vampire_passive/increment_thrall_cap/two = 600,
							/datum/spell/vampire/self/share_damage = 800)
	fully_powered_abilities = list(/datum/vampire_passive/full,
								/datum/spell/vampire/hysteria,
								/datum/vampire_passive/vision/full,
								/datum/vampire_passive/increment_thrall_cap/three)


/datum/vampire_subclass/ancient
	name = "ancient"
	standard_powers = list(/datum/spell/vampire/self/vamp_claws,
							/datum/spell/vampire/self/blood_swell,
							/datum/spell/vampire/self/cloak,
							/datum/spell/vampire/enthrall,
							/datum/spell/vampire/thrall_commune,
							/datum/spell/vampire/blood_tendrils,
							/datum/spell/vampire/blood_barrier,
							/datum/spell/vampire/self/blood_rush,
							/datum/spell/vampire/self/stomp,
							/datum/spell/vampire/charge,
							/datum/spell/vampire/shadow_snare,
							/datum/spell/vampire/soul_anchor,
							/datum/spell/vampire/pacify,
							/datum/spell/vampire/switch_places,
							/datum/spell/ethereal_jaunt/blood_pool,
							/datum/vampire_passive/blood_swell_upgrade,
							/datum/spell/vampire/dark_passage,
							/datum/spell/vampire/self/decoy,
							/datum/spell/vampire/blood_eruption,
							/datum/spell/vampire/predator_senses,
							/datum/spell/vampire/self/overwhelming_force,
							/datum/spell/vampire/vamp_extinguish,
							/datum/spell/vampire/rally_thralls,
							/datum/spell/vampire/self/share_damage,
							/datum/spell/fireball/demonic_grasp,
							/datum/spell/vampire/shadow_boxing,
							/datum/vampire_passive/full,
							/datum/vampire_passive/vision/full,
							/datum/spell/vampire/self/blood_spill,
							/datum/spell/vampire/arena,
							/datum/spell/vampire/self/eternal_darkness,
							/datum/spell/vampire/hysteria,
							/datum/spell/vampire/raise_vampires,
							/datum/vampire_passive/vision/xray)
	improved_rejuv_healing = TRUE
	thrall_cap = 150 // can thrall high pop
