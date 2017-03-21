

//Glorified teleporter that puts you in a new human body.
// it's """VR"""

/obj/item/clothing/glasses/vr_goggles
	desc = "A long time ago, people used these glasses to makes images from screens threedimensional."
	name = "3D glasses"
	icon_state = "3d"
	item_state = "3d"
	prescription_upgradable = 0
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi'
		)

	var/you_die_in_the_game_you_die_for_real = FALSE
	var/mob/living/carbon/human/virtual_reality/vr_human
	var/static/list/available_vr_spawnpoints
	var/vr_category = "default" //Specific category of spawn points to pick from
	var/outfit = /datum/outfit/vr_basic

/obj/item/clothing/glasses/vr_goggles/Destroy()
	..()
	cleanup_vr_avatar()

/obj/item/clothing/glasses/vr_goggles/emag_act(mob/user)
	//placeholder

/obj/item/clothing/glasses/vr_goggles/dropped()
	..()
	if(vr_human)
		cleanup_vr_avatar()
		vr_human.revert_to_reality(FALSE, FALSE)

/obj/item/clothing/glasses/vr_goggles/equipped()
	..()
	var/mob/living/carbon/human/H = loc
	spawn(1)
		if(H.glasses == src)
			control_remote(H,build_virtual_avatar(H,pick(avatarspawn)))

/obj/item/clothing/glasses/vr_goggles/proc/build_virtual_avatar(mob/living/carbon/human/virtual_reality/H, location)
	if(!location)
		return
	var/mob/living/carbon/human/virtual_reality/vr_avatar
	cleanup_vr_avatar()
	vr_avatar = new /mob/living/carbon/human/virtual_reality(location)
	vr_avatar.set_species(H.species.name)
	vr_avatar.vr_goggles = src
	vr_avatar.real_me = H
	vr_avatar.dna = H.dna.Clone()
	vr_avatar.name = H.name
	vr_avatar.real_name = H.real_name
	vr_avatar.undershirt = H.undershirt
	vr_avatar.underwear = H.underwear
//	vr_avatar.change_hair(H.head_organ.h_style)
	if(outfit)
		var/datum/outfit/vr_basic/O = new outfit()
		O.equip(vr_avatar)
	return vr_avatar

/obj/item/clothing/glasses/vr_goggles/proc/control_remote(mob/living/carbon/human/H, mob/living/carbon/human/virtual_reality/vr_avatar)
	if(H.mind)
		H.mind.transfer_to(vr_avatar)

/obj/item/clothing/glasses/vr_goggles/proc/cleanup_vr_avatar()
	if(vr_human)
		vr_human.death(0)

/datum/outfit/vr_basic
	name = "basic vr"
	uniform = /obj/item/clothing/under/psysuit
	shoes = /obj/item/clothing/shoes/black