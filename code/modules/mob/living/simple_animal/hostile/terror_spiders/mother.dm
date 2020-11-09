
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 MOTHER OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: support (team medic)
// -------------: AI: none (only effective under player control, alongside other player-controlled spiders)
// -------------: SPECIAL: creates royal jellies which boost health regen of other spiders
// -------------: TO FIGHT IT: shoot it, it will die quickly
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/mother
	name = "Mother of Terror spider"
	desc = "An enormous spider. Hundreds of tiny spiderlings are crawling all over it. Their beady little eyes all stare at you. The horror!"
	spider_role_summary = "Schmuck bait. Extremely weak in combat, but spawns many spiderlings when it dies."
	ai_target_method = TS_DAMAGE_SIMPLE
	icon_state = "terror_mother"
	icon_living = "terror_mother"
	icon_dead = "terror_mother_dead"
	maxHealth = 120 // same combat stats as an unboosted T1 gray. Very weak in combat.
	health = 120
	melee_damage_lower = 10
	melee_damage_upper = 20
	regen_points_max = 400 // enough to lay 4 jellys
	regen_points_per_kill = 200 // >2x normal, since they're food reprocessors
	idle_ventcrawl_chance = 5
	spider_tier = TS_TIER_3
	spider_opens_doors = 2
	web_type = null // ideally they'd have a super useful web, for more diverse stuff to do, but that's for a future update
	var/datum/action/innate/terrorspider/ventsmash/ventsmash_action
	var/datum/action/innate/terrorspider/mother/royaljelly/royaljelly_action
	var/datum/action/innate/terrorspider/remoteview/remoteview_action
	var/jelly_cost = 100


/mob/living/simple_animal/hostile/poison/terror_spider/mother/New()
	..()
	ventsmash_action = new()
	ventsmash_action.Grant(src)
	royaljelly_action = new()
	royaljelly_action.Grant(src)
	remoteview_action = new()
	remoteview_action.Grant(src)


/mob/living/simple_animal/hostile/poison/terror_spider/mother/Stat()
	..()
	// Provides a status panel indicator, showing mothers how many regen points they have.
	if(statpanel("Status") && ckey && stat == CONSCIOUS)
		stat(null, "Regeneration Points: [regen_points]")

/mob/living/simple_animal/hostile/poison/terror_spider/mother/proc/DoCreateJelly()
	if(regen_points < jelly_cost)
		to_chat(src, "<span class='danger'>You need [jelly_cost] regeneration points to do this.</span>")
		return
	var/turf/mylocation = get_turf(src)
	if(isspaceturf(mylocation))
		to_chat(src, "<span class='danger'>Cannot secrete jelly in space.</span>")
		return
	visible_message("<span class='notice'>[src] begins to secrete royal jelly.</span>")
	if(do_after(src, 100, target = loc))
		if(loc != mylocation)
			return
		new /obj/structure/spider/royaljelly(loc)
		regen_points -= jelly_cost
