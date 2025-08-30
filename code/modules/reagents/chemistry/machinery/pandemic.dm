#define ANALYSIS_DIFFICULTY_BASE 100
#define ANALYSIS_DIFFICULTY_INCREMENT 40
#define ANALYSIS_DURATION_BASE (0.5 MINUTES)
#define STAGE_CONTRIBUTION 40
#define GENE_CONTRIBUTION 60

/// list of known advanced disease ids. If an advanced disease isn't here it will display as unknown disease on scanners
/// Initialized with the id of the flu and cold samples from the virologist's fridge in the pandemic's init
GLOBAL_LIST_EMPTY(known_advanced_diseases)
GLOBAL_LIST_EMPTY(detected_advanced_diseases)

/obj/machinery/pandemic
	name = "PanD.E.M.I.C 2200"
	desc = "Used to work with viruses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pandemic0"
	idle_power_consumption = 20
	resistance_flags = ACID_PROOF
	density = TRUE
	anchored = TRUE
	/// The base analysis time which is later modified by samples of uniqute stages and symptom prediction
	var/analysis_difficulty_base = ANALYSIS_DIFFICULTY_BASE
	/// How difficult the disease is to analyze. This sets the requirements for how much you need to contribute with things like stages and symptom predictions
	var/analysis_difficulty = 0
	/// The contribution of various factors towards analysis. The "max" values are only for the UI
	var/analysis_contributions = list(
		"Stage Data" = list("amount" = 0, "max" = 5 * STAGE_CONTRIBUTION),
		"Viral Gene Data" = list("amount" = 0, "max" = 2 * GENE_CONTRIBUTION),
		"Symptom Data" = list("amount" = 0, "max" = 0.5 * ANALYSIS_DIFFICULTY_BASE)
		)
	/// The time at which the analysis of a disease will be done. Calculated at the begnining of analysis using analysis_difficulty and symptoms symptom_guesses.
	var/analysis_time
	/// How much time analysis will take. Depends on components
	var/analysis_duration
	/// Whether the PANDEMIC is currently analyzing an advanced disease
	var/analyzing = FALSE
	/// Whether to keep the report screen up. This is so it can stay persistent while the UI is closed
	var/reporting = FALSE
	/// Can our sample be analyzed
	var/valid_sample = FALSE
	/// ID of the disease being analyzed
	var/analyzed_ID = ""
	/// Index of the disease being analyzed
	var/analyzed_index
	/// List of all symptoms. Gets filled in Initialize().
	var/symptom_list = list()
	var/temp_html = ""
	var/printing = null
	var/wait = null
	var/selected_strain_index = 1
	var/obj/item/reagent_containers/beaker = null
	/// The current symptom predictions
	var/list/predictions = list(
		"No Prediction",
		"No Prediction",
		"No Prediction",
		"No Prediction",
		"No Prediction",
		"No Prediction"
		)

