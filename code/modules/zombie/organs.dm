#define START_TIMER reanimation_timer = world.time + rand(600,1200)

/obj/item/organ/internal/zombie_infection
	name = "festering ooze"
	desc = "A black web of pus and vicera."
	parent_organ = "head"
	slot = "zombie_infection"
	icon_state = "blacktumor"
	var/causes_damage = TRUE
	var/reanimation_timer
	var/datum/species/old_species = /datum/species/human
	var/living_transformation_time = 5
	var/converts_living = FALSE

/obj/item/organ/internal/zombie_infection/New()
	. = ..()
	if(iscarbon(loc))
		insert(loc)
	GLOB.zombie_infection_list += src

/obj/item/organ/internal/zombie_infection/Destroy()
	GLOB.zombie_infection_list -= src
	. = ..()

/obj/item/organ/internal/zombie_infection/insert(mob/living/carbon/human/M, special = 0)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/organ/internal/zombie_infection/remove(mob/living/carbon/human/M, special = 0)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(iszombie(M) && old_species)
		M.set_species(old_species)

/obj/item/organ/internal/zombie_infection/on_find(mob/living/finder)
	to_chat(finder,"<span class='warning'>Inside the head is a disgusting black \
		web of pus and vicera, bound tightly around the brain like some \
		biological harness.</span>")

/obj/item/organ/internal/zombie_infection/process()
	if(!ishuman(owner)) // We do not support monkey or xeno zombies. Yet.
		qdel(src)
		return
	if(owner.suiciding)
		return
	if(owner.stat != DEAD && !converts_living)
		return
	if (causes_damage && !iszombie(owner) && owner.stat != DEAD)
		owner.adjustToxLoss(1)
		if (prob(10))
			to_chat(owner, "<span class='danger'>You feel sick...</span>")
	if(!owner.get_int_organ(/obj/item/organ/internal/brain))
		return	
	else if(reanimation_timer && (reanimation_timer < world.time))
		zombify() // Rise and shine, Mr Romero... rise and shine.
		reanimation_timer = null
	else if(owner.stat == DEAD && !reanimation_timer)
		START_TIMER
	else if(converts_living && !iszombie(owner) && !reanimation_timer)
		START_TIMER

/obj/item/organ/internal/zombie_infection/remove(mob/living/carbon/human/M, special = 0)
	. = ..()
	CHECK_DNA_AND_SPECIES(M)
	if(iszombie(M) && old_species)
		M.set_species(old_species)

/obj/item/organ/internal/zombie_infection/proc/zombify()
	CHECK_DNA_AND_SPECIES(owner)
	var/datum/species/zombie = /datum/species/zombie/infectious
	if(!iszombie(owner))
		old_species = owner.dna.species
		owner.set_species(zombie)
	//Fully heal the zombie's damage the first time they rise
	owner.setToxLoss(0, 0)
	owner.setOxyLoss(0, 0)
	owner.heal_overall_damage(INFINITY, INFINITY, INFINITY, null, TRUE)

	if(!owner.revive())
		return

	owner.grab_ghost()
	owner.visible_message("<span class='danger'>[owner] suddenly convulses, as [owner.p_they()] stagger to [owner.p_their()] feet and gain a ravenous hunger in [owner.p_their()] eyes!</span>", "<span class='alien'>You HUNGER!</span>")
	playsound(owner.loc, 'sound/hallucinations/far_noise.ogg', 50, 1)
	to_chat(owner, "<span class='alertalien'>You are now a zombie!</span>")

#undef START_TIMER