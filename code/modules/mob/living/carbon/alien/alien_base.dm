/mob/living/carbon/alien
	name = "alien"
	voice_name = "alien"
	speak_emote = list("hisses")
	bubble_icon = "alien"
	icon = 'icons/mob/alien.dmi'
	gender = NEUTER
	faction = list("alien")

	var/nightvision = TRUE
	see_in_dark = 4

	var/obj/item/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = FALSE
	var/move_delay_add = 0 // movement delay to add

	status_flags = CANPARALYSE|CANPUSH
	var/heal_rate = 5
	var/loudspeaker = FALSE
	var/heat_protection = 0.5
	var/leaping = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	var/death_message = "lets out a waning guttural screech, green blood bubbling from its maw..."
	var/death_sound = 'sound/voice/hiss6.ogg'
	ignore_generic_organs = TRUE
	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/alien

/mob/living/carbon/alien/Initialize(mapload)
	. = ..()
	create_reagents(1000)

	for(var/organ_path in get_caste_organs())
		var/obj/item/organ/internal/organ = new organ_path()
		organ.insert(src)

/// returns the list of type paths of the organs that we need to insert into
/// this particular xeno upon its creation
/mob/living/carbon/alien/proc/get_caste_organs()
	RETURN_TYPE(/list/obj/item/organ/internal)
	return list(
		/obj/item/organ/internal/brain/xeno,
		/obj/item/organ/internal/alien/hivenode,
		/obj/item/organ/internal/ears
	)

/mob/living/carbon/alien/get_default_language()
	if(default_language)
		return default_language
	return GLOB.all_languages["Xenomorph"]

/mob/living/carbon/alien/say_quote(message, datum/language/speaking = null)
	var/speech_verb = "hisses"
	var/ending = copytext(message, length(message))

	if(speaking && (speaking.name != "Galactic Common")) //this is so adminbooze xenos speaking common have their custom verbs,
		speech_verb = speaking.get_spoken_verb(ending)          //and use normal verbs for their own languages and non-common languages
	else
		if(ending == "!")
			speech_verb = "roars"
		else if(ending== "?")
			speech_verb = "hisses curiously"
	return speech_verb


/mob/living/carbon/alien/adjustToxLoss(amount)
	return STATUS_UPDATE_NONE

/mob/living/carbon/alien/adjustFireLoss(amount) // Weak to Fire
	if(amount > 0)
		return ..(amount * 1.5)
	else
		return ..(amount)


/mob/living/carbon/alien/check_eye_prot()
	return 2

/mob/living/carbon/alien/handle_environment(datum/gas_mixture/readonly_environment)
	if(!readonly_environment)
		return

	var/loc_temp = get_temperature(readonly_environment)

	if(!on_fire) // If you're on fire, ignore local air temperature
		if(loc_temp > bodytemperature)
			//Place is hotter than we are
			var/thermal_protection = heat_protection //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(thermal_protection < 1)
				bodytemperature += (1-thermal_protection) * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)
		else
			bodytemperature += 1 * ((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR)
		//	bodytemperature -= max((loc_temp - bodytemperature / BODYTEMP_AUTORECOVERY_DIVISOR), BODYTEMP_AUTORECOVERY_MINIMUM)

	// +/- 50 degrees from 310.15K is the 'safe' zone, where no damage is dealt.
	if(bodytemperature > 360.15)
		//Body temperature is too hot.
		throw_alert("alien_fire", /atom/movable/screen/alert/alien_fire)
		switch(bodytemperature)
			if(360 to 400)
				apply_damage(HEAT_DAMAGE_LEVEL_1, BURN)
			if(400 to 460)
				apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
			if(460 to INFINITY)
				if(on_fire)
					apply_damage(HEAT_DAMAGE_LEVEL_3, BURN)
				else
					apply_damage(HEAT_DAMAGE_LEVEL_2, BURN)
	else
		clear_alert("alien_fire")

/mob/living/carbon/alien/IsAdvancedToolUser()
	return has_fine_manipulation

/mob/living/carbon/alien/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Intent:", "[a_intent]")
	status_tab_data[++status_tab_data.len] = list("Move Mode:", "[m_intent]")

/mob/living/carbon/alien/SetStunned(amount, updating = TRUE, force = 0)
	..()
	if(!(status_flags & CANSTUN) && amount)
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 2), 10) // a maximum delay of 10

