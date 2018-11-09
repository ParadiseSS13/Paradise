#define EGG_INCUBATION_TIME 120

/mob/living/simple_animal/hostile/headcrab
	name = "headslug"
	desc = "Absolutely not de-beaked or harmless. Keep away from corpses."
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	icon = 'icons/mob/mob.dmi'
	health = 50
	maxHealth = 50
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = list("creature")
	robust_searching = 1
	stat_attack = 2
	obj_damage = 0
	environment_smash = 0
	speak_emote = list("squeaks")
	ventcrawler = 2
	var/datum/mind/origin
	var/egg_lain = 0

/mob/living/simple_animal/hostile/headcrab/examine(mob/user)
	..()
	if(stat == DEAD)
		to_chat(desc = "It appears to be dead.")

/mob/living/simple_animal/hostile/headcrab/proc/Infect(mob/living/carbon/victim)
	var/obj/item/organ/internal/body_egg/changeling_egg/egg = new(victim)
	egg.insert(victim)
	if(origin)
		egg.origin = origin
	else if(mind) // Let's make this a feature
		egg.origin = mind
	for(var/obj/item/organ/internal/I in src)
		I.loc = egg
	visible_message("<span class='warning'>[src] plants something in [victim]'s flesh!</span>", \
					"<span class='danger'>We inject our egg into [victim]'s body!</span>")
	egg_lain = 1

/mob/living/simple_animal/hostile/headcrab/AttackingTarget()
	if(egg_lain)
		target.attack_animal(src)
		return
	if(iscarbon(target) && !issmall(target))
		// Changeling egg can survive in aliens!
		var/mob/living/carbon/C = target
		if(C.stat == DEAD)
			if(C.status_flags & XENO_HOST)
				to_chat(src, "<span class='userdanger'>A foreign presence repels us from this body. Perhaps we should try to infest another?</span>")
				return
			Infect(target)
			to_chat(src, "<span class='userdanger'>With our egg laid, our death approaches rapidly...</span>")
			spawn(100)
				death()
			return
	target.attack_animal(src)




/obj/item/organ/internal/body_egg/changeling_egg
	name = "changeling egg"
	desc = "Twitching and disgusting."
	origin_tech = "biotech=7" // You need to be really lucky to obtain it.
	var/datum/mind/origin
	var/time

/obj/item/organ/internal/body_egg/changeling_egg/egg_process()
	// Changeling eggs grow in dead people
	time++
	if(time >= EGG_INCUBATION_TIME)
		Pop()
		remove(owner)
		qdel(src)

/obj/item/organ/internal/body_egg/changeling_egg/proc/Pop()
	var/mob/living/carbon/human/monkey/M = new(owner)
	owner.stomach_contents += M

	for(var/obj/item/organ/internal/I in src)
		I.insert(M, 1)

	if(origin && origin.current && (origin.current.stat == DEAD))
		origin.transfer_to(M)
		if(!origin.changeling)
			M.make_changeling()
		if(origin.changeling.can_absorb_dna(M, owner))
			origin.changeling.absorb_dna(owner, M)

		origin.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
		M.key = origin.key
	owner.gib()

#undef EGG_INCUBATION_TIME
