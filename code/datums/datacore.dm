/datum/datacore
	var/list/medical = list()
	var/list/general = list()
	var/list/security = list()
	var/list/ai = list()
	//This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/list/locked = list()

/*
We can't just insert in HTML into the TGUI so we need the raw data to play with.
Instead of creating this list over and over when someone leaves their PDA open to the page
we'll only update it when it changes.  The PDA_Manifest global list is zeroed out upon any change
using /datum/datacore/proc/manifest_inject(), or manifest_insert()
*/

GLOBAL_LIST_EMPTY(PDA_Manifest)

/datum/datacore/proc/get_manifest_json()
	if(length(GLOB.PDA_Manifest))
		return
	var/heads[0]
	var/sec[0]
	var/eng[0]
	var/med[0]
	var/sci[0]
	var/ser[0]
	var/sup[0]
	var/bot[0]
	var/misc[0]
	for(var/datum/data/record/t in GLOB.data_core.general)
		var/name = sanitize(t.fields["name"])
		var/rank = sanitize(t.fields["rank"])
		var/real_rank = t.fields["real_rank"]

		var/isactive = t.fields["p_stat"]
		var/department = 0
		var/depthead = 0 			// Department Heads will be placed at the top of their lists.
		if(real_rank in GLOB.command_positions)
			heads[++heads.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			depthead = 1
			if(rank == "Captain" && length(heads) != 1)
				heads.Swap(1,  length(heads))

		if(real_rank in GLOB.active_security_positions)
			sec[++sec.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && length(sec) != 1)
				sec.Swap(1, length(sec))

		if(real_rank in GLOB.engineering_positions)
			eng[++eng.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && length(eng) != 1)
				eng.Swap(1, length(eng))

		if(real_rank in GLOB.medical_positions)
			med[++med.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && length(med) != 1)
				med.Swap(1, length(med))

		if(real_rank in GLOB.science_positions)
			sci[++sci.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && length(sci) != 1)
				sci.Swap(1, length(sci))

		if(real_rank in GLOB.service_positions)
			ser[++ser.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && length(ser) != 1)
				ser.Swap(1, length(ser))

		if(real_rank in GLOB.supply_positions)
			sup[++sup.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1
			if(depthead && length(sup) != 1)
				sup.Swap(1, length(sup))

		if(real_rank in GLOB.nonhuman_positions)
			bot[++bot.len] = list("name" = name, "rank" = rank, "active" = isactive)
			department = 1

		if(!department && !(name in heads))
			misc[++misc.len] = list("name" = name, "rank" = rank, "active" = isactive)


	GLOB.PDA_Manifest = list(\
		"heads" = heads,\
		"sec" = sec,\
		"eng" = eng,\
		"med" = med,\
		"sci" = sci,\
		"ser" = ser,\
		"sup" = sup,\
		"bot" = bot,\
		"misc" = misc\
		)
	return



/datum/datacore/proc/manifest()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		manifest_inject(H)

/datum/datacore/proc/manifest_modify(name, assignment)
	if(length(GLOB.PDA_Manifest))
		GLOB.PDA_Manifest.Cut()
	var/datum/data/record/foundrecord
	var/real_title = assignment

	for(var/datum/data/record/t in GLOB.data_core.general)
		if(t)
			if(t.fields["name"] == name)
				foundrecord = t
				break

	var/list/all_jobs = get_job_datums()
	var/is_custom_job = TRUE

	for(var/datum/job/J in all_jobs)
		var/list/alttitles = get_alternate_titles(J.title)
		if(J.title == real_title)
			is_custom_job = FALSE
		if(assignment in alttitles)
			real_title = J.title
			is_custom_job = FALSE
			break

	if(is_custom_job && foundrecord)
		real_title = foundrecord.fields["real_rank"]

	if(foundrecord)
		foundrecord.fields["rank"] = assignment
		foundrecord.fields["real_rank"] = real_title

GLOBAL_VAR_INIT(record_id_num, 1001)
/datum/datacore/proc/manifest_inject(mob/living/carbon/human/H)
	if(length(GLOB.PDA_Manifest))
		GLOB.PDA_Manifest.Cut()

	if(H.mind && (H.mind.assigned_role != H.mind.special_role))
		var/assignment
		if(H.mind.role_alt_title)
			assignment = H.mind.role_alt_title
		else if(H.mind.assigned_role)
			assignment = H.mind.assigned_role
		else if(H.job)
			assignment = H.job
		else
			assignment = "Unassigned"
		GLOB.crew_list[H.real_name] = assignment

		var/id = num2hex(GLOB.record_id_num++, 6)


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
		G.fields["species"]		= H.dna.species.name
		G.fields["ai_target"]	= "None" // for malf hud
		G.fields["b_dna"]		= H.dna.unique_enzymes

		// Do some ID card checking stuff here to save on resources
		var/card_photo
		if(istype(H.wear_id, /obj/item/card/id))
			var/obj/item/card/id/IDC = H.wear_id
			card_photo = IDC.photo
		else
			card_photo = get_id_photo(H)

		G.fields["photo"] = card_photo
		G.fields["photo-south"] = "data:image/png;base64,[icon2base64(icon(card_photo, dir = SOUTH))]"
		G.fields["photo-west"] = "data:image/png;base64,[icon2base64(icon(card_photo, dir = WEST))]"
		if(H.gen_record && !jobban_isbanned(H, ROLEBAN_RECORDS))
			G.fields["notes"] = H.gen_record
		else
			G.fields["notes"] = "No notes found."
		G.fields["nt_relation"] = H?.client?.prefs?.active_character?.nanotrasen_relation || "Unknown relation."
		general += G

		//Medical Record
		var/datum/data/record/M = new()
		M.fields["id"]			= id
		M.fields["name"]		= H.real_name
		M.fields["blood_type"]	= H.dna.blood_type
		M.fields["b_dna"]		= H.dna.unique_enzymes
		M.fields["mi_dis"]		= "None"
		M.fields["mi_dis_d"]	= "No minor disabilities have been declared."
		M.fields["ma_dis"]		= "None"
		M.fields["ma_dis_d"]	= "No major disabilities have been diagnosed."
		M.fields["alg"]			= "None"
		M.fields["alg_d"]		= "No allergies have been detected in this patient."
		M.fields["cdi"]			= "None"
		M.fields["cdi_d"]		= "No diseases have been diagnosed at the moment."
		if(H.med_record && !jobban_isbanned(H, ROLEBAN_RECORDS))
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
		if(H.sec_record && !jobban_isbanned(H, ROLEBAN_RECORDS))
			S.fields["notes"] = H.sec_record
		else
			S.fields["notes"] = "No notes found."
		LAZYINITLIST(S.fields["comments"])
		security += S

		//Locked Record
		var/datum/data/record/L = new()
		L.fields["id"]			= md5("[H.real_name][H.mind.assigned_role]")
		L.fields["name"]		= H.real_name
		L.fields["rank"] 		= H.mind.assigned_role
		L.fields["age"]			= H.age
		L.fields["sex"]			= capitalize(H.gender)
		L.fields["blood_type"]	= H.dna.blood_type
		L.fields["b_dna"]		= H.dna.unique_enzymes
		L.fields["enzymes"]		= H.dna.SE // Used in respawning
		L.fields["identity"]	= H.dna.UI // "
		L.fields["image"]		= getFlatIcon(H)	//This is god-awful
		locked += L
	return

/proc/get_id_photo(mob/living/carbon/human/H, custom_job = null)
	var/icon/preview_icon = new /icon('icons/mob/human.dmi', "blank")
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	var/obj/item/organ/internal/eyes/eyes_organ = H.get_int_organ(/obj/item/organ/internal/eyes)

	var/icon/temp
	// Tail, Wings, Spines
	if(H.body_accessory && (istype(H.body_accessory, /datum/body_accessory/tail) || istype(H.body_accessory, /datum/body_accessory/wing) || istype(H.body_accessory, /datum/body_accessory/spines)))
		temp = new/icon("icon" = H.body_accessory.icon, "icon_state" = H.body_accessory.icon_state)
		preview_icon.Blend(temp, ICON_OVERLAY)
	else if(H.tail && H.dna.species.bodyflags & HAS_TAIL)
		temp = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[H.tail]_s")
		preview_icon.Blend(temp, ICON_OVERLAY)
	else if(H.wing && H.dna.species.bodyflags & HAS_WING)
		temp = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[H.wing]_s")
		preview_icon.Blend(temp, ICON_OVERLAY)
	else if(H.spines && H.dna.species.bodyflags & HAS_BACK_SPINES)
		temp = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[H.spines]_s")
		preview_icon.Blend(temp, ICON_OVERLAY)

	var/icon/preview_hands = new /icon('icons/blanks/32x32.dmi', "nothing") // Saving these for later.
	for(var/obj/item/organ/external/E in H.bodyparts)
		if(E.limb_name == "l_hand" || E.limb_name == "r_hand")
			preview_hands.Blend(E.get_icon(), ICON_OVERLAY)
			continue
		preview_icon.Blend(E.get_icon(), ICON_OVERLAY)

	// Skin tone
	if(H.dna.species.bodyflags & HAS_SKIN_TONE)
		if(H.s_tone >= 0)
			preview_icon.Blend(rgb(H.s_tone, H.s_tone, H.s_tone), ICON_ADD)
			preview_hands.Blend(rgb(H.s_tone, H.s_tone, H.s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-H.s_tone,  -H.s_tone,  -H.s_tone), ICON_SUBTRACT)
			preview_hands.Blend(rgb(-H.s_tone,  -H.s_tone,  -H.s_tone), ICON_SUBTRACT)

	// Proper Skin color - Fix, you can't have HAS_SKIN_TONE *and* HAS_SKIN_COLOR
	if(H.dna.species.bodyflags & HAS_SKIN_COLOR)
		preview_icon.Blend(H.skin_colour, ICON_ADD)
		preview_hands.Blend(H.skin_colour, ICON_ADD)

	// Markings
	var/icon/t_marking_s
	if(H.dna.species.bodyflags & HAS_TAIL_MARKINGS)
		var/tail_marking = H.m_styles["tail"]
		var/datum/sprite_accessory/tail_marking_style = GLOB.marking_styles_list[tail_marking]
		if(tail_marking_style && tail_marking_style.species_allowed)
			t_marking_s = new/icon("icon" = tail_marking_style.icon, "icon_state" = "[tail_marking_style.icon_state]_s")
			t_marking_s.Blend(H.m_colours["tail"], ICON_ADD)
			if(!(H.body_accessory && istype(H.body_accessory, /datum/body_accessory/body)))
				preview_icon.Blend(t_marking_s, ICON_OVERLAY)
	if((H.dna.species.bodyflags & HAS_HEAD_MARKINGS) || (H.dna.species.bodyflags & HAS_BODY_MARKINGS))
		if(H.dna.species.bodyflags & HAS_BODY_MARKINGS) //Body markings.
			var/body_marking = H.m_styles["body"]
			var/datum/sprite_accessory/body_marking_style = GLOB.marking_styles_list[body_marking]
			if(body_marking_style && body_marking_style.species_allowed)
				var/icon/b_marking_s = new/icon("icon" = body_marking_style.icon, "icon_state" = "[body_marking_style.icon_state]_s")
				b_marking_s.Blend(H.m_colours["body"], ICON_ADD)
				preview_icon.Blend(b_marking_s, ICON_OVERLAY)
		if(H.dna.species.bodyflags & HAS_HEAD_MARKINGS) //Head markings.
			var/head_marking = H.m_styles["head"]
			var/datum/sprite_accessory/head_marking_style = GLOB.marking_styles_list[head_marking]
			if(head_marking_style && head_marking_style.species_allowed)
				var/icon/h_marking_s = new/icon("icon" = head_marking_style.icon, "icon_state" = "[head_marking_style.icon_state]_s")
				h_marking_s.Blend(H.m_colours["head"], ICON_ADD)
				preview_icon.Blend(h_marking_s, ICON_OVERLAY)

	//Underwear
	var/icon/underwear_standing = new /icon('icons/mob/clothing/underwear.dmi', "nude")
	if(H.underwear && H.dna.species.clothing_flags & HAS_UNDERWEAR)
		var/datum/sprite_accessory/underwear/U = GLOB.underwear_list[H.underwear]
		if(U)
			var/u_icon = U.sprite_sheets && (H.dna.species.sprite_sheet_name in U.sprite_sheets) ? U.sprite_sheets[H.dna.species.sprite_sheet_name] : U.icon //Species-fit the undergarment.
			underwear_standing.Blend(new /icon(u_icon, "uw_[U.icon_state]"), ICON_OVERLAY)

	if(H.undershirt && H.dna.species.clothing_flags & HAS_UNDERSHIRT)
		var/datum/sprite_accessory/undershirt/U2 = GLOB.undershirt_full_list[H.undershirt]
		if(U2)
			var/u2_icon = U2.sprite_sheets && (H.dna.species.sprite_sheet_name in U2.sprite_sheets) ? U2.sprite_sheets[H.dna.species.sprite_sheet_name] : U2.icon
			underwear_standing.Blend(new /icon(u2_icon, "us_[U2.icon_state]"), ICON_OVERLAY)

	if(H.socks && H.dna.species.clothing_flags & HAS_SOCKS)
		var/datum/sprite_accessory/socks/U3 = GLOB.socks_list[H.socks]
		if(U3)
			var/u3_icon = U3.sprite_sheets && (H.dna.species.sprite_sheet_name in U3.sprite_sheets) ? U3.sprite_sheets[H.dna.species.sprite_sheet_name] : U3.icon
			underwear_standing.Blend(new /icon(u3_icon, "sk_[U3.icon_state]"), ICON_OVERLAY)

	if(underwear_standing)
		preview_icon.Blend(underwear_standing, ICON_OVERLAY)

	if(!(H.dna.species.bodyflags & NO_EYES))
		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = H.dna.species ? H.dna.species.eyes : "eyes_s")
		if(!eyes_organ)
			return
		eyes_s.Blend(eyes_organ.eye_color, ICON_ADD)
		preview_icon.Blend(eyes_s, ICON_OVERLAY)

	var/list/icon/clothes_layers = new/list(TOTAL_LAYERS)
	for(var/i in 1 to TOTAL_LAYERS)
		clothes_layers[i] = 'icons/blanks/32x32.dmi'
	var/job_clothes = null
	var/datum/job/job_datum = null
	var/datum/outfit/job/job_outfit = null
	if(custom_job)
		job_clothes = custom_job
	else if(H.mind)
		job_clothes = H.mind.assigned_role
	if(job_clothes in SSjobs.name_occupations)
		job_datum = SSjobs.name_occupations[job_clothes]
		job_outfit = job_datum.outfit
	if(!job_outfit)
		switch(job_clothes)
			if("Syndicate Agent")
				job_outfit = /datum/outfit/admin/syndicate
			if("Syndicate Nuclear Operative")
				job_outfit = /datum/outfit/admin/syndicate/operative
			if("Emergency Response Team Officer")
				job_outfit = /datum/outfit/job/response_team/security/amber
			if("Emergency Response Team Engineer")
				job_outfit = /datum/outfit/job/response_team/engineer/amber
			if("Emergency Response Team Medic")
				job_outfit = /datum/outfit/job/response_team/medic/amber
			if("Emergency Response Team Inquisitor")
				job_outfit = /datum/outfit/job/response_team/paranormal/amber
			if("Emergency Response Team Janitor")
				job_outfit = /datum/outfit/job/response_team/janitorial/amber
			if("Emergency Response Team Leader")
				job_datum = /datum/outfit/job/response_team/commander/amber
			if("Emergency Response Team Member")
				job_outfit = /datum/outfit/job/response_team/security/amber
			if("Naked")
				job_outfit = /datum/outfit/naked
			else
				if(H.mind && (H.mind.assigned_role in get_all_centcom_jobs()))
					job_outfit = /datum/outfit/job/ntnavyofficer
				else
					job_outfit = /datum/outfit/job/assistant
	job_outfit = new job_outfit()
	var/datum/robolimb/robohead = GLOB.all_robolimbs[head_organ.model]
	var/monitor_head = robohead && robohead.is_monitor
	clothes_layers = job_outfit.preview_layered_icon(H.dna.species.sprite_sheet_name, H.bodyparts_by_name, null, monitor_head)

	preview_icon.Blend(clothes_layers[UNIFORM_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[ID_LAYER], ICON_OVERLAY)
	preview_icon.Blend(preview_hands, ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[SHOES_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[GLOVES_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[LEFT_EAR_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[RIGHT_EAR_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[BELT_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[SPECIAL_NECK_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[SUIT_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[SPECIAL_BELT_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[NECK_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[SUIT_STORE_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[BACK_LAYER], ICON_OVERLAY)

	//Head Accessory
	var/datum/sprite_accessory/head_accessory/head_accessory_style
	var/icon/head_accessory_s
	if(head_organ.dna.species.bodyflags & HAS_HEAD_ACCESSORY)
		head_accessory_style = GLOB.head_accessory_styles_list[head_organ.ha_style]
		if(head_accessory_style && head_accessory_style.species_allowed)
			head_accessory_s = new/icon("icon" = head_accessory_style.icon, "icon_state" = "[head_accessory_style.icon_state]_s")
			head_accessory_s.Blend(head_organ.headacc_colour, ICON_ADD)
			if(!head_accessory_style.over_hair)
				preview_icon.Blend(head_accessory_s, ICON_OVERLAY)

	var/datum/sprite_accessory/facial_hair/facial_hair_style = GLOB.facial_hair_styles_list[head_organ.f_style]
	var/icon/facial_s
	if(facial_hair_style && facial_hair_style.species_allowed)
		facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		if(istype(head_organ.dna.species, /datum/species/slime))
			facial_s.Blend("[H.skin_colour]A0", ICON_ADD) //A0 = 160 alpha.
		else
			facial_s.Blend(head_organ.facial_colour, ICON_ADD)

		if(facial_hair_style.secondary_theme)
			var/icon/facial_secondary_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_[facial_hair_style.secondary_theme]_s")
			if(!facial_hair_style.no_sec_colour)
				facial_secondary_s.Blend(head_organ.sec_facial_colour, ICON_ADD)
			facial_s.Blend(facial_secondary_s, ICON_OVERLAY)
		if(!facial_hair_style.over_hair)
			preview_icon.Blend(facial_s, ICON_OVERLAY)

	var/datum/sprite_accessory/hair/hair_style = GLOB.hair_styles_full_list[head_organ.h_style]
	if(hair_style)
		if(!hair_style.glasses_over)
			preview_icon.Blend(clothes_layers[GLASSES_LAYER], ICON_OVERLAY)
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		// I'll want to make a species-specific proc for this sooner or later
		// But this'll do for now
		if(istype(head_organ.dna.species, /datum/species/slime))
			hair_s.Blend("[H.skin_colour]A0", ICON_AND) //A0 = 160 alpha.
		else
			hair_s.Blend(head_organ.hair_colour, ICON_ADD)

		var/datum/sprite_accessory/hair_gradient/gradient = GLOB.hair_gradients_list[head_organ.h_grad_style]
		if(gradient)
			var/icon/grad_s = new/icon("icon" = gradient.icon, "icon_state" = gradient.icon_state)
			if(head_organ.h_grad_offset_x)
				grad_s.Shift(EAST, head_organ.h_grad_offset_x)
			if(head_organ.h_grad_offset_y)
				grad_s.Shift(NORTH, head_organ.h_grad_offset_y)
			grad_s.Blend(hair_s, ICON_ADD)
			grad_s.MapColors(COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, head_organ.h_grad_colour)
			grad_s.ChangeOpacity(head_organ.h_grad_alpha / 255)
			hair_s.Blend(grad_s, ICON_OVERLAY)

		if(hair_style.secondary_theme)
			var/icon/hair_secondary_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_[hair_style.secondary_theme]_s")
			if(!hair_style.no_sec_colour)
				hair_secondary_s.Blend(head_organ.sec_hair_colour, ICON_ADD)
			hair_s.Blend(hair_secondary_s, ICON_OVERLAY)

		preview_icon.Blend(hair_s, ICON_OVERLAY)
		if(hair_style.glasses_over)
			preview_icon.Blend(clothes_layers[GLASSES_LAYER], ICON_OVERLAY)
	else
		preview_icon.Blend(clothes_layers[GLASSES_LAYER], ICON_OVERLAY)

		// Head accessories and facial hair that render over top-of-head hair
	if(H.dna.species && (H.dna.species.bodyflags & HAS_HEAD_ACCESSORY) && head_accessory_style && head_accessory_style.species_allowed && head_accessory_style.over_hair)
		preview_icon.Blend(head_accessory_s, ICON_OVERLAY)
	if(facial_hair_style && facial_hair_style.species_allowed && facial_hair_style.over_hair)
		preview_icon.Blend(facial_s, ICON_OVERLAY)

	qdel(head_accessory_s)
	qdel(facial_s)

	preview_icon.Blend(clothes_layers[FACEMASK_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[OVER_MASK_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[HEAD_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[L_HAND_LAYER], ICON_OVERLAY)
	preview_icon.Blend(clothes_layers[R_HAND_LAYER], ICON_OVERLAY)

	//Bus body accessories that go over clothes.
	if(H.body_accessory && istype(H.body_accessory, /datum/body_accessory/body))
		temp = new/icon("icon" = H.body_accessory.icon, "icon_state" = H.body_accessory.icon_state)
		if(H.body_accessory.pixel_x_offset)
			temp.Shift(EAST, H.body_accessory.pixel_x_offset)
		if(H.body_accessory.pixel_y_offset)
			temp.Shift(NORTH, H.body_accessory.pixel_y_offset)
		if(H.dna.species.bodyflags & HAS_SKIN_COLOR)
			temp.Blend(H.skin_colour, H.body_accessory.blend_mode)
		if(t_marking_s)
			temp.Blend(t_marking_s, ICON_OVERLAY)
		preview_icon.Blend(temp, ICON_OVERLAY)

	return new /icon(preview_icon, frame = 1)
