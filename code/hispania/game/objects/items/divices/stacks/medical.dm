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
