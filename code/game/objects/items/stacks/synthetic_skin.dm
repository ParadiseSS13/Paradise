/obj/item/stack/synthetic_skin
	name = "level-1 synthetic skin plate"
	desc = "A sheet of level-1 synthetic skin plating. Used as a cheap covering for cybernetic organs, is able to match the colour of the limb but not the texture."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "skin_1"
	w_class = WEIGHT_CLASS_SMALL
	singular_name = "skin plate"
	max_amount = 10
	merge_type = /obj/item/stack/synthetic_skin
	var/skin_level = 1

/obj/item/stack/synthetic_skin/attack__legacy__attackchain(mob/living/M as mob, mob/user as mob)
	if(!ishuman(M) || !istype(user))
		return FALSE
	var/mob/living/carbon/human/H = M
	var/obj/item/organ/external/external_limb = H.get_organ(user.zone_selected)
	if(external_limb)
		user.visible_message("<span class='notice'>[user] starts to apply [src] on [H]'s [external_limb.name]...</span>")
		if(!do_mob(user, H, 5 SECONDS))
			return FALSE
		use(1)
		if(external_limb.apply_augmented_skin(skin_level))
			user.visible_message("<span class='notice'>[user] applies some [src] on [H]'s [external_limb.name].</span>")
			return TRUE
		else
			to_chat(user, "<span class='warning'>You fail to apply a better skin cover to [H]'s [external_limb.name].</span>")
			return FALSE

/obj/item/stack/synthetic_skin/level_2
	name = "level-2 synthetic skin patch"
	desc = "A sealed patch of synthetic skin. An improvement over the basic version, more water resistant and less prone to peeling off."
	icon_state = "skin_2"
	merge_type = /obj/item/stack/synthetic_skin/level_2
	singular_name = "skin patch"
	skin_level = 2


/obj/item/stack/synthetic_skin/level_3
	name = "level-3 synthetic skin foam"
	desc = "A nanite foam injector meeting the requirements of level-3 synthetic skin. The best one can buy, best used to hide major cybernetic alterations, for beauty or for infiltration."
	icon_state = "skin_3"
	merge_type = /obj/item/stack/synthetic_skin/level_3
	singular_name = "nanite foam"
	skin_level = 3
