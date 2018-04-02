var/global/hotel_guard_paranoia = 0

/mob/living/carbon/human/interactive/away/hotel
	away_area = /area/awaymission/spacehotel
	override_under = /obj/item/clothing/under/mafia
	chattyness = SNPC_CHANCE_TALK / 4
	faction = list("hotel")
	var/list/hotel_enemies = list()

/mob/living/carbon/human/interactive/away/hotel/retalTarget(mob/living/target)
	..(target)
	DeclareEnemy()

/mob/living/carbon/human/interactive/away/hotel/death(gibbed)
	hotel_guard_paranoia++
	..(gibbed)

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
	var/has_called_security = FALSE

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
		return

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

	// Checking out
	if(id_owner in hotel.guests)
		say ("Hope you enjoyed your [adjective_objects] stay at our [adjective_generic] hotel!")
		hotel.checkout(hotel.guests[id_owner])
		return

	// Checking in - is this person allowed to check in?
	var/should_call_security = FALSE
	var/list/saved_enemies = list()
	for(var/mob/living/simple_animal/hostile/retaliate/hotel_secbot/B in living_mob_list)
		if(id_owner in B.enemies)
			should_call_security = TRUE
			saved_enemies = B.enemies
			break
	if(should_call_security)
		if(has_called_security)
			say("No way! Not while security is after you!")
			return
		say("GUARDS!")
		has_called_security = TRUE
		sleep(5)
		for(var/obj/effect/landmark/L in landmarks_list)
			if(L.name == "hotelguardspawn")
				var/mob/living/simple_animal/hostile/retaliate/hotel_secbot/B = new /mob/living/simple_animal/hostile/retaliate/hotel_secbot(get_turf(L))
				B.enemies = saved_enemies.Copy()
				playsound(B.loc, 'sound/effects/sparks4.ogg', 50, 1)
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(4, 1, B)
				s.start()
		return

	// Checking in - verify there is a room free
	var/obj/machinery/door/unpowered/hotel_door/D = safepick(hotel.vacant_rooms)
	if(!D)
		say("Sorry, all the [adjective_objects] are occupied currently.")
		return

	// Checking in - actually do checkin
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
	attacktext = "slices"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("hotel")
	speak_emote = list("states")
	gold_core_spawnable = CHEM_MOB_SPAWN_INVALID
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	deathmessage = "blows apart!"
	del_on_death = 1
	var/turf/home_turf
	var/max_distance = 25
	var/gear_confiscated = 0
	var/guards_area = FALSE

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/New()
	..()
	home_turf = get_turf(src)

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/death(gibbed)
	hotel_guard_paranoia++
	..(gibbed)


/mob/living/simple_animal/hostile/retaliate/hotel_secbot/boss
	name = "Hotel Security Chief"
	health = 300
	maxHealth = 300
	max_distance = 10
	guards_area = TRUE

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/Aggro()
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.back && istype(H.back, /obj/item/device/radio/electropack))
			var/obj/item/device/radio/electropack/E = H.back
			H.visible_message("<span class='danger'>[src] activates the electropack on [H]!</span>", "<span class='userdanger'>[src] activated your electropack!</span>")
			spawn(0)
				E.activate_pack()
	playsound(loc, 'sound/voice/halt.ogg', 50, 0)
	gear_confiscated = 0

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/handle_automated_action()
	..()
	if(prob(10) && !target)
		if(get_dist(loc, home_turf) > max_distance)
			return_home()
	if(guards_area && prob(10))
		Retaliate()

/mob/living/simple_animal/hostile/retaliate/hotel_secbot/proc/return_home()
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
		if(HULK in H.mutations)
			H.attack_animal(src)
		else if(!H.stunned)
			stun_attack(H)
		else if(H.canBeHandcuffed() && !H.handcuffed)
			cuff(H)
		else if(H.handcuffed || !H.canBeHandcuffed())
			hotel_brig(H)
		else
			H.attack_animal(src)
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
	var/obj/effect/landmark/hotelbrig
	var/obj/effect/landmark/hotelevidence
	var/obj/effect/landmark/hotelgateout
	for(var/obj/effect/landmark/S in landmarks_list)
		if(S.name == "hotelbrig")
			hotelbrig = S
		if(S.name == "hotelevidence")
			hotelevidence = S
		if(S.name == "hotelgateout")
			hotelgateout = S
	if(!hotelevidence || !hotelbrig || !hotelgateout || hotel_guard_paranoia >= 5)
		H.attack_animal(src)
		return
	if(hotel_guard_paranoia || health != maxHealth)
		var/obj/item/I
		if(H.back && H.canUnEquip(H.back, 0) && !istype(H.back, /obj/item/weapon/tank) && !istype(H.back, /obj/item/device/radio/electropack))
			I = H.back
		else if(H.belt && H.canUnEquip(H.belt, 0) && !istype(H.belt, /obj/item/weapon/tank))
			I = H.belt
		else if(H.gloves && H.canUnEquip(H.gloves, 0))
			I = H.gloves
		else if(H.l_store && H.canUnEquip(H.l_store, 0) && !istype(H.l_store, /obj/item/weapon/tank))
			I = H.l_store
		else if(H.r_store && H.canUnEquip(H.r_store, 0) && !istype(H.r_store, /obj/item/weapon/tank))
			I = H.r_store
		if(I)
			H.unEquip(I, 0)
			H.visible_message("<span class='danger'>[src] removes [I] from [H]!</span>", "<span class='userdanger'>[src] confiscates [I]!</span>")
			I.forceMove(get_turf(hotelevidence))
			gear_confiscated++
			return
		if(!H.back)
			H.equip_to_slot_or_del(new /obj/item/device/radio/electropack(H), slot_back)
			H.visible_message("<span class='danger'>[src] puts an electropack on [H]!</span>", "<span class='userdanger'>[src] puts an electropack on you!</span>")
			return
		if(gear_confiscated)
			qdel(hotelevidence)
	playsound(loc, 'sound/effects/sparks4.ogg', 50, 1)
	if (hotel_guard_paranoia)
		H.visible_message("<span class='danger'>[src] teleports [H] away!</span>", "<span class='userdanger'>[src] beams you to the special guest suite!</span>")
		do_teleport(H, get_turf(hotelbrig), 0)
	else
		H.visible_message("<span class='danger'>[src] teleports [H] away!</span>", "<span class='userdanger'>[src] beams you to their gateway storage room. They are showing you the door!</span>")
		do_teleport(H, get_turf(hotelgateout), 0)
	LoseTarget()
	gear_confiscated = 0
	hotel_guard_paranoia++