/obj/machinery/pandemic/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/pandemic(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/micro_laser(null)
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
	update_icon()

/obj/machinery/pandemic/RefreshParts()
	var/manip_rating = 0
	var/laser_rating = 0
	for(var/obj/item/stock_parts/manipulator/manip in component_parts)
		manip_rating += manip.rating
	for(var/obj/item/stock_parts/micro_laser/laser in component_parts)
		laser_rating += laser.rating

	analysis_difficulty_base = ANALYSIS_DIFFICULTY_BASE * (9 / (manip_rating + 8))
	analysis_duration = ANALYSIS_DURATION_BASE * (1 / laser_rating)
	find_analysis_requirements()

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
	B.scatter_atom()
	replicator_cooldown(cooldown)
	B.name = "[name] [bottle_type] bottle"
	return B

/// Find the time it would take to analyze the current disease before any symptom predictions are made
/obj/machinery/pandemic/proc/find_analysis_requirements()
	if(!beaker)
		return
	analysis_contributions["Stage Data"]["amount"] = 0
	analysis_contributions["Viral Gene Data"]["amount"] = 0
	analysis_contributions["Symptom Data"]["amount"] = 0
	analysis_contributions["Symptom Data"]["max"] = 1
	valid_sample = TRUE
	var/strains = 0
	var/list/stages = list()
	var/current_strain = ""
	var/stealth_init = FALSE
	var/stealth = 0
	var/resistance = 0
	var/max_stages = 0
	var/known_symptoms = 0
	var/num_symptoms = 0
	var/datum/reagent/blood/blood_sample = locate() in beaker.reagents.reagent_list
	var/datum/reagent/virus_genes/gene_sample = locate() in beaker.reagents.reagent_list
	if(blood_sample && blood_sample.data && blood_sample.data["viruses"])
		for(var/datum/disease/advance/to_analyze in blood_sample.data["viruses"])
			// Note down number of symptoms and number of known symptoms.
			// We only use these values if we find one strain, so no need to worry about overwriting
			known_symptoms = length(GLOB.detected_advanced_diseases["[z]"][to_analyze.GetDiseaseID()]["known_symptoms"])
			num_symptoms = length(to_analyze.symptoms)
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
					valid_sample = FALSE
					SStgui.update_uis(src, TRUE)
					return
				current_strain = to_analyze.strain
			// Calculate the stealth and resistance values. We only need to do this once
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
				analysis_contributions["Stage Data"]["amount"] += STAGE_CONTRIBUTION
				stages += to_analyze.stage

	if(gene_sample && gene_sample.data)
		for(var/key in gene_sample.data)
			for(var/strain_id in gene_sample.data[key])
				if(strain_id == current_strain)
					analysis_contributions["Viral Gene Data"]["amount"] += GENE_CONTRIBUTION
					break

	var/power_level = (stealth + resistance)
	// Make sure we don't runtime if empty
	if(max_stages)
		analysis_difficulty = analysis_difficulty_base + ANALYSIS_DIFFICULTY_INCREMENT * (1.17 ** power_level)
	else
		analysis_difficulty = analysis_difficulty_base

	analysis_contributions["Symptom Data"]["amount"] = num_symptoms ? analysis_difficulty * known_symptoms / (2 * num_symptoms) : 0
	analysis_contributions["Symptom Data"]["max"] = max(analysis_difficulty / 2, 1)

	SStgui.update_uis(src, TRUE)

/obj/machinery/pandemic/proc/start_analysis(strain_index)
	var/datum/disease/advance/virus = GetVirusByIndex(strain_index)
	analyzing = TRUE
	analysis_time = world.time + analysis_duration
	analyzed_ID = virus.GetDiseaseID()
	analyzed_index = strain_index

/obj/machinery/pandemic/proc/analyze(strain_index)
	reporting = TRUE
	var/datum/disease/advance/virus = GetVirusByIndex(analyzed_index)
	var/symptom_names = list()
	for(var/datum/symptom/current_symptom in virus.symptoms)
		symptom_names += list(current_symptom.name)
	for(var/name in predictions)
		if(!name || name == "No Prediction")
			continue
		if(name in symptom_names)
			GLOB.detected_advanced_diseases["[z]"][analyzed_ID]["known_symptoms"] |= list(name)

	var/found_symptoms = length(GLOB.detected_advanced_diseases["[z]"][analyzed_ID]["known_symptoms"])
	// Correct symptom symptom_guesses reduce the final analysis time by up to half of the base time.
	analysis_contributions["Symptom Data"]["max"] = analysis_difficulty / 2
	analysis_contributions["Symptom Data"]["amount"] = analysis_difficulty * found_symptoms / (2 * length(virus.symptoms))

	var/total_contribution = 0
	for(var/factor in analysis_contributions)
		total_contribution += analysis_contributions[factor]["amount"]

	return (analysis_difficulty - total_contribution) <= 0

/obj/machinery/pandemic/process()
	if(analyzing && analysis_time < world.time)
		if(analyze(analyzed_index))
			GLOB.known_advanced_diseases["[z]"] += analyzed_ID
		analyzing = FALSE
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
		if("eject_beaker")
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
				AD.Refresh(TRUE, FALSE, FALSE, FALSE)
			var/datum/reagent/blood = locate() in beaker.reagents.reagent_list
			if(blood.data && blood.data["viruses"])
				for(var/datum/disease/advance/virus in blood.data["viruses"])
					virus.AssignName(new_name)
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
			start_analysis(params["strain_index"])
		if("set_prediction")
			set_predictions(text2num(params["pred_index"]), params["pred_value"])
			SStgui.update_uis(src)
		if("close_report")
			reporting = FALSE
		else
			return FALSE

/obj/machinery/pandemic/proc/set_predictions(index, value)
	predictions[index] = value

/obj/machinery/pandemic/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/pandemic/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PanDEMIC", name)
		ui.open()

/obj/machinery/pandemic/ui_data(mob/user)
	var/datum/reagent/blood/Blood = null
	var/can_analyze = valid_sample
	var/contribution_list = list()
	var/contribution_sum = 0
	if(beaker)
		var/datum/reagents/R = beaker.reagents
		for(var/datum/reagent/blood/B in R.reagent_list)
			if(B)
				Blood = B
				break
	if(Blood)
		if(Blood.data && Blood.data["viruses"])
			for(var/datum/disease/advance/virus in Blood.data["viruses"])
				if((virus.GetDiseaseID() in GLOB.known_advanced_diseases["[z]"]))
					can_analyze = FALSE
					break
	for(var/factor in analysis_contributions)
		contribution_list += list(list(
			"factor" = factor,
			"amount" = analysis_contributions[factor]["amount"],
			"maxAmount" = analysis_contributions[factor]["max"],
		))
		contribution_sum += analysis_contributions[factor]["amount"]

	var/list/data = list(
		"synthesisCooldown" = wait ? TRUE : FALSE,
		"beakerLoaded" = beaker ? TRUE : FALSE,
		"beakerContainsBlood" = Blood ? TRUE : FALSE,
		"beakerContainsVirus" = length(Blood?.data["viruses"]) != 0,
		"selectedStrainIndex" = selected_strain_index,
		"analysisTime" = analysis_time > world.time ? analysis_time - world.time : 0,
		"analysisDuration" = analysis_duration,
		"analysisDifficulty" = analysis_difficulty,
		"analysisContributions" = contribution_list,
		"totalContribution" = contribution_sum,
		"canAnalyze" =  can_analyze,
		"analyzing" = analyzing,
		"reporting" = reporting,
		"symptom_names" = symptom_list,
		"predictions" = predictions,
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
		if(!(blood_disease.GetDiseaseID() in GLOB.detected_advanced_diseases["[z]"]))
			GLOB.detected_advanced_diseases["[z]"] += list(blood_disease.GetDiseaseID() = list("known_symptoms" = list()))
		if(blood_disease.visibility_flags & VIRUS_HIDDEN_PANDEMIC)
			continue

		var/list/symptoms = blood_disease.get_pandemic_symptoms(z)
		var/list/base_stats = blood_disease.get_pandemic_base_stats()
		var/known = blood_disease.is_known(z)
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
			"possibleCures" = known ? blood_disease.cure_text : "Unknown strain",
			"RequiredCures" = "[blood_disease.get_required_cures()]",
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
	data["analysis_difficulty"] = analysis_difficulty

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

/obj/machinery/pandemic/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 4 SECONDS)

/obj/machinery/pandemic/item_interaction(mob/living/user, obj/item/used, list/modifiers)
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
		icon_state = "pandemic1"
		var/datum/reagent/blood/inserted = locate() in beaker.reagents.reagent_list
		if(inserted && inserted.data && inserted.data["viruses"])
			for(var/datum/disease/advance/virus in inserted.data["viruses"])
				if(!(virus.GetDiseaseID() in GLOB.detected_advanced_diseases["[z]"]))
					GLOB.detected_advanced_diseases["[z]"] += list(virus.GetDiseaseID() = list("known_symptoms" = list()))
				log_admin("[key_name(user)] inserted disease [virus] of strain [virus.strain] with the following symptoms: [english_list(virus.symptoms)] into [src] at these coords x: [x] y: [y] z: [z]")
		find_analysis_requirements()
		SStgui.update_uis(src, TRUE)
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

#undef ANALYSIS_DIFFICULTY_BASE
#undef ANALYSIS_DIFFICULTY_INCREMENT
#undef ANALYSIS_DURATION_BASE
#undef STAGE_CONTRIBUTION
#undef GENE_CONTRIBUTION
