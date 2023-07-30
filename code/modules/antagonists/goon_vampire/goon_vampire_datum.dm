/datum/antagonist/goon_vampire
	name = "Goon-Vampire"
	antag_hud_type = ANTAG_HUD_VAMPIRE
	antag_hud_name = "hudvampire"
	special_role = SPECIAL_ROLE_VAMPIRE
	/// Total blood drained by vampire over round.
	var/bloodtotal = 0
	/// Current amount of blood.
	var/bloodusable = 0
	/// Handles the vampire cloak toggle.
	var/iscloaking = FALSE
	/// List of available powers and passives.
	var/list/powers = list()
	/// Who the vampire is draining of blood.
	var/mob/living/carbon/human/draining
	/// Nullrod makes them useless for a short while.
	var/nullified = 0
	/// List of the peoples UIDs that we have drained, and how much blood from each one.
	var/list/drained_humans = list()
	/// A list of powers that vampires unlock.
	var/list/upgrade_tiers = list(
		/obj/effect/proc_holder/spell/goon_vampire/self/rejuvenate = 0,
		/obj/effect/proc_holder/spell/goon_vampire/targetted/hypnotise = 0,
		/obj/effect/proc_holder/spell/goon_vampire/glare = 0,
		/datum/goon_vampire_passive/vision = 100,
		/obj/effect/proc_holder/spell/goon_vampire/self/shapeshift = 100,
		/obj/effect/proc_holder/spell/goon_vampire/self/cloak = 150,
		/obj/effect/proc_holder/spell/goon_vampire/targetted/disease = 150,
		/obj/effect/proc_holder/spell/goon_vampire/bats = 200,
		/obj/effect/proc_holder/spell/goon_vampire/self/screech = 200,
		/datum/goon_vampire_passive/regen = 200,
		/obj/effect/proc_holder/spell/goon_vampire/shadowstep = 250,
		/obj/effect/proc_holder/spell/goon_vampire/self/jaunt = 300,
		/obj/effect/proc_holder/spell/goon_vampire/targetted/enthrall = 300,
		/datum/goon_vampire_passive/full = 500)


/datum/antagonist/goon_vampire/Destroy(force, ...)
	owner.current.create_log(CONVERSION_LOG, "De-goon-vampired")
	draining = null
	return ..()


/datum/antagonist/goon_vampire/add_owner_to_gamemode()
	SSticker.mode.goon_vampires += owner


/datum/antagonist/goon_vampire/remove_owner_from_gamemode()
	SSticker.mode.goon_vampires -= owner


/datum/antagonist/goon_vampire/greet()
	var/dat
	SEND_SOUND(owner.current, 'sound/ambience/antag/vampalert.ogg')
	dat = "<span class='danger'>Вы — вампир!</span><br>"
	dat += {"Чтобы укусить кого-то, нацельтесь в голову, выберите намерение вреда (4) и ударьте пустой рукой. Пейте кровь, чтобы получать новые силы.<br>Вы уязвимы перед святостью и звёздным светом. Не выходите в космос, избегайте священника, церкви и, особенно, святой воды."}
	to_chat(owner.current, dat)


/datum/antagonist/goon_vampire/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("Вы превратились в робота! Вы чувствуете как вампирские силы исчезают…"))
	else
		to_chat(owner.current, span_userdanger("Ваш разум очищен! Вы больше не вампир."))


/datum/antagonist/goon_vampire/give_objectives()
	add_objective(/datum/objective/blood)
	add_objective(/datum/objective/maroon)
	add_objective(/datum/objective/steal)

	if(prob(20)) // 20% chance of getting survive. 80% chance of getting escape.
		add_objective(/datum/objective/survive)
	else
		add_objective(/datum/objective/escape)


/datum/antagonist/goon_vampire/apply_innate_effects(mob/living/mob_override)
	mob_override = ..()
	if(!owner.som) //thralls and mindslaves
		owner.som = new()
		owner.som.masters += owner

	mob_override.dna.species.hunger_type = "vampire"
	mob_override.dna.species.hunger_icon = 'icons/mob/screen_hunger_vampire.dmi'
	check_vampire_upgrade(FALSE)


/datum/antagonist/goon_vampire/remove_innate_effects(mob/living/mob_override)
	mob_override = ..()
	remove_all_powers()
	var/datum/hud/hud = mob_override.hud_used
	if(hud?.vampire_blood_display)
		hud.remove_vampire_hud()
	mob_override.dna.species.hunger_type = initial(mob_override.dna.species.hunger_type)
	mob_override.dna.species.hunger_icon = initial(mob_override.dna.species.hunger_icon)
	animate(mob_override, alpha = 255)

	if(mob_override.mind.som)
		var/datum/mindslaves/slaved = mob_override.mind.som
		slaved.masters -= mob_override.mind
		slaved.serv -= mob_override.mind
		slaved.leave_serv_hud(mob_override.mind)
		mob_override.mind.som = null


