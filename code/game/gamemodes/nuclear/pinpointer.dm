#define MODE_OFF 	0
#define MODE_DISK 	1
#define MODE_NUKE 	2
#define MODE_ADV 	3
#define MODE_SHIP 	4
#define MODE_OPERATIVE 5
#define MODE_CREW 	6
#define MODE_NINJA 	7
#define MODE_THIEF 	8
#define SETTING_DISK 		0
#define SETTING_LOCATION 	1
#define SETTING_OBJECT 		2

/obj/item/pinpointer
	name = "pinpointer"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinoff"
	flags = CONDUCT
	slot_flags = SLOT_PDA | SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_state = "electronic"
	throw_speed = 4
	throw_range = 20
	materials = list(MAT_METAL=500)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/obj/item/disk/nuclear/the_disk = null
	var/obj/machinery/nuclearbomb/the_bomb = null
	var/obj/machinery/nuclearbomb/syndicate/the_s_bomb = null // used by syndicate pinpointers.
	var/cur_index = 1 // Which index the current mode is
	var/mode = MODE_OFF // On which mode the pointer is at
	var/modes = list(MODE_DISK, MODE_NUKE) // Which modes are there
	var/shows_nuke_timer = TRUE
	var/syndicate = FALSE // Indicates pointer is syndicate, and points to the syndicate nuke.
	var/icon_off = "pinoff"
	var/icon_null = "pinonnull"
	var/icon_direct = "pinondirect"
	var/icon_close = "pinonclose"
	var/icon_medium = "pinonmedium"
	var/icon_far = "pinonfar"

/obj/item/pinpointer/New()
	..()
	GLOB.pinpointer_list += src

/obj/item/pinpointer/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.pinpointer_list -= src
	mode = MODE_OFF
	the_disk = null
	return ..()

/obj/item/pinpointer/process()
	if(mode == MODE_DISK)
		workdisk()
	else if(mode == MODE_NUKE)
		workbomb()

/obj/item/pinpointer/attack_self(mob/user)
	cycle(user)

/obj/item/pinpointer/proc/cycle(mob/user)
	if(cur_index > length(modes))
		mode = MODE_OFF
		to_chat(user, "<span class='notice'>Вы отключили [src.name].</span>")
		STOP_PROCESSING(SSfastprocess, src)
		icon_state = icon_off
		cur_index = 1
		return
	if(cur_index == 1)
		START_PROCESSING(SSfastprocess, src)
	mode = modes[cur_index++]
	activate_mode(mode, user)
	to_chat(user, "<span class='notice'>[get_mode_text(mode)]</span>")

/obj/item/pinpointer/proc/get_mode_text(mode)
	switch(mode)
		if(MODE_DISK)
			return "Authentication Disk Locator active."
		if(MODE_NUKE)
			return "Nuclear Device Locator active."
		if(MODE_ADV)
			return "Advanced Pinpointer Online."
		if(MODE_SHIP)
			return "Shuttle Locator active."
		if(MODE_OPERATIVE)
			return "You point the pinpointer to the nearest operative."
		if(MODE_CREW)
			return "You turn on the pinpointer."
		if(MODE_THIEF)
			return "Вы включили спец-пинпоинтер."


/obj/item/pinpointer/proc/activate_mode(mode, mob/user) //for crew pinpointer
	return

/obj/item/pinpointer/proc/scandisk()
	if(!the_disk)
		the_disk = locate()

/obj/item/pinpointer/proc/scanbomb()
	if(!syndicate)
		if(!the_bomb)
			the_bomb = locate()
	else
		if(!the_s_bomb)
			the_s_bomb = locate()

/obj/item/pinpointer/proc/point_at(atom/target)
	if(!target)
		icon_state = icon_null
		return

	var/turf/T = get_turf(target)
	var/turf/L = get_turf(src)

	if(!(T && L) || (T.z != L.z))
		icon_state = icon_null
	else
		dir = get_dir(L, T)
		switch(get_dist(L, T))
			if(-1)
				icon_state = icon_direct
			if(1 to 8)
				icon_state = icon_close
			if(9 to 16)
				icon_state = icon_medium
			if(16 to INFINITY)
				icon_state = icon_far

