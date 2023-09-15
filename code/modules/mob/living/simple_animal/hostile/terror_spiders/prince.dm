
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 PRINCE OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: boss
// -------------: AI: no special ai
// -------------: SPECIAL: massive health
// -------------: TO FIGHT IT: a squad of at least 4 people with laser rifles.
// -------------: SPRITES FROM: Travelling Merchant, https://www.paradisestation.org/forum/profile/2715-travelling-merchant/

/mob/living/simple_animal/hostile/poison/terror_spider/prince
	name = "Prince of Terror spider"
	desc = "An enormous, terrifying spider. It looks like it is judging everything it sees. Its hide seems armored, and it bears the scars of many battles."
	spider_role_summary = "Miniboss terror spider. Lightning bruiser."
	spider_intro_text = "As a Prince of Terror Spider, your role is to slaughter the crew with no remorse. \
	You have extremely high health and your attacks deal massive brute damage, while also dealing high stamina damage and knocking down crew. \
	You can also force open powered doors, smash down walls and lay webs which take longer to destroy and block vision. \
	However, your large size makes you unable to ventcrawl and you regenerate health slower than other spiders."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_allblack"
	icon_living = "terror_allblack"
	icon_dead = "terror_allblack_dead"
	maxHealth = 600 // 30 laser shots
	health = 600
	regen_points_per_hp = 6 // double the normal - IE halved regen speed
	move_to_delay = 3
	speed = 0
	melee_damage_lower = 30
	melee_damage_upper = 40
	ventcrawler = 0
	ai_ventcrawls = FALSE
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	idle_ventcrawl_chance = 0
	spider_tier = TS_TIER_3
	loudspeaker = TRUE
	spider_opens_doors = 2
	web_type = /obj/structure/spider/terrorweb/purple
	ai_spins_webs = FALSE
	gender = MALE

/mob/living/simple_animal/hostile/poison/terror_spider/prince/spider_specialattack(mob/living/carbon/human/L)
	L.KnockDown(10 SECONDS)
	L.adjustStaminaLoss(40)
	return ..()
