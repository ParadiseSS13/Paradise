#define ANALYSIS_TIME_BASE (90 MINUTES)

/// list of known advanced disease ids. If an advanced disease isn't here it will display as unknown disease on scanners
/// Initialized with the id of the flu and cold samples from the virologist's fridge in the pandemic's init
GLOBAL_LIST_EMPTY(known_advanced_diseases)
GLOBAL_LIST_EMPTY(detected_advanced_diseases)

/obj/machinery/pandemic
	name = "PanD.E.M.I.C 2200"
	desc = "Used to work with viruses."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pandemic0"
	idle_power_consumption = 20
	resistance_flags = ACID_PROOF
	/// The base analysis time which is later modified by samples of uniqute stages and symptom prediction
	var/base_analaysis_time = ANALYSIS_TIME_BASE
	/// Amount of time it would take to analyze the current disease, before guessing symptoms. -1 means either no disease or that it doesn't require analysis.
	var/analysis_time_delta = -1
	/// The time at which the analysis of a disease will be done. Calculated at the begnining of analysis using analysis_time_delta and symptoms symptom_guesses.
	var/analysis_time
	/// Amount of time to add to the analysis time. resets upon successful analysis of a disease or by calibrating.
	var/static/accumulated_error = list()
	/// List of virus strains and stages already used for calibration.
	var/static/list/used_calibration = list()
	/// Whether the machine is calibrating
	var/calibrating = FALSE
	/// Whether the PANDEMIC is currently analyzing an advanced disease
	var/analyzing = FALSE
	/// ID of the disease being analyzed
	var/analyzed_ID = ""
	/// List of all symptoms. Gets filled in Initialize().
	var/symptom_list = list()
	var/temp_html = ""
	var/printing = null
	var/wait = null
	var/selected_strain_index = 1
	var/obj/item/reagent_containers/beaker = null

/obj/machinery/pandemic/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/pandemic(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()

	GLOB.pandemics |= src
	var/datum/symptom/S
	symptom_list += list("No Prediction")
	for(var/symptom_path in GLOB.list_symptoms)
		// I don't know a way to access the name of something with only the path without creating an instance.
		S = new symptom_path()
		symptom_list += list(S.name)
		qdel(S)
	// We init the list for the Z level here so that we can know it is loaded when we do.
	if(!(z in GLOB.known_advanced_diseases))
		GLOB.known_advanced_diseases += list("[z]" = list("4:origin", "24:origin"))
	if(!(z in accumulated_error))
		accumulated_error += list("[z]" = 0)
		used_calibration += list("[z]" = list())
	update_icon()

/obj/machinery/pandemic/RefreshParts()
	var/total_rating = 0
	for(var/obj/item/stock_parts/manipulator/manip in component_parts)
		total_rating += manip.rating
	base_analaysis_time = ANALYSIS_TIME_BASE * (6 / (total_rating + 4))

/obj/machinery/pandemic/Destroy()
	GLOB.pandemics -= src
	return ..()

/obj/machinery/pandemic/proc/set_broken()
	stat |= BROKEN
	update_icon()

/obj/machinery/pandemic/proc/GetViruses()
	if(beaker && beaker.reagents)
		if(length(beaker.reagents.reagent_list))
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["viruses"])
					var/list/viruses = BL.data["viruses"]
					return viruses

/obj/machinery/pandemic/proc/GetVirusByIndex(index)
	var/list/viruses = GetViruses()
	if(viruses && index > 0 && index <= length(viruses))
		return viruses[index]

/obj/machinery/pandemic/proc/GetResistances()
	if(beaker && beaker.reagents)
		if(length(beaker.reagents.reagent_list))
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["resistances"])
					var/list/resistances = BL.data["resistances"]
					return resistances

/obj/machinery/pandemic/proc/GetResistancesByIndex(index)
	var/list/resistances = GetResistances()
	if(resistances && index > 0 && index <= length(resistances))
		return resistances[index]

/obj/machinery/pandemic/proc/GetVirusTypeByIndex(index)
	var/datum/disease/D = GetVirusByIndex(index)
	if(D)
		return D.GetDiseaseID()

