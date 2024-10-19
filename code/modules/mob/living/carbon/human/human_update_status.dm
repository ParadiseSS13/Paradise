/mob/living/carbon/human/update_stat(reason = "none given")
	if(status_flags & GODMODE)
		return
	..(reason)
	if(stat == DEAD)
		if(dna.species && dna.species.can_revive_by_healing)  // Here's where IPC revival is handled
			var/obj/item/organ/internal/brain/B = get_int_organ(/obj/item/organ/internal/brain)
			if(B)
				if((health >= (HEALTH_THRESHOLD_DEAD + HEALTH_THRESHOLD_CRIT) * 0.5) && ipc_vital_organ_check() && !suiciding)
					var/mob/dead/observer/ghost = get_ghost()
					if(ghost)
						to_chat(ghost, "<span class='ghostalert'>Your chassis has been repaired and repowered, re-enter if you want to continue playing!</span> (Verbs -> Ghost -> Re-enter corpse)")
						SEND_SOUND(ghost, sound('sound/effects/genetics.ogg'))
					update_revive()
					create_debug_log("revived from healing, trigger reason: [reason]")

/mob/living/carbon/human/update_nearsighted_effects()
	var/obj/item/clothing/glasses/G = glasses
	if(HAS_TRAIT(src, TRAIT_NEARSIGHT) && (!istype(G) || !G.prescription))
		overlay_fullscreen("nearsighted", /atom/movable/screen/fullscreen/stretch/impaired, 1)
	else
		clear_fullscreen("nearsighted")


/mob/living/carbon/human/can_hear()
	. = TRUE // Fallback if we don't have a species
	if(dna.species)
		. = dna.species.can_hear(src)

/mob/living/carbon/human/check_death_method()
	return dna.species.dies_at_threshold
