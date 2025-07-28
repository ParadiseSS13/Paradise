
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 PRINCESS OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: mini-queen, maintains a smaller nest, but also more expendable
// -------------: AI: maintains a small group of spiders. Small fraction of a queen's nest.
// -------------: SPECIAL: lays eggs over time, like a queen
// -------------: TO FIGHT IT: hunt it before it lays eggs
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess
	name = "Princess of Terror spider"
	desc = "An enormous spider. It looks strangely cute and fluffy."
	spider_role_summary = "Mini-Queen"
	spider_intro_text = "As a Princess of Terror Spider, your role is to build and maintain a small nest. \
	You constantly generate eggs at a slow rate which you can lay at a desired location, though you are limited mostly to basic terror spider eggs. Eggs generated while you are in a pipe will be lost. \
	You can also open powered doors and your webs are airtight, being capable of blocking off exposure to space. \
	You do not take damage from weaker weapons or projectiles. \
	However, you only have moderate health and deal moderate damage, making you weak in direct fights and reliant on other spiders for defence."
	icon_state = "terror_princess1"
	icon_living = "terror_princess1"
	icon_dead = "terror_princess1_dead"
	maxHealth = 150
	health = 150
	spider_tier = TS_TIER_3

	// Unlike queens, no ranged attack.
	ranged = FALSE
	retreat_distance = 0
	minimum_distance = 0
	projectilesound = null
	projectiletype = null

	canlay = 0
	hasnested = TRUE
	var/spider_max_children = 8


/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/grant_queen_subtype_abilities()
	// Queens start in movement mode, where they can ventcrawl but not lay eggs. Then they move to NestMode() where they can wallsmash and egglay, but not ventcrawl.
	// Princesses are simpler, and can always lay eggs, always vent crawl, but never smash walls. Unlike queens, they don't have a "nesting" transformation.
	queeneggs_action = new()
	queeneggs_action.Grant(src)
	queensense_action = new()
	queensense_action.Grant(src)


/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/ListAvailableEggTypes()
	var/list/valid_types = list(TS_DESC_RED, TS_DESC_GRAY, TS_DESC_GREEN)

	// Each princess can also have ONE black/purple/brown. If it dies, they can pick a new spider from the 3 advanced types to lay.
	var/list/spider_array = CountSpidersDetailed(TRUE, list(/mob/living/simple_animal/hostile/poison/terror_spider/black, /mob/living/simple_animal/hostile/poison/terror_spider/purple, /mob/living/simple_animal/hostile/poison/terror_spider/brown))
	if(spider_array["all"] < 1)
		valid_types |= TS_DESC_BLACK
		valid_types |= TS_DESC_PURPLE
		valid_types |= TS_DESC_BROWN

	return valid_types


/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/grant_eggs()
	spider_lastspawn = world.time

	if(!isturf(loc))
		to_chat(src, "<span class='danger'>You cannot generate eggs while hiding in [loc].</span>")
		return

	var/list/spider_array = CountSpidersDetailed(TRUE)
	var/brood_count = spider_array["all"]

	// Color shifts depending on how much of their brood capacity they have used.
	if(brood_count == 0)
		icon_state = "terror_princess1"
		icon_living = "terror_princess1"
		icon_dead = "terror_princess1_dead"
		desc = "An enormous spider. It looks strangely cute and fluffy, with soft pink fur covering most of its body."
	else if(brood_count < (spider_max_children /2))
		icon_state = "terror_princess2"
		icon_living = "terror_princess2"
		icon_dead = "terror_princess2_dead"
		desc = "An enormous spider. It used to look strangely cute and fluffy, but now the effect is spoiled by parts of its fur, which have turned an ominous blood red in color."
	else
		icon_state = "terror_princess3"
		icon_living = "terror_princess3"
		icon_dead = "terror_princess3_dead"
		desc = "An enormous spider. Its entire body looks to be the color of dried blood."

	if((brood_count + canlay) >= spider_max_children)
		return
	canlay++
	if(canlay == 1)
		to_chat(src, "<span class='notice'>You have an egg available to lay.</span>")
	else
		to_chat(src, "<span class='notice'>You have [canlay] eggs available to lay.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/show_egg_timer()
	to_chat(src, "<span class='danger'>Too soon to attempt that again. You generate a new egg every [spider_spawnfrequency / 10] seconds.</span>")

/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/NestMode()
	// Princesses don't nest. However, we still need to override this in case an AI princess calls it.
	return

/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/spider_special_action()
	// Princess AI routine. GREATLY simplified version of queen routine.
	if(stat == CONSCIOUS && !ckey)
		// Utilize normal queen AI for finding a nest site (neststep=0), and activating NestMode() (neststep=1)
		if(neststep != 2)
			return ..()
		// After that, simply lay an egg once per nestfrequency, until we have the max.
		if(world.time < (lastnestsetup + nestfrequency))
			return
		lastnestsetup = world.time
		if(ai_nest_is_full())
			return
		spider_lastspawn = world.time
		DoLayTerrorEggs(pick(spider_types_standard), 1)
		// Yes, this means NPC princesses won't create T2 spiders.


/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess/ai_nest_is_full()
	var/list/spider_array = CountSpidersDetailed(TRUE)
	if(spider_array["all"] >= spider_max_children)
		return TRUE
	return FALSE

