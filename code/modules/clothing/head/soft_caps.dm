/obj/item/clothing/head/soft
	name = "grey cap"
	desc = "It's a baseball hat in a tasteless grey colour."
	icon = 'icons/obj/clothing/head/softcap.dmi'
	icon_state = "grey"
	worn_icon = 'icons/mob/clothing/head/softcap.dmi'
	actions_types = list(/datum/action/item_action/flip_cap)
	dog_fashion = /datum/dog_fashion/head/softcap
	sprite_sheets = list(
		"Kidan" = 'icons/mob/clothing/species/kidan/head/softcap.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head/softcap.dmi'
	)
	dyeable = TRUE
	/// Is the cap flipped? Affects sprite
	var/flipped = FALSE

/obj/item/clothing/head/soft/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/clothing/head/soft/dropped()
	flipped = FALSE
	update_icon(UPDATE_ICON_STATE)
	return ..()

/obj/item/clothing/head/soft/update_icon_state()
	icon_state = "[initial(icon_state)][flipped ? "_flipped" : ""]"

/obj/item/clothing/head/soft/attack_self__legacy__attackchain(mob/user)
	flip(user)

/obj/item/clothing/head/soft/proc/flip(mob/user)
	flipped = !flipped
	if(flipped)
		to_chat(usr, "You flip the hat backwards.")
	else
		to_chat(user, "You flip the hat back in normal position.")
	update_icon(UPDATE_ICON_STATE)
	user.update_inv_head()	//so our mob-overlays update
	update_action_buttons()

/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red colour."
	icon_state = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue colour."
	icon_state = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green colour."
	icon_state = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow colour."
	icon_state = "yellow"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange colour."
	icon_state = "orange"

/obj/item/clothing/head/soft/white
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white colour."
	icon_state = "white"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple colour."
	icon_state = "purple"

/obj/item/clothing/head/soft/black
	name = "black cap"
	desc = "It's a baseball hat in a tasteless black colour."
	icon_state = "black"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbow"

/obj/item/clothing/head/soft/cargo
	name = "cargo cap"
	desc = "It's a brown baseball hat with a grey cargo technician shield."
	icon_state = "cargo"
	dog_fashion = /datum/dog_fashion/head/cargo_tech

/obj/item/clothing/head/soft/mining
	name = "mining cap"
	desc = "It's an brown hard peaked baseball hat with a purple miner shield."
	icon_state = "mining"
	dog_fashion = /datum/dog_fashion/head/miningsoft

/obj/item/clothing/head/soft/expedition
	name = "expedition cap"
	desc = "It's a baseball hat in the brown and blue markings of the expedition team."
	icon_state = "expedition"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 10, ACID = 50)

/obj/item/clothing/head/soft/smith
	name = "smith's cap"
	desc = "It's a brown baseball hat with a black smithing shield."
	icon_state = "smith"
	dog_fashion = /datum/dog_fashion/head/smith

/obj/item/clothing/head/soft/engineer
	name = "engineer's cap"
	desc = "It's a yellow baseball hat with an orange engineering shield."
	icon_state = "engineer"

/obj/item/clothing/head/soft/atmos
	name = "atmospheric technician's cap"
	desc = "It's a yellow baseball hat with a blue engineering shield."
	icon_state = "atmos"

/obj/item/clothing/head/soft/janitorgrey
	name = "grey janitor's cap"
	desc = "It's a grey baseball hat with a purple custodial shield."
	icon_state = "janitorgrey"

/obj/item/clothing/head/soft/janitorpurple
	name = "purple janitor's cap"
	desc = "It's a purple baseball hat with a mint service shield."
	icon_state = "janitorpurple"

/obj/item/clothing/head/soft/hydroponics
	name = "botanist's cap"
	desc = "It's a green baseball hat with a blue service shield."
	icon_state = "hydroponics"

/obj/item/clothing/head/soft/hydroponics_alt
	name = "hydroponics cap"
	desc = "It's a green baseball hat with a brown service shield."
	icon_state = "hydroponics_alt"

/obj/item/clothing/head/soft/paramedic
	name = "\improper EMT cap"
	desc = "It's a blue baseball hat with a white medical shield."
	icon_state = "paramedic"
	dog_fashion = /datum/dog_fashion/head/paramedic

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red colour."
	icon_state = "sec"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 10, ACID = 50)
	strip_delay = 60

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	desc = "It's a baseball hat in corporate colours."
	icon_state = "corp"

/obj/item/clothing/head/soft/solgov
	name = "\improper TSF marine cap"
	desc = "A soft cap worn by marines of the Trans-Solar Federation."
	icon_state = "solgov"
	dog_fashion = null

/obj/item/clothing/head/soft/solgov/marines
	armor = list(MELEE = 10, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 75)
	strip_delay = 6 SECONDS
	flipped = TRUE

/obj/item/clothing/head/soft/solgov/marines/elite
	name = "\improper MARSOC cap"
	desc = "A cap worn by marines of the Trans-Solar Federation's Marine Special Operations Command. You aren't quite sure how they made this bulletproof, but you are glad it is!"
	icon_state = "solgovelite"
	armor = list(MELEE = 25, BULLET = 75, LASER = 5, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = 200, ACID = 200)
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/soft/solgov/marines/command
	name = "\improper TSF marine lieutenant's cap"
	desc = "A soft cap worn by marines of the Trans-Solar Federation. The insignia signifies the wearer bears the rank of a Lieutenant."
	icon_state = "solgovc"
	strip_delay = 8 SECONDS

/obj/item/clothing/head/soft/solgov/marines/command/elite
	name = "\improper MARSOC Lieutenant's cap"
	desc = "A cap worn by junior officers of the Trans-Solar Federation's Marine Special Operations Command. You aren't quite sure how they made this bulletproof, but you are glad it is! The insignia signifies the wearer bears the rank of a Lieutenant."
	armor = list(MELEE = 25, BULLET = 75, LASER = 5, ENERGY = 5, BOMB = 15, RAD = 50, FIRE = 200, ACID = 200)
	icon_state = "solgovcelite"
	resistance_flags = FIRE_PROOF
