
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 PRINCE OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: boss
// -------------: AI: no special ai
// -------------: SPECIAL: massive health
// -------------: TO FIGHT IT: a squad of at least 4 people with laser rifles.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/LightningBruiser
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/WakeupCallBoss
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/prince
	name = "prince of terror spider"
	desc = "An enormous, terrifying spider. It looks like it is judging everything it sees. Extremely dangerous."
	spider_role_summary = "Boss-level terror spider. Lightning bruiser. Capable of taking on a squad by itself."

	altnames = list("Prince of Terror","Terror Prince")
	icon_state = "terror_queen"
	icon_living = "terror_queen"
	icon_dead = "terror_queen_dead"
	maxHealth = 600 // 30 laser shots. 15 cannon shots
	health = 600
	melee_damage_lower = 15
	melee_damage_upper = 25
	move_to_delay = 5
	ventcrawler = 1

	ai_ventcrawls = 0 // no override, never ventcrawls. Ever.
	idle_ventcrawl_chance = 0

	spider_tier = 3
	spider_opens_doors = 2



#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON