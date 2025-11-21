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
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You query upon the nature of miracles...</span>") // Fucking magnets, how do they work!?
		if(2) // Non-harmfully pull in metal stuff next to you.
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel a light tingling sensation.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You feel a slight shock course through your body!</span>")
				for(var/obj/O in orange(LOW_ATTRACTION_RANGE, affected_mob))
					if(!O.anchored && (O.flags & CONDUCT))
						step_towards(O,affected_mob)
				for(var/mob/living/silicon/S in orange(LOW_ATTRACTION_RANGE, affected_mob))
					if(is_ai(S))
						continue
					step_towards(S, affected_mob)
				for(var/mob/living/carbon/human/machine/M in orange(LOW_ATTRACTION_RANGE, affected_mob))
					step_towards(M, affected_mob)
		if(3) // 50/50 chance to non harmfully pull or have metal stuff thrown at you from further away.
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel pins and needles radiating through you!</span>")
			if(prob(4))
				to_chat(affected_mob, "<span class='userdanger'>You feel a strong shock course through your body.</span>")
				for(var/obj/O in orange(MEDIUM_ATTRACTION_RANGE, affected_mob))
					if(!O.anchored && (O.flags & CONDUCT))
						if(prob(50))
							for(i in 1 to rand(1, 2))
								step_towards(O,affected_mob)
						else
							O.throw_at(affected_mob, MEDIUM_ATTRACTION_RANGE + 1, 1)
				for(var/mob/living/silicon/S in orange(MEDIUM_ATTRACTION_RANGE, affected_mob))
					if(is_ai(S))
						continue
					if(prob(50))
						for(i in 1 to rand(1, 2))
							step_towards(S, affected_mob)
					else
						S.throw_at(affected_mob, MEDIUM_ATTRACTION_RANGE + 1, 1)
				for(var/mob/living/carbon/human/machine/M in orange(MEDIUM_ATTRACTION_RANGE, affected_mob))
					if(prob(50))
						var/i
						var/iter = rand(1,2)
						for(i=0,i<iter,i++)
							step_towards(M, affected_mob)
					else
						M.throw_at(affected_mob, MEDIUM_ATTRACTION_RANGE + 1, 1)
		if(4) // All metal stuff will be violently thrown at you from across the room.
			if(prob(10))
				to_chat(affected_mob, "<span class='userdanger'>You feel a thousand pinpricks across every inch of your body!</span>")
			if(prob(8))
				to_chat(affected_mob, "<span class='userdanger'>You feel a powerful shock course through your body!</span>")
				for(var/obj/O in orange(HIGH_ATTRACTION_RANGE, affected_mob))
					if(!O.anchored && (O.flags & CONDUCT))
						O.throw_at(affected_mob, HIGH_ATTRACTION_RANGE + 1, 1)
				for(var/mob/living/silicon/S in orange(HIGH_ATTRACTION_RANGE, affected_mob))
					if(is_ai(S))
						continue
					S.throw_at(affected_mob, HIGH_ATTRACTION_RANGE + 1, 1)
				for(var/mob/living/carbon/human/machine/M in orange(HIGH_ATTRACTION_RANGE, affected_mob))
					M.throw_at(affected_mob, HIGH_ATTRACTION_RANGE + 1, 1)

#undef LOW_ATTRACTION_RANGE
#undef MEDIUM_ATTRACTION_RANGE
#undef HIGH_ATTRACTION_RANGE
