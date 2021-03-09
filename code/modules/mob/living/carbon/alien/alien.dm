/mob/living/carbon/alien
	name = "alien"
	voice_name = "alien"
	speak_emote = list("hisses")
	bubble_icon = "alien"
	icon = 'icons/mob/alien.dmi'
	gender = NEUTER
	dna = null
	alien_talk_understand = TRUE

	var/nightvision = FALSE
	see_in_dark = 4

	var/obj/item/card/id/wear_id = null // Fix for station bounced radios -- Skie
	var/has_fine_manipulation = FALSE
	var/move_delay_add = FALSE // movement delay to add

	status_flags = CANPARALYSE|CANPUSH
	var/heal_rate = 5

	var/large = FALSE
	var/heat_protection = 0.5
	var/leaping = FALSE
	ventcrawler = 2
	var/list/alien_organs = list()
	var/death_message = "lets out a waning guttural screech, green blood bubbling from its maw..."
	var/death_sound = 'sound/voice/hiss6.ogg'

/mob/living/carbon/alien/New()
	..()
	create_reagents(1000)
	verbs += /mob/living/verb/mob_sleep
	verbs += /mob/living/verb/lay_down
	alien_organs += new /obj/item/organ/internal/brain/xeno
	alien_organs += new /obj/item/organ/internal/xenos/hivenode
	alien_organs += new /obj/item/organ/internal/ears
	for(var/obj/item/organ/internal/I in alien_organs)
		I.insert(src)

/mob/living/carbon/alien/get_default_language()
	if(default_language)
		return default_language
	return GLOB.all_languages["Xenomorph"]

/mob/living/carbon/alien/say_quote(var/message, var/datum/language/speaking = null)
	var/verb = "hisses"
	var/ending = copytext(message, length(message))

	if(speaking && (speaking.name != "Galactic Common")) //this is so adminbooze xenos speaking common have their custom verbs,
		verb = speaking.get_spoken_verb(ending)          //and use normal verbs for their own languages and non-common languages
	else
		if(ending=="!")
			verb = "roars"
		else if(ending=="?")
			verb = "hisses curiously"
	return verb


/mob/living/carbon/alien/adjustToxLoss(amount)
	return STATUS_UPDATE_NONE

/mob/living/carbon/alien/adjustFireLoss(amount) // Weak to Fire
	if(amount > 0)
		return ..(amount * 2)
	else
		return ..(amount)


/mob/living/carbon/alien/check_eye_prot()
	return 2

/mob/living/carbon/alien/handle_environment(var/datum/gas_mixture/environment)

	if(!environment)
		return

	var/loc_temp = get_temperature(environment)

//	to_chat(world, "Loc temp: [loc_temp] - Body temp: [bodytemperature] - Fireloss: [getFireLoss()] - Fire protection: [heat_protection] - Location: [loc] - src: [src]")

	// Aliens are now weak to fire.

	//After then, it reacts to the surrounding atmosphere based on your thermal protection
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
		throw_alert("alien_fire", /obj/screen/alert/alien_fire)
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

/mob/living/carbon/alien/Stat()
	..()
	statpanel("Status")
	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")
	show_stat_emergency_shuttle_eta()

/mob/living/carbon/alien/SetStunned(amount, updating = 1, force = 0)
	..()
	if(!(status_flags & CANSTUN) && amount)
		// add some movement delay
		move_delay_add = min(move_delay_add + round(amount / 2), 10) // a maximum delay of 10

/mob/living/carbon/alien/movement_delay()
	. = ..()
	. += move_delay_add + config.alien_delay //move_delay_add is used to slow aliens with stuns

/mob/living/carbon/alien/getDNA()
	return null

/mob/living/carbon/alien/setDNA()
	return

/mob/living/carbon/alien/verb/nightvisiontoggle()
	set name = "Toggle Night Vision"
	set category = "Alien"

	if(!nightvision)
		see_in_dark = 8
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		nightvision = TRUE
		usr.hud_used.nightvisionicon.icon_state = "nightvision1"
	else if(nightvision)
		see_in_dark = initial(see_in_dark)
		lighting_alpha = initial(lighting_alpha)
		nightvision = FALSE
		usr.hud_used.nightvisionicon.icon_state = "nightvision0"

	update_sight()


/mob/living/carbon/alien/assess_threat(var/mob/living/simple_animal/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
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
	if(judgebot.weaponscheck)
		if(judgebot.check_for_weapons(l_hand))
			threatcount += 4
		if(judgebot.check_for_weapons(r_hand))
			threatcount += 4

	//Mindshield implants imply trustworthyness
	if(ismindshielded(src))
		threatcount -= 1

	return threatcount

/*----------------------------------------
Proc: AddInfectionImages()
Des: Gives the client of the alien an image on each infected mob.
----------------------------------------*/
/mob/living/carbon/alien/proc/AddInfectionImages()
	if(client)
		for(var/mob/living/C in GLOB.mob_list)
			if(HAS_TRAIT(C, TRAIT_XENO_HOST))
				var/obj/item/organ/internal/body_egg/alien_embryo/A = C.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo)
				if(A)
					var/I = image('icons/mob/alien.dmi', loc = C, icon_state = "infected[A.stage]")
					client.images += I
	return


/*----------------------------------------
Proc: RemoveInfectionImages()
Des: Removes all infected images from the alien.
----------------------------------------*/
/mob/living/carbon/alien/proc/RemoveInfectionImages()
	if(client)
		for(var/image/I in client.images)
			if(dd_hasprefix_case(I.icon_state, "infected"))
				qdel(I)
	return

/mob/living/carbon/alien/canBeHandcuffed()
	return 1

/mob/living/carbon/alien/proc/updatePlasmaDisplay()
	if(hud_used) //clientless aliens
		hud_used.alien_plasma_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'> <font face='Small Fonts' color='magenta'>[getPlasma()]</font></div>"
		hud_used.alien_plasma_display.maptext_x = -3

/mob/living/carbon/alien/larva/updatePlasmaDisplay()
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
