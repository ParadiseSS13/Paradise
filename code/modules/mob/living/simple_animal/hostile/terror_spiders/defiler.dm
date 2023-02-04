// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 DEFILER TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: stealthy reproduction
// -------------: AI: injects a venom that makes you grow spiders in your body, then retreats
// -------------: SPECIAL: stuns you on first attack - vulnerable to groups while it does this
// -------------: TO FIGHT IT: blast it before it can get away
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/defiler
	name = "Defiler of Terror"
	desc = "An ominous-looking white spider, its ghostly eyes and vicious-looking fangs are the stuff of nightmares."
	ai_target_method = TS_DAMAGE_POISON
	icon_state = "terror_white"
	icon_living = "terror_white"
	icon_dead = "terror_white_dead"
	maxHealth = 220
	health = 220
	death_sound = 'sound/creatures/terrorspiders/death2.ogg'
	speed = -0.1
	melee_damage_lower = 2
	melee_damage_upper = 5
	spider_opens_doors = 2
	spider_tier = TS_TIER_2
	gender = MALE
	web_type = /obj/structure/spider/terrorweb/white
	delay_web = 20
	special_abillity = list(/obj/effect/proc_holder/spell/targeted/terror/smoke,
							/obj/effect/proc_holder/spell/targeted/terror/parasmoke,
							/obj/effect/proc_holder/spell/targeted/terror/infest)
	spider_intro_text = "Будучи Осквернителем Ужаса, ваша цель - атаковать ничего не подозревающих гуманоидов, чтобы заразить их яйцами. Вы наносите мало урона, но можете парализовать цель за два укуса, а ваш яд заставит её замолчать. Вы также можете генерировать различные дымы вредящие противникам. И помните, не нужно убивать заражённых, они послужат носителями для новых пауков!"


/mob/living/simple_animal/hostile/poison/terror_spider/defiler/LoseTarget()
	stop_automated_movement = 0
	attackstep = 0
	attackcycles = 0
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/defiler/death(gibbed)
	if(can_die() && !hasdied && spider_uo71)
		UnlockBlastDoors("UO71_Bridge")
	return ..(gibbed)

/mob/living/simple_animal/hostile/poison/terror_spider/defiler/spider_specialattack(mob/living/carbon/human/L, poisonable)
	L.AdjustSilence(5)
	L.adjustStaminaLoss(50)
	if(!poisonable)
		..()
		return
	var/inject_target = pick("chest","head")
	L.attack_animal(src)
	if(L.stunned || L.paralysis || L.can_inject(null, FALSE, inject_target, FALSE))
		if(!IsTSInfected(L) && ishuman(L))
			visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [L]!</span>")
			new /obj/item/organ/internal/body_egg/terror_eggs(L)
			if(!ckey)
				LoseTarget()
				walk_away(src,L,2,1)

/proc/IsTSInfected(mob/living/carbon/C) // Terror AI requires this
	if(C.get_int_organ(/obj/item/organ/internal/body_egg))
		return 1
	return 0


/obj/structure/spider/terrorweb/white
	name = "infested web"
	desc = "This web is covered in hundreds of tiny, biting spiders - and their eggs."

/obj/structure/spider/terrorweb/white/web_special_ability(mob/living/carbon/C)
	if(istype(C))
		if(!IsTSInfected(C) && ishuman(C))
			var/inject_target = pick("chest","head")
			if(C.can_inject(null, FALSE, inject_target, FALSE))
				to_chat(C, "<span class='danger'>[src] slices into you!</span>")
				new /obj/item/organ/internal/body_egg/terror_eggs(C)
