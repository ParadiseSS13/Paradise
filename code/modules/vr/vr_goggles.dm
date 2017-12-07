//Glorified teleporter that puts you in a new human body.
// it's """VR"""

/obj/item/clothing/glasses/vr_goggles
	desc = "Your ticket to another reality."
	name = "VR Goggles"
	icon_state = "3d"
	item_state = "3d"
	prescription_upgradable = 0
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)

	var/you_die_in_the_game_you_die_for_real = FALSE
	var/mob/living/carbon/human/virtual_reality/vr_human = null
	var/user_health = 0
	var/exile = 0


/obj/item/clothing/glasses/vr_goggles/Destroy()
	if(vr_human)
		vr_human.revert_to_reality(1)
		cleanup_vr_avatar()
	processing_objects.Remove(src)
	return ..()

/obj/item/clothing/glasses/vr_goggles/dropped()
	if(vr_human)
		vr_human.revert_to_reality(0)
	processing_objects.Remove(src)
	..()

/obj/item/clothing/glasses/vr_goggles/proc/cleanup_vr_avatar()
	if(vr_human)
		vr_human = null

/obj/item/clothing/glasses/vr_goggles/proc/contained()
	if(exile && vr_server_status == VR_SERVER_ON)
		return 1
	else if (!exile && vr_server_status == VR_SERVER_EMAG)
		return 1
	else
		return 0

/obj/item/clothing/glasses/vr_goggles/proc/enter_vr()
	var/area/A = get_area(src)
	var/mob/living/carbon/human/H = loc
	if(vr_server_status == VR_SERVER_OFF)
		to_chat(H, "Failed to reach VR Server")
	else
		var/datum/vr_room/lobby = vr_rooms_official["Lobby"]
		spawn(1)
			if(H.glasses == src)
				if(exile && !(istype(A, /area/security/vr)))
					visible_message("<span class='notice'>ERROR: No connection to containment downlink</span>")
					return
				if(vr_human == null)
					vr_human = spawn_vr_avatar(H, lobby)
				else
					control_remote(H, vr_human)
		user_health = H.health
		processing_objects.Add(src)

/obj/item/clothing/glasses/vr_goggles/equipped()
	..()
	enter_vr()

/obj/item/clothing/glasses/vr_goggles/process()
	var/mob/living/carbon/human/H = loc
	if(user_health - H.health > 50 && !contained())
		vr_human.revert_to_reality(0)

/obj/item/clothing/glasses/vr_goggles/exile
	desc = "The mind is just another prison with the right bars."
	name = "Exile VR Goggles"
	icon_state = "3d"
	item_state = "3d"
	exile = 1