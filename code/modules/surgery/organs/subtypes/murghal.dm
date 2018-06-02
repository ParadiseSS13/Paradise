
#define MURGHAL_BOOST_HUNGERCOST 40.5
#define MURGHAL_BOOST_MINHUNGER 150

/obj/item/organ/internal/adrenal
	name = "Adrenaline Gland"
	desc = "Specialized gland that convert nutriment into adrenaline directly into the bloodstream."
	icon = 'icons/obj/surgery_murghal.dmi'
	icon_state = "adrenal_gland"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_TINY
	parent_organ = "groin"
	slot = "gland"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/speeding = 0
	var/cooldown = 0

/obj/item/organ/internal/adrenal/ui_action_click()
	if(toggle_boost())
		if(speeding)
			owner.visible_message("<span class='notice'>[owner] crouches a little!</span>", "<span class='notice'>You get ready to sprint.</span>")
		else
			owner.visible_message("<span class='notice'>[owner] assumes a normal standing position.</span>", "<span class='notice'>You relax your muscles.</span>")
			cooldown = 1
			spawn(1200)
				cooldown = 0

/obj/item/organ/internal/adrenal/on_life()
	..()
	if(speeding)//i hate this but i couldnt figure out a better way
		if(owner.nutrition < MURGHAL_BOOST_MINHUNGER)
			toggle_boost(1)
			to_chat(owner, "<span class='warning'>You are too tired to sprint!</span>")
			return

		if(owner.stat)
			toggle_boost(1)
			owner.visible_message("<span class='notice'>[owner] assumes a normal standing position.</span>")
			return

		owner.nutrition = max(owner.nutrition - MURGHAL_BOOST_HUNGERCOST, MURGHAL_BOOST_HUNGERCOST)

	return

/obj/item/organ/internal/adrenal/on_owner_death()
	if(speeding)
		toggle_boost(1)

/obj/item/organ/internal/adrenal/proc/toggle_boost(statoverride)
	if(!statoverride && owner.incapacitated())
		to_chat(owner, "<span class='warning'>You cannot sprint in your current state.</span>")
		return 0

	if(!statoverride && owner.nutrition < MURGHAL_BOOST_MINHUNGER)
		to_chat(owner, "<span class='warning'>You are too tired to sprint, eat something!</span>")
		return 0

	if(cooldown)
		to_chat(owner, "<span class='warning'>You are still exhausted from the last sprint, you will need to wait a bit longer!</span>")
		return 0


	if(!speeding)
		owner.status_flags |= GOTTAGOFAST
		speeding =1
		return 1

	else
		owner.status_flags &= ~GOTTAGOFAST
		speeding = 0
		return 1

/obj/item/organ/internal/adrenal/remove(mob/living/carbon/M, special = 0)
	if(ishuman(M))

		if(speeding)
			toggle_boost(1)

	. = ..()

#undef MURGHAL_BOOST_HUNGERCOST
#undef MURGHAL_BOOST_MINHUNGER