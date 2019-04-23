/obj/item/implant/chem
	name = "chem implant"
	desc = "Injects things."
	icon_state = "reagents"
	origin_tech = "materials=3;biotech=4"
	container_type = OPENCONTAINER

/obj/item/implant/chem/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp MJ-420 Prisoner Management Implant<BR>
				<b>Life:</b> Deactivates upon death but remains within the body.<BR>
				<b>Important Notes: Due to the system functioning off of nutrients in the implanted subject's body, the subject<BR>
				will suffer from an increased appetite.</B><BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a small capsule that can contain various chemicals. Upon receiving a specially encoded signal<BR>
				the implant releases the chemicals directly into the blood stream.<BR>
				<b>Special Features:</b>
				<i>Micro-Capsule</i>- Can be loaded with any sort of chemical agent via the common syringe and can hold 50 units.<BR>
				Can only be loaded while still in its original case.<BR>
				<b>Integrity:</b> Implant will last so long as the subject is alive."}
	return dat

/obj/item/implant/chem/New()
	..()
	create_reagents(50)
	GLOB.tracked_implants += src

/obj/item/implant/chem/Destroy()
	GLOB.tracked_implants -= src
	return ..()




/obj/item/implant/chem/trigger(emote, mob/source, force)
	if(force && emote == "deathgasp")
		activate(reagents.total_volume)

/obj/item/implant/chem/activate(cause)
	if(!cause || !imp_in)	return 0
	var/mob/living/carbon/R = imp_in
	var/injectamount = null
	if(cause == "action_button")
		injectamount = reagents.total_volume
	else
		injectamount = cause
	reagents.trans_to(R, injectamount)
	to_chat(R, "<span class='italics'>You hear a faint beep.</span>")
	if(!reagents.total_volume)
		to_chat(R, "<span class='italics'>You hear a faint click from your chest.</span>")
		qdel(src)


/obj/item/implantcase/chem
	name = "implant case - 'Remote Chemical'"
	desc = "A glass case containing a remote chemical implant."

/obj/item/implantcase/chem/New()
	imp = new /obj/item/implant/chem(src)
	..()
