/*
 *Contains:
 * Creeping Widow martial art datum
 * Creeping Widow MMB override datum
 * Creeping Widow injector
 */


// Creeping Widow injector - Single use nanomachine thing that teaches people the creeping widow style.


/obj/item/weapon/creeping_widow_injector/
	name = "strange injector"
	desc = "A strange autoinjector made of a black metal.<br>You can see a green liquid through the glass."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "injector"
	attack_verb = list("poked", "prodded")
	var/used = 0

/obj/item/weapon/creeping_widow_injector/attack_self(mob/living/carbon/human/user as mob)
	if(!used)
		user.visible_message("<span class='warning'>You stick the [src]'s needle into your arm and press the button.", \
			  "<span class='warning'>[user] sticks the [src]'s needle \his arm and presses the button.")
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
	name = "Creeping Widow Style"
	var/list/attack_names = list("dragon", "eagle", "mantis", "tiger", "spider", "monkey", "snake", "crane", "xeno") // Fluff attack texts, used later in attack message generation.
	var/has_choke_hold = 0 	// Are we current choking a bitch?
	var/has_focus = 1		//Can we user our special moves?

/datum/martial_art/ninja_martial_art/teach(var/mob/living/carbon/human/H,var/make_temporary=0)
	..()
	H.middleClickOverride = new /datum/middleClickOverride/ninja_martial_art()
		to_chat(H, "You have been taugh the ways of the <i>Creeping Widow</i>.<br>\)
			Your stikes on harm intent will deal more damage.<br>Using middle mouse button on a nearby person while on harm intent will send them flying backwards.<br>\
			Your grabs will instantly be aggressive while you are using this style.<br>Using middle mouse button while on harm intent and behind a person will put them in a silencing choke hold.<br>\
			Using middle mouse button on a nearby person while on disarm intent will wrench their wrist, causing them to drop what they are holding.</span>"

/datum/martial_art/ninja_martial_art/proc/wrist_wrench(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		if(has_focus)
			has_focus = 0
			A.face_atom(D)
			D.visible_message("<span class='warning'>[A] grabs [D]'s wrist and wrenches it sideways!</span>", \
							  "<span class='userdanger'>[A] grabs your wrist and violently wrenches it to the side!</span>")
			playsound(get_turf(A), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			D.emote("scream")
			D.drop_item()
			D.apply_damage(5, BRUTE, pick("l_arm", "r_arm"))
			D.Stun(1)
			spawn(50) has_focus = 1
			return 1
		to_chat(A, "<span class='warning'>You are not focused enough to use that move yet!</span>")
		return 0
	return A.pointed(D)

/datum/martial_art/ninja_martial_art/proc/choke_hold(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		A.face_atom(D)
		if(A.dir != D.dir) // If the user's direction is not the same as the target's after A.face_atom(D) you are not behind them, and cannot use this ability.
			to_chat(A, "<span class='warning'>You cannot grab [D] from that angle!</span>")
			return 0

		if(has_choke_hold) // Are we already choking someone?
			to_chat(A, "<span class='warning'>You are have a target in your grip!</span>")
			return 0

		has_choke_hold = 1

		var/hold_name = "[pick(attack_names)] [pick("grip", "hold", "vise", "press")]"

		D.visible_message("<span class='warning'>[A] comes from behind and puts [D] in a [hold_name]!</span>", \
						  "<span class='userdanger'>[A]\ puts you in a [hold_name]! You are unable to speak!</span>")
		step_to(D,get_step(D,D.dir),1)

		D.grabbedby(A, 1)
		var/obj/item/weapon/grab/G = A.get_active_hand()
		if(G)
			G.state = GRAB_NECK

		var/I = 0
		while(I < 20) // Loop to process the silence for the person being strangled so we don't have to add 20 silence all at once.
			if(G == A.get_active_hand() && G.state >= GRAB_NECK) // Grab must be in the user's active hand for the duration of the strangle.
				D.silent += 1
				D.adjustOxyLoss(1)
			else
				D.visible_message("<span class='warning'>[A] loses his grip on [D]'s neck!</span>", \
									"<span class='userdanger'>[A] loses his grip on your neck!</span>")
				has_choke_hold = 0
				return 0
			I++
			sleep(5)

		to_chat(A, "<span class='warning'>You feel [D] go limp in your grip.</span>")
		to_chat(D, "<span class='userdanger'>You feel your consciousness slip away as [A] strangles you!</span>")
		D.AdjustParalysis(20)

		has_choke_hold = 0

		return 1
	return A.pointed(D)

/datum/martial_art/ninja_martial_art/proc/palm_strike(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(!D.stat && !D.weakened)
		if(has_focus)
			has_focus = 0
			A.face_atom(D)

			var/strike_adjective = pick(attack_names)
			D.visible_message("<span class='danger'>[A] sends [D] flying backwards with a [strike_adjective] palm strike!</span>", \
				"<span class='userdanger'>[A] delivers a [strike_adjective] palm strike to you and sends you flying!</span>")

			var/atom/throw_target = get_ranged_target_turf(D, get_dir(D, get_step_away(D, A)), 3) // Get a turf 3 tiles away from the target relative to our direction from him.
			D.throw_at(throw_target, 200, 4) // Throw the poor bastard at the target we just gabbed.

			D.Weaken(2)
			playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
			spawn(50) has_focus = 1
			return 1
		to_chat(A, "<span class='warning'>You are not focused enough to use that move yet!</span>")
		return 0
	return A.pointed(D)

/datum/martial_art/ninja_martial_art/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D) //Instant aggressive grab
	D.grabbedby(A)
	var/obj/item/weapon/grab/G = A.get_active_hand()
	if(G)
		G.state = GRAB_AGGRESSIVE

	return 1

/datum/martial_art/ninja_martial_art/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D) // 10 damage punches
	var/strike_name = "[pick(attack_names)] [pick("punches", "kicks", "chops", "slams", "strikes")]"
	D.visible_message("<span class='danger'>[A] [strike_name] on [D]!</span>", \
					  "<span class='userdanger'>[A] [strike_name] you!</span>")
	D.apply_damage(10, BRUTE)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
	return 1

// Ninja middle click override, required for the special moves to function and handled in grant_ninja_martial_art

/datum/middleClickOverride/ninja_martial_art

/datum/middleClickOverride/ninja_martial_art/onClick(var/atom/A, var/mob/living/carbon/human/user)
	if(!istype(user.martial_art, /datum/martial_art/ninja_martial_art))
		user.pointed(A) // If they don't have the required martial art just point at the target.

	if(!istype(A, /mob/living/carbon/human)) // Special moves only work on humans.
		user.pointed(A)
		return 0
	if(user.a_intent == "help") // No special move for help intent.
		user.pointed(A)
		return 0
	if(!(A in range(1,user))) // Is the target within one tile of us?
		user.pointed(A)
		return 0

	var/datum/martial_art/ninja_martial_art/user_martial_art = user.martial_art
	var/mob/living/carbon/human/target = A

	switch(user.a_intent)
		if("disarm")
			user_martial_art.wrist_wrench(user, target)
		if("grab")
			user_martial_art.choke_hold(user, target)
		if("harm")
			user_martial_art.palm_strike(user, target)
	return 1