/datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE, FEMALE)
	underwear = random_underwear(gender, species)
	undershirt = random_undershirt(gender, species)
	socks = random_socks(gender, species)
	if(species in list("Human", "Drask"))
		s_tone = random_skin_tone()
	h_style = random_hair_style(gender, species)
	f_style = random_facial_hair_style(gender, species)
	if(species == "Human" || species == "Unathi" || species == "Tajaran" || species == "Skrell" || species == "Machine" || species == "Vulpkanin")
		randomize_hair_color("hair")
	randomize_hair_color("facial")
	randomize_eyes_color()
	if(species == "Unathi" || species == "Tajaran" || species == "Skrell" || species == "Vulpkanin")
		randomize_skin_color()
	backbag = 2
	age = rand(AGE_MIN,AGE_MAX)


/datum/preferences/proc/randomize_hair_color(var/target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		r_facial = r_hair
		g_facial = g_hair
		b_facial = b_hair
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
			r_hair = red
			g_hair = green
			b_hair = blue
		if("facial")
			r_facial = red
			g_facial = green
			b_facial = blue

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

	r_eyes = red
	g_eyes = green
	b_eyes = blue

/datum/preferences/proc/randomize_skin_color()
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

	r_skin = red
	g_skin = green
	b_skin = blue

/datum/preferences/proc/blend_backpack(var/icon/clothes_s,var/backbag,var/satchel,var/backpack="backpack")
	switch(backbag)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', backpack), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', satchel), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
	return clothes_s

