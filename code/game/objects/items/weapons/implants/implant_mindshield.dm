/obj/item/implant/mindshield
	name = "mindshield implant"
	desc = "Stops people messing with your mind."
	origin_tech = "materials=2;biotech=4;programming=4"
	activated = IMPLANT_ACTIVATED_PASSIVE

/obj/item/implant/mindshield/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Management Implant<BR>
				<b>Life:</b> Ten years.<BR>
				<b>Important Notes:</b> Personnel injected with this device can better resist mental compulsions.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small pod of nanobots that manipulate the host's mental functions.<BR>
				<b>Special Features:</b> Will prevent and cure most forms of brainwashing.<BR>
				<b>Integrity:</b> Implant will last so long as the nanobots are inside the bloodstream."}
	return dat


/obj/item/implant/mindshield/implant(mob/target)
	if(..())
		if(target.mind in SSticker.mode.revolutionaries)
			SSticker.mode.remove_revolutionary(target.mind)
		if(target.mind in SSticker.mode.cult)
			to_chat(target, "<span class='warning'>You feel the corporate tendrils of Nanotrasen try to invade your mind!</span>")
		else
			to_chat(target, "<span class='notice'>Your mind feels hardened - more resistant to brainwashing.</span>")
		return TRUE
	return FALSE

/obj/item/implant/mindshield/removed(mob/target, silent = 0)
	if(..())
		if(target.stat != DEAD && !silent)
			to_chat(target, "<span class='boldnotice'>Your mind softens. You feel susceptible to the effects of brainwashing once more.</span>")
		return TRUE
	return FALSE


/obj/item/implanter/mindshield
	name = "implanter (mindshield)"

/obj/item/implanter/mindshield/New()
	imp = new /obj/item/implant/mindshield(src)
	..()

/obj/item/implantcase/mindshield
	name = "implant case - 'mindshield'"
	desc = "A glass case containing a mindshield implant."

/obj/item/implantcase/mindshield/New()
	imp = new /obj/item/implant/mindshield(src)
	..()
