//Due to how large this one is it gets its own file
/datum/job/chaplain
	title = "Chaplain"
	flag = JOB_CHAPLAIN
	department_flag = JOBCAT_SUPPORT
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_SERVICE
	supervisors = "the head of personnel"
	department_head = list("Head of Personnel")
	selection_color = "#dddddd"
	access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MAINT_TUNNELS)
	minimal_access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MAINT_TUNNELS)
	outfit = /datum/outfit/job/chaplain

/datum/outfit/job/chaplain
	name = "Chaplain"
	jobtype = /datum/job/chaplain

	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	shoes = /obj/item/clothing/shoes/black
	l_ear = /obj/item/radio/headset/headset_service
	id = /obj/item/card/id/chaplain
	pda = /obj/item/pda/chaplain
	backpack_contents = list(
		/obj/item/camera/spooky = 1,
		/obj/item/nullrod = 1
	)

/datum/outfit/job/chaplain/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()

	if(visualsOnly)
		return

	if(istype(H.mind))
		ADD_TRAIT(H.mind, TRAIT_HOLY, ROUNDSTART_TRAIT)

	INVOKE_ASYNC(src, PROC_REF(religion_pick), H)

/datum/outfit/job/chaplain/proc/religion_pick(mob/living/carbon/human/user)
	var/obj/item/storage/bible/B = new /obj/item/storage/bible(get_turf(user))
	B.customisable = TRUE // Only the initial bible is customisable
	user.put_in_l_hand(B)

	var/religion_name = "Christianity"
	var/new_religion = copytext(clean_input("You are the Chaplain. What name do you give your beliefs? Default is Christianity.", "Name change", religion_name, user), 1, MAX_NAME_LEN)

	if(!new_religion)
		new_religion = religion_name

	switch(lowertext(new_religion))
		if("christianity")
			B.name = "The Holy Bible"
		if("satanism")
			B.name = "The Unholy Bible"
		if("cthulu")
			B.name = "The Necronomicon"
		if("islam")
			B.name = "Quran"
		if("scientology")
			B.name = pick("The Biography of L. Ron Hubbard", "Dianetics")
		if("chaos")
			B.name = "The Book of Lorgar"
		if("imperium")
			B.name = "Uplifting Primer"
		if("toolboxia")
			B.name = "Toolbox Manifesto Robusto"
		if("science")
			B.name = pick("Principle of Relativity", "Quantum Enigma: Physics Encounters Consciousness", "Programming the Universe", "Quantum Physics and Theology", "String Theory for Dummies", "How To: Build Your Own Warp Drive", "The Mysteries of Bluespace", "Playing God: Collector's Edition")
		else
			B.name = "The Holy Book of [new_religion]"
	SSblackbox.record_feedback("text", "religion_name", 1, "[new_religion]", 1)

	var/deity_name = "Space Jesus"
	var/new_deity = copytext(clean_input("Who or what do you worship? Default is Space Jesus.", "Name change", deity_name, user), 1, MAX_NAME_LEN)

	if(!length(new_deity) || (new_deity == "Space Jesus"))
		new_deity = deity_name
	B.deity_name = new_deity
	SSblackbox.record_feedback("text", "religion_deity", 1, "[new_deity]", 1)

	user.AddSpell(new /obj/effect/proc_holder/spell/chaplain_bless(null))

	if(SSticker)
		SSticker.Bible_deity_name = B.deity_name
