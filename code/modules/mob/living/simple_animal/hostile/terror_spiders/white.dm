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
	spider_intro_text = "As a White Terror Spider, your role is to infect the crew with spider eggs which make them a host for future spiderlings. \
	Both your bite and webs will inject these eggs into your victims, which will gradually cause spiderlings to burst out of them unless removed through surgery. Your webs will not inject victims wearing full hardsuits. \
	You also have high health and while your attacks are weak, they will knock people down to make it harder for them to chase after you."
	ai_target_method = TS_DAMAGE_POISON
	icon_state = "terror_white"
	icon_living = "terror_white"
	icon_dead = "terror_white_dead"
	maxHealth = 200
	health = 200
	melee_damage_lower = 5
	melee_damage_upper = 15
	spider_tier = TS_TIER_2
	spider_opens_doors = 2
	loudspeaker = TRUE
	web_type = /obj/structure/spider/terrorweb/white


/mob/living/simple_animal/hostile/poison/terror_spider/white/LoseTarget()
	stop_automated_movement = FALSE
	attackstep = 0
	attackcycles = 0
	..()

/mob/living/simple_animal/hostile/poison/terror_spider/white/spider_specialattack(mob/living/carbon/human/L, poisonable)
	if(!poisonable)
		..()
		return
	var/inject_target = pick("chest","head")
	if(!L.attack_animal(src))
		return
	L.KnockDown(10 SECONDS)
	L.apply_damage(30, STAMINA)
	if(L.can_inject(null, FALSE, inject_target, FALSE) || (HAS_TRAIT(L, TRAIT_HANDS_BLOCKED) && HAS_TRAIT(L, TRAIT_IMMOBILIZED)))
		if(!IsTSInfected(L) && ishuman(L))
			visible_message("<span class='danger'>[src] buries its long fangs deep into the [inject_target] of [L]!</span>")
			new /obj/item/organ/internal/body_egg/terror_eggs(L)
			if(!ckey)
				LoseTarget()
				GLOB.move_manager.move_away(src,L,2,1)

/proc/IsTSInfected(mob/living/carbon/C) // Terror AI requires this
	if(C.get_int_organ(/obj/item/organ/internal/body_egg))
		return 1
	return 0

/obj/item/organ/internal/body_egg/terror_eggs/Initialize(mapload)
	. = ..()
	GLOB.ts_infected_list += src

/obj/item/organ/internal/body_egg/terror_eggs/insert(mob/living/carbon/M, special)
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(readd_infected))

/obj/item/organ/internal/body_egg/terror_eggs/proc/readd_infected(mob/infected, new_stat, old_stat)
	SIGNAL_HANDLER
	if(new_stat != DEAD)
		GLOB.ts_infected_list |= src

/obj/item/organ/internal/body_egg/terror_eggs/Destroy()
	GLOB.ts_infected_list -= src
	return ..()

/obj/item/organ/internal/body_egg/terror_eggs/on_owner_death()
	GLOB.ts_infected_list -= src
	return ..()

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
