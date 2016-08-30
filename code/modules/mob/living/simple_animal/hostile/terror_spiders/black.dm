
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 BLACK TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: assassin, poisoner, DoT expert
// -------------: AI: attacks to inject its venom, then retreats. Will inject its enemies multiple times then hang back to ensure they die.
// -------------: SPECIAL: venom that does more damage the more of it is in you
// -------------: TO FIGHT IT: if bitten once, retreat, get charcoal/etc treatment, and come back with a gun.
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/GradualGrinder
// -------------: SPRITES FROM: Travelling Merchant, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=2766

/mob/living/simple_animal/hostile/poison/terror_spider/black
	name = "Black Terror spider"
	desc = "An ominous-looking spider, black as the darkest night, and with merciless yellow eyes."
	spider_role_summary = "Hit-and-run attacker with extremely venomous bite."

	icon_state = "terror_black"
	icon_living = "terror_black"
	icon_dead = "terror_black_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its bite will kill you!
	health = 120
	melee_damage_lower = 5
	melee_damage_upper = 10
	move_to_delay = 5
	stat_attack = 1 // ensures they will target people in crit, too!
	spider_tier = TS_TIER_2



/mob/living/simple_animal/hostile/poison/terror_spider/black/ShowGuide()
	..()
	var/list/guidelist = list()
	guidelist += "BLACK TERROR guide:"
	guidelist += "- You are an assassin. Even 2-3 bites from you is fatal to organic humanoids - if you back off and let your poison work. You are very vulnurable to mechs and borgs."
	guidelist += "- Try to bite a few times and retreat quickly. You will die if you stick around. You are very dangerous and should expect crew to focus fire on you."
	to_chat(src, guidelist.Join("<BR>"))

/mob/living/simple_animal/hostile/poison/terror_spider/black/spider_specialattack(mob/living/carbon/human/L, var/poisonable)
	if(!poisonable)
		return ..()
	if(L.reagents.has_reagent("terror_black_toxin", 50))
		return ..()
	var/inject_target = pick("chest", "head")
	if(L.stunned || L.can_inject(null, 0, inject_target, 0))
		L.reagents.add_reagent("terror_black_toxin", 15) // inject our special poison
		visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [target]!</span>")
	else
		visible_message("<span class='danger'>[src] bites [target], but cannot inject venom into their [inject_target]!</span>")
	L.attack_animal(src)