
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GREEN TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: reproduction
// -------------: AI: after it kills you, it webs you and lays new terror eggs on your body
// -------------: SPECIAL: can also create webs, web normal objects, etc
// -------------: TO FIGHT IT: kill it however you like - just don't die to it!
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/EnemySummoner
// -------------: SPRITES FROM: Codersprites :(

/mob/living/simple_animal/hostile/poison/terror_spider/green
	name = "Green Terror spider"
	desc = "An ominous-looking green spider, it has a small egg-sac attached to it."
	altnames = list("Green Terror spider","Insidious Breeding spider","Fast Bloodsucking spider")
	spider_role_summary = "Average melee spider that webs its victims and lays more spider eggs"
	egg_name = "green spider eggs"

	icon_state = "terror_green"
	icon_living = "terror_green"
	icon_dead = "terror_green_dead"
	maxHealth = 120
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	ventcrawler = 1
	ai_cocoons_object = 1


/mob/living/simple_animal/hostile/poison/terror_spider/green/verb/Wrap()
	set name = "Wrap"
	set category = "Spider"
	set desc = "Wrap up prey to eat (allowing you to lay eggs) and objects (making them inaccessible to humans)."
	DoWrap()


/mob/living/simple_animal/hostile/poison/terror_spider/green/verb/LayGreenEggs()
	set name = "Lay Green Eggs"
	set category = "Spider"
	set desc = "Lay a clutch of eggs. You must have wrapped a prey creature for feeding first."
	DoLayGreenEggs()


/mob/living/simple_animal/hostile/poison/terror_spider/proc/DoLayGreenEggs()
	var/obj/effect/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
	else if(!fed)
		to_chat(src, "<span class='warning'>You are too hungry to do this!</span>")
	else if(busy != LAYING_EGGS)
		busy = LAYING_EGGS
		visible_message("<span class='notice'>\The [src] begins to lay a cluster of eggs.</span>")
		stop_automated_movement = 1
		spawn(50)
			if(busy == LAYING_EGGS)
				E = locate() in get_turf(src)
				if(!E)
					if (prob(33))
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red, 2, 1)
					else if (prob(50))
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black, 2, 1)
					else
						DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green, 2, 1)
					fed--
			busy = 0
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/poison/terror_spider/green/harvest()
	new /obj/item/weapon/reagent_containers/terrorspider_parts/toxgland_green(get_turf(src))
	gib()