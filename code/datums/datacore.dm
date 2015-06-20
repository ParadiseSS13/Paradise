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
		if (t)
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
		G.fields["sex"]			= H.gender
		G.fields["species"]		= H.get_species()
		G.fields["photo"]		= get_id_photo(H)
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
		L.fields["sex"]			= H.gender
		L.fields["b_type"]		= H.b_type
		L.fields["b_dna"]		= H.dna.unique_enzymes
		L.fields["enzymes"]		= H.dna.SE // Used in respawning
		L.fields["identity"]	= H.dna.UI // "
		L.fields["image"]		= getFlatIcon(H)	//This is god-awful
		locked += L
	return


proc/get_id_photo(var/mob/living/carbon/human/H)
	H.regenerate_icons()
	var/icon/preview_icon = icon(H.icon)
	for(var/image/I in H.overlays_standing)
		if(I && I.icon)
			preview_icon.Blend(icon(I.icon, I.icon_state), ICON_OVERLAY)
	return preview_icon