/obj/item/pinpointer/proc/workdisk()
	scandisk()
	point_at(the_disk)

/obj/item/pinpointer/proc/workbomb()
	if(!syndicate)
		scanbomb()
		point_at(the_bomb)
	else
		scanbomb()
		point_at(the_s_bomb)

/obj/item/pinpointer/examine(mob/user)
	. = ..()
	if(shows_nuke_timer)
		for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
			if(bomb.timing)
				. += "<span class='warning'>Extreme danger. Arming signal detected. Time remaining: [bomb.timeleft]</span>"

/obj/item/pinpointer/advpinpointer
	name = "advanced pinpointer"
	desc = "A larger version of the normal pinpointer, this unit features a helpful quantum entanglement detection system to locate various objects that do not broadcast a locator signal."
	modes = list(MODE_ADV)
	var/modelocked = FALSE // If true, user cannot change mode.
	var/turf/location = null
	var/obj/target = null
	var/setting = 0

/obj/item/pinpointer/advpinpointer/process()
	switch(setting)
		if(SETTING_DISK)
			workdisk()
		if(SETTING_LOCATION)
			point_at(location)
		if(SETTING_OBJECT)
			point_at(target)

/obj/item/pinpointer/advpinpointer/workdisk() //since mode works diffrently for advpinpointer
	scandisk()
	point_at(the_disk)

/obj/item/pinpointer/advpinpointer/AltClick(mob/user)
	. = ..()
	toggle_mode(user)

/obj/item/pinpointer/advpinpointer/verb/toggle_mode(mob/user)
	set category = "Object"
	set name = "Toggle Pinpointer Mode"
	set src in usr

	if(user.stat || user.restrained())
		return

	if(modelocked)
		to_chat(user, "<span class='warning'>[src] is locked. It can only track one specific target.</span>")
		return

	mode = MODE_OFF
	icon_state = icon_off
	target = null
	location = null

	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Location", "Disk Recovery", "Other Signature"))
		if("Location")
			setting = SETTING_LOCATION

			var/locationx = input(user, "Введите X координату для поиска.", "Локация?" , "") as num
			if(!locationx || !(user in view(1,src)))
				return
			var/locationy = input(user, "Введите Y координату для поиска.", "Локация?" , "") as num
			if(!locationy || !(user in view(1,src)))
				return

			var/turf/Z = get_turf(src)

			location = locate(locationx,locationy,Z.z)

			to_chat(user, "<span class='notice'>Вы переключили пинпоинтер для обнаружения [locationx],[locationy]</span>")


			return attack_self()

		if("Disk Recovery")
			setting = SETTING_DISK
			return attack_self()

		if("Other Signature")
			setting = SETTING_OBJECT
			switch(alert("Search for item signature or DNA fragment?" , "Signature Mode Select" , "Item" , "DNA"))
				if("Item")
					var/list/item_names[0]
					var/list/item_paths[0]
					for(var/objective in GLOB.potential_theft_objectives)
						var/datum/theft_objective/T = objective
						var/name = initial(T.name)
						item_names += name
						item_paths[name] = initial(T.typepath)
					var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in item_names
					if(!targetitem)
						return

					var/list/target_candidates = get_all_of_type(item_paths[targetitem], subtypes = TRUE)
					for(var/obj/item/candidate in target_candidates)
						if(!is_admin_level((get_turf(candidate)).z))
							target = candidate
							break

					if(!target)
						to_chat(user, "<span class='warning'>Failed to locate [targetitem]!</span>")
						return
					to_chat(user, "<span class='notice'>Вы переключили пинпоинтер для обнаружения [targetitem].</span>")
				if("DNA")
					var/DNAstring = input("Input DNA string to search for." , "Please Enter String." , "")
					if(!DNAstring)
						return
					for(var/mob/living/carbon/C in GLOB.mob_list)
						if(!C.dna)
							continue
						if(C.dna.unique_enzymes == DNAstring)
							target = C
							break

			return attack_self()

