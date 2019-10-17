 /* Data HUDs have been rewritten in a more generic way.
 * In short, they now use an observer-listener pattern.
 * See code/datum/hud.dm for the generic hud datum.
 * Update the HUD icons when needed with the appropriate hook. (see below)
 */

/* DATA HUD DATUMS */

/atom/proc/add_to_all_human_data_huds()
	for(var/datum/atom_hud/data/human/hud in huds) hud.add_to_hud(src)

/atom/proc/remove_from_all_data_huds()
	for(var/datum/atom_hud/data/hud in huds) hud.remove_from_hud(src)

/datum/atom_hud/data

/datum/atom_hud/data/human/medical
	hud_icons = list(HEALTH_HUD, STATUS_HUD)

/datum/atom_hud/data/human/medical/basic

/datum/atom_hud/data/human/medical/basic/proc/check_sensors(mob/living/carbon/human/H)
	if(!istype(H)) return 0
	var/obj/item/clothing/under/U = H.w_uniform
	if(!istype(U)) return 0
	if(U.sensor_mode <= 2) return 0
	return 1

/datum/atom_hud/data/human/medical/basic/add_to_single_hud(mob/M, mob/living/carbon/H)
	if(check_sensors(H) || istype(M,/mob/dead/observer) )
		..()

/datum/atom_hud/data/human/medical/basic/proc/update_suit_sensors(mob/living/carbon/H)
	check_sensors(H) ? add_to_hud(H) : remove_from_hud(H)

/datum/atom_hud/data/human/medical/advanced

/datum/atom_hud/data/human/security

/datum/atom_hud/data/human/security/basic
	hud_icons = list(ID_HUD)

/datum/atom_hud/data/human/security/advanced
	hud_icons = list(ID_HUD, IMPTRACK_HUD, IMPMINDSHIELD_HUD, IMPCHEM_HUD, WANTED_HUD)

/datum/atom_hud/data/diagnostic
	hud_icons = list (DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_BOT_HUD, DIAG_TRACK_HUD)

/datum/atom_hud/data/diagnostic/advanced
	hud_icons = list (DIAG_HUD, DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_BOT_HUD, DIAG_TRACK_HUD, DIAG_PATH_HUD)

/datum/atom_hud/data/bot_path
	hud_icons = list(DIAG_PATH_HUD)

/datum/atom_hud/abductor
	hud_icons = list(GLAND_HUD)

/datum/atom_hud/data/hydroponic
	hud_icons = list (PLANT_NUTRIENT_HUD, PLANT_WATER_HUD, PLANT_STATUS_HUD, PLANT_HEALTH_HUD, PLANT_TOXIN_HUD, PLANT_PEST_HUD, PLANT_WEED_HUD)

/* MED/SEC/DIAG HUD HOOKS */

/*
 * THESE HOOKS SHOULD BE CALLED BY THE MOB SHOWING THE HUD
 */

/***********************************************
 Medical HUD! Basic mode needs suit sensors on.
************************************************/

//HELPERS

//called when a carbon changes virus
/mob/living/carbon/proc/check_virus()
	for(var/thing in viruses)
		var/datum/disease/D = thing
		if((!(D.visibility_flags & HIDDEN_SCANNER)) && (D.severity != NONTHREAT))
			return 1
	return 0

