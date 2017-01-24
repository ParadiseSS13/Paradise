
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GRAY TERROR -------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: fast, weak terror spider
// -------------: SPECIAL: silences targets
// -------------: TO FIGHT IT: shoot it!
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/gray
	name = "Gray Terror spider"
	desc = "An ominous-looking gray spider, it seems jittery."
	spider_role_summary = "Fast-moving but weak spider."
	icon_state = "terror_gray"
	icon_living = "terror_gray"
	icon_dead = "terror_gray_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but silences its targets
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	ventcrawler = 1
	move_to_delay = 5 // normal speed
	stat_attack = 1 // ensures they will target people in crit, too!
	environment_smash = 1


/mob/living/simple_animal/hostile/poison/terror_spider/gray/spider_specialattack(mob/living/carbon/human/L, poisonable)
	if(!poisonable)
		..()
		return
	if(L.silent >= 10)
		L.attack_animal(src)
	else
		var/inject_target = pick("chest","head")
		if(L.stunned || L.can_inject(null,0,inject_target,0))
			L.Silence(20) // instead of having a venom that only lasts seconds, we just add the silence directly.
			visible_message("<span class='danger'>[src] buries grey fangs deep into the [inject_target] of [target]!</span>")
		else
			visible_message("<span class='danger'>[src] bites [target], but cannot inject venom into their [inject_target]!</span>")
		L.attack_animal(src)