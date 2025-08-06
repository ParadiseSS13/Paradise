
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T3 MOTHER OF TERROR --------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: support (team medic)
// -------------: AI: none (only effective under player control, alongside other player-controlled spiders)
// -------------: SPECIAL: picks up / carries spiderlings to prevent them being killed. Creates royal jellies to heal spiders.
// -------------: TO FIGHT IT: shoot it, it will die quickly
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/mother
	name = "Mother of Terror spider"
	desc = "An enormous spider. Tiny spiderlings are crawling all over it. Their beady little eyes all stare at you. The horror!"
	spider_role_summary = "Carries spiderlings to protect them. Creates royal jelly that heals other spiders."
	spider_intro_text = "As a Mother of Terror Spider, your role is to support other spiders and spiderlings. \
	You can pickup and incubate spiderlings to ensure they mature safely and at a faster rate, and your webs cannot be passed by spiderlings to keep them closer to nests. \
	You can also produce royal jelly for other spiders to consume for faster health regeneration. \
	Both of these require you to expend your own regeneration, though you gain much more from webbing corpses than other spiders. \
	While you can open powered doors and bust open vents like a brown spider, you have low health and deal low damage, so you should avoid fights wherever possible."
	icon_state = "terror_mother"
	icon_living = "terror_mother"
	icon_dead = "terror_mother_dead"
	melee_damage_lower = 10
	regen_points_per_tick = 2
	regen_points_max = 400 // enough to lay 4 jellies, if fully charged
	regen_points_per_kill = 200 // >2x normal, since they're food reprocessors
	idle_ventcrawl_chance = 5
	spider_tier = TS_TIER_3
	loudspeaker = TRUE
	spider_opens_doors = 2
	web_type = /obj/structure/spider/terrorweb/mother

	var/jelly_cost = 100


/mob/living/simple_animal/hostile/poison/terror_spider/mother/Initialize(mapload)
	. = ..()
	var/static/list/action_paths = list(
		/datum/action/innate/terrorspider/ventsmash,
		/datum/action/innate/terrorspider/remoteview,
		/datum/action/innate/terrorspider/mother/royaljelly,
		/datum/action/innate/terrorspider/mother/gatherspiderlings,
		/datum/action/innate/terrorspider/mother/incubateeggs,
	)
	for(var/action_path in action_paths)
		var/datum/action/act = new action_path
		act.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/mother/death(gibbed)
	DropSpiderlings()
	. = ..()

/mob/living/simple_animal/hostile/poison/terror_spider/mother/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	// Provides a status panel indicator, showing mothers how many regen points they have.
	if(ckey && stat == CONSCIOUS)
		status_tab_data[++status_tab_data.len] = list("Regeneration Points:", "[regen_points]")

/mob/living/simple_animal/hostile/poison/terror_spider/mother/examine(mob/user)
	. = ..()
	if(!key || stat == DEAD)
		return
	if(!isobserver(user) && !isterrorspider(user))
		return
	. += "<span class='notice'>[p_they(TRUE)] is carrying [length(contents)] spiderlings.</span>"

/mob/living/simple_animal/hostile/poison/terror_spider/mother/proc/DoCreateJelly()
	// Mothers create jellies, which other terrors eat to get regeneration points, just like they get from wrapping corpses.
	// Jellies are essentially health packs that provide healing over time.
	if(regen_points < jelly_cost)
		to_chat(src, "<span class='danger'>You only have [regen_points] of the [jelly_cost] regeneration points you need to do this.</span>")
		return
	if(!isturf(loc))
		to_chat(src, "<span class='danger'>You can only secrete jelly while standing on a floor.</span>")
		return
	var/turf/mylocation = get_turf(src)
	if(isspaceturf(mylocation))
		to_chat(src, "<span class='danger'>Cannot secrete jelly in space.</span>")
		return
	visible_message("<span class='notice'>[src] begins to secrete royal jelly.</span>")
	if(do_after_once(src, 100, target = loc, attempt_cancel_message = "You stop producing jelly."))
		if(loc != mylocation)
			return
		if(regen_points < jelly_cost)
			to_chat(src, "<span class='danger'>You only have [regen_points] of the [jelly_cost] regeneration points you need to do this.</span>")
			return
		new /obj/structure/spider/royaljelly(loc)
		regen_points -= jelly_cost

/mob/living/simple_animal/hostile/poison/terror_spider/mother/consume_jelly(obj/structure/spider/royaljelly/J)
	// Jellies give more regeneration points to the spider who eats them than they cost the mother to create.
	// This makes them cost-efficient. But it also means we can't let mothers eat jellies, or they could keep cycling them for infinite points.
	to_chat(src, "<span class='warning'>Mothers cannot consume royal jelly.</span>")
	return

/mob/living/simple_animal/hostile/poison/terror_spider/mother/proc/PickupSpiderlings()
	// Mothers can pick up spiderlings, carrying them on their back and stopping them from wandering into trouble.
	var/pickup_count = 0
	for(var/obj/structure/spider/spiderling/terror_spiderling/S in orange(2, src))
		var/turf/T = get_turf(S)
		new /obj/effect/temp_visual/heal(T)
		S.movement_disabled = TRUE
		S.forceMove(src)
		pickup_count++
	if(pickup_count)
		to_chat(src, "<span class='notice'>You pick up [pickup_count] spiderling(s), storing them safely on your back.")
	else
		to_chat(src, "<span class='warning'>There are no spiderlings close enough for you to pick up.")

/mob/living/simple_animal/hostile/poison/terror_spider/mother/proc/DropSpiderlings()
	// Called when a mother dies.
	var/turf/T = get_turf(src)
	for(var/obj/structure/spider/spiderling/terror_spiderling/S in src)
		S.movement_disabled = FALSE
		S.forceMove(T)
		S.immediate_ventcrawl = TRUE

/mob/living/simple_animal/hostile/poison/terror_spider/mother/proc/IncubateEggs()
	// Mothers can spend regen points to make existing eggs mature faster.
	// This lets mothers save the spiderlings from eggs that would otherwise be lost when a nest is about to get wiped out.
	if(regen_points < 50)
		to_chat(src, "<span class='danger'>You only have [regen_points] of the 50 regeneration points required to do this.</span>")
		return
	for(var/obj/structure/spider/eggcluster/terror_eggcluster/C in orange(0, src))
		var/turf/T = get_turf(C)
		new /obj/effect/temp_visual/heal(T)
		C.amount_grown += 25
		regen_points -= 25
		to_chat(src, "<span class='notice'>You warm [C], encouraging faster growth.")
		return
	to_chat(src, "<span class='warning'>The 'incubate eggs' ability can only be used on top of existing eggs.")

/obj/structure/spider/terrorweb/mother
	name = "mother web"
	desc = "This web is coated in pheromones which prevent spiderlings from passing it."

/obj/structure/spider/terrorweb/mother/CanPass(atom/movable/mover, border_dir)
	if(istype(mover, /obj/structure/spider/spiderling/terror_spiderling))
		return FALSE
	return ..()
