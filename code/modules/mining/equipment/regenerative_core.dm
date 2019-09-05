/*********************Hivelord stabilizer****************/
/obj/item/hivelordstabilizer
	name = "hivelord stabilizer"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	desc = "Inject a hivelord core with this stabilizer to preserve its healing powers indefinitely."
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "biotech=3"

/obj/item/hivelordstabilizer/afterattack(obj/item/organ/internal/M, mob/user)
	. = ..()
	var/obj/item/organ/internal/regenerative_core/C = M
	if(!istype(C, /obj/item/organ/internal/regenerative_core))
		to_chat(user, "<span class='warning'>The stabilizer only works on certain types of monster organs, generally regenerative in nature.</span>")
		return ..()

	C.preserved()
	to_chat(user, "<span class='notice'>You inject the [M] with the stabilizer. It will no longer go inert.</span>")
	qdel(src)

/************************Hivelord core*******************/
/obj/item/organ/internal/regenerative_core
	name = "regenerative core"
	desc = "All that remains of a hivelord. It can be used to help keep your body going, but it will rapidly decay into uselessness."
	icon_state = "roro core 2"
	flags = NOBLUDGEON
	slot = "hivecore"
	force = 0
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/inert = 0
	var/preserved = 0

/obj/item/organ/internal/regenerative_core/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, .proc/inert_check), 2400)

/obj/item/organ/internal/regenerative_core/proc/inert_check()
	if(!preserved)
		go_inert()

/obj/item/organ/internal/regenerative_core/proc/preserved(implanted = 0)
	inert = FALSE
	preserved = TRUE
	update_icon()
	desc = "All that remains of a hivelord. It is preserved, allowing you to use it to heal completely without danger of decay."
	if(implanted)
		feedback_add_details("hivelord_core", "[type]|implanted")
	else
		feedback_add_details("hivelord_core", "[type]|stabilizer")

/obj/item/organ/internal/regenerative_core/proc/go_inert()
	inert = TRUE
	name = "decayed regenerative core"
	desc = "All that remains of a hivelord. It has decayed, and is completely useless."
	feedback_add_details("hivelord_core", "[src.type]|inert")
	update_icon()

/obj/item/organ/internal/regenerative_core/ui_action_click()
	if(inert)
		to_chat(owner, "<span class='notice'>[src] breaks down as it tries to activate.</span>")
	else
		owner.revive()
	qdel(src)

/obj/item/organ/internal/regenerative_core/on_life()
	..()
	if(owner.health < HEALTH_THRESHOLD_CRIT)
		ui_action_click()

///Handles applying the core, logging and status/mood events.
/obj/item/organ/internal/regenerative_core/proc/applyto(atom/target, mob/user)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(inert)
			to_chat(user, "<span class='notice'>[src] has decayed and can no longer be used to heal.</span>")
			return
		else
			if(H.stat == DEAD)
				to_chat(user, "<span class='notice'>[src] is useless on the dead.</span>")
				return
			if(H != user)
				H.visible_message("[user] forces [H] to apply [src]... Black tendrils entangle and reinforce [H.p_them()]!")
				feedback_add_details("hivelord_core","[src.type]|used|other")
			else
				to_chat(user, "<span class='notice'>You start to smear [src] on yourself. Disgusting tendrils hold you together and allow you to keep moving, but for how long?</span>")
				feedback_add_details("hivelord_core","[src.type]|used|self")
			H.revive()
			user.drop_item()
			qdel(src)

/obj/item/organ/internal/regenerative_core/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		applyto(target, user)

/obj/item/organ/internal/regenerative_core/attack_self(mob/user)
	applyto(user, user)

/obj/item/organ/internal/regenerative_core/insert(mob/living/carbon/M, special = 0)
	..()
	if(!preserved && !inert)
		preserved(TRUE)
		owner.visible_message("<span class='notice'>[src] stabilizes as it's inserted.</span>")

/obj/item/organ/internal/regenerative_core/remove(mob/living/carbon/M, special = 0)
	if(!inert && !special)
		owner.visible_message("<span class='notice'>[src] rapidly decays as it's removed.</span>")
		go_inert()
	return ..()

/obj/item/organ/internal/regenerative_core/prepare_eat()
	return null

/*************************Legion core********************/
/obj/item/organ/internal/regenerative_core/legion
	desc = "A strange rock that crackles with power. It can be used to heal completely, but it will rapidly decay into uselessness."
	icon_state = "legion_soul"

/obj/item/organ/internal/regenerative_core/legion/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/organ/internal/regenerative_core/legion/update_icon()
	icon_state = inert ? "legion_soul_inert" : "legion_soul"
	cut_overlays()
	if(!inert && !preserved)
		add_overlay("legion_soul_crackle")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/internal/regenerative_core/legion/go_inert()
	..()
	desc = "[src] has become inert. It has decayed, and is completely useless."

/obj/item/organ/internal/regenerative_core/legion/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. It is preserved, allowing you to use it to heal completely without danger of decay."