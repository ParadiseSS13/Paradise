/datum/martial_art
	var/name = "Martial Art"
	var/streak = ""
	var/max_streak_length = 6
	var/current_target = null
	var/temporary = 0
	var/datum/martial_art/base = null // The permanent style
	var/deflection_chance = 0 //Chance to deflect projectiles
	var/block_chance = 0 //Chance to block melee attacks using items while on throw mode.
	var/restraining = 0 //used in cqc's disarm_act to check if the disarmed is being restrained and so whether they should be put in a chokehold or not
	var/help_verb = null
	var/no_guns = FALSE	//set to TRUE to prevent users of this style from using guns (sleeping carp, highlander). They can still pick them up, but not fire them.
	var/no_guns_message = ""	//message to tell the style user if they try and use a gun while no_guns = TRUE (DISHONORABRU!)

/datum/martial_art/proc/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/help_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	return 0

/datum/martial_art/proc/can_use(mob/living/carbon/human/H)
	return TRUE

/datum/martial_art/proc/add_to_streak(var/element,var/mob/living/carbon/human/D)
	if(D != current_target)
		current_target = D
		streak = ""
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak,2)
	return

/datum/martial_art/proc/basic_hit(var/mob/living/carbon/human/A,var/mob/living/carbon/human/D)

	var/damage = rand(A.dna.species.punchdamagelow, A.dna.species.punchdamagehigh)
	var/datum/unarmed_attack/attack = A.dna.species.unarmed

	var/atk_verb = "[pick(attack.attack_verb)]"
	if(D.lying)
		atk_verb = "kick"

	switch(atk_verb)
		if("kick")
			A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		else
			A.do_attack_animation(D, attack.animation_type)

	if(!damage)
		playsound(D.loc, attack.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] has attempted to [atk_verb] [D]!</span>")
		return 0

	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, attack.attack_sound, 25, 1, -1)
	D.visible_message("<span class='danger'>[A] has [atk_verb]ed [D]!</span>", \
								"<span class='userdanger'>[A] has [atk_verb]ed [D]!</span>")

	D.apply_damage(damage, BRUTE, affecting, armor_block)

	add_attack_logs(A, D, "Melee attacked with martial-art [src]", (damage > 0) ? null : ATKLOG_ALL)

	if((D.stat != DEAD) && damage >= A.dna.species.punchstunthreshold)
		D.visible_message("<span class='danger'>[A] has weakened [D]!!</span>", \
								"<span class='userdanger'>[A] has weakened [D]!</span>")
		D.apply_effect(4, WEAKEN, armor_block)
		D.forcesay(GLOB.hit_appends)
	else if(D.lying)
		D.forcesay(GLOB.hit_appends)
	return 1

/datum/martial_art/proc/teach(var/mob/living/carbon/human/H,var/make_temporary=0)
	if(help_verb)
		H.verbs += help_verb
	if(make_temporary)
		temporary = 1
	if(temporary)
		if(H.martial_art)
			base = H.martial_art.base
	else
		base = src
	H.martial_art = src

/datum/martial_art/proc/remove(var/mob/living/carbon/human/H)
	if(H.martial_art != src)
		return
	H.martial_art = base
	if(help_verb)
		H.verbs -= help_verb

//ITEMS

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_gloves)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_gloves) == src)
		style.remove(H)
	return

/obj/item/storage/belt/champion/wrestling
	name = "Wrestling Belt"
	var/datum/martial_art/wrestling/style = new

/obj/item/storage/belt/champion/wrestling/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_belt)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
		to_chat(user, "<span class='sciradio'>You have an urge to flex your muscles and get into a fight. You have the knowledge of a thousand wrestlers before you. You can remember more by using the Recall teaching verb in the wrestling tab.</span>")
	return

/obj/item/storage/belt/champion/wrestling/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_belt) == src)
		style.remove(H)
		to_chat(user, "<span class='sciradio'>You no longer have an urge to flex your muscles.</span>")
	return

/obj/item/plasma_fist_scroll
	name = "frayed scroll"
	desc = "An aged and frayed scrap of paper written in shifting runes. There are hand-drawn illustrations of pugilism."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/used = 0

/obj/item/plasma_fist_scroll/attack_self(mob/user as mob)
	if(!ishuman(user))
		return

	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/plasma_fist/F = new/datum/martial_art/plasma_fist(null)
		F.teach(H)
		to_chat(H, "<span class='boldannounce'>You have learned the ancient martial art of Plasma Fist.</span>")
		used = 1
		desc = "It's completely blank."
		name = "empty scroll"
		icon_state = "blankscroll"

