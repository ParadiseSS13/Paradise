// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 WHITE TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: stealthy reproduction
// -------------: AI: injects a venom that makes you grow spiders in your body, then retreats
// -------------: SPECIAL: stuns you on first attack - vulnerable to groups while it does this
// -------------: TO FIGHT IT: blast it before it can get away
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/white
	name = "White Terror spider"
	desc = "An ominous-looking white spider, its ghostly eyes and vicious-looking fangs are the stuff of nightmares."
	spider_role_summary = "Rare, bite-and-run spider that infects hosts with spiderlings"
	ai_target_method = TS_DAMAGE_POISON
	icon_state = "terror_white"
	icon_living = "terror_white"
	icon_dead = "terror_white_dead"
	maxHealth = 200
	health = 200
	melee_damage_lower = 5
	melee_damage_upper = 15
	move_to_delay = 4
	spider_tier = TS_TIER_2
	web_infects = 1


/mob/living/simple_animal/hostile/poison/terror_spider/white/LoseTarget()
	stop_automated_movement = 0
	attackstep = 0
	attackcycles = 0
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/white/death(gibbed)
	if(!hasdied)
		if(spider_uo71)
			UnlockBlastDoors("UO71_Bridge")
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/white/spider_specialattack(mob/living/carbon/human/L, poisonable)
	if(!poisonable)
		..()
		return
	var/inject_target = pick("chest","head")
	L.attack_animal(src)
	if(L.stunned || L.paralysis || L.can_inject(null, 0, inject_target, 0))
		if(!IsTSInfected(L))
			visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [L]!</span>")
			new /obj/item/organ/internal/body_egg/terror_eggs(L)
			if(!ckey)
				LoseTarget()
				walk_away(src,L,2,1)
		else if(prob(25))
			visible_message("<span class='danger'>[src] pounces on [L]!</span>")
			L.Weaken(5)
			L.Stun(5)

/proc/IsTSInfected(mob/living/carbon/C) // Terror AI requires this
	if(C.get_int_organ(/obj/item/organ/internal/body_egg))
		return 1
	return 0