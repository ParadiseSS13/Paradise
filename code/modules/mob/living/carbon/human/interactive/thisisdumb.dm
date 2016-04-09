/mob/living/carbon/human/interactive/tigercat/New(loc)
	..(loc, "Tajaran")
	rename_character(name, "Tigercat")

/mob/living/carbon/human/interactive/tigercat/random()
	..()
	gender = "male"

/mob/living/carbon/human/interactive/tigercat/Life()
	reagents.add_reagent("sodiumchloride", 1)
	..()

/mob/living/carbon/human/interactive/tigercat/chatter()
	if(prob(50))
		if(prob(25))
			say("GOD FUCKING DAMNIT FUCKING FUCKING GODDAMN CODE FUCK")
	else
		..()

/mob/living/carbon/human/interactive/fethas/New(loc)
	..(loc, "Unathi")
	rename_character(name, "Fethas")

/mob/living/carbon/human/interactive/fethas/random()
	..()
	gender = "female"

/mob/living/carbon/human/interactive/fethas/setup_job()
	..()
	favoured_types += /obj/structure/closet/cardboard
	functions += "hidebox"

/mob/living/carbon/human/interactive/fethas/proc/hidebox()
	if(shouldModulePass() || !prob(SNPC_FUZZY_CHANCE_LOW))
		return
	var/list/rangeCheck = view(7, src)

	var/obj/structure/closet/C = locate() in rangeCheck

	if(!C)
		C = new /obj/structure/closet/cardboard(get_turf(loc))
		custom_emote(1, "[pick("gibbers","drools","slobbers","claps wildly","spits")], and folds together \a [C]!")

	if(C)
		if(!Adjacent(C))
			tryWalk(C)
		else
			if(!C.opened)
				C.open()
			if(!C.opened)
				return
			forceMove(get_turf(C))
			custom_emote(1, "goes inside \the [C].")
			C.close()

/mob/living/carbon/human/interactive/fethas/chatter()
	if(prob(50))
		if(prob(50))
			custom_emote(2, "[pick("mutters", "gibbers")] something about a box.")
		else if(prob(50))
			say("GOD FUCKING DAMNIT FUCKING FUCKING GODDAMN CODE FUCK")
	else
		..()

/mob/living/carbon/human/interactive/angry/crazylemon/New(loc)
	..(loc, "Machine")
	rename_character(name, "Crazylemon")
	status_flags &= ~CANSTUN

	var/obj/item/weapon/twohanded/mjollnir/M = new(src)
	M.force = 0
	M.force_unwielded = 0
	M.force_wielded = 0
	M.flags |= NODROP
	take_to_slot(M, 1)
	M.wield(src)

/mob/living/carbon/human/interactive/angry/crazylemon/random()
	..()
	gender = "male"

/mob/living/carbon/human/interactive/fox
	default_job = /datum/job/scientist

/mob/living/carbon/human/interactive/fox/New(loc)
	..(loc, "Vulpkanin")
	rename_character(name, "Fox P McCloud")

/mob/living/carbon/human/interactive/fox/doSetup()
	..("Chemical Researcher")

/mob/living/carbon/human/interactive/fox/random()
	..()
	gender = "male"
	r_eyes = 0
	g_eyes = 255
	b_eyes = 0
	r_facial = 255
	g_facial = 255
	b_facial = 255
	r_skin = 150
	g_skin = 35
	b_skin = 1
	h_style = "None"
	f_style = "Vulpine and Earfluff"
	ha_style = "Vulpine and Earfluff"
	body_accessory = body_accessory_by_name["Vulpkanin Alt 2 (Straight)"]

	take_to_slot(new /obj/item/weapon/reagent_containers/food/snacks/grown/orange, 1)