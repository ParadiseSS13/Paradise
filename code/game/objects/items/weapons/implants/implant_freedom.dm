/obj/item/implant/freedom
	name = "freedom bio-chip"
	desc = "Use this to escape from those evil Red Shirts."
	icon_state = "freedom"
	item_color = "r"
	origin_tech = "combat=5;magnets=3;biotech=4;syndicate=2"
	uses = 4
	implant_data = /datum/implant_fluff/freedom
	implant_state = "implant-syndicate"


/obj/item/implant/freedom/activate()
	uses--
	to_chat(imp_in, "You feel a faint click.")
	if(iscarbon(imp_in))
		var/mob/living/carbon/C_imp_in = imp_in
		C_imp_in.uncuff()
		for(var/obj/item/grab/G in C_imp_in.grabbed_by)
			var/mob/living/carbon/M = G.assailant
			C_imp_in.visible_message("<span class='warning'>[C_imp_in] suddenly shocks [M] from their wrists and slips out of their grab!</span>")
			M.Stun(2 SECONDS) //Drops the grab
			M.apply_damage(2, BURN, "r_hand", M.run_armor_check("r_hand", "energy"))
			M.apply_damage(2, BURN, "l_hand", M.run_armor_check("l_hand", "energy"))
			C_imp_in.SetStunned(0) //This only triggers if they are grabbed, to have them break out of the grab, without the large stun time.
			C_imp_in.SetWeakened(0)
			playsound(C_imp_in.loc, "sound/weapons/egloves.ogg", 75, 1)
	if(!uses)
		qdel(src)

/obj/item/implanter/freedom
	name = "bio-chip implanter (freedom)"
	implant_type = /obj/item/implant/freedom

/obj/item/implantcase/freedom
	name = "bio-chip case - 'Freedom'"
	desc = "A glass case containing a freedom bio-chip."
	implant_type = /obj/item/implant/freedom

/obj/item/implant/freedom/prototype
	name = "prototype freedom bio-chip"
	desc = "Use this to escape from those evil Red Shirts. Works only once!"
	icon_state = "freedom"
	item_color = "r"
	origin_tech = "combat=5;magnets=3;biotech=3;syndicate=1"
	uses = 1
	implant_data = /datum/implant_fluff/protofreedom
	implant_state = "implant-syndicate"

/obj/item/implanter/freedom/prototype
	name = "bio-chip implanter (proto-freedom)"
	implant_type = /obj/item/implant/freedom/prototype

/obj/item/implantcase/freedom/prototype
	name = "bio-chip case - 'Proto-Freedom'"
	desc = "A glass case containing a prototype freedom bio-chip."
	implant_type = /obj/item/implant/freedom/prototype