/mob/living/carbon/alien/movement_delay()
	. = ..()
	. += move_delay_add + GLOB.configuration.movement.alien_delay //move_delay_add is used to slow aliens with stuns

/mob/living/carbon/alien/getDNA()
	return null

/mob/living/carbon/alien/setDNA()
	return

/mob/living/carbon/alien/assess_threat(mob/living/simple_animal/bot/secbot/judgebot, lasercolor)
	if(judgebot.emagged)
		return 10 //Everyone is a criminal!
	var/threatcount = 0

	//Securitrons can't identify aliens
	if(!lasercolor && judgebot.idcheck)
		threatcount += 4

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if((istype(r_hand,/obj/item/gun/energy/laser/tag/red)) || (istype(l_hand,/obj/item/gun/energy/laser/tag/red)))
				threatcount += 4

		if(lasercolor == "r")
			if((istype(r_hand,/obj/item/gun/energy/laser/tag/blue)) || (istype(l_hand,/obj/item/gun/energy/laser/tag/blue)))
				threatcount += 4

		return threatcount

	//Check for weapons
	if(judgebot.weapons_check)
		if(judgebot.check_for_weapons(l_hand))
			threatcount += 4
		if(judgebot.check_for_weapons(r_hand))
			threatcount += 4

	//Mindshield implants imply trustworthyness
	if(ismindshielded(src))
		threatcount -= 1

	return threatcount

/mob/living/carbon/alien/proc/deathrattle()
	var/alien_message = deathrattle_message()
	for(var/mob/living/carbon/alien/M in GLOB.player_list)
		to_chat(M, alien_message)

/mob/living/carbon/alien/proc/deathrattle_message()
	return "<i><span class='alien'>The hivemind echoes: [name] has been slain!</span></i>"

/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/alien/proc/AddInfectionImages()
	if(!client)
		return
	for(var/mob/living/C in GLOB.mob_list)
		if(HAS_TRAIT(C, TRAIT_XENO_HOST))
			var/obj/item/organ/internal/body_egg/alien_embryo/A = C.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo)
			if(!A)
				continue
			var/I = image('icons/mob/alien.dmi', loc = C, icon_state = "infected[A.stage]")
			client.images += I

/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/alien/proc/RemoveInfectionImages()
	if(!client)
		return
	for(var/image/I in client.images)
		if(dd_hasprefix_case(I.icon_state, "infected"))
			qdel(I)

/mob/living/carbon/alien/canBeHandcuffed()
	return TRUE

/* Although this is on the carbon level, we only want this proc'ing for aliens that do have this hud. Only humanoid aliens do at the moment, so we have a check
and carry the owner just to make sure*/
/mob/living/carbon/proc/update_plasma_display(mob/owner)
	for(var/datum/action/spell_action/action in actions)
		action.build_all_button_icons()
	if(!hud_used || !isalien(owner)) //clientless aliens or non aliens
		return
	hud_used.alien_plasma_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font face='Small Fonts' color='magenta'>[get_plasma()]</font></div>"
	hud_used.alien_plasma_display.maptext_x = -3

/mob/living/carbon/alien/larva/update_plasma_display()
	return

/mob/living/carbon/alien/can_use_vents()
	return

/mob/living/carbon/alien/getTrail()
	if(getBruteLoss() < 200)
		return pick("xltrails_1", "xltrails_2")
	else
		return pick("xttrails_1", "xttrails_2")

/mob/living/carbon/alien/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		grant_death_vision()
		return

	see_invisible = initial(see_invisible)
	sight = SEE_MOBS
	if(nightvision)
		see_in_dark = 8
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	else
		see_in_dark = initial(see_in_dark)
		lighting_alpha = initial(lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/living/carbon/alien/on_lying_down(new_lying_angle)
	. = ..()
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, LYING_DOWN_TRAIT) //Xenos can't crawl

/mob/living/carbon/alien/update_stat(reason)
	if(health <= HEALTH_THRESHOLD_CRIT && stat == CONSCIOUS)
		KnockOut()
	return ..()

/mob/living/carbon/alien/plushify(plushie_override, curse_time)
	. = ..(/obj/item/toy/plushie/face_hugger, curse_time)
