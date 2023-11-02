/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(!user)
		return

	var/datum/species/S = GLOB.all_species[active_character.species]
	if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				active_character.ResetJobs()
				active_character.SetChoices(user)
			if("learnaboutselection")
				if(GLOB.configuration.url.wiki_url)
					if(alert("Would you like to open the Job selection info in your browser?", "Open Job Selection", "Yes", "No") == "Yes")
						user << link("[GLOB.configuration.url.wiki_url]/index.php/Job_Selection_and_Assignment")
				else
					to_chat(user, "<span class='danger'>The Wiki URL is not set in the server configuration.</span>")
			if("random")
				if(active_character.alternate_option == GET_RANDOM_JOB || active_character.alternate_option == BE_ASSISTANT)
					active_character.alternate_option += 1
				else if(active_character.alternate_option == RETURN_TO_LOBBY)
					active_character.alternate_option = 0
				else
					return 0
				active_character.SetChoices(user)
			if("alt_title")
				var/datum/job/job = locate(href_list["job"])
				if(job)
					var/choices = list(job.title) + job.alt_titles
					var/choice = input("Pick a title for [job.title].", "Character Generation", active_character.GetPlayerAltTitle(job)) as anything in choices | null
					if(choice)
						active_character.SetPlayerAltTitle(job, choice)
						active_character.SetChoices(user)
			if("input")
				SetJob(user, href_list["text"])
			if("setJobLevel")
				UpdateJobPreference(user, href_list["text"], text2num(href_list["level"]))
			else
				active_character.SetChoices(user)
		return 1
	else if(href_list["preference"] == "disabilities")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=disabil")
				ShowChoices(user)
			if("reset")
				active_character.disabilities = 0
				active_character.SetDisabilities(user)
			if("input")
				var/dflag=text2num(href_list["disability"])
				if(dflag >= 0) // Toggle it.
					active_character.disabilities ^= text2num(href_list["disability"]) //MAGIC
				active_character.SetDisabilities(user)
			else
				active_character.SetDisabilities(user)
		return 1

	else if(href_list["preference"] == "records")
		if(text2num(href_list["record"]) >= 1)
			active_character.SetRecords(user)
			return
		else
			user << browse(null, "window=records")

		if(href_list["task"] == "med_record")
			var/medmsg = input(usr,"Set your medical notes here.","Medical Records",html_decode(active_character.med_record)) as message

			if(medmsg != null)
				medmsg = copytext(medmsg, 1, MAX_PAPER_MESSAGE_LEN)
				medmsg = html_encode(medmsg)

				active_character.med_record = medmsg
				active_character.SetRecords(user)

		if(href_list["task"] == "sec_record")
			var/secmsg = input(usr,"Set your security notes here.","Security Records",html_decode(active_character.sec_record)) as message

			if(secmsg != null)
				secmsg = copytext(secmsg, 1, MAX_PAPER_MESSAGE_LEN)
				secmsg = html_encode(secmsg)

				active_character.sec_record = secmsg
				active_character.SetRecords(user)

		if(href_list["task"] == "gen_record")
			var/genmsg = input(usr,"Set your employment notes here.","Employment Records",html_decode(active_character.gen_record)) as message

			if(genmsg != null)
				genmsg = copytext(genmsg, 1, MAX_PAPER_MESSAGE_LEN)
				genmsg = html_encode(genmsg)

				active_character.gen_record = genmsg
				active_character.SetRecords(user)

	if(href_list["preference"] == "gear")
		if(href_list["toggle_gear"])
			var/datum/gear/TG = GLOB.gear_datums[text2path(href_list["toggle_gear"])]
			if(TG && (TG.type in active_character.loadout_gear))
				active_character.loadout_gear -= TG.type
			else
				if(TG.donator_tier && user.client.donator_level < TG.donator_tier)
					to_chat(user, "<span class='warning'>That gear is only available at a higher donation tier than you are on.</span>")
					return
				build_loadout(TG)

		else if(href_list["gear"] && href_list["tweak"]) // NYI
			var/datum/gear/gear = GLOB.gear_datums[text2path(href_list["gear"])]
			var/datum/gear_tweak/tweak = locate(href_list["tweak"])
			if(!tweak || !istype(gear) || !(tweak in gear.gear_tweaks))
				return
			var/metadata = tweak.get_metadata(user, active_character.get_tweak_metadata(gear, tweak))
			if(!metadata)
				return
			active_character.set_tweak_metadata(gear, tweak, metadata)
		else if(href_list["select_category"])
			gear_tab = href_list["select_category"]
		else if(href_list["clear_loadout"])
			active_character.loadout_gear.Cut()

		ShowChoices(user)
		return

	switch(href_list["task"])
		if("random")
			var/datum/robolimb/robohead
			if(S.bodyflags & ALL_RPARTS)
				var/head_model = "[!active_character.rlimb_data["head"] ? "Morpheus Cyberkinetics" : active_character.rlimb_data["head"]]"
				robohead = GLOB.all_robolimbs[head_model]
			switch(href_list["preference"])
				if("name")
					active_character.real_name = random_name(active_character.gender, active_character.species)
					if(isnewplayer(user))
						var/mob/new_player/N = user
						N.new_player_panel_proc()
				if("age")
					active_character.age = rand(S.min_age , S.max_age)
				if("hair")
					if(!(S.bodyflags & BALD))
						active_character.h_colour = rand_hex_color()
				if("secondary_hair")
					if(!(S.bodyflags & BALD))
						active_character.h_sec_colour = rand_hex_color()
				if("h_style")
					active_character.h_style = random_hair_style(active_character.gender, active_character.species, robohead)
				if("facial")
					if(!(S.bodyflags & SHAVED))
						active_character.f_colour = rand_hex_color()
				if("secondary_facial")
					if(!(S.bodyflags & SHAVED))
						active_character.f_sec_colour = rand_hex_color()
				if("f_style")
					active_character.f_style = random_facial_hair_style(active_character.gender, active_character.species, robohead)
				if("headaccessory")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
						active_character.hacc_colour = rand_hex_color()
				if("ha_style")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
						active_character.ha_style = random_head_accessory(active_character.species)
				if("m_style_head")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						active_character.m_styles["head"] = random_marking_style("head", active_character.species, robohead, null, active_character.alt_head)
				if("m_head_colour")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						active_character.m_colours["head"] = rand_hex_color()
				if("m_style_body")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings.
						active_character.m_styles["body"] = random_marking_style("body", active_character.species)
				if("m_body_colour")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings.
						active_character.m_colours["body"] = rand_hex_color()
				if("m_style_tail")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						active_character.m_styles["tail"] = random_marking_style("tail", active_character.species, null, active_character.body_accessory)
				if("m_tail_colour")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						active_character.m_colours["tail"] = rand_hex_color()
				if("underwear")
					active_character.underwear = random_underwear(active_character.gender, active_character.species)
					ShowChoices(user)
				if("undershirt")
					active_character.undershirt = random_undershirt(active_character.gender, active_character.species)
					ShowChoices(user)
				if("socks")
					active_character.socks = random_socks(active_character.gender, active_character.species)
					ShowChoices(user)
				if("eyes")
					active_character.e_colour = rand_hex_color()
				if("s_tone")
					if(S.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
						active_character.s_tone = random_skin_tone()
				if("s_color")
					if(S.bodyflags & HAS_SKIN_COLOR)
						active_character.s_colour = rand_hex_color()
				if("bag")
					active_character.backbag = pick(GLOB.backbaglist)
				if("all")
					active_character.randomise()
		if("input")
			switch(href_list["preference"])
				if("name")
					var/raw_name = clean_input("Choose your character's name:", "Character Preference", , user)
					if(!isnull(raw_name)) // Check to ensure that the user entered text (rather than cancel.)
						var/new_name = reject_bad_name(raw_name, 1)
						if(new_name)
							active_character.real_name = new_name
							if(isnewplayer(user))
								var/mob/new_player/N = user
								N.new_player_panel_proc()
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([S.min_age]-[S.max_age])", "Character Preference") as num|null
					if(new_age)
						active_character.age = max(min(round(text2num(new_age)), S.max_age), S.min_age)
				if("species")
					var/list/new_species = list()
					var/prev_species = active_character.species

					for(var/_species in GLOB.all_species)
						if(can_use_species(user, _species))
							new_species += _species

					active_character.species = input("Please select a species", "Character Generation", null) in sortTim(new_species, GLOBAL_PROC_REF(cmp_text_asc))
					var/datum/species/NS = GLOB.all_species[active_character.species]
					if(!istype(NS)) //The species was invalid. Notify the user and fail out.
						active_character.species = prev_species
						to_chat(user, "<span class='warning'>Invalid species, please pick something else.</span>")
						return
					if(prev_species != active_character.species)
						active_character.age = clamp(active_character.age, NS.min_age, NS.max_age)
						if(NS.has_gender && active_character.gender == PLURAL)
							active_character.gender = pick(MALE,FEMALE)
						var/datum/robolimb/robohead
						if(NS.bodyflags & ALL_RPARTS)
							var/head_model = "[!active_character.rlimb_data["head"] ? "Morpheus Cyberkinetics" : active_character.rlimb_data["head"]]"
							robohead = GLOB.all_robolimbs[head_model]
						//grab one of the valid hair styles for the newly chosen species
						active_character.h_style = random_hair_style(active_character.gender, active_character.species, robohead)

						//grab one of the valid facial hair styles for the newly chosen species
						active_character.f_style = random_facial_hair_style(active_character.gender, active_character.species, robohead)

						if(NS.bodyflags & HAS_HEAD_ACCESSORY) //Species that have head accessories.
							active_character.ha_style = random_head_accessory(active_character.species)
						else
							active_character.ha_style = "None" // No Vulp ears on Unathi
							active_character.hacc_colour = rand_hex_color()

						if(NS.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
							active_character.m_styles["head"] = random_marking_style("head", active_character.species, robohead, null, active_character.alt_head)
						else
							active_character.m_styles["head"] = "None"
							active_character.m_colours["head"] = "#000000"

						if(NS.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
							active_character.m_styles["body"] = random_marking_style("body", active_character.species)
						else
							active_character.m_styles["body"] = "None"
							active_character.m_colours["body"] = "#000000"

						if(NS.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
							active_character.m_styles["tail"] = random_marking_style("tail", active_character.species, null, active_character.body_accessory)
						else
							active_character.m_styles["tail"] = "None"
							active_character.m_colours["tail"] = "#000000"

						// Don't wear another species' underwear!
						var/datum/sprite_accessory/SA = GLOB.underwear_list[active_character.underwear]
						if(!SA || !(active_character.species in SA.species_allowed))
							active_character.underwear = random_underwear(active_character.gender, active_character.species)

						SA = GLOB.undershirt_list[active_character.undershirt]
						if(!SA || !(active_character.species in SA.species_allowed))
							active_character.undershirt = random_undershirt(active_character.gender, active_character.species)

						SA = GLOB.socks_list[active_character.socks]
						if(!SA || !(active_character.species in SA.species_allowed))
							active_character.socks = random_socks(active_character.gender, active_character.species)

						//reset skin tone and colour
						if(NS.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
							random_skin_tone(active_character.species)
						else
							active_character.s_tone = 0

						if(!(NS.bodyflags & HAS_SKIN_COLOR))
							active_character.s_colour = "#000000"

						active_character.alt_head = "None" //No alt heads on species that don't have them.
						active_character.speciesprefs = 0 //My Vox tank shouldn't change how my future Grey talks.
						active_character.body_accessory = random_body_accessory(NS.name, NS.optional_body_accessory)

						//Reset prosthetics.
						active_character.organ_data = list()
						active_character.rlimb_data = list()

						if(!(NS.autohiss_basic_map))
							active_character.autohiss_mode = AUTOHISS_OFF
				if("speciesprefs")
					active_character.speciesprefs = !active_character.speciesprefs //Starts 0, so if someone clicks the button up top there, this won't be 0 anymore. If they click it again, it'll go back to 0.
				if("language")
//						var/languages_available
					var/list/new_languages = list("None")
					for(var/L in GLOB.all_languages)
						var/datum/language/lang = GLOB.all_languages[L]
						if(!(lang.flags & RESTRICTED))
							new_languages += lang.name

					active_character.language = input("Please select a secondary language", "Character Generation", null) in sortTim(new_languages, GLOBAL_PROC_REF(cmp_text_asc))

				if("autohiss_mode")
					if(S.autohiss_basic_map)
						var/list/autohiss_choice = list("Off" = AUTOHISS_OFF, "Basic" = AUTOHISS_BASIC, "Full" = AUTOHISS_FULL)
						var/new_autohiss_pref = input(user, "Choose your character's auto-accent level:", "Character Preference") as null|anything in autohiss_choice
						if(new_autohiss_pref)
							active_character.autohiss_mode = autohiss_choice[new_autohiss_pref]

				if("metadata")
					var/new_metadata = input(user, "Enter any information you'd like others to see, such as Roleplay-preferences:", "Game Preference" , active_character.metadata)  as message|null
					if(new_metadata)
						active_character.metadata = sanitize(copytext_char(new_metadata,1,MAX_MESSAGE_LEN))	// SS220 EDIT - ORIGINAL: copytext

				if("b_type")
					var/new_b_type = input(user, "Choose your character's blood-type:", "Character Preference") as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )
					if(new_b_type)
						active_character.b_type = new_b_type

				if("hair")
					if(!(S.bodyflags & BALD))
						var/input = "Choose your character's hair colour:"
						var/new_hair = input(user, input, "Character Preference", active_character.h_colour) as color|null
						if(new_hair)
							active_character.h_colour = new_hair

				if("secondary_hair")
					if(!(S.bodyflags & BALD))
						var/datum/sprite_accessory/hair_style = GLOB.hair_styles_public_list[active_character.h_style]
						if(hair_style.secondary_theme && !hair_style.no_sec_colour)
							var/new_hair = input(user, "Choose your character's secondary hair colour:", "Character Preference", active_character.h_sec_colour) as color|null
							if(new_hair)
								active_character.h_sec_colour = new_hair

				if("h_style")
					var/list/valid_hairstyles = list()
					for(var/hairstyle in GLOB.hair_styles_public_list)
						var/datum/sprite_accessory/SA = GLOB.hair_styles_public_list[hairstyle]

						if(hairstyle == "Bald") //Just in case.
							valid_hairstyles += hairstyle
							continue
						if(S.bodyflags & ALL_RPARTS) //Species that can use prosthetic heads.
							var/head_model
							if(!active_character.rlimb_data["head"]) //Handle situations where the head is default.
								head_model = "Morpheus Cyberkinetics"
							else
								head_model = active_character.rlimb_data["head"]
							var/datum/robolimb/robohead = GLOB.all_robolimbs[head_model]
							if((active_character.species in SA.species_allowed) && robohead.is_monitor && ((SA.models_allowed && (robohead.company in SA.models_allowed)) || !SA.models_allowed)) //If this is a hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
								valid_hairstyles += hairstyle //Give them their hairstyles if they do.
							else
								if(!robohead.is_monitor && ("Human" in SA.species_allowed)) /*If the hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																							But if the user has a robotic humanoid head and the hairstyle can fit humans, let them use it as a wig. */
									valid_hairstyles += hairstyle
						else //If the user is not a species who can have robotic heads, use the default handling.
							if(active_character.species in SA.species_allowed) //If the user's head is of a species the hairstyle allows, add it to the list.
								valid_hairstyles += hairstyle

					sortTim(valid_hairstyles, GLOBAL_PROC_REF(cmp_text_asc)) //this alphabetizes the list
					var/new_h_style = input(user, "Choose your character's hair style:", "Character Preference") as null|anything in valid_hairstyles
					if(new_h_style)
						active_character.h_style = new_h_style

				if("h_grad_style")
					var/result = input(user, "Choose your character's hair gradient style:", "Character Preference") as null|anything in GLOB.hair_gradients_list
					if(result)
						active_character.h_grad_style = result

				if("h_grad_offset")
					var/result = input(user, "Enter your character's hair gradient offset as a comma-separated value (x,y). Example:\n0,0 (no offset)\n5,0 (5 pixels to the right)", "Character Preference") as null|text
					if(result)
						var/list/expl = splittext(result, ",")
						if(length(expl) == 2)
							active_character.h_grad_offset_x = clamp(text2num(expl[1]) || 0, -16, 16)
							active_character.h_grad_offset_y = clamp(text2num(expl[2]) || 0, -16, 16)

				if("h_grad_colour")
					var/result = input(user, "Choose your character's hair gradient colour:", "Character Preference", active_character.h_grad_colour) as color|null
					if(result)
						active_character.h_grad_colour = result

				if("h_grad_alpha")
					var/result = input(user, "Choose your character's hair gradient alpha (0-255):", "Character Preference", active_character.h_grad_alpha) as num|null
					if(!isnull(result))
						active_character.h_grad_alpha = clamp(result, 0, 255)

				if("headaccessory")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species with head accessories.
						var/input = "Choose the colour of your your character's head accessory:"
						var/new_head_accessory = input(user, input, "Character Preference", active_character.hacc_colour) as color|null
						if(new_head_accessory)
							active_character.hacc_colour = new_head_accessory

				if("ha_style")
					if(S.bodyflags & HAS_HEAD_ACCESSORY) //Species with head accessories.
						var/list/valid_head_accessory_styles = list()
						for(var/head_accessory_style in GLOB.head_accessory_styles_list)
							var/datum/sprite_accessory/H = GLOB.head_accessory_styles_list[head_accessory_style]
							if(!(active_character.species in H.species_allowed))
								continue

							valid_head_accessory_styles += head_accessory_style

						sortTim(valid_head_accessory_styles, GLOBAL_PROC_REF(cmp_text_asc))
						var/new_head_accessory_style = input(user, "Choose the style of your character's head accessory:", "Character Preference") as null|anything in valid_head_accessory_styles
						if(new_head_accessory_style)
							active_character.ha_style = new_head_accessory_style

				if("alt_head")
					if(active_character.organ_data["head"] == "cyborg")
						return
					if(S.bodyflags & HAS_ALT_HEADS) //Species with alt heads.
						var/list/valid_alt_heads = list()
						valid_alt_heads["None"] = GLOB.alt_heads_list["None"] //The only null entry should be the "None" option
						for(var/alternate_head in GLOB.alt_heads_list)
							var/datum/sprite_accessory/alt_heads/head = GLOB.alt_heads_list[alternate_head]
							if(!(active_character.species in head.species_allowed))
								continue

							valid_alt_heads += alternate_head

						var/new_alt_head = input(user, "Choose your character's alternate head style:", "Character Preference") as null|anything in valid_alt_heads
						if(new_alt_head)
							active_character.alt_head = new_alt_head
						if(active_character.m_styles["head"])
							var/head_marking = active_character.m_styles["head"]
							var/datum/sprite_accessory/body_markings/head/head_marking_style = GLOB.marking_styles_list[head_marking]
							if(!head_marking_style.heads_allowed || (!("All" in head_marking_style.heads_allowed) && !(active_character.alt_head in head_marking_style.heads_allowed)))
								active_character.m_styles["head"] = "None"

				if("m_style_head")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						var/list/valid_markings = list()
						valid_markings["None"] = GLOB.marking_styles_list["None"]
						for(var/markingstyle in GLOB.marking_styles_list)
							var/datum/sprite_accessory/body_markings/head/M = GLOB.marking_styles_list[markingstyle]
							if(!(active_character.species in M.species_allowed))
								continue
							if(M.marking_location != "head")
								continue
							if(active_character.alt_head && active_character.alt_head != "None")
								if(!("All" in M.heads_allowed) && !(active_character.alt_head in M.heads_allowed))
									continue
							else
								if(M.heads_allowed && !("All" in M.heads_allowed))
									continue

							if(S.bodyflags & ALL_RPARTS) //Species that can use prosthetic heads.
								var/head_model
								if(!active_character.rlimb_data["head"]) //Handle situations where the head is default.
									head_model = "Morpheus Cyberkinetics"
								else
									head_model = active_character.rlimb_data["head"]
								var/datum/robolimb/robohead = GLOB.all_robolimbs[head_model]
								if(robohead.is_monitor && M.name != "None") //If the character can have prosthetic heads and they have the default Morpheus head (or another monitor-head), no optic markings.
									continue
								else if(!robohead.is_monitor && M.name != "None") //Otherwise, if they DON'T have the default head and the head's not a monitor but the head's not in the style's list of allowed models, skip.
									if(!(robohead.company in M.models_allowed))
										continue

							valid_markings += markingstyle
						sortTim(valid_markings, GLOBAL_PROC_REF(cmp_text_asc))
						var/new_marking_style = input(user, "Choose the style of your character's head markings:", "Character Preference", active_character.m_styles["head"]) as null|anything in valid_markings
						if(new_marking_style)
							active_character.m_styles["head"] = new_marking_style

				if("m_head_colour")
					if(S.bodyflags & HAS_HEAD_MARKINGS) //Species with head markings.
						var/input = "Choose the colour of your your character's head markings:"
						var/new_markings = input(user, input, "Character Preference", active_character.m_colours["head"]) as color|null
						if(new_markings)
							active_character.m_colours["head"] = new_markings

				if("m_style_body")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
						var/list/valid_markings = list()
						valid_markings["None"] = GLOB.marking_styles_list["None"]
						for(var/markingstyle in GLOB.marking_styles_list)
							var/datum/sprite_accessory/M = GLOB.marking_styles_list[markingstyle]
							if(!(active_character.species in M.species_allowed))
								continue
							if(M.marking_location != "body")
								continue

							valid_markings += markingstyle
						sortTim(valid_markings, GLOBAL_PROC_REF(cmp_text_asc))
						var/new_marking_style = input(user, "Choose the style of your character's body markings:", "Character Preference", active_character.m_styles["body"]) as null|anything in valid_markings
						if(new_marking_style)
							active_character.m_styles["body"] = new_marking_style

				if("m_body_colour")
					if(S.bodyflags & HAS_BODY_MARKINGS) //Species with body markings/tattoos.
						var/input = "Choose the colour of your your character's body markings:"
						var/new_markings = input(user, input, "Character Preference", active_character.m_colours["body"]) as color|null
						if(new_markings)
							active_character.m_colours["body"] = new_markings

				if("m_style_tail")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						var/list/valid_markings = list()
						valid_markings["None"] = GLOB.marking_styles_list["None"]
						for(var/markingstyle in GLOB.marking_styles_list)
							var/datum/sprite_accessory/body_markings/tail/M = GLOB.marking_styles_list[markingstyle]
							if(M.marking_location != "tail")
								continue
							if(!(active_character.species in M.species_allowed))
								continue
							if(!active_character.body_accessory)
								if(M.tails_allowed)
									continue
							else
								if(!M.tails_allowed || !(active_character.body_accessory in M.tails_allowed))
									continue

							valid_markings += markingstyle
						sortTim(valid_markings, GLOBAL_PROC_REF(cmp_text_asc))
						var/new_marking_style = input(user, "Choose the style of your character's tail markings:", "Character Preference", active_character.m_styles["tail"]) as null|anything in valid_markings
						if(new_marking_style)
							active_character.m_styles["tail"] = new_marking_style

				if("m_tail_colour")
					if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
						var/input = "Choose the colour of your your character's tail markings:"
						var/new_markings = input(user, input, "Character Preference", active_character.m_colours["tail"]) as color|null
						if(new_markings)
							active_character.m_colours["tail"] = new_markings

				if("body_accessory")
					var/list/possible_body_accessories = list()
					if(check_rights(R_ADMIN, 1, user))
						possible_body_accessories = GLOB.body_accessory_by_name.Copy()
					else
						for(var/B in GLOB.body_accessory_by_name)
							var/datum/body_accessory/accessory = GLOB.body_accessory_by_name[B]
							if(isnull(accessory)) // None
								continue
							if(active_character.species in accessory.allowed_species)
								possible_body_accessories += B
					if(S.optional_body_accessory)
						possible_body_accessories += "None" //the only null entry should be the "None" option
					else
						possible_body_accessories -= "None" // in case an admin is viewing it
					sortTim(possible_body_accessories, GLOBAL_PROC_REF(cmp_text_asc))
					var/new_body_accessory = input(user, "Choose your body accessory:", "Character Preference") as null|anything in possible_body_accessories
					if(new_body_accessory)
						active_character.m_styles["tail"] = "None"
						active_character.body_accessory = (new_body_accessory == "None") ? null : new_body_accessory

				if("facial")
					if(!(S.bodyflags & SHAVED))
						var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", active_character.f_colour) as color|null
						if(new_facial)
							active_character.f_colour = new_facial

				if("secondary_facial")
					if(!(S.bodyflags & SHAVED))
						var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[active_character.f_style]
						if(facial_hair_style.secondary_theme && !facial_hair_style.no_sec_colour)
							var/new_facial = input(user, "Choose your character's secondary facial-hair colour:", "Character Preference", active_character.f_sec_colour) as color|null
							if(new_facial)
								active_character.f_sec_colour = new_facial

				if("f_style")
					var/list/valid_facial_hairstyles = list()
					for(var/facialhairstyle in GLOB.facial_hair_styles_list)
						var/datum/sprite_accessory/SA = GLOB.facial_hair_styles_list[facialhairstyle]

						if(facialhairstyle == "Shaved") //Just in case.
							valid_facial_hairstyles += facialhairstyle
							continue
						if(active_character.gender == MALE && SA.gender == FEMALE)
							continue
						if(active_character.gender == FEMALE && SA.gender == MALE)
							continue
						if(S.bodyflags & ALL_RPARTS) //Species that can use prosthetic heads.
							var/head_model
							if(!active_character.rlimb_data["head"]) //Handle situations where the head is default.
								head_model = "Morpheus Cyberkinetics"
							else
								head_model = active_character.rlimb_data["head"]
							var/datum/robolimb/robohead = GLOB.all_robolimbs[head_model]
							if((active_character.species in SA.species_allowed) && robohead.is_monitor && ((SA.models_allowed && (robohead.company in SA.models_allowed)) || !SA.models_allowed)) //If this is a facial hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
								valid_facial_hairstyles += facialhairstyle //Give them their facial hairstyles if they do.
							else
								if(!robohead.is_monitor && ("Human" in SA.species_allowed)) /*If the facial hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																							But if the user has a robotic humanoid head and the facial hairstyle can fit humans, let them use it as a wig. */
									valid_facial_hairstyles += facialhairstyle
						else //If the user is not a species who can have robotic heads, use the default handling.
							if(active_character.species in SA.species_allowed) //If the user's head is of a species the facial hair style allows, add it to the list.
								valid_facial_hairstyles += facialhairstyle
					sortTim(valid_facial_hairstyles, GLOBAL_PROC_REF(cmp_text_asc))
					var/new_f_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in valid_facial_hairstyles
					if(new_f_style)
						active_character.f_style = new_f_style

				if("underwear")
					var/list/valid_underwear = list()
					for(var/underwear in GLOB.underwear_list)
						var/datum/sprite_accessory/SA = GLOB.underwear_list[underwear]
						if(active_character.gender == MALE && SA.gender == FEMALE)
							continue
						if(active_character.gender == FEMALE && SA.gender == MALE)
							continue
						if(!(active_character.species in SA.species_allowed))
							continue
						valid_underwear[underwear] = GLOB.underwear_list[underwear]
					sortTim(valid_underwear, GLOBAL_PROC_REF(cmp_text_asc))
					var/new_underwear = input(user, "Choose your character's underwear:", "Character Preference") as null|anything in valid_underwear
					ShowChoices(user)
					if(new_underwear)
						active_character.underwear = new_underwear
				if("undershirt")
					var/list/valid_undershirts = list()
					for(var/undershirt in GLOB.undershirt_list)
						var/datum/sprite_accessory/SA = GLOB.undershirt_list[undershirt]
						if(active_character.gender == MALE && SA.gender == FEMALE)
							continue
						if(active_character.gender == FEMALE && SA.gender == MALE)
							continue
						if(!(active_character.species in SA.species_allowed))
							continue
						valid_undershirts[undershirt] = GLOB.undershirt_list[undershirt]
					sortTim(valid_undershirts, GLOBAL_PROC_REF(cmp_text_asc))
					var/new_undershirt = input(user, "Choose your character's undershirt:", "Character Preference") as null|anything in valid_undershirts
					ShowChoices(user)
					if(new_undershirt)
						active_character.undershirt = new_undershirt

				if("socks")
					var/list/valid_sockstyles = list()
					for(var/sockstyle in GLOB.socks_list)
						var/datum/sprite_accessory/SA = GLOB.socks_list[sockstyle]
						if(active_character.gender == MALE && SA.gender == FEMALE)
							continue
						if(active_character.gender == FEMALE && SA.gender == MALE)
							continue
						if(!(active_character.species in SA.species_allowed))
							continue
						valid_sockstyles[sockstyle] = GLOB.socks_list[sockstyle]
					sortTim(valid_sockstyles, GLOBAL_PROC_REF(cmp_text_asc))
					var/new_socks = input(user, "Choose your character's socks:", "Character Preference")  as null|anything in valid_sockstyles
					ShowChoices(user)
					if(new_socks)
						active_character.socks = new_socks

				if("eyes")
					var/new_eyes = input(user, "Choose your character's eye colour:", "Character Preference", active_character.e_colour) as color|null
					if(new_eyes)
						active_character.e_colour = new_eyes

				if("s_tone")
					if(S.bodyflags & HAS_SKIN_TONE)
						var/new_s_tone = input(user, "Choose your character's skin-tone:\n(Light 1 - 220 Dark)", "Character Preference")  as num|null
						if(new_s_tone)
							active_character.s_tone = 35 - max(min(round(new_s_tone), 220), 1)
					else if(S.bodyflags & HAS_ICON_SKIN_TONE)
						var/const/MAX_LINE_ENTRIES = 4
						var/prompt = "Choose your character's skin tone: 1-[S.icon_skin_tones.len]\n("
						for(var/i = 1 to S.icon_skin_tones.len)
							if(i > MAX_LINE_ENTRIES && !((i - 1) % MAX_LINE_ENTRIES))
								prompt += "\n"
							prompt += "[i] = [S.icon_skin_tones[i]]"
							if(i != S.icon_skin_tones.len)
								prompt += ", "
						prompt += ")"
						var/skin_c = input(user, prompt, "Character Preference") as num|null
						if(isnum(skin_c))
							active_character.s_tone = max(min(round(skin_c), S.icon_skin_tones.len), 1)

				if("skin")
					if((S.bodyflags & HAS_SKIN_COLOR) || GLOB.body_accessory_by_species[active_character.species] || check_rights(R_ADMIN, 0, user))
						var/new_skin = input(user, "Choose your character's skin colour: ", "Character Preference", active_character.s_colour) as color|null
						if(new_skin)
							active_character.s_colour = new_skin

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference", ooccolor) as color|null
					if(new_ooccolor)
						ooccolor = new_ooccolor

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference") as null|anything in GLOB.backbaglist
					if(new_backbag)
						active_character.backbag = new_backbag

				if("nt_relation")
					var/new_relation = input(user, "Choose your relation to NT. Note that this represents what others can find out about your character by researching your background, not what your character actually thinks.", "Character Preference")  as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_relation)
						active_character.nanotrasen_relation = new_relation

				if("physique")
					var/new_physique = input(user, "Choose your descriptor for how built your character is on glance.", "Character Preference") as null|anything in GLOB.character_physiques
					if(new_physique)
						active_character.physique = new_physique

				if("height")
					var/new_height = input(user, "Choose your descriptor for how tall your character is on glance.", "Character Preference") as null|anything in GLOB.character_heights
					if(new_height)
						active_character.height = new_height

				if("flavor_text")
					var/msg = input(usr,"Set the flavor text in your 'examine' verb. The flavor text should be a physical descriptor of your character at a glance. SFW Drawn Art of your character is acceptable.","Flavor Text",html_decode(active_character.flavor_text)) as message

					if(msg != null)
						msg = copytext(msg, 1, MAX_MESSAGE_LEN)
						msg = html_encode(msg)

						active_character.flavor_text = msg

				// SS220 ADDITION START
				if("tts_seed")
					var/datum/ui_module/tts_seeds_explorer/explorer = explorer_users[user]
					if(!explorer)
						explorer = new()
						explorer_users[user] = explorer
					explorer.ui_interact(user)
					return
				// SS220 ADDITION END

				if("limbs")
					var/valid_limbs = list("Left Leg", "Right Leg", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Hand", "Right Hand")
					if(S.bodyflags & ALL_RPARTS)
						valid_limbs = list("Torso", "Lower Body", "Head", "Left Leg", "Right Leg", "Left Arm", "Right Arm", "Left Foot", "Right Foot", "Left Hand", "Right Hand")
					var/limb_name = input(user, "Which limb do you want to change?") as null|anything in valid_limbs
					if(!limb_name) return

					var/limb = null
					var/second_limb = null // if you try to change the arm, the hand should also change
					var/third_limb = null  // if you try to unchange the hand, the arm should also change
					var/valid_limb_states = list("Normal", "Amputated", "Prosthesis")
					var/no_amputate = 0

					switch(limb_name)
						if("Torso")
							limb = "chest"
							second_limb = "groin"
							no_amputate = 1
						if("Lower Body")
							limb = "groin"
							no_amputate = 1
						if("Head")
							limb = "head"
							no_amputate = 1
						if("Left Leg")
							limb = "l_leg"
							second_limb = "l_foot"
						if("Right Leg")
							limb = "r_leg"
							second_limb = "r_foot"
						if("Left Arm")
							limb = "l_arm"
							second_limb = "l_hand"
						if("Right Arm")
							limb = "r_arm"
							second_limb = "r_hand"
						if("Left Foot")
							limb = "l_foot"
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = "l_leg"
						if("Right Foot")
							limb = "r_foot"
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = "r_leg"
						if("Left Hand")
							limb = "l_hand"
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = "l_arm"
						if("Right Hand")
							limb = "r_hand"
							if(!(S.bodyflags & ALL_RPARTS))
								third_limb = "r_arm"

					var/new_state = input(user, "What state do you wish the limb to be in?") as null|anything in valid_limb_states
					if(!new_state) return

					switch(new_state)
						if("Normal")
							if(limb == "head")
								active_character.m_styles["head"] = "None"
								active_character.h_style = GLOB.hair_styles_public_list["Bald"]
								active_character.f_style = GLOB.facial_hair_styles_list["Shaved"]
							active_character.organ_data[limb] = null
							active_character.rlimb_data[limb] = null
							if(third_limb)
								active_character.organ_data[third_limb] = null
								active_character.rlimb_data[third_limb] = null
						if("Amputated")
							if(!no_amputate)
								active_character.organ_data[limb] = "amputated"
								active_character.rlimb_data[limb] = null
								if(second_limb)
									active_character.organ_data[second_limb] = "amputated"
									active_character.rlimb_data[second_limb] = null
						if("Prosthesis")
							var/choice
							var/subchoice
							var/datum/robolimb/R = new()
							var/in_model
							var/robolimb_companies = list()
							for(var/limb_type in typesof(/datum/robolimb)) //This loop populates a list of companies that offer the limb the user selected previously as one of their cybernetic products.
								R = new limb_type()
								if(!R.unavailable_at_chargen && (limb in R.parts) && R.has_subtypes) //Ensures users can only choose companies that offer the parts they want, that singular models get added to the list as well companies that offer more than one model, and...
									robolimb_companies[R.company] = R //List only main brands that have the parts we're looking for.
							R = new() //Re-initialize R.

							choice = input(user, "Which manufacturer do you wish to use for this limb?") as null|anything in robolimb_companies //Choose from a list of companies that offer the part the user wants.
							if(!choice)
								return
							R.company = choice
							R = GLOB.all_robolimbs[R.company]
							if(R.has_subtypes == 1) //If the company the user selected provides more than just one base model, lets handle it.
								var/list/robolimb_models = list()
								for(var/limb_type in typesof(R)) //Handling the different models of parts that manufacturers can provide.
									var/datum/robolimb/L = new limb_type()
									if(limb in L.parts) //Make sure that only models that provide the parts the user needs populate the list.
										robolimb_models[L.company] = L
										if(robolimb_models.len == 1) //If there's only one model available in the list, autoselect it to avoid having to bother the user with a dialog that provides only one option.
											subchoice = L.company //If there ends up being more than one model populating the list, subchoice will be overwritten later anyway, so this isn't a problem.
										if(second_limb in L.parts) //If the child limb of the limb the user selected is also present in the model's parts list, state it's been found so the second limb can be set later.
											in_model = 1
								if(robolimb_models.len > 1) //If there's more than one model in the list that can provide the part the user wants, let them choose.
									subchoice = input(user, "Which model of [choice] [limb_name] do you wish to use?") as null|anything in robolimb_models
								if(subchoice)
									choice = subchoice
							if(limb in list("head", "chest", "groin"))
								if(!(S.bodyflags & ALL_RPARTS))
									return
								if(limb == "head")
									active_character.ha_style = "None"
									active_character.alt_head = null
									active_character.h_style = GLOB.hair_styles_public_list["Bald"]
									active_character.f_style = GLOB.facial_hair_styles_list["Shaved"]
									active_character.m_styles["head"] = "None"
							active_character.rlimb_data[limb] = choice
							active_character.organ_data[limb] = "cyborg"
							if(second_limb)
								if(subchoice)
									if(in_model)
										active_character.rlimb_data[second_limb] = choice
										active_character.organ_data[second_limb] = "cyborg"
								else
									active_character.rlimb_data[second_limb] = choice
									active_character.organ_data[second_limb] = "cyborg"
				if("organs")
					var/organ_name = input(user, "Which internal function do you want to change?") as null|anything in list("Eyes", "Ears", "Heart", "Lungs", "Liver", "Kidneys")
					if(!organ_name)
						return

					var/organ = null
					switch(organ_name)
						if("Eyes")
							organ = "eyes"
						if("Ears")
							organ = "ears"
						if("Heart")
							organ = "heart"
						if("Lungs")
							organ = "lungs"
						if("Liver")
							organ = "liver"
						if("Kidneys")
							organ = "kidneys"

					var/new_state = input(user, "What state do you wish the organ to be in?") as null|anything in list("Normal", "Cybernetic")
					if(!new_state) return

					switch(new_state)
						if("Normal")
							active_character.organ_data[organ] = null
						if("Cybernetic")
							active_character.organ_data[organ] = "cybernetic"

				if("clientfps")
					var/version_message
					if(user.client && user.client.byond_version < 511)
						version_message = "\nYou need to be using byond version 511 or later to take advantage of this feature, your version of [user.client.byond_version] is too low"
					if(world.byond_version < 511)
						version_message += "\nThis server does not currently support client side fps. You can set now for when it does."
					var/desiredfps = input(user, "Choose your desired fps.[version_message]\n(0 = synced with server tick rate (currently:[world.fps]))", "Character Preference", clientfps)  as null|num
					if(!isnull(desiredfps))
						clientfps = desiredfps
						if(world.byond_version >= 511 && user.client && user.client.byond_version >= 511)
							parent.fps = clientfps

		else
			switch(href_list["preference"])
				if("cbmode")
					var/cb_mode = input(user, "Select a colourblind mode\nNote this will disable special screen effects such as the cursed heart warnings!") as null|anything in list(COLOURBLIND_MODE_NONE, COLOURBLIND_MODE_DEUTER, COLOURBLIND_MODE_PROT, COLOURBLIND_MODE_TRIT)
					if(cb_mode)
						colourblind_mode = cb_mode
						user.update_client_colour(0)

				if("publicity")
					if(unlock_content)
						toggles ^= PREFTOGGLE_MEMBER_PUBLIC

				if("donor_public")
					if(user.client.donator_level > 0)
						toggles ^= PREFTOGGLE_DONATOR_PUBLIC

				if("gender")
					if(!S.has_gender)
						var/newgender = input(user, "Choose Gender:") as null|anything in list("Male", "Female", "Genderless")
						switch(newgender)
							if("Male")
								active_character.gender = MALE
							if("Female")
								active_character.gender = FEMALE
							if("Genderless")
								active_character.gender = PLURAL
					else
						if(active_character.gender == MALE)
							active_character.gender = FEMALE
						else
							active_character.gender = MALE
					active_character.underwear = random_underwear(active_character.gender)

				if("hear_adminhelps")
					sound ^= SOUND_ADMINHELP
				if("ui")
					switch(UI_style)
						if("Midnight")
							UI_style = "Plasmafire"
						if("Plasmafire")
							UI_style = "Retro"
						if("Retro")
							UI_style = "Slimecore"
						if("Slimecore")
							UI_style = "Operative"
						if("Operative")
						// SS220 ADDITION START
							UI_style = "Vaporwave"
						if("Vaporwave")
							UI_style = "Detective"
						if("Detective")
							UI_style = "Trasen"
						if("Trasen")
							UI_style = "Clockwork"
						if("Clockwork")
						// SS220 ADDITION END
							UI_style = "White"
						else
							UI_style = "Midnight"

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()

				if("tgui")
					toggles2 ^= PREFTOGGLE_2_FANCYUI

				if("ghost_att_anim")
					toggles2 ^= PREFTOGGLE_2_ITEMATTACK

				if("winflash")
					toggles2 ^= PREFTOGGLE_2_WINDOWFLASHING

				if("mam")
					toggles2 ^= PREFTOGGLE_2_MOD_ACTIVATION_METHOD


				if("setviewrange")
					var/list/viewrange_options = list(
						"15x15 (Classic)" = "15x15",
						"17x15 (Wide)" = "17x15",
						"19x15 (Ultrawide)" = "19x15"
					)

					var/new_range = input(user, "Select a view range") as anything in viewrange_options
					var/actual_new_range = viewrange_options[new_range]

					viewrange = actual_new_range

					if(actual_new_range != parent.view)
						parent.view = actual_new_range
						// Update the size of the click catcher
						var/list/actualview = getviewsize(parent.view)
						parent.void.UpdateGreed(actualview[1],actualview[2])

					parent.debug_text_overlay?.update_view(parent)

				if("afk_watch")
					if(!(toggles2 & PREFTOGGLE_2_AFKWATCH))
						to_chat(user, "<span class='info'>You will now get put into cryo dorms after [GLOB.configuration.afk.auto_cryo_minutes] minutes. \
								Then after [GLOB.configuration.afk.auto_despawn_minutes] minutes you will be fully despawned. You will receive a visual and auditory warning before you will be put into cryodorms.</span>")
					else
						to_chat(user, "<span class='info'>Automatic cryoing turned off.</span>")
					toggles2 ^= PREFTOGGLE_2_AFKWATCH

				if("UIcolor")
					var/UI_style_color_new = input(user, "Choose your UI color, dark colors are not recommended!", UI_style_color) as color|null
					if(!UI_style_color_new) return
					UI_style_color = UI_style_color_new

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()

				if("UIalpha")
					var/UI_style_alpha_new = input(user, "Select a new alpha(transparence) parameter for UI, between 50 and 255", UI_style_alpha) as num
					if(!UI_style_alpha_new || !(UI_style_alpha_new <= 255 && UI_style_alpha_new >= 50))
						return
					UI_style_alpha = UI_style_alpha_new

					if(ishuman(usr)) //mid-round preference changes, for aesthetics
						var/mob/living/carbon/human/H = usr
						H.remake_hud()

				if("thought_bubble")
					toggles2 ^= PREFTOGGLE_2_THOUGHT_BUBBLE
					if(length(parent?.screen))
						var/obj/screen/plane_master/point/PM = locate(/obj/screen/plane_master/point) in parent.screen
						PM.backdrop(parent.mob)

				if("be_special")
					var/r = href_list["role"]
					if(r in GLOB.special_roles)
						be_special ^= r

				if("name")
					active_character.be_random_name = !active_character.be_random_name

				if("randomslot")
					toggles2 ^= PREFTOGGLE_2_RANDOMSLOT
					if(isnewplayer(usr))
						var/mob/new_player/N = usr
						N.new_player_panel_proc()

				if("hear_midis")
					sound ^= SOUND_MIDI

				if("lobby_music")
					sound ^= SOUND_LOBBY
					if((sound & SOUND_LOBBY) && user.client)
						user.client.playtitlemusic()
					else
						user.stop_sound_channel(CHANNEL_LOBBYMUSIC)

				if("ghost_ears")
					toggles ^= PREFTOGGLE_CHAT_GHOSTEARS

				if("ghost_sight")
					toggles ^= PREFTOGGLE_CHAT_GHOSTSIGHT

				if("ghost_radio")
					toggles ^= PREFTOGGLE_CHAT_GHOSTRADIO

				if("ghost_pda")
					toggles ^= PREFTOGGLE_CHAT_GHOSTPDA

				if("anonmode")
					toggles2 ^= PREFTOGGLE_2_ANON

				if("save")
					save_preferences(user)
					active_character.save(user)

				if("clear")
					if(!active_character.from_db || active_character.real_name != input("This will clear the current slot permanently. Please enter the character's full name to confirm."))
						return FALSE
					active_character.clear_character_slot(user)
					// Gimmie a freshie
					var/datum/character_save/CS = new
					character_saves[active_character.slot_number] = CS
					CS.slot_number = active_character.slot_number // Dont lose this
					active_character = CS

				if("open_load_dialog")
					if(!IsGuestKey(user.key))
						open_load_dialog(user)
						return 1

				if("close_load_dialog")
					close_load_dialog(user)

				if("changeslot")
					active_character = character_saves[text2num(href_list["num"])]
					default_slot = text2num(href_list["num"])
					close_load_dialog(user)
					if(isnewplayer(user))
						var/mob/new_player/N = user
						N.new_player_panel_proc()

				if("tab")
					if(href_list["tab"])
						current_tab = text2num(href_list["tab"])


				if("ambientocclusion")
					toggles ^= PREFTOGGLE_AMBIENT_OCCLUSION
					if(length(parent?.screen))
						var/obj/screen/plane_master/game_world/PM = locate(/obj/screen/plane_master/game_world) in parent.screen
						PM.backdrop(parent.mob)

				if("parallax")
					var/parallax_styles = list(
						"Off" = PARALLAX_DISABLE,
						"Low" = PARALLAX_LOW,
						"Medium" = PARALLAX_MED,
						"High" = PARALLAX_HIGH,
						"Insane" = PARALLAX_INSANE
					)
					parallax = parallax_styles[input(user, "Pick a parallax style", "Parallax Style") as null|anything in parallax_styles]
					if(parent && parent.mob && parent.mob.hud_used)
						parent.mob.hud_used.update_parallax_pref()

				if("parallax_darkness")
					toggles2 ^= PREFTOGGLE_2_PARALLAX_IN_DARKNESS
					parent.mob?.hud_used?.update_parallax_pref()

				if("screentip_mode")
					var/desired_screentip_mode = clamp(input(user, "Pick a screentip size, pick 0 to disable screentips. (We suggest a number between 8 and 15):", "Screentip Size") as null|num, 0, 20)
					if(!isnull(desired_screentip_mode))
						screentip_mode = desired_screentip_mode

				if("screentip_color")
					var/screentip_color_new = input(user, "Choose your screentip color", screentip_color) as color|null
					if(screentip_color_new)
						screentip_color = screentip_color_new

				if("edit_2fa")
					// Do this async so we arent holding up a topic() call
					INVOKE_ASYNC(user.client, TYPE_PROC_REF(/client, edit_2fa))
					return // We return here to avoid focus being lost

				if("keybindings")
					if(!keybindings_overrides)
						keybindings_overrides = list()

					if(href_list["set"])
						var/datum/keybinding/KB = locateUID(href_list["set"])
						if(KB)
							if(href_list["key"])
								var/old_key = href_list["old"]
								var/new_key = copytext(url_decode(href_list["key"]), 1, 16)
								var/alt_mod = text2num(href_list["alt"]) ? "Alt" : ""
								var/ctrl_mod = text2num(href_list["ctrl"]) ? "Ctrl" : ""
								var/shift_mod = text2num(href_list["shift"]) ? "Shift" : ""
								var/numpad = (text2num(href_list["numpad"]) && text2num(new_key)) ? "Numpad" : ""
								var/clear = text2num(href_list["clear_key"])

								if(new_key == "Unidentified") //There doesn't seem to be any any key!
									capture_keybinding(user, KB, href_list["old"])
									return

								if(!(length_char(new_key) == 1 && text2ascii(new_key) >= 0x80)) // Don't uppercase unicode stuff
									new_key = uppertext(new_key)

								// Map for JS keys
								var/static/list/key_map = list(
									"UP" = "North",
									"RIGHT" = "East",
									"DOWN" = "South",
									"LEFT" = "West",
									"INSERT" = "Insert",
									"HOME" = "Northwest",
									"PAGEUP" = "Northeast",
									"DEL" = "Delete",
									"END" = "Southwest",
									"PAGEDOWN" = "Southeast",
									"SPACEBAR" = "Space",
									"ALT" = "Alt",
									"SHIFT" = "Shift",
									"CONTROL" = "Ctrl",
									"DIVIDE" = "Divide",
									"MULTIPLY" = "Multiply",
									"ADD" = "Add",
									"SUBTRACT" = "Subtract",
									"DECIMAL" = "Decimal",
									"CLEAR" = "Center"
								)

								new_key = convert_ru_key_to_en_key(key_map[new_key] || new_key) // SS220 EDIT

								var/full_key
								switch(new_key)
									if("ALT")
										full_key = "Alt[ctrl_mod][shift_mod]"
									if("CONTROL")
										full_key = "[alt_mod]Ctrl[shift_mod]"
									if("SHIFT")
										full_key = "[alt_mod][ctrl_mod]Shift"
									else
										full_key = "[alt_mod][ctrl_mod][shift_mod][numpad][new_key]"

								// Update overrides
								var/list/key_overrides = keybindings_overrides[KB.name] || KB.keys?.Copy() || list()
								var/index = key_overrides.Find(old_key)
								var/changed = FALSE
								if(clear) // Clear
									key_overrides -= old_key
									changed = TRUE
								else if(old_key != full_key)
									if(index) // Replace
										var/cur_index = key_overrides.Find(full_key)
										if(cur_index)
											key_overrides[cur_index] = old_key
										key_overrides[index] = full_key
										changed = TRUE
									else // Add
										key_overrides -= (old_key || full_key) // Defaults to the new key itself, as to reorder it
										key_overrides += full_key
										changed = TRUE
								else
									changed = isnull(keybindings_overrides[KB.name]) // Sets it in the JSON

								if(changed)
									if(!length(key_overrides) && !length(KB.keys))
										keybindings_overrides -= KB.name
									else
										keybindings_overrides[KB.name] = key_overrides

								user << browse(null, "window=capturekeypress")
							else
								capture_keybinding(user, KB, href_list["old"])
								return

					else if(href_list["reset"])
						var/datum/keybinding/KB = locateUID(href_list["reset"])
						if(KB)
							keybindings_overrides -= KB.name

					else if(href_list["clear"])
						var/datum/keybinding/KB = locateUID(href_list["clear"])
						if(KB)
							if(length(KB.keys))
								keybindings_overrides[KB.name] = list()
							else
								keybindings_overrides -= KB.name

					else if(href_list["all"])
						var/yes = alert(user, "Really [href_list["all"]] all key bindings?", "Confirm", "Yes", "No") == "Yes"
						if(yes)
							switch(href_list["all"])
								if("reset")
									keybindings_overrides = list()
								if("clear")
									for(var/kb in GLOB.keybindings)
										var/datum/keybinding/KB = kb
										keybindings_overrides[KB.name] = list()

					else if(href_list["custom_emote_set"])
						var/datum/keybinding/custom/custom_emote_keybind = locateUID(href_list["custom_emote_set"])
						if(custom_emote_keybind)
							var/emote_text = active_character.custom_emotes[custom_emote_keybind.name]
							var/desired_emote = stripped_input(user, "Enter your custom emote text, 128 character limit.", "Custom Emote Setter", emote_text, max_length = 128)
							if(desired_emote && (desired_emote != custom_emote_keybind.default_emote_text)) //don't let them save the default custom emote text
								active_character.custom_emotes[custom_emote_keybind.name] = desired_emote
							active_character.save(user)

					else if(href_list["custom_emote_reset"])
						var/datum/keybinding/custom/custom_emote_keybind = locateUID(href_list["custom_emote_reset"])
						if(custom_emote_keybind)
							active_character.custom_emotes.Remove(custom_emote_keybind.name)
							active_character.save(user)

					init_keybindings(keybindings_overrides)
					save_preferences(user) //Ideally we want to save people's keybinds when they enter them


	ShowChoices(user)
	return 1
