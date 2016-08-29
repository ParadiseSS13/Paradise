
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
	altnames = list("Gray Trap spider", "Gray Stalker spider", "Ghostly Ambushing spider")
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

/mob/living/simple_animal/hostile/poison/terror_spider/gray/ShowGuide()
	..()
	var/list/guidelist = list()
	guidelist += "GRAY TERROR guide:"
	guidelist += "- You are a stealth killer. Your venom silences its targets."
	guidelist += "- You are weak, but fast, and should use webs in corridors to trap your prey, hiding in a vent until they are entangled."
	guidelist += "- Do not attempt to take on well-armed foes without the element of surprise - you will die quickly!"
	to_chat(src, guidelist.Join("<BR>"))

/mob/living/simple_animal/hostile/poison/terror_spider/gray/spider_specialattack(var/mob/living/carbon/human/L, var/poisonable)
	if(!poisonable)
		..()
		return
	if(L.silent >= 10)
		L.attack_animal(src)
	else
		var/inject_target = pick("chest","head")
		if(L.stunned || L.can_inject(null,0,inject_target,0))
			L.silent = max(L.silent, 20) // instead of having a venom that only lasts seconds, we just add the silence directly.
			visible_message("<span class='danger'>[src] buries grey fangs deep into the [inject_target] of [target]!</span>")
		else
			visible_message("<span class='danger'>[src] bites [target], but cannot inject venom into their [inject_target]!</span>")
		L.attack_animal(src)