/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "cargosoft"
	item_state = "helmet"
	item_color = "cargo"
	var/flipped = 0
	actions_types = list(/datum/action/item_action/flip_cap)
	dog_fashion = /datum/dog_fashion/head/cargo_tech
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi'
		)

/obj/item/clothing/head/soft/dropped()
	icon_state = "[item_color]soft"
	flipped = 0
	..()

/obj/item/clothing/head/soft/attack_self(mob/user)
	flip(user)

/obj/item/clothing/head/soft/proc/flip(mob/user)
	flipped = !flipped
	if(flipped)
		icon_state = "[item_color]soft_flipped"
		to_chat(usr, "You flip the hat backwards.")
	else
		icon_state = "[item_color]soft"
		to_chat(user, "You flip the hat back in normal position.")
	user.update_inv_head()	//so our mob-overlays update

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red colour."
	icon_state = "redsoft"
	item_color = "red"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue colour."
	icon_state = "bluesoft"
	item_color = "blue"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green colour."
	icon_state = "greensoft"
	item_color = "green"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "yellowsoft"
	item_color = "yellow"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"
	item_color = "grey"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange colour."
	icon_state = "orangesoft"
	item_color = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white colour."
	icon_state = "mimesoft"
	item_color = "mime"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple colour."
	icon_state = "purplesoft"
	item_color = "purple"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/black
	name = "black cap"
	desc = "It's a baseball hat in a tasteless black colour."
	icon_state = "blacksoft"
	item_color = "black"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	item_color = "rainbow"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red colour."
	icon_state = "secsoft"
	item_color = "sec"
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	desc = "It's a baseball hat in corporate colours."
	icon_state = "corpsoft"
	item_color = "corp"

/obj/item/clothing/head/soft/solgov
	name = "\improper Trans-Solar Federation marine cap"
	desc = "A soft cap worn by marines of the Trans-Solar Federation."
	icon_state = "solgovsoft"
	item_color = "solgov"
	dog_fashion = null

/obj/item/clothing/head/soft/solgov/marines
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30,"energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50)
	strip_delay = 60
	icon_state = "solgovsoft_flipped"
	flipped = TRUE

/obj/item/clothing/head/soft/solgov/marines/elite
	name = "\improper Trans-Solar Federation Specops marine cap"
	desc = "A soft cap worn by marines of the Trans-Solar Federation Specops division."
	icon_state = "solgovelitesoft_flipped"
	item_color = "solgovelite"

/obj/item/clothing/head/soft/solgov/marines/command
	name = "\improper Trans-Solar Federation lieutenant's cap"
	desc = "A soft cap worn by marines of the Trans-Solar Federation. The insignia signifies the wearer bears the rank of a Lieutenant."
	icon_state = "solgovcsoft_flipped"
	item_color = "solgovc"
	dog_fashion = null
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 50, "acid" = 60)
	strip_delay = 80

/obj/item/clothing/head/soft/solgov/marines/command/elite
	name = "\improper Trans-Solar Federation Specops Lieutenant's cap"
	desc = "A soft cap worn by marines of the Trans-Solar Federation Specops division. The insignia signifies the wearer bears the rank of a Lieutenant."
	icon_state = "solgovcelitesoft"
	item_color = "solgovcelite"
