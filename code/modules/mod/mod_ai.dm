/obj/item/mod/control/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(!open) //mod must be open
		to_chat(user, "<span class='warning'>Suit must be open to transfer!</span>")
		return
	switch(interaction)
		if(AI_TRANS_TO_CARD)
			if(!ai)
				to_chat(user, "<span class='warning'>No AI in the suit!</span>")
				return
			to_chat(user, "<span class='notice'>Transferring to card...</span>")
			if(!do_after(user, 5 SECONDS, target = src))
				return
			if(!ai)
				return
			AI.aiRestorePowerRoutine = 0//So the AI initially has power.
			AI.control_disabled = TRUE
			AI.aiRadio.disabledAi = TRUE
			AI.forceMove(card)
			to_chat(AI, "You have been downloaded to a mobile storage device. Wireless connection offline.")
			to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) removed from [name] and stored within local memory.</span>")
			for(var/datum/action/action as anything in actions)
				action.Remove(AI)
			ai = null

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to the suit.
			var/mob/living/silicon/ai/AI2 = locate(/mob/living/silicon/ai) in card
			if(!AI2)
				to_chat(user, "<span class='warning'>No AI in the card!</span>")
				return
			if(ai)
				to_chat(user, "<span class='warning'>The suit already has an AI!</span>")
				return
			if(AI2.stat || !AI2.client)
				to_chat(user, "<span class='warning'>AI was unresponsive to upload protocols</span>")
				return
			to_chat(user, "<span class='notice'>Transferring to card...</span>")
			if(!do_after(user, 5 SECONDS, target = src))
				return
			if(ai)
				return
			AI2.control_disabled = FALSE
			AI2.aiRadio.disabledAi = FALSE
			ai_enter_mod(AI2)

/obj/item/mod/control/proc/ai_enter_mod(mob/living/silicon/ai/new_ai)
	new_ai.control_disabled = FALSE
	new_ai.aiRadio.disabledAi = FALSE
	new_ai.aiRestorePowerRoutine = 0//So the AI initially has power.
	new_ai.cancel_camera()
	new_ai.remote_control = src
	new_ai.forceMove(src)
	ai = new_ai
	for(var/datum/action/action as anything in actions)
		action.Grant(new_ai)

#define MOVE_DELAY 2
#define WEARER_DELAY 1
#define LONE_DELAY 5
#define CHARGE_PER_STEP (DEFAULT_CHARGE_DRAIN * 2.5)
#define AI_FALL_TIME (1 SECONDS)

/obj/item/mod/control/relaymove(mob/user, direction)
	if((!active && wearer) || get_charge() < CHARGE_PER_STEP  || user != ai || !COOLDOWN_FINISHED(src, cooldown_mod_move) || (wearer?.pulledby?.grab_state > GRAB_PASSIVE))
		return FALSE
	var/timemodifier = MOVE_DELAY * (ISDIAGONALDIR(direction) ? sqrt(2) : 1) * (wearer ? WEARER_DELAY : LONE_DELAY)
	if(wearer && !wearer.Process_Spacemove(direction))
		return FALSE
	else if(!wearer && (!has_gravity() || !isturf(loc)))
		return FALSE
	COOLDOWN_START(src, cooldown_mod_move, movedelay * timemodifier + slowdown_active)
	subtract_charge(CHARGE_PER_STEP)
	playsound(src, 'sound/mecha/mechmove01.ogg', 25, TRUE)
	if(ismovable(wearer?.loc))
		return wearer.loc.relaymove(wearer, direction)
	else if(wearer)
		ADD_TRAIT(wearer, TRAIT_FORCED_STANDING, MOD_TRAIT)
		addtimer(CALLBACK(src, PROC_REF(ai_fall)), AI_FALL_TIME, TIMER_UNIQUE | TIMER_OVERRIDE)
	var/atom/movable/mover = wearer || src
	return mover.try_step_multiz(direction)

#undef MOVE_DELAY
#undef WEARER_DELAY
#undef LONE_DELAY
#undef CHARGE_PER_STEP

/obj/item/mod/control/proc/ai_fall()
	if(!wearer)
		return
	REMOVE_TRAIT(wearer, TRAIT_FORCED_STANDING, MOD_TRAIT)

/obj/item/mod/ai_minicard
	name = "AI mini-card"
	desc = "A small card designed to eject dead AIs. You could use an intellicard to recover it."
	icon = 'icons/obj/aicards.dmi'
	icon_state = "minicard"
	var/stored_ai

/obj/item/mod/ai_minicard/Initialize(mapload, mob/living/silicon/ai/ai)
	. = ..()
	if(!ai)
		return
	ai.apply_damage(150, BURN)
	INVOKE_ASYNC(ai, TYPE_PROC_REF(/mob/living/silicon/ai, death))
	ai.forceMove(src)
	stored_ai = ai
	icon_state = "minicard-filled"

/obj/item/mod/ai_minicard/Destroy()
	QDEL_NULL(stored_ai)
	return ..()

/obj/item/mod/ai_minicard/examine(mob/user)
	. = ..()
	. += to_chat(user, "<span class='notice'>You see [stored_ai.resolve() || "no AI"] stored inside.</span>")

/obj/item/mod/ai_minicard/transfer_ai(interaction, mob/user, mob/living/silicon/ai/intAI, obj/item/aicard/card)
	. = ..()
	if(!.)
		return
	if(interaction != AI_TRANS_TO_CARD)
		return
	var/mob/living/silicon/ai/ai = stored_ai.resolve()
	if(!ai)
		to_chat(user, "<span class='warning'>No AI detected!</span>")
		return
	to_chat(user, "<span class='notice'>Transferring to card...</span>")
	if(!do_after(user, 5 SECONDS, target = src) || !ai)
		return
	icon_state = "minicard"
	ai.forceMove(card)
	ai.forceMove(card)
	ai.notify_ghost_cloning("You have been recovered from the wreckage!", source = card)
	stored_ai = null

#undef AI_FALL_TIME