/datum/preferences/proc/update_preview_icon(var/for_observer=0)		//seriously. This is horrendous.
	qdel(preview_icon_front)
	qdel(preview_icon_side)
	qdel(preview_icon)

	var/g = "m"
	if(gender == FEMALE)	g = "f"

	var/icon/icobase
	var/datum/species/current_species = all_species[species]

	//Icon-based species colour.
	var/coloured_tail
	if(current_species)
		if(current_species.bodyflags & HAS_ICON_SKIN_TONE) //Handling species-specific icon-based skin tones by flagged race.
			var/mob/living/carbon/human/H = new
			H.species = current_species
			H.s_tone = s_tone
			H.species.updatespeciescolor(H)

			icobase = H.species.icobase
			if(H.species.bodyflags & HAS_TAIL)
				coloured_tail = H.species.tail
			qdel(H)
		else
			icobase = current_species.icobase
	else
		icobase = 'icons/mob/human_races/r_human.dmi'

	var/fat=""
	if(disabilities & DISABILITY_FLAG_FAT && current_species.flags & CAN_BE_FAT)
		fat="_fat"
	preview_icon = new /icon(icobase, "torso_[g][fat]")
	preview_icon.Blend(new /icon(icobase, "groin_[g]"), ICON_OVERLAY)
	preview_icon.Blend(new /icon(icobase, "head_[g]"), ICON_OVERLAY)

	//Tail
	if(current_species && (current_species.bodyflags & HAS_TAIL))
		var/tail_icon
		var/tail_icon_state

		if(body_accessory)
			var/datum/body_accessory/accessory = body_accessory_by_name[body_accessory]
			tail_icon = accessory.icon
			tail_icon_state = accessory.icon_state
		else
			tail_icon = "icons/effects/species.dmi"
			if(coloured_tail)
				tail_icon_state = "[coloured_tail]_s"
			else
				tail_icon_state = "[current_species.tail]_s"

		var/icon/temp = new /icon("icon" = tail_icon, "icon_state" = tail_icon_state)
		preview_icon.Blend(temp, ICON_OVERLAY)

	for(var/name in list("chest", "groin", "head", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "l_arm", "l_hand"))
		if(organ_data[name] == "amputated") continue
		if(organ_data[name] == "cyborg")
			var/datum/robolimb/R
			if(rlimb_data[name]) R = all_robolimbs[rlimb_data[name]]
			if(!R) R = basic_robolimb
			if(name == "chest")
				name = "torso"
			preview_icon.Blend(icon(R.icon, "[name]"), ICON_OVERLAY) // This doesn't check gendered_icon. Not an issue while only limbs can be robotic.
			continue
		preview_icon.Blend(new /icon(icobase, "[name]"), ICON_OVERLAY)

	// Skin color
	if(current_species && (current_species.bodyflags & HAS_SKIN_COLOR))
		preview_icon.Blend(rgb(r_skin, g_skin, b_skin), ICON_ADD)

	// Skin tone
	if(current_species && (current_species.bodyflags & HAS_SKIN_TONE))
		if(s_tone >= 0)
			preview_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-s_tone,  -s_tone,  -s_tone), ICON_SUBTRACT)

	//Body Markings
	if(current_species && (current_species.bodyflags & HAS_MARKINGS))
		var/datum/sprite_accessory/marking_style = marking_styles_list[m_style]
		if(marking_style && marking_style.species_allowed)
			var/icon/markings_s = new/icon("icon" = marking_style.icon, "icon_state" = "[marking_style.icon_state]_s")
			markings_s.Blend(rgb(r_markings, g_markings, b_markings), ICON_ADD)
			preview_icon.Blend(markings_s, ICON_OVERLAY)


	var/icon/face_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "bald_s")
	if(!(current_species.bodyflags & NO_EYES))
		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = current_species ? current_species.eyes : "eyes_s")
		eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
		face_s.Blend(eyes_s, ICON_OVERLAY)


	var/datum/sprite_accessory/hair_style = hair_styles_list[h_style]
	if(hair_style)
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		if(current_species.name == "Slime People") // whee I am part of the problem
			hair_s.Blend(rgb(r_skin, g_skin, b_skin, 160), ICON_ADD)
		else
			hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
		face_s.Blend(hair_s, ICON_OVERLAY)

	//Head Accessory
	if(current_species && (current_species.bodyflags & HAS_HEAD_ACCESSORY))
		var/datum/sprite_accessory/head_accessory_style = head_accessory_styles_list[ha_style]
		if(head_accessory_style && head_accessory_style.species_allowed)
			var/icon/head_accessory_s = new/icon("icon" = head_accessory_style.icon, "icon_state" = "[head_accessory_style.icon_state]_s")
			head_accessory_s.Blend(rgb(r_headacc, g_headacc, b_headacc), ICON_ADD)
			face_s.Blend(head_accessory_s, ICON_OVERLAY)

	var/datum/sprite_accessory/facial_hair_style = facial_hair_styles_list[f_style]
	if(facial_hair_style && facial_hair_style.species_allowed)
		var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		if(current_species.name == "Slime People") // whee I am part of the problem
			facial_s.Blend(rgb(r_skin, g_skin, b_skin, 160), ICON_ADD)
		else
			facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
		face_s.Blend(facial_s, ICON_OVERLAY)

	var/icon/underwear_s = null
	if(underwear && (current_species.clothing_flags & HAS_UNDERWEAR))
		var/datum/sprite_accessory/underwear/U = underwear_list[underwear]
		if(U)
			underwear_s = new/icon(U.icon, "uw_[U.icon_state]_s", ICON_OVERLAY)

	var/icon/undershirt_s = null
	if(undershirt && (current_species.clothing_flags & HAS_UNDERSHIRT))
		var/datum/sprite_accessory/undershirt/U2 = undershirt_list[undershirt]
		if(U2)
			undershirt_s = new/icon(U2.icon, "us_[U2.icon_state]_s", ICON_OVERLAY)

	var/icon/socks_s = null
	if(socks && (current_species.clothing_flags & HAS_SOCKS))
		var/datum/sprite_accessory/socks/U3 = socks_list[socks]
		if(U3)
			socks_s = new/icon(U3.icon, "sk_[U3.icon_state]_s", ICON_OVERLAY)

	var/icon/clothes_s = null
	var/uniform_dmi='icons/mob/uniform.dmi'
	if(disabilities&DISABILITY_FLAG_FAT)
		uniform_dmi='icons/mob/uniform_fat.dmi'
	if(job_support_low & CIVILIAN)//This gives the preview icon clothes depending on which job(if any) is set to 'high'
		clothes_s = new /icon(uniform_dmi, "grey_s")
		clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if(backbag == 2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		else if(backbag == 3 || backbag == 4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	else if(job_support_high)//I hate how this looks, but there's no reason to go through this switch if it's empty
		switch(job_support_high)
			if(HOP)
				clothes_s = new /icon(uniform_dmi, "hop_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "ianshirt"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(BARTENDER)
				clothes_s = new /icon(uniform_dmi, "ba_suit_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "tophat"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(BOTANIST)
				clothes_s = new /icon(uniform_dmi, "hydroponics_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "ggloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "apron"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "nymph"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-hyd"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(CHEF)
				clothes_s = new /icon(uniform_dmi, "chef_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "chefhat"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "apronchef"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(JANITOR)
				clothes_s = new /icon(uniform_dmi, "janitor_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "bio_janitor"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(LIBRARIAN)
				clothes_s = new /icon(uniform_dmi, "red_suit_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "hairflower"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(QUARTERMASTER)
				clothes_s = new /icon(uniform_dmi, "qm_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "poncho"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(CARGOTECH)
				clothes_s = new /icon(uniform_dmi, "cargotech_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "flat_cap"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(MINER)
				clothes_s = new /icon(uniform_dmi, "miner_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "bearpelt"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(LAWYER)
				clothes_s = new /icon(uniform_dmi, "internalaffairs_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/inhands/items_righthand.dmi', "briefcase"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "suitjacket_blue"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(CHAPLAIN)
				clothes_s = new /icon(uniform_dmi, "chapblack_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "imperium_monk"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(CLOWN)
				clothes_s = new /icon(uniform_dmi, "clown_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "clown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "clown"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "clownpack"), ICON_OVERLAY)
			if(MIME)
				clothes_s = new /icon(uniform_dmi, "mime_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "lgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "mime"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "suspenders"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	else if(job_medsci_high)
		switch(job_medsci_high)
			if(RD)
				clothes_s = new /icon(uniform_dmi, "director_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "petehat"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-tox"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(SCIENTIST)
				clothes_s = new /icon(uniform_dmi, "toxinswhite_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "metroid"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-tox"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(CHEMIST)
				clothes_s = new /icon(uniform_dmi, "chemistrywhite_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labgreen"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-chem"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(CMO)
				clothes_s = new /icon(uniform_dmi, "cmo_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "bio_cmo"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_cmo_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(DOCTOR)
				clothes_s = new /icon(uniform_dmi, "medical_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "surgeon"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(GENETICIST)
				clothes_s = new /icon(uniform_dmi, "geneticswhite_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "monkeysuit"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_gen_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-gen"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(VIROLOGIST)
				clothes_s = new /icon(uniform_dmi, "virologywhite_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "sterile"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_vir_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "plaguedoctor"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-vir"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(PSYCHIATRIST)
				clothes_s = new /icon(uniform_dmi, "psych_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(PARAMEDIC)
				clothes_s = new /icon(uniform_dmi, "paramedic_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigoff"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "bluesoft"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
			if(ROBOTICIST)
				clothes_s = new /icon(uniform_dmi, "robotics_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "labcoat_open"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/inhands/items_righthand.dmi', "toolbox_blue"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	else if(job_engsec_high)
		switch(job_engsec_high)
			if(CAPTAIN)
				clothes_s = new /icon(uniform_dmi, "captain_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "centcomcaptain"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "captain"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-cap"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(HOS)
				clothes_s = new /icon(uniform_dmi, "hosred_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret_hos"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(WARDEN)
				clothes_s = new /icon('icons/mob/uniform.dmi', "warden_s")
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "slippers_worn"), ICON_OVERLAY)
				else
					clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(DETECTIVE)
				clothes_s = new /icon(uniform_dmi, "detective_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/mask.dmi', "cigaron"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "detective"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "detective"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(OFFICER)
				clothes_s = new /icon(uniform_dmi, "secred_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/head.dmi', "beret_officer"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(CHIEF)
				clothes_s = new /icon(uniform_dmi, "chief_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "brown"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_white"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/inhands/items_righthand.dmi', "blueprints"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "engiepack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(ENGINEER)
				clothes_s = new /icon(uniform_dmi, "engine_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "orange"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "hazard"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "engiepack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(ATMOSTECH)
				clothes_s = new /icon(uniform_dmi, "atmos_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "bgloves"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				if(prob(1))
					clothes_s.Blend(new /icon('icons/mob/suit.dmi', "firesuit"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

			if(AI)//Gives AI and borgs assistant-wear, so they can still customize their character
				clothes_s = new /icon(uniform_dmi, "grey_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "straight_jacket"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "cardborg_h"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(CYBORG)
				clothes_s = new /icon(uniform_dmi, "grey_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "cardborg"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "cardborg_h"), ICON_OVERLAY)
				if(backbag == 2)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
				else if(backbag == 3 || backbag == 4)
					clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
	else if(job_karma_high)
		switch(job_karma_high)
			if(MECHANIC)
				clothes_s = new /icon(uniform_dmi, "mechanic_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "orange"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/belt.dmi', "utility"), ICON_OVERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "hardhat0_yellow"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "engiepack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-eng"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(PILOT)
				clothes_s = new /icon(uniform_dmi, "secred_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "bomber"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-sec"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(BRIGDOC)
				clothes_s = new /icon(uniform_dmi, "medical_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "white"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "fr_jacket_open"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "medicalpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-med"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(NANO)
				clothes_s = new /icon(uniform_dmi, "officer_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(BLUESHIELD)
				clothes_s = new /icon(uniform_dmi, "officer_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "jackboots"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/hands.dmi', "swat_gl"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "blueshield"), ICON_OVERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "securitypack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
			if(JUDGE)
				clothes_s = new /icon(uniform_dmi, "really_black_suit_s")
				clothes_s.Blend(new /icon('icons/mob/feet.dmi', "laceups"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/head.dmi', "mercy_hood"), ICON_UNDERLAY)
				clothes_s.Blend(new /icon('icons/mob/suit.dmi', "judge"), ICON_UNDERLAY)
				switch(backbag)
					if(2)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
					if(3)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel-norm"), ICON_OVERLAY)
					if(4)
						clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	if(disabilities & NEARSIGHTED)
		preview_icon.Blend(new /icon('icons/mob/eyes.dmi', "glasses"), ICON_OVERLAY)

	// Observers get tourist outfit.
	if(for_observer)
		clothes_s = new /icon(uniform_dmi, "tourist_s")
		clothes_s.Blend(new /icon('icons/mob/feet.dmi', "black"), ICON_UNDERLAY)
		if(backbag == 2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "backpack"), ICON_OVERLAY)
		else if(backbag == 3 || backbag == 4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)

	if(underwear_s)
		preview_icon.Blend(underwear_s, ICON_OVERLAY)
	if(undershirt_s)
		preview_icon.Blend(undershirt_s, ICON_OVERLAY)
	if(socks_s)
		preview_icon.Blend(socks_s, ICON_OVERLAY)
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)
	preview_icon.Blend(face_s, ICON_OVERLAY)
	preview_icon_front = new(preview_icon, dir = SOUTH)
	preview_icon_side = new(preview_icon, dir = WEST)

	qdel(face_s)
	qdel(underwear_s)
	qdel(undershirt_s)
	qdel(socks_s)
	qdel(clothes_s)
