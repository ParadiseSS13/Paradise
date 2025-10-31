// Giant evil flesh spider
/mob/living/basic/giant_spider/flesh_spider
	name = "flesh spider"
	desc = "A horrifyingly grotesque mass of animated flesh shaped like a spider. A tar-like venom drips from its bony fangs."
	icon_state = "flesh_spider"
	icon_living = "flesh_spider"
	icon_dead = "flesh_spider_dead"
	mob_biotypes = MOB_ORGANIC
	ventcrawler = VENTCRAWLER_ALWAYS
	butcher_results = list(/obj/item/food/monstermeat/spidermeat = 4)
	maxHealth = 90
	health = 90
	obj_damage = 60
	melee_damage_lower = 10
	melee_damage_upper = 15
	melee_attack_cooldown_min = 1 SECONDS
	melee_attack_cooldown_max = 2 SECONDS
	faction = list("nether")
	ai_controller = /datum/ai_controller/basic_controller/incursion/flesh_spider
	venom_per_bite = 10
	innate_actions = list()
