/obj/item/clothing/head/soft
	name = "cargo cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "cargosoft"
	item_state = "helmet"
	item_color = "cargo"
	var/flipped = FALSE
	actions_types = list(/datum/action/item_action/flip_cap)
	dog_fashion = /datum/dog_fashion/head/cargo_tech
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)
	dyeable = TRUE

/obj/item/clothing/head/soft/dropped()
	icon_state = "[item_color]soft"
	flipped = FALSE
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
		A.UpdateButtons()

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

/obj/item/clothing/head/soft/deliverysoft
	name = "delivery boy cap"
	desc = "It's a baseball hat that is part of the delivery boy uniform."
	icon_state = "deliverysoft"
	item_color = "delivery"
	dog_fashion = /datum/dog_fashion/head/softcap
	sprite_sheets = list(
		"Human" = 'icons/mob/clothing/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
		)

/obj/item/clothing/head/soft/janitorgrey
	name = "grey janitor's cap"
	desc = "It's a grey baseball hat with a purple custodial shield."
	icon_state = "janitorgreysoft"
	item_color = "janitorgrey"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/janitorpurple
	name = "purple janitor's cap"
	desc = "It's a purple baseball hat with a mint service shield."
	icon_state = "janitorpurplesoft"
	item_color = "janitorpurple"
	dog_fashion = /datum/dog_fashion/head/softcap

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red colour."
	icon_state = "secsoft"
	item_color = "sec"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 10, ACID = 50)
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
	armor = list(MELEE = 10, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 75)
	icon_state = "solgovsoft_flipped"
	strip_delay = 60
	flipped = TRUE

/obj/item/clothing/head/soft/solgov/marines/elite
	name = "\improper Trans-Solar Federation Specops marine cap"
	desc = "A cap worn by marines of the Trans-Solar Federation Specops division. You aren't quite sure how they made this bulletproof, but you are glad it is!"
	armor = list(MELEE = 25, BULLET = 75, LASER = 5, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = 200, ACID = 200)
	icon_state = "solgovelitesoft_flipped"
	item_color = "solgovelite"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/soft/solgov/marines/command
	name = "\improper Trans-Solar Federation lieutenant's cap"
	desc = "A soft cap worn by marines of the Trans-Solar Federation. The insignia signifies the wearer bears the rank of a Lieutenant."
	icon_state = "solgovcsoft_flipped"
	item_color = "solgovc"
	dog_fashion = null
	strip_delay = 80

/obj/item/clothing/head/soft/solgov/marines/command/elite
	name = "\improper Trans-Solar Federation Specops Lieutenant's cap"
	desc = "A cap worn by marines of the Trans-Solar Federation Specops division. You aren't quite sure how they made this bulletproof, but you are glad it is! The insignia signifies the wearer bears the rank of a Lieutenant."
	armor= list(MELEE = 25, BULLET = 75, LASER = 5, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = 200, ACID = 200)
	icon_state = "solgovcelitesoft"
	item_color = "solgovcelite"
	resistance_flags = FIRE_PROOF