///////////////////////
//nuke op pinpointers//
///////////////////////
/obj/item/pinpointer/nukeop
	var/obj/docking_port/mobile/home = null
	slot_flags = SLOT_BELT | SLOT_PDA
	syndicate = TRUE
	modes = list(MODE_DISK, MODE_NUKE)

/obj/item/pinpointer/nukeop/process()
	switch(mode)
		if(MODE_DISK)
			workdisk()
		if(MODE_NUKE)
			workbomb()
		if(MODE_SHIP)
			worklocation()

/obj/item/pinpointer/nukeop/workdisk()
	if(GLOB.bomb_set)	//If the bomb is set, lead to the shuttle
		mode = MODE_SHIP	//Ensures worklocation() continues to work
		modes = list(MODE_SHIP)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator mode actived.")			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	scandisk()
	point_at(the_disk)

/obj/item/pinpointer/nukeop/workbomb()
	if(GLOB.bomb_set)	//If the bomb is set, lead to the shuttle
		mode = MODE_SHIP	//Ensures worklocation() continues to work
		modes = list(MODE_SHIP)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)	//Plays a beep
		visible_message("Shuttle Locator mode actived.")			//Lets the mob holding it know that the mode has changed
		return		//Get outta here
	scanbomb()
	point_at(the_s_bomb)

/obj/item/pinpointer/nukeop/proc/worklocation()
	if(!GLOB.bomb_set)
		mode = MODE_DISK
		modes = list(MODE_DISK, MODE_NUKE)
		playsound(loc, 'sound/machines/twobeep.ogg', 50, 1)
		visible_message("<span class='notice'>Authentication Disk Locator mode actived.</span>")
		return
	if(!home)
		home = SSshuttle.getShuttle("syndicate")
		if(!home)
			icon_state = icon_null
			return
	if(loc.z != home.z)	//If you are on a different z-level from the shuttle
		icon_state = icon_null
	else
		point_at(home)

/obj/item/pinpointer/operative
	name = "operative pinpointer"
	desc = "A pinpointer that leads to the first Syndicate operative detected."
	icon_state = "pinoff_contractor"
	icon_off = "pinoff_contractor"
	icon_null = "pinonnull_contractor"
	icon_direct = "pinondirect_contractor"
	icon_close = "pinonclose_contractor"
	icon_medium = "pinonmedium_contractor"
	icon_far = "pinonfar_contractor"
	var/mob/living/carbon/nearest_op = null
	modes = list(MODE_OPERATIVE)

/obj/item/pinpointer/operative/process()
	if(mode == MODE_OPERATIVE)
		workop()
	else
		icon_state = icon_off

/obj/item/pinpointer/operative/proc/scan_for_ops()
	if(mode == MODE_OPERATIVE)
		nearest_op = null //Resets nearest_op every time it scans
		var/closest_distance = 1000
		for(var/mob/living/carbon/M in GLOB.mob_list)
			if(M.mind && (M.mind in SSticker.mode.syndicates))
				if(get_dist(M, get_turf(src)) < closest_distance) //Actually points toward the nearest op, instead of a random one like it used to
					nearest_op = M

/obj/item/pinpointer/operative/proc/workop()
	if(mode == MODE_OPERATIVE)
		scan_for_ops()
		point_at(nearest_op, FALSE)
	else
		return FALSE

/obj/item/pinpointer/operative/examine(mob/user)
	. = ..()
	if(mode == MODE_OPERATIVE)
		if(nearest_op)
			. += "<span class='notice'>Nearest operative detected is <i>[nearest_op.real_name].</i></span>"
		else
			. += "<span class='notice'>No operatives detected within scanning range.</span>"

/obj/item/pinpointer/ninja
	name = "spider clan pinpointer"
	desc = "A pinpointer that leads to the first Spider Clan assassin detected."
	var/mob/living/carbon/nearest_ninja = null
	modes = list(MODE_NINJA)

/obj/item/pinpointer/ninja/process()
	if(mode == MODE_NINJA)
		workninja()
	else
		icon_state = icon_off

/obj/item/pinpointer/ninja/proc/scan_for_ninja()
	if(mode == MODE_NINJA)
		nearest_ninja = null //Resets nearest_ninja every time it scans
		var/closest_distance = 1000
		for(var/mob/living/carbon/potential_ninja in GLOB.mob_list)
			if(isninja(potential_ninja))
				if(get_dist(potential_ninja, get_turf(src)) < closest_distance)
					nearest_ninja = potential_ninja

