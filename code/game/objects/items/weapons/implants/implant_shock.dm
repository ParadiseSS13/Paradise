/obj/item/implant/shock
	name = "shock bio-chip"
	desc = "Use this to escape from those evil Red Shirts."
	icon_state = "freedom"
	item_color = "r"
	origin_tech = "combat=5;magnets=3;biotech=4;syndicate=2"
	implant_data = /datum/implant_fluff/freedom
	implant_state = "implant-syndicate" //


/obj/item/implant/shock/activate()
	to_chat(imp_in, "You toggle the implant")
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

/obj/item/clothing/gloves/color/yellow/power
	var/old_mclick_override
	var/datum/middleClickOverride/power_gloves/mclick_override = new /datum/middleClickOverride/power_gloves
	var/last_shocked = 0
	var/shock_delay = 3 SECONDS
	var/unlimited_power = FALSE // Does this really need explanation?
	var/shock_range = 7

/obj/item/clothing/gloves/color/yellow/power/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='warning'>These are a pair of power gloves, and can be used to fire bolts of electricity while standing over powered power cables.</span>"

/obj/item/clothing/gloves/color/yellow/power/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(slot == SLOT_HUD_GLOVES)
		if(H.middleClickOverride)
			old_mclick_override = H.middleClickOverride
		H.middleClickOverride = mclick_override
		if(!unlimited_power)
			to_chat(H, "<span class='notice'>You feel electricity begin to build up in [src].</span>")
		else
			to_chat(H, "<span class='biggerdanger'>You feel like you have UNLIMITED POWER!!</span>")

/obj/item/clothing/gloves/color/yellow/power/dropped(mob/user, slot)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_HUD_GLOVES) == src && H.middleClickOverride == mclick_override)
		if(old_mclick_override)
			H.middleClickOverride = old_mclick_override
			old_mclick_override = null
		else
			H.middleClickOverride = null

/obj/item/clothing/gloves/color/yellow/power/unlimited
	name = "UNLIMITED POWER gloves"
	desc = "These gloves possess UNLIMITED POWER."
	shock_delay = 0
	unlimited_power = TRUE