/obj/item/sleeping_carp_scroll
	name = "mysterious scroll"
	desc = "A scroll filled with strange markings. It seems to be drawings of some sort of martial art."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"

/obj/item/sleeping_carp_scroll/attack_self(mob/living/carbon/human/user as mob)
	if(!istype(user) || !user)
		return
	if(user.mind && (user.mind.changeling || user.mind.vampire)) //Prevents changelings and vampires from being able to learn it
		if(user.mind && user.mind.changeling) //Changelings
			to_chat(user, "<span class ='warning'>We try multiple times, but we are not able to comprehend the contents of the scroll!</span>")
			return
		else //Vampires
			to_chat(user, "<span class ='warning'>Your blood lust distracts you too much to be able to concentrate on the contents of the scroll!</span>")
			return

	to_chat(user, "<span class='sciradio'>You have learned the ancient martial art of the Sleeping Carp! \
					Your hand-to-hand combat has become much more effective, and you are now able to deflect any projectiles directed toward you. \
					However, you are also unable to use any ranged weaponry. \
					You can learn more about your newfound art by using the Recall Teachings verb in the Sleeping Carp tab.</span>")


	var/datum/martial_art/the_sleeping_carp/theSleepingCarp = new(null)
	theSleepingCarp.teach(user)
	user.drop_item()
	visible_message("<span class='warning'>[src] lights up in fire and quickly burns to ash.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/CQC_manual
	name = "old manual"
	desc = "A small, black manual. There are drawn instructions of tactical hand-to-hand combat."
	icon = 'icons/obj/library.dmi'
	icon_state = "cqcmanual"

/obj/item/CQC_manual/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	to_chat(user, "<span class='boldannounce'>You remember the basics of CQC.</span>")

	var/datum/martial_art/cqc/CQC = new(null)
	CQC.teach(user)
	user.drop_item()
	visible_message("<span class='warning'>[src] beeps ominously, and a moment later it bursts up in flames.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/twohanded/bostaff
	name = "bo staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts. Can be wielded to both kill and incapacitate."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 24
	throwforce = 20
	throw_speed = 2
	attack_verb = list("smashed", "slammed", "whacked", "thwacked")
	icon_state = "bostaff0"
	block_chance = 50

/obj/item/twohanded/bostaff/update_icon()
	icon_state = "bostaff[wielded]"
	return

/obj/item/twohanded/bostaff/attack(mob/target, mob/living/user)
	add_fingerprint(user)
	if((CLUMSY in user.disabilities) && prob(50))
		to_chat(user, "<span class ='warning'>You club yourself over the head with [src].</span>")
		user.Weaken(3)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, "head")
		else
			user.take_organ_damage(2*force)
		return
	if(isrobot(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, "<span class='warning'>It would be dishonorable to attack a foe while [C.p_they()] cannot retaliate.</span>")
		return
	switch(user.a_intent)
		if(INTENT_DISARM)
			if(!wielded)
				return ..()
			if(!ishuman(target))
				return ..()
			var/mob/living/carbon/human/H = target
			var/list/fluffmessages = list("[user] clubs [H] with [src]!", \
										  "[user] smacks [H] with the butt of [src]!", \
										  "[user] broadsides [H] with [src]!", \
										  "[user] smashes [H]'s head with [src]!", \
										  "[user] beats [H] with front of [src]!", \
										  "[user] twirls and slams [H] with [src]!")
			H.visible_message("<span class='warning'>[pick(fluffmessages)]</span>", \
								   "<span class='userdanger'>[pick(fluffmessages)]</span>")
			playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, 1, -1)
			H.adjustStaminaLoss(rand(13,20))
			if(prob(10))
				H.visible_message("<span class='warning'>[H] collapses!</span>", \
									   "<span class='userdanger'>Your legs give out!</span>")
				H.Weaken(4)
			if(H.staminaloss && !H.sleeping)
				var/total_health = (H.health - H.staminaloss)
				if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
					H.visible_message("<span class='warning'>[user] delivers a heavy hit to [H]'s head, knocking [H.p_them()] out cold!</span>", \
										   "<span class='userdanger'>[user] knocks you unconscious!</span>")
					H.SetSleeping(30)
					H.adjustBrainLoss(25)
			return
		else
			return ..()
	return ..()

/obj/item/twohanded/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		return ..()
	return 0