//helper for getting the appropriate health status
/proc/RoundHealth(mob/living/M)
	if(M.stat == DEAD || (M.status_flags & FAKEDEATH))
		return "health-100-dead" //what's our health? it doesn't matter, we're dead, or faking

	var/maxi_health = M.maxHealth
	if(iscarbon(M) && M.health < 0)
		maxi_health = 100 //so crit shows up right for aliens and other high-health carbon mobs; noncarbons don't have crit.
	var/resulthealth = (M.health / maxi_health) * 100

	switch(resulthealth)
		if(100 to INFINITY)
			return "health100"
		if(95 to 100)
			return "health95"
		if(90 to 95)
			return "health90"
		if(80 to 90)
			return "health80"
		if(70 to 80)
			return "health70"
		if(60 to 70)
			return "health60"
		if(50 to 60)
			return "health50"
		if(40 to 50)
			return "health40"
		if(30 to 40)
			return "health30"
		if(20 to 30)
			return "health20"
		if(10 to 20)
			return "health10"
		if(0 to 10)
			return "health0"
		if(-10 to 0)
			return "health-0" //The health bar will turn a brilliant red and flash as usual, but deducted health will be black.
		if(-20 to -10)
			return "health-10"
		if(-30 to -20)
			return "health-20"
		if(-40 to -30)
			return "health-30"
		if(-50 to -40)
			return "health-40"
		if(-60 to -50)
			return "health-50"
		if(-70 to -60)
			return "health-60"
		if(-80 to -70)
			return "health-70"
		if(-90 to -80)
			return "health-80"
		if(-100 to -90)
			return "health-90"
		else
			return "health-100" //past this point, you're just in trouble
	return "0"


///HOOKS

//called when a human changes suit sensors
/mob/living/carbon/proc/update_suit_sensors()
	var/datum/atom_hud/data/human/medical/basic/B = huds[DATA_HUD_MEDICAL_BASIC]
	B.update_suit_sensors(src)


//called when a living mob changes health
/mob/living/proc/med_hud_set_health()
	var/image/holder = hud_list[HEALTH_HUD]
	holder.icon_state = "hud[RoundHealth(src)]"


//called when a carbon changes stat, virus or XENO_HOST
/mob/living/proc/med_hud_set_status()
	var/image/holder = hud_list[STATUS_HUD]
	if(stat == DEAD)
		holder.icon_state = "huddead"
	else
		holder.icon_state = "hudhealthy"

//called when a carbon changes stat, virus or XENO_HOST
/mob/living/carbon/med_hud_set_status()
	var/image/holder = hud_list[STATUS_HUD]
	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(stat == DEAD || (status_flags & FAKEDEATH))
		if(timeofdeath)
			var/tdelta = round(world.time - timeofdeath)
			if(tdelta < (DEFIB_TIME_LIMIT * 10))
				holder.icon_state = "huddefib"
				return
		holder.icon_state = "huddead"
	else if(status_flags & XENO_HOST)
		holder.icon_state = "hudxeno"
	else if(check_virus())
		holder.icon_state = "hudill"
	else if(B && B.controlling)
		holder.icon_state = "hudbrainworm"
	else
		holder.icon_state = "hudhealthy"



/***********************************************
 Security HUDs! Basic mode shows only the job.
************************************************/

//HOOKS

/mob/living/carbon/human/proc/sec_hud_set_ID()
	var/image/holder = hud_list[ID_HUD]
	holder.icon_state = "hudunknown"
	if(wear_id)
		holder.icon_state = "hud[ckey(wear_id.GetJobName())]"
	sec_hud_set_security_status()



/mob/living/carbon/human/proc/sec_hud_set_implants()
	var/image/holder
	for(var/i in list(IMPTRACK_HUD, IMPMINDSHIELD_HUD, IMPCHEM_HUD))
		holder = hud_list[i]
		holder.icon_state = null
	for(var/obj/item/implant/I in src)
		if(I.implanted)
			if(istype(I,/obj/item/implant/tracking))
				holder = hud_list[IMPTRACK_HUD]
				holder.icon_state = "hud_imp_tracking"
			else if(istype(I,/obj/item/implant/mindshield))
				holder = hud_list[IMPMINDSHIELD_HUD]
				holder.icon_state = "hud_imp_loyal"
			else if(istype(I,/obj/item/implant/chem))
				holder = hud_list[IMPCHEM_HUD]
				holder.icon_state = "hud_imp_chem"


/mob/living/carbon/human/proc/sec_hud_set_security_status()
	var/image/holder = hud_list[WANTED_HUD]
	var/perpname = get_visible_name(TRUE) //gets the name of the perp, works if they have an id or if their face is uncovered
	if(!SSticker) return //wait till the game starts or the monkeys runtime....
	if(perpname)
		var/datum/data/record/R = find_record("name", perpname, data_core.security)
		if(R)
			switch(R.fields["criminal"])
				if("*Execute*")
					holder.icon_state = "hudexecute"
					return
				if("*Arrest*")
					holder.icon_state = "hudwanted"
					return
				if("Incarcerated")
					holder.icon_state = "hudprisoner"
					return
				if("Parolled")
					holder.icon_state = "hudparolled"
					return
				if("Released")
					holder.icon_state = "hudreleased"
					return
	holder.icon_state = null

