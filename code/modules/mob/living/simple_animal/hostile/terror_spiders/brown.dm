// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 BROWN TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: breaking vents
// -------------: AI: ventcrawls a lot, breaks open vents
// -------------: SPECIAL: ventsmash
// -------------: TO FIGHT IT: blast it before it can get away!
// -------------: SPRITES FROM: IK3I

/mob/living/simple_animal/hostile/poison/terror_spider/brown
	name = "Brown Terror spider"
	desc = "An ominous-looking spider, colored brown like the dirt it crawled out of. Its forearms have sharp digging claws."
	spider_role_summary = "Vent-breaking spider that breaches into new areas."
	spider_intro_text = "As a Brown Terror Spider, your role is to breach areas for other spiders to attack. \
	Your attacks are strong, and in addition to being able to open powered doors you can also break down walls. \
	You are also able to breach welded vents, allowing groups of terror spiders to break into areas that the crew might consider secure. \
	However you have low health, move slower than other spiders, and cannot spin any webs."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_brown"
	icon_living = "terror_brown"
	icon_dead = "terror_brown_dead"
	melee_damage_lower = 20
	melee_damage_upper = 30
	move_to_delay = 20 // Slow.
	spider_opens_doors = 2 // Breach specialist.
	environment_smash = ENVIRONMENT_SMASH_RWALLS // Breaks anything.
	spider_tier = TS_TIER_2
	ai_ventbreaker = TRUE
	freq_ventcrawl_combat = 600 // Ventcrawls very frequently, breaking open vents as it goes.
	freq_ventcrawl_idle =  1800
	web_type = null

/mob/living/simple_animal/hostile/poison/terror_spider/brown/Initialize(mapload)
	. = ..()
	var/datum/action/innate/terrorspider/ventsmash/act = new
	act.Grant(src)
