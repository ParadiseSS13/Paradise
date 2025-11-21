#define LOW_ATTRACTION_RANGE 2
#define MEDIUM_ATTRACTION_RANGE 4
#define HIGH_ATTRACTION_RANGE 6

/datum/disease/magnitis
	name = "Magnitis"
	max_stages = 4
	spread_text = "Airborne"
	cure_text = "Iron"
	cures = list("iron")
	agent = "Fukkos Miracos"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "This disease disrupts the magnetic field of your body, making it act as a powerful magnet. Injections of iron help stabilize the field."
	severity = VIRUS_DANGEROUS

/datum/disease/magnitis/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(1)
			if(prob(5)) // Water, air, fire and dirt! Fucking magnets, how do they work!?
				to_chat(affected_mob, "<span class='danger'>You query upon the nature of miracles...</span>")
		if(2)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel a light tingling sensation.</span>")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel a slight shock course through your body!</span>")
				magnetic_pull(affected_mob, LOW_ATTRACTION_RANGE, 0)
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel pins and needles radiating through you!</span>")
			if(prob(10))
				to_chat(affected_mob, "<span class='userdanger'>You feel a strong shock course through your body.</span>")
				magnetic_pull(affected_mob, MEDIUM_ATTRACTION_RANGE, 50)
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='userdanger'>You feel a thousand pinpricks across every inch of your body!</span>")
			if(prob(10))
				to_chat(affected_mob, "<span class='userdanger'>You feel a powerful shock course through your body!</span>")
				magnetic_pull(affected_mob, HIGH_ATTRACTION_RANGE, 100)

/**
* Handles magnitis pulling and throwing stuff.
* Arguments:
* * `affected_mob` - The magnitis-affected mob doing the pulling.
* * `pull_range` - How far the magnetic influence reaches.
* * `throw_chance` - Probability affected objects will be violently thrown at the `affected_mob` instead of being harmlessly pulled.
*/
/datum/disease/magnitis/proc/magnetic_pull(mob/living/affected_mob, pull_range, throw_chance)
	var/list/valid_pull_targets = list()
	for(var/atom/movable/A in orange(pull_range, affected_mob))
		if(!A.anchored && (A.flags & CONDUCT))
			valid_pull_targets |= A
			continue
		if((ismachineperson(A) || issilicon(A)))
			var/mob/living/M = A
			if(!M.anchored && !HAS_TRAIT(M, TRAIT_MAGPULSE))
				valid_pull_targets |= A

	for(var/atom/movable/attracted_body in valid_pull_targets)
		if(prob(throw_chance))
			attracted_body.throw_at(affected_mob, pull_range + 1, 1)
		else
			for(var/i in 1 to rand(1, 2))
				step_towards(attracted_body, affected_mob)

#undef LOW_ATTRACTION_RANGE
#undef MEDIUM_ATTRACTION_RANGE
#undef HIGH_ATTRACTION_RANGE
