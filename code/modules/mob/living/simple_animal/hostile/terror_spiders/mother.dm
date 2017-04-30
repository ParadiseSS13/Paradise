
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 MOTHER OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: living schmuck bait
// -------------: AI: no special ai
// -------------: SPECIAL: spawns an ungodly number of spiderlings when killed
// -------------: TO FIGHT IT: don't! Just leave it alone! It is harmless by itself... but god help you if you aggro it.
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/mother
	name = "Mother of Terror spider"
	desc = "An enormous spider. Hundreds of tiny spiderlings are crawling all over it. Their beady little eyes all stare at you. The horror!"
	spider_role_summary = "Schmuck bait. Extremely weak in combat, but spawns many spiderlings when it dies."
	ai_target_method = TS_DAMAGE_SIMPLE
	icon_state = "terror_gray2"
	icon_living = "terror_gray2"
	icon_dead = "terror_gray2_dead"
	maxHealth = 50
	health = 50
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_to_delay = 5
	idle_ventcrawl_chance = 5
	spider_tier = TS_TIER_3
	spider_opens_doors = 2
	var/canspawn = 1
	var/datum/action/innate/terrorspider/ventsmash/ventsmash_action

/mob/living/simple_animal/hostile/poison/terror_spider/mother/New()
	..()
	ventsmash_action = new()
	ventsmash_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/mother/death(gibbed)
	if(canspawn)
		canspawn = 0
		for(var/i in 0 to 30)
			var/obj/structure/spider/spiderling/terror_spiderling/S = new /obj/structure/spider/spiderling/terror_spiderling(get_turf(src))
			S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray)
			if(prob(66))
				S.stillborn = 1
			else if(prob(10))
				S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/black, /mob/living/simple_animal/hostile/poison/terror_spider/green)
			S.amount_grown = 50 // double speed growth
			S.immediate_ventcrawl = 1
		visible_message("<span class='userdanger'>[src] breaks apart, the many spiders on its back scurrying everywhere!</span>")
		degenerate = 1
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/mother/Destroy()
	canspawn = 0
	return ..()