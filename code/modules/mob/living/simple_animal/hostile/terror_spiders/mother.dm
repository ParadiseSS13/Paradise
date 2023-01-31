
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 MOTHER OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: support (team medic)
// -------------: AI: none (only effective under player control, alongside other player-controlled spiders)
// -------------: SPECIAL: picks up / carries spiderlings to prevent them being killed. Creates royal jellies to heal spiders.
// -------------: TO FIGHT IT: shoot it, it will die quickly
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/mother
	name = "Mother of Terror"
	desc = "An enormous spider. Tiny spiderlings are crawling all over it. Their beady little eyes all stare at you. The horror!"
	ai_target_method = TS_DAMAGE_SIMPLE
	icon_state = "terror_mother"
	icon_living = "terror_mother"
	icon_dead = "terror_mother_dead"
	maxHealth = 150
	health = 150
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
	can_wrap = FALSE
	melee_damage_lower = 10
	melee_damage_upper = 15
	idle_ventcrawl_chance = 5
	spider_tier = TS_TIER_3
	spider_opens_doors = 2
	can_wrap = FALSE
	special_abillity = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/terror/jelly,
							/obj/effect/proc_holder/spell/aoe_turf/terror/healing)
	spider_intro_text = "Будучи Матерью Ужаса, ваша задача - массовое исцеление пауков. Вы пассивно исцеляете всех пауков вокруг вас, и можете создавать желе, которое мгновенно их исцеляет, а также мгновенно исцелять пауков вокруг себя используя вашу способность."
	var/datum/action/innate/terrorspider/ventsmash/ventsmash_action
	var/datum/action/innate/terrorspider/remoteview/remoteview_action
	tts_seed = "Maiev"

/mob/living/simple_animal/hostile/poison/terror_spider/mother/New()
	..()
	ventsmash_action = new()
	ventsmash_action.Grant(src)
	remoteview_action = new()
	remoteview_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/mother/AttackingTarget()
	. = ..()
	if(isterrorspider(target) && target != src) //no self healing
		var/mob/living/L = target
		if(L.stat < DEAD)
			L.adjustBruteLoss(-10)
			new /obj/effect/temp_visual/heal(get_turf(L), "#8c00ff")
			new /obj/effect/temp_visual/heal(get_turf(L), "#8c00ff")

/mob/living/simple_animal/hostile/poison/terror_spider/mother/Life(seconds)
	. = ..()
	for(var/mob/living/simple_animal/S in view(7, src))
		if(S.health < S.maxHealth && src.stat != DEAD)
			if(isterrorspider(S) && S != src) //still no self healing
				S.adjustBruteLoss(-2)
				new /obj/effect/temp_visual/heal(get_turf(S), "#8c00ff")

/mob/living/simple_animal/hostile/poison/terror_spider/mother/consume_jelly(obj/structure/spider/royaljelly/J)
	to_chat(src, "<span class='warning'>Mothers cannot consume royal jelly.</span>")
	return
