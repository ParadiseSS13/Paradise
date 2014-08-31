/hook/death/proc/track_kills(mob/living/carbon/human/deceased, gibbed)
	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if (!mode) return 1

	mode.body_count+=deceased.mind
	return 1

/hook/clone/proc/update_icon(mob/living/carbon/human/H)
	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if (!mode) return 1

	mode.update_icon(H.mind)
	return 1

/hook/harvest_podman/proc/update_icon(mob/living/carbon/monkey/diona/D)
	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if (!mode) return 1

	mode.update_icon(D.mind)
	return 1

/hook/roundend/proc/report_mutiny_news()
	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if (!mode) return 1

	mode.round_outcome()
	return 1
