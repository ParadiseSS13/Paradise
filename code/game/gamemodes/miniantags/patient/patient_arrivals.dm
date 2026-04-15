/datum/event/patient_arrivals
	name = "Patient Arrivals"
	role_weights = list(ASSIGNMENT_MEDICAL = 5)
	role_requirements = list(ASSIGNMENT_MEDICAL = 3)
	nominal_severity = EVENT_LEVEL_MODERATE
	startWhen = 5 MINUTES
	/// Maximum number of spawns, should scale with number of medical staff.
	var/max_spawn = 0
	/// If the event ran successfully
	var/success_run
	/// Number of tots spawned in
	var/tot_number = 0
	/// Number of players spawned in
	var/spawned_in = 0
	/// Number of medical staff
	var/med_count = 0
	/// Number of antags
	var/antag_count = 0
	/// This would be a very rare way for antagonists to visit the station. For obvious reasons.
	var/max_antag = 1
	/// Chance of being antag
	var/chance = 5
	/// All possible patient hardships
	var/valid_patient_types = list("explosion", "war", "fire", "disease", "radiation", "general")
	/// What type of hardship these patients are suffering
	var/patient_type = null
	/// Skeleton disease event to keep track of diseases
	var/datum/event/disease_outbreak/disease_ref
	/// What disease most patients will have, if disease is chosen
	var/chosen_disease = null
	/// Where the patients are from, used in several announcements
	var/patient_origin = "a secret underground supermatter assembly plant"
	/// The disaster description, used in several announcements
	var/disaster_desc = "Something went really wrong in "

/datum/event/patient_arrivals/New(mapload, event_type = null)
	if(!event_type)
		return ..()
	if(!(event_type in valid_patient_types))
		error("Tried to spawn patient_arrivals event of type [event_type], which doesn't exist. Valid types are [english_list(valid_patient_types)].")
		return FALSE
	patient_type = event_type
	return ..()

/datum/event/patient_arrivals/setup()
	patient_type = pick(valid_patient_types)
	disease_ref = new disease_ref(skeleton = TRUE)
	if(isemptylist(disease_ref.diseases_minor) || isemptylist(disease_ref.diseases_moderate_major))
		disease_ref.populate_diseases()
	if(patient_type == "disease")
		if(isemptylist(disease_ref.transmissable_symptoms))
			disease_ref.populate_symptoms()
		// Sometimes we have a known moderate/major disease, usually it's an advanced virus
		if(prob(40))
			var/datum/disease/virus = pick(disease_ref.diseases_moderate_major)
			chosen_disease = new virus()
		else
			chosen_disease = disease_ref.create_virus(4)
	for(var/mob/living/player in GLOB.mob_list)
		if(player.mind && player.stat != DEAD)
			med_count++
			if(player.mind.special_role)
				antag_count++
				continue
	max_spawn = min(med_count + 1, 10)
	if(SSticker && istype(SSticker.mode, /datum/game_mode/extended))
		chance = 100

/datum/event/patient_arrivals/start()
	// Let's just avoid trouble, sending people into those is probably bad.
	if(GAMEMODE_IS_CULT || GAMEMODE_IS_WIZARD || GAMEMODE_IS_NUCLEAR)
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
		EC.next_event_time = world.time + 1 MINUTES
		log_debug("Patient Arrivals roll canceled due to gamemode. Rolling another midround in 60 seconds.")
		return
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_GAMMA) // Who would send more people to somewhere that's not safe?
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
		EC.next_event_time = world.time + 1 MINUTES
		log_debug("Patient Arrivals roll canceled due to heightened alert. Rolling another midround in 60 seconds.")
		return

	INVOKE_ASYNC(src, PROC_REF(spawn_arrivals))

