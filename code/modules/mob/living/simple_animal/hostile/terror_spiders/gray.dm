
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GRAY TERROR -------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: ambusher
// -------------: AI: hides in vents, emerges when prey is near to kill it, then hides again. Intended to scare normal crew.
// -------------: SPECIAL: invisible when on top of a vent, emerges when prey approaches or gets trapped in webs
// -------------: TO FIGHT IT: shoot it through a window, or make it regret ambushing you
// -------------: CONCEPT: http://tvtropes.org/pmwiki/pmwiki.php/Main/StealthExpert
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/gray
	name = "gray terror spider"
	desc = "An ominous-looking gray spider, its color and shape makes it hard to see."
	altnames = list("Gray Trap spider","Gray Stalker spider","Ghostly Ambushing spider")
	spider_role_summary = "Stealth spider that ambushes weak humans from vents."

	icon_state = "terror_gray"
	icon_living = "terror_gray"
	icon_dead = "terror_gray_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its almost invisible.
	health = 120
	melee_damage_lower = 15 // same as guard spider, its a melee class
	melee_damage_upper = 20
	ventcrawler = 1
	move_to_delay = 5 // normal speed
	stat_attack = 1 // ensures they will target people in crit, too!
	environment_smash = 1
	wander = 0 // wandering defeats the purpose of stealth
	idle_vision_range = 3 // very low idle vision range
	ai_hides_in_vents = 1
	vision_type = null // prevent them seeing through walls when doing AOE web.


/mob/living/simple_animal/hostile/poison/terror_spider/gray/adjustBruteLoss(var/damage)
	..(damage)
	if (invisibility > 0 || icon_state == "terror_gray_cloaked")
		GrayDeCloak()

/mob/living/simple_animal/hostile/poison/terror_spider/gray/adjustFireLoss(var/damage)
	..(damage)
	if (invisibility > 0 || icon_state == "terror_gray_cloaked")
		GrayDeCloak()

/mob/living/simple_animal/hostile/poison/terror_spider/gray/Aggro()
	GrayDeCloak()
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/gray/AttackingTarget()
	if (invisibility > 0 || icon_state == "terror_gray_cloaked")
		GrayDeCloak()
	else
		..()

/mob/living/simple_animal/hostile/poison/terror_spider/proc/GrayCloak()
	visible_message("<span class='notice'> [src] hides in the vent.</span>")
	invisibility = SEE_INVISIBLE_LEVEL_ONE
	icon_state = "terror_gray_cloaked"
	icon_living = "terror_gray_cloaked"
	if (!ckey)
		vision_range = 3
		idle_vision_range = 3
	// Bugged, does not work yet. Also spams webs. Also doesn't look great. But... planned.
	move_to_delay = 15 // while invisible, slow.

/mob/living/simple_animal/hostile/poison/terror_spider/proc/GrayDeCloak()
	invisibility = 0
	icon_state = "terror_gray"
	icon_living = "terror_gray"
	vision_range = 9
	idle_vision_range = 9
	move_to_delay = 5
	if (ai_hides_in_vents)
		prob_ai_hides_in_vents = 10


#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON