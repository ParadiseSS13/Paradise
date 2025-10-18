RESTRICT_TYPE(/datum/antagonist/vampire)

/datum/antagonist/vampire
	name = "Vampire"
	job_rank = ROLE_VAMPIRE
	special_role = SPECIAL_ROLE_VAMPIRE
	antag_hud_type = ANTAG_HUD_VAMPIRE
	antag_hud_name = "hudvampire"
	wiki_page_name = "Vampire"
	var/bloodtotal = 0
	var/bloodusable = 0
	/// what vampire subclass the vampire is.
	var/datum/vampire_subclass/subclass
	/// handles the vampire cloak toggle
	var/iscloaking = FALSE
	/// list of available powers and passives
	var/list/powers = list()
	/// who the vampire is draining of blood
	var/mob/living/carbon/human/draining
	/// Nullrods and holywater make their abilities cost more
	var/nullified = 0
	/// a list of powers that all vampires unlock and at what blood level they unlock them, the rest of their powers are found in the vampire_subclass datum
	var/list/upgrade_tiers = list(/datum/spell/vampire/self/rejuvenate = 0,
									/datum/spell/vampire/glare = 0,
									/datum/vampire_passive/vision = 100,
									/datum/spell/vampire/self/specialize = 150,
									/datum/spell/vampire/self/exfiltrate = 150,
									/datum/vampire_passive/regen = 200,
									/datum/vampire_passive/vision/advanced = 500)

	/// list of the peoples UIDs that we have drained, and how much blood from each one
	var/list/drained_humans = list()
	blurb_text_color = COLOR_RED
	blurb_r = 255
	blurb_g = 221
	blurb_b = 138
	blurb_a = 1
	boss_title = "Master Vampire"

/datum/antagonist/vampire/Destroy(force, ...)
	draining = null
	QDEL_NULL(subclass)
	return ..()

/datum/antagonist/vampire/detach_from_owner()
	owner.current.create_log(CONVERSION_LOG, "De-vampired")
	if(ishuman(owner.current))
		var/mob/living/carbon/human/human_owner = owner.current
		human_owner.set_alpha_tracking(ALPHA_VISIBLE, src)
	return ..()

/datum/antagonist/vampire/add_owner_to_gamemode()
	SSticker.mode.vampires += owner

/datum/antagonist/vampire/remove_owner_from_gamemode()
	SSticker.mode.vampires -= owner

/datum/antagonist/vampire/proc/adjust_nullification(base, extra)
	// First hit should give full nullification, while subsequent hits increase the value slower
	nullified = clamp(nullified + extra, base, VAMPIRE_NULLIFICATION_CAP)

/datum/antagonist/vampire/proc/force_add_ability(path)
	var/spell = new path(owner)
	powers += spell
	if(istype(spell, /datum/spell))
		owner.AddSpell(spell)
	if(istype(spell, /datum/vampire_passive))
		var/datum/vampire_passive/passive = spell
		passive.owner = owner.current
		passive.on_apply(src)

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

/datum/antagonist/vampire/remove_innate_effects(mob/living/mob_override)
	mob_override = ..()
	remove_all_powers()
	var/datum/hud/hud = mob_override.hud_used
	if(hud?.vampire_blood_display)
		hud.remove_vampire_hud()
	mob_override.dna?.species.hunger_icon = initial(mob_override.dna.species.hunger_icon)
	owner.current.alpha = 255
	REMOVE_TRAITS_IN(owner.current, "vampire")
	UnregisterSignal(owner, COMSIG_ATOM_HOLY_ATTACK)

