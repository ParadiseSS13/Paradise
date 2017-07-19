// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 BROWN TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: breaking vents
// -------------: AI: ventcrawls a lot, breaks open vents
// -------------: SPECIAL: nothing
// -------------: TO FIGHT IT: blast it before it can get away
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/brown
	name = "Ghostly Nightmare spider"
	desc = "An ominous-looking white spider, its ghostly eyes and vicious-looking fangs are the stuff of nightmares. This one has extra-long claws protruding from its feet."
	spider_role_summary = "Tunneling spider that smashes open vents"
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_gray2"
	icon_living = "terror_gray2"
	icon_dead = "terror_gray2_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 25
	move_to_delay = 4
	spider_tier = TS_TIER_2

	ai_ventbreaker = 1
	freq_ventcrawl_combat = 600 // 1 minute, quite frequent!
	freq_ventcrawl_idle =  6000 // 10 minutes