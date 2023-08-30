#define ASH_WALKER_SPAWN_THRESHOLD 2
//The ash walker den consumes corpses or unconscious mobs to create ash walker eggs. For more info on those, check ghost_role_spawners.dm
/obj/structure/lavaland/ash_walker
	name = "necropolis tendril nest"
	desc = "Щупальце искажённой злобы. Вокруг него обустроено гнездо, полное быстро растущих яиц…"
	icon = 'icons/mob/nest.dmi'
	icon_state = "ash_walker_nest"

	move_resist = INFINITY // just killing it tears a massive hole in the ground, let's not move it
	anchored = TRUE
	density = TRUE

	resistance_flags = FIRE_PROOF | LAVA_PROOF
	max_integrity = 200

	var/faction = list("ashwalker")
	var/meat_counter = 6

/obj/structure/lavaland/ash_walker/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/lavaland/ash_walker/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/obj/structure/lavaland/ash_walker/deconstruct(disassembled)
	new /obj/item/assembly/signaler/anomaly(get_step(loc, pick(GLOB.alldirs)))
	new	/obj/effect/collapse(loc)
	return ..()

/obj/structure/lavaland/ash_walker/process()
	consume()
	spawn_mob()

/obj/structure/lavaland/ash_walker/proc/consume()
	for(var/mob/living/H in view(src, 1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message("<span class='warning'>Шипастые усики жадно подтаскивают тело [H] и разрывают его на куски, окропляя кровью растущие яйца.</span>")
			playsound(get_turf(src),'sound/magic/demon_consume.ogg', 100, 1)
			for(var/obj/item/W in H)
				if(!H.drop_item_ground(W))
					qdel(W)
			if(ismegafauna(H))
				meat_counter += 20
			else
				meat_counter++
			H.gib()
			obj_integrity = min(obj_integrity + max_integrity*0.05,max_integrity)//restores 5% hp of tendril

/obj/structure/lavaland/ash_walker/proc/spawn_mob()
	if(meat_counter >= ASH_WALKER_SPAWN_THRESHOLD)
		//spawn a shaman if there isn't a living one, or an egg for one
		var/shaman = TRUE
		for(var/mob/living/carbon/human/lizardfinder in GLOB.mob_living_list)
			if(is_species(lizardfinder, /datum/species/unathi/ashwalker/shaman))
				shaman = FALSE //lizard found
		if(shaman)
			for(var/spawners in GLOB.mob_spawners)//if an admin spawns in a shaman egg somewhere randomly, that will prevent any eggs from spawning normally
				for(var/egg in GLOB.mob_spawners[spawners])
					if(istype(egg, /obj/effect/mob_spawn/human/ash_walker/shaman))
						shaman = FALSE
						break
		if(shaman)//is a shaman being spawned?
			new /obj/effect/mob_spawn/human/ash_walker/shaman(get_step(loc, pick(GLOB.alldirs)))
		else
			new /obj/effect/mob_spawn/human/ash_walker(get_step(loc, pick(GLOB.alldirs)))
		visible_message("<span class='danger'>Одно из яиц вырастает до огромных размеров и открепляется от щупальца. Оно готово к вылуплению!</span>")
		meat_counter -= ASH_WALKER_SPAWN_THRESHOLD

/obj/effect/mob_spawn/human/ash_walker
	name = "ash walker egg"
	desc = "Жёлтое яйцо размером с человека, порождённое каким-то непостижимым существом. Внутри проглядывает гуманоидный силуэт."
	mob_name = "an ash walker"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "large_egg"
	mob_species = /datum/species/unathi/ashwalker
	outfit = /datum/outfit/ashwalker
	mob_gender = MALE
	roundstart = FALSE
	death = FALSE
	anchored = FALSE
	move_resist = MOVE_FORCE_NORMAL
	density = FALSE
	important_info = "Не покидайте Лаваленд без разрешения администратора. Нападать на шахтёрский аванпост можно только в ответ на агрессию."
	description = "Вы — пеплоходец, дикарь из племени коренных обитателей Лаваленда. Выживайте, охотьтесь и защищайте своё гнездо. Пользуйтесь примитивными племенными технологиями. Скармливайте трупы щупальцу в гнезде, дабы оно порождало яйца новых пеплоходцев. Вам разрешено атаковать шахтёров и других чужаков."
	flavour_text = "Ваше племя поклоняется Некрополю. Пустоши для вас — священные земли, а местные чудища — их щедрые дары умелым охотникам. \
	Вы видели вдали огни… Они предвещают прибытие чужаков, желающих разорить ваши земли и даже сам Некрополь. Но для вас они — лишь очередные подношения для гнезда."
	assignedrole = "Ash Walker"
	respawn_cooldown = 10 MINUTES
	var/eggtype = "пеплоходца"

/obj/effect/mob_spawn/human/ash_walker/special(mob/living/carbon/human/new_spawn)
	new_spawn.rename_character(new_spawn.real_name, new_spawn.dna.species.get_random_name(new_spawn.gender))
	new_spawn.faction = "ashwalker"

	to_chat(new_spawn, "<b>Добывайте для гнезда трупы гуманоидов и зверей. Щупальце поглотит их, порождая яйца новых пеплоходцев. Слава Некрополю!</b>")

/obj/effect/mob_spawn/human/ash_walker/New()
	. = ..()
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Яйцо [eggtype] готово вылупиться в [A.name].", source = src, action = NOTIFY_ATTACK, flashwindow = FALSE)


//Ash walker shaman eggs: Spawns in ash walker dens in lavaland. Only one can exist at a time, they are squishier than regular ashwalkers, and have the sole purpose of keeping other ashwalkers alive.
/obj/effect/mob_spawn/human/ash_walker/shaman
	name = "ash walker shaman egg"
	desc = "Янтарное яйцо размером с человека, порождённое каким-то непостижимым существом. Внутри проглядывает гуманоидный силуэт."
	mob_name = "an ash walker shaman"
	mob_species = /datum/species/unathi/ashwalker/shaman
	outfit = /datum/outfit/ashwalker/shaman //might be OP, but the flavour is there
	description = "Вы - шаман племени пеплоходцев. Ваше племя поклоняется некрополю. Обеспечьте выживание и лечение подконтрольных вам пеплоходцев. Проводите обряды, направленные на исцеление тела и души, обеспечивайте охотников пропитанием."
	assignedrole = "Ash Walker Shaman"
	eggtype = "шамана пеплоходцев"

/datum/outfit/ashwalker
	name ="Ashwalker"
	uniform = /obj/item/clothing/under/ash_walker

/datum/outfit/ashwalker/shaman //yep, we adding uniform available only for lizards
	name = "Ashwalker Shaman"
	uniform = /obj/item/clothing/under/ash_walker_shaman
	head = /obj/item/clothing/head/shamanash
	neck = /obj/item/clothing/neck/mantle/unathi
	belt = /obj/item/storage/bag/medpouch
	gloves = /obj/item/clothing/gloves/color/black/goliath
