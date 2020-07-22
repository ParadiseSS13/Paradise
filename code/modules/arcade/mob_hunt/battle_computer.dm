
/obj/machinery/computer/mob_battle_terminal
	name = "Nano-Mob Hunter GO! Battle Terminal"
	desc = "Insert a mob card to partake in life-like Nano-Mob Battle Action!"
	icon_state = "mob_battle_empty"
	icon_screen = null
	icon_keyboard = null
	density = 0
	anchored = 1
	var/obj/item/nanomob_card/card
	var/datum/mob_hunt/mob_info
	var/obj/effect/landmark/battle_mob_point/avatar_point
	var/obj/effect/nanomob/battle/avatar
	var/ready = 0
	var/team = "Grey"

/obj/machinery/computer/mob_battle_terminal/red
	pixel_y = 24
	dir = SOUTH
	team = "Red"

/obj/machinery/computer/mob_battle_terminal/blue
	pixel_y = -24
	dir = NORTH
	team = "Blue"

/obj/machinery/computer/mob_battle_terminal/red/Initialize()
	..()
	check_connection()

/obj/machinery/computer/mob_battle_terminal/blue/Initialize()
	..()
	check_connection()

/obj/machinery/computer/mob_battle_terminal/update_icon()
	if(card)
		icon_state = "mob_battle_loaded"
	else
		icon_state = "mob_battle_empty"
	..()

/obj/machinery/computer/mob_battle_terminal/Destroy()
	eject_card(1)
	if(SSmob_hunt)
		if(SSmob_hunt.battle_turn)
			SSmob_hunt.battle_turn = null
		if(SSmob_hunt.red_terminal == src)
			SSmob_hunt.red_terminal = null
		if(SSmob_hunt.blue_terminal == src)
			SSmob_hunt.blue_terminal = null
	QDEL_NULL(avatar)
	return ..()

/obj/machinery/computer/mob_battle_terminal/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/nanomob_card))
		insert_card(O, user)
		return
	return ..()

/obj/machinery/computer/mob_battle_terminal/proc/insert_card(obj/item/nanomob_card/new_card, mob/user)
	if(!new_card)
		return
	if(card)
		to_chat(user, "<span class='warning'>The card slot is currently filled.</span>")
		return
	if(!new_card.mob_data)
		to_chat(user, "<span class='danger'>This is a blank mob card.</span>")
		return
	if(new_card.mob_data && !new_card.mob_data.cur_health)
		to_chat(user, "<span class='warning'>This mob is incapacitated! Heal it before attempting to use it in battle!</span>")
		return
	user.unEquip(new_card)
	new_card.forceMove(src)
	card = new_card
	mob_info = card.mob_data
	update_icon()
	update_avatar()
	updateUsrDialog()

/obj/machinery/computer/mob_battle_terminal/proc/eject_card(override = 0)
	if(!override)
		if(ready && SSmob_hunt.battle_turn != team)
			audible_message("You can't recall on your rival's turn!", null, 2)
			return
	card.mob_data = mob_info
	mob_info = null
	card.forceMove(get_turf(src))
	card = null
	update_avatar()
	update_icon()
	updateUsrDialog()

/obj/machinery/computer/mob_battle_terminal/proc/update_avatar()
	//if we don't have avatars yet, spawn them
	if(!avatar)
		if(!avatar_point)
			log_debug("[src] attempted to spawn a battle mob avatar without a spawn point!")
			return
		else
			avatar = new(get_turf(avatar_point))
	//update avatar info from card
	if(mob_info)
		avatar.mob_info = mob_info
	else
		avatar.mob_info = null
	//tell the avatar to update themself with the new info
	avatar.update_self()

/obj/machinery/computer/mob_battle_terminal/attack_hand(mob/user)
	add_fingerprint(user)
	interact(user)

/obj/machinery/computer/mob_battle_terminal/attack_ai(mob/user)
	to_chat(user, "<span class='warning'>You cannot interface with this portion of the simulation.</span>")
	return

/obj/machinery/computer/mob_battle_terminal/interact(mob/user)
	check_connection()
	var/dat = ""
	dat += "<table border='1' style='width:75%'>"
	dat += "<tr>"
	dat += "<td>"
	dat += "[team] PLAYER"
	dat += "</td>"
	dat += "</tr>"
	dat += "<tr>"
	dat += "<td>"
	if(!card)
		dat += "<h1>No Nano-Mob card loaded.</h1>"
		dat += "</td>"
		dat += "</tr>"
		if(ready && SSmob_hunt.battle_turn)	//offer the surrender option if they are in a battle (ready), but don't have a card loaded
			dat += "<tr>"
			dat += "<td><a href='?src=[UID()];surrender=1'>Surrender!</a></td>"
			dat += "</tr>"
	else
		dat += "<table>"
		dat += "<tr>"
		dat += "<td>"
		dat += "<h1>[mob_info.mob_name]</h1>"
		dat += "</td>"
		if(mob_info.nickname)
			dat += "<td rowspan='2'>"
		else
			dat += "<td>"
		var/img_src = "[mob_info.icon_state_normal].png"
		if(mob_info.is_shiny)
			dat += "[mob_info.icon_state_shiny].png"
		dat += "<img src='[img_src]'>"
		dat += "</td>"
		dat += "</tr>"
		if(mob_info.nickname)
			dat += "<tr>"
			dat += "<td>"
			dat += "<h2>[mob_info.nickname]</h2>"
			dat += "</td>"
			dat += "</tr>"
		dat += "</table>"
		dat += "<hr>"
		dat += "Health: [mob_info.cur_health] / [mob_info.max_health]<br>"
		dat += "<table border='1'>"
		dat += "<tr>"
		if(mob_info.cur_health)
			dat += "<td><a href='?src=[UID()];attack=1'>Attack!</a></td>"
		else
			dat += "<td>Incapacitated!</td>"
		dat += "<td><a href='?src=[UID()];eject=1'>Recall!</a></td>"
		dat += "</tr>"
		dat += "</table>"
		dat += "</td>"
		dat += "</tr>"
		if(!ready)
			dat += "<tr>"
			dat += "<td><a href='?src=[UID()];ready=1'>Battle!</a></td>"
			dat += "</tr>"
		if(ready && !SSmob_hunt.battle_turn)
			dat += "<tr>"
			dat += "<td><a href='?src=[UID()];ready=2'>Cancel Battle!</a></td>"
			dat += "</tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "mob_battle_terminal", "Nano-Mob Hunter GO! Battle Terminal", 575, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/mob_battle_terminal/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["attack"])
		do_attack()

	if(href_list["eject"])
		eject_card()

	if(href_list["surrender"])
		surrender()

	if(href_list["ready"])
		var/option = text2num(href_list["ready"])
		if(option == 1)
			start_battle()
		else if(option == 2)
			ready = 0
			audible_message("[team] Player cancels their battle challenge.", null, 5)

	updateUsrDialog()

