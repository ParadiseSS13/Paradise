//Control file with the backbone for the vr rooms and avatars

var/list/vr_rooms = list()
var/list/vr_rooms_official = list()
var/list/vr_all_players = list()

/datum/vr_room
	var/name = null
	var/datum/map_template/vr/template = null
	var/datum/space_chunk/chunk = null
	var/list/spawn_points = list()
	var/list/players = list()
	var/expires = 1
	var/creator = null
	var/delete_timer = null
	var/round_timer = null
	var/round_end = null
	var/obj/effect/landmark/reset_point = null
	var/list/waitlist = list()
	var/list/templatelist = list()

/datum/vr_room/proc/cleanup()
	for(var/mob/living/carbon/human/virtual_reality/player in players)
		player.death()
	vr_rooms.Remove(src.name)
	spawn_points = list()
	space_manager.free_space(src.chunk)
	qdel(src)

/datum/vr_room/proc/sort_landmarks()
	for(var/atom/landmark in chunk.search_chunk(landmarks_list))
		if(landmark.name == "avatarspawn")
			spawn_points.Add(landmark)
		if(landmark.name == "resetpoint")
			reset_point = landmark
		if(landmark.name == "vr_loot_common" && template.loot_common.len > 0)
			if(prob(90))
				var/picked = pick(template.loot_common)
				new picked(get_turf(landmark))
		if(landmark.name == "vr_loot_rare" && template.loot_rare.len > 0)
			if(prob(50))
				var/picked = pick(template.loot_rare)
				new picked(get_turf(landmark))

/datum/vr_room/proc/assign_buttons()
	for(var/obj/machinery/vr_reset_button/b in chunk.search_chunk(vr_reset_buttons))
		b.room = src

/datum/vr_room/proc/assign_timers()
	for(var/obj/machinery/status_display/vr/T in world)
		if(T.room_name == name)
			T.myroom = src

/datum/vr_room/proc/vr_round()
	for(var/mob/living/carbon/human/virtual_reality/player in players)
		player.death()

	if(templatelist.len)
		template = vr_templates[pick(templatelist)]
	else
		cleanup()
		return

	if(waitlist.len > 1)
		to_chat(waitlist, "Previous round in cleanup mode, the next round will start in aproximatly 30 seconds. Please be in the lobby and on the list.")
		spawn_points = list()
		spawn(0)
			space_manager.free_space(src.chunk)
		round_end = world.time + 30 SECONDS
		sleep(30 SECONDS)
		chunk = space_manager.allocate_space(template.width, template.height)
		template.load(locate(chunk.x,chunk.y,chunk.zpos), centered = FALSE)

		sort_landmarks()
		assign_timers()

		for(var/mob/living/carbon/human/virtual_reality/player in waitlist)
			waitlist.Remove(player)
			if(player.myroom == vr_rooms_official["Lobby"])
				var/mob/living/carbon/human/virtual_reality/avatar = spawn_vr_avatar(player, src)
				avatar.equip_to_slot_if_possible(new /obj/item/device/observer, slot_r_ear, 1, 1, 1)
				player.death()

		round_timer = addtimer(src, "vr_round", 10 MINUTES)
		round_end = world.time + 10 MINUTES
	else
		to_chat(waitlist, "There are not enough players to start the round, checking again in one minute.")
		round_timer = addtimer(src, "vr_round", 1 MINUTES)
		round_end = world.time + 1 MINUTES

proc/make_vr_room(name, template, expires, creator)
	var/datum/vr_room/R = new
	R.name = name
	R.template = template
	R.template = vr_templates[R.template]
	R.chunk = space_manager.allocate_space(R.template.width, R.template.height)
	R.expires = expires
	R.creator = creator
	R.template.load(locate(R.chunk.x,R.chunk.y,R.chunk.zpos), centered = FALSE)

	if(expires == 1)
		vr_rooms[R.name] = R
		R.delete_timer = addtimer(R, "cleanup", 3 MINUTES)
	else if(expires == 0)
		vr_rooms_official[R.name] = R
	else if (expires == 2)
		vr_rooms_official[R.name] = R
		R.round_timer = addtimer(R, "vr_round", 3 MINUTES)
		R.round_end = world.time + 3 MINUTES

	R.sort_landmarks()
	R.assign_buttons()
	if(expires == 2 || expires == 0)
		R.assign_timers()

	return R

