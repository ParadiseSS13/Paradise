#define PAY_INTERVAL 6000	// amount of ticks between payment

/area/awaymission/spacehotel
	name = "Deep Space Hotel 419"
	requires_power = 0

/area/awaymission/spacehotel/kitchen
	name = "Hotel Kitchen"
	icon_state = "kitchen"

/area/awaymission/spacehotel/reception
	name = "Hotel Reception"
	icon_state = "entry"

// "Directional" map template loader for N or S hotel room
/obj/effect/landmark/map_loader/hotel_room
	icon = 'icons/testing/turf_analysis.dmi'
	icon_state = "arrow"

/obj/item/paper/crumpled/hotel_scrap_1
	name = "paper scrap"
	info = "I can't believe this shitty hotel assigned me a purple-themed room. <i>Why does the shower dump grape drink everywhere??</i>"

/obj/item/paper/hotel_scrap_2
	name = "Journal Entry #2"
	info = "<h3>Day 7:</h3>Today, I stepped into my bathroom, only to discover that it had become a mountainside wilderness. I tried to wash my hands with snow, but it didn't particularly pan out.<br>I contacting the front desk regarding the issue, but the receptionist just stared at me with dead eyes and spouted unrepeatable curses at me. However, I convinced them to reassign me to an upgraded suite."

/obj/item/paper/hotel_scrap_3
	name = "Journal Entry #3"
	info = "<h3>Day 26:</h3>Well, that sucked royally. The queen-sized bed was nice, but the hottub in my room was, well, my wife described it as \"a portal to hell\". I don't know, I guess the lava and weird blood gave it that impression, but it was pretty nicely warm.<br>However, <i>\"we\"</i> decided to get assigned to a new room. Whatever."

/obj/item/paper/hotel_scrap_4
	name = "Diary Page"
	info = "<b>Day 7 of Bad Vacation</b><br>Thanks Qzxor this shit vacation is ending today. The novelty of the trashy pool wore off 2 days in and I'm not allowed in the bar. The tiny box they called a room that, we had to cram into, just had a poster and a couple of beds. Only one bedsheet to spare. Shower had brown water and sink just dumped its water back out the ceiling, somehow.<br><br>PS: The receptionist isn't paying attention to us when we try to check out. Apparently, we're staying another day."

/obj/item/paper/hotel_scrap_5
	name = "Journal Entry #5"
	info = "<h3>Day 185:</h3>I feel like the restaurant's chef is just making random dishes to mess with me. I request something from the menu, and he throws out something nobody asked for on the counter. The bartender isn't much better. At least both of them can make some nice food and drinks. I would complain to the management... but they never seem to care."

/obj/item/paper/crumpled/hotel_scrap_6
	name = "Journal Entry #6"
	info = "<h3>Day 386:</h3><span style='font-family: wingdings; color: red'>AMBGAT MEZLBNU</span>. Something wrong. Can't stop hugging plushies."

/obj/item/paper/crumpled/hotel_scrap_7
	name = "Journal Entry #8"
	info = "<span style='font-family: wingdings; color: red'>ASGATDHU NAMSPA KER OKS O OKDOFLI OSDSFKO OASKDAFO AOSDKF OINAIS ISJDDEF OSKFEREAODIK OSI ODIFOSA OEKRRO ASODFKAO PSSDOF SDFK OSDKF OSDKFSASPODFIOSASD UHGU DFYG FPO ASDFOS DFOASSD FAPSO FSPDFOIER OPWASDSA PS DODIOF OSDI</span> pizza <span style='font-family: wingdings; color: red'>OKSDFO AL OKEWORK CVBUASO SDFO AOE RAOWEIK SODDFI</span>"

/obj/item/paper/hotel_scrap_8
	name = "Mysterious Note"
	icon_state = "paper_talisman"
	info = "<div style='text-align: center; color: red; font: 24pt comic sans ms'>There is only one way to leave.</div>"

/obj/item/paper/pamphlet/hotel
	name = "space hotel pamphlet"
	info = "<h3>Welcome to Deep Space Hotel 419!</h3>Thank you for choosing our hotel. Simply hand your credit or debit card to the concierge and get your room key! To check out, hand your credit card back.<small><h4>Conditions:</h4><ul><li>The hotel is not responsible for any losses due to time or space anomalies.<li>The hotel is not responsible for events that occur outside of the hotel station, including, but not limited to, events that occur inside of dimensional pockets.<li>The hotel is not responsible for overcharging your account.<li>The hotel is not responsible for missing persons.<li>The hotel is not responsible for mind-altering effects due to drugs, magic, demons, or space worms.</ul></small>"

