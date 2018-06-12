
#define MURGHAL_BOOST_HUNGERCOST 20
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
	var/sprint_treshold
	var/warning_treshold
	var/sprint_steps

/obj/item/organ/internal/adrenal/ui_action_click()
	if(toggle_boost())
		if(speeding)
			owner.visible_message("<span class='notice'>[owner] crouches a little!</span>", "<span class='notice'>You get ready to sprint.</span>")
			sprint_treshold = rand(30,50)
			warning_treshold = sprint_treshold - (rand(8,15))
			sprint_steps = owner.step_count
		else
			owner.visible_message("<span class='notice'>[owner] assumes a normal standing position.</span>", "<span class='notice'>You relax your muscles.</span>")
			cooldown = 1
			if(sprint_steps<= sprint_treshold)
				spawn(1200)
					cooldown = 0
			if(sprint_steps > sprint_treshold)
				to_chat(owner, "<span class='warning'>You feel extremely exhausted!</span>")
				spawn(2400)
					cooldown = 0

/obj/item/organ/internal/adrenal/on_life()
	..()
	if(speeding)//i hate this but i couldnt figure out a better way
		if(owner.nutrition < MURGHAL_BOOST_MINHUNGER)
			toggle_boost(1)
			sprint_treshold = 0
			warning_treshold = 0
			sprint_steps = 0
			owner.step_count =0
			to_chat(owner, "<span class='warning'>You are too tired to sprint!</span>")
			return

		if(sprint_steps >= sprint_treshold)
			to_chat(owner, "<span class='warning'>You legs are starting to hurt!</span>")
			owner.nutrition = max(owner.nutrition - MURGHAL_BOOST_HUNGERCOST*2, MURGHAL_BOOST_HUNGERCOST)
			owner.bruteloss = 5
			return

		if(sprint_steps >= warning_treshold)
			to_chat(owner, "<span class='warning'>You are getting tired!</span>")
			return

		if(owner.stat)
			toggle_boost(1)
			owner.visible_message("<span class='notice'>[owner] assumes a normal standing position.</span>")
			sprint_treshold = 0
			warning_treshold = 0
			sprint_steps = 0
			owner.step_count = 0
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
/*
var/mob/living/carbon/human/H = user
	var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
	var/obj/item/organ/external/affecting = H.get_organ(ran_zone(dam_zone))
	user.visible_message("<span class='warning'>[user] cuts open [user.p_their()] [affecting] and begins writing in [user.p_their()] own blood!</span>", "<span class='cult'>You slice open your [affecting] and begin drawing a sigil of [ticker.cultdat.entity_title3].</span>")
	user.apply_damage(initial(rune_to_scribe.scribe_damage), BRUTE , affecting)


var/mob/living/carbon/human/H = user
		if(H.getBrainLoss() >= 60 && Adjacent(user))
			playsound(loc, 'sound/effects/bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				visible_message("<span class='warning'>[user] headbutts the airlock.</span>")
				var/obj/item/organ/external/affecting = H.get_organ("head")
				H.Stun(5)
				H.Weaken(5)
				if(affecting.receive_damage(10, 0))
					H.UpdateDamageIcon()

					*/