/datum/antagonist/vampire/exfiltrate(mob/living/carbon/human/extractor, obj/item/radio/radio)
	remove_all_powers()
	// Remove thralls
	if(istype(subclass, SUBCLASS_DANTALION))
		var/list/thralls = SSticker.mode.vampire_enthralled
		for(var/datum/mind/possible_thrall in thralls)
			for(var/datum/antagonist/slavetag in possible_thrall.antag_datums)
				if(!istype(slavetag, /datum/antagonist/mindslave))
					continue
				var/datum/antagonist/mindslave/slave = slavetag
				if(slave.master == extractor.mind)
					possible_thrall.remove_antag_datum(/datum/antagonist/mindslave/thrall)

	if(isplasmaman(extractor))
		extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/vampire/plasmaman)
	else
		extractor.equipOutfit(/datum/outfit/admin/ghostbar_antag/vampire)
	radio.autosay("<b>--ZZZT!- Wonderfully done, [extractor.real_name]. Welcome to -^%&!-ZZT!-</b>", "Ancient Vampire", "Security")
	SSblackbox.record_feedback("tally", "successful_extraction", 1, "Vampire")

#define BLOOD_GAINED_MODIFIER 0.5

/datum/antagonist/vampire/proc/handle_bloodsucking(mob/living/carbon/human/H, suck_rate = 5 SECONDS)
	draining = H
	var/unique_suck_id = H.UID()
	var/blood = 0
	var/blood_volume_warning = 9999 //Blood volume threshold for warnings
	if(owner.current.is_muzzled())
		to_chat(owner.current, "<span class='warning'>[owner.current.wear_mask] prevents you from biting [H]!</span>")
		draining = null
		return
	add_attack_logs(owner.current, H, "vampirebit & is draining their blood.", ATKLOG_ALMOSTALL)
	owner.current.visible_message("<span class='danger'>[owner.current] grabs [H]'s neck harshly and sinks in [owner.current.p_their()] fangs!</span>", "<span class='danger'>You sink your fangs into [H] and begin to drain [H.p_their()] blood.</span>", "<span class='notice'>You hear a soft puncture and a wet sucking noise.</span>")
	while(do_mob(owner.current, H, suck_rate, hidden = TRUE))
		owner.current.do_attack_animation(H, ATTACK_EFFECT_BITE)
		if(unique_suck_id in drained_humans)
			if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
				to_chat(owner.current, "<span class='warning'>You have drained most of the life force from [H]'s blood, and you will get no more useable blood from them!</span>")
				H.blood_volume = max(H.blood_volume - 25, 0)
				owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + 5))
				continue

		if((H.stat != DEAD || H.has_status_effect(STATUS_EFFECT_RECENTLY_SUCCUMBED)) && !HAS_MIND_TRAIT(H, TRAIT_XENOBIO_SPAWNED_HUMAN))
			if(H.ckey || H.player_ghosted) //Requires ckey regardless if monkey or humanoid, or the body has been ghosted before it died
				blood = min(20, H.blood_volume)
				adjust_blood(H, blood * BLOOD_GAINED_MODIFIER)
				to_chat(owner.current, "<span class='notice'><b>You have accumulated [bloodtotal] unit\s of blood, and have [bloodusable] left to use.</b></span>")
		H.blood_volume = max(H.blood_volume - 25, 0)
		//Blood level warnings (Code 'borrowed' from Fulp)
		if(H.blood_volume)
			if(H.blood_volume <= BLOOD_VOLUME_BAD && blood_volume_warning > BLOOD_VOLUME_BAD)
				to_chat(owner.current, "<span class='danger'>Your victim's blood volume is dangerously low.</span>")
			else if(H.blood_volume <= BLOOD_VOLUME_STABLE && blood_volume_warning > BLOOD_VOLUME_STABLE)
				to_chat(owner.current, "<span class='warning'>Your victim's blood is at an unsafe level.</span>")
			blood_volume_warning = H.blood_volume //Set to blood volume, so that you only get the message once
		else
			to_chat(owner.current, "<span class='warning'>You have bled your victim dry!</span>")
			break
		if((!H.ckey && !H.player_ghosted) || HAS_MIND_TRAIT(H, TRAIT_XENOBIO_SPAWNED_HUMAN)) //Only runs if there is no ckey and the body has not being ghosted while alive, also runs if the victim is an evolved caterpillar or diona nymph.
			to_chat(owner.current, "<span class='notice'><b>Feeding on [H] reduces your thirst, but you get no usable blood from them.</b></span>")
			owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + 5))
		else
			owner.current.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, owner.current.nutrition + (blood / 2)))

	draining = null
	to_chat(owner.current, "<span class='notice'>You stop draining [H.name] of blood.</span>")