/obj/effect/landmark/map_loader/hotel_room/Initialize()
	..()
	// load and randomly assign rooms
	var/global/list/south_room_templates = list()
	var/global/list/north_room_templates = list()
	var/static/path = "_maps/map_files/templates/spacehotel/"
	var/global/loaded = 0
	if(!loaded)
		loaded = 1
		for(var/map in flist(path))
			if(cmptext(copytext(map, length(map) - 3), ".dmm"))
				var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
				if(copytext(map, 1, 3) == "n_")
					north_room_templates += T
				else if(copytext(map, 1, 3) == "s_")
					south_room_templates += T
				else
					// omnidirectional rooms are randomly assigned
					if(prob(50))
						north_room_templates += T
					else
						south_room_templates += T

	var/datum/map_template/M = safepick(dir == NORTH ? north_room_templates : south_room_templates)
	if(M)
		template = M
		if(dir == NORTH)
			north_room_templates -= M
		else
			south_room_templates -= M
		load(M)

// The door to a hotel room, but also metadata for the room itself
/obj/machinery/door/unpowered/hotel_door
	name = "Room Door"
	icon = 'icons/obj/doors/doorsand.dmi'
	icon_state = "door_closed"
	autoclose = 1
	var/doorOpen = 'sound/machines/airlock_open.ogg'
	var/doorClose = 'sound/machines/airlock_close.ogg'
	var/doorDeni = 'sound/machines/deniedbeep.ogg'
	var/id									// the room number, eg 101
	var/obj/item/card/hotel_card/card// room's key card
	var/mob/living/occupant = null			// the current room occupant
	var/datum/money_account/account			// Account we're pulling from
	var/roomtimer							// timer PS handle for updating room

/obj/machinery/door/unpowered/hotel_door/New()
	..()
	if(id)
		name = "Room [id]"

	// in case we spawned after hotel
	var/obj/effect/hotel_controller/H
	H = H.controller
	if(H)
		H.add_room(src)

/obj/machinery/door/unpowered/hotel_door/Destroy()
	if(roomtimer)
		deltimer(roomtimer)
		roomtimer = null
	QDEL_NULL(card)
	return ..()

/obj/machinery/door/unpowered/hotel_door/examine(mob/user)
	..()
	to_chat(user, "This room is currently [occupant ? "" : "un"]occupied.")

/obj/machinery/door/unpowered/hotel_door/allowed(mob/living/carbon/user)
	for(var/obj/item/card/hotel_card/C in user.get_all_slots())
		if(C == card && occupant)
			atom_say("Welcome, [occupant.real_name]!")
			return 1
	return 0

/obj/machinery/door/unpowered/hotel_door/update_icon()
	overlays.Cut()
	if(density)
		icon_state = "door_closed"
	else
		icon_state = "door_open"

/obj/machinery/door/unpowered/hotel_door/do_animate(animation)
	switch(animation)
		if("opening")
			playsound(loc, doorOpen, 30, 1)
			flick("door_opening", src)
		if("closing")
			playsound(loc, doorClose, 30, 1)
			flick("door_closing", src)
		if("deny")
			playsound(src.loc, doorDeni, 50, 0, 3)
			flick("door_deny", src)

/obj/machinery/door/unpowered/hotel_door/autoclose()
	if(!density && !operating && autoclose)
		close()

/obj/machinery/door/unpowered/hotel_door/emag_act(mob/user)
	if(isliving(user) && density)
		var/obj/effect/hotel_controller/H
		if(H.controller)
			H.controller.deploy_sec(user)
	..()

/obj/item/card/hotel_card
	name = "Key Card"
	icon_state = "guest"
	color = "#0CF"
	var/id

/obj/item/card/hotel_card/New(loc, ID)
	..()
	if(ID)
		id = ID
	if(id)
		name = "Key Card - [id]"
		desc = "A key card to room [id]. Use it to open the door."

