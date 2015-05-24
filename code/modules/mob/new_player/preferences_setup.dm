datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
	proc/randomize_appearance_for(var/mob/living/carbon/human/H)
		if(H)
			if(H.gender == MALE)
				gender = MALE
			else
				gender = FEMALE
		if(species == "Human")
			s_tone = random_skin_tone()
		h_style = random_hair_style(gender, species)
		f_style = random_facial_hair_style(gender, species)
		if(species == "Human" || species == "Unathi" || species == "Tajaran" || species == "Skrell" || species == "Machine")
			randomize_hair_color("hair")
		randomize_hair_color("facial")
		randomize_eyes_color()
		if(species == "Unathi" || species == "Tajaran" || species == "Skrell")
			randomize_skin_color()
		underwear = rand(1,underwear_m.len)
		undershirt = rand(1,undershirt_t.len)
		backbag = 2
		age = rand(AGE_MIN,AGE_MAX)
		if(H)
			copy_to(H,1)


	proc/randomize_hair_color(var/target = "hair")
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

	proc/randomize_eyes_color()
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

	proc/randomize_skin_color()
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

	proc/blend_backpack(var/icon/clothes_s,var/backbag,var/satchel,var/backpack="backpack")
		switch(backbag)
			if(2)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', backpack), ICON_OVERLAY)
			if(3)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', satchel), ICON_OVERLAY)
			if(4)
				clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
		return clothes_s


	proc/update_preview_icon()		//seriously. This is horrendous. //less so now
		if(!dummy)
			dummy = new(null, species)
		dummy.set_species(species)
		dummy.flags |= GODMODE
		copy_to(dummy)

		for (var/obj/item/I in dummy)
			if(!istype(I,/obj/item/organ))
				dummy.unEquip(I)
				if(I.loc != dummy)
					qdel(I)

		var/jobflag
		var/dept
		if(job_support_high)
			jobflag = job_support_high
			dept = CIVILIAN
		else if (job_medsci_high)
			jobflag = job_medsci_high
			dept = MEDSCI
		else if (job_engsec_high)
			jobflag = job_engsec_high
			dept = ENGSEC

		if(jobflag && dept && job_master)
			for (var/datum/job/J in job_master.occupations)
				if((J.department_flag & dept) && (J.flag & jobflag))
					var/alt = GetPlayerAltTitle(J)
					if(alt)	//more hacks
						if(!dummy.mind)
							dummy.mind = new
						dummy.mind.role_alt_title = alt
					J.equip(dummy)
					break
		dummy.update_eyes()
		dummy.force_update_limbs()
		dummy.regenerate_icons()
		preview_icon = icon(dummy.icon)
		for(var/image/I in dummy.overlays_standing)
			if(I && I.icon)
				preview_icon.Blend(icon(I.icon, I.icon_state), ICON_OVERLAY)
		preview_icon_front = new(preview_icon, dir = SOUTH)
		preview_icon_side = new(preview_icon, dir = WEST)