#undef BLOOD_GAINED_MODIFIER

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
 * * give_specialize_power - if the [specialize][/datum/spell/vampire/self/specialize] power should be given back or not
 */
/datum/antagonist/vampire/proc/clear_subclass(give_specialize_power = TRUE)
	if(give_specialize_power)
		// Choosing a subclass in the first place removes this from `upgrade_tiers`, so add it back if needed.
		upgrade_tiers[/datum/spell/vampire/self/specialize] = 150
	remove_all_powers()
	QDEL_NULL(subclass)
	check_vampire_upgrade()

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
			if(istype(p, /datum/spell))
				var/datum/spell/power = p
				to_chat(owner.current, "<span class='boldnotice'>[power.gain_desc]</span>")
			else if(istype(p, /datum/vampire_passive))
				var/datum/vampire_passive/power = p
				to_chat(owner.current, "<span class='boldnotice'>[power.gain_desc]</span>")

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
		to_chat(owner.current, "<span class='biggerdanger'>The starlight saps your strength, you should get out of the starlight!</span>")
		subtract_usable_blood(10)
		vamp_burn(10)
	else		//You're in trouble, get out of the sun NOW
		to_chat(owner.current, "<span class='biggerdanger'>Your body is turning to ash, get out of the starlight NOW!</span>")
		owner.current.adjustCloneLoss(10)	//I'm melting!
		vamp_burn(85)
		if(owner.current.getCloneLoss() >= 100)
			owner.current.dust()

/datum/antagonist/vampire/proc/handle_vampire()
	if(owner.current.hud_used)
		var/datum/hud/hud = owner.current.hud_used
		if(!hud.vampire_blood_display)
			hud.vampire_blood_display = new /atom/movable/screen()
			hud.vampire_blood_display.name = "Usable Blood"
			hud.vampire_blood_display.icon_state = "blood_display"
			hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
			hud.static_inventory += hud.vampire_blood_display
			hud.show_hud(hud.hud_version)
		hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#ce0202'>[bloodusable]</font></div>"
	handle_vampire_cloak()
	if(isspaceturf(get_turf(owner.current)))
		check_sun()
	if(istype(get_area(owner.current), /area/station/service/chapel) && !get_ability(/datum/vampire_passive/full) && bloodtotal > 0)
		vamp_burn(7)
	nullified = max(0, nullified - 2)

/datum/antagonist/vampire/proc/handle_vampire_cloak()
	if(!ishuman(owner.current))
		owner.current.alpha = 255
		return
	var/mob/living/carbon/human/human_owner = owner.current
	var/turf/simulated/T = get_turf(human_owner)
	var/light_available = T.get_lumcount() * 10

	if(!istype(T))
		return

	if(!iscloaking || human_owner.on_fire)
		human_owner.set_alpha_tracking(ALPHA_VISIBLE, src)
		REMOVE_TRAIT(human_owner, TRAIT_GOTTAGONOTSOFAST, VAMPIRE_TRAIT)
		return

	if(light_available <= 2)
		human_owner.set_alpha_tracking(ALPHA_VISIBLE * 0.15, src)
		ADD_TRAIT(human_owner, TRAIT_GOTTAGONOTSOFAST, VAMPIRE_TRAIT)
		return

	REMOVE_TRAIT(human_owner, TRAIT_GOTTAGONOTSOFAST, VAMPIRE_TRAIT)
	human_owner.set_alpha_tracking(ALPHA_VISIBLE * 0.80, src)

/**
 * Handles unique drain ID checks and increases vampire's total and usable blood by blood_amount. Checks for ability upgrades.
 *
 * Arguments:
 ** C: victim [/mob/living/carbon] that is being drained form.
 ** blood_amount: amount of blood to add to vampire's usable and total pools.
 */
/datum/antagonist/vampire/proc/adjust_blood(mob/living/carbon/C, blood_amount = 0)
	if(C)
		var/unique_suck_id = C.UID()
		if(!(unique_suck_id in drained_humans))
			drained_humans[unique_suck_id] = 0
		if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
			return
		drained_humans[unique_suck_id] += blood_amount
	bloodtotal += blood_amount
	bloodusable += blood_amount
	check_vampire_upgrade(TRUE)
	for(var/datum/spell/S in powers)
		if(S.action)
			S.action.build_all_button_icons()

