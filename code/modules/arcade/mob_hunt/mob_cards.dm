
//Standard Cards
/obj/item/nanomob_card
	name = "Nano-Mob Hunter Trading Card"
	desc = "A blank Nano-Mob Hunter Trading Card. Worthless!"
	icon = 'icons/obj/card.dmi'
	icon_state = "trade_card"
	force = 0
	throwforce = 1
	w_class = WEIGHT_CLASS_TINY
	var/datum/mob_hunt/mob_data

/obj/item/nanomob_card/proc/update_info()
	if(!mob_data)
		return
	if(mob_data.is_shiny)
		name = "Holographic [mob_data.mob_name] Nano-Mob Hunter Card"
		desc = "WOW! A holographic trading card containing a level [mob_data.level] [mob_data.mob_name]!"
		icon_state = "trade_card_holo"
	else
		name = "[mob_data.mob_name] Nano-Mob Hunter Card"
		desc = "A trading card containing a level [mob_data.level] [mob_data.mob_name]!"

//Booster Pack Cards (random mob data)
/obj/item/nanomob_card/booster
	name = "Nano-Mob Hunter Booster Pack Card"
	desc = "A random Nano-Mob Trading Card from a Booster Pack. Wonder what it is?"

/obj/item/nanomob_card/booster/New()
	var/datum/mob_hunt/mob_info = pick(subtypesof(/datum/mob_hunt))
	mob_data = new mob_info(0,null,1)
	update_info()

//Booster Packs (Box of booster pack cards)
/obj/item/storage/box/nanomob_booster_pack
	name = "Nano-Mob Hunter Trading Card Booster Pack"
	desc = "Contains 6 random Nano-Mob Hunter Trading Cards. May contain a holographic card!"
	can_hold = list(/obj/item/nanomob_card)

/obj/item/storage/box/nanomob_booster_pack/New()
	..()
	for(var/i in 1 to 6)
		new /obj/item/nanomob_card/booster(src)
