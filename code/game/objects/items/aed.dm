/obj/item/defibrillator/aed
	name = "Automatic external defibrillator"
	desc = "A device that delivers shocks to detachable paddles that restarts stopped hearts."
	icon_state = "aed"
	item_state = "aed"
	slot_flags = SLOT_BACK | SLOT_BELT
	origin_tech = "biotech=2"
	species_fit = null 
	sprite_sheets = null 

/obj/item/defibrillator/aed/loaded/New() //starts with hicap
	..()
	bcell = new(src)
	update_icon()

/obj/item/defibrillator/aed/item_action_slot_check(slot, mob/user)
	return slot == slot_back || slot == slot_belt

/obj/item/defibrillator/aed/make_paddles()
    return new /obj/item/twohanded/shockpaddles/aed(src)

/obj/item/defibrillator/aed/update_overlays()
	overlays.Cut()
	if(!on)
		overlays += "[initial(icon_state)]-paddles"

/obj/item/twohanded/shockpaddles/aed
	name = "AED paddles"
	desc = "A pair of plastic-gripped paddles with flat metal surfaces that are used to deliver electric shocks."
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"
	revivecost = 10000 // Fucking expensive piece of shit

/obj/item/twohanded/shockpaddles/aed/try_revive(mob/living/carbon/human/H, mob/living/user, tplus)
	to_chat(user, "<span class='danger'>[H] doesn't respond at all!</span>")
