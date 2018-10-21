

/mob/living/carbon/human/virtual_reality
	var/mob/living/carbon/human/real_me //The human controlling us, can be any human (including virtual ones... inception...)
	var/datum/action/quit_vr/quit_action
	var/datum/action/back_to_lobby/back_to_lobby
	var/datum/action/detach_from_avatar/detach_from_avatar

/mob/living/carbon/human/virtual_reality/New()
	quit_action = new()
	quit_action.Grant(src)
	back_to_lobby = new()
	back_to_lobby.Grant(src)
	detach_from_avatar = new()
	detach_from_avatar.Grant(src)
	..()

/mob/living/carbon/human/virtual_reality/death()
	if(can_die())
		return_to_lobby()
	return ..()

/mob/living/carbon/human/virtual_reality/Destroy()
	return_to_lobby()
	return ..()

/mob/living/carbon/human/virtual_reality/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."
	var/mob/living/carbon/human/H = real_me
	revert_to_reality(FALSE)
	if(H)
		H.ghost()
	qdel(src)

/mob/living/carbon/human/virtual_reality/proc/revert_to_reality(remove = 0)
	if(real_me && mind)
		mind.transfer_to(real_me)
		real_me.EyeBlind(2)
		real_me.Confused(2)
		if(remove)
			qdel(src)
		else
			return src

/mob/living/carbon/human/virtual_reality/proc/return_to_lobby()
	if(real_me && mind)
		var/mob/living/carbon/human/virtual_reality/new_vr
		new_vr = spawn_vr_avatar(src, "Lobby")
		var/obj/item/clothing/glasses/vr_goggles/g = new_vr.real_me.glasses
		g.vr_human = new_vr
		qdel(src)

/datum/action/quit_vr
	name = "Quit Virtual Reality"

/datum/action/quit_vr/Trigger()
	if(..())
		if(istype(owner, /mob/living/carbon/human/virtual_reality))
			var/mob/living/carbon/human/virtual_reality/vr = owner
			vr.revert_to_reality(1)
		else
			Remove(owner)

/datum/action/back_to_lobby
	name = "Return To Lobby"

/datum/action/back_to_lobby/Trigger()
	if(..())
		if(istype(owner, /mob/living/carbon/human/virtual_reality))
			var/mob/living/carbon/human/virtual_reality/vr = owner
			vr.return_to_lobby()
		else
			Remove(owner)

/datum/action/detach_from_avatar
	name = "Detach From Avatar"

/datum/action/detach_from_avatar/Trigger()
	if(..())
		if(istype(owner, /mob/living/carbon/human/virtual_reality))
			var/mob/living/carbon/human/virtual_reality/vr = owner
			var/obj/item/clothing/glasses/vr_goggles/g = vr.real_me.glasses
			g.vr_human = vr
			vr.revert_to_reality(0)
		else
			Remove(owner)
