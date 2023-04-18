/obj/item/paper/syndicate/code_words
	name = "Code Words"

/obj/item/paper/syndicate/code_words/New()
	..()

	var/phrases = jointext(GLOB.syndicate_code_phrase, ", ")
	var/responses = jointext(GLOB.syndicate_code_response, ", ")
	info += "<B>Синдикат предоставил вам следующие кодовые слова, чтобы определять потенциальных агентов на станции:</B><BR>\n"
	info += "<B>Кодовые слова: </B>[phrases]<BR>\n"
	info += "<B>Кодовые ответы: </B>[responses]<BR>\n"
	info += "Используйте слова при общении с потенциальными агентами. В тоже время будьте осторожны, ибо кто угодно может оказаться потенциальным врагом."
	info_links = info
	overlays += "paper_words"

// Space Base Spawners. Исспользуется переделанная копия спавнеров лавалендовских.
/obj/effect/mob_spawn/human/space_base_syndicate
	name = "Syndicate Scientist sleeper"
	mob_name = "Syndicate Scientist"
	roundstart = FALSE
	death = FALSE
	id_job = "Syndicate Scientist"
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "cryo_s"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Эксперементируйте со смертельными химикатами, растениями, генами и вирусами. Наслаждайтесь спокойной жизнью зная, что ваша работа так или иначе насолит НТ в будущем!"
	flavour_text = "Вы агент синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Продолжайте свои исследования на сколько можете и постарайтесь не высовываться. \
	Вам дали ясно понять, что синдикат заставит вас очень сильно пожалеть если вы разочаруете их!"
	outfit = /datum/outfit/space_base_syndicate
	assignedrole = TAIPAN_SCIENTIST
	del_types = list() // Necessary to prevent del_types from removing radio!
	allow_prefs_prompt = TRUE
	allow_species_pick = TRUE
	allow_gender_pick = TRUE
	allow_name_pick = TRUE
	pickable_species = list("Human", "Vulpkanin", "Tajaran", "Unathi", "Skrell", "Diona", "Drask", "Vox", "Plasmaman", "Machine", "Kidan", "Grey", "Nucleation", "Slime People", "Wryn", "Nian")
	faction = list("syndicate")
	min_hours = 10
	exp_type = EXP_TYPE_LIVING

/obj/effect/mob_spawn/human/space_base_syndicate/Destroy()
    var/obj/machinery/cryopod/syndie/S = new(get_turf(src))
    S.setDir(dir)
    return ..()

/datum/outfit/space_base_syndicate
	name = "Space Base Syndicate Scientist"
	r_hand = /obj/item/melee/energy/sword/saber
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/syndicate/taipan // See del_types above
	back = /obj/item/storage/backpack/syndicate/science
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	id = /obj/item/card/id/syndicate/scientist
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/space_base_syndicate/pre_equip(mob/living/carbon/human/H)
	if(H.dna.species)
		var/race = H.dna.species.name
		switch(race)
			if("Vox", "Vox Armalis")
				box = /obj/item/storage/box/survival_vox
			if("Plasmaman")
				box = /obj/item/storage/box/survival_plasmaman
			else
				box = /obj/item/storage/box/survival_syndi

/datum/outfit/space_base_syndicate/post_equip(mob/living/carbon/human/H)
	H.faction |= "syndicate"
	if(H.dna.species)

		var/race = H.dna.species.name

		switch(race)
			if("Vox", "Vox Armalis")
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(H), slot_wear_mask)
				H.equip_to_slot_or_del(new /obj/item/tank/internals/emergency_oxygen/double/vox(H), slot_l_hand)
				H.internal = H.l_hand

			if("Plasmaman")
				var/L = H.get_item_by_slot(slot_l_store)
				var/R = H.get_item_by_slot(slot_r_store)
				var/I = H.get_item_by_slot(slot_wear_id)
				qdel(H.get_item_by_slot(slot_w_uniform))
				qdel(H.get_item_by_slot(slot_head))
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(H), slot_wear_mask)
				H.equip_to_slot(new /obj/item/tank/internals/plasmaman/belt/full(H), slot_l_hand)
				H.equip_to_slot(I, slot_wear_id) // По непонятной мне причине другие методы считают что персонаж не может надеть предметы. Поэтому надеваем насильно!
				H.equip_to_slot(R, slot_r_store)
				H.equip_to_slot(L, slot_l_store)
				H.equip_to_slot_or_del(new /obj/item/clothing/under/plasmaman(H), slot_w_uniform)
				H.equip_to_slot(new /obj/item/clothing/head/helmet/space/plasmaman(H), slot_head)
				H.internal = H.l_hand

		H.update_action_buttons_icon()
		H.rejuvenate() //fix any damage taken by naked vox/plasmamen/etc

