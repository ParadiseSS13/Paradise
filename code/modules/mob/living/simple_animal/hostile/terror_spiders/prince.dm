
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
	name = "Prince of Terror spider"
	desc = "An enormous, terrifying spider. It looks like it is judging everything it sees. Extremely dangerous."
	spider_role_summary = "Boss-level terror spider. Lightning bruiser. Capable of taking on a squad by itself."
	ai_target_method = TS_DAMAGE_BRUTE
	egg_name = "prince spider eggs"

	altnames = list("Prince of Terror", "Terror Prince")
	icon_state = "terror_queen"
	icon_living = "terror_queen"
	icon_dead = "terror_queen_dead"
	maxHealth = 600 // 30 laser shots. 15 cannon shots
	health = 600
	melee_damage_lower = 15
	melee_damage_upper = 25
	move_to_delay = 5
	ventcrawler = 1
	loot = list(/obj/item/clothing/accessory/medal)

	ai_ventcrawls = 0
	idle_ventcrawl_chance = 0

	spider_tier = TS_TIER_3
	spider_opens_doors = 2


/mob/living/simple_animal/hostile/poison/terror_spider/prince/death(gibbed)
	if(!hasdroppedloot)
		if(spider_uo71)
			UnlockBlastDoors("UO71_SciStorage", "UO71 Secure Science Storage is now unlocked!")
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/prince/ShowGuide()
	..()
	var/guidetext = "PRINCE OF TERROR guide:"
	guidetext += "<BR>- A ferocious warrior, you wander the stars, identifying potential nest sites, and threats, for your fellow Terror Spiders."
	guidetext += "<BR>- You have been sent to this remote station to determine if it would make a suitable nest."
	guidetext += "<BR>- <b>You have lots of health, and decent attacks, but can be killed by a well-armed group.</b>"
	guidetext += "<BR>- Expect crew to treat you as a level 5 biohazard. Even a single Prince (aka: War Spider) can wreck a station."
	to_chat(src, guidetext)

/mob/living/simple_animal/hostile/poison/terror_spider/prince/spider_specialattack(var/mob/living/carbon/human/L)
	if(prob(15))
		visible_message("<span class='danger'>[src] rams into [L], knocking them to the floor!</span>")
		L.Weaken(5)
		L.Stun(5)
	else
		..()