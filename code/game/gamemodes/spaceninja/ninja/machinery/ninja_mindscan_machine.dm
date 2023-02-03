/*
 * Машина для сканирования разума. Позмоляющее выполнить особую цель на
 * Поиск + похищение и в конце концов изучение разума жертвы
 * Изначально ниндзя не знает кто жертва, но знает примерные отделы где она работает
 * Он должен похищать людей на свой шаттл и привозить к устройству
 * Устройство их сканирует и если человек тот - цель выполнена
 * Если не тот. Цель не выполнена и мы вписываем человека в список просканированных
 * В конечном итоге либо ниндзя найдет цель, либо цель станет выполнена после сканирования n-ого кол-ва жертв
 *
 */

/obj/machinery/ninja_mindscan_machine
	anchored = TRUE
	name = "Mind-Scan Machine"
	desc = "A very complex machine with a capability of scanning the brain of it's occupant to retrieve any valuable information they possess."
	density = TRUE
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "ninja_sleeper"
	/// Нельзя чтобы такая дорогая технология была сломана игроком по фану
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | NO_MALF_EFFECT
	var/mob/living/carbon/human/occupant
	var/mob/living/carbon/human/ninja
	var/datum/objective/find_and_scan/objective
	var/on_enter_occupant_message = "Попав в устройство вы чувствуете колющую боль в своей голове и... засыпаете..."

/obj/machinery/ninja_mindscan_machine/Initialize()
	. = ..()
	update_state_icon()

/obj/machinery/ninja_mindscan_machine/Destroy()
	if(occupant)
		occupant.forceMove(get_turf(src))
	. = ..()
	occupant = null
	objective = null
	ninja = null

/obj/machinery/ninja_mindscan_machine/attack_hand(mob/user)
	if(..(user))
		return
	if(!isninja(user))
		to_chat(user, span_boldwarning("ERROR!!! UNAUTORISED USER!!!"))
		return
	if(!objective || user != ninja)
		var/temp_objective = locate(/datum/objective/find_and_scan) in user.mind.objectives
		if(!temp_objective)
			to_chat(user, span_boldwarning("Your clan does not need you to scan anyone right now."))
			return
		objective = temp_objective
		ninja = user
		to_chat(user, span_boldwarning("User: [user] registered. Ready to scan."))
	add_fingerprint(user)
	ui_interact(user)