/obj/effect/mob_spawn/human/space_base_syndicate/special(mob/living/carbon/human/H)
	GLOB.human_names_list += H.real_name
	SEND_SOUND(H, 'sound/effects/taipan_start.ogg')
	GLOB.taipan_players_active += H.mind
	H.give_taipan_hud()
	return ..()

/obj/effect/mob_spawn/human/space_base_syndicate/medic
	name = "Syndicate Medic sleeper"
	mob_name = "Syndicate Medic"
	id_job = "Syndicate Medic"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Проводите медицинские опыты сомнительного содержания. Вылечивайте своих коллег, которые опять поссорились с генералом Синди, или оживляйте неудачных космических путников, для допросов или боргизации. Даже Синдикату нужны врачи!"
	flavour_text = "Вы агент синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Продолжайте свои исследования на сколько можете и постарайтесь не высовываться. \
	Вам дали ясно понять, что синдикат заставит вас очень сильно пожалеть если вы разочаруете их!"
	outfit = /datum/outfit/space_base_syndicate/medic
	assignedrole = TAIPAN_MEDIC
	min_hours = 10
	exp_type = EXP_TYPE_LIVING
/datum/outfit/space_base_syndicate/medic
	name = "Space Base Syndicate Medic"
	r_hand = /obj/item/melee/energy/sword/saber
	uniform = /obj/item/clothing/under/syndicate
	glasses = /obj/item/clothing/glasses/hud/health
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/syndicate/taipan // See del_types above
	back = /obj/item/storage/backpack/syndicate/med
	belt = /obj/item/storage/belt/medical
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	id = /obj/item/card/id/syndicate/medic
	implants = list(/obj/item/implant/weapons_auth)
	backpack_contents = list(
		/obj/item/reagent_containers/applicator/brute = 1,
		/obj/item/reagent_containers/applicator/burn = 1,
		/obj/item/reagent_containers/hypospray/safety = 1,
		/obj/item/healthanalyzer/advanced = 1,
		/obj/item/reagent_containers/glass/bottle/charcoal = 1
	)

/obj/effect/mob_spawn/human/space_base_syndicate/botanist
	name = "Syndicate Botanist sleeper"
	mob_name = "Syndicate Botanist"
	id_job = "Syndicate Botanist"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Выращивайте сомнительные растения. Помогите повару накормить экипаж, а учёным создать опаснейшие растения! Наслаждайтесь силой природы в руках Синдиката!"
	flavour_text = "Вы агент синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Продолжайте свои исследования на сколько можете и постарайтесь не высовываться. \
	Вам дали ясно понять, что синдикат заставит вас очень сильно пожалеть если вы разочаруете их!"
	outfit = /datum/outfit/space_base_syndicate/botanist
	assignedrole = TAIPAN_BOTANIST
	min_hours = 10
	exp_type = EXP_TYPE_LIVING
/datum/outfit/space_base_syndicate/botanist
	name = "Space Base Syndicate Botanist"
	r_hand = /obj/item/melee/energy/sword/saber
	uniform = /obj/item/clothing/under/syndicate
	glasses = /obj/item/clothing/glasses/hud/hydroponic
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_ear = /obj/item/radio/headset/syndicate/taipan // See del_types above
	suit = /obj/item/clothing/suit/apron
	back = /obj/item/storage/backpack/syndicate
	belt = /obj/item/storage/belt/botany
	r_pocket = /obj/item/gun/projectile/automatic/pistol
	id = /obj/item/card/id/syndicate/botanist
	implants = list(/obj/item/implant/weapons_auth)