/obj/machinery/pandemic/proc/replicator_cooldown(waittime)
	wait = 1
	update_icon()
	spawn(waittime)
		wait = null
		update_icon()
		playsound(loc, 'sound/machines/ping.ogg', 30, 1)

/obj/machinery/pandemic/update_icon_state()
	if(stat & BROKEN)
		icon_state = (beaker ? "pandemic1_b" : "pandemic0_b")
		return
	icon_state = "pandemic[(beaker)?"1":"0"][(has_power()) ? "" : "_nopower"]"

/obj/machinery/pandemic/update_overlays()
	. = list()
	if(!wait)
		. += "waitlight"

/obj/machinery/pandemic/proc/create_culture(name, bottle_type = "culture", cooldown = 50)
	var/obj/item/reagent_containers/glass/bottle/B = new/obj/item/reagent_containers/glass/bottle(loc)
	B.icon_state = "bottle"
	B.scatter_atom()
	replicator_cooldown(cooldown)
	B.name = "[name] [bottle_type] bottle"
	return B

/// Find the time it would take to analyze the current disease before any symptom symptom_guesses are made
/obj/machinery/pandemic/proc/find_analysis_time_delta(datum/reagent/R)
	var/strains = 0
	var/stage_amount = 0
	var/list/stages = list()
	var/current_strain = ""
	var/stealth_init = FALSE
	var/stealth = 0
	var/resistance = 0
	var/max_stages = 0
	for(var/datum/disease/advance/to_analyze in R.data["viruses"])
		// Automatically analyze if the tracker stores the ID of an analyzed disease
		if(to_analyze.tracker && (to_analyze.tracker in GLOB.known_advanced_diseases["[z]"]))
			if(!(to_analyze.GetDiseaseID() in GLOB.known_advanced_diseases["[z]"]))
				GLOB.known_advanced_diseases["[z]"] += list(to_analyze.GetDiseaseID())
		// If we know this disease there's no need to keep going.
		if(to_analyze.GetDiseaseID() in GLOB.known_advanced_diseases["[z]"])
			return
		// If we somehow got multiple strains we can't do analysis.
		if(to_analyze.strain != current_strain || current_strain == "")
			strains++
			if(strains > 1)
				analysis_time_delta = - 2
				SStgui.update_uis(src, TRUE)
				return
			current_strain = to_analyze.strain
		// Figure out the stealth value. We only need to do this once
		if(!stealth_init)
			for(var/datum/symptom/S in to_analyze.symptoms)
				stealth += S.stealth
				resistance += S.resistance
			stealth += to_analyze.base_properties["stealth"]
			resistance +=  to_analyze.base_properties["resistance"]
			max_stages = to_analyze.max_stages
			stealth_init = TRUE
		// If we found a unique stage count it
		if(!(to_analyze.stage in stages))
			stage_amount++
			stages += to_analyze.stage

	var/power_level = max(stealth + resistance, 0)
	// Make sure we don't runtime if empty
	if(max_stages)
		analysis_time_delta = base_analaysis_time * (1 - stage_amount / (stage_amount + clamp(power_level, 1, max_stages)))
	else
		analysis_time_delta = base_analaysis_time
	SStgui.update_uis(src, TRUE)

/obj/machinery/pandemic/proc/stop_analysis()
	analysis_time_delta = -1
	analyzing = FALSE
	analyzed_ID = ""

/obj/machinery/pandemic/proc/analyze(disease_ID, symptoms)
	analyzing = TRUE
	analyzed_ID = disease_ID
	var/symptom_names = list()
	var/symptom_guesses = list()
	var/correct_prediction_count = 0
	for(var/symptom in symptoms)
		symptom_names += list(symptom["name"])
		symptom_guesses += list(symptom["guess"])
	for(var/name in symptom_guesses)
		if(!name || name == "No Prediction")
			continue
		if(name in symptom_names)
			correct_prediction_count++
		else
			accumulated_error["[z]"] += 3 MINUTES
	// Correct symptom symptom_guesses reduce the final analysis time by up to half of the base time.
	analysis_time = max(0, analysis_time_delta - base_analaysis_time * correct_prediction_count / (2 * length(symptoms))) + world.time
	return