/// Сюда вписать код ответственный за пихание оккупанта
/obj/machinery/ninja_mindscan_machine/MouseDrop_T(atom/movable/dropped as mob|obj, mob/user as mob)
// Только ниндзя умеет работать с этой машиной, но я всё равно оставлю проверки ниже во избежание других проблем.
	if(!isninja(user))
		to_chat(user, span_boldwarning("ERROR!!! UNAUTORISED USER!!!"))
		return
	if(!objective || user != ninja)
		var/temp_objective = locate(/datum/objective/find_and_scan) in user.mind.objectives
		if(!temp_objective)
			to_chat(user, span_boldwarning("Your clan does not need you to scan anyone right now."))
			return
		objective = temp_objective
		ninja = user
		to_chat(user, span_boldwarning("User: [user.real_name] registered. Ready to scan."))

	if(dropped == user) //No. Only other living. Not you
		to_chat(user, span_notice("You are not that stupid to get inside this, are you?!"))
		return
	if(dropped.loc == user) //no you can't pull things out of your ass
		//testing(span_green("[src]: Пытались поместить кого то из своего инвентаря"))
		return
	if(user.incapacitated()) //are you cuffed, dying, lying, stunned or other
		//testing(span_green("[src]: Вы связаны!"))
		return
	if(get_dist(user, src) > 1 || get_dist(user, dropped) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		//testing(span_green("[src]: Проблемы с дистанцией!"))
		return
	if(!istype(dropped, /mob/living/carbon/human))
		//testing(span_green("[src]: Пихаете не хумана!"))
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		//testing(span_green("[src]: Вы не хуман!"))
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		//testing(span_green("[src]: Маловероятный исход с доставанием с 0-ого z lvl-a!"))
		return
	if(!istype(user.loc, /turf) || !istype(dropped.loc, /turf)) // are you in a container/closet/pod/etc?
		//testing(span_green("[src]: Жертва в контейнере!"))
		return
	if(occupant)
		to_chat(user, span_boldnotice("The [src] is already occupied!"))
		return

	var/mob/living/dropped_mob = dropped
	if(!istype(dropped_mob) || dropped_mob.buckled)
		return
	if(dropped_mob.stat == DEAD)
		to_chat(user, span_notice("You can't scan dead people!"))
		return
	if(!dropped_mob.mind)
		to_chat(user, span_notice("Catatonic people are not allowed!"))
		return
	if(dropped_mob.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("[dropped_mob] will not fit into [src] because [dropped_mob.p_they()] [dropped_mob.p_have()] a slime latched onto [dropped_mob.p_their()] head."))
		return
	if(!dropped_mob.client)
		//testing(span_green("[src]: У жертвы нет клиента!"))
		return
	if(!Adjacent(dropped_mob) && !Adjacent(user))
		to_chat(user, span_boldnotice("You're not close enough to [src]."))
		return
	if(dropped_mob != user)
		visible_message("[user] starts putting [dropped_mob] into the [src].")
	if(do_after(user, 20, target = dropped_mob))
		if(!dropped_mob)
			return
		if(occupant)
			to_chat(user, span_boldnotice("\The [src] is in use."))
			return
		take_occupant(dropped_mob)
	else
		to_chat(user, span_notice("You stop putting [dropped_mob] into the [src]."))


/obj/machinery/ninja_mindscan_machine/proc/scan_occupant()
	if(!occupant)
		return
	if(occupant.stat == DEAD)
		atom_say("ERROR! Occupant is DEAD! Aborting!")
		return
	if("[occupant.mind]" in objective.scanned_occupants)
		atom_say("ERROR! Occupant was already scanned before! Aborting!")
		return
	if(!(occupant.mind.assigned_role in objective.possible_roles))
		atom_say("ERROR! Occupant's job is not on the list! Aborting!")
		return
	atom_say("Mind Scan initiated!")
	sleep(30)
	atom_say("Analyzing nerve pattern for [occupant.real_name]")
	sleep(30)
	atom_say("[rand(1, 50)]%")
	sleep(50)
	atom_say("[rand(51, 99)]%")
	sleep(30)
	atom_say("Mind Scan - Task completed!")
	objective.scanned_occupants.Add("[occupant.mind]")
	if(objective.target == occupant.mind || objective.scanned_occupants.len >= objective.scans_to_win)
		objective.completed = TRUE
		atom_say("Occupant knows valuable information! Info has been transferred to the clan! Well done [ninja]!")
	else
		atom_say("Occupant does not know the information requested by the Clan! Still some information was usefull... Search more!")

/obj/machinery/ninja_mindscan_machine/proc/take_occupant(var/mob/living/carbon/possible_occupant)
	if(occupant)
		return
	if(!possible_occupant)
		return
	possible_occupant.forceMove(src)
	to_chat(possible_occupant, span_notice("[on_enter_occupant_message]"))
	occupant = possible_occupant
	occupant.SetSleeping(60)
	update_state_icon()
	desc = "[initial(desc)] ([occupant.name])"
	if(findtext("[possible_occupant.key]","@",1,2))
		var/found_text = replacetext(possible_occupant.key, "@", "")
		for(var/mob/dead/observer/ghost in GLOB.respawnable_list) //this may not be foolproof but it seemed like a better option than 'in world'
			if(ghost.key == found_text)
				if(ghost.client && ghost.client.holder) //just in case someone has a byond name with @ at the start, which I don't think is even possible but whatever
					to_chat(ghost, "<span style='color: #800080;font-weight: bold;font-size:4;'>Warning: Your body has entered [src].</span>")
	add_fingerprint(possible_occupant)

//Вытаскивание из машины
/obj/machinery/ninja_mindscan_machine/proc/go_out()
	if(!occupant)
		return
	occupant.forceMove(get_turf(src))
	occupant = null
	update_state_icon()

/obj/machinery/ninja_mindscan_machine/force_eject_occupant(mob/target)
	go_out()

//Телепорт из машины на станцию после сканирования
/obj/machinery/ninja_mindscan_machine/proc/teleport_out()
	if(!occupant)
		return
	occupant.forceMove(pick(GLOB.ninja_teleport))
	var/teleport_loc = occupant.loc
	var/effect_dir = occupant.dir
	occupant = null
	playsound(teleport_loc, 'sound/effects/phasein.ogg', 25, TRUE)
	playsound(teleport_loc, 'sound/effects/sparks2.ogg', 50, TRUE)
	new /obj/effect/temp_visual/dir_setting/ninja/phase(teleport_loc, effect_dir)
	new /obj/item/radio/headset(teleport_loc)	//Если парня запрёт в техах, без средства связи... будет не круто, не так ли?
	to_chat(ninja, "[span_boldnotice("VOID-Shift")] occupant translocation successful")
	update_state_icon()

/obj/machinery/ninja_mindscan_machine/proc/update_state_icon()
	icon_state = occupant ? initial(icon_state) : "[initial(icon_state)]_open"

/obj/machinery/ninja_mindscan_machine/proc/get_occupant_icon()
	if(!occupant)
		return
	occupant.setDir(SOUTH)
	var/icon/I = getFlatIcon(occupant, no_anim = TRUE)
	I.Scale(96,96)
	return I

/obj/machinery/ninja_mindscan_machine/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "NinjaMindScan", name, 500, 400, master_ui, state)
		ui.open()

/obj/machinery/ninja_mindscan_machine/ui_data(mob/user)
	var/list/data = list()
	var/list/scanned_occupants_info = list()

	data["occupant_name"] = occupant ? occupant.real_name : "none"
	data["occupant_health"] = occupant ? occupant.health : "none"

	for(var/temp_occupant as anything in objective.scanned_occupants)
		scanned_occupants_info += list(list("scanned_occupant" = temp_occupant))

	data["scanned_occupants"] = scanned_occupants_info
	//Иконка похищенного
	var/icon/occupant_icon = get_occupant_icon()
	var/icon/no_occupant_icon = icon('icons/mob/ninja_previews.dmi', "ninja_preview_no_icon", SOUTH, frame = 1)
	data["occupantIcon"]= occupant ? icon2base64(occupant_icon) : icon2base64(no_occupant_icon)

	return data

/obj/machinery/ninja_mindscan_machine/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("scan_occupant")
			scan_occupant()
		if("go_out")
			go_out()
		if("teleport_out")
			teleport_out()

