
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
	spider_role_summary = "Miniboss terror spider. Lightning bruiser."

	icon_state = "terror_allblack"
	icon_living = "terror_allblack"
	icon_dead = "terror_allblack_dead"

	maxHealth = 600 // 30 laser shots
	health = 600
	regen_points_per_hp = 6 // double the normal - IE halved regen speed

	melee_damage_lower = 20
	melee_damage_upper = 30
	move_to_delay = 4 // faster than normal

	ventcrawler = 0
	environment_smash = 3

	loot = list(/obj/item/clothing/accessory/medal)
	spider_tier = TS_TIER_3
	spider_opens_doors = 2

	var/datum/action/innate/terrorspider/princesmash/princesmash_action


/mob/living/simple_animal/hostile/poison/terror_spider/prince/New()
	..()
	princesmash_action = new()
	princesmash_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/prince/spider_specialattack(mob/living/carbon/human/L)
	if(prob(15))
		visible_message("<span class='danger'>[src] rams into [L], knocking them to the floor!</span>")
		L.Weaken(5)
		L.Stun(5)
	else
		..()