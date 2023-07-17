/obj/item/implant/mindshield
	name = "mindshield bio-chip"
	desc = "Stops people messing with your mind."
	origin_tech = "materials=2;biotech=4;programming=4"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/mindshield
	implant_state = "implant-nanotrasen"

/obj/item/implant/mindshield/can_implant(mob/source, mob/user)
	if(source.mind in SSticker.mode.head_revolutionaries)
		source.visible_message("<span class='biggerdanger'>[source] seems to resist [src]!</span>",
								"<span class='warning'>You feel something interfering with your mental conditioning, but you resist it!</span>")
		return FALSE
	return ..()

/obj/item/implant/mindshield/implant(mob/target)
	if(!..())
		return FALSE
	if(target.mind)
		if(target.mind in SSticker.mode.revolutionaries)
			SSticker.mode.remove_revolutionary(target.mind)
		if(target.mind in SSticker.mode.cult)
			to_chat(target, "<span class='warning'>You feel the corporate tendrils of Nanotrasen try to invade your mind!</span>")
		return TRUE

	to_chat(target, "<span class='notice'>Your mind feels hardened - more resistant to brainwashing.</span>")
	return TRUE

/obj/item/implant/mindshield/removed(mob/target, silent = 0)
	if(..())
		if(target.stat != DEAD && !silent)
			to_chat(target, "<span class='boldnotice'>Your mind softens. You feel susceptible to the effects of brainwashing once more.</span>")
		return TRUE
	return FALSE

/obj/item/implanter/mindshield
	name = "bio-chip implanter (mindshield)"
	implant_type = /obj/item/implant/mindshield

/obj/item/implantcase/mindshield
	name = "bio-chip case - 'mindshield'"
	desc = "A glass case containing a mindshield bio-chip."
	implant_type = /obj/item/implant/mindshield
