/datum/martial_art/bearserk
	weight = 7 // Higher weight as much like Krav-Maga, the Pelt can be taken off
	name = "Rage of the Space Bear"
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/bearserk/bear_jaws, /datum/martial_combo/bearserk/paw_slam, /datum/martial_combo/bearserk/smokey)

/datum/martial_art/bearserk/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("punches", "claws", "hits", "mauls")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>",
					"<span class='userdanger'>[A] [atk_verb] you!</span>")
	D.apply_damage(rand(15, 20), BRUTE, A.zone_selected)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, TRUE, -1)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	return TRUE

/datum/martial_art/bearserk/explaination_header(user)
	to_chat(usr, "<b><i>Quelling the ursine rage for a moment, you ponder the attacks of the Space Bear...</i></b>")
	
/datum/martial_art/bearserk/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	if(HAS_TRAIT(H, TRAIT_PACIFISM))
		to_chat(H, "<span class='warning'>You feel rage briefly flicker in your mind, before you reject such violent thoughts and calm down. \
		At least the durable, weighty pelt still protects your body.</span>")
		return
	to_chat(H, "<span class='userdanger'>Like a berserker of old, you harness the Rage of the Space Bear!</span>")
	to_chat(H, "<span class='warning'>Ursine might flows through your body, making you far more dangerous in unarmed combat. \
	You can learn more about this newfound strength in the Recall Teachings verb in the martial arts tab.</span>")


/datum/martial_art/bearserk/remove(mob/living/carbon/human/H)
	..()
	to_chat(H, "<span class = 'sciradio'>The fury of the bears leaves your mind...</span>")
		
// The Pelt

/obj/item/clothing/head/bearpelt/bearserk
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	item_state = "bearpelt"
	flags = BLOCKHAIR
	armor = list(MELEE = 40, BULLET = 20, LASER = 20, ENERGY = 10, BOMB = 10, RAD = 0, FIRE = 25, ACID = 25)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|HEAD|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|HEAD|ARMS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	var/datum/martial_art/bearserk/style = new

/obj/item/clothing/head/bearpelt/bearserk/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_head)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
		H.faction |= "russian" // Insert Russian Hardbass
		
/obj/item/clothing/head/bearpelt/bearserk/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_head) == src)
		style.remove(H)
		H.faction -= "russian" // Hardbass stops

/obj/item/clothing/head/bearpelt/bearserk/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='warning'>Wearing this armored pelt grants you the strength of the Science department's greatest menace, the space bear. \
		It also makes wild bears neutral towards you, and Russians for some reason.</span>"
