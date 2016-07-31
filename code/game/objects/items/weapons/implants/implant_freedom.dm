/obj/item/weapon/implant/freedom
	name = "freedom implant"
	desc = "Use this to escape from those evil Red Shirts."
	icon_state = "freedom"
	item_color = "r"
	uses = 4


/obj/item/weapon/implant/freedom/activate()
	uses--
	to_chat(imp_in, "You feel a faint click.")
	if(iscarbon(imp_in))
		var/mob/living/carbon/C_imp_in = imp_in
		C_imp_in.uncuff()
	if(!uses)
		qdel(src)


/obj/item/weapon/implant/freedom/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Freedom Beacon<BR>
<b>Life:</b> optimum 5 uses<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Transmits a specialized cluster of signals to override handcuff locking
mechanisms<BR>
<b>Special Features:</b><BR>
<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system<BR>
<HR>
No Implant Specifics"}
	return dat


/obj/item/weapon/implanter/freedom
	name = "implanter (freedom)"

/obj/item/weapon/implanter/freedom/New()
	imp = new /obj/item/weapon/implant/freedom(src)
	..()


/obj/item/weapon/implantcase/freedom
	name = "implant case - 'Freedom'"
	desc = "A glass case containing a freedom implant."

/obj/item/weapon/implantcase/freedom/New()
	imp = new /obj/item/weapon/implant/freedom(src)
	..()