/obj/item/organ/internal/body_egg/spider_eggs
	name = "spider eggs"
	icon = 'icons/effects/effects.dmi'
	icon_state = "eggs"
	var/stage = 1

/obj/item/organ/internal/body_egg/spider_eggs/on_life()
	if(stage < 5 && prob(3))
		stage++

	switch(stage)
		if(2)
			if(prob(3))
				owner.reagents.add_reagent("histamine", 2)
		if(3)
			if(prob(5))
				owner.reagents.add_reagent("histamine", 3)
		if(4)
			if(prob(12))
				owner.reagents.add_reagent("histamine", 5)
		if(5)
			to_chat(owner, "<span class='danger'>You feel like something is tearing its way out of your skin...</span>")
			owner.reagents.add_reagent("histamine", 10)
			if(prob(30))
				owner.emote("scream")
				var/spiders = rand(3,5)
				for(var/i in 1 to spiders)
					new/obj/effect/spider/spiderling(get_turf(owner))
				owner.visible_message("<span class='danger'>[owner] bursts open! Holy fuck!</span>")
				owner.gib()

/obj/item/organ/internal/body_egg/spider_eggs/remove(var/mob/living/carbon/M, var/special = 0)
	..()
	M.reagents.del_reagent("spidereggs") //purge all remaining spider eggs reagent if caught, in time.
	qdel(src) //We don't want people re-implanting these for near instant gibbings.
	return null
