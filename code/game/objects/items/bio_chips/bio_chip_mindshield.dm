/obj/item/bio_chip/mindshield
	name = "mindshield bio-chip"
	desc = "Stops people messing with your mind."
	origin_tech = "materials=2;biotech=4;programming=4"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/mindshield
	implant_state = "implant-nanotrasen"
	var/hud_icon_state = "hud_imp_loyal"
	var/cult_source = "corporate tendrils of Nanotrasen"

/obj/item/bio_chip/mindshield/can_implant(mob/source, mob/user)
	if(source.mind?.has_antag_datum(/datum/antagonist/rev/head))
		source.visible_message("<span class='biggerdanger'>[source] seems to resist [src]!</span>",
								"<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
		return FALSE
	return ..()

/obj/item/bio_chip/mindshield/implant(mob/target)
	if(!..())
		return FALSE
	if(target.mind)
		if(target.mind.has_antag_datum(/datum/antagonist/rev))
			SSticker.mode.remove_revolutionary(target.mind)
		if(IS_CULTIST(target))
			to_chat(target, "<span class='warning'>You feel the [cult_source] try to invade your mind!</span>")
		return TRUE

	to_chat(target, "<span class='notice'>Your mind feels hardened - more resistant to brainwashing.</span>")
	return TRUE

/obj/item/bio_chip/mindshield/removed(mob/target, silent = 0)
	if(..())
		if(target.stat != DEAD && !silent)
			to_chat(target, "<span class='boldnotice'>Your mind softens. You feel susceptible to the effects of brainwashing once more.</span>")
		return TRUE
	return FALSE

/obj/item/bio_chip_implanter/mindshield
	name = "bio-chip implanter (mindshield)"
	implant_type = /obj/item/bio_chip/mindshield

/obj/item/bio_chip_case/mindshield
	name = "bio-chip case - 'mindshield'"
	desc = "A glass case containing a mindshield bio-chip."
	implant_type = /obj/item/bio_chip/mindshield

/obj/item/bio_chip/mindshield/syndicate
	name = "syndishield bio-chip"
	desc = "Stops Nanotrasen from messing with your mind."
	origin_tech = "materials=2;biotech=4;programming=4;syndicate=3"
	implant_data = /datum/implant_fluff/syndicate_shield
	hud_icon_state = "hud_imp_syndiloyal"
	cult_source = "twisted plans of the Syndicate"

/obj/item/bio_chip_implanter/syndishield
	name = "bio-chip implanter (syndishield)"
	implant_type = /obj/item/bio_chip/mindshield/syndicate

/obj/item/bio_chip_case/syndishield
	name = "bio-chip case - 'syndishield'"
	desc = "A glass case containing a mindshield bio-chip."
	implant_type = /obj/item/bio_chip/mindshield/syndicate
