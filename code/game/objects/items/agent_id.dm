/obj/item/card/id/syndicate
	name = "agent card"
	origin_tech = "syndicate=1"
	untrackable = TRUE
	/// List of access types the agent ID should start off with
	var/list/initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS)
	/// Editing is prohibited if registered_human reference is missing
	var/mob/living/carbon/human/registered_human
	// Static list of all occupations available when changing the occupation on an agent ID
	var/static/list/possible_jobs
	/// The HUD icon that should be displayed on a mob that is wearing the agent ID
	var/hud_icon

	COOLDOWN_DECLARE(new_photo_cooldown)

/obj/item/card/id/syndicate/Initialize(mapload)
	. = ..()
	access = initial_access.Copy()
	if(!length(possible_jobs))
		possible_jobs = sortTim(GLOB.joblist, GLOBAL_PROC_REF(cmp_text_asc))

/obj/item/card/id/syndicate/Destroy()
	registered_human = null
	return ..()

/obj/item/card/id/syndicate/researcher
	initial_access = list(ACCESS_SYNDICATE)
	assignment = "Syndicate Researcher"
	icon_state = "syndie"

/obj/item/card/id/syndicate/vox
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_VOX, ACCESS_EXTERNAL_AIRLOCKS)

/obj/item/card/id/syndicate/ghost_bar
	name = "ghost bar identification card"
	assignment = "Ghost Bar Occupant"
	initial_access = list() // This is for show, they don't need actual accesses
	icon_state = "assistant"

/obj/item/card/id/syndicate/command
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND, ACCESS_EXTERNAL_AIRLOCKS)
	icon_state = "commander"

/obj/item/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	icon_state = "syndie"
	assignment = "Syndicate Overlord"
	untrackable = TRUE
	can_id_flash = FALSE //This can ID flash, this just prevents it from always flashing.
	access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND, ACCESS_EXTERNAL_AIRLOCKS)

/obj/item/card/id/syndicate/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(istype(target, /obj/item/card/id))
		var/obj/item/card/id/I = target
		if(isliving(user) && user?.mind?.special_role)
			to_chat(usr, "<span class='notice'>The card's microscanners activate as you pass it over [I], copying its access.</span>")
			access |= I.access //Don't copy access if user isn't an antag -- to prevent metagaming
			return ITEM_INTERACT_COMPLETE

/obj/item/card/id/syndicate/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!registered_human || !Adjacent(registered_human))
		return
	. = TRUE
	switch(action)
		if("delete_info")
			delete_info(ui)
		if("clear_access")
			clear_access()
		if("change_ai_tracking")
			change_ai_tracking()
		if("change_name")
			change_name(params["option"], params["name"])
		if("change_photo")
			change_photo()
		if("change_appearance")
			change_appearance(params["new_appearance"])
		if("change_sex")
			change_sex(params["sex"])
		if("change_age")
			change_age(params["age"])
		if("change_occupation")
			change_occupation(params["option"])
		if("change_money_account")
			change_money_account(params["option"], params["new_account"])
		if("change_blood_type")
			change_blood_type(params["option"], params["new_type"])
		if("change_dna_hash")
			change_dna_hash(params["option"], params["new_dna"])
		if("change_fingerprints")
			change_fingerprints(params["option"], params["new_fingerprints"])
	RebuildHTML()

/obj/item/card/id/syndicate/ui_data(mob/user)
	var/list/data = list()
	data["registered_name"] = registered_name
	data["sex"] = sex
	data["age"] = age
	data["assignment"] = assignment
	data["job_icon"] = hud_icon
	data["associated_account_number"] = associated_account_number
	data["blood_type"] = blood_type
	data["dna_hash"] = dna_hash
	data["fingerprint_hash"] = fingerprint_hash
	data["photo"] = photo
	data["ai_tracking"] = untrackable
	data["photo_cooldown"] = COOLDOWN_FINISHED(src, new_photo_cooldown)
	return data

/obj/item/card/id/syndicate/ui_static_data(mob/user)
	var/list/data = list()
	var/list/idcard_skins = list()
	for(var/idcard_skin in get_all_card_skins())
		idcard_skins.Add(idcard_skin)
	data["appearances"] = idcard_skins
	data["id_icon"] = icon
	return data

/obj/item/card/id/syndicate/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AgentCard", name)
		ui.open()

/obj/item/card/id/syndicate/activate_self(mob/user)
	if(..() || !ishuman(user))
		return
	if(!registered_human)
		registered_human = user
	if(registered_human != user)
		flash_card(user)
		return
	switch(tgui_alert(user, "Would you like to display [src] or edit it?", "Choose", list("Edit", "Show")))
		if("Show")
			flash_card(user)
		if("Edit")
			ui_interact(user)

/obj/item/card/id/syndicate/proc/delete_info(datum/tgui/ui)
	name = initial(name)
	registered_name = initial(registered_name)
	icon_state = initial(icon_state)
	sex = initial(sex)
	age = initial(age)
	assignment = initial(assignment)
	rank = initial(rank)
	associated_account_number = initial(associated_account_number)
	blood_type = initial(blood_type)
	dna_hash = initial(dna_hash)
	fingerprint_hash = initial(fingerprint_hash)
	photo = null
	registered_human.sec_hud_set_ID()
	registered_human = null
	ui.close()

/obj/item/card/id/syndicate/proc/clear_access()
	access = initial_access.Copy() // Initial() doesn't work on lists
	to_chat(registered_human, "<span class='notice'>Card access reset.</span>")

/obj/item/card/id/syndicate/proc/change_ai_tracking()
	untrackable = !untrackable

