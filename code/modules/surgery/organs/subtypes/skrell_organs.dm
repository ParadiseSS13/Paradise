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
	parent_organ = "head"
	slot = "headpocket"
	actions_types = list(/datum/action/item_action/organ_action/toggle/headpocket)
	var/obj/item/held_item

/datum/action/item_action/organ_action/toggle/headpocket
	button_icon_state = "skrell_headpocket_in"

/obj/item/organ/internal/headpocket/proc/update_button_state()
	for(var/datum/action/item_action/T in actions)
		T.button_icon_state = "skrell_headpocket[held_item ? "_out" : "_in"]"
		T.build_all_button_icons()

/obj/item/organ/internal/headpocket/Destroy()
	empty_contents()
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
		update_button_state()
	else
		var/obj/item/I = owner.get_active_hand()
		if(!I)
			to_chat(owner, "<span class='notice'>You're not holding anything in your main hand to put in your [name].</span>")
			return
		if(istype(I, /obj/item/disk/nuclear))
			to_chat(owner, "<span class='warning'>[I] slips out of your [name]!</span>")
			return
		if(I.w_class > WEIGHT_CLASS_SMALL)
			to_chat(owner, "<span class='notice'>[I] is too large to fit in your [name].</span>")
			return
		if(owner.unequip(I))
			owner.visible_message("<span class='notice'>[owner] places [I] into [owner.p_their()] [name].</span>", "<span class='notice'>You place [I] into your [name].</span>")
			I.forceMove(src)
			held_item = I
			update_button_state()

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
	if(held_item)
		held_item.emp_act(severity)
	..()

/obj/item/organ/internal/headpocket/hear_talk(mob/living/M, list/message_pieces)
	if(held_item)
		held_item.hear_talk(M, message_pieces)
	..()

/obj/item/organ/internal/headpocket/hear_message(mob/living/M, msg)
	if(held_item)
		held_item.hear_message(M, msg)
	..()

/obj/item/organ/internal/heart/skrell
	name = "skrell heart"
	desc = "A stream lined heart."
	icon = 'icons/obj/species_organs/skrell.dmi'

/obj/item/organ/internal/brain/skrell
	icon = 'icons/obj/species_organs/skrell.dmi'
	desc = "A brain with a odd division in the middle."
	mmi_icon = 'icons/obj/species_organs/skrell.dmi'

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
