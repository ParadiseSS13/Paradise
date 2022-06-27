#define MORPH_AMBUSH_PERFECTION_TIME 10 SECONDS

/obj/effect/proc_holder/spell/targeted/morph_spell/ambush
	name = "Prepare Ambush"
	desc = "Prepare an ambush. Dealing significantly more damage on the first hit and you will weaken the target. Only works while morphed. If the target tries to use you with their hands then you will do even more damage. \
	 		Keeping still for another 10 seconds will perfect your disguise."
	action_icon_state = "morph_ambush"
	charge_max = 8 SECONDS
	self_only = TRUE

/obj/effect/proc_holder/spell/targeted/morph_spell/ambush/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(!user.morphed)
		if(show_message)
			to_chat(user, "<span class='warning'>You can only prepare an ambush if you're disguised!</span>")
		return FALSE
	if(user.ambush_prepared)
		if(show_message)
			to_chat(user, "<span class='warning'>You are already prepared!</span>")
		return FALSE

/obj/effect/proc_holder/spell/targeted/morph_spell/ambush/cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	to_chat(user, "<span class='sinister'>You start preparing an ambush.</span>")
	if(!do_after(user, 6 SECONDS, FALSE, user, TRUE, list(CALLBACK(src, .proc/prepare_check, user)), FALSE))
		if(!user.morphed)
			to_chat(user, "<span class='warning'>You need to stay morphed to prepare the ambush!</span>")
			return
		to_chat(user, "<span class='warning'>You need to stay still to prepare the ambush!</span>")
		return
	user.prepare_ambush()

/obj/effect/proc_holder/spell/targeted/morph_spell/ambush/proc/prepare_check(mob/living/simple_animal/hostile/morph/user)
	return !user.morphed

/datum/status_effect/morph_ambush
	id = "morph_ambush"
	duration = -1
	tick_interval = MORPH_AMBUSH_PERFECTION_TIME
	alert_type = /obj/screen/alert/status_effect/morph_ambush

/datum/status_effect/morph_ambush/tick()
	STOP_PROCESSING(SSfastprocess, src)
	var/mob/living/simple_animal/hostile/morph/morph = owner
	morph.perfect_ambush()
	linked_alert.name = "Perfect Ambush!"
	linked_alert.desc = "You have prepared an ambush! Your disguise is flawless!"

/obj/screen/alert/status_effect/morph_ambush
	name = "Ambush!"
	desc = "You have prepared an ambush!"
	icon_state = "morph_ambush"

#undef MORPH_AMBUSH_PERFECTION_TIME
