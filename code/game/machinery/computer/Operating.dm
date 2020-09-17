#define OP_COMPUTER_COOLDOWN 60

/obj/machinery/computer/operating
	name = "operating computer"
	density = 1
	anchored = 1.0
	icon_keyboard = "med_key"
	icon_screen = "crew"
	circuit = /obj/item/circuitboard/operating
	var/obj/machinery/optable/table = null
	var/mob/living/carbon/human/victim = null
	light_color = LIGHT_COLOR_PURE_BLUE
	var/verbose = 1 //general speaker toggle
	var/patientName = null
	var/oxyAlarm = 30 //oxy damage at which the computer will beep
	var/choice = 0 //just for going into and out of the options menu
	var/healthAnnounce = 1 //healther announcer toggle
	var/crit = 1 //crit beeping toggle
	var/nextTick = OP_COMPUTER_COOLDOWN
	var/healthAlarm = 50
	var/oxy = 1 //oxygen beeping toggle

/obj/machinery/computer/operating/New()
	..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		table = locate(/obj/machinery/optable, get_step(src, dir))
		if(table)
			table.computer = src
			break

/obj/machinery/computer/operating/Destroy()
	if(table)
		table.computer = null
		table = null
	if(victim)
		victim = null
	return ..()

/obj/machinery/computer/operating/attack_ai(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER))
		return
	tgui_interact(user)

/obj/machinery/computer/operating/attack_hand(mob/user)
	if(..(user))
		return

	if(stat & (NOPOWER|BROKEN))
		return


	add_fingerprint(user)
	tgui_interact(user)

/obj/machinery/computer/operating/tgui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/tgui_state/state = GLOB.tgui_default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "OperatingComputer", "Patient Monitor", 650, 455, master_ui, state)
		ui.open()

/obj/machinery/computer/operating/tgui_data(mob/user)
	var/data[0]
	var/mob/living/carbon/human/occupant
	if(table)
		occupant = table.victim
	data["hasOccupant"] = occupant ? 1 : 0
	var/occupantData[0]

	if(occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = HEALTH_THRESHOLD_DEAD
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["paralysis"] = occupant.paralysis
		occupantData["hasBlood"] = 0
		occupantData["bodyTemperature"] = occupant.bodytemperature
		occupantData["maxTemp"] = 1000 // If you get a burning vox armalis into the sleeper, congratulations
		// Because we can put simple_animals in here, we need to do something tricky to get things working nice
		occupantData["temperatureSuitability"] = 0 // 0 is the baseline
		if(ishuman(occupant) && occupant.dna.species)
			var/datum/species/sp = occupant.dna.species
			if(occupant.bodytemperature < sp.cold_level_3)
				occupantData["temperatureSuitability"] = -3
			else if(occupant.bodytemperature < sp.cold_level_2)
				occupantData["temperatureSuitability"] = -2
			else if(occupant.bodytemperature < sp.cold_level_1)
				occupantData["temperatureSuitability"] = -1
			else if(occupant.bodytemperature > sp.heat_level_3)
				occupantData["temperatureSuitability"] = 3
			else if(occupant.bodytemperature > sp.heat_level_2)
				occupantData["temperatureSuitability"] = 2
			else if(occupant.bodytemperature > sp.heat_level_1)
				occupantData["temperatureSuitability"] = 1
		else if(istype(occupant, /mob/living/simple_animal))
			var/mob/living/simple_animal/silly = occupant
			if(silly.bodytemperature < silly.minbodytemp)
				occupantData["temperatureSuitability"] = -3
			else if(silly.bodytemperature > silly.maxbodytemp)
				occupantData["temperatureSuitability"] = 3
		// Blast you, imperial measurement system
		occupantData["btCelsius"] = occupant.bodytemperature - T0C
		occupantData["btFaren"] = ((occupant.bodytemperature - T0C) * (9.0/5.0))+ 32

		if(ishuman(occupant) && !(NO_BLOOD in occupant.dna.species.species_traits))
			occupantData["pulse"] = occupant.get_pulse(GETPULSE_TOOL)
			occupantData["hasBlood"] = 1
			occupantData["bloodLevel"] = round(occupant.blood_volume)
			occupantData["bloodMax"] = occupant.max_blood
			occupantData["bloodPercent"] = round(100*(occupant.blood_volume/occupant.max_blood), 0.01) //copy pasta ends here

			occupantData["bloodType"] = occupant.dna.blood_type
		if(occupant.surgeries.len)
			occupantData["inSurgery"] = 1
			for(var/datum/surgery/procedure in occupant.surgeries)
				occupantData["surgeryName"] = "[capitalize(procedure.name)]"
				var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
				occupantData["stepName"] = "[capitalize(surgery_step.name)]"

	data["occupant"] = occupantData
	data["verbose"]=verbose
	data["oxyAlarm"]=oxyAlarm
	data["choice"]=choice
	data["health"]=healthAnnounce
	data["crit"]=crit
	data["healthAlarm"]=healthAlarm
	data["oxy"]=oxy

	return data


/obj/machinery/computer/operating/tgui_act(action, params)
	if(..())
		return
	if(stat & (NOPOWER|BROKEN))
		return

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

	. = TRUE
	switch(action)
		if("verboseOn")
			verbose = TRUE
		if("verboseOff")
			verbose = FALSE
		if("healthOn")
			healthAnnounce = TRUE
		if("healthOff")
			healthAnnounce = FALSE
		if("critOn")
			crit = TRUE
		if("critOff")
			crit = FALSE
		if("oxyOn")
			oxy = TRUE
		if("oxyOff")
			oxy = FALSE
		if("oxy_adj")
			oxyAlarm = clamp(text2num(params["new"]), -100, 100)
		if("choiceOn")
			choice = TRUE
		if("choiceOff")
			choice = FALSE
		if("health_adj")
			healthAlarm = clamp(text2num(params["new"]), -100, 100)
		else
			return FALSE

/obj/machinery/computer/operating/process()

	if(table && table.check_victim())
		if(verbose)
			if(patientName!=table.victim.name)
				patientName=table.victim.name
				atom_say("New patient detected, loading stats")
				victim = table.victim
				atom_say("[victim.real_name], [victim.dna.blood_type] blood, [victim.stat ? "Non-Responsive" : "Awake"]")
				SStgui.update_uis(src)
			if(nextTick < world.time)
				nextTick=world.time + OP_COMPUTER_COOLDOWN
				if(crit && victim.health <= -50 )
					playsound(src.loc, 'sound/machines/defib_success.ogg', 50, 0)
				if(oxy && victim.getOxyLoss()>oxyAlarm)
					playsound(src.loc, 'sound/machines/defib_saftyoff.ogg', 50, 0)
				if(healthAnnounce && victim.health <= healthAlarm)
					atom_say("[round(victim.health)]")