/datum/event/patient_arrivals/proc/spawn_arrivals()
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a Patient?", null, TRUE)
	// We'll keep spawning new patients until we hit the max_spawn cap of patients.
	while(max_spawn > 0 && length(candidates))
		var/turf/picked_loc = pick(GLOB.latejoin)
		// Taking a random player from the candidate list.
		var/mob/patient_mob = pick_n_take(candidates)
		max_spawn--
		var/datum/patient/patient_picked = pick(subtypesof(/datum/patient))
		if(!istype(patient_mob))
			continue
		var/mob/living/carbon/human/patient_human = new patient_picked.patient_species(picked_loc)
		// Picking a random objective, as all objectives are a subtype of /objective/patient.
		var/obj_patient = pick(subtypesof(/datum/objective/patient))
		var/datum/objective/patient/picked_objective = new obj_patient()
		// Handles outfit, account and other stuff.
		patient_human.ckey = patient_mob.ckey
		patient_human.dna.species.after_equip_job(null, patient_human)
		patient_human.age = rand(21, patient_human.dna.species.max_age)
		if(prob(50))
			patient_human.change_gender(FEMALE)
		set_appearance(patient_human)
		patient_human.equipOutfit(patient_picked.patient_outfit)
		GLOB.data_core.manifest_inject(patient_human) // Proc checks if they have a special role before adding to the manifest, if they do, they aren't added. This needs to be done before adding the special role.
		patient_human.mind.special_role = SPECIAL_ROLE_TOURIST
		// Rolls a 5% probability, checks if we haven't already made a tot, and checks if there's space for a new tot!
		// If any is false, we don't make a new patient tot
		if(prob(chance) && tot_number < 1 && antag_count < max_antag && (ROLE_TRAITOR in patient_human.client.prefs.be_special) && !jobban_isbanned(patient_human, ROLE_TRAITOR))
			if(player_old_enough_antag(patient_human.client, ROLE_TRAITOR))
				tot_number++
				patient_human.mind.add_antag_datum(/datum/antagonist/traitor)
		add_ailments(patient_human)
		if(patient_human.mind.special_role != SPECIAL_ROLE_TRAITOR)
			patient_human.mind.add_mind_objective(picked_objective)
			greeting(patient_human)
		success_run = TRUE
		spawned_in++
	if(success_run)
		log_debug("Patient event made: [tot_number] traitors.")
		populate_announcement()
		if(patient_type == "radiation")
			radiation_pulse(center_of_shuttle, 800, emission_type = BETA_RAD)
		var/transport_reason = pick(
			"We don't have the kind of specialized skills necessary to address their needs",
			"We're simply over capacity",
			"We've heard glowing reviews of your medical department",
			"Supplies are scarce and our staff have also been affected",
			"They have zero medical professionals on staff",
			"We suspect there's something greater at hand here than a simple accident, and we have dedicated all our resources to the investigation",
			"Many of them can't afford treatment in our highly advanced facilities",
			"They begged and begged us to provide them transport out of that disaster",
		)
		GLOB.minor_announcement.Announce("[disaster_desc], we have been inundated with patients. [transport_reason], so we're sending them to you. We trust that you will care for them in their time of need and provide work to the able after their recovery.")

/datum/event/patient_arrivals/proc/populate_announcement()
	switch(patient_type)
		if("explosion")
			disaster_desc = "After a catastrophic explosion on [patient_origin]"
		if("war")
			var/warring_parties = pick(
				"splinter states of the Kidan Anarchy",
				"Moghes and other Unathi holdings",
				"Gorlex Marauders and the TSF",
				"wizards and the Cult of Nar'sie",
			)
			disaster_desc = "Due to the ongoing armed conflict between [warring_parties]"
		if("fire")
			disaster_desc = "After the Syndicate started a plasma fire at [patient_origin]"
		if("disease")
			disaster_desc = "Ever since the outbreak of a terrible disease on [patient_origin]"
		if("radiation")
			disaster_desc = "Because of a terrible reactor accident on [patient_origin]"
			radiation_pulse(center_of_shuttle, 800, emission_type = BETA_RAD)
		if("general")
			disaster_desc = "After the [pick("shutdown", "destruction")] of the medical facilities on [patient_origin]"

