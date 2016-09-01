/hook/startup/proc/createDatacore()
	data_core = new /obj/effect/datacore()
	return 1

/obj/effect/datacore/proc/manifest(var/nosleep = 0)
	spawn()
		if(!nosleep)
			sleep(40)
		for(var/mob/living/carbon/human/H in player_list)
			manifest_inject(H)
		return

/obj/effect/datacore/proc/manifest_modify(var/name, var/assignment)
	if(PDA_Manifest.len)
		PDA_Manifest.Cut()
	var/datum/data/record/foundrecord
	var/real_title = assignment

	for(var/datum/data/record/t in data_core.general)
		if(t)
			if(t.fields["name"] == name)
				foundrecord = t
				break

	var/list/all_jobs = get_job_datums()

	for(var/datum/job/J in all_jobs)
		var/list/alttitles = get_alternate_titles(J.title)
		if(!J)	continue
		if(assignment in alttitles)
			real_title = J.title
			break

	if(foundrecord)
		foundrecord.fields["rank"] = assignment
		foundrecord.fields["real_rank"] = real_title

/obj/effect/datacore/proc/manifest_inject(var/mob/living/carbon/human/H)
	if(PDA_Manifest.len)
		PDA_Manifest.Cut()

	if(H.mind && (H.mind.assigned_role != "MODE"))
		var/assignment
		if(H.mind.role_alt_title)
			assignment = H.mind.role_alt_title
		else if(H.mind.assigned_role)
			assignment = H.mind.assigned_role
		else if(H.job)
			assignment = H.job
		else
			assignment = "Unassigned"

		var/id = add_zero(num2hex(rand(1, 1.6777215E7)), 6)	//this was the best they could come up with? A large random number? *sigh*


		//General Record
		var/datum/data/record/G = new()
		G.fields["id"]			= id
		G.fields["name"]		= H.real_name
		G.fields["real_rank"]	= H.mind.assigned_role
		G.fields["rank"]		= assignment
		G.fields["age"]			= H.age
		G.fields["fingerprint"]	= md5(H.dna.uni_identity)
		G.fields["p_stat"]		= "Active"
		G.fields["m_stat"]		= "Stable"
		G.fields["sex"]			= capitalize(H.gender)
		G.fields["species"]		= H.get_species()
		G.fields["photo"]		= get_id_photo(H)
		G.fields["photo-south"] = "'data:image/png;base64,[icon2base64(icon(G.fields["photo"], dir = SOUTH))]'"
		G.fields["photo-west"] = "'data:image/png;base64,[icon2base64(icon(G.fields["photo"], dir = WEST))]'"
		if(H.gen_record && !jobban_isbanned(H, "Records"))
			G.fields["notes"] = H.gen_record
		else
			G.fields["notes"] = "No notes found."
		general += G

		//Medical Record
		var/datum/data/record/M = new()
		M.fields["id"]			= id
		M.fields["name"]		= H.real_name
		M.fields["b_type"]		= H.b_type
		M.fields["b_dna"]		= H.dna.unique_enzymes
		M.fields["mi_dis"]		= "None"
		M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
		M.fields["ma_dis"]		= "None"
		M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
		M.fields["alg"]			= "None"
		M.fields["alg_d"]		= "No allergies have been detected in this patient."
		M.fields["cdi"]			= "None"
		M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
		if(H.med_record && !jobban_isbanned(H, "Records"))
			M.fields["notes"] = H.med_record
		else
			M.fields["notes"] = "No notes found."
		medical += M

		//Security Record
		var/datum/data/record/S = new()
		S.fields["id"]			= id
		S.fields["name"]		= H.real_name
		S.fields["criminal"]	= "None"
		S.fields["mi_crim"]		= "None"
		S.fields["mi_crim_d"]	= "No minor crime convictions."
		S.fields["ma_crim"]		= "None"
		S.fields["ma_crim_d"]	= "No major crime convictions."
		S.fields["notes"]		= "No notes."
		if(H.sec_record && !jobban_isbanned(H, "Records"))
			S.fields["notes"] = H.sec_record
		else
			S.fields["notes"] = "No notes."
		security += S

		//Locked Record
		var/datum/data/record/L = new()
		L.fields["id"]			= md5("[H.real_name][H.mind.assigned_role]")
		L.fields["name"]		= H.real_name
		L.fields["rank"] 		= H.mind.assigned_role
		L.fields["age"]			= H.age
		L.fields["sex"]			= capitalize(H.gender)
		L.fields["b_type"]		= H.b_type
		L.fields["b_dna"]		= H.dna.unique_enzymes
		L.fields["enzymes"]		= H.dna.SE // Used in respawning
		L.fields["identity"]	= H.dna.UI // "
		L.fields["image"]		= getFlatIcon(H)	//This is god-awful
		locked += L
	return


