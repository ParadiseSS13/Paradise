
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 PRINCESS OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: cutesy
// -------------: AI: as green, but will evolve to queen when it can
// -------------: SPECIAL: can evolve into a queen, if fed enough
// -------------: TO FIGHT IT: kill it before it evolves
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/princess
	name = "Princess of Terror spider"
	desc = "An enormous spider. It looks strangely cute and fluffy."
	spider_role_summary = "Future Queen"
	ai_target_method = TS_DAMAGE_SIMPLE
	icon_state = "terror_princess1"
	icon_living = "terror_princess1"
	icon_dead = "terror_princess_dead1"
	maxHealth = 150
	health = 150
	regen_points_per_hp = 1 // always regens very fast
	force_threshold = 18 // outright immune to anything of force under 18, same as queen
	melee_damage_lower = 10
	melee_damage_upper = 20
	idle_ventcrawl_chance = 5
	spider_tier = TS_TIER_3
	spider_opens_doors = 2
	web_type = /obj/structure/spider/terrorweb/queen
	var/feedings_to_evolve = 3
	var/datum/action/innate/terrorspider/ventsmash/ventsmash_action
	var/datum/action/innate/terrorspider/evolvequeen/evolvequeen_action

/mob/living/simple_animal/hostile/poison/terror_spider/princess/New()
	..()
	ventsmash_action = new()
	ventsmash_action.Grant(src)
	evolvequeen_action = new()
	evolvequeen_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/princess/proc/evolve_to_queen()
	var/mob/living/simple_animal/hostile/poison/terror_spider/queen/Q = new /mob/living/simple_animal/hostile/poison/terror_spider/queen(loc)
	if(mind)
		mind.transfer_to(Q)
	qdel(src)

/mob/living/simple_animal/hostile/poison/terror_spider/princess/DoWrap()
	. = ..()
	if(fed == 0)
		icon_state = "terror_princess1"
		icon_living = "terror_princess1"
		icon_dead = "terror_princess_dead1"
		desc = "An enormous spider. It looks strangely cute and fluffy, with soft pink fur covering most of its body."
	else if(fed == 1)
		icon_state = "terror_princess2"
		icon_living = "terror_princess2"
		icon_dead = "terror_princess2_dead"
		desc = "An enormous spider. It used to look strangely cute and fluffy, but now the effect is spoiled by parts of its fur, which have turned an ominous blood red in color."
	else
		icon_state = "terror_princess3"
		icon_living = "terror_princess3"
		icon_dead = "terror_princess3_dead"
		desc = "An enormous spider. Its entire body has turned an ominous blood red color, with actual blood dripping from its jaws. It stares around, hungrily."

/mob/living/simple_animal/hostile/poison/terror_spider/princess/spider_special_action()
	if(cocoon_target)
		handle_cocoon_target()
	else if(fed >= feedings_to_evolve)
		evolve_to_queen()
	else if(world.time > (last_cocoon_object + freq_cocoon_object))
		seek_cocoon_target()