/obj/machinery/pandemic/proc/calibrate()
	if(!accumulated_error["[z]"])
		return
	var/error_reduction
	for(var/datum/disease/advance/virus in GetViruses())
		// We can't calibrate using the same strain and stage combination twice
		if(!(used_calibration["[z]"]["[virus.strain]_[virus.stage]"]))
			used_calibration["[z]"] += list("[virus.strain]_[virus.stage]" = TRUE)
			error_reduction += max(accumulated_error["[z]"] / 5, 3 MINUTES)
	if(error_reduction)
		calibrating = TRUE
		SStgui.update_uis(src)
		spawn(10 SECONDS)
			accumulated_error["[z]"] = max(accumulated_error["[z]"] - error_reduction, 0)
			calibrating = FALSE
			SStgui.update_uis(src)
	// Reset the list of used viruses if we are fully calibrated
	if(!accumulated_error["[z]"])
		used_calibration["[z]"] = list()

/obj/machinery/pandemic/process()
	if(analyzing)
		if(analysis_time_delta < 0)
			analyzing = FALSE
			return

		if(analysis_time + accumulated_error["[z]"] < world.time)
			GLOB.known_advanced_diseases["[z]"] += analyzed_ID
			analyzing = FALSE
			analysis_time_delta = -1
			accumulated_error["[z]"] = 0
			SStgui.update_uis(src, TRUE)

/obj/machinery/pandemic/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(inoperable())
		return


	. = TRUE

	switch(action)
		if("clone_strain")
			if(wait)
				atom_say("The replicator is not ready yet.")
				return

			var/strain_index = text2num(params["strain_index"])
			if(isnull(strain_index))
				atom_say("Unable to respond to command.")
				return
			var/datum/disease/virus = GetVirusByIndex(strain_index)
			var/datum/disease/D = null
			if(!virus)
				atom_say("Unable to find requested strain.")
				return
			var/type = virus.GetDiseaseID()
			if(!ispath(type))
				var/datum/disease/advance/A = virus
				if(istype(A))
					D = A.Copy()
			else if(type)
				if(type in GLOB.diseases) // Make sure this is a disease
					D = new type(0, null)
			if(!D)
				atom_say("Unable to synthesize requested strain.")
				return
			var/default_name = ""
			if(D.name == "Unknown" || D.name == "")
				default_name = replacetext(beaker.name, new/regex(" culture bottle\\Z", "g"), "")
			else
				default_name = D.name
			var/name = tgui_input_text(usr, "Name:", "Name the culture", default_name, MAX_NAME_LEN)
			if(name == null || wait)
				return
			var/obj/item/reagent_containers/glass/bottle/B = create_culture(name)
			B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood", 20, list("viruses" = list(D)))
		if("clone_vaccine")
			if(wait)
				atom_say("The replicator is not ready yet.")
				return

			var/resistance_index = text2num(params["resistance_index"])
			if(isnull(resistance_index))
				atom_say("Unable to find requested antibody.")
				return
			var/vaccine_type = GetResistancesByIndex(resistance_index)
			var/vaccine_name = "Unknown"
			if(!ispath(vaccine_type))
				if(GLOB.archive_diseases[vaccine_type])
					var/datum/disease/D = GLOB.archive_diseases[vaccine_type]
					if(D)
						vaccine_name = D.name
			else if(vaccine_type)
				var/datum/disease/D = new vaccine_type(0, null)
				if(D)
					vaccine_name = D.name

			if(!vaccine_type)
				atom_say("Unable to synthesize requested antibody.")
				return

			var/obj/item/reagent_containers/glass/bottle/B = create_culture(vaccine_name, "vaccine", 200)
			B.reagents.add_reagent("vaccine", 15, list(vaccine_type))
		if("remove_from_database")
			if(params["strain_id"] in GLOB.known_advanced_diseases["[z]"])
				GLOB.known_advanced_diseases["[z]"] -= params["strain_id"]
				SStgui.update_uis(src, TRUE)
		if("calibrate")
			calibrate()
		if("eject_beaker")
			stop_analysis()
			eject_beaker()
			update_static_data(ui.user)
		if("destroy_eject_beaker")
			beaker.reagents.clear_reagents()
			eject_beaker()
			update_static_data(ui.user)
		if("print_release_forms")
			var/strain_index = text2num(params["strain_index"])
			if(isnull(strain_index))
				atom_say("Unable to respond to command.")
				return
			var/type = GetVirusTypeByIndex(strain_index)
			if(!type)
				atom_say("Unable to find requested strain.")
				return
			var/datum/disease/advance/A = GLOB.archive_diseases[type]
			if(!A)
				atom_say("Unable to find requested strain.")
				return
			print_form(A, usr)
		if("name_strain")
			var/strain_index = text2num(params["strain_index"])
			if(isnull(strain_index))
				atom_say("Unable to respond to command.")
				return
			var/type = GetVirusTypeByIndex(strain_index)
			if(!type)
				atom_say("Unable to find requested strain.")
				return
			var/datum/disease/advance/A = GLOB.archive_diseases[type]
			if(!A)
				atom_say("Unable to find requested strain.")
				return
			var/new_name = tgui_input_text(usr, "Name the Strain", "New Name", max_length = MAX_NAME_LEN)
			if(!new_name)
				return
			A.AssignName(new_name)
			for(var/datum/disease/advance/AD in GLOB.active_diseases)
				AD.Refresh(FALSE, FALSE, FALSE, FALSE)
			update_static_data(ui.user)
		if("switch_strain")
			var/strain_index = text2num(params["strain_index"])
			if(isnull(strain_index) || strain_index < 1)
				atom_say("Unable to respond to command.")
				return
			var/list/viruses = GetViruses()
			if(strain_index > length(viruses))
				atom_say("Unable to find requested strain.")
				return
			selected_strain_index = strain_index;
		if("analyze_strain")
			analyze(params["strain_id"], params["symptoms"])
		else
			return FALSE