/obj/effect/mob_spawn/human/space_base_syndicate/cargotech
	name = "Syndicate Cargo Technician sleeper"
	mob_name = "Syndicate Cargo Technician"
	id_job = "Syndicate Cargo Technician"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Даже синдикату нужны рабочие руки, приносите людям их посылки, заказывайте и продавайте, наслаждайтесь простой работой среди всех этих учёных. Здесь всё равно платят в разы лучше!"
	flavour_text = "Вы Грузчик синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Работайте с грузами, заказывайте всё что может потребоваться станции или вам и зарабатывайте реальные деньги, а не виртуальные очки!"
	outfit = /datum/outfit/space_base_syndicate/cargotech
	assignedrole = TAIPAN_CARGO
	min_hours = 10
	exp_type = EXP_TYPE_LIVING
/datum/outfit/space_base_syndicate/cargotech
	name = "Space Base Syndicate Cargo Technician"
	head = /obj/item/clothing/head/soft
	uniform = /obj/item/clothing/under/rank/cargotech
	r_ear = /obj/item/radio/headset/syndicate/taipan // See del_types above
	suit = /obj/item/clothing/suit/armor/vest
	id = /obj/item/card/id/syndicate/cargo
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/syndicate/cargo

/obj/effect/mob_spawn/human/space_base_syndicate/chef
	name = "Syndicate Chef Sleeper"
	mob_name = "Syndicate Chef"
	id_job = "Syndicate Chef"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Даже синдикату нужны рабочие руки! У вас в распоряжении свой бар, кухня и ботаника. Накормите этих голодных учёных или помогите им создать последнее блюдо для ваших врагов. Здесь всё равно платят в разы лучше!"
	flavour_text = "Вы Повар синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Готовьте еду и напитки экипажу и постарайтесь не высовываться!"
	outfit = /datum/outfit/space_base_syndicate/chef
	assignedrole = TAIPAN_CHEF
	min_hours = 10
	exp_type = EXP_TYPE_LIVING

/obj/effect/mob_spawn/human/space_base_syndicate/chef/special(mob/living/carbon/human/H)
	. = ..()
	var/datum/martial_art/cqc/under_siege/justacook = new
	justacook.teach(H)

/datum/outfit/space_base_syndicate/chef
	name = "Space Base Syndicate Chef"
	head = /obj/item/clothing/head/chefhat
	uniform = /obj/item/clothing/under/suit_jacket/charcoal
	r_ear = /obj/item/radio/headset/syndicate/taipan // See del_types above
	suit = /obj/item/clothing/suit/chef/classic
	id = /obj/item/card/id/syndicate/kitchen
	shoes = /obj/item/clothing/shoes/black
	back = /obj/item/storage/backpack/syndicate

/obj/effect/mob_spawn/human/space_base_syndicate/engineer
	name = "Syndicate Atmos Engineer Sleeper"
	mob_name = "Syndicate Atmos Engineer"
	id_job = "Syndicate Atmos Engineer"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Там где есть космическая станция, есть и двигатели с трубами которым нужно своё техобслуживание. Обеспечьте станцию энергией, чините повреждения после неудачных опытов учёных и отдыхайте в баре пока снова что-нибудь не взорвут. "
	flavour_text = "Вы Инженер атмосферник синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Запустите двигатель, убедитесь, что на станцию подаётся достаточно электричества и воздуха, а так же чините отделы которые неприменно сломают."
	outfit = /datum/outfit/space_base_syndicate/engineer
	assignedrole = TAIPAN_ENGINEER
	min_hours = 10
	exp_type = EXP_TYPE_ENGINEERING
/datum/outfit/space_base_syndicate/engineer
	name = "Space Base Syndicate Engineer"
	head = /obj/item/clothing/head/beret/eng
	r_ear = /obj/item/radio/headset/syndicate/taipan // See del_types above
	suit = /obj/item/clothing/suit/storage/hazardvest
	belt = /obj/item/storage/belt/utility/atmostech
	id = /obj/item/card/id/syndicate/engineer
	shoes = /obj/item/clothing/shoes/workboots
	back = /obj/item/storage/backpack/syndicate/engineer

