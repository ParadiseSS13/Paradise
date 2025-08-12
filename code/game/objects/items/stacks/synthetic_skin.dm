/obj/item/stack/synthetic_skin
	name = "level-1 synthetic skin"
	desc = "A roll of level-1 synthetic skin. Used as a cheap covering for cybernetic organs."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "skin_1"
	w_class = WEIGHT_CLASS_TINY
	singular_name = "globs of gobbly go" // qwertodo: once skin is sprited, find a proper singular name
	amount = 1
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
	name = "level-2 synthetic skin"
	desc = "A roll of level-2 synthetic skin. An improvement over the basic version, more water resistant and less prone to peeling off."
	icon_state = "skin_2"
	merge_type = /obj/item/stack/synthetic_skin/level_2
	skin_level = 2

/obj/item/stack/synthetic_skin/level_3
	name = "level-3 synthetic skin"
	desc = "A roll of level-3 synthetic skin. The best one can buy, best used to hide major cybernetic alterations, for beauty or for infiltration."
	icon_state = "skin_3"
	merge_type = /obj/item/stack/synthetic_skin/level_3
	skin_level = 3