/obj/machinery/pandemic/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/pandemic/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PanDEMIC", name)
		ui.open()

/obj/machinery/pandemic/ui_data(mob/user)
	var/datum/reagent/blood/Blood = null
	if(beaker)
		var/datum/reagents/R = beaker.reagents
		for(var/datum/reagent/blood/B in R.reagent_list)
			if(B)
				Blood = B
				break
	var/can_calibrate = FALSE
	if(Blood && accumulated_error["[z]"] > 0)
		if(Blood.data && Blood.data["viruses"])
			for(var/datum/disease/advance/virus in Blood.data["viruses"])
				if((virus.GetDiseaseID() in GLOB.known_advanced_diseases["[z]"]) && !used_calibration["[z]"]["[virus.strain]_[virus.stage]"])
					can_calibrate = TRUE
					break

	var/list/data = list(
		"synthesisCooldown" = wait ? TRUE : FALSE,
		"beakerLoaded" = beaker ? TRUE : FALSE,
		"beakerContainsBlood" = Blood ? TRUE : FALSE,
		"beakerContainsVirus" = length(Blood?.data["viruses"]) != 0,
		"calibrating" = calibrating,
		"canCalibrate" = can_calibrate,
		"selectedStrainIndex" = selected_strain_index,
		"analysisTime" = (analysis_time + accumulated_error["[z]"]) > world.time ? analysis_time + accumulated_error["[z]"] - world.time : 0,
		"accumulatedError" = accumulated_error["[z]"],
		"analysisTimeDelta" = analysis_time_delta + accumulated_error["[z]"],
		"analyzing" = analyzing,
		"symptom_names" = symptom_list,
	)

	return data

