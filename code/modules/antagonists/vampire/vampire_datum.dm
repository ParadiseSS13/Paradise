/datum/antagonist/vampire
	name = "Vampire"
	antag_hud_type = ANTAG_HUD_VAMPIRE
	antag_hud_name = "hudvampire"
	special_role = SPECIAL_ROLE_VAMPIRE
	var/bloodtotal = 0
	var/bloodusable = 0
	/// What vampire subclass the vampire is.
	var/datum/vampire_subclass/subclass
	/// Handles the vampire cloak toggle.
	var/iscloaking = FALSE
	/// List of available powers and passives.
	var/list/powers = list()
	/// Who the vampire is draining of blood.
	var/mob/living/carbon/human/draining
	/// Nullrods and holywater make their abilities cost more.
	var/nullified = 0
	/// List of powers that all vampires unlock and at what blood level they unlock them, the rest of their powers are found in the vampire_subclass datum.
	var/list/upgrade_tiers = list(/obj/effect/proc_holder/spell/vampire/self/rejuvenate = 0,
									/obj/effect/proc_holder/spell/vampire/glare = 0,
									/datum/vampire_passive/vision = 100,
									/obj/effect/proc_holder/spell/vampire/self/specialize = 150,
									/datum/vampire_passive/regen = 200)

	/// List of the peoples UIDs that we have drained, and how much blood from each one.
	var/list/drained_humans = list()


/datum/antagonist/vampire/Destroy(force, ...)
	owner.current.create_log(CONVERSION_LOG, "De-vampired")
	draining = null
	//QDEL_NULL(subclass)
	return ..()


/datum/antagonist/vampire/greet()
	var/dat
	SEND_SOUND(owner.current, sound('sound/ambience/antag/vampalert.ogg'))
	dat = "<span class='danger'>You are a Vampire!</span><br>"
	dat += {"To bite someone, target the head and use harm intent with an empty hand. Drink blood to gain new powers.
		You are weak to holy things, starlight and fire. Don't go into space and avoid the Chaplain, the chapel and especially Holy Water."}
	to_chat(owner.current, dat)


/datum/antagonist/vampire/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("Being a robot you fill how your vampiric powers fade away..."))
	else
		to_chat(owner.current, span_userdanger("Your mind is cleansed. You are no longer a vampire."))


/datum/antagonist/vampire/give_objectives()
	add_objective(/datum/objective/blood)
	add_objective(/datum/objective/maroon)
	add_objective(/datum/objective/steal)

	if(prob(20)) // 20% chance of getting survive. 80% chance of getting escape.
		add_objective(/datum/objective/survive)
	else
		add_objective(/datum/objective/escape)


/datum/antagonist/vampire/add_owner_to_gamemode()
	SSticker.mode.vampires += owner


/datum/antagonist/vampire/remove_owner_from_gamemode()
	SSticker.mode.vampires -= owner


/datum/antagonist/vampire/apply_innate_effects(mob/living/mob_override)
	mob_override = ..()
	if(!owner.som) //thralls and mindslaves
		owner.som = new()
		owner.som.masters += owner

	mob_override.dna.species.hunger_type = "vampire"
	mob_override.dna.species.hunger_icon = 'icons/mob/screen_hunger_vampire.dmi'
	check_vampire_upgrade(FALSE)


/datum/antagonist/vampire/remove_innate_effects(mob/living/mob_override)
	mob_override = ..()
	remove_all_powers()
	var/datum/hud/hud = mob_override.hud_used
	if(hud?.vampire_blood_display)
		hud.remove_vampire_hud()

	mob_override.dna.species.hunger_type = initial(mob_override.dna.species.hunger_type)
	mob_override.dna.species.hunger_icon = initial(mob_override.dna.species.hunger_icon)
	animate(mob_override, alpha = 255)
	REMOVE_TRAITS_IN(mob_override, VAMPIRE_TRAIT)


/**
 * Remove the vampire's current subclass and add the specified one.
 *
 * Arguments:
 * * new_subclass_type - a [/datum/vampire_subclass] typepath
 */
/datum/antagonist/vampire/proc/change_subclass(new_subclass_type)
	if(isnull(new_subclass_type))
		return

	clear_subclass(FALSE)
	add_subclass(new_subclass_type, log_choice = FALSE)


/**
 * Remove and delete the vampire's current subclass and all associated abilities.
 *
 * Arguments:
 * * give_specialize_power - if the [specialize][/obj/effect/proc_holder/spell/vampire/self/specialize] power should be given back or not
 */
