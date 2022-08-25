//Just reformed /datum/component/squeak
/datum/component/jackboots
	var/static/list/step_sounds = list('sound/effects/jackboot1.ogg' = 1, 'sound/effects/jackboot2.ogg' = 1)
	// This is so shoes don't squeak every step
	var/steps = 0
	var/step_delay = 1
	// This is to stop squeak spam from inhand usage
	var/last_use = 0
	var/use_delay = 20
	///when sounds start falling off for the squeak
	var/sound_falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE
	///sound exponent for squeak. Defaults to 10 as squeaking is loud and annoying enough.
	var/sound_falloff_exponent = 10

/datum/component/jackboots/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(istype(parent, /obj/item/clothing/shoes))
		RegisterSignal(parent, COMSIG_SHOES_STEP_ACTION, .proc/step_sound)

/datum/component/jackboots/proc/step_sound()
	if(steps > step_delay)
		play_sound()
		steps = 0
	else
		steps++

/datum/component/jackboots/proc/play_sound()
	if(ismob(parent))
		var/mob/M = parent
		if(M.stat == DEAD)
			return
	playsound(parent, pickweight(step_sounds), 50, TRUE, 0, falloff_exponent = sound_falloff_exponent)
