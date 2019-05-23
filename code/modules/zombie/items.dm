/obj/item/zombie_hand
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
		unconscious or dead humans, butchering all other living things to \
		sustain the zombie, forcing open airlock doors and opening \
		child-safe caps on bottles."
	flags = NODROP|ABSTRACT
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	var/icon_left = "bloodhand_left"
	var/icon_right = "bloodhand_right"
	force = 25
	damtype = "brute"

/obj/item/zombie_hand/equipped(mob/user, slot)
	. = ..()
	switch(slot)
		// Yes, these intentionally don't match
		if(slot_l_hand)
			icon_state = icon_right
		if(slot_r_hand)
			icon_state = icon_left

/obj/item/zombie_hand/dropped(mob/user)
	. = ..()
	// Zombie hands are force dropped upon species loss
	qdel(src)

/obj/item/zombie_hand/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
		
	else if(isliving(target))
		if(ishuman(target))
			check_infection(target, user)
		else
			check_feast(target, user)

/obj/item/zombie_hand/proc/check_infection(var/mob/living/carbon/human/target, var/mob/user)
	var/mob/living/carbon/human/T = target
	if(NOZOMBIE in T.dna.species.species_traits)
		// cannot infect any NOZOMBIE subspecies (such as high functioning
		// zombies)
		return

	var/obj/item/organ/internal/zombie_infection/infection
	infection = target.get_organ_slot("zombie_infection")
	if(!infection)
		if (T.InCritical() || (!T.check_death_method() && T.health <= HEALTH_THRESHOLD_DEAD))
			infection = new(target)

/obj/item/zombie_hand/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		var/hp_gained = target.maxHealth
		target.gib()
		user.adjustBruteLoss(-hp_gained)
		user.adjustToxLoss(-hp_gained)
		user.adjustFireLoss(-hp_gained)
		user.adjustCloneLoss(-hp_gained)
		user.adjustBrainLoss(-hp_gained) // Zom Bee gibbers "BRAAAAISNSs!1!"

/obj/item/zombie_hand/suicide_act(mob/living/carbon/human/user)
	// Suiciding as a zombie brings someone else in to play it
	user.visible_message("<span class='suicide'>[user] is lying down.</span>")
	if(!istype(user))
		return

	user.Weaken(30)
	var/success = offer_control(user)
	if(success)
		user.visible_message("<span class='suicide'>[user] appears to have \
			found new spirit.</span>")
		return SHAME
	else
		user.visible_message("<span class='suicide'>[user] stops moving.\
			</span>")
		return OXYLOSS