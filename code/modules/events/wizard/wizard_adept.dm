/datum/event/wizard_adept
	name = "Wizard Adept"
	role_weights = list(ASSIGNMENT_SECURITY = 2)
	role_requirements = list(ASSIGNMENT_CREW = 20, ASSIGNMENT_SECURITY = 2)
	nominal_severity = EVENT_LEVEL_MAJOR

/datum/event/wizard_adept/start()
	INVOKE_ASYNC(src, PROC_REF(poll_wiz_adept))

/datum/event/wizard_adept/proc/poll_wiz_adept(list/potential_wizards)
	var/list/candidates = list()
	if(!potential_wizards)
		candidates = SSghost_spawns.poll_candidates("Do you want to play as a Wizard?", ROLE_WIZARD, TRUE)
	else
		candidates = potential_wizards
	if(!length(candidates))
		kill()
		return
	var/mob/new_wizard
	while(length(candidates))
		new_wizard = pick_n_take(candidates)
		if(jobban_isbanned(new_wizard, ROLE_TRAITOR))
			continue
		break
	if(!new_wizard)
		kill()
		return

	var/gender_pref = input_async(new_wizard, "Please select a gender (10 seconds):", list("Male", "Female"))
	addtimer(CALLBACK(src, PROC_REF(get_species), candidates, new_wizard, gender_pref), 10 SECONDS)

/datum/event/wizard_adept/proc/get_species(list/potential_wizards, mob/new_wizard, datum/async_input/gender_pref)
	gender_pref.close()
	var/sel_gender = gender_pref.result
	if(!sel_gender) // Player was AFK and did not select a gender
		poll_wiz_adept(potential_wizards)
		return
	var/species_pref = input_async(new_wizard, "Please select a species (10 seconds):", list("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin", "Nian", "Drask", "Kidan", "Grey", "Skkulakin", "Vox", "Slime", "Machine", "Random"))
	addtimer(CALLBACK(src, PROC_REF(create_ninja), potential_wizards, new_wizard, sel_gender, species_pref), 10 SECONDS)

/datum/event/wizard_adept/proc/create_ninja(list/potential_wizards, mob/new_wizard, sel_gender, datum/async_input/species_pref)
	species_pref.close()
	var/sel_species = species_pref.result
	if(!sel_species) // Player was AFK and did not select a species
		poll_wiz_adept(potential_wizards)
		return
	if(!new_wizard || !new_wizard.client)
		poll_wiz_adept(potential_wizards)
		return

	if(!length(GLOB.wizardstart))
		message_admins("Unable to spawn wizard adept - no valid spawn locations.")
		return

	var/mob/living/carbon/human/M = new(pick(GLOB.wizardstart))

	M.ckey = new_wizard.ckey
	dust_if_respawnable(new_wizard)

	if(sel_gender == "Male")
		M.change_gender(MALE)
		M.change_body_type(MALE)
	else
		M.change_gender(FEMALE)
		M.change_body_type(FEMALE)

	if(sel_species == "Random")
		sel_species = pick("Human", "Tajaran", "Skrell", "Unathi", "Diona", "Vulpkanin", "Nian", "Drask", "Kidan", "Grey", "Skkulakin", "Vox", "Slime", "Machine")
	if(sel_species == "Slime")
		sel_species = "Slime People"
	var/datum/species/S = GLOB.all_species[sel_species]
	var/species = S.type
	M.set_species(species, TRUE)
	M.dna.ready_dna(M)
	M.cleanSE()
	M.overeatduration = 0
	M.age = rand(30, 50)
	M.regenerate_icons()

	M.mind = new
	M.mind.bind_to(M)
	M.mind.set_original_mob(M)
	M.mind.make_wizard_adept()