//Control code for the avatars
proc/build_virtual_avatar(mob/living/carbon/human/H, location, datum/vr_room/room)
	if(!location)
		return
	var/mob/living/carbon/human/virtual_reality/vr_avatar
	location = get_turf(location)
	vr_avatar = new /mob/living/carbon/human/virtual_reality(location)
	if(istype(H, /mob/living/carbon/human/virtual_reality))
		var/mob/living/carbon/human/virtual_reality/V = H
		vr_avatar.real_me = V.real_me
		V.real_me.vr_avatar = vr_avatar
	else
		vr_avatar.real_me = H
		H.vr_avatar = vr_avatar

	vr_avatar.dna = H.dna.Clone()
	vr_avatar.sync_organ_dna(assimilate=1)
	vr_avatar.set_species(H.species.name)
	vr_avatar.update_mutantrace(1)
	vr_avatar.UpdateAppearance()

	vr_avatar.name = H.name
	vr_avatar.real_name = H.real_name
	vr_avatar.undershirt = H.undershirt
	vr_avatar.underwear = H.underwear
	vr_avatar.equipOutfit(room.template.outfit)
	if(H.body_accessory)
		vr_avatar.body_accessory = H.body_accessory
	vr_avatar.update_tail_layer()

	var/obj/item/radio/headset/R = new /obj/item/radio/headset/vr(vr_avatar)
	vr_avatar.equip_to_slot_or_del(R, slot_l_ear)

	if(vr_avatar.species.name == "Plasmaman")
		for(var/obj/item/plasmensuit_cartridge/C in vr_avatar.loc)
			qdel(C)

	vr_avatar.species.after_equip_job(null, vr_avatar)

	vr_avatar.myroom = room
	vr_all_players.Add(vr_avatar)
	for (var/obj/item/clothing/ears/vr_headset/g in H.contents)
		g.vr_human = vr_avatar

	if(room.name == "Lobby")
		if(vr_avatar.a_intent != INTENT_HELP)
			vr_avatar.a_intent_change(INTENT_HELP)
		vr_avatar.can_change_intents = 0 //Now you have no choice but to be helpful.
	H.vr_avatar = vr_avatar
	return vr_avatar


proc/control_remote(mob/living/carbon/human/H, mob/living/carbon/human/virtual_reality/vr_avatar)
	if(H.ckey)
		vr_avatar.ckey = H.ckey
		//SSnanoui.close_user_uis(H)
		if(istype(H, /mob/living/carbon/human/virtual_reality))
			var/mob/living/carbon/human/virtual_reality/V = H
			vr_avatar.real_me = V.real_me
		else
			vr_avatar.real_me = H

proc/spawn_vr_avatar(mob/living/carbon/human/H, datum/vr_room/room)

	var/mob/living/carbon/human/virtual_reality/vr_human
	vr_human = build_virtual_avatar(H, pick(room.spawn_points), room)
	room.players.Add(vr_human)
	deltimer(room.delete_timer)
	control_remote(H, vr_human)
	return vr_human

proc/vr_kick_all_players()
	for(var/mob/living/carbon/human/virtual_reality/player in vr_all_players)
		player.revert_to_reality(1)

//Preloaded rooms
/hook/roundstart/proc/starting_levels()
	make_vr_room("Lobby", "lobby", 0)
	var/datum/vr_room/roman = make_vr_room("Roman Arena", "roman1", 2)
	roman.templatelist = list("roman1","roman2","roman3")
	return 1