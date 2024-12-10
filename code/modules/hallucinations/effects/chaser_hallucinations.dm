/**
  * # Hallucination - Space Carp
  */
/obj/effect/hallucination/chaser/attacker/space_carp
	hallucination_icon = 'icons/mob/carp.dmi'
	hallucination_icon_state = "base"
	duration = 30 SECONDS
	damage = 25

/obj/effect/hallucination/chaser/attacker/space_carp/Initialize(mapload, mob/living/carbon/hallucination_target)
	. = ..()
	name = "space carp"

/obj/effect/hallucination/chaser/attacker/space_carp/attack_effects()
	do_attack_animation(target, ATTACK_EFFECT_BITE)
	target.playsound_local(get_turf(src), 'sound/weapons/bite.ogg', 50, TRUE)
	to_chat(target, "<span class='userdanger'>[name] bites you!</span>")

/obj/effect/hallucination/chaser/attacker/space_carp/on_knockdown()
	target.visible_message("<span class='warning'>[target] recoils as if hit by something, before suddenly collapsing!</span>", "<span class='userdanger'>[name] bites you!</span>")

/**
  * # Hallucination - Green Terror Spider
  */
/obj/effect/hallucination/chaser/attacker/terror_spider
	hallucination_icon = 'icons/mob/terrorspider.dmi'
	hallucination_icon_state = "terror_green"
	duration = 30 SECONDS
	damage = 25

/obj/effect/hallucination/chaser/attacker/terror_spider/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	name = "Green Terror spider ([rand(100, 999)])"

/obj/effect/hallucination/chaser/attacker/terror_spider/attack_effects()
	do_attack_animation(target, ATTACK_EFFECT_BITE)
	target.playsound_local(get_turf(src), 'sound/weapons/bite.ogg', 50, TRUE)
	to_chat(target, "<span class='userdanger'>[name] bites you!</span>")

/obj/effect/hallucination/chaser/attacker/terror_spider/on_knockdown()
	target.visible_message("<span class='warning'>[target] recoils as if hit by something, before suddenly collapsing!</span>",
						"<span class='userdanger'>[name] bites you!</span>")

/**
  * # Hallucination - Abductor Agent
  */
/obj/effect/hallucination/chaser/attacker/abductor
	hallucination_icon = 'icons/mob/simple_human.dmi'
	hallucination_icon_state = "abductor_agent"
	duration = 45 SECONDS
	damage = 100
	/// The hallucination that spawned us.
	var/obj/effect/hallucination/abduction/owning_hallucination = null

/obj/effect/hallucination/chaser/attacker/abductor/Initialize(mapload, mob/living/carbon/target)
	. = ..()
	name = "Unknown"

/obj/effect/hallucination/chaser/attacker/abductor/attack_effects()
	do_attack_animation(target)
	target.playsound_local(get_turf(src), 'sound/weapons/egloves.ogg', 50, TRUE)

/obj/effect/hallucination/chaser/attacker/abductor/on_knockdown()
	target.visible_message("<span class='warning'>[target] recoils as if hit by something, before suddenly collapsing!</span>",
						"<span class='userdanger'>[name] has stunned you with the advanced baton!</span>")
	if(!QDELETED(owning_hallucination))
		owning_hallucination.spawn_scientist()
	else
		qdel(src)

/**
  * # Hallucination - Random Hostile Humanoid
  */
/obj/effect/hallucination/chaser/attacker/assaulter
	duration = 30 SECONDS
	damage = 40
	/// The attack verb to display.
	var/attack_verb = "punches"
	/// The attack sound to play. Can be a file or text (passed to [/proc/get_sfx]).
	var/attack_sound = "punch"

/obj/effect/hallucination/chaser/attacker/assaulter/Initialize(mapload, mob/living/carbon/target)
	var/new_name
	// 80% chance to use a simple human sprite
	if(prob(80))
		new_name = "Unknown"
		hallucination_icon = 'icons/mob/simple_human.dmi'
		hallucination_icon_state = pick("arctic_skeleton", "templar", "skeleton", "sovietmelee", "piratemelee", "plasma_miner_tool", "cat_butcher", "syndicate_space_sword", "syndicate_stormtrooper_sword", "zombie", "scary_clown")

		// Adjust the attack verb and sound depending on the "mob"
		switch(hallucination_icon_state)
			if("arctic_skeleton", "templar", "sovietmelee", "plasma_miner_tool")
				attack_verb = "slashed"
				attack_sound = 'sound/weapons/bladeslice.ogg'
			if("cat_butcher")
				attack_verb = "sawed"
				attack_sound = 'sound/weapons/circsawhit.ogg'
			if("piratemelee", "syndicate_space_sword", "syndicate_stormtrooper_sword")
				attack_verb = "slashed"
				attack_sound = 'sound/weapons/blade1.ogg'

	// If nothing else we'll stay a monke
	. = ..()
	name = new_name || name

/obj/effect/hallucination/chaser/attacker/assaulter/attack_effects()
	do_attack_animation(target)
	target.playsound_local(get_turf(src), istext(attack_sound) ? get_sfx(attack_sound) : attack_sound, 25, TRUE)
	to_chat(target, "<span class='userdanger'>[name] has [attack_verb] [target]!</span>")

/obj/effect/hallucination/chaser/attacker/assaulter/on_knockdown()
	target.visible_message("<span class='warning'>[target] recoils as if hit by something, before suddenly collapsing!</span>",
						"<span class='userdanger'>[name] has [attack_verb] [target]!</span>")
	QDEL_IN(src, 3 SECONDS)