/obj/machinery/pandemic/ui_static_data(mob/user)
	var/list/data = list()
	. = data

	var/datum/reagent/blood/Blood = null
	if(beaker)
		var/datum/reagents/R = beaker.reagents
		for(var/datum/reagent/blood/B in R.reagent_list)
			if(B)
				Blood = B
				break

	var/list/strains = list()
	for(var/datum/disease/blood_disease in GetViruses())
		var/known = FALSE
		if(!(blood_disease.GetDiseaseID() in GLOB.detected_advanced_diseases["[z]"]))
			GLOB.detected_advanced_diseases["[z]"] += list(blood_disease.GetDiseaseID())
		if(blood_disease.visibility_flags & VIRUS_HIDDEN_PANDEMIC)
			continue

		var/list/symptoms = list()
		var/list/base_stats = list()
		var/datum/disease/advance/advanced_disease = blood_disease
		if(istype(blood_disease, /datum/disease/advance))
			known = (advanced_disease.GetDiseaseID() in GLOB.known_advanced_diseases["[z]"])
			for(var/datum/symptom/virus_symptom in advanced_disease.symptoms)
				symptoms += list(list(
					"name" = virus_symptom.name,
					"stealth" = known ? virus_symptom.stealth : "UNKNOWN",
					"resistance" = known ? virus_symptom.resistance : "UNKNOWN",
					"stageSpeed" = known ? virus_symptom.stage_speed : "UNKNOWN",
					"transmissibility" = known ? virus_symptom.transmittable : "UNKNOWN",
					"complexity" = known ? virus_symptom.level : "UNKNOWN",
				))

			base_stats["stealth"] = advanced_disease.base_properties["stealth"]
			base_stats["resistance"] = advanced_disease.base_properties["resistance"]
			base_stats["stageSpeed"] = advanced_disease.base_properties["stage rate"]
			base_stats["transmissibility"] = advanced_disease.base_properties["transmittable"]
		else
			known = TRUE
			base_stats["stealth"] = 0
			base_stats["resistance"] = 0
			base_stats["stageSpeed"] = 0
			base_stats["transmissibility"] = 0
		strains += list(list(
			"commonName" = known ? blood_disease.name : "Unknown strain",
			"description" = known ? blood_disease.desc : "Unknown strain",
			"strainID" = blood_disease.get_strain_id(),
			"strainFullID" = blood_disease.get_full_strain_id(),
			"diseaseID" = blood_disease.get_ui_id(),
			"sample_stage" = blood_disease.get_stage(),
			"known" = known,
			"bloodDNA" = Blood.data["blood_DNA"],
			"bloodType" = Blood.data["blood_type"],
			"diseaseAgent" = blood_disease.agent,
			"possibleTreatments" = known ? blood_disease.cure_text : "Unknown strain",
			"RequiredCures" = blood_disease.get_required_cures(),
			"Stabilized" = blood_disease.is_stabilized(),
			"StrainTracker" = blood_disease.get_tracker(),
			"transmissionRoute" = known ? blood_disease.spread_text : "Unknown strain",
			"symptoms" = symptoms,
			"baseStats" = base_stats,
			"isAdvanced" = istype(blood_disease, /datum/disease/advance),
		))
	data["strains"] = strains

	var/list/resistances = list()
	for(var/resistance in GetResistances())
		if(!ispath(resistance))
			var/datum/disease/resisted_disease = GLOB.archive_diseases[resistance]
			if(resisted_disease)
				resistances += list(resisted_disease.name)
		else if(resistance)
			var/datum/disease/resistance_disease = new resistance(0, null)
			if(resistance_disease)
				resistances += list(resistance_disease.name)
	data["resistances"] = resistances
	data["analysis_time_delta"] = analysis_time_delta

/obj/machinery/pandemic/proc/eject_beaker()
	beaker.forceMove(loc)
	beaker = null
	icon_state = "pandemic0"
	selected_strain_index = 1

