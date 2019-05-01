/datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	var/datum/species/S = GLOB.all_species[species]
	if(!istype(S)) //The species was invalid. Set the species to the default, fetch the datum for that species and generate a random character.
		species = initial(species)
		S = GLOB.all_species[species]
	var/datum/robolimb/robohead

	if(S.bodyflags & ALL_RPARTS)
		var/head_model = "[!rlimb_data["head"] ? "Morpheus Cyberkinetics" : rlimb_data["head"]]"
		robohead = all_robolimbs[head_model]
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE, FEMALE)
	underwear = random_underwear(gender, species)
	undershirt = random_undershirt(gender, species)
	socks = random_socks(gender, species)
	if(body_accessory_by_species[species])
		body_accessory = random_body_accessory(species)
		if(body_accessory == "None") //Required to prevent a bug where the information/icons in the character preferences screen wouldn't update despite the data being changed.
			body_accessory = null
	if(S.bodyflags & (HAS_SKIN_TONE|HAS_ICON_SKIN_TONE))
		s_tone = random_skin_tone(species)
	h_style = random_hair_style(gender, species, robohead)
	f_style = random_facial_hair_style(gender, species, robohead)
	if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Wryn", "Vulpkanin", "Vox"))
		randomize_hair_color("hair")
		randomize_hair_color("facial")
	if(S.bodyflags & HAS_HEAD_ACCESSORY)
		ha_style = random_head_accessory(species)
		hacc_colour = randomize_skin_color(1)
	if(S.bodyflags & HAS_HEAD_MARKINGS)
		m_styles["head"] = random_marking_style("head", species, robohead, null, alt_head)
		m_colours["head"] = randomize_skin_color(1)
	if(S.bodyflags & HAS_BODY_MARKINGS)
		m_styles["body"] = random_marking_style("body", species)
		m_colours["body"] = randomize_skin_color(1)
	if(S.bodyflags & HAS_TAIL_MARKINGS) //Species with tail markings.
		m_styles["tail"] = random_marking_style("tail", species, null, body_accessory)
		m_colours["tail"] = randomize_skin_color(1)
	if(!(S.bodyflags & ALL_RPARTS))
		randomize_eyes_color()
	if(S.bodyflags & HAS_SKIN_COLOR)
		randomize_skin_color()
	backbag = 2
	age = rand(AGE_MIN, AGE_MAX)


/datum/preferences/proc/randomize_hair_color(var/target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		f_colour = h_colour
		return

	var/red
	var/green
	var/blue

	var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
	switch(col)
		if("blonde")
			red = 255
			green = 255
			blue = 0
		if("black")
			red = 0
			green = 0
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 51
		if("copper")
			red = 255
			green = 153
			blue = 0
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("wheat")
			red = 255
			green = 255
			blue = 153
		if("old")
			red = rand (100, 255)
			green = red
			blue = red
		if("punk")
			red = rand (0, 255)
			green = rand (0, 255)
			blue = rand (0, 255)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	switch(target)
		if("hair")
			h_colour = rgb(red, green, blue)
		if("facial")
			f_colour = rgb(red, green, blue)

/datum/preferences/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	e_colour = rgb(red, green, blue)

/datum/preferences/proc/randomize_skin_color(var/pass_on)
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	if(pass_on)
		return rgb(red, green, blue)
	else
		s_colour = rgb(red, green, blue)

/datum/preferences/proc/blend_backpack(var/icon/clothes_s,var/backbag,var/satchel,var/backpack="backpack")
	switch(backbag)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', backpack), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', satchel), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
	return clothes_s



// Determine what job is marked as 'High' priority, and dress them up as such.
/datum/preferences/proc/get_highest_job()
	var/highRankFlag = job_support_high | job_medsci_high | job_engsec_high | job_karma_high

	if(job_support_low & CIVILIAN)
		return SSjobs.GetJob("Civilian")
	else if(highRankFlag)
		var/highDeptFlag
		if(job_support_high)
			highDeptFlag = SUPPORT
		else if(job_medsci_high)
			highDeptFlag = MEDSCI
		else if(job_engsec_high)
			highDeptFlag = ENGSEC
		else if(job_karma_high)
			highDeptFlag = KARMA

		for(var/datum/job/job in SSjobs.occupations)
			if(job.flag & highRankFlag && job.department_flag == highDeptFlag)
				return job

/datum/preferences/proc/update_preview_icon()
	// Silicons only need a very basic preview since there is no customization for them.
	if(job_engsec_high)
		switch(job_engsec_high)
			if(AI)
				preview_icon = icon('icons/mob/AI.dmi', "AI", SOUTH)
				preview_icon.Scale(64, 64)
				return
			if(CYBORG)
				preview_icon = icon('icons/mob/robots.dmi', "robot", SOUTH)
				preview_icon.Scale(64, 64)
				return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	copy_to(mannequin)

	var/datum/job/previewJob

	previewJob = get_highest_job()

	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE, FALSE, alt_title = GetPlayerAltTitle(previewJob))

	COMPILE_OVERLAYS(mannequin)
	CHECK_TICK
	preview_icon = icon('icons/effects/effects.dmi', "nothing")
	preview_icon.Scale(48+32, 16+32)
	CHECK_TICK
	mannequin.setDir(NORTH)

	var/icon/stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 25, 17)
	CHECK_TICK
	mannequin.setDir(WEST)
	stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 1, 9)
	CHECK_TICK
	mannequin.setDir(SOUTH)
	stamp = getFlatIcon(mannequin)
	CHECK_TICK
	preview_icon.Blend(stamp, ICON_OVERLAY, 49, 1)
	CHECK_TICK
	preview_icon.Scale(preview_icon.Width() * 2, preview_icon.Height() * 2) // Scaling here to prevent blurring in the browser.
	CHECK_TICK
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