/obj/effect/mob_spawn/human/space_base_syndicate/comms
	name = "Syndicate Comms Officer sleeper"
	mob_name = "Syndicate Comms Officer"
	id_job = "Syndicate Comms Officer"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Проверяйте камеры и коммуникации, руководите станцией в случае ЧП, старайтесь помогать любым агентам синдиката на станции при этом сохраняя свою базу секретом от НТ. Вы являетесь единственным агентом с доступом в хранилище и оружейную."
	flavour_text = "Вы Офицер синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Наблюдайте за станцией НТ, руководите вверенной вам базой и постарайтесь не высовываться. \
	Синдикат ясно дал вам понять, что не стоит подводить их доверие. Не разочаруйте их!"
	outfit = /datum/outfit/space_base_syndicate/comms
	assignedrole = TAIPAN_COMMS
	min_hours = 50
	exp_type = EXP_TYPE_COMMAND
/datum/outfit/space_base_syndicate/comms
	name = "Space Base Syndicate Comms Officer"
	r_ear = /obj/item/radio/headset/syndicate/taipan/tcomms_agent // See del_types above
	r_hand = /obj/item/twohanded/dualsaber
	mask = /obj/item/clothing/mask/chameleon
	suit = /obj/item/clothing/suit/armor/vest
	belt = /obj/item/gun/projectile/automatic/pistol/deagle
	back = /obj/item/storage/backpack/fluff/syndiesatchel
	id = /obj/item/card/id/syndicate/comms_officer
	backpack_contents = list(
		/obj/item/paper/monitorkey = 1, // message console does NOT spawn with this
		/obj/item/paper/syndicate/code_words = 1,
		/obj/item/ammo_box/magazine/m50 = 3
	)

/obj/effect/mob_spawn/human/space_base_syndicate/rd
	name = "Syndicate Research Director sleeper"
	mob_name = "Syndicate Research Director"
	id_job = "Syndicate Research Director"
	important_info = "Не мешайте другим оперативникам синдиката (Таким как предатели или ядерные оперативники). Вы можете работать вместе или против не связанных с синдикатом антагонистов в индивидуальном порядке. Не покидайте свою базу без разрешения администрации! Ваша база, её секретность и её сохранность является для вас высшим приоритетом!"
	description = "Следите за тем чтобы учёные занимались исследованиями и не подорвали всю станцию, предоставьте синдикату результаты своих исследований через карго и помните, смерть Нанотрейзен!"
	flavour_text = "Вы Директор Исследований синдиката, работающий на сверхсекретной научно-наблюдательной станции Тайпан, занимающейся созданием биооружия и взаимодействием с чёрным рынком. К несчастью, ваш самый главный враг, компания Нанотрэйзен, имеет собственную массивную научную базу в вашем секторе. Продолжайте свои исследования на сколько можете и постарайтесь не высовываться. \
	Вам дали ясно понять, что синдикат заставит вас очень сильно пожалеть если вы разочаруете их!"
	outfit = /datum/outfit/space_base_syndicate/rd
	assignedrole = TAIPAN_RD
	min_hours = 50
	exp_type = EXP_TYPE_SCIENCE
/datum/outfit/space_base_syndicate/rd
	name = "Space Base Syndicate Research Director"
	r_ear = /obj/item/radio/headset/syndicate/taipan // See del_types above
	r_hand = /obj/item/melee/classic_baton/telescopic
	l_pocket = /obj/item/melee/energy/sword/saber
	head = /obj/item/clothing/head/beret/sci
	suit = /obj/item/clothing/suit/storage/labcoat/fluff/aeneas_rinil
	back = /obj/item/storage/backpack/fluff/syndiesatchel
	id = /obj/item/card/id/syndicate/research_director
	backpack_contents = list(
		/obj/item/gun/energy/telegun = 1
	)

