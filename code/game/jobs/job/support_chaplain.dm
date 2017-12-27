//Due to how large this one is it gets its own file
/datum/job/chaplain
	title = "Chaplain"
	flag = CHAPLAIN
	department_flag = SUPPORT
	total_positions = 1
	spawn_positions = 1
	is_service = 1
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(access_morgue, access_chapel_office, access_crematorium, access_maint_tunnels)
	minimal_access = list(access_morgue, access_chapel_office, access_crematorium, access_maint_tunnels)

	outfit = /datum/outfit/job/chaplain

/datum/outfit/job/chaplain
	name = "Chaplain"
	jobtype = /datum/job/chaplain

	uniform = /obj/item/clothing/under/rank/chaplain
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/device/radio/headset/headset_service
	pda = /obj/item/device/pda/chaplain
	backpack_contents = list(
		/obj/item/device/camera/spooky = 1
	)

/datum/outfit/job/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	if(visualsOnly)
		return

	var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible(H)

	spawn()
		H.equip_to_slot_or_del(B, slot_l_hand)

		var/religion_name = "Christianity"
		var/new_religion = sanitize(copytext(input(H, "You are the crew services officer. Would you like to change your religion? Default is Christianity, in SPACE.", "Name change", religion_name),1,MAX_NAME_LEN))

		if(!new_religion)
			new_religion = religion_name

		switch(lowertext(new_religion))
			if("christianity")
				B.name = pick("The Holy Bible")
			if("satanism")
				B.name = "The Unholy Bible"
			if("cthulu")
				B.name = "The Necronomicon"
			if("islam")
				B.name = "Quran"
			if("scientology")
				B.name = pick("The Biography of L. Ron Hubbard","Dianetics")
			if("chaos")
				B.name = "The Book of Lorgar"
			if("imperium")
				B.name = "Uplifting Primer"
			if("toolboxia")
				B.name = "Toolbox Manifesto Robusto"
			if("homosexuality")
				B.name = "Guys Gone Wild"
			if("lol", "wtf", "gay", "penis", "ass", "poo", "badmin", "shitmin", "deadmin", "cock", "cocks")
				B.name = pick("Woodys Got Wood: The Aftermath", "War of the Cocks", "Sweet Bro and Hella Jef: Expanded Edition")
				H.setBrainLoss(99) // starts off retarded as fuck
			if("science")
				B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
			else
				B.name = "The Holy Book of [new_religion]"
		feedback_set_details("religion_name","[new_religion]")

		var/deity_name = "Space Jesus"
		var/new_deity = sanitize(copytext(input(H, "Would you like to change your deity? Default is Space Jesus.", "Name change", deity_name),1,MAX_NAME_LEN))

		if((length(new_deity) == 0) || (new_deity == "Space Jesus") )
			new_deity = deity_name
		B.deity_name = new_deity

		var/accepted = 0
		var/outoftime = 0
		spawn(200) // 20 seconds to choose
			outoftime = 1
		var/new_book_style = "Bible"

		while(!accepted)
			if(!B) break // prevents possible runtime errors
			new_book_style = input(H,"Which bible style would you like?") in list("Bible", "Koran", "Scrapbook", "Creeper", "White Bible", "Holy Light", "Athiest", "Tome", "The King in Yellow", "Ithaqua", "Scientology", "the bible melts", "Necronomicon", "Greentext")
			switch(new_book_style)
				if("Koran")
					B.icon_state = "koran"
					B.item_state = "koran"
					for(var/area/chapel/main/A in world)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 4
				if("Scrapbook")
					B.icon_state = "scrapbook"
					B.item_state = "scrapbook"
				if("Creeper")
					B.icon_state = "creeper"
					B.item_state = "syringe_kit"
				if("White Bible")
					B.icon_state = "white"
					B.item_state = "syringe_kit"
				if("Holy Light")
					B.icon_state = "holylight"
					B.item_state = "syringe_kit"
				if("Athiest")
					B.icon_state = "athiest"
					B.item_state = "syringe_kit"
					for(var/area/chapel/main/A in world)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 10
				if("Tome")
					B.icon_state = "tome"
					B.item_state = "syringe_kit"
				if("The King in Yellow")
					B.icon_state = "kingyellow"
					B.item_state = "kingyellow"
				if("Ithaqua")
					B.icon_state = "ithaqua"
					B.item_state = "ithaqua"
				if("Scientology")
					B.icon_state = "scientology"
					B.item_state = "scientology"
					for(var/area/chapel/main/A in world)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 8
				if("the bible melts")
					B.icon_state = "melted"
					B.item_state = "melted"
				if("Necronomicon")
					B.icon_state = "necronomicon"
					B.item_state = "necronomicon"
				if("Greentext")
					B.icon_state = "greentext"
					B.item_state = "greentext"
				else
					// if christian bible, revert to default
					B.icon_state = "bible"
					B.item_state = "bible"
					for(var/area/chapel/main/A in world)
						for(var/turf/T in A.contents)
							if(T.icon_state == "carpetsymbol")
								T.dir = 2

			H.update_inv_l_hand() // so that it updates the bible's item_state in his hand

			switch(input(H,"Look at your bible - is this what you want?") in list("Yes","No"))
				if("Yes")
					accepted = 1
				if("No")
					if(outoftime)
						to_chat(H, "Welp, out of time, buddy. You're stuck. Next time choose faster.")
						accepted = 1

		if(ticker)
			ticker.Bible_icon_state = B.icon_state
			ticker.Bible_item_state = B.item_state
			ticker.Bible_name = B.name
			ticker.Bible_deity_name = B.deity_name
		feedback_set_details("religion_deity","[new_deity]")
		feedback_set_details("religion_book","[new_book_style]")