/**
 * Safely subtract vampire's bloodusable. Clamped between 0 and bloodtotal.
 *
 * Arguments:
 ** blood_amount: amount of blood to subtract.
 */
/datum/antagonist/vampire/proc/subtract_usable_blood(blood_amount)
	bloodusable = clamp(bloodusable - blood_amount, 0, bloodtotal)

/datum/antagonist/vampire/proc/vamp_burn(burn_chance)
	if(prob(burn_chance) && owner.current.health >= 50)
		switch(owner.current.health)
			if(75 to 100)
				to_chat(owner.current, "<span class='warning'>Your skin flakes away...</span>")
			if(50 to 75)
				to_chat(owner.current, "<span class='warning'>Your skin sizzles!</span>")
		owner.current.adjustFireLoss(3)
	else if(owner.current.health < 50)
		if(!owner.current.on_fire)
			to_chat(owner.current, "<span class='danger'>Your skin catches fire!</span>")
			owner.current.emote("scream")
		else
			to_chat(owner.current, "<span class='danger'>You continue to burn!</span>")
		owner.current.adjust_fire_stacks(5)
		owner.current.IgniteMob()

/datum/antagonist/vampire/vv_edit_var(var_name, var_value)
	. = ..()
	check_vampire_upgrade(TRUE)

/datum/antagonist/vampire/give_objectives()
	add_antag_objective(/datum/objective/blood)
	add_antag_objective(/datum/objective/assassinate)

	if(prob(5)) // 5% chance of getting protect. 95% chance of getting steal.
		add_antag_objective(/datum/objective/protect)
	else
		add_antag_objective(/datum/objective/steal)

	if(prob(20)) // 20% chance of getting survive. 80% chance of getting escape.
		add_antag_objective(/datum/objective/survive)
	else
		add_antag_objective(/datum/objective/escape)

/datum/antagonist/vampire/greet()
	var/list/messages = list()
	SEND_SOUND(owner.current, sound('sound/ambience/antag/vampalert.ogg'))
	messages.Add("<span class='danger'>You are a Vampire!</span><br>")
	messages.Add("To bite someone, target the head and use harm intent with an empty hand. Drink blood to gain new powers. \
		You are weak to holy things, starlight, and fire. Don't go into space and avoid the Chaplain, the chapel, and especially Holy Water.")
	return messages

/datum/antagonist/vampire/apply_innate_effects(mob/living/mob_override)
	mob_override = ..()
	if(!owner.som) //thralls and mindslaves
		owner.som = new()
		owner.som.masters += owner

	mob_override.dna?.species.hunger_icon = 'icons/mob/screen_hunger_vampire.dmi'
	check_vampire_upgrade(FALSE)
	RegisterSignal(mob_override, COMSIG_ATOM_HOLY_ATTACK, PROC_REF(holy_attack_reaction))

/datum/antagonist/vampire/proc/holy_attack_reaction(mob/target, obj/item/source, mob/user, antimagic_flags)
	SIGNAL_HANDLER // COMSIG_ATOM_HOLY_ATTACK
	if(!HAS_MIND_TRAIT(user, TRAIT_HOLY)) // Sec officer with a nullrod, or miner with a talisman, does not get to do this
		return
	if(!source.force) // Needs force to work.
		return
	var/bonus_force = 0
	if(istype(source, /obj/item/nullrod))
		var/obj/item/nullrod/N = source
		bonus_force = N.sanctify_force
	if(!get_ability(/datum/vampire_passive/full))
		to_chat(owner.current, "<span class='warning'>[source]'s power interferes with your own!</span>")
		adjust_nullification(30 + bonus_force, 15 + bonus_force)

/datum/antagonist/vampire/custom_blurb()
	return "On the date [GLOB.current_date_string], at [station_time_timestamp()],\n in the [station_name()], [get_area_name(owner.current, TRUE)]...\nThe hunt begins again..."
