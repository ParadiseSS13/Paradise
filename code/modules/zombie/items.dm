/obj/item/zombie_hand
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
		unconscious or dead humans, butchering all other living things to \
		sustain the zombie, forcing open airlock doors and opening \
		child-safe caps on bottles."
	flags = NODROP|ABSTRACT|DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	var/icon_left = "bloodhand_left"
	var/icon_right = "bloodhand_right"
	hitsound = 'sound/hallucinations/growl1.ogg'
	force = 21 // Just enough to break airlocks with melee attacks
	damtype = "brute"

/obj/item/zombie_hand/equipped(mob/user, slot)
	. = ..()
	switch(slot)
		// Yes, these intentionally don't match
		if(slot_l_hand)
			icon_state = icon_right
		if(slot_r_hand)
			icon_state = icon_left

/obj/item/zombie_hand/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return

	else if(isliving(target))
		if(ishuman(target))
			try_to_zombie_infect(target)
		else
			check_feast(target, user)

/proc/try_to_zombie_infect(mob/living/carbon/human/target)
	CHECK_DNA_AND_SPECIES(target)

	if(NOZOMBIE in target.dna.species.species_traits)
		// cannot infect any NOZOMBIE subspecies (such as high functioning
		// zombies)
		return

	var/obj/item/organ/internal/zombie_infection/infection
	infection = target.get_organ_slot("zombie_infection")
	if(!infection)
		infection = new()
		infection.insert(target)

/obj/item/zombie_hand/proc/check_feast(mob/living/target, mob/living/user)
	if(target.stat == DEAD)
		var/hp_gained = target.maxHealth
		target.gib()
		user.adjustBruteLoss(-hp_gained, FALSE)
		user.adjustToxLoss(-hp_gained, FALSE)
		user.adjustFireLoss(-hp_gained, FALSE)
		user.adjustCloneLoss(-hp_gained, FALSE)
		user.adjustBrainLoss(-hp_gained, FALSE) // Zom Bee gibbers "BRAAAAISNSs!1!"
		user.updatehealth()

/obj/item/zombie_hand/suicide_act(mob/living/carbon/human/user)
	user.visible_message("<span class='suicide'>[user] is ripping [user.p_their()] brains out! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/L = user
		var/obj/item/organ/external/O = L.get_organ("head")
		if(O)
			O.droplimb()
	return (BRUTELOSS)