/obj/item/card/hotel_card/Destroy()
	var/mob/user = get(loc, /mob)
	if(user)
		to_chat(user, "\The [src] suddenly disappears in a flash!")
	return ..()

/obj/effect/hotel_controller
	var/global/obj/effect/hotel_controller/controller

	name = "Deep Space Hotel 419"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x"
	invisibility = 101
	anchored = 1
	density = 0
	opacity = 0
	var/list/room_doors[0]			// assoc list of [room id]=hotel_door
	var/list/vacant_rooms[0]		// list of vacant room doors
	var/list/guests[0]				// assoc list of [guest mob]=room id

	var/obj/item/radio/radio	// for shouting at deadbeats

/obj/effect/hotel_controller/New()
	..()
	if(controller)
		qdel(src)
	controller = src

	radio = new()
	radio.broadcasting = 0
	radio.listening = 0

	// get room doors
	for(var/obj/machinery/door/unpowered/hotel_door/D in get_area(src))
		add_room(D)

/obj/effect/hotel_controller/proc/add_room(obj/machinery/door/unpowered/hotel_door/D)
	room_doors["[D.id]"] = D
	vacant_rooms += D

/obj/effect/hotel_controller/Destroy()
	room_doors.Cut()
	vacant_rooms.Cut()
	guests.Cut()

	QDEL_NULL(radio)

	return ..()

// to check a person into a room; no financial stuff; returns the keycard
/obj/effect/hotel_controller/proc/checkin(roomid, mob/living/carbon/occupant, obj/item/card/id/id)
	if(!istype(occupant))
		return null
	var/obj/machinery/door/unpowered/hotel_door/D = room_doors["[roomid]"]
	if(!D || D.occupant || (occupant in guests))
		return null

	D.account = get_card_account(id, occupant)
	if(!D.account)
		return null
	if(!D.account.charge(100, null, "10 minutes hotel stay", "Biesel GalaxyNet Terminal [rand(111,1111)]", "[name]"))
		return null

	D.occupant = occupant
	D.roomtimer = addtimer(CALLBACK(src, .proc/process_room, roomid), PAY_INTERVAL, TIMER_STOPPABLE)
	vacant_rooms -= D
	guests[occupant] = roomid

	var/obj/item/card/hotel_card/C = new(ID = roomid)
	D.card = C
	return C

/obj/effect/hotel_controller/proc/process_room(roomid)
	var/obj/machinery/door/unpowered/hotel_door/D = room_doors["[roomid]"]
	if(!D || !D.occupant)
		return

	if(D.account.charge(100, null, "10 minutes hotel stay extension", "Biesel GalaxyNet Terminal [rand(111,1111)]", "[name]"))
		D.roomtimer = addtimer(CALLBACK(src, .proc/process_room, roomid), PAY_INTERVAL, TIMER_STOPPABLE)
	else
		force_checkout(roomid)

// Checks a person out of a room; no financial stuff
/obj/effect/hotel_controller/proc/checkout(roomid)
	var/obj/machinery/door/unpowered/hotel_door/D = room_doors["[roomid]"]
	if(!D || !D.occupant)
		return 0

	guests -= D.occupant
	D.occupant = null
	D.account = null
	deltimer(D.roomtimer)
	D.roomtimer = null
	qdel(D.card)
	vacant_rooms += D
	return 1

// The person's card bounced mid-stay
/obj/effect/hotel_controller/proc/force_checkout(roomid)
	var/obj/machinery/door/unpowered/hotel_door/D = room_doors["[roomid]"]
	if(!D || !D.occupant)
		return 0

	var/mob/deadbeat = D.occupant

	radio.autosay("[deadbeat], your card has been rejected. You have 30 seconds to check out.", name, zlevel = list(z))
	spawn(300)
		if(D.occupant == deadbeat)
			// they still haven't checked out...
			deploy_sec(deadbeat)
			checkout(roomid)

/obj/effect/hotel_controller/proc/deploy_sec(mob/living/target)
	if(!istype(target) || !istype(get_area(target), /area/awaymission/spacehotel))
		return

	var/list/secs[0]
	for(var/mob/living/carbon/human/interactive/away/hotel/guard/M in get_area(src))
		if(!M.retal)
			secs += M
	var/mob/living/carbon/human/interactive/away/hotel/guard/S = safepick(secs)
	if(!S)
		return

	S.retal_target = target
	S.retal = 1
