/obj/item/implant/freedom
	name = "freedom implant"
	desc = "Use this to escape from those evil Red Shirts."
	icon_state = "freedom"
	item_color = "r"
	origin_tech = "combat=5;magnets=3;biotech=4;syndicate=2"
	uses = 4


/obj/item/implant/freedom/activate()
	uses--
	to_chat(imp_in, "You feel a faint click.")
	if(iscarbon(imp_in))
		var/mob/living/carbon/C_imp_in = imp_in
		C_imp_in.uncuff()
		for(var/obj/item/grab/G in C_imp_in.grabbed_by)
			var/mob/living/carbon/M = G.assailant
			C_imp_in.visible_message("<span class='warning'>[C_imp_in] suddenly shocks [M] from their wrists and slips out of their grab!</span>")
			M.Stun(1) //Drops the grab
			M.apply_damage(2, BURN, "r_hand", M.run_armor_check("r_hand", "energy"))
			M.apply_damage(2, BURN, "l_hand", M.run_armor_check("l_hand", "energy"))
			C_imp_in.SetStunned(0) //This only triggers if they are grabbed, to have them break out of the grab, without the large stun time.
			C_imp_in.SetWeakened(0)
			playsound(C_imp_in.loc, "sound/weapons/Egloves.ogg", 75, 1)
	if(!uses)
		qdel(src)


/obj/item/implant/freedom/get_data()
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


/obj/item/implanter/freedom
	name = "implanter (freedom)"

/obj/item/implanter/freedom/New()
	imp = new /obj/item/implant/freedom(src)
	..()


/obj/item/implantcase/freedom
	name = "implant case - 'Freedom'"
	desc = "A glass case containing a freedom implant."

/obj/item/implantcase/freedom/New()
	imp = new /obj/item/implant/freedom(src)
	..()
