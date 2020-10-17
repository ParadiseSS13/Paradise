// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T2 WHITE TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: stealthy reproduction
// -------------: AI: injects a venom that makes you grow spiders in your body, then retreats
// -------------: SPECIAL: stuns you on first attack - vulnerable to groups while it does this
// -------------: TO FIGHT IT: blast it before it can get away
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/white
	name = "White Terror spider"
	desc = "An ominous-looking white spider, its ghostly eyes and vicious-looking fangs are the stuff of nightmares."
	spider_role_summary = "Rare, bite-and-run spider that infects hosts with spiderlings"
	ai_target_method = TS_DAMAGE_POISON
	icon_state = "terror_white"
	icon_living = "terror_white"
	icon_dead = "terror_white_dead"
	maxHealth = 200
	health = 200
	melee_damage_lower = 5
	melee_damage_upper = 15
	spider_tier = TS_TIER_2
	web_type = /obj/structure/spider/terrorweb/white


/mob/living/simple_animal/hostile/poison/terror_spider/white/LoseTarget()
	stop_automated_movement = 0
	attackstep = 0
	attackcycles = 0
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/white/death(gibbed)
	if(can_die() && !hasdied && spider_uo71)
		UnlockBlastDoors("UO71_Bridge")
	return ..(gibbed)

/mob/living/simple_animal/hostile/poison/terror_spider/white/spider_specialattack(mob/living/carbon/human/L, poisonable)
	if(!poisonable)
		..()
		return
	var/inject_target = pick("chest","head")
	L.attack_animal(src)
	if(L.stunned || L.paralysis || L.can_inject(null, FALSE, inject_target, FALSE))
		if(!IsTSInfected(L) && ishuman(L))
			visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [L]!</span>")
			new /obj/item/organ/internal/body_egg/terror_eggs(L)
			if(!ckey)
				LoseTarget()
				walk_away(src,L,2,1)
		else if(prob(25))
			visible_message("<span class='danger'>[src] pounces on [L]!</span>")
			L.Weaken(5)
			L.Stun(5)

/proc/IsTSInfected(mob/living/carbon/C) // Terror AI requires this
	if(C.get_int_organ(/obj/item/organ/internal/body_egg))
		return 1
	return 0


/obj/structure/spider/terrorweb/white
	name = "infested web"
	desc = "This web is covered in hundreds of tiny, biting spiders - and their eggs."

/obj/structure/spider/terrorweb/white/web_special_ability(mob/living/carbon/C)
	if(istype(C))
		if(!IsTSInfected(C) && ishuman(C))
			var/inject_target = pick("chest","head")
			if(C.can_inject(null, FALSE, inject_target, FALSE))
				to_chat(C, "<span class='danger'>[src] slices into you!</span>")
				new /obj/item/organ/internal/body_egg/terror_eggs(C)

// Call in game via Advanced ProcCall in Debug tab with own character as mob reference argument
/datum/tests/terror_spider_white/gh12857/proc/run_test(mob/admin, cleanup="on_pass")
	var/turf/center = locate(156, 14, 2)
	admin.forceMove(center)

	var/turf/spider_turf = locate(center.x + 4, center.y, center.z)
	var/mob/living/simple_animal/hostile/poison/terror_spider/white/spidey = new /mob/living/simple_animal/hostile/poison/terror_spider/white(spider_turf)

	// A monkey with no armor. Should be infectable
	var/turf/monkey_turf = locate(center.x + 4, center.y+1, center.z)
	var/mob/living/carbon/human/monkey/monkey = new /mob/living/carbon/human/monkey(monkey_turf)

	// An engineer in a hardsuit. Should not be infectable
	var/turf/engi_turf = locate(center.x + 4, center.y-1, center.z)
	var/mob/living/carbon/human/engi = new /mob/living/carbon/human(engi_turf)
	var/obj/item/clothing/suit/space/hardsuit/hardsuit =  new /obj/item/clothing/suit/space/hardsuit/engine()
	engi.equip_to_slot_if_possible(hardsuit, slot_wear_suit)
	hardsuit.ToggleHelmet()

	spidey.UnarmedAttack(monkey)
	for (var/i=0; i < 5; i++)   // for good measure
		spidey.UnarmedAttack(engi)

	var/passed = TRUE
	if (!IsTSInfected(monkey))
		passed = FALSE
		message_admins("Mokey was bitten by a terror white and not infected.")
	if (IsTSInfected(engi))
		passed = FALSE
		message_admins("Engineer in a hardsuit was bitten by a terror and somehow got infected")

	if (!passed)
		message_admins("Spider injection test failed")
	if (cleanup == "always" || (passed && cleanup == "on_pass"))
		qdel(spidey)
		qdel(monkey)
		qdel(engi)
		for(var/obj/item in range(6, center))
			qdel(item)

	return passed