/datum/antagonist/goon_vampire/proc/handle_vampire()
	if(owner.current.hud_used)
		var/datum/hud/hud = owner.current.hud_used
		if(!hud.vampire_blood_display)
			hud.vampire_blood_display = new /obj/screen()
			hud.vampire_blood_display.name = "Доступная кровь"
			hud.vampire_blood_display.icon_state = "blood_display"
			hud.vampire_blood_display.screen_loc = "WEST:6,CENTER-1:15"
			hud.static_inventory += hud.vampire_blood_display
			hud.show_hud(hud.hud_version)
		hud.vampire_blood_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#ce0202'>[bloodusable]</font></div>"

	handle_vampire_cloak()

	if(isspaceturf(get_turf(owner.current)))
		check_sun()

	if(is_type_in_typecache(get_area(owner.current), GLOB.holy_areas) && !get_ability(/datum/goon_vampire_passive/full))
		vamp_burn(7)

	nullified = max(0, nullified - 1)


/datum/antagonist/goon_vampire/proc/handle_vampire_cloak()
	if(!ishuman(owner.current))
		animate(owner.current, time = 5, alpha = 255)
		return
	var/turf/simulated/T = get_turf(owner.current)
	var/light_available = T.get_lumcount(0.5) * 10

	if(!istype(T))
		return

	if(!iscloaking || owner.current.on_fire)
		animate(owner.current, time = 5, alpha = 255)
		return

	if(light_available <= 2)
		animate(owner.current, time = 5, alpha = 38) // round(255 * 0.15)
		return

	animate(owner.current, time = 5, alpha = 204) // 255 * 0.80


/datum/antagonist/goon_vampire/proc/vamp_burn(burn_chance)
	if(prob(burn_chance) && owner.current.health >= 50)
		switch(owner.current.health)
			if(75 to 100)
				to_chat(owner.current, span_warning("Ваша кожа дымится…"))
			if(50 to 75)
				to_chat(owner.current, span_warning("Ваша кожа шипит!"))
		owner.current.adjustFireLoss(3)
	else if(owner.current.health < 50)
		if(!owner.current.on_fire)
			to_chat(owner.current, span_danger("Ваша кожа загорается!"))
			owner.current.emote("scream")
		else
			to_chat(owner.current, span_danger("Вы продолжаете гореть!"))
		owner.current.adjust_fire_stacks(5)
		owner.current.IgniteMob()


/datum/antagonist/goon_vampire/proc/check_sun()
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
		to_chat(owner.current, span_warning("Свет звёзд жжётся и истощает ваши силы!"))
		bloodusable -= 10
		vamp_burn(10)
	else		//You're in trouble, get out of the sun NOW
		to_chat(owner.current, span_userdanger("Ваше тело обугливается, превращаясь в пепел! Укройтесь от звёздного света!"))
		owner.current.adjustCloneLoss(10)	//I'm melting!
		vamp_burn(85)


/datum/antagonist/goon_vampire/proc/remove_all_powers()
	for(var/power in powers)
		remove_ability(power)


/datum/antagonist/goon_vampire/proc/check_vampire_upgrade(announce = TRUE)
	var/list/old_powers = powers.Copy()

	for(var/ptype in upgrade_tiers)
		var/level = upgrade_tiers[ptype]
		if(bloodtotal >= level)
			var/obj/effect/proc_holder/spell/goon_vampire/spell = add_ability(ptype)
			if(spell)
				for(var/datum/action/spell_action/action in owner.current.actions)
					action.UpdateButtonIcon()

	if(announce)
		announce_new_power(old_powers)


/datum/antagonist/goon_vampire/proc/announce_new_power(list/old_powers)
	for(var/p in powers)
		if(!(p in old_powers))
			if(istype(p, /obj/effect/proc_holder/spell/goon_vampire))
				var/obj/effect/proc_holder/spell/goon_vampire/power = p
				to_chat(owner.current, span_boldnotice("[power.gain_desc]"))
			else if(istype(p, /datum/goon_vampire_passive))
				var/datum/goon_vampire_passive/power = p
				to_chat(owner.current, span_boldnotice("[power.gain_desc]"))


/datum/antagonist/goon_vampire/proc/get_ability(path)
	for(var/datum/power as anything in powers)
		if(power.type == path)
			return power
	return null


/datum/antagonist/goon_vampire/proc/add_ability(path)
	if(!get_ability(path))
		return force_add_ability(path)


/datum/antagonist/goon_vampire/proc/force_add_ability(path)
	var/spell = new path(owner)
	if(istype(spell, /obj/effect/proc_holder/spell/goon_vampire))
		owner.AddSpell(spell)

	powers += spell
	owner.current.update_sight()
	return spell


/datum/antagonist/goon_vampire/proc/remove_ability(ability)
	if(ability && (ability in powers))
		powers -= ability
		owner.spell_list.Remove(ability)
		qdel(ability)
		owner.current.update_sight()


