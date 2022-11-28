 /*
 *Contains:
 * Creeping Widow martial art datum
 * Creeping Widow MMB override datum
 * Creeping Widow injector
*/


// Creeping Widow injector - Single use nanomachine thing that teaches people the creeping widow style.


/obj/item/creeping_widow_injector
	name = "strange injector"
	desc = "A strange autoinjector made of a black metal.<br>You can see a green liquid through the glass."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "injector"
	attack_verb = list("poked", "prodded")
	var/used = 0

/obj/item/creeping_widow_injector/attack_self(mob/living/carbon/human/user as mob)
	if(!used)
		user.visible_message("<span class='warning'>You stick the [src]'s needle into your arm and press the button.", \
			  "<span class='warning'>[user] sticks the [src]'s needle [user.p_their()] arm and presses the button.")
		to_chat(user, "<span class='info'>The nanomachines in the [src] flow through your bloodstream.")

		var/datum/martial_art/ninja_martial_art/N = new/datum/martial_art/ninja_martial_art(null)
		N.teach(user)

		used = 1
		icon_state = "injector-used"
		desc = "A strange autoinjector made of a black metal.<br>It appears to be used up and empty."
		return 0
	else
		to_chat(user, "<span class='warning'>The [src] has been used already!</span>")
		return 1

// Ninja martial art datum

/datum/martial_art/ninja_martial_art
	name = "Creeping Widow"
	combos = list(	/datum/martial_combo/ninja_martial_art/energy_tornado,
					/datum/martial_combo/ninja_martial_art/palm_strike,
					/datum/martial_combo/ninja_martial_art/wrench_wrist,
					/datum/martial_combo/ninja_martial_art/neck_slice)
	has_explaination_verb = TRUE
	reflection_chance = 50
	var/obj/item/clothing/suit/space/space_ninja/my_suit
	var/obj/item/melee/energy_katana/my_energy_katana

	var/list/attack_names = list("dragon", "eagle", "mantis", "tiger", "spider", "monkey", "snake", "crane", "xeno") // Fluff attack texts, used later in attack message generation.
	var/has_focus = TRUE		//Can we use our special moves?

/datum/martial_art/ninja_martial_art/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	. = ..()
	to_chat(H, span_notice("You have been taught the ways of the <i>Creeping Widow!</i>.<br>\
		[span_green("To use your moves you must have focus!")] <br> Your focus passively regenerates over time.<br>\
		To learn more about it, check the Martial Arts tab."))

/datum/martial_art/ninja_martial_art/harm_act(var/mob/living/carbon/human/attacker, var/mob/living/carbon/human/defender)
	MARTIAL_ARTS_ACT_CHECK
	basic_hit(attacker,defender)
	return TRUE

/datum/martial_art/ninja_martial_art/disarm_act(var/mob/living/carbon/human/attacker, var/mob/living/carbon/human/defender)
	MARTIAL_ARTS_ACT_CHECK
	basic_hit(attacker,defender)
	return TRUE

/datum/martial_art/ninja_martial_art/grab_act(var/mob/living/carbon/human/attacker, var/mob/living/carbon/human/defender)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/grab_item = defender.grabbedby(attacker, 1)
	if(grab_item)
		grab_item.state = GRAB_AGGRESSIVE //Instant aggressive grab
		add_attack_logs(attacker, defender, "Melee attacked with martial-art [src] : aggressively grabbed")
	if(!defender.stat && !defender.weakened)
		if(attacker.dir == defender.dir && has_focus)
			has_focus = FALSE
			var/hold_name = "[pick(attack_names)] [pick("grip", "hold", "vise", "press")]"
			playsound(get_turf(attacker), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
			attacker.do_attack_animation(defender, ATTACK_EFFECT_PUNCH)
			defender.visible_message("<span class='warning'>[attacker] comes from behind, punches the [defender] in their neck and puts [defender] in a [hold_name]!</span>", \
							"<span class='userdanger'>[attacker]\ punches you in the neck and puts you in a [hold_name]! You are unable to speak!</span>")
			defender.silent += 20
			defender.adjustOxyLoss(20)
			defender.apply_damage(5, BRUTE, pick("head", "mouth"))
			addtimer(CALLBACK(src, .proc/regain_focus, attacker), 300)
	return TRUE

/datum/martial_art/ninja_martial_art/proc/regain_focus(user)
	to_chat(user, span_green("You regained your focus!"))
	has_focus = TRUE

//Проверяет наличие, катаны привязанной к искусству хотя бы в одной руке
/datum/martial_art/ninja_martial_art/proc/check_katana(mob/living/user)
	if(!my_energy_katana)
		return FALSE
	if(user.get_inactive_hand() == my_energy_katana)
		return TRUE
	if(user.get_active_hand() == my_energy_katana)
		return TRUE
	return FALSE

/datum/martial_art/ninja_martial_art/explaination_header(user)
	to_chat(user, "<b><i>You honor your clan and remember your teachings...</i></b>")

/datum/martial_art/ninja_martial_art/explaination_footer(user)
	to_chat(user, "<b><i>[span_green("To use your moves you must have focus!")] <br> Your focus passively regenerates over time.<br>\
		Your grabs will instantly be aggressive while you are using this style.<br>And if you are behind a person you will punch them in their neck, if you are focused.<br></i></b>")