/***********************************************
 Diagnostic HUDs!
************************************************/

//For Diag health and cell bars!
/proc/RoundDiagBar(value)
	switch(value * 100)
		if(95 to INFINITY)
			return "max"
		if(80 to 100)
			return "good"
		if(60 to 80)
			return "high"
		if(40 to 60)
			return "med"
		if(20 to 40)
			return "low"
		if(1 to 20)
			return "crit"
		else
			return "dead"
	return "dead"

//Sillycone hooks
/mob/living/silicon/proc/diag_hud_set_health()
	var/image/holder = hud_list[DIAG_HUD]
	if(stat == DEAD)
		holder.icon_state = "huddiagdead"
	else
		holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/silicon/proc/diag_hud_set_status()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	switch(stat)
		if(CONSCIOUS)
			holder.icon_state = "hudstat"
		if(UNCONSCIOUS)
			holder.icon_state = "hudoffline"
		else
			holder.icon_state = "huddead2"

//Borgie battery tracking!
/mob/living/silicon/robot/proc/diag_hud_set_borgcell()
	var/image/holder = hud_list[DIAG_BATT_HUD]
	if(cell)
		var/chargelvl = (cell.charge/cell.maxcharge)
		holder.icon_state = "hudbatt[RoundDiagBar(chargelvl)]"
	else
		holder.icon_state = "hudnobatt"

/*~~~~~~~~~~~~~~~~~~~~
	BIG STOMPY MECHS
~~~~~~~~~~~~~~~~~~~~~*/
/obj/mecha/proc/diag_hud_set_mechhealth()
	var/image/holder = hud_list[DIAG_MECH_HUD]
	var/icon/I = icon(icon, icon_state, dir)
	holder.pixel_y = I.Height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(obj_integrity/max_integrity)]"

/obj/mecha/proc/diag_hud_set_mechcell()
	var/image/holder = hud_list[DIAG_BATT_HUD]
	if(cell)
		var/chargelvl = cell.charge/cell.maxcharge
		holder.icon_state = "hudbatt[RoundDiagBar(chargelvl)]"
	else
		holder.icon_state = "hudnobatt"


/obj/mecha/proc/diag_hud_set_mechstat()
	var/image/holder = hud_list[DIAG_STAT_HUD]
	holder.icon_state = null
	if(internal_damage)
		holder.icon_state = "hudwarn"

/obj/mecha/proc/diag_hud_set_mechtracking() //Shows tracking beacons on the mech
	var/image/holder = hud_list[DIAG_TRACK_HUD]
	var/new_icon_state //This var exists so that the holder's icon state is set only once in the event of multiple mech beacons.
	for(var/obj/item/mecha_parts/mecha_tracking/T in trackers)
		if(T.ai_beacon) //Beacon with AI uplink
			new_icon_state = "hudtrackingai"
			break //Immediately terminate upon finding an AI beacon to ensure it is always shown over the normal one, as mechs can have several trackers.
		else
			new_icon_state = "hudtracking"
	holder.icon_state = new_icon_state

/*~~~~~~~~~
	Bots!
~~~~~~~~~~*/
/mob/living/simple_animal/bot/proc/diag_hud_set_bothealth()
	var/image/holder = hud_list[DIAG_HUD]
	if(stat == DEAD)
		holder.icon_state = "huddiagdead"
	else
		holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/simple_animal/bot/proc/diag_hud_set_botstat() //On (With wireless on or off), Off, EMP'ed
	var/image/holder = hud_list[DIAG_STAT_HUD]
	if(on)
		holder.icon_state = "hudstat"
	else if(stat) //Generally EMP causes this
		holder.icon_state = "hudoffline"
	else //Bot is off
		holder.icon_state = "huddead2"

