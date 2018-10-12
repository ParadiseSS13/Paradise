

/mob/living/carbon/human/virtual_reality
	var/mob/living/carbon/human/real_me
	var/datum/vr_room/myroom
	var/datum/action/quit_vr/quit_action
	var/datum/action/back_to_lobby/back_to_lobby
	var/datum/action/detach_from_avatar/detach_from_avatar

/mob/living/carbon/human/virtual_reality/New()
	..()

/mob/living/carbon/human/virtual_reality/death()
	if(!can_die())
		return FALSE
	handle_despawn()
	return ..(gibbed = 1)

/mob/living/carbon/human/virtual_reality/proc/handle_despawn()
	myroom.players.Remove(src)
	vr_all_players.Remove(src)
	if((myroom.players.len == 0) && (myroom.expires == 1))
		myroom.delete_timer = addtimer(CALLBACK(myroom, /datum/vr_room/proc/cleanup), 3 MINUTES, TIMER_STOPPABLE)
	else if((myroom.players.len == 1) && (myroom.expires == 2))
		myroom.round_timer = addtimer(CALLBACK(myroom, /datum/vr_room/proc/vr_round), 10 SECONDS, TIMER_STOPPABLE)
		var/mob/living/carbon/human/virtual_reality/winner = myroom.players[1]
		myroom.round_end = world.time + 1 MINUTES
		for(var/mob/living/carbon/human/virtual_reality/P in vr_all_players)
			if(P.ckey)
				to_chat(P, "SYSTEM MESSAGE: [winner.name] has won the PVP match in The [myroom.name]. New match in one minute, please be in the lobby.")
			else if(P.real_me.can_hear() && P.real_me.ckey && P in myroom.waitlist)
				to_chat(P.real_me, "\[VR HEADSET\]: [winner.name] has won the PVP match in The [myroom.name]. New match in one minute, please be in the lobby.")

	if(src.ckey)
		return_to_lobby()
	if(src.surgeries.len == 0)
		var/mob/living/carbon/human/virtual_reality/vr = src
		var/list/corpse_equipment = vr.get_all_slots()
		corpse_equipment += vr.get_equipped_items()
		for(var/obj/O in corpse_equipment)
			if(myroom.template.death_type == VR_DROP_ALL)
				vr.unEquip(O)
			else if(myroom.template.death_type == VR_DROP_BLACKLIST && !(O.type in myroom.template.drop_blacklist))
				vr.unEquip(O)
			else if(myroom.template.death_type == VR_DROP_WHITELIST && (O.type in myroom.template.drop_whitelist))
				vr.unEquip(O)
			else
				qdel(O)
		qdel(src)


/mob/living/carbon/human/virtual_reality/Destroy()
	return ..()

/mob/living/carbon/human/virtual_reality/ghost()
	alert(src, "You can not ghost while in VR. Please exit first.","Are you sure you want to ghost?")
	return

/mob/living/carbon/human/virtual_reality/proc/revert_to_reality(var/remove)
	if(real_me && ckey)
		real_me.ckey = ckey
		real_me.EyeBlind(2)
		real_me.Confused(2)
		var/mob/living/carbon/human/virtual_reality/vr = src
		var/obj/item/clothing/ears/vr_headset/goggles
		for(var/obj/effect/proc_holder/spell/S in src.mind.spell_list)
			src.mind.RemoveSpell(S)
		for(var/obj/item/clothing/ears/vr_headset/g in vr.real_me.contents)
			goggles = g
		if(goggles.contained() && vr_server_status == VR_SERVER_EMAG)
			real_me.adjustBrainLoss(60)
			real_me.vomit(20)
		for(var/obj/item/clothing/ears/vr_headset/g in vr.real_me.contents)
			processing_objects.Remove(g)
			if(remove)
				g.vr_human = null
		if(remove)
			handle_despawn()
		else
			return src

/mob/living/carbon/human/virtual_reality/proc/return_to_lobby()
	if(real_me && mind)
		var/mob/living/carbon/human/virtual_reality/new_vr
		var/datum/vr_room/lobby = vr_rooms_official["Lobby"]
		new_vr = spawn_vr_avatar(src, lobby)
		for(var/obj/item/clothing/ears/vr_headset/g in new_vr.real_me.contents)
			g.vr_human = new_vr

/obj/effect/proc_holder/spell/vr
	var/mob/living/carbon/human/virtual_reality/avatar // for brain removal

/obj/effect/proc_holder/spell/vr/Click()
	cast(user = usr) // All the spell logic is wasted on this use of the spell system, so it is bypassed
	start_recharge()

/obj/effect/proc_holder/spell/vr/quit_vr
	name = "Quit Virtual Reality"
	panel = "VR"
	charge_max = 10
	action_icon_state = "shutdown"

/obj/effect/proc_holder/spell/vr/quit_vr/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = avatar
	if(istype(H, /mob/living/carbon/human/virtual_reality))
		var/mob/living/carbon/human/virtual_reality/vr = H
		var/obj/item/clothing/ears/vr_headset/goggles
		for(var/obj/item/clothing/ears/vr_headset/g in vr.real_me.contents)
			goggles = g
		if(!goggles.contained())
			vr.revert_to_reality(1)
		else
			to_chat(vr, "You are currently imprisoned in Virtual Reality and are unable to disconnect.")

/obj/effect/proc_holder/spell/vr/back_to_lobby
	name = "Return To Lobby"
	panel = "VR"
	charge_max = 10
	action_icon_state = "lobby"

/obj/effect/proc_holder/spell/vr/back_to_lobby/cast(list/targets, mob/user = usr)
	to_chat(world, "haaaalp")
	var/mob/living/carbon/human/H = avatar
	to_chat(world, H.name)
	if(istype(H, /mob/living/carbon/human/virtual_reality))
		var/mob/living/carbon/human/virtual_reality/vr = H
		to_chat(world, vr.name)
		if(!vr.ckey)
			vr.ckey = user.ckey
		vr.handle_despawn()

/obj/effect/proc_holder/spell/vr/detach_from_avatar
	name = "Detach From Avatar"
	panel = "VR"
	charge_max = 10
	action_icon_state = "logout"

/obj/effect/proc_holder/spell/vr/detach_from_avatar/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H = avatar
	if(istype(H, /mob/living/carbon/human/virtual_reality))
		var/mob/living/carbon/human/virtual_reality/vr = H
		var/obj/item/clothing/ears/vr_headset/goggles
		for(var/obj/item/clothing/ears/vr_headset/g in vr.real_me.contents)
			goggles = g
		if(!goggles.contained())
			vr.revert_to_reality(0)
		else
			to_chat(vr, "You are currently imprisoned in Virtual Reality and are unable to disconnect.")

/mob/living/carbon/human/virtual_reality/proc/add_mind_powers()
	src.mind.AddSpell(new /obj/effect/proc_holder/spell/vr/quit_vr(null))
	src.mind.AddSpell(new /obj/effect/proc_holder/spell/vr/back_to_lobby(null))
	src.mind.AddSpell(new /obj/effect/proc_holder/spell/vr/detach_from_avatar(null))
	for(var/obj/effect/proc_holder/spell/S in src.mind.spell_list)
		if(istype(S, /obj/effect/proc_holder/spell/vr))
			var/obj/effect/proc_holder/spell/vr/vr_spell = S
			vr_spell.avatar = src