/datum/event/patient_arrivals/proc/add_ailments(mob/living/carbon/human/patient)
	ADD_TRAIT(patient, TRAIT_MUTE, TRAIT_GENERIC)
	switch(patient_type)
		if("explosion")
			if(prob(60))
				var/obj/item/organ/internal/ears/ears = patient.get_int_organ(/obj/item/organ/internal/ears)
				if(istype(ears))
					ears.receive_damage(rand(5, 20))
			if(prob(50))
				for(var/count in 1 to 10)
					var/obj/item/shrapnel/embedder = new /obj/item/shrapnel()
					if(!patient.try_embed_object(embedder, silent = TRUE))
						qdel(embedder)
			if(prob(30))
				patient.apply_damage(rand(10, 30), BURN, BOMB)
			if(prob(20))
				for(var/count in 1 to 30)
					var/obj/item/shrapnel/embedder = new /obj/item/shrapnel()
					if(!patient.try_embed_object(embedder, silent = TRUE))
						qdel(embedder)
			if(prob(10))
				patient.apply_damage(rand(40, 70), BURN, BOMB)
		if("war")
			if(prob(80))
				var/obj/item/organ/internal/ears/ears = patient.get_int_organ(/obj/item/organ/internal/ears)
				if(istype(ears))
					ears.receive_damage(rand(1, 15))
			if(prob(50))
				for(var/count in 1 to 10)
					var/obj/item/shrapnel/embedder = new /obj/item/shrapnel()
					if(!patient.try_embed_object(embedder, silent = TRUE))
						qdel(embedder)
			if(prob(30))
				patient.apply_damage(rand(20, 40), BRUTE)
			if(prob(20))
				patient.apply_damage(rand(5, 15), TOX)
			if(prob(10))
				patient.apply_damage(rand(10, 30), BURN)
		if("fire")
			if(prob(80))
				patient.apply_damage(rand(5, 20), BURN)
			if(prob(30))
				patient.apply_damage(rand(30, 70), BURN)
		if("disease")
			if(prob(95))
				patient.ForceContractDisease(chosen_disease, TRUE, TRUE)
			else
				if(prob(75)) // An unfortunate someone with a different disease who got lumped in
					var/datum/disease/virus = pick(disease_ref.diseases_moderate_major)
					patient.ForceContractDisease(new virus(), TRUE, TRUE)
				else // A very unfortunate someone with a trivial disease who got lumped in
					var/datum/disease/virus = pick(disease_ref.diseases_minor)
					patient.ForceContractDisease(new virus(), TRUE, TRUE)
		if("radiation")
			if(prob(80))
				randmutb(patient)
			if(prob(40))
				randmuti(patient)
			if(prob(20))
				randmutg(patient)
			if(prob(10))
				randmutb(patient)
			if(prob(5))
				randmuti(patient)
			if(prob(5))
				randmutb(patient)
		if("general")
			var/cause = pick("addict", "virus", "damage", "poisoned", "allergy", "organ")
			switch(cause)
				if("addict")
					// give patient some intoxicant and one or more addictions?
				if("virus")
					var/datum/disease/virus = pick(disease_ref.diseases_minor)
					patient.ForceContractDisease(new virus(), TRUE, TRUE)
				if("damage")
					patient.apply_damage(rand(20,80), pick(BRUTE, BURN, TOX))
				if("poisoned")
					// give patient one or more poisons
				if("allergy")
					// load patient up with histamine
				if("organ")
					// deal random internal organ damage
		else
			// this shouldn't happen but better a failsafe than nothing
			patient.apply_damage(100)
	REMOVE_TRAIT(patient, TRAIT_MUTE, TRAIT_GENERIC)

// from tourist arrivals but it definitely doesn't feel adequate for the variety of alien species we've got
/datum/event/patient_arrivals/proc/set_appearance(mob/living/carbon/human/patient)
	var/obj/item/organ/external/head/head_organ = patient.get_organ("head")
	var/hair_c = pick("#8B4513", "#000000", "#FF4500", "#FFD700") // Brown, black, red, blonde
	var/eye_c = pick("#000000", "#8B4513", "1E90FF") // Black, brown, blue
	var/skin_tone = rand(-120, 20)

	head_organ.facial_colour = hair_c
	head_organ.sec_facial_colour = hair_c
	head_organ.hair_colour = hair_c
	head_organ.sec_hair_colour = hair_c
	patient.change_eye_color(eye_c)
	patient.s_tone = skin_tone
	head_organ.h_style = random_hair_style(patient.gender, head_organ.dna.species.name)
	head_organ.f_style = random_facial_hair_style(patient.gender, head_organ.dna.species.name)

	patient.regenerate_icons()
	patient.update_body()
	patient.update_dna()

// Patient datum stuff, mostly being species and outfit.
/datum/patient
	var/patient_outfit
	var/patient_species

/datum/patient/human
	patient_species = /mob/living/carbon/human
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/unathi
	patient_species = /mob/living/carbon/human/unathi
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/vulp
	patient_species = /mob/living/carbon/human/vulpkanin
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/skulk
	patient_species = /mob/living/carbon/human/skulk
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/skrell
	patient_species = /mob/living/carbon/human/skrell
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/grey
	patient_species = /mob/living/carbon/human/grey
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/nian
	patient_species = /mob/living/carbon/human/moth
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/vox
	patient_species = /mob/living/carbon/human/vox
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/kidan
	patient_species = /mob/living/carbon/human/kidan
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/tajaran
	patient_species = /mob/living/carbon/human/tajaran
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/drask
	patient_species = /mob/living/carbon/human/drask
	patient_outfit = /datum/outfit/admin/patient

/datum/patient/slime
	patient_species = /mob/living/carbon/human/slime
	patient_outfit = /datum/outfit/admin/patient