/datum/antagonist/vampire/proc/clear_subclass(give_specialize_power = TRUE)
	if(give_specialize_power)
		// Choosing a subclass in the first place removes this from `upgrade_tiers`, so add it back if needed.
		upgrade_tiers[/obj/effect/proc_holder/spell/vampire/self/specialize] = 150

	remove_all_powers()
	QDEL_NULL(subclass)
	check_vampire_upgrade()


/datum/antagonist/vampire/proc/adjust_blood(mob/living/carbon/user, blood_amount = 0)
	if(user)
		var/unique_suck_id = user.UID()
		if(!(unique_suck_id in drained_humans))
			drained_humans[unique_suck_id] = 0

		if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
			return

		drained_humans[unique_suck_id] += blood_amount

	bloodtotal += blood_amount
	bloodusable += blood_amount
	check_vampire_upgrade(TRUE)

	for(var/obj/effect/proc_holder/spell/power in powers)
		if(power.action)
			power.action.UpdateButtonIcon()


#define BLOOD_GAINED_MODIFIER 0.5

/datum/antagonist/vampire/proc/handle_bloodsucking(mob/living/carbon/human/target, suck_rate = 5 SECONDS)
	draining = target
	var/unique_suck_id = target.UID()
	var/blood = 0
	var/blood_volume_warning = 9999 //Blood volume threshold for warnings

	if(owner.current.is_muzzled())
		to_chat(owner.current, span_warning("[owner.current.wear_mask] prevents you from biting [target]!"))
		draining = null
		return

	add_attack_logs(owner.current, target, "vampirebit & is draining their blood.", ATKLOG_ALMOSTALL)
	owner.current.visible_message(span_danger("[owner.current] grabs [target]'s neck harshly and sinks in [owner.current.p_their()] fangs!"), \
								span_danger("You sink your fangs into [target] and begin to drain [target.p_their()] blood."), \
								span_italics("You hear a soft puncture and a wet sucking noise."))

	if(!iscarbon(owner.current))
		target.LAssailant = null
	else
		target.LAssailant = owner.current

	while(do_mob(owner.current, target, suck_rate))
		owner.current.face_atom(target)
		owner.current.do_attack_animation(target, ATTACK_EFFECT_BITE)
		if(unique_suck_id in drained_humans)
			if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
				to_chat(owner.current, span_warning("You have drained most of the life force from [target]'s blood, and you will get no more useable blood from them!"))
				target.blood_volume = max(target.blood_volume - 25, 0)
				owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + 5))
				continue


		if(target.stat < DEAD)
			if(target.ckey || target.player_ghosted) //Requires ckey regardless if monkey or humanoid, or the body has been ghosted before it died
				blood = min(20, target.blood_volume)
				adjust_blood(target, blood * BLOOD_GAINED_MODIFIER)
				to_chat(owner.current, span_boldnotice("You have accumulated [bloodtotal] unit\s of blood, and have [bloodusable] left to use."))

		target.blood_volume = max(target.blood_volume - 25, 0)

		//Blood level warnings (Code 'borrowed' from Fulp)
		if(target.blood_volume)
			if(target.blood_volume <= BLOOD_VOLUME_BAD && blood_volume_warning > BLOOD_VOLUME_BAD)
				to_chat(owner.current, span_danger("Your victim's blood volume is dangerously low."))

			else if(target.blood_volume <= BLOOD_VOLUME_OKAY && blood_volume_warning > BLOOD_VOLUME_OKAY)
				to_chat(owner.current, span_warning("Your victim's blood is at an unsafe level."))
			blood_volume_warning = target.blood_volume //Set to blood volume, so that you only get the message once

		else
			to_chat(owner.current, span_warning("You have bled your victim dry!"))
			break

		if(!target.ckey && !target.player_ghosted)//Only runs if there is no ckey and the body has not being ghosted while alive
			to_chat(owner.current, span_boldnotice("Feeding on [target] reduces your thirst, but you get no usable blood from them."))
			owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + 5))

		else
			owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + (blood / 2)))

	draining = null
	to_chat(owner.current, span_notice("You stop draining [target.name] of blood."))

#undef BLOOD_GAINED_MODIFIER


