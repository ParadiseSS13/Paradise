/obj/item/organ/internal/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and viscera."
	parent_organ = "head"
	slot = "zombie_infection"
	icon_state = "blacktumor"
	var/causes_damage = TRUE
	var/datum/species/old_species = /datum/species/human
	var/living_transformation_time = 30
	var/converts_living = FALSE

	var/revive_time_min = 450
	var/revive_time_max = 700
	var/timer_id

/obj/item/organ/internal/zombie_infection/New(mob/living/carbon/holder)
	..()
	GLOB.zombie_infection_list += src

/obj/item/organ/internal/zombie_infection/Destroy()
	GLOB.zombie_infection_list -= src
	. = ..()

/obj/item/organ/internal/zombie_infection/insert(mob/living/carbon/human/M, special = 0)
	..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/internal/zombie_infection/remove(mob/living/carbon/human/M, special = 0)
	STOP_PROCESSING(SSobj, src)
	if(iszombie(M) && old_species)
		M.set_species(old_species, retain_damage = TRUE)
	if(timer_id)
		deltimer(timer_id)
	. = ..()

/obj/item/organ/internal/zombie_infection/on_find(mob/living/finder)
	to_chat(finder, "<span class='warning'>Inside the head is a disgusting black \
		web of pus and viscera, bound tightly around the brain like some \
		biological harness.</span>")

/obj/item/organ/internal/zombie_infection/process()
	if(!owner)
		return
	if(!(src in owner.internal_organs))
		remove(owner)
	if(causes_damage && !iszombie(owner) && owner.stat != DEAD)
		owner.adjustToxLoss(1)
		if (prob(10))
			to_chat(owner, "<span class='danger'>You feel sick...</span>")
	if(timer_id)
		return
	if(owner.suiciding)
		return
	if(owner.stat != DEAD && !converts_living)
		return
	if(!owner.get_int_organ(/obj/item/organ/internal/brain))
		return
	if(!iszombie(owner))
		to_chat(owner, "<span class='cultlarge'>You can feel your heart stopping, but something isn't right... \
		life has not abandoned your broken form. You can only feel a deep and immutable hunger that \
		not even death can stop, you will rise again!</span>")
	var/revive_time = rand(revive_time_min, revive_time_max)
	var/flags = TIMER_STOPPABLE
	timer_id = addtimer(CALLBACK(src, .proc/zombify), revive_time, flags)

/obj/item/organ/internal/zombie_infection/proc/zombify()
	timer_id = null

	if(!converts_living && owner.stat != DEAD)
		return

	if(!iszombie(owner))
		old_species = owner.dna.species.type
		owner.set_species(/datum/species/zombie/infectious)
		for(var/datum/disease/critical/crit in owner.viruses) // cure any new crit viruses
			crit.cure(0)

	var/stand_up = (owner.stat == DEAD) || (owner.stat == UNCONSCIOUS)
	//Fully heal the zombie's damage the first time they rise
	owner.setToxLoss(0)
	owner.setOxyLoss(0)
	owner.setBrainLoss(0)
	owner.setCloneLoss(0)
	owner.SetLoseBreath(0)
	owner.heal_overall_damage(INFINITY, INFINITY, TRUE, TRUE, FALSE)
	owner.setStaminaLoss(0)

	if(!owner.update_revive())
		return

	owner.grab_ghost()
	owner.visible_message("<span class='danger'>[owner] suddenly convulses, as [owner.p_they()][stand_up ? " stagger to [owner.p_their()] feet and" : ""] gain a ravenous hunger in [owner.p_their()] eyes!</span>", "<span class='alien'>You HUNGER!</span>")
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, TRUE)
	owner.do_jitter_animation(living_transformation_time)
	owner.Stun(living_transformation_time * 0.05)
	to_chat(owner, "<span class='alertalien'>You are now a zombie! Do not seek to be cured, do not help any non-zombies in any way, do not harm your zombie brethren and spread the disease by killing others. You are a creature of hunger and violence.</span>")

/obj/item/organ/internal/zombie_infection/nodamage
	causes_damage = FALSE