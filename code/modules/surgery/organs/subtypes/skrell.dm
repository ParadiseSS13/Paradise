/obj/item/organ/internal/liver/skrell
	name = "skrell liver"
	icon = 'icons/obj/species_organs/skrell.dmi'
	alcohol_intensity = 4

/obj/item/organ/internal/headpocket
	name = "headpocket"
	desc = "Allows Skrell to hide tiny objects within their head tentacles."
	icon = 'icons/obj/species_organs/skrell.dmi'
	icon_state = "skrell_headpocket"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_SMALL
	parent_organ = "head"
	slot = "headpocket"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/obj/item/held_item

/obj/item/organ/internal/headpocket/Destroy()
	QDEL_NULL(held_item)
	return ..()

/obj/item/organ/internal/headpocket/on_life()
	..()
	var/obj/item/organ/external/head/head = owner.get_organ("head")
	if(held_item && !findtextEx(head.h_style, "Tentacles"))
		owner.visible_message("<span class='notice'>[held_item] falls from [owner]'s [name]!</span>", "<span class='notice'>[held_item] falls from your [name]!</span>")
		empty_contents()

/obj/item/organ/internal/headpocket/ui_action_click()
	if(held_item)
		owner.visible_message("<span class='notice'>[owner] removes [held_item] from [owner.p_their()] [name].</span>", "<span class='notice'>You remove [held_item] from your [name].</span>")
		owner.put_in_hands(held_item)
		held_item = null
	else
		var/obj/item/I = owner.get_active_hand()
		if(I && I.w_class <= WEIGHT_CLASS_SMALL && !istype(I, /obj/item/disk/nuclear) && owner.unEquip(I))
			owner.visible_message("<span class='notice'>[owner] places [I] into [owner.p_their()] [name].</span>", "<span class='notice'>You place [I] into your [name].</span>")
			I.forceMove(src)
			held_item = I

/obj/item/organ/internal/headpocket/on_owner_death()
	empty_contents()

/obj/item/organ/internal/headpocket/remove(mob/living/carbon/M, special = 0)
	empty_contents()
	. = ..()

/obj/item/organ/internal/headpocket/proc/empty_contents()
	if(held_item)
		held_item.forceMove(get_turf(owner))
		held_item = null

/obj/item/organ/internal/headpocket/emp_act(severity)
	held_item.emp_act(severity)
	..()

/obj/item/organ/internal/headpocket/hear_talk(mob/living/M, list/message_pieces)
	held_item.hear_talk(M, message_pieces)
	..()

/obj/item/organ/internal/headpocket/hear_message(mob/living/M, msg)
	held_item.hear_message(M, msg)
	..()

/obj/item/organ/internal/heart/skrell
	name = "skrell heart"
	desc = "A stream lined heart"
	icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/brain/skrell
	icon = 'icons/obj/species_organs/skrell.dmi'
	desc = "A brain with a odd division in the middle."
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/skrell.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/skrell
	name = "skrell lungs"
	icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/kidneys/skrell
	name = "skrell kidneys"
	icon = 'icons/obj/species_organs/skrell.dmi'
	desc = "The smallest kidneys you have ever seen, it probably doesn't even work."

/obj/item/organ/internal/eyes/skrell
	name = "skrell eyeballs"
	icon = 'icons/obj/species_organs/skrell.dmi'
