/obj/item/organ/internal/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and viscera."
	parent_organ = "head"
	slot = "zombie_infection"
	icon_state = "blacktumor"
	var/causes_damage = TRUE
	var/datum/species/old_species = /datum/species/human
	var/living_transformation_time = 3
	var/revive_time_min = 450
	var/revive_time_max = 700
	var/timer_id
	var/dont_delete = FALSE // to prevent set_species proc in zombify from deleting the infection organ immediately

/obj/item/organ/internal/zombie_infection/New()
	. = ..()
	if(ishuman(owner) && !ismachine(owner) && !iszombie(owner.dna.species))
		old_species = owner.dna.species
	GLOB.zombie_infection_list += src

/obj/item/organ/internal/zombie_infection/Destroy()
	GLOB.zombie_infection_list -= src
	. = ..()

/obj/item/organ/internal/zombie_infection/insert(mob/living/carbon/human/M, special = 0)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/internal/zombie_infection/remove(mob/living/carbon/human/M, special = 0)
	STOP_PROCESSING(SSobj, src)
	if(iszombie(M) && old_species && !dont_delete)
		M.set_species(old_species)
	if(timer_id)
		deltimer(timer_id)
	..()

/obj/item/organ/internal/zombie_infection/on_find(mob/living/finder)
	to_chat(finder,"<span class='warning'>Inside the head is a disgusting black \
		web of pus and viscera, bound tightly around the brain like some \
		biological harness.</span>")

/obj/item/organ/internal/zombie_infection/process()
	if(!ishuman(owner)) // We do not support monkey or xeno zombies. Yet.
		qdel(src)
		return
	if(owner.suiciding)
		return
	if(owner.stat != DEAD)
		return
	if(causes_damage && !iszombie(owner) && owner.stat != DEAD)
		owner.adjustToxLoss(1)
		if (prob(10))
			to_chat(owner, "<span class='danger'>You feel sick...</span>")
	if(!owner.get_int_organ(/obj/item/organ/internal/brain))
		return
	if(!iszombie(owner) && !timer_id)
		to_chat(owner, "<span class='cultlarge'>You can feel your heart stopping, but something isn't right... \
		life has not abandoned your broken form. You can only feel a deep and immutable hunger that \
		not even death can stop, you will rise again!</span>")	
	var/revive_time = rand(revive_time_min, revive_time_max)
	var/flags = TIMER_STOPPABLE
	timer_id = addtimer(CALLBACK(src, .proc/zombify), revive_time, flags)

/obj/item/organ/internal/zombie_infection/proc/zombify()
	timer_id = null
	if(owner.stat != DEAD)
		return

	if(!iszombie(owner))
		old_species = owner.dna.species
		dont_delete = TRUE // make sure the remove code above does not run when the species code replaces all the organs
		owner.set_species(/datum/species/zombie/infectious)
		for(var/thing in owner.viruses) // cure any new crit viruses
			var/datum/disease/D = thing
			D.cure(0)
		dont_delete = FALSE
	//Fully heal the zombie's damage the first time they rise
	owner.setToxLoss(0)
	owner.setOxyLoss(0)
	owner.setBrainLoss(0)
	owner.setCloneLoss(0)
	owner.SetLoseBreath(0)
	owner.heal_overall_damage(INFINITY,INFINITY,TRUE,TRUE,FALSE)

	if(owner.update_revive())
		owner.grab_ghost()

	owner.visible_message("<span class='danger'>[owner] suddenly convulses, as [owner.p_they()] stagger to [owner.p_their()] feet and gain a ravenous hunger in [owner.p_their()] eyes!</span>", "<span class='alien'>You HUNGER!</span>")
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	owner.do_jitter_animation(living_transformation_time)
	owner.Stun(living_transformation_time)
	to_chat(owner, "<span class='alertalien'>You are now a zombie! Do not seek to be cured, do not help any non-zombies in any way, do not harm your zombie brethren and spread the disease by killing others. You are a creature of hunger and violence.</span>")
