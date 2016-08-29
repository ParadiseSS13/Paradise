
/mob/living/simple_animal/hostile/poison/terror_spider/verb/ShowGuide()
	set name = "Show Guide"
	set category = "Spider"
	set desc = "Learn how to spider."
	var/list/guidelist = list()
	guidelist += "------------------------"
	guidelist += "Intro:"
	guidelist += "- Terror Spiders are a bioweapon, created when the Syndicate mixed Giant Spider and Xenomorph DNA."
	guidelist += "- Ruled by Queens, they are aggressive, and very good in melee combat."
	guidelist += " "
	guidelist += "Communications:"
	guidelist += "<B>- You speak over the Terror Spider hivemind by default. All other TS hear this. To speak common, use :9 or .9 </B>"
	guidelist += "- Terror Spiders are the nuke ops of spiders. They work as a team. Communicate regularly!"
	guidelist += " "
	guidelist += "Verbs:"
	guidelist += " - Show Guide - Shows this guide."
	guidelist += " - Web - Spins a terror web. Non-spiders get trapped if they touch a web."
	guidelist += " - Eat Corpse - Eat the corpse of a dead foe to boost your regeneration"
	guidelist += "------------------------"
	guidelist += " "
	to_chat(src, guidelist.Join("<BR>"))

// ---------- WEB

/mob/living/simple_animal/hostile/poison/terror_spider/verb/Web()
	set name = "Lay Web"
	set category = "Spider"
	set desc = "Spin a sticky web to slow down prey."
	visible_message("<span class='notice'>\the [src] begins to secrete a sticky substance.</span>")
	if(do_after(src, 40, target = loc))
		new /obj/effect/spider/terrorweb(loc)

/obj/effect/spider/terrorweb
	name = "terror web"
	desc = "it's stringy and sticky"
	icon = 'icons/effects/effects.dmi'
	anchored = 1 // prevents people dragging it
	density = 0 // prevents it blocking all movement
	health = 20 // two welders, or one laser shot (15 for the normal spider webs)
	icon_state = "stickyweb1"


/obj/effect/spider/terrorweb/New()
	if(prob(50))
		icon_state = "stickyweb2"


/obj/effect/spider/terrorweb/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1
	if(istype(mover, /mob/living/simple_animal/hostile/poison/terror_spider))
		return 1
	if(istype(mover, /mob/living))
		if(prob(80))
			to_chat(mover, "<span class='danger'>You get stuck in \the [src] for a moment.</span>")
			var/mob/living/M = mover
			M.Stun(5) // 5 seconds.
			M.Weaken(5) // 5 seconds.
			return 1
		else
			return 0
	if(istype(mover, /obj/item/projectile))
		return prob(20)
	return ..()



// ---------- WRAP


/mob/living/simple_animal/hostile/poison/terror_spider/verb/EatCorpse()
	set name = "Eat Corpse"
	set category = "Spider"
	set desc = "Takes a bite out of a humanoid. Increases regeneration. Use on dead bodies is preferable!"
	var/choices = list()
	for(var/mob/living/L in oview(1,src))
		if(L in nibbled)
			continue
		if(Adjacent(L))
			if(L.stat != CONSCIOUS)
				choices += L
	var/nibbletarget = input(src,"What do you wish to nibble?") in null|choices
	if(!nibbletarget)
		// cancel
	else if(nibbletarget in nibbled)
		to_chat(src, "You have already eaten some of [nibbletarget]. Their blood is no use to you now.")
	else
		nibbled += nibbletarget
		regen_points += regen_points_per_kill
		to_chat(src, "You take a bite out of [nibbletarget], boosting your regeneration for awhile.")
		src.do_attack_animation(nibbletarget)
		if(spider_debug)
			to_chat(src, "You now have [regen_points] regeneration points.")