/datum/antagonist/vampire/proc/force_add_ability(path)
	var/spell = new path(owner)
	if(istype(spell, /obj/effect/proc_holder/spell))
		owner.AddSpell(spell)

	if(istype(spell, /datum/vampire_passive))
		var/datum/vampire_passive/passive = spell
		passive.owner = owner.current
		passive.on_apply(src)

	powers += spell
	owner.current.update_sight() // Life updates conditionally, so we need to update sight here in case the vamp gets new vision based on his powers. Maybe one day refactor to be more OOP and on the vampire's ability datum.


/datum/antagonist/vampire/proc/get_ability(path)
	for(var/datum/power as anything in powers)
		if(power.type == path)
			return power
	return null


/datum/antagonist/vampire/proc/add_ability(path)
	if(!get_ability(path))
		force_add_ability(path)


/datum/antagonist/vampire/proc/remove_ability(ability)
	if(ability && (ability in powers))
		powers -= ability
		owner.spell_list.Remove(ability)
		qdel(ability)
		owner.current.update_sight() // Life updates conditionally, so we need to update sight here in case the vamp loses his vision based powers. Maybe one day refactor to be more OOP and on the vampire's ability datum.


/**
 * Removes all of the vampire's current powers.
 */
/datum/antagonist/vampire/proc/remove_all_powers()
	for(var/power in powers)
		remove_ability(power)


/datum/antagonist/vampire/proc/check_vampire_upgrade(announce = TRUE)
	var/list/old_powers = powers.Copy()

	for(var/ptype in upgrade_tiers)
		var/level = upgrade_tiers[ptype]
		if(bloodtotal >= level)
			add_ability(ptype)

	if(!subclass)
		return
	subclass.add_subclass_ability(src)

	check_full_power_upgrade()

	if(announce)
		announce_new_power(old_powers)


/datum/antagonist/vampire/proc/check_full_power_upgrade()
	if(subclass.full_power_override || (length(drained_humans) >= FULLPOWER_DRAINED_REQUIREMENT && bloodtotal >= FULLPOWER_BLOODTOTAL_REQUIREMENT))
		subclass.add_full_power_abilities(src)


/datum/antagonist/vampire/proc/announce_new_power(list/old_powers)
	for(var/p in powers)
		if(!(p in old_powers))
			if(istype(p, /obj/effect/proc_holder/spell))
				var/obj/effect/proc_holder/spell/power = p
				to_chat(owner.current, span_boldnotice("[power.gain_desc]"))

			else if(istype(p, /datum/vampire_passive))
				var/datum/vampire_passive/power = p
				to_chat(owner.current, span_boldnotice("[power.gain_desc]"))


/datum/antagonist/vampire/proc/check_sun()
	var/ax = owner.current.x
	var/ay = owner.current.y

	for(var/i = 1 to 20)
		ax += SSsun.dx
		ay += SSsun.dy

		var/turf/T = locate(round(ax, 0.5), round(ay, 0.5), owner.current.z)

		if(!T)
			return

		if(T.x == 1 || T.x == world.maxx || T.y == 1 || T.y == world.maxy)
			break

		if(T.density)
			return

	if(bloodusable >= 10)	//burn through your blood to tank the light for a little while
		to_chat(owner.current, span_warning("The starlight saps your strength!"))
		bloodusable -= 10
		vamp_burn(10)

	else		//You're in trouble, get out of the sun NOW
		to_chat(owner.current, span_userdanger("Your body is turning to ash, get out of the light now!"))
		owner.current.adjustCloneLoss(10)	//I'm melting!
		vamp_burn(85)
		if(owner.current.cloneloss >= 100)
			owner.current.dust()


/datum/antagonist/vampire/proc/vamp_burn(burn_chance)
	if(prob(burn_chance) && owner.current.health >= 50)
		switch(owner.current.health)
			if(75 to 100)
				to_chat(owner.current, span_warning("Your skin flakes away..."))
			if(50 to 75)
				to_chat(owner.current, span_warning("Your skin sizzles!"))
		owner.current.adjustFireLoss(3)

	else if(owner.current.health < 50)
		if(!owner.current.on_fire)
			to_chat(owner.current, span_danger("Your skin catches fire!"))
			owner.current.emote("scream")
		else
			to_chat(owner.current, span_danger("You continue to burn!"))
		owner.current.adjust_fire_stacks(5)
		owner.current.IgniteMob()