/mob/living/simple_animal/bot/proc/diag_hud_set_botmode() //Shows a bot's current operation
	var/image/holder = hud_list[DIAG_BOT_HUD]
	if(client) //If the bot is player controlled, it will not be following mode logic!
		holder.icon_state = "hudsentient"
		return

	switch(mode)
		if(BOT_SUMMON, BOT_RESPONDING) //Responding to PDA or AI summons
			holder.icon_state = "hudcalled"
		if(BOT_CLEANING, BOT_REPAIRING, BOT_HEALING) //Cleanbot cleaning, Floorbot fixing, or Medibot Healing
			holder.icon_state = "hudworking"
		if(BOT_PATROL, BOT_START_PATROL) //Patrol mode
			holder.icon_state = "hudpatrol"
		if(BOT_PREP_ARREST, BOT_ARREST, BOT_HUNT, BOT_BLOCKED, BOT_NO_ROUTE) //STOP RIGHT THERE, CRIMINAL SCUM!
			holder.icon_state = "hudalert"
		if(BOT_MOVING, BOT_DELIVER, BOT_GO_HOME, BOT_NAV, BOT_WAIT_FOR_NAV) //Moving to target for normal bots, moving to deliver or go home for MULES.
			holder.icon_state = "hudmove"
		else
			holder.icon_state = ""

/*~~~~~~~~~~~~~~
	PLANT HUD
~~~~~~~~~~~~~~~*/
/proc/RoundPlantBar(value)
	switch(value * 100)
		if(1 to 10)
			return "10"
		if(10 to 20)
			return "20"
		if(20 to 30)
			return "30"
		if(30 to 40)
			return "40"
		if(40 to 50)
			return "50"
		if(50 to 60)
			return "60"
		if(60 to 70)
			return "70"
		if(70 to 80)
			return "80"
		if(80 to 90)
			return "90"
		if(90 to INFINITY)
			return "max"
		else
			return "zero"
	return "zero"

/obj/machinery/hydroponics/proc/plant_hud_set_nutrient()
	var/image/holder = hud_list[PLANT_NUTRIENT_HUD]
	holder.icon_state = "hudnutrient[RoundPlantBar(nutrilevel/maxnutri)]"

/obj/machinery/hydroponics/proc/plant_hud_set_water()
	var/image/holder = hud_list[PLANT_WATER_HUD]
	holder.icon_state = "hudwater[RoundPlantBar(waterlevel/maxwater)]"

/obj/machinery/hydroponics/proc/plant_hud_set_status()
	var/image/holder = hud_list[PLANT_STATUS_HUD]
	if(!myseed)
		holder.icon_state = ""
		return
	if(harvest)
		holder.icon_state = "hudharvest"
		return
	if(dead)
		holder.icon_state = "huddead"
		return
	holder.icon_state = ""

/obj/machinery/hydroponics/proc/plant_hud_set_health()
	var/image/holder = hud_list[PLANT_HEALTH_HUD]
	if(!myseed)
		holder.icon_state = ""
		return
	holder.icon_state = "hudplanthealth[RoundPlantBar(plant_health/myseed.endurance)]"

/obj/machinery/hydroponics/proc/plant_hud_set_toxin()
	var/image/holder = hud_list[PLANT_TOXIN_HUD]
	if(toxic < 10)	// You don't want to see these icons if the value is small
		holder.icon_state = ""
		return
	holder.icon_state = "hudtoxin[RoundPlantBar(toxic/100)]"

/obj/machinery/hydroponics/proc/plant_hud_set_pest()
	var/image/holder = hud_list[PLANT_PEST_HUD]
	if(pestlevel < 1)	// You don't want to see these icons if the value is small
		holder.icon_state = ""
		return
	holder.icon_state = "hudpest[RoundPlantBar(pestlevel/10)]"

/obj/machinery/hydroponics/proc/plant_hud_set_weed()
	var/image/holder = hud_list[PLANT_WEED_HUD]
	if(weedlevel < 1)	// You don't want to see these icons if the value is small
		holder.icon_state = ""
		return
	holder.icon_state = "hudweed[RoundPlantBar(weedlevel/10)]"