/datum/antagonist/goon_vampire/proc/handle_bloodsucking(mob/living/carbon/human/H)
	draining = H
	var/unique_suck_id = H.UID()
	var/blood = 0
	var/blood_limit_exceeded = FALSE
	var/old_bloodtotal = 0 //used to see if we increased our blood total
	var/old_bloodusable = 0 //used to see if we increased our blood usable
	var/blood_volume_warning = 9999 //Blood volume threshold for warnings
	if(owner.current.is_muzzled())
		var/mob/living/carbon/mask_owner = owner
		to_chat(owner.current, span_warning("[mask_owner.wear_mask] мешает вам укусить [H]!"))
		draining = null
		return
	add_attack_logs(owner, H, "vampirebit & is draining their blood.", ATKLOG_ALMOSTALL)
	owner.current.visible_message(span_danger("[owner.current] грубо хватает шею [H] и вонзает в неё клыки!"), \
								span_danger("Вы вонзаете клыки в шею [H] и начинаете высасывать [genderize_ru(H.gender, "его", "её", "его", "их")] кровь."), \
								span_italics("Вы слышите тихий звук прокола и влажные хлюпающие звуки."))
	if(!iscarbon(owner.current))
		H.LAssailant = null
	else
		H.LAssailant = owner.current
	while(do_mob(owner.current, H, 5 SECONDS))
		if(!isvampire(owner))
			to_chat(owner.current, span_userdanger("Ваши клыки исчезают!"))
			return
		old_bloodtotal = bloodtotal
		old_bloodusable = bloodusable
		if(unique_suck_id in drained_humans)
			if(drained_humans[unique_suck_id] >= BLOOD_DRAIN_LIMIT)
				to_chat(owner.current, span_warning("Вы поглотили всю жизненную эссенцию [H], дальнейшее питьё крови будет только утолять голод"))
				blood_limit_exceeded = TRUE

		if(H.stat < DEAD)
			if(H.ckey || H.player_ghosted) //Requires ckey regardless if monkey or humanoid, or the body has been ghosted before it died
				blood = min(20, H.blood_volume) / 2	// if they have less than 20 blood, give them the remnant else they get 20 blood
				if(!blood_limit_exceeded)
					bloodtotal += blood	//divide by 2 to counted the double suction since removing cloneloss -Melandor0
					bloodusable += blood
		else
			if(H.ckey || H.player_ghosted)
				blood = min(10, H.blood_volume) / 2	// The dead only give 5 blood
				if(!blood_limit_exceeded)
					bloodtotal += blood

		if(old_bloodtotal != bloodtotal)
			if(H.ckey || H.player_ghosted) // Requires ckey regardless if monkey or human, and has not ghosted, otherwise no power
				to_chat(owner.current, span_boldnotice("Вы накопили [bloodtotal] единиц[declension_ru(bloodtotal, "у", "ы", "")] крови[bloodusable != old_bloodusable ? ", и теперь вам доступно [bloodusable] единиц[declension_ru(bloodusable, "а", "ы", "")] крови" : ""]."))

		check_vampire_upgrade()
		H.blood_volume = max(H.blood_volume - 25, 0)
		if(!(unique_suck_id in drained_humans))
			drained_humans[unique_suck_id] = 0

		if(drained_humans[unique_suck_id] < BLOOD_DRAIN_LIMIT)
			drained_humans[unique_suck_id] += blood

		//Blood level warnings (Code 'borrowed' from Fulp)
		if(H.blood_volume)
			if(H.blood_volume <= BLOOD_VOLUME_BAD && blood_volume_warning > BLOOD_VOLUME_BAD)
				to_chat(owner.current, span_danger("У вашей жертвы остаётся опасно мало крови!"))
			else if(H.blood_volume <= BLOOD_VOLUME_OKAY && blood_volume_warning > BLOOD_VOLUME_OKAY)
				to_chat(owner.current, span_warning("У вашей жертвы остаётся тревожно мало крови."))
			blood_volume_warning = H.blood_volume //Set to blood volume, so that you only get the message once
		else
			to_chat(owner.current, span_warning("Вы выпили свою жертву досуха!"))
			break

		if(ishuman(owner.current))
			var/mob/living/carbon/human/V = owner.current
			if(!H.ckey && !H.player_ghosted)//Only runs if there is no ckey and the body has not being ghosted while alive
				to_chat(V, span_boldnotice("Питьё крови у [H] насыщает вас, но доступной крови от этого вы не получаете."))
				V.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, V.nutrition + 5))
			else
				V.set_nutrition(min(NUTRITION_LEVEL_WELL_FED, V.nutrition + (blood / 2)))

	draining = null
	to_chat(owner.current, span_notice("Вы прекращаете пить кровь [H.name]."))


/datum/antagonist/goon_vampire/vv_edit_var(var_name, var_value)
	. = ..()
	check_vampire_upgrade(TRUE)


/datum/antagonist/mindslave/goon_thrall
	name = "Vampire Thrall"
	antag_hud_type = ANTAG_HUD_VAMPIRE
	antag_hud_name = "vampthrall"
	master_hud_icon = "vampire"


/datum/antagonist/mindslave/goon_thrall/add_owner_to_gamemode()
	SSticker.mode.goon_vampire_enthralled += owner


/datum/antagonist/mindslave/goon_thrall/remove_owner_from_gamemode()
	SSticker.mode.goon_vampire_enthralled -= owner

