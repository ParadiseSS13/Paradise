/mob/living/carbon/human/interactive/away/hotel
	away_area = /area/awaymission/spacehotel
	override_under = /obj/item/clothing/under/mafia
	chattyness = SNPC_CHANCE_TALK / 4

/mob/living/carbon/human/interactive/away/hotel/Initialize(mapload)
	. = ..(mapload, /datum/species/skrell)

/mob/living/carbon/human/interactive/away/hotel/doSetup()
	..()
	MYID.access = list(access_syndicate)
	RPID.access = list(access_syndicate)

/mob/living/carbon/human/interactive/away/hotel/guard
	default_job = /datum/job/officer

/mob/living/carbon/human/interactive/away/hotel/guard/doSetup()
	..("Guard")

	// anti-pinata cheese
	var/obj/item/implant/dust/D = new /obj/item/implant/dust(src)
	D.implant(src)

	for(var/obj/item/I in get_all_slots())
		I.flags |= NODROP

/mob/living/carbon/human/interactive/away/hotel/guard/KnockOut()
	// you'll never take me alive (this triggers the implant)
	emote("deathgasp")
	if(stat != DEAD)
		// mission failed. we'll get em next time
		..()

/mob/living/carbon/human/interactive/away/hotel/chef
	default_job = /datum/job/chef
	away_area = /area/awaymission/spacehotel/kitchen
	override_under = /obj/item/clothing/under/mafia/vest

/mob/living/carbon/human/interactive/away/hotel/bartender
	default_job = /datum/job/bartender
	override_under = /obj/item/clothing/under/mafia/vest

/mob/living/carbon/human/interactive/away/hotel/concierge
	override_under = /obj/item/clothing/under/mafia/white
	away_area = /area/awaymission/spacehotel/reception
	var/list/known_guests[0]
	var/obj/effect/hotel_controller/hotel
	var/obj/item/card/id/last_seen_id = null

/mob/living/carbon/human/interactive/away/hotel/concierge/random()
	..()
	equip_or_collect(new /obj/item/clipboard(src), slot_l_hand)

/mob/living/carbon/human/interactive/away/hotel/concierge/doSetup()
	..("Concierge")

/mob/living/carbon/human/interactive/away/hotel/concierge/setup_job()
	favoured_types = list(/obj/item/paper, /obj/item/clipboard)
	functions += list("stamping", "concierge")
	restrictedJob = 1

/mob/living/carbon/human/interactive/away/hotel/concierge/proc/concierge()
	if(!hotel)
		hotel = hotel.controller
		if(!hotel)
			return

	var/verbs_use = pick_list(speak_file, "verbs_use")
	var/verbs_touch = pick_list(speak_file, "verbs_touch")
	var/verbs_move = pick_list(speak_file, "verbs_move")
	var/nouns_generic = pick_list(speak_file, "nouns_generic")
	var/adjective_insult = pick_list(speak_file, "adjective_insult")
	var/adjective_objects = pick_list(speak_file, "adjective_objects")
	var/adjective_generic = pick_list(speak_file, "adjective_generic")
	var/curse_words = pick_list(speak_file, "curse_words")

	var/found = 0
	for(var/mob/living/carbon/human/H in nearby - known_guests)
		pointed(H)
		known_guests += H
		found = 1
	if(found)
		say("Welcome to [hotel], [nouns_generic]! Please check in by [ing_verb(verbs_move)] and [ing_verb(verbs_use)] your [adjective_objects] ID onto the table.")
		return

	var/obj/item/card/id
	var/id_seen = 0
	for(var/obj/item/card/id/I in get_area(src))
		id_seen = 1
		if(I != last_seen_id)
			id = I
	if(!id_seen)
		last_seen_id = null
		return
	if(!id)
		return
	var/turf/idloc = get_turf(id)
	if(!Adjacent(idloc))
		tryWalk(idloc)
	else
		// is the last jerk that touched it over here?
		var/mob/id_owner
		for(var/mob/living/carbon/human/H in nearby)
			if(H.ckey == id.fingerprintslast)
				id_owner = H
				break

		if(!id_owner)
			say("Whose card is this?")
			pointed(id)
			return

		last_seen_id = id
		// Checking in or out?
		if(id_owner in hotel.guests)
			// Check out
			say ("Hope you enjoyed your [adjective_objects] stay at our [adjective_generic] hotel!")
			hotel.checkout(hotel.guests[id_owner])
		else
			// pick a room
			var/obj/machinery/door/unpowered/hotel_door/D = safepick(hotel.vacant_rooms)
			if(!D)
				say("Sorry, all the [adjective_objects] are occupied currently.")
			else
				// Check in
				say("$100 per 10 minutes. The cost will be automatically [past_verb(verbs_touch)] while you're checked in.")

				var/obj/item/card/hotel_card/K = hotel.checkin(D.id, id_owner, id)
				if(K)
					K.forceMove(idloc)
				else
					say("Your [adjective_insult] [curse_words] card was rejected.")