/obj/item/pinpointer/ninja/proc/workninja()
	scan_for_ninja()
	point_at(nearest_ninja, FALSE)

/obj/item/pinpointer/ninja/examine(mob/user)
	. = ..()
	if(mode == MODE_NINJA)
		if(nearest_ninja)
			. += "Nearest ninja detected is <i>[nearest_ninja.real_name].</i>"
		else
			. += "No ninjas detected within scanning range."

/obj/item/pinpointer/crew
	name = "crew pinpointer"
	desc = "A handheld tracking device that points to crew suit sensors."
	shows_nuke_timer = FALSE
	icon_state = "pinoff_crew"
	icon_off = "pinoff_crew"
	icon_null = "pinonnull_crew"
	icon_direct = "pinondirect_crew"
	icon_close = "pinonclose_crew"
	icon_medium = "pinonmedium_crew"
	icon_far = "pinonfar_crew"
	modes = list(MODE_CREW)
	var/target = null //for targeting in processing
	var/target_set = FALSE //have we set a target at any point?

/obj/item/pinpointer/crew/proc/trackable(mob/living/carbon/human/H)
	if(H && istype(H.w_uniform, /obj/item/clothing/under))
		var/turf/here = get_turf(src)
		var/obj/item/clothing/under/U = H.w_uniform
		// Suit sensors must be on maximum.
		if(!U.has_sensor || U.sensor_mode < 3)
			return FALSE
		var/turf/there = get_turf(U)
		return istype(there) && there.z == here.z
	return FALSE

/obj/item/pinpointer/crew/process()
	if(mode == MODE_CREW && target_set)
		point_at(target)

/obj/item/pinpointer/crew/point_at(atom/target)
	if(!target || !trackable(target))
		icon_state = icon_null
		return

	..(target)

/obj/item/pinpointer/crew/activate_mode(mode, mob/user)
	var/list/name_counts = list()
	var/list/names = list()

	for(var/thing in GLOB.human_list)
		var/mob/living/carbon/human/H = thing
		if(!trackable(H))
			continue

		var/name = "Unknown"
		if(H.wear_id)
			var/obj/item/card/id/I = H.wear_id.GetID()
			if(I)
				name = I.registered_name

		while(name in name_counts)
			name_counts[name]++
			name = text("[] ([])", name, name_counts[name])
		names[name] = H
		name_counts[name] = 1

	if(!names.len)
		user.visible_message("<span class='notice'>[user]'s pinpointer fails to detect a signal.</span>", "<span class='notice'>Your pinpointer fails to detect a signal.</span>")
		return

	var/A = input(user, "Person to track", "Pinpoint") in names
	if(!src || !user || (user.get_active_hand() != src) || user.incapacitated() || !A)
		return

	target = names[A]
	target_set = TRUE
	user.visible_message("<span class='notice'>[user] activates [user.p_their()] pinpointer.</span>", "<span class='notice'>You activate your pinpointer.</span>")

/obj/item/pinpointer/crew/centcom
	name = "centcom pinpointer"
	desc = "A handheld tracking device that tracks crew based on remote centcom sensors."

/obj/item/pinpointer/crew/centcom/trackable(mob/living/carbon/human/H)
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(H)
	return istype(there) && istype(here) && there.z == here.z


///////////////////////
///thief pinpointers///
///////////////////////
/obj/item/pinpointer/thief
	name = "pinpointer"
	desc = "Модифицированный пинпоинтер #REDACTED# предназначенный для нахождения всех ценных и интересных для #REDACTED# сигнатур, не передающий сигналы локаторами. На обратной стороне напечатан странный непонятный детский ребус."
	modes = list(MODE_THIEF)
	shows_nuke_timer = FALSE
	icon_state = "pinoff_crew"
	icon_off = "pinoff_crew"
	icon_null = "pinonnull_crew"
	icon_direct = "pinondirect_crew"
	icon_close = "pinonclose_crew"
	icon_medium = "pinonmedium_crew"
	icon_far = "pinonfar_crew"
	var/turf/location = null
	var/obj/target = null
	var/setting = 0
	var/datum/objective/steal_pet/datum_steal_pet = new
	var/datum/objective/steal_structure/datum_steal_structure = new

