/datum/martial_art/judo
	name = "Corporate Judo"
	has_explaination_verb = TRUE
	no_baton = TRUE
	combos = list(/datum/martial_combo/judo/discombobulate, /datum/martial_combo/judo/eyepoke, /datum/martial_combo/judo/judothrow, /datum/martial_combo/judo/armbar, /datum/martial_combo/judo/wheelthrow)
	weight = 5 //takes priority over boxing and drunkneness, less priority than krav or CQC/carp
	no_baton_reason = "<span class='warning'>The baton feels off balance in your hand due to your judo training!</span>"
	can_horizontally_grab = FALSE

//Corporate Judo Belt

/obj/item/judobelt
	name = "\improper Corporate Judo Belt"
	desc = "Teaches the wearer NT Corporate Judo."
	icon = 'icons/obj/clothing/belts.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	icon_state = "judobelt"
	item_state = "judo"
	slot_flags = SLOT_FLAG_BELT
	flags_2 = ALLOW_BELT_NO_JUMPSUIT_2
	w_class = WEIGHT_CLASS_BULKY
	var/datum/martial_art/judo/style

/obj/item/judobelt/Initialize()
	. = ..()
	style = new()

/obj/item/judobelt/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == SLOT_HUD_BELT)
		var/mob/living/carbon/human/H = user
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(H, "<span class='warning'>The arts of Corporate Judo echo uselessly in your head, the thought of violence disgusts you!</span>")
			return
		style.teach(H, TRUE)
		to_chat(H, "<span class='userdanger'>The belt's nanites infuse you with the prowess of a black belt in Corporate Judo!</span>")
		to_chat(H, "<span class='danger'>See the martial arts tab for an explanation of combos.</span>")
		return

/obj/item/judobelt/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_HUD_BELT) == src)
		style.remove(H)
		to_chat(user, "<span class='sciradio'>You suddenly forget the arts of Corporate Judo...</span>")

//Increased harm damage
/datum/martial_art/judo/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/picked_hit_type = pick("chops", "slices", "strikes")
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	D.apply_damage(7, BRUTE)
	playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					"<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_attack_logs(A, D, "Melee attacked with [src]")
	return TRUE

/datum/martial_art/judo/grab_act(mob/living/carbon/human/attacker, mob/living/carbon/human/defender)
	if(IS_HORIZONTAL(attacker))
		return FALSE
	return ..()

/datum/martial_art/judo/explaination_header(user)
	to_chat(user, "<b><i>You recall the teachings of Corporate Judo.</i></b>")

/datum/martial_art/cqc/explaination_footer(user)
	to_chat(user, "<b>Your unarmed strikes hit about twice as hard as your peers, on average.</b>")

/datum/martial_art/judo/under_siege
	name = "Professional Bodyguarding"
	var/static/list/areas_under_siege = typecacheof(list(/area/station/service/kitchen, /area/station/service/bar))

/datum/martial_art/judo/under_siege/teach(mob/living/carbon/human/H, make_temporary)
	RegisterSignal(H, COMSIG_AREA_ENTERED, PROC_REF(bar_check))
	return ..()

/datum/martial_art/judo/under_siege/remove(mob/living/carbon/human/H)
	UnregisterSignal(H, COMSIG_AREA_ENTERED)
	return ..()

/datum/martial_art/judo/under_siege/proc/bar_check(mob/living/carbon/human/H, area/entered_area)
	SIGNAL_HANDLER
	if(!is_type_in_typecache(entered_area, areas_under_siege))
		var/list/held_items = list(H.get_active_hand(), H.get_inactive_hand())
		for(var/obj/item/slapper/parry/smacking_hand in held_items)
			qdel(smacking_hand)
		can_parry = FALSE
		weight = 0
	else
		can_parry = TRUE
		weight = 5

/datum/martial_art/judo/under_siege/can_use(mob/living/carbon/human/H)
	var/area/A = get_area(H)
	if(!(is_type_in_typecache(A, areas_under_siege)))
		return FALSE
	return ..()