/datum/antagonist/vampire/proc/handle_vampire()
	if(owner.current.hud_used)
		var/datum/hud/hud = owner.current.hud_used
		if(!hud.vampire_blood_display)
			hud.vampire_blood_display = new /obj/screen()
			hud.vampire_blood_display.name = "Usable Blood"
			hud.vampire_blood_display.icon_state = "blood_display"
			hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
			hud.static_inventory += hud.vampire_blood_display
			hud.show_hud(hud.hud_version)
		hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#ce0202'>[bloodusable]</font></div>"

	handle_vampire_cloak()
	if(isspaceturf(get_turf(owner.current)))
		check_sun()

	if(is_type_in_typecache(get_area(owner.current), GLOB.holy_areas) && !get_ability(/datum/vampire_passive/full) && bloodtotal > 0)
		vamp_burn(7)

	nullified = max(0, nullified - 2)


/datum/antagonist/vampire/proc/handle_vampire_cloak()
	if(!ishuman(owner.current))
		animate(owner.current, time = 5, alpha = 255)
		return
	var/turf/simulated/owner_turf = get_turf(owner.current)
	var/light_available = owner_turf.get_lumcount() * 10

	if(!istype(owner_turf))
		return

	if(!iscloaking || owner.current.on_fire)
		animate(owner.current, time = 5, alpha = 255)
		REMOVE_TRAIT(owner.current, TRAIT_GOTTAGONOTSOFAST, VAMPIRE_TRAIT)
		return

	if(light_available <= 2)
		animate(owner.current, time = 5, alpha = 38)	// round(255 * 0.15)
		ADD_TRAIT(owner.current, TRAIT_GOTTAGONOTSOFAST, VAMPIRE_TRAIT)
		return

	REMOVE_TRAIT(owner.current, TRAIT_GOTTAGONOTSOFAST, VAMPIRE_TRAIT)
	animate(owner.current, time = 5, alpha = 204) // 255 * 0.80


/datum/antagonist/vampire/vv_edit_var(var_name, var_value)
	. = ..()
	check_vampire_upgrade(TRUE)


/datum/hud/proc/remove_vampire_hud()
	static_inventory -= vampire_blood_display
	QDEL_NULL(vampire_blood_display)


/datum/antagonist/vampire/proc/adjust_nullification(base, extra)
	// First hit should give full nullification, while subsequent hits increase the value slower
	nullified = clamp(nullified + extra, base, VAMPIRE_NULLIFICATION_CAP)


/**
 * Takes any datum `source` and checks it for vampire datum.
 */
/proc/isvampire(datum/source)
	if(!source)
		return FALSE

	if(!has_variable(source, "mind"))
		if(has_variable(source, "antag_datums"))
			var/datum/mind/our_mind = source
			return our_mind.has_antag_datum(/datum/antagonist/vampire) || our_mind.has_antag_datum(/datum/antagonist/goon_vampire)

		return FALSE

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/vampire) || mind_holder.mind.has_antag_datum(/datum/antagonist/goon_vampire)


/**
 * Takes any datum `source` and checks it for vampire thrall datum.
 */
/proc/isvampirethrall(datum/source)
	if(!source)
		return FALSE

	if(!has_variable(source, "mind"))
		if(has_variable(source, "antag_datums"))
			var/datum/mind/our_mind = source
			return our_mind.has_antag_datum(/datum/antagonist/mindslave/thrall) || our_mind.has_antag_datum(/datum/antagonist/mindslave/goon_thrall)

		return FALSE

	if(!isliving(source))
		return FALSE

	var/mob/living/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/mindslave/thrall) || mind_holder.mind.has_antag_datum(/datum/antagonist/mindslave/goon_thrall)


/datum/antagonist/mindslave/thrall
	name = "Vampire Thrall"
	antag_hud_type = ANTAG_HUD_VAMPIRE
	antag_hud_name = "vampthrall"
	master_hud_icon = "vampire"


/datum/antagonist/mindslave/thrall/add_owner_to_gamemode()
	SSticker.mode.vampire_enthralled += owner


/datum/antagonist/mindslave/thrall/remove_owner_from_gamemode()
	SSticker.mode.vampire_enthralled -= owner


/datum/antagonist/mindslave/thrall/apply_innate_effects(mob/living/mob_override)
	mob_override = ..()
	var/datum/mind/M = mob_override.mind
	M.AddSpell(new /obj/effect/proc_holder/spell/vampire/thrall_commune)


/datum/antagonist/mindslave/thrall/remove_innate_effects(mob/living/mob_override)
	mob_override = ..()
	var/datum/mind/M = mob_override.mind
	M.RemoveSpell(/obj/effect/proc_holder/spell/vampire/thrall_commune)