/obj/machinery/computer/mob_battle_terminal/proc/check_connection()
	if(team == "Red")
		if(SSmob_hunt && !SSmob_hunt.red_terminal)
			SSmob_hunt.red_terminal = src
	else if(team == "Blue")
		if(SSmob_hunt && !SSmob_hunt.blue_terminal)
			SSmob_hunt.blue_terminal = src

	find_avatar_spawn_point()

/obj/machinery/computer/mob_battle_terminal/proc/find_avatar_spawn_point()
	if(avatar_point)
		return
	var/obj/effect/landmark/battle_mob_point/closest
	for(var/obj/effect/landmark/battle_mob_point/bmp in GLOB.landmarks_list)
		if(!istype(bmp, /obj/effect/landmark/battle_mob_point))
			continue
		if(bmp.z != z)	//only match with points on the same z-level)
			continue
		if(!closest || isnull(closest))
			closest = bmp
			continue
		if(closest == bmp)
			continue
		if((abs(x-bmp.x)+abs(y-bmp.y)) < (abs(x-closest.x)+abs(y-closest.y)))	//get_dist would be preferable if it didn't count diagonals as 1 distance, so we have to rely on actual x/y distances in this janky way.
			closest = bmp
	if(closest)
		avatar_point = closest
	else
		log_debug("[src] was unable to locate a nearby mob battle landmark! Unable to spawn battle avatars!")

/obj/machinery/computer/mob_battle_terminal/proc/do_attack()
	if(!ready)		//no attacking if you arent ready to fight (duh)
		return
	if(!SSmob_hunt || team != SSmob_hunt.battle_turn)		//don't attack unless it is actually our turn
		return
	else
		var/message = "[mob_info.mob_name] attacks!"
		if(mob_info.nickname)
			message = "[mob_info.nickname] attacks!"
		audible_message(message, null, 5)
		SSmob_hunt.launch_attack(team, mob_info.get_raw_damage(), mob_info.get_attack_type())

/obj/machinery/computer/mob_battle_terminal/proc/start_battle()
	if(ready)	//don't do anything if we are still ready
		return
	if(!card)	//don't do anything if there isn't a card inserted
		return
	ready = 1
	audible_message("[team] Player is ready for battle! Waiting for rival...", null, 5)
	SSmob_hunt.start_check()

/obj/machinery/computer/mob_battle_terminal/proc/receive_attack(raw_damage, datum/mob_type/attack_type)
	var/message = mob_info.take_damage(raw_damage, attack_type)
	avatar.audible_message(message, null, 5)
	if(!mob_info.cur_health)
		SSmob_hunt.end_battle(team)
		eject_card(1)	//force the card out, they were defeated
	else
		SSmob_hunt.end_turn()

/obj/machinery/computer/mob_battle_terminal/proc/surrender()
	audible_message("[team] Player surrenders the battle!", null, 5)
	SSmob_hunt.end_battle(team, 1)

//////////////////////////////
//	Mob Healing Terminal	//
//		(Pokemon Center)	//
//////////////////////////////

/obj/machinery/computer/mob_healer_terminal
	name = "Nano-Mob Hunter GO! Restoration Terminal"
	desc = "Swipe a mob card to instantly restore it to full health!"
	icon_state = "mob_battle_loaded"
	icon_screen = null
	icon_keyboard = null
	density = 0
	anchored = 1
	dir = EAST

/obj/machinery/computer/mob_healer_terminal/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/nanomob_card))
		heal_card(O, user)
		return
	return ..()

/obj/machinery/computer/mob_healer_terminal/proc/heal_card(obj/item/nanomob_card/patient, mob/user)
	if(!patient)
		return
	if(!patient.mob_data)
		to_chat(user, "<span class='danger'>This is a blank mob card.</span>")
		return
	if(patient.mob_data && patient.mob_data.cur_health == patient.mob_data.max_health)
		to_chat(user, "<span class='warning'>This mob is already at maximum health!</span>")
		return
	patient.mob_data.cur_health = patient.mob_data.max_health
	to_chat(user, "<span class='notify'>[patient.mob_data.nickname ? patient.mob_data.nickname : patient.mob_data.mob_name] has been restored to full health!</span>")