proc/get_id_photo(var/mob/living/carbon/human/H)
	var/icon/preview_icon = null
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	var/obj/item/organ/internal/eyes/eyes_organ = H.get_int_organ(/obj/item/organ/internal/eyes)

	var/g = "m"
	if(H.gender == FEMALE)
		g = "f"

	var/icon/icobase = H.species.icobase

	preview_icon = new /icon(icobase, "torso_[g]")
	var/icon/temp
	temp = new /icon(icobase, "groin_[g]")
	preview_icon.Blend(temp, ICON_OVERLAY)
	temp = new /icon(icobase, "head_[g]")
	preview_icon.Blend(temp, ICON_OVERLAY)

	//Tail
	if(H.species.tail && H.species.flags & HAS_TAIL)
		temp = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[H.species.tail]_s")
		preview_icon.Blend(temp, ICON_OVERLAY)

	for(var/obj/item/organ/external/E in H.organs)
		preview_icon.Blend(E.get_icon(), ICON_OVERLAY)

	// Skin tone
	if(H.species.bodyflags & HAS_SKIN_TONE)
		if(H.s_tone >= 0)
			preview_icon.Blend(rgb(H.s_tone, H.s_tone, H.s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-H.s_tone,  -H.s_tone,  -H.s_tone), ICON_SUBTRACT)
