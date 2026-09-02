/datum/component/incursion_mob_death
	var/gib_delay = 2 MINUTES

/datum/component/incursion_mob_death/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(extra_death_effect))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(extra_death_effect))

/datum/component/incursion_mob_death/proc/extra_death_effect(datum/source)
	SIGNAL_HANDLER
	if(prob(95)) // Save some corpses for xenobio
		addtimer(CALLBACK(src, PROC_REF(delayed_gib)), gib_delay)

/datum/component/incursion_mob_death/proc/delayed_gib()
	var/mob/living/demon = parent
	new /obj/effect/temp_visual/demonic_grasp(demon.loc)
	demon.gib()