/obj/item/card/id/syndicate/proc/change_name(option, name)
	var/new_name
	if(option == "Primary")
		new_name = ishuman(registered_human) ? registered_human.real_name : registered_human.name
	else if(option == "Secondary")
		new_name = tgui_input_list(registered_human, "Whose name do you want to copy?", "Agent ID - Name", GLOB.crew_list)
		if(isnull(new_name))
			return
	else
		new_name = sanitize(name)

	registered_name = reject_bad_name(new_name, TRUE)
	UpdateName()
	to_chat(registered_human, "ID name has been changed to [new_name].")

/obj/item/card/id/syndicate/proc/change_photo()
	if(!COOLDOWN_FINISHED(src, new_photo_cooldown))
		return
	var/job_clothes = null
	if(assignment)
		job_clothes = assignment
	var/icon/newphoto = get_id_photo(registered_human, job_clothes)
	if(!newphoto)
		return
	photo = newphoto
	COOLDOWN_START(src, new_photo_cooldown, 10 SECONDS) // This proc is expensive, we don't want people spamming it.

/obj/item/card/id/syndicate/proc/change_appearance(new_appearance)
	if(!new_appearance)
		return
	if(new_appearance in icon_states(icon))
		icon_state = new_appearance

/obj/item/card/id/syndicate/proc/change_sex(new_sex)
	if(!Adjacent(registered_human) || isnull(new_sex))
		return

	sex = sanitize(new_sex)

/obj/item/card/id/syndicate/proc/change_age(new_age)
	age = clamp(new_age, AGE_MIN, AGE_MAX)

/obj/item/card/id/syndicate/proc/change_occupation(option)
	var/new_job
	var/new_rank
	if(option == "Primary")
		new_job = assignment
		new_rank = tgui_input_list(registered_human, "What SecHUD icon would you like to be shown on this card?", "Agent Card Occupation", GLOB.joblist + "Prisoner" + "Centcom" + "Solgov" + "Soviet" + "Unknown")
	else
		var/department = tgui_input_list(registered_human, "Do you want a custom occupation?", "Agent Card Occupation", list("Existing job", "Custom"))
		if(department != "Custom")
			new_job = tgui_input_list(registered_human, "What job would you like to put on this card?", "Agent Card Occupation", possible_jobs)
			new_rank = new_job
		else
			new_job = sanitize(tgui_input_text(registered_human, "Choose a custom job title:", "Agent Card Occupation", "Assistant", MAX_MESSAGE_LEN))
			new_rank = tgui_input_list(registered_human, "What SecHUD icon would you like to be shown on this card?", "Agent Card Occupation", GLOB.joblist + "Prisoner" + "Centcom" + "Solgov" + "Soviet" + "Unknown")

	if(!Adjacent(registered_human) || isnull(new_job))
		return
	assignment = new_job
	rank = new_rank
	hud_icon = ckey(get_job_name())
	UpdateName()
	registered_human.sec_hud_set_ID()

/obj/item/card/id/syndicate/proc/change_money_account(option, new_account)
	if(option == "Primary")
		new_account = registered_human.mind.initial_account?.account_number
		if(!new_account)
			to_chat(registered_human, "You don't have an account.")
			return
	else if(option == "Secondary")
		new_account = rand(1000, 9999) * 1000 + rand(1000, 9999)
	else
		new_account = text2num(new_account)
		if(!isnum(new_account))
			to_chat(registered_human, "ID account number can only contain numbers.")
			return

	associated_account_number = clamp(new_account, 1000000, 9999999)
	to_chat(registered_human, "ID account number has been changed to [new_account].")

/obj/item/card/id/syndicate/proc/change_blood_type(option, new_type)
	var/list/possible_blood_types = list("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "Slime Jelly", "None")
	if(option == "Primary")
		blood_type = registered_human.dna.blood_type
	else if(new_type)
		if(!(new_type in possible_blood_types))
			return
		blood_type = new_type
	to_chat(registered_human, "ID blood type has been changed to [blood_type].")

/obj/item/card/id/syndicate/proc/change_dna_hash(option, new_dna)
	if(option == "Primary")
		dna_hash = registered_human.dna.unique_enzymes
	else if(option == "Secondary")
		dna_hash = md5(num2text(rand(0, 999)))
	else
		if(new_dna)
			dna_hash = sanitize(new_dna, 33) // Max length of 32 characters

/obj/item/card/id/syndicate/proc/change_fingerprints(option, new_fingerprints)
	if(option == "Primary")
		fingerprint_hash = md5(registered_human.dna.uni_identity)
	else if(option == "Secondary")
		fingerprint_hash = md5(num2text(rand(0, 999)))
	else
		var/fingerprints_param  = new_fingerprints
		if(fingerprints_param)
			fingerprint_hash = sanitize(fingerprints_param, 33)

/// like /obj/item/card/id/syndicate, but you can only swipe access, not change your identity, its also trackable
/obj/item/card/id/syndi_scan_only
	name = "Syndicate Operative's ID card (Operative)"
	rank = "Operative"
	assignment = "Operative"
	registered_name = "Syndicate Operative"
	access = list(ACCESS_SYNDICATE)

/obj/item/card/id/syndi_scan_only/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='notice'>Similar to an agent ID, this ID card can be used to copy accesses, but it lacks the customization and anti-tracking capabilities of an agent ID.</span>"

/obj/item/card/id/syndi_scan_only/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(istype(target, /obj/item/card/id))
		var/obj/item/card/id/I = target
		if(isliving(user) && user.mind)
			if(user.mind.special_role)
				to_chat(user, "<span class='notice'>The card's microscanners activate as you pass it over [I], copying its access.</span>")
				access |= I.access // Don't copy access if user isn't an antag -- to prevent metagaming
				return ITEM_INTERACT_COMPLETE
