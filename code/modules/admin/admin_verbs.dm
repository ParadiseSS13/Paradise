/client/proc/add_user_verbs()
	SSuser_verbs.associate(src)
	if(check_rights_client(R_ADMIN|R_DEBUG|R_VIEWRUNTIMES, FALSE, src))
		// This setting exposes the profiler & client side tools
		spawn(1)
			control_freak = 0

/client/proc/remove_user_verbs()
	SSuser_verbs.deassociate(src)

USER_VERB(hide_verbs, R_NONE, "Adminverbs - Hide All", "Hide most of your admin verbs.", VERB_CATEGORY_ADMIN)
	client.remove_user_verbs()
	add_verb(client, /client/proc/show_verbs)

	to_chat(client, SPAN_INTERFACE("Almost all of your adminverbs have been hidden."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Hide Admin Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/show_verbs()
	set name = "Adminverbs - Show"
	set category = VERB_CATEGORY_ADMIN

	remove_verb(src, /client/proc/show_verbs)
	add_user_verbs()

	to_chat(src, SPAN_INTERFACE("All of your adminverbs are now visible."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Admin Verbs") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/mentor_ghost()
	var/is_mentor = check_rights(R_MENTOR, FALSE)
	var/is_full_admin = check_rights(R_ADMIN|R_MOD, FALSE)

	if(!is_mentor && !is_full_admin)
		to_chat(src, SPAN_WARNING("You aren't allowed to use this!"))
		return

	// mentors are allowed only if they have the observe trait, which is given on observe.
	// they should also not be given this proc.
	if(!is_full_admin && (is_mentor && !HAS_MIND_TRAIT(mob, TRAIT_MENTOR_OBSERVING) || !is_mentor))
		return

	do_aghost()

/client/proc/do_aghost()
	if(isobserver(mob))
		//re-enter
		var/mob/dead/observer/ghost = mob
		var/old_turf = get_turf(ghost)
		ghost.ghost_flags |= GHOST_CAN_REENTER // just in-case.
		ghost.reenter_corpse()
		log_admin("[key_name(usr)] re-entered their body")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aghost") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		if(ishuman(mob))
			var/mob/living/carbon/human/H = mob
			H.regenerate_icons() // workaround for #13269
		if(is_ai(mob)) // client.mob, built in byond client var
			var/mob/living/silicon/ai/ai = mob
			ai.eyeobj.set_loc(old_turf)
	else if(isnewplayer(mob))
		to_chat(src, "<font color='red'>Error: Aghost: Can't admin-ghost whilst in the lobby. Join or observe first.</font>")
	else
		//ghostize
		var/mob/body = mob
		body.ghostize()
		if(body && !body.key)
			body.key = "@[key]"	//Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		log_admin("[key_name(usr)] has admin-ghosted")
		// TODO: SStgui.on_transfer() to move windows from old and new
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aghost") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(admin_ghost, R_ADMIN|R_MOD, "Aghost", "Aghost self.", VERB_CATEGORY_ADMIN)
	client.do_aghost()

/// Allow an admin to observe someone.
/// mentors are allowed to use this verb while living, but with some stipulations:
/// if they attempt to do anything that would stop their orbit, they will immediately be returned to their body.
USER_VERB(admin_observe, R_ADMIN|R_MOD|R_MENTOR, "Aobserve", "Admin-observe a player mob.", VERB_CATEGORY_ADMIN)
	if(isnewplayer(client.mob))
		to_chat(client, SPAN_WARNING("You cannot aobserve while in the lobby. Please join or observe first."))
		return

	var/mob/target

	target = tgui_input_list(client, "Select a mob to observe", "Aobserve", GLOB.player_list)
	if(isnull(target))
		return
	if(target == client)
		to_chat(client, SPAN_WARNING("You can't observe yourself!"))
		return

	if(isobserver(target))
		to_chat(client, SPAN_WARNING("[target] is a ghost, and cannot be observed."))
		return

	if(isnewplayer(target))
		to_chat(client, SPAN_WARNING("[target] is in the lobby, and cannot be observed."))
		return

	SSuser_verbs.invoke_verb(client, /datum/user_verb/admin_observe_target, target)

/client/proc/cleanup_admin_observe(mob/dead/observer/ghost)
	if(!istype(ghost) || !ghost.mob_observed)
		return FALSE

	// un-follow them
	ghost.cleanup_observe()
	// if it's a mentor, make sure they go back to their body.
	if(HAS_TRAIT(mob.mind, TRAIT_MENTOR_OBSERVING))
		// handler will handle removing the trait
		mob.stop_orbit()
	log_admin("[key_name(src)] has de-activated Aobserve")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Aobserve") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return TRUE

USER_CONTEXT_MENU(admin_observe_target, R_ADMIN|R_MOD|R_MENTOR, "\[Admin\] Aobserve", mob/target as mob)
	if(isnewplayer(client.mob))
		to_chat(client, SPAN_WARNING("You cannot aobserve while in the lobby. Please join or observe first."))
		return

	if(isnewplayer(target))
		to_chat(client, SPAN_WARNING("[target] is currently in the lobby."))
		return

	if(isobserver(target))
		to_chat(client, SPAN_WARNING("You can't observe a ghost."))
		return

	var/mob/dead/observer/observer = client.mob
	if(istype(observer) && target == locateUID(observer.mob_observed))
		client.cleanup_admin_observe(client.mob)
		return
	client.cleanup_admin_observe(client.mob)

	if(isnull(target) || target == client.mob)
		// let the default one find the target if there isn't one
		SSuser_verbs.invoke_verb(client, /datum/user_verb/admin_observe)
		return

	// observers don't need to ghost, so we don't need to worry about adding any traits
	if(isobserver(client.mob))
		var/mob/dead/observer/ghost = client.mob
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Aobserve") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		ghost.do_observe(target)
		return

	log_admin("[key_name(client)] has Aobserved out of their body to follow [target]")
	client.do_aghost()
	var/mob/dead/observer/ghost = client.mob

	var/full_admin = check_rights_client(R_ADMIN|R_MOD, FALSE, client)
	if(!full_admin)
		// if they're a me and they're alive, add the MENTOR_OBSERVINGtrait to ensure that they can only go back to their body.
		// we need to handle this here because when you aghost, your mob gets set to the ghost. Oops!
		ADD_TRAIT(client.mob.mind, TRAIT_MENTOR_OBSERVING, MENTOR_OBSERVING)
		RegisterSignal(ghost, COMSIG_ATOM_ORBITER_STOP, TYPE_PROC_REF(/client, on_mentor_observe_end), override = TRUE)
		to_chat(client, SPAN_NOTICE("You have temporarily observed [target], either move or observe again to un-observe."))
		log_admin("[key_name(client)] has mobserved out of their body to follow [target].")
	else
		log_admin("[key_name(client)] is aobserving [target].")

	ghost.do_observe(target)

/client/proc/on_mentor_observe_end(atom/movable/us, atom/movable/orbited)
	SIGNAL_HANDLER  // COMSIG_ATOM_ORBITER_STOP
	if(!isobserver(mob))
		log_and_message_admins("A mentor somehow managed to end observing while not being a ghost. Please investigate and notify coders.")
		return
	var/mob/dead/observer/ghost = mob

	// just to be safe
	ghost.cleanup_observe()

	REMOVE_TRAIT(mob.mind, TRAIT_MENTOR_OBSERVING, MENTOR_OBSERVING)
	UnregisterSignal(mob, COMSIG_ATOM_ORBITER_STOP)

	if(!ghost.reenter_corpse())
		// tell everyone since this is kinda nasty.
		log_debug("Mentor [key_name_mentor(src)] was unable to re-enter their body after mentor observing.")
		log_and_message_admins("[key_name_mentor(src)] was unable to re-enter their body after mentor observing.")
		to_chat(src, SPAN_USERDANGER("Unable to return you to your body after mentor ghosting. If your body still exists, please contact a coder, and you should probably ahelp."))

USER_VERB(invisimin, R_ADMIN, "Invisimin", "Toggles ghost-like invisibility (Don't abuse this)", VERB_CATEGORY_ADMIN)
	if(!isliving(client.mob))
		return

	var/mob/living/client_mob = client.mob
	if(client_mob.invisibility == INVISIBILITY_OBSERVER)
		client_mob.invisibility = initial(client_mob.invisibility)
		client_mob.add_to_all_human_data_huds()
		to_chat(client, SPAN_DANGER("Invisimin off. Invisibility reset."))
		log_admin("[key_name(client)] has turned Invisimin OFF")
	else
		client_mob.invisibility = INVISIBILITY_OBSERVER
		client_mob.remove_from_all_data_huds()
		to_chat(client, SPAN_NOTICE("Invisimin on. You are now as invisible as a ghost."))
		log_admin("[key_name(client)] has turned Invisimin ON")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Invisimin") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(player_panel, R_ADMIN|R_MOD, "Player Panel", "Opens the player panel.", VERB_CATEGORY_ADMIN)
	client.holder.player_panel_new()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Player Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(check_antagonists, R_ADMIN, "Check Antagonists", "Open the Antagonists panel.", VERB_CATEGORY_ADMIN)
	client.holder.check_antagonists()
	log_admin("[key_name(client)] checked antagonists")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antags") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(check_antagonists_tgui, R_ADMIN, "TGUI - Antagonists", "Open the TGUI Antagonists panel.", VERB_CATEGORY_ADMIN)
	var/datum/ui_module/admin = get_admin_ui_module(/datum/ui_module/admin/antagonist_menu)
	admin.ui_interact(client.mob)
	log_admin("[key_name(client)] checked antagonists")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Antags2") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(ban_panel, R_BAN, "Ban Panel", "Opens the ban panel.", VERB_CATEGORY_ADMIN)
	client.holder.DB_ban_panel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Ban Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(game_panel, R_ADMIN, "Game Panel", "Opens the game panel.", VERB_CATEGORY_ADMIN)
	client.holder.Game()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Game Panel") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(secrets_panel, R_ADMIN, "Secrets", "Opens the secrets panel.", VERB_CATEGORY_ADMIN)
	client.holder.Secrets()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Secrets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/getStealthKey()
	return GLOB.stealthminID[ckey]

/client/proc/createStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	GLOB.stealthminID["[ckey]"] = "@[num2text(num)]"

USER_VERB(stealth_mode, R_ADMIN, "Stealth Mode", "Enables stealth mode.", VERB_CATEGORY_ADMIN)
	var/datum/admins/holder = client.holder
	if(istype(holder))
		holder.big_brother = 0
		if(holder.fakekey)
			holder.fakekey = null
		else
			var/new_key = ckeyEx(clean_input("Enter your desired display name.", "Fake Key", client.key, user = client))
			if(!new_key)	return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			client.createStealthKey()
		log_admin("[key_name(client)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]")
		message_admins("[key_name_admin(client)] has turned stealth mode [holder.fakekey ? "ON" : "OFF"]", 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stealth Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(big_brother, R_PERMISSIONS, "Big Brother Mode", "Enables Big Brother mode.", VERB_CATEGORY_ADMIN)
	var/datum/admins/holder = client.holder
	if(holder)
		if(holder.fakekey)
			holder.fakekey = null
			holder.big_brother = 0
		else
			var/new_key = ckeyEx(clean_input("Enter your desired display name. Unlike normal stealth mode, this will not appear in Who at all, except for other heads.", "Fake Key", client.key, user = client))
			if(!new_key)
				return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			holder.big_brother = 1
			if(isobserver(client.mob))
				client.mob.invisibility = 90
				client.mob.see_invisible = 90
			client.createStealthKey()
		log_admin("[key_name(client)] has turned BB mode [holder.fakekey ? "ON" : "OFF"]", TRUE)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Big Brother Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(drop_bomb, R_EVENT, "Drop Bomb", "Cause an explosion of varying strength at your location.", VERB_CATEGORY_EVENT)
	var/turf/epicenter = client.mob.loc
	var/list/choices = list("Small Bomb", "Medium Bomb", "Big Bomb", "Custom Bomb")
	var/choice = tgui_input_list(client, "What size explosion would you like to produce?", "Drop Bomb", choices)
	switch(choice)
		if(null)
			return 0
		if("Small Bomb")
			explosion(epicenter, 1, 2, 3, 3, cause = "[client.ckey]: Drop Bomb command")
		if("Medium Bomb")
			explosion(epicenter, 2, 3, 4, 4, cause = "[client.ckey]: Drop Bomb command")
		if("Big Bomb")
			explosion(epicenter, 3, 5, 7, 5, cause = "[client.ckey]: Drop Bomb command")
		if("Custom Bomb")
			var/devastation_range = tgui_input_number(client, "Devastation range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(devastation_range))
				return
			var/heavy_impact_range = tgui_input_number(client, "Heavy impact range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(heavy_impact_range))
				return
			var/light_impact_range = tgui_input_number(client, "Light impact range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(light_impact_range))
				return
			var/flash_range = tgui_input_number(client, "Flash range (in tiles):", "Custom Bomb", max_value = 255)
			if(isnull(flash_range))
				return
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, 1, 1, cause = "[client.ckey]: Drop Bomb command")
	log_admin("[key_name(client)] created an admin explosion at [epicenter.loc]")
	message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] created an admin explosion at [epicenter.loc]"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Bomb") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(give_spell, R_EVENT, "Give Spell", VERB_NO_DESCRIPTION, VERB_CATEGORY_HIDDEN, mob/T)
	var/list/spell_list = list()
	var/type_length = length("/datum/spell") + 2
	for(var/A in GLOB.spells)
		spell_list[copytext("[A]", type_length)] = A
	var/datum/spell/S = input(client, "Choose the spell to give to that guy", "ABRAKADABRA") as null|anything in spell_list
	if(!S)
		return
	S = spell_list[S]
	if(T.mind)
		T.mind.AddSpell(new S)
	else
		T.AddSpell(new S)

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Spell") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(client)] gave [key_name(T)] the spell [S].")
	message_admins("[key_name_admin(client)] gave [key_name(T)] the spell [S].", 1)

USER_VERB(give_disease, R_EVENT, "Give Disease", VERB_NO_DESCRIPTION, VERB_CATEGORY_HIDDEN, mob/T)
	var/datum/disease/given_disease = null

	if(tgui_input_list(client, "Create own disease", "Would you like to create your own disease?", list("Yes","No")) == "Yes")
		given_disease = AdminCreateVirus(client)
	else
		given_disease = tgui_input_list(client, "ACHOO", "Choose the disease to give to that guy", GLOB.diseases)

	if(!given_disease)
		return

	if(!istype(given_disease, /datum/disease/advance))
		given_disease = new given_disease
	T.ForceContractDisease(given_disease)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Disease") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(client)] gave [key_name(T)] the disease [given_disease].")
	message_admins(SPAN_ADMINNOTICE("[key_name_admin(client)] gave [key_name(T)] the disease [given_disease]."))

USER_VERB(disease_outbreak, R_EVENT, "Disease Outbreak", "Creates a disease and infects a random player with it.", VERB_CATEGORY_EVENT)
	var/datum/disease/given_disease = null
	if(tgui_input_list(client, "Create own disease", "Would you like to create your own disease?", list("Yes","No")) == "Yes")
		given_disease = AdminCreateVirus(client)
	else
		given_disease = tgui_input_list(client, "ACHOO", "Choose the disease to give to that guy", GLOB.diseases)
	if(!given_disease)
		return

	if(!istype(given_disease, /datum/disease/advance))
		given_disease = new given_disease

	for(var/thing in shuffle(GLOB.human_list))
		var/mob/living/carbon/human/H = thing
		if(H.stat == DEAD || !is_station_level(H.z))
			continue
		if(!H.HasDisease(given_disease))
			H.ForceContractDisease(given_disease)
			break
	if(istype(given_disease, /datum/disease/advance))
		var/datum/disease/advance/given_advanced_disease = given_disease
		var/list/name_symptoms = list()
		for(var/datum/symptom/S in given_advanced_disease.symptoms)
			name_symptoms += S.name
		message_admins("[key_name_admin(client)] has triggered a custom virus outbreak of [given_advanced_disease.name]! It has these symptoms: [english_list(name_symptoms)] and these base stats [english_map(given_advanced_disease.base_properties)]")
	else
		message_admins("[key_name_admin(client)] has triggered a custom virus outbreak of [given_disease.name]!")

USER_CONTEXT_MENU(make_sound, R_EVENT, "\[Admin\] Make Sound", obj/O in view())
	if(O)
		var/message = clean_input("What do you want the message to be?", "Make Sound", user = client)
		if(!message)
			return
		for(var/mob/V in hearers(O))
			V.show_message(admin_pencode_to_html(message), 2)
		log_admin("[key_name(client)] made [O] at [O.x], [O.y], [O.z] make a sound")
		message_admins(SPAN_NOTICE("[key_name_admin(client)] made [O] at [O.x], [O.y], [O.z] make a sound"))
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Sound") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_build_mode_self, R_EVENT, "Toggle Build Mode Self", "Toggle Build Mode on yourself.", VERB_CATEGORY_EVENT)
	if(client.mob)
		togglebuildmode(client.mob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Build Mode") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(object_talk, R_EVENT, "oSay", "Display a message to everyone who can hear the target", VERB_CATEGORY_EVENT, msg as text)
	var/mob/living/mob = client.mob
	if(mob.control_object)
		if(!msg)
			return
		for(var/mob/V in hearers(mob.control_object))
			V.show_message("<b>[mob.control_object.name]</b> says: \"" + msg + "\"", 2)
		log_admin("[key_name(client)] used oSay on [mob.control_object]: [msg]")
		message_admins("[key_name_admin(client)] used oSay on [mob.control_object]: [msg]")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "oSay") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(deadmin_self, R_ADMIN|R_MENTOR, "De-admin self", "De-admin yourself.", VERB_CATEGORY_ADMIN)
	log_admin("[key_name(client)] deadmined themself.")
	message_admins("[key_name_admin(client)] deadmined themself.")
	client.deadmin()
	to_chat(client, SPAN_INTERFACE("You are now a normal player."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "De-admin") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_log_hrefs, R_SERVER, "Toggle href logging", "Toggle href logging", VERB_CATEGORY_SERVER)
	if(!client.is_connecting_from_localhost())
		if(tgui_alert(client, "Are you sure about this?", "Confirm", list("Yes", "No")) != "Yes")
			return

	// Why would we ever turn this off?
	if(GLOB.configuration.logging.href_logging)
		GLOB.configuration.logging.href_logging = FALSE
		to_chat(client, "<b>Stopped logging hrefs</b>")
	else
		GLOB.configuration.logging.href_logging = TRUE
		to_chat(client, "<b>Started logging hrefs</b>")

USER_VERB(check_ai_laws, R_ADMIN, "Check AI Laws", "Output AI laws.", VERB_CATEGORY_ADMIN)
	client.holder.output_ai_laws()

USER_VERB(open_law_manager, R_ADMIN, "Manage Silicon Laws", "Open the law manager.", VERB_CATEGORY_ADMIN)
	var/mob/living/silicon/S = input(client, "Select silicon.", "Manage Silicon Laws") as null|anything in GLOB.silicon_mob_list
	if(!S) return

	var/datum/ui_module/law_manager/L = new(S)
	L.ui_interact(client.mob)
	log_and_message_admins("has opened [S]'s law manager.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Manage Silicon Laws") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(change_human_appearance, R_EVENT, "\[Admin\] C.M.A. - Admin", mob/living/carbon/human/H in GLOB.mob_list)
	if(!istype(H))
		if(isbrain(H))
			var/mob/living/brain/B = H
			if(istype(B.container, /obj/item/mmi/robotic_brain/positronic))
				var/obj/item/mmi/robotic_brain/positronic/C = B.container
				var/obj/item/organ/internal/brain/mmi_holder/posibrain/P = C.loc
				if(ishuman(P.owner))
					H = P.owner
			else
				return
		else
			return

	if(client.holder)
		log_and_message_admins("is altering the appearance of [H].")
		H.change_appearance(APPEARANCE_ALL, client.mob, client.mob, check_species_whitelist = 0)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "CMA - Admin") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(change_human_appearance_self, R_EVENT, "\[Admin\] C.M.A. - Self",mob/living/carbon/human/H in GLOB.mob_list)
	if(!istype(H))
		if(isbrain(H))
			var/mob/living/brain/B = H
			if(istype(B.container, /obj/item/mmi/robotic_brain/positronic))
				var/obj/item/mmi/robotic_brain/positronic/C = B.container
				var/obj/item/organ/internal/brain/mmi_holder/posibrain/P = C.loc
				if(ishuman(P.owner))
					H = P.owner
			else
				return
		else
			return

	if(!H.client)
		to_chat(client, "Only mobs with clients can alter their own appearance.")
		return

	switch(alert(client, "Do you wish for [H] to be allowed to select non-whitelisted races?","Alter Mob Appearance","Yes","No","Cancel"))
		if("Yes")
			log_and_message_admins("has allowed [H] to change [H.p_their()] appearance, without whitelisting of races.")
			H.change_appearance(APPEARANCE_ALL, H.loc, check_species_whitelist = 0)
		if("No")
			log_and_message_admins("has allowed [H] to change [H.p_their()] appearance, with whitelisting of races.")
			H.change_appearance(APPEARANCE_ALL, H.loc, check_species_whitelist = 1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "CMA - Self") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(free_job_slot, R_ADMIN, "Free Job Slot", "Frees a station job role.", VERB_CATEGORY_ADMIN)
	var/list/jobs = list()
	for(var/datum/job/J in SSjobs.occupations)
		if(J.current_positions >= J.total_positions && J.total_positions != -1)
			jobs += J.title
	if(!length(jobs))
		to_chat(client, "There are no fully staffed jobs.")
		return
	var/job = input(client, "Please select job slot to free", "Free Job Slot") as null|anything in jobs
	if(job)
		SSjobs.FreeRole(job, force = TRUE)
		log_admin("[key_name(client)] has freed a job slot for [job].")
		message_admins("[key_name_admin(client)] has freed a job slot for [job].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Free Job Slot") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(man_up, R_ADMIN, "\[Admin\] Man Up", mob/T as mob in GLOB.player_list)
	to_chat(T, chat_box_notice_thick(SPAN_NOTICE("<b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.")))
	SEND_SOUND(T, sound('sound/voice/manup1.ogg'))

	log_admin("[key_name(client)] told [key_name(T)] to man up and deal with it.")
	message_admins("[key_name_admin(client)] told [key_name(T)] to man up and deal with it.")

USER_VERB(global_man_up, R_ADMIN, "Man Up Global", "Tells everyone to man up and deal with it.", VERB_CATEGORY_ADMIN)
	if(tgui_alert(client, "Are you sure you want to send the global message?", "Confirm Man Up Global", list("Yes", "No")) == "Yes")
		var/manned_up_sound = sound('sound/voice/manup1.ogg')
		for(var/sissy in GLOB.player_list)
			to_chat(sissy, chat_box_notice_thick(SPAN_NOTICE("<b><font size=4>Man up.<br> Deal with it.</font></b><br>Move on.")))
			SEND_SOUND(sissy, manned_up_sound)

		log_admin("[key_name(client)] told everyone to man up and deal with it.")
		message_admins("[key_name_admin(client)] told everyone to man up and deal with it.")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Man Up Global") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_VERB(toggle_advanced_interaction, R_ADMIN, "Toggle Advanced Admin Interaction", \
		"Allows you to interact with atoms such as buttons and doors, on top of regular machinery interaction.", VERB_CATEGORY_ADMIN)
	client.advanced_admin_interaction = !client.advanced_admin_interaction

	log_admin("[key_name(client)] has [client.advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")
	message_admins("[key_name_admin(client)] has [client.advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")

USER_VERB(show_watchlist, R_ADMIN, "Show Watchlist", "Show the watchlist.", VERB_CATEGORY_ADMIN)
	client.watchlist_show()

USER_VERB(send_alert_message, R_ADMIN, "Send Alert Message", "Sends a large notice to a player.", VERB_CATEGORY_ADMIN, mob/about_to_be_banned)
	if(!ismob(about_to_be_banned))
		return

	var/default_text = "An admin is trying to talk to you!\nCheck your chat window and click their name to respond or you may be banned!"
	var/new_text = tgui_input_text(client, "Input your message, or use the default.", "Admin Message - Text Selector", default_text, 500, TRUE)

	if(!new_text)
		return

	if(default_text == new_text)
		show_blurb(about_to_be_banned, 15, new_text, null, "center", "center", COLOR_RED, null, null, 1)
		log_admin("[key_name(client)] sent a default admin alert to [key_name(about_to_be_banned)].")
		message_admins("[key_name(client)] sent a default admin alert to [key_name(about_to_be_banned)].")
		return

	new_text = strip_html(new_text, 500)

	var/message_color = tgui_input_color(client, "Input your message color:", "Admin Message - Color Selector", COLOR_RED)
	if(isnull(message_color))
		return

	show_blurb(about_to_be_banned, 15, new_text, null, "center", "center", message_color, null, null, 1)
	log_admin("[key_name(client)] sent an admin alert to [key_name(about_to_be_banned)] with custom message \"[new_text]\".")
	message_admins("[key_name(client)] sent an admin alert to [key_name(about_to_be_banned)] with custom message \"[new_text]\".")

USER_VERB(debug_statpanel, R_DEBUG, "Debug Stat Panel", "Toggles local debug of the stat panel", VERB_CATEGORY_DEBUG)
	client.stat_panel.send_message("create_debug")

USER_VERB(profile_code, R_DEBUG|R_VIEWRUNTIMES, "Profile Code", "View code profiler", VERB_CATEGORY_DEBUG)
	winset(client, null, "command=.profile")

USER_VERB(export_character, R_ADMIN, "Export Character DMI/JSON", "Saves character DMI and JSON to data directory.", VERB_CATEGORY_ADMIN)
	if(ishuman(client.mob))
		var/mob/living/carbon/human/H = client.mob
		H.export_dmi_json()

USER_VERB(raw_gas_scan, R_DEBUG|R_VIEWRUNTIMES, "Raw Gas Scan", "Scans your current tile, including LINDA data not normally displayed.", VERB_CATEGORY_DEBUG)
	atmos_scan(client.mob, get_turf(client.mob), silent = TRUE, milla_turf_details = TRUE)

USER_VERB(find_interesting_turf, R_DEBUG|R_VIEWRUNTIMES, "Interesting Turf", \
		"Teleports you to a random Interesting Turf from MILLA", VERB_CATEGORY_DEBUG)
	if(!isobserver(client.mob))
		to_chat(client.mob, SPAN_WARNING("You must be an observer to do this!"))
		return

	var/list/interesting_tile = get_random_interesting_tile()
	if(!length(interesting_tile))
		to_chat(client, SPAN_NOTICE("There are no interesting turfs. How interesting!"))
		return

	var/turf/T = interesting_tile[MILLA_INDEX_TURF]
	var/mob/dead/observer/O = client.mob
	admin_forcemove(O, T)
	O.manual_follow(T)

USER_VERB(visualize_interesting_turfs, R_DEBUG|R_VIEWRUNTIMES, "Visualize Interesting Turfs", "Shows all the Interesting Turfs from MILLA", VERB_CATEGORY_DEBUG)
	if(SSair.interesting_tile_count > 500)
		// This can potentially iterate through a list thats 20k things long. Give ample warning to the user
		if(tgui_alert(client, "WARNING: There are [SSair.interesting_tile_count] Interesting Turfs. This process will be lag intensive and should only be used if the atmos controller \
			is screaming bloody murder. Are you sure you with to continue", "WARNING", list("I am sure", "Nope")) != "I am sure")
			return
	else
		if(tgui_alert(client, "Visualizing turfs may cause server to lag. Are you sure?", "Warning", list("Yes", "No")) != "Yes")
			return

	var/display_turfs_overlay = FALSE
	if(tgui_alert(client, "Would you like to have all interesting turfs have a client side overlay applied as well?", "Optional", list("Yes", "No")) == "Yes")
		display_turfs_overlay = TRUE

	message_admins("[key_name_admin(client)] is visualizing interesting atmos turfs. Server may lag.")

	var/list/zlevel_turf_indexes = list()

	var/list/coords = get_interesting_atmos_tiles()
	if(!length(coords))
		to_chat(client, SPAN_NOTICE("There are no interesting turfs. How interesting!"))
		return

	while(length(coords))
		var/offset = length(coords) - MILLA_INTERESTING_TILE_SIZE
		var/turf/T = coords[offset + MILLA_INDEX_TURF]
		coords.len -= MILLA_INTERESTING_TILE_SIZE


		// ENSURE YOU USE STRING NUMBERS HERE, THIS IS A DICTIONARY KEY NOT AN INDEX!!!
		if(!zlevel_turf_indexes["[T.z]"])
			zlevel_turf_indexes["[T.z]"] = list()
		zlevel_turf_indexes["[T.z]"] |= T
		if(display_turfs_overlay)
			client.images += image('icons/effects/alphacolors.dmi', T, "red")
		CHECK_TICK

	// Sort the keys
	zlevel_turf_indexes = sortAssoc(zlevel_turf_indexes)

	for(var/key in zlevel_turf_indexes)
		to_chat(client, SPAN_NOTICE("Z[key]: <b>[length(zlevel_turf_indexes["[key]"])] Interesting Turfs</b>"))

	var/z_to_view = tgui_input_number(client, "A list of z-levels their ITs has appeared in chat. Please enter a Z to visualize. Enter 0 or close the window to cancel", "Selection", 0)

	if(!z_to_view)
		return

	// Do not combine these
	var/list/ui_dat = list()
	var/list/turf_markers = list()

	var/datum/browser/vis = new(client, "atvis", "Interesting Turfs (Z[z_to_view])", 300, 315)
	ui_dat += "<center><canvas width=\"255px\" height=\"255px\" id=\"atmos\"></canvas></center>"
	ui_dat += "<script>e=document.getElementById(\"atmos\");c=e.getContext('2d');c.fillStyle='#ffffff';c.fillRect(0,0,255,255);function s(x,y){var p=c.createImageData(1,1);p.data\[0]=255;p.data\[1]=0;p.data\[2]=0;p.data\[3]=255;c.putImageData(p,(x-1),255-Math.abs(y-1));}</script>"
	// Now generate the other list
	for(var/x in zlevel_turf_indexes["[z_to_view]"])
		var/turf/T = x
		turf_markers += "s([T.x],[T.y]);"
		CHECK_TICK

	ui_dat += "<script>[turf_markers.Join("")]</script>"

	vis.set_content(ui_dat.Join(""))
	vis.open(FALSE)

USER_VERB(create_rnd_restore_disk, R_ADMIN, "Create RnD Backup Restore Disk", "Create RnD Backup Restore Disk", VERB_CATEGORY_EVENT)
	var/list/targets = list()

	for(var/rnc_uid in SSresearch.backups)
		var/datum/rnd_backup/B = SSresearch.backups[rnc_uid]

		targets["[B.last_name] - [B.last_timestamp]"] = rnc_uid

	var/choice = input(client, "Select a backup to restore", "RnD Backup Restore") as null|anything in targets
	if(!choice || !(choice in targets))
		return

	var/actual_target = targets[choice]
	if(!(actual_target in SSresearch.backups))
		return

	var/datum/rnd_backup/B = SSresearch.backups[actual_target]
	if(tgui_alert(client, "Are you sure you want to restore this RnD backup? The disk will spawn below your character.", "Are you sure?", list("Yes", "No")) != "Yes")
		return

	B.to_backup_disk(get_turf(client.mob))

/proc/ghost_follow_uid(mob/user, uid)
	var/client/client = user.client
	if(!isobserver(user))
		SSuser_verbs.invoke_verb(user, /datum/user_verb/admin_ghost)
	var/datum/target = locateUID(uid)
	if(QDELETED(target))
		to_chat(user, SPAN_WARNING("This datum has been deleted!"))
		return

	if(istype(target, /datum/mind))
		var/datum/mind/mind = target
		if(!ismob(mind.current))
			to_chat(user, SPAN_WARNING("This can only be used on instances of type /mob"))
			return
		target = mind.current

	var/mob/dead/observer/A = client.mob
	A.manual_follow(target)
