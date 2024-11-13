/datum/martial_art/bearserk
	weight = 8 // Only beaten out by Carp-Fu, because being able to go back to using guns when you want to is OP
	name = "Rage of the Space Bear"
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/bearserk/bear_jaws, /datum/martial_combo/bearserk/paw_slam, /datum/martial_combo/bearserk/smokey)

/datum/martial_art/bearserk/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("punches", "claws", "hits", "mauls")
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", "<span class='userdanger'>[A] [atk_verb] you!</span>")
	D.apply_damage(10, BRUTE, A.zone_selected)
	if(isliving(D) && D.stat != DEAD)
		A.adjustStaminaLoss(-20)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	return TRUE

/datum/martial_art/bearserk/explaination_header(user)
	to_chat(user, "<b><i>Quelling the ursine rage for a moment, you ponder on how a Space Bear fights...</i></b>")

/datum/martial_art/bearserk/explaination_footer(user)
	to_chat(user, "<b>All combos recover stamina and grant a stamina resistance buff, so get aggressive!</b>")

/datum/martial_art/bearserk/teach(mob/living/carbon/human/H, make_temporary = 0)
	..()
	if(HAS_TRAIT(H, TRAIT_PACIFISM))
		to_chat(H, "<span class='warning'>You feel otherworldly rage flicker briefly in your mind, before you reject such violent thoughts and calm down. \
		At the very least, the weighty pelt still protects your body.</span>")
		return
	to_chat(H, "<span class='userdanger'>Like a berserker of old, you harness the Rage of the Space Bear!</span>")
	to_chat(H, "<span class='warning'>The occultic, ursine might and anger of Foh'Sie and Smoh'Kie flows through your body, making you far more dangerous in unarmed combat. \
	You can learn more about this newfound strength in the Recall Teachings verb in the martial arts tab.</span>")

/datum/martial_art/bearserk/remove(mob/living/carbon/human/H)
	..()
	to_chat(H, "<span class='sciradio'>The ancient fury of bears leaves your mind...</span>")

// The Pelt

/obj/item/clothing/head/bearpelt/bearserk
	strip_delay = 80
	armor = list(MELEE = 30, BULLET = 20, LASER = 20, ENERGY = 20, BOMB = 20, RAD = 0, FIRE = INFINITY, ACID = 75)
	resistance_flags = FIRE_PROOF
	body_parts_covered = UPPER_TORSO|HEAD|ARMS
	var/datum/martial_art/bearserk/style

/obj/item/clothing/head/bearpelt/bearserk/Initialize(mapload)
	. = ..()
	style = new()

/obj/item/clothing/head/bearpelt/bearserk/equipped(mob/user, slot)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(slot == ITEM_SLOT_HEAD)
		style.teach(H, TRUE)
		H.faction |= "soviet"
		H.physiology.stun_mod *= 0.80
		ADD_TRAIT(H, TRAIT_RESISTHEAT, "bearserk")

/obj/item/clothing/head/bearpelt/bearserk/dropped(mob/user, datum/reagent/R)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_HEAD) == src)
		style.remove(H)
		H.faction -= "soviet"
		H.physiology.stun_mod /= 0.80
		REMOVE_TRAIT (H, TRAIT_RESISTHEAT, "bearserk")

/obj/item/clothing/head/bearpelt/bearserk/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='warning'>Wearing this armored pelt grants you the strength of the space bear. \
		It also makes wild bears and wild communists neutral towards you.</span>"
