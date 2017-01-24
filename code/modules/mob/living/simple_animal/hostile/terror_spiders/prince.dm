
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 PRINCE OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: boss
// -------------: AI: no special ai
// -------------: SPECIAL: massive health
// -------------: TO FIGHT IT: a squad of at least 4 people with laser rifles.
// -------------: SPRITES FROM: Travelling Merchant, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=2766

/mob/living/simple_animal/hostile/poison/terror_spider/prince
	name = "Prince of Terror spider"
	desc = "An enormous, terrifying spider. It looks like it is judging everything it sees. Its hide seems armored, and it bears the scars of many battles."
	spider_role_summary = "Boss-level terror spider. Lightning bruiser. Capable of taking on a squad by itself."
	icon_state = "terror_allblack"
	icon_living = "terror_allblack"
	icon_dead = "terror_allblack_dead"
	maxHealth = 400 // 20 laser shots.
	health = 400
	melee_damage_lower = 15
	melee_damage_upper = 25
	move_to_delay = 5
	ventcrawler = 1
	loot = list(/obj/item/clothing/accessory/medal)
	spider_tier = TS_TIER_3
	spider_opens_doors = 2


/mob/living/simple_animal/hostile/poison/terror_spider/prince/spider_specialattack(mob/living/carbon/human/L)
	if(prob(15))
		visible_message("<span class='danger'>[src] rams into [L], knocking them to the floor!</span>")
		L.Weaken(5)
		L.Stun(5)
	else
		..()