/mob/living/carbon/human/interactive/away/hotel
	away_area = /area/awaymission/spacehotel
	override_under = /obj/item/clothing/under/mafia
	chattyness = SNPC_CHANCE_TALK / 4
	faction = list("hotel")
	var/list/hotel_enemies = list()

/mob/living/carbon/human/interactive/away/hotel/retalTarget(mob/living/target)
	..(target)
	DeclareEnemy()

/mob/living/carbon/human/interactive/away/hotel/proc/DeclareEnemy()
	for(var/mob/living/L in get_mobs_in_view(8, src))
		if("hotel" in L.faction)
			continue
		if(L in hotel_enemies)
			continue
		for(var/mob/living/simple_animal/hostile/retaliate/hotel_secbot/B in living_mob_list)
			if(!(L in B.enemies))
				B.enemies |= L
		pointed(L)
		hotel_enemies |= L

/mob/living/carbon/human/interactive/away/hotel/New(loc)
	..(loc, "Skrell")

/mob/living/carbon/human/interactive/away/hotel/doSetup()
	..()
	MYID.access = list(access_syndicate)
	RPID.access = list(access_syndicate)

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
	var/obj/item/weapon/card/id/last_seen_id = null

/mob/living/carbon/human/interactive/away/hotel/concierge/random()
	..()
	equip_or_collect(new /obj/item/weapon/clipboard(src), slot_l_hand)

/mob/living/carbon/human/interactive/away/hotel/concierge/doSetup()
	..("Concierge")

/mob/living/carbon/human/interactive/away/hotel/concierge/setup_job()
	favoured_types = list(/obj/item/weapon/paper, /obj/item/weapon/clipboard)
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

	var/obj/item/weapon/card/id
	var/id_seen = 0
	for(var/obj/item/weapon/card/id/I in get_area(src))
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
			for(var/mob/living/simple_animal/hostile/retaliate/hotel_secbot/H in living_mob_list)
				if(id_owner in H.enemies)
					say("Sorry, I cannot check you in while [H] is after you.")
					return

			// pick a room
			var/obj/machinery/door/unpowered/hotel_door/D = safepick(hotel.vacant_rooms)
			if(!D)
				say("Sorry, all the [adjective_objects] are occupied currently.")
			else
				// Check in
				say("$100 per 10 minutes. The cost will be automatically [past_verb(verbs_touch)] while you're checked in.")

				var/obj/item/weapon/card/hotel_card/K = hotel.checkin(D.id, id_owner, id)
				if(K)
					K.forceMove(idloc)
				else
					say("Your [adjective_insult] [curse_words] card was rejected.")


/mob/living/simple_animal/hostile/retaliate/hotel_secbot
	name = "Hotel Security"
	desc = "A small security robot."
	icon = 'icons/mob/hivebot.dmi'
	icon_state = "SecBot"
	icon_living = "SecBot"
	icon_dead = "SecBot"
	health = 200
	maxHealth = 200
	melee_damage_lower = 15
	melee_damage_upper = 15
	anchored = 1
	attacktext = "batons"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("hotel")
	speak_emote = list("states")
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	deathmessage = "blows apart!"
	del_on_death = 1
	var/turf/home_turf


/mob/living/simple_animal/hostile/retaliate/hotel_secbot/New()
	..()
	home_turf = get_turf(src)

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/boss
	name = "Hotel Security Chief"
	health = 300
	maxHealth = 300
	var/max_distance = 10

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/Aggro()
	..()
	playsound(loc, 'sound/voice/halt.ogg', 50, 0)

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/boss/handle_automated_action()
	..()
	if(prob(10) && !target)
		Retaliate()
		if(get_dist(loc, home_turf) > max_distance)
			playsound(loc, 'sound/effects/sparks4.ogg', 50, 1)
			do_teleport(src, home_turf, 0)

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/Retaliate()
	..()
	if(!enemies.len)
		return
	for(var/mob/living/simple_animal/hostile/retaliate/hotel_secbot/B in living_mob_list)
		if(B == src)
			continue
		for(var/E in enemies)
			if(!(E in B.enemies))
				B.enemies |= E

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/AttackingTarget()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!H.stunned)
			stun_attack(H)
		else if(H.canBeHandcuffed() && !H.handcuffed)
			cuff(H)
		else if(H.handcuffed)
			hotel_brig(H)
		else
			target.attack_animal(src)
	else
		target.attack_animal(src)

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/proc/stun_attack(mob/living/carbon/human/H)
	playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
	H.stuttering = 5
	H.Stun(5)
	H.Weaken(5)
	add_logs(src, H, "stunned")
	H.visible_message("<span class='danger'>[src] has stunned [H]!</span>", "<span class='userdanger'>[src] has stunned you!</span>")

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/proc/cuff(mob/living/carbon/human/H)
	playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
	H.visible_message("<span class='danger'>[src] is trying to put zipties on [H]!</span>",\
						"<span class='userdanger'>[src] is trying to put zipties on you!</span>")
	H.handcuffed = new /obj/item/weapon/restraints/handcuffs/cable/zipties/used(H)
	H.update_handcuffed()

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/proc/hotel_brig(mob/living/carbon/human/H)
	var/obj/effect/landmark/brig
	var/obj/effect/landmark/evidence
	for(var/obj/effect/landmark/S in landmarks_list)
		if(S.name == "hotelbrig")
			brig = S
		if(S.name == "hotelevidence")
			evidence = S
	if(!evidence || !brig)
		H.attack_animal(src)
		return
	var/obj/item/I
	if(H.back && H.canUnEquip(H.back, 0))
		I = H.back
	else if(H.belt && H.canUnEquip(H.belt, 0))
		I = H.belt
	else if(H.gloves && H.canUnEquip(H.gloves, 0))
		I = H.gloves
	else if(H.l_store && H.canUnEquip(H.l_store, 0))
		I = H.l_store
	else if(H.r_store && H.canUnEquip(H.r_store, 0))
		I = H.r_store

	if(I)
		H.unEquip(I, 0)
		H.visible_message("<span class='danger'>[src] removes [I] from [H]!</span>", "<span class='userdanger'>[src] confiscates [I]!</span>")
		I.forceMove(get_turf(evidence))
		return

	qdel(evidence)
	H.visible_message("<span class='danger'>[src] beams [H] to the special guest suite!</span>", "<span class='userdanger'>[src] beams you to the special guest suite!</span>")
	playsound(loc, 'sound/effects/sparks4.ogg', 50, 1)
	do_teleport(H, get_turf(brig), 0)
	LoseTarget()