/obj/item/implant/mindshield
	name = "mindshield implant"
	desc = "Stops people messing with your mind."
	origin_tech = "materials=2;biotech=4;programming=4"
	activated = IMPLANT_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/mindshield
	implant_state = "implant-nanotrasen"

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
	name = "implanter (mindshield)"
	implant_type = /obj/item/implant/mindshield

/obj/item/implantcase/mindshield
	name = "implant case - 'mindshield'"
	desc = "A glass case containing a mindshield implant."
	implant_type = /obj/item/implant/mindshield
