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
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_brown"
	icon_living = "terror_brown"
	icon_dead = "terror_brown_dead"
	maxHealth = 120 // Low
	health = 120
	melee_damage_lower = 20
	melee_damage_upper = 30
	move_to_delay = 20 // Slow.
	spider_opens_doors = 2 // Breach specialist.
	environment_smash = ENVIRONMENT_SMASH_RWALLS // Breaks anything.
	spider_tier = TS_TIER_2
	ai_ventbreaker = 1
	freq_ventcrawl_combat = 600 // Ventcrawls very frequently, breaking open vents as it goes.
	freq_ventcrawl_idle =  1800
	web_type = null
	var/datum/action/innate/terrorspider/ventsmash/ventsmash_action

/mob/living/simple_animal/hostile/poison/terror_spider/brown/New()
	..()
	ventsmash_action = new()
	ventsmash_action.Grant(src)