//Prints a nice virus release form. Props to Urbanliner for the layout
/obj/machinery/pandemic/proc/print_form(datum/disease/advance/D, mob/living/user)
	D = GLOB.archive_diseases[D.GetDiseaseID()]
	if(!(printing) && D)
		var/reason = tgui_input_text(user,"Enter a reason for the release", "Write", multiline = TRUE)
		if(!reason)
			return
		reason += "<span class=\"paper_field\"></span>"
		var/english_symptoms = list()
		for(var/I in D.symptoms)
			var/datum/symptom/S = I
			english_symptoms += S.name
		var/symtoms = english_list(english_symptoms)


		var/signature
		if(tgui_alert(user, "Would you like to add your signature?", "Signature", list("Yes","No")) == "Yes")
			signature = "<font face=\"[SIGNFONT]\"><i>[user ? user.real_name : "Anonymous"]</i></font>"
		else
			signature = "<span class=\"paper_field\"></span>"

		printing = 1
		var/obj/item/paper/P = new /obj/item/paper(loc)
		visible_message("<span class='notice'>[src] rattles and prints out a sheet of paper.</span>")
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)

		P.info = "<U><font size=\"4\"><B><center> Releasing Virus </B></center></font></U>"
		P.info += "<HR>"
		P.info += "<U>Name of the Virus:</U> [D.name] <BR>"
		P.info += "<U>Symptoms:</U> [symtoms]<BR>"
		P.info += "<U>Spreads by:</U> [D.spread_text]<BR>"
		P.info += "<U>Cured by:</U> [D.cure_text]<BR>"
		P.info += "<BR>"
		P.info += "<U>Reason for releasing:</U> [reason]"
		P.info += "<HR>"
		P.info += "The Virologist is responsible for any biohazards caused by the virus released.<BR>"
		P.info += "<U>Virologist's sign:</U> [signature]<BR>"
		P.info += "If approved, stamp below with the Chief Medical Officer's stamp, and/or the Captain's stamp if required:"
		P.populatefields()
		P.updateinfolinks()
		P.name = "Releasing Virus - [D.name]"
		printing = null

/obj/machinery/pandemic/proc/print_goal_orders()
	if(stat & (BROKEN|NOPOWER))
		return

	playsound(loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
	var/obj/item/paper/P = new /obj/item/paper(loc)
	P.name = "paper - 'Viral Samples Request'"

	var/list/info_text = list("<div style='text-align:center;'><img src='ntlogo.png'>")
	info_text += "<h3>Viral Sample Orders</h3></div><hr>"
	info_text += "<b>Viral Sample Orders for [station_name()]'s Virologist:</b><br><br>"

	for(var/datum/virology_goal/G in GLOB.virology_goals)
		info_text += G.get_report()
		info_text += "<hr>"
	info_text += "-Nanotrasen Virology Research"

	P.info = info_text.Join("")
	P.update_icon()

/obj/machinery/pandemic/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/pandemic/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/pandemic/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/pandemic/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(default_unfasten_wrench(user, used, time = 4 SECONDS))
		power_change()
		return
	if((istype(used, /obj/item/reagent_containers) && (used.container_type & OPENCONTAINER)) && user.a_intent != INTENT_HARM)
		if(stat & (NOPOWER|BROKEN))
			return ITEM_INTERACT_COMPLETE
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into the machine!</span>")
			return ITEM_INTERACT_COMPLETE
		if(!user.drop_item())
			return ITEM_INTERACT_COMPLETE

		beaker = used
		beaker.forceMove(src)
		to_chat(user, "<span class='notice'>You add the beaker to the machine.</span>")
		SStgui.update_uis(src, TRUE)
		icon_state = "pandemic1"
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			if(R.id == "blood")
				find_analysis_time_delta(R)
				SStgui.update_uis(src, TRUE)
				for(var/datum/disease/advance/virus in R.data["viruses"])
					log_admin("[key_name(user)] inserted disease [virus] of strain [virus.strain] with the following symptoms: [english_list(virus.symptoms)] into [src] at these coords x: [x] y: [y] z: [z]")
				break

		return ITEM_INTERACT_COMPLETE
	else
		return ..()

/obj/machinery/pandemic/screwdriver_act(mob/living/user, obj/item/I)
	if(!default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		return FALSE
	if(beaker)
		eject_beaker()
	return TRUE

/obj/machinery/pandemic/crowbar_act(mob/living/user, obj/item/I)
	return default_deconstruction_crowbar(user, I)

#undef ANALYSIS_TIME_BASE
