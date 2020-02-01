
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 BLACK TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: assassin, poisoner, DoT expert
// -------------: AI: attacks to inject its venom, then retreats. Will inject its enemies multiple times then hang back to ensure they die.
// -------------: SPECIAL: venom that does more damage the more of it is in you
// -------------: TO FIGHT IT: if bitten once, retreat, get charcoal/etc treatment, and come back with a gun.
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/black
	name = "Black Terror spider"
	desc = "An ominous-looking spider, black as the darkest night. It has merciless eyes, and a blood-red hourglass pattern on its back."
	spider_role_summary = "Hit-and-run attacker with extremely venomous bite."
	ai_target_method = TS_DAMAGE_POISON

	icon_state = "terror_widow"
	icon_living = "terror_widow"
	icon_dead = "terror_widow_dead"
	maxHealth = 120 // same health as hunter spider, aka, pretty weak.. but its bite will kill you!
	health = 120
	melee_damage_lower = 5
	melee_damage_upper = 10
	web_type = /obj/structure/spider/terrorweb/black
	stat_attack = UNCONSCIOUS // ensures they will target people in crit, too!
	spider_tier = TS_TIER_2


/mob/living/simple_animal/hostile/poison/terror_spider/black/spider_specialattack(mob/living/carbon/human/L, poisonable)
	if(!poisonable)
		return ..()
	if(L.reagents.has_reagent("terror_black_toxin", 100))
		return ..()
	var/inject_target = pick("chest", "head")
	if(L.stunned || L.can_inject(null, FALSE, inject_target, FALSE))
		L.reagents.add_reagent("terror_black_toxin", 30) // inject our special poison
		visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [target]!</span>")
	else
		visible_message("<span class='danger'>[src] bites [target], but cannot inject venom into [target.p_their()] [inject_target]!</span>")
	L.attack_animal(src)
	if(!ckey && (!(target in enemies) || L.reagents.has_reagent("terror_black_toxin", 60)))
		step_away(src, L)
		step_away(src, L)
		LoseTarget()
		step_away(src, L)
		visible_message("<span class='notice'>[src] jumps away from [L]!</span>")


/obj/structure/spider/terrorweb/black
	name = "sinister web"
	desc = "This web has beads of a dark fluid on its strands."

/obj/structure/spider/terrorweb/black/web_special_ability(mob/living/carbon/C)
	if(istype(C))
		if(!C.reagents.has_reagent("terror_black_toxin", 60))
			var/inject_target = pick("chest","head")
			if(C.can_inject(null, FALSE, inject_target, FALSE))
				to_chat(C, "<span class='danger'>[src] slices into you!</span>")
				C.reagents.add_reagent("terror_black_toxin", 30)