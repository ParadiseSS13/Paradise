
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 MOTHER OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: living schmuck bait
// -------------: AI: no special ai
// -------------: SPECIAL: spawns an ungodly number of spiderlings when killed
// -------------: TO FIGHT IT: don't! Just leave it alone! It is harmless by itself... but god help you if you aggro it.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/MotherOfAThousandYoung
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/SchmuckBait
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/mother
	name = "Mother of Terror spider"
	desc = "An enormous spider. Its back is a crawling mass of spiderlings. All of them look around with beady little eyes. The horror!"
	spider_role_summary = "Schmuck bait. Extremely weak in combat, but spawns many spiderlings when it dies."
	egg_name = "mother spider eggs"

	altnames = list("Seemingly Harmless spider","Strange spider","Wolf Mother spider")
	icon_state = "terror_queen"
	icon_living = "terror_queen"
	icon_dead = "terror_queen_dead"
	maxHealth = 50
	health = 50
	melee_damage_lower = 10
	melee_damage_upper = 20
	move_to_delay = 5
	ventcrawler = 1
	idle_ventcrawl_chance = 5

	spider_tier = 3
	spider_opens_doors = 2

	var/canspawn = 1

/mob/living/simple_animal/hostile/poison/terror_spider/mother/death(gibbed)
	if (canspawn)
		canspawn = 0
		for(var/i=0, i<30, i++)
			var/obj/effect/spider/terror_spiderling/S = new /obj/effect/spider/terror_spiderling(get_turf(src))
			S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/red, /mob/living/simple_animal/hostile/poison/terror_spider/gray)
			if (prob(50))
				S.stillborn = 1
			else if (prob(10))
				S.grow_as = pick(/mob/living/simple_animal/hostile/poison/terror_spider/black, /mob/living/simple_animal/hostile/poison/terror_spider/green)
		visible_message("<span class='userdanger'>\The [src] breaks apart, the many spiders on its back scurrying everywhere!</span>")
		degenerate = 1
		loot = 0
	..()