/obj/item/pinpointer/thief/process()
	switch(setting)
		if(SETTING_LOCATION)
			point_at(location)
		if(SETTING_OBJECT)
			point_at(target)

/obj/item/pinpointer/thief/cycle(mob/user)
	. = ..()
	switch(setting)
		if(SETTING_LOCATION)
			if(!location)
				to_chat(user, "<span class='notice'>Определите координаты локации у пинпоинтера.</span>")
		if(SETTING_OBJECT)
			if(!target)
				to_chat(user, "<span class='notice'>Определите цель пинпоинтера.</span>")
		else
			to_chat(user, "<span class='warning'>Режим пинпоинтера не определен.</span>")

/obj/item/pinpointer/thief/AltClick(mob/user)
	. = ..()
	toggle_mode(user)

/obj/item/pinpointer/thief/verb/toggle_mode(mob/user)
	set category = "Object"
	set name = "Переключить Режим Пинпоинтера"
	set src in usr

	if(user.stat || user.restrained())
		return

	mode = MODE_OFF
	icon_state = icon_off
	target = null
	location = null

	switch(alert("Выберите режим пинпоинтера.", "Выбор режима пинпоинтера", "Локация", "Сигнатура Объекта", "Цели"))
		if("Локация")
			setting = SETTING_LOCATION

			var/locationx = input(user, "Введите X координату для поиска.", "Локация?" , "") as num
			if(!locationx || !(user in view(1,src)))
				return
			var/locationy = input(user, "Введите Y координату для поиска.", "Локация?" , "") as num
			if(!locationy || !(user in view(1,src)))
				return
			var/turf/Z = get_turf(src)
			location = locate(locationx,locationy,Z.z)

			to_chat(user, "<span class='notice'>Вы переключили пинпоинтер для обнаружения [locationx],[locationy]</span>")
			return attack_self()

		if("Сигнатура Объекта")
			setting = SETTING_OBJECT
			var/list/targets_list = list()
			var/list/target_names[0]
			var/list/target_paths[0]
			var/input_ask = "Выберите сигнатуру"
			var/input_tittle = "Режим выбора"

			//var/datum/objective/steal_structure/objective = locate() in owner.objectives
			//if(!objective)

			var/input_type
			input_type = alert("Какие типы сигнатуры объектов необходимо найти?" , "Выбор Сигнатуры Объектов" , "Предмет" , "Структура" , "Питомец")
			if(!input_type)
				return

			var/input_subtype
			switch(input_type)
				if("Предмет")
					input_subtype = alert("Какой тип доступности предмета?" , "Определение Доступности Предмета" , "Сложнодоступен" , "Доступен" , "Коллекционный")
					switch(input_subtype)
						if("Сложнодоступен")
							var/list/datum_list = GLOB.potential_theft_objectives_hard + GLOB.potential_theft_objectives
							for(var/element in datum_list)
								var/datum/theft_objective/D = element
								targets_list.Add(initial(D.typepath))
						if("Доступен")
							var/list/datum_list = GLOB.potential_theft_objectives_medium
							for(var/element in datum_list)
								var/datum/theft_objective/D = element
								targets_list.Add(initial(D.typepath))
						if("Коллекционный")
							var/list/datum_list = GLOB.potential_theft_objectives_collect
							for(var/element in datum_list)
								var/datum/theft_objective/collect/D = element
								var/typepath_datum = initial(D.typepath)
								if(typepath_datum)
									targets_list.Add(typepath_datum)
									continue
								var/subtype_datum = initial(D.subtype)
								var/list/type_list = subtype_datum ? subtypesof(subtype_datum) : initial(D.type_list)
								targets_list += type_list
					if(!input_subtype)
						return
					input_subtype = " ([input_subtype])"
					if(!length(targets_list))
						return
				if("Структура")
					targets_list = datum_steal_structure.possible_targets_list
				if("Питомец")
					targets_list = datum_steal_pet.possible_targets_list

			for(var/T in targets_list)
				var/obj/temp_target = T
				var/name = initial(temp_target.name)
				target_names += name
				target_paths[name] = temp_target

			var/choosen_target = input("[input_ask], типа \"[input_type][input_subtype]\"", "[input_tittle]: [input_type][input_subtype]","") as null|anything in target_names
			if(!choosen_target)
				return

			var/list/target_candidates = get_all_of_type(target_paths[choosen_target], subtypes = TRUE)

			for(var/T in target_candidates)
				var/obj/candidate = T
				if(!is_admin_level((get_turf(candidate)).z))
					target = candidate
					break

			if(!target)
				to_chat(user, "<span class='warning'>Не удалось обнаружить [choosen_target]!</span>")
				return
			to_chat(user, "<span class='notice'>Вы переключили пинпоинтер для обнаружения [choosen_target].</span>")
			return attack_self()

		if("Цели")
			setting = SETTING_OBJECT
			if(length(user.mind.objectives) && (user.mind in SSticker.mode.thieves))
				var/list/targets_list = list()
				var/list/target_names[0]
				var/list/target_paths[0]

				for(var/datum/objective/objective in user.mind.objectives)

					if(istype(objective, /datum/objective/steal))
						var/datum/objective/steal/temp_objective = objective
						var/obj/item/wanted_type = temp_objective.steal_target.typepath
						if(!(wanted_type in targets_list))
							targets_list.Add(wanted_type)

					if(istype(objective, /datum/objective/steal_structure))
						var/datum/objective/steal_structure/temp_objective = objective
						var/obj/wanted_type = temp_objective.wanted_type
						if(!(wanted_type in targets_list))
							targets_list.Add(wanted_type)

					if(istype(objective, /datum/objective/steal_pet))
						var/datum/objective/steal_pet/temp_objective = objective
						var/mob/wanted_type = temp_objective.wanted_type
						if(!(wanted_type in targets_list))
							targets_list.Add(wanted_type)

					if(istype(objective, /datum/objective/collect))
						var/datum/objective/collect/temp_objective = objective
						var/list/wanted_type_list = temp_objective.collect_objective.type_list
						for(var/W in wanted_type_list)
							var/obj/item/wanted_type = W
							if(!(wanted_type in targets_list))
								targets_list.Add(wanted_type)

						var/list/datum_list = GLOB.potential_theft_objectives_collect
						for(var/datum/theft_objective/collect/D in datum_list)
							var/typepath_datum = initial(D.typepath)
							if(typepath_datum)
								targets_list.Add(typepath_datum)
								continue
							var/subtype_datum = initial(D.subtype)
							var/list/type_list = subtype_datum ? subtypesof(subtype_datum) : initial(D.type_list)
							targets_list += type_list

				for(var/T in targets_list)
					var/obj/temp_target = T
					var/name = initial(temp_target.name)
					target_names += name
					target_paths[name] = temp_target

				var/choosen_target = input("Выберите интересующую вас цель:", "Режим Выбора Цели","") as null|anything in target_names
				if(!choosen_target)
					return

				var/list/target_candidates = get_all_of_type(target_paths[choosen_target], subtypes = TRUE)
				for(var/T in target_candidates)
					var/obj/candidate = T
					if(!is_admin_level((get_turf(candidate)).z))
						target = candidate
						break

				to_chat(user, "<span class='notice'>Вы переключили пинпоинтер для обнаружения интересных целей для Гильдии Воров.</span>")
			else
				to_chat(user, "<span class='warning'>Не удалось обнаружить интересные цели для #REDACTED#! Если вы не член #REDACTED#, верните устройство владельцу или обратитесь по зашифрованному номеру на обратной стороне пинпоинтера.</span>")

			return attack_self()

#undef MODE_OFF
#undef MODE_DISK
#undef MODE_NUKE
#undef MODE_ADV
#undef MODE_SHIP
#undef MODE_OPERATIVE
#undef MODE_CREW
#undef MODE_NINJA
#undef MODE_THIEF
#undef SETTING_DISK
#undef SETTING_LOCATION
#undef SETTING_OBJECT
