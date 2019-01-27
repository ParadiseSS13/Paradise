//Glorified teleporter that puts you in a new human body.
// it's """VR"""

/obj/item/clothing/ears/vr_headset
	desc = "Your ticket to another reality. Designed to be worn above the ears."
	name = "N.T.S.R.S. Headset"
	icon_state = "brainset"
	item_state = "brainset"
	actions_types = list(/datum/action/item_action/enter_vr)
	var/you_die_in_the_game_you_die_for_real = FALSE //Perhaps some day
	var/mob/living/carbon/human/virtual_reality/vr_human = null
	var/user_health = 0
	var/exile = 0
	var/area/room = null

/obj/item/clothing/ears/vr_headset/Destroy()
	if(vr_human)
		vr_human.revert_to_reality(1)
		cleanup_vr_avatar()
	processing_objects.Remove(src)
	return ..()

/obj/item/clothing/ears/vr_headset/dropped()
	if(vr_human)
		vr_human.revert_to_reality(0)
	processing_objects.Remove(src)
	..()

/obj/item/clothing/ears/vr_headset/proc/cleanup_vr_avatar()
	if(vr_human)
		vr_human = null

/obj/item/clothing/ears/vr_headset/proc/contained()
	if(exile && vr_server_status == VR_SERVER_ON)
		return 1
	else if (!exile && vr_server_status == VR_SERVER_EMAG)
		return 1

/obj/item/clothing/ears/vr_headset/proc/enter_vr()
	var/area/A = get_area(src)
	var/mob/living/carbon/human/H = loc
	if(vr_server_status == VR_SERVER_OFF)
		to_chat(H, "Failed to reach VR Server")
	else
		var/datum/vr_room/lobby = vr_rooms_official["Lobby"]
		spawn(1)
			if(H.l_ear == src || H.r_ear == src)
				if(exile && !(istype(A, /area/security/vr)))
					visible_message("<span class='notice'>ERROR: No connection to containment downlink in this area</span>")
					return
				if(istype(H, /mob/living/carbon/human/virtual_reality))
					to_chat(H, "<span class='notice'>No. You can't enter VR in VR.</span>")
					return
				if(vr_human == null)
					vr_human = spawn_vr_avatar(H, lobby)
				else
					control_remote(H, vr_human)
					H.vr_avatar = vr_human
				user_health = H.health
				processing_objects.Add(src)
				room = A

/obj/item/clothing/ears/vr_headset/equipped()
	..()
	if(exile)
		enter_vr()


/obj/item/clothing/ears/vr_headset/item_action_slot_check(slot, mob/user)
    if(slot == slot_l_ear || slot == slot_r_ear)
        return 1

/obj/item/clothing/ears/vr_headset/ui_action_click()
	enter_vr()

/obj/item/clothing/ears/vr_headset/process()
	var/mob/living/carbon/human/H = loc
	var/area/A = get_area(src)
	H.Weaken(3)
	if((user_health - H.health > 25 && !contained()) || (exile && !(istype(A, /area/security/vr))) || H.stat == 2)
		vr_human.revert_to_reality(0)
	if(room != A)
		to_chat(vr_human, "<span class='danger'>You see your vision flicker as your headset changes from one network to another.</span>")
		room = A
	if(H.ckey)
		processing_objects.Remove(src)

/obj/item/clothing/ears/vr_headset/exile
	desc = "The mind is just another prison with the right bars."
	name = "Exile N.T.S.R.S. Goggles"
	icon_state = "prisonerset"
	item_state = "prisonerset"
	exile = 1