/* Commented out due to broken-ness, see below comment
	// Skin color
	if(H.species.flags & HAS_SKIN_TONE)
		if(!H.species || H.species.flags & HAS_SKIN_COLOR)
			preview_icon.Blend(rgb(H.r_skin, H.g_skin, H.b_skin), ICON_ADD)
*/
	// Proper Skin color - Fix, you can't have HAS_SKIN_TONE *and* HAS_SKIN_COLOR
	if(H.species.bodyflags & HAS_SKIN_COLOR)
		preview_icon.Blend(rgb(H.r_skin, H.g_skin, H.b_skin), ICON_ADD)

	var/icon/face_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "bald_s")
	if(!(H.species.bodyflags & NO_EYES))
		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = H.species ? H.species.eyes : "eyes_s")
		if(!eyes_organ)
			return
		var/eye_red = eyes_organ.eye_colour[1]
		var/eye_green = eyes_organ.eye_colour[2]
		var/eye_blue = eyes_organ.eye_colour[3]
		eyes_s.Blend(rgb(eye_red, eye_green, eye_blue), ICON_ADD)
		face_s.Blend(eyes_s, ICON_OVERLAY)

	var/datum/sprite_accessory/hair_style = hair_styles_list[head_organ.h_style]
	if(hair_style)
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		// I'll want to make a species-specific proc for this sooner or later
		// But this'll do for now
		if(head_organ.species.name == "Slime People")
			hair_s.Blend(rgb(H.r_skin, H.g_skin, H.b_skin, 160), ICON_ADD)
		else
			hair_s.Blend(rgb(head_organ.r_hair, head_organ.g_hair, head_organ.b_hair), ICON_ADD)
		face_s.Blend(hair_s, ICON_OVERLAY)

	//Head Accessory
	if(head_organ.species.bodyflags & HAS_HEAD_ACCESSORY)
		var/datum/sprite_accessory/head_accessory_style = head_accessory_styles_list[head_organ.ha_style]
		if(head_accessory_style && head_accessory_style.species_allowed)
			var/icon/head_accessory_s = new/icon("icon" = head_accessory_style.icon, "icon_state" = "[head_accessory_style.icon_state]_s")
			head_accessory_s.Blend(rgb(head_organ.r_headacc, head_organ.g_headacc, head_organ.b_headacc), ICON_ADD)
			face_s.Blend(head_accessory_s, ICON_OVERLAY)

	var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[head_organ.f_style]
	if(facial_hair_style && facial_hair_style.species_allowed)
		var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		if(head_organ.species.name == "Slime People")
			facial_s.Blend(rgb(H.r_skin, H.g_skin, H.b_skin, 160), ICON_ADD)
		else
			facial_s.Blend(rgb(head_organ.r_facial, head_organ.g_facial, head_organ.b_facial), ICON_ADD)
		face_s.Blend(facial_s, ICON_OVERLAY)

	//Markings
	if(H.species.bodyflags & HAS_MARKINGS)
		var/datum/sprite_accessory/marking_style = marking_styles_list[H.m_style]
		if(marking_style && marking_style.species_allowed)
			var/icon/markings_s = new/icon("icon" = marking_style.icon, "icon_state" = "[marking_style.icon_state]_s")
			markings_s.Blend(rgb(H.r_markings, H.g_markings, H.b_markings), ICON_ADD)
			face_s.Blend(markings_s, ICON_OVERLAY)

	preview_icon.Blend(face_s, ICON_OVERLAY)


	var/icon/clothes_s = null
	switch(H.mind.assigned_role)
		if("Head of Personnel")
			clothes_s = new /icon('icons/mob/uniform.dmi', "hop_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Nanotrasen Representative")
			clothes_s = new /icon('icons/mob/uniform.dmi', "officer_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
		if("Blueshield")
			clothes_s = new /icon('icons/mob/uniform.dmi', "officer_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/hands.dmi', "swat_gl"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "blueshield"), ICON_OVERLAY)
		if("Magistrate")
			clothes_s = new /icon('icons/mob/uniform.dmi', "really_black_suit_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "judge"), ICON_OVERLAY)
		if("Bartender")
			clothes_s = new /icon('icons/mob/uniform.dmi', "ba_suit_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Botanist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "hydroponics_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Chef")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chef_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Janitor")
			clothes_s = new /icon('icons/mob/uniform.dmi', "janitor_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Librarian")
			clothes_s = new /icon('icons/mob/uniform.dmi', "red_suit_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Quartermaster")
			clothes_s = new /icon('icons/mob/uniform.dmi', "qm_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Cargo Technician")
			clothes_s = new /icon('icons/mob/uniform.dmi', "cargotech_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Shaft Miner")
			clothes_s = new /icon('icons/mob/uniform.dmi', "miner_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Lawyer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "internalaffairs_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Chaplain")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chapblack_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Research Director")
			clothes_s = new /icon('icons/mob/uniform.dmi', "director_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		if("Scientist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "toxinswhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
		if("Chemist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chemistrywhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
		if("Chief Medical Officer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "cmo_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_cmo_open"), ICON_OVERLAY)
		if("Medical Doctor")
			clothes_s = new /icon('icons/mob/uniform.dmi', "medical_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		if("Geneticist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "geneticswhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_gen_open"), ICON_OVERLAY)
		if("Virologist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "virologywhite_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_vir_open"), ICON_OVERLAY)
		if("Psychiatrist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "psych_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_UNDERLAY)
		if("Paramedic")
			clothes_s = new /icon('icons/mob/uniform.dmi', "paramedic_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if("Captain")
			clothes_s = new /icon('icons/mob/uniform.dmi', "captain_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
		if("Head of Security")
			clothes_s = new /icon('icons/mob/uniform.dmi', "hosred_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if("Warden")
			clothes_s = new /icon('icons/mob/uniform.dmi', "warden_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if("Detective")
			clothes_s = new /icon('icons/mob/uniform.dmi', "detective_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "detective"), ICON_OVERLAY)
		if("Security Pod Pilot")
			clothes_s = new /icon('icons/mob/uniform.dmi', "secred_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "bomber"), ICON_OVERLAY)
		if("Brig Physician")
			clothes_s = new /icon('icons/mob/uniform.dmi', "medical_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "fr_jacket_open"), ICON_OVERLAY)
		if("Security Officer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "secred_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if("Chief Engineer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "chief_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Station Engineer")
			clothes_s = new /icon('icons/mob/uniform.dmi', "engine_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "orange"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Life Support Specialist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "atmos_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Mechanic")
			clothes_s = new /icon('icons/mob/uniform.dmi', "mechanic_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "orange"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
		if("Roboticist")
			clothes_s = new /icon('icons/mob/uniform.dmi', "robotics_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		else if(H.mind.assigned_role in get_all_centcom_jobs())
			clothes_s = new /icon('icons/mob/uniform.dmi', "officer_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
		else
			clothes_s = new /icon('icons/mob/uniform.dmi', "grey_s")
			clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
	preview_icon.Blend(face_s, ICON_OVERLAY) // Why do we do this twice
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)
	qdel(face_s)
	qdel(clothes_s)

	return preview_icon
