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


/obj/item/clothing/glasses/vr_goggles/Destroy()
	..()
	vr_human.revert_to_reality(1)
	cleanup_vr_avatar()

/obj/item/clothing/glasses/vr_goggles/dropped()
	..()
	if(vr_human)
		vr_human.revert_to_reality(0)

/obj/item/clothing/glasses/vr_goggles/proc/cleanup_vr_avatar()
	if(vr_human)
		vr_human = null

/obj/item/clothing/glasses/vr_goggles/equipped()
	..()
	var/mob/living/carbon/human/H = loc
	spawn(1)
		if(H.glasses == src)
			if(vr_human == null)
				vr_human = spawn_vr_avatar(H, "Lobby")
			else
				control_remote(H, vr_human)