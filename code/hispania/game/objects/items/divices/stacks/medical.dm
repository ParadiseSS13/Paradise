/obj/item/stack/medical/splint/hand_made
	name = "handmade splints"
	icon = 'icons/hispania/obj/miscellaneous.dmi'
	icon_state = "tape-splint"
	other_delay = 100

/obj/item/stack/medical/ointment/earthly_cataplasm
	name = "earthly herbal cataplasm"
	singular_name = "earthly herbal cataplasm"
	desc = "A type of primitive herbal cataplasm made with Lavaland plants. Smells horrible.\n It is imbued with ancient wisdom."
	icon = 'icons/hispania/obj/miscellaneous.dmi'
	icon_state = "poultice_green"
	amount = 10
	max_amount = 10
	heal_brute = 30
	self_delay = 15

/obj/item/stack/medical/ointment/earthly_cataplasm/heal(mob/living/M, mob/user)
	if(ishuman(M))
		var/obj/item/clothing/mask/P = M.wear_mask
		playsound(src, 'sound/misc/soggy.ogg', 30, TRUE)
		if(P && (P.flags_cover & MASKCOVERSMOUTH))
			to_chat(M, "<span class='warning'>You slightly smell and taste something foul...</span>")
			return ..()
		if(HAS_TRAIT(M, TRAIT_NOBREATH))
			to_chat(M, "<span class='warning'>You slightly taste something foul...</span>")
			return ..()
		if(M.mind && (M.mind.assigned_role == "Detective" || M.mind.assigned_role == "Coroner"))
			to_chat(M, "<span class='warning'>You taste and smell something foul but nothing new...</span>")
			return ..()
		if(isashwalker(M))
			to_chat(M, "<span class='warning'>You embrace nature..</span>")
			return ..()
		to_chat(M, "<span class='warning'>You smell and taste something foul...</span>")
		M.fakevomit()
		M.Weaken(2)
	return ..()

/obj/item/stack/medical/ointment/earthly_cataplasm/fiery_cataplasm
	name = "fiery herbal cataplasm"
	singular_name = "fiery herbal cataplasm"
	desc = "A type of primitive herbal cataplasm made with Lavaland plants. Smells horrible.\n It is imbued with ancient wisdom."
	icon_state = "poultice_orange"
	amount = 10
	max_amount = 10
	heal_burn = 30
	self_delay = 15

//////Delay de aplicacion cataplasmas////
/obj/item/stack/medical/ointment/earthly_cataplasm/attack(mob/living/carbon/M, mob/user)
	if(!istype(M))
		return FALSE
	if(user != M)
		M.visible_message("<span class='notice'>[user] attempts to apply [src].</span>")
		if(self_delay)
			if(!do_mob(user, M, 20))
				return TRUE
		return ..()
	else
		heal(M, user)
		M.UpdateDamageIcon()
		use(1)

/obj/item/stack/medical/quickclot
	name = "surgical quikclot gauze kit"
	desc = "A brand of hemostatic dressing famous through centuries, wound dressing that contains an agent that promotes blood clotting. You can take the bandages out with something sharp."
	icon = 'icons/hispania/obj/miscellaneous.dmi'
	icon_state = "quickclot"
	self_delay = 100
	w_class = WEIGHT_CLASS_NORMAL
	var/other_delay = 20
	amount = 4
	max_amount = 4

/obj/item/stack/medical/quickclot/attack(mob/living/M, mob/user)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/affecting = H.get_organ(user.zone_selected)
		if(!affecting)
			to_chat(user, "<span class='warning'>[M] doesn't have a limb there!</span>")
			return TRUE
		var/limb = affecting.name
		if(!(affecting.limb_name in list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")))
			to_chat(user, "<span class='danger'>You can't apply a [src] there!</span>")
			return TRUE
		if(affecting.internal_bleeding)
			if((M == user && self_delay > 0) || (M != user && other_delay > 0))
				user.visible_message("<span class='notice'>[user] starts to apply [src] to [H]'s [limb].</span>", \
										"<span class='notice'>You start to apply [src] to [H]'s [limb].</span>", \
										"<span class='notice'>You hear something being wrapped.</span>")
			if(M == user && !do_mob(user, H, self_delay))
				return TRUE
			else if(!do_mob(user, H, other_delay))
				return TRUE
			user.visible_message("<span class='notice'>[user] applies [src] to [H]'s [limb].</span>", \
								"<span class='notice'>You apply [src] to [H]'s [limb] stopping the internal bleeding.</span>")
			affecting.internal_bleeding = FALSE
			use(1)
		else
			to_chat(user, "<span class='warning'>You are unable to find any signs of internal bleeding on this limb.</span>")

/obj/item/stack/medical/quickclot/attackby(obj/item/I, mob/user, params)
	if(I.sharp)
		new /obj/item/stack/medical/bruise_pack(user.drop_location())
		user.visible_message("[user] cuts the special bandages from [src] into pieces of normal bandages with [I].", \
					 "<span class='notice'>You cut the special bandages from [src] into pieces of bandages with [I].</span>", \
					 "<span class='italics'>You hear cutting.</span>")
		use(1)
	else
		return ..()

/obj/item/stack/medical/quickclot/survivalqc
	name = "survival quikclot gauze kit"
	icon_state = "quickclot_surv"
	other_delay = 40
	amount = 2