//Прок вызываемый для выдачи Тайпан Худа
/mob/living/proc/give_taipan_hud(mob/living/H = src, role = null)
	if(!H.mind)
		stack_trace("Error. \"give_taipan_hud\" called by/for a mob [H.name] with no mind! Mob location: [get_area(H)]. Proc execution aborted.")
		return
	if(!role)
		role = H.find_taipan_hud_number_by_job()
	if(role)
		var/datum/atom_hud/antag/taipanhud = GLOB.huds[TAIPAN_HUD]
		taipanhud.join_hud(H)
		H.mind.offstation_role = TRUE
		switch(role)
			if(TAIPAN_HUD_SCIENTIST)
				set_antag_hud(H.mind.current, "hudsyndie_t_sci")
			if(TAIPAN_HUD_MEDIC)
				set_antag_hud(H.mind.current, "hudsyndie_t_medic")
			if(TAIPAN_HUD_BOTANIST)
				set_antag_hud(H.mind.current, "hudsyndie_t_botanist")
			if(TAIPAN_HUD_CARGO)
				set_antag_hud(H.mind.current, "hudsyndie_t_cargo")
			if(TAIPAN_HUD_CHEF)
				set_antag_hud(H.mind.current, "hudsyndie_t_chef")
			if(TAIPAN_HUD_ENGINEER)
				set_antag_hud(H.mind.current, "hudsyndie_t_eng")
			if(TAIPAN_HUD_COMMS)
				set_antag_hud(H.mind.current, "hudsyndie_t_comms")
			if(TAIPAN_HUD_RD)
				set_antag_hud(H.mind.current, "hudsyndie_t_rd")
			if(TAIPAN_HUD_CYBORG)
				set_antag_hud(H.mind.current, "hudsyndie_t_borg")
		H.regenerate_icons()

//Прок ищущий номер роли, смотря на текст профессии
/mob/living/proc/find_taipan_hud_number_by_job(job = src.mind.assigned_role)
	var/role = null
	switch(job)
		if(TAIPAN_SCIENTIST)
			role = TAIPAN_HUD_SCIENTIST
		if(TAIPAN_MEDIC)
			role = TAIPAN_HUD_MEDIC
		if(TAIPAN_BOTANIST)
			role = TAIPAN_HUD_BOTANIST
		if(TAIPAN_CARGO)
			role = TAIPAN_HUD_CARGO
		if(TAIPAN_CHEF)
			role = TAIPAN_HUD_CHEF
		if(TAIPAN_ENGINEER)
			role = TAIPAN_HUD_ENGINEER
		if(TAIPAN_COMMS)
			role = TAIPAN_HUD_COMMS
		if(TAIPAN_RD)
			role = TAIPAN_HUD_RD
		if(CYBORG)
			role = TAIPAN_HUD_CYBORG
	return role

//Прок вызываемый криоподом, для создания нового спавнера гост роли
/obj/machinery/cryopod/proc/free_taipan_role(job = null)
	switch(job)
		if(TAIPAN_SCIENTIST)
			var/obj/effect/mob_spawn/human/space_base_syndicate/S = new(get_turf(src))
			S.setDir(dir)
			Destroy()
		if(TAIPAN_MEDIC)
			var/obj/effect/mob_spawn/human/space_base_syndicate/medic/S = new(get_turf(src))
			S.setDir(dir)
			Destroy()
		if(TAIPAN_BOTANIST)
			var/obj/effect/mob_spawn/human/space_base_syndicate/botanist/S = new(get_turf(src))
			S.setDir(dir)
			Destroy()
		if(TAIPAN_CARGO)
			var/obj/effect/mob_spawn/human/space_base_syndicate/cargotech/S = new(get_turf(src))
			S.setDir(dir)
			Destroy()
		if(TAIPAN_CHEF)
			var/obj/effect/mob_spawn/human/space_base_syndicate/chef/S = new(get_turf(src))
			S.setDir(dir)
			Destroy()
		if(TAIPAN_ENGINEER)
			var/obj/effect/mob_spawn/human/space_base_syndicate/engineer/S = new(get_turf(src))
			S.setDir(dir)
			Destroy()
		if(TAIPAN_COMMS)
			var/obj/effect/mob_spawn/human/space_base_syndicate/comms/S = new(get_turf(src))
			S.setDir(dir)
			Destroy()
		if(TAIPAN_RD)
			var/obj/effect/mob_spawn/human/space_base_syndicate/rd/S = new(get_turf(src))
			S.setDir(dir)
			Destroy()
