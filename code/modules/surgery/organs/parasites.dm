
// Traitor-only space spider eggs: https://github.com/ParadiseSS13/Paradise/pull/3862

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



// Terror Spiders - white spider infection: https://github.com/ParadiseSS13/Paradise/pull/4229

/obj/item/organ/internal/body_egg/terror_eggs
	name = "terror eggs"
	icon = 'icons/effects/effects.dmi'
	icon_state = "eggs"
	var/wdstage = 1
	var/awaymission_infection = 0
	var/alternate_ending = 0

/obj/item/organ/internal/body_egg/terror_eggs/on_life()
	wdstage += 1
	if(owner.health < -25)
		to_chat(owner,"<span class='notice'> You feel a strange, blissful senstation.</span>")
		owner.adjustBruteLoss(-5)
		owner.adjustFireLoss(-5)
		owner.adjustToxLoss(-5)
		// the spider eggs secrete stimulants/etc to keep their host alive until they hatch
	switch (wdstage)
		if (1) // immediately
			to_chat(owner,"<span class='danger'> Your spider bite wound hurts horribly! </span>")
			if(istype(get_area(owner), /area/awaycontent) || istype(get_area(owner), /area/awaymission/))
				awaymission_infection = 1
		if (15) // 30 seconds... enough time for the nerve agent to kick in, the pain to be blocked, and healing to begin
			to_chat(owner,"<span class='notice'> The pain has faded, and stopped bleeding, though the skin around it has turned black.</span>")
			owner.adjustBruteLoss(-10)
		if (60) // 2 minutes... the point where the venom uses and accellerates the healing process, to feed the eggs
			to_chat(owner,"<span class='notice'> Your bite wound has completely sealed up, though the skin is still black. You feel significantly better.</span>")
			owner.adjustBruteLoss(-20)
		if (120) // 4 minutes... where the eggs are developing, and the wound is turning into a hatching site, but invisibly
			to_chat(owner,"<span class='notice'> The black flesh around your old spider bite wound has started to peel off.</span>")
		if (150) // 5 minutes... where the victim realizes something is wrong - this is not a normal wound
			to_chat(owner,"<span class='danger'> The black flesh around your spider bite wound has cracked, and started to split open!</span>")
		if (165) // 5m 30s
			to_chat(owner,"<span class='danger'> The black flesh splits open completely, revealing a cluster of small black oval shapes inside you, shapes that seem to be moving!</span>")
		if (180) // 6m
			if (awaymission_infection && !istype(get_area(owner), /area/awaycontent) && !istype(get_area(owner), /area/awaymission/))
				// we started in the awaymission, we ended on the station.
				// To prevent someone bringing an infection back, we're going to trigger an alternate, equally-bad result here.
				// Actually, let's make it slightly worse... just to discourage people from bringing back infections.
				alternate_ending = 1
			to_chat(owner,"<span class='danger'> The shapes extend tendrils out of your wound... no... those are legs! SPIDER LEGS! You have spiderlings growing inside you! You scratch at the wound, but it just aggrivates them - they swarm out of the wound, biting you all over!</span>")
			owner.visible_message("<span class='danger'>[owner] flails around on the floor as spiderlings erupt from their skin and swarm all over them! </span>")
			owner.Stun(20)
			owner.Weaken(20)
			// yes, this is a hella long stun - that's intentional. Gotta give the spiderlings time to escape.
			var/obj/effect/spider/terror_spiderling/S1 = new(get_turf(owner))
			S1.grow_as = /mob/living/simple_animal/hostile/poison/terror_spider/red
			S1.name = "red spiderling"
			var/obj/effect/spider/terror_spiderling/S2 = new(get_turf(owner))
			S2.grow_as = /mob/living/simple_animal/hostile/poison/terror_spider/gray
			S2.name = "gray spiderling"
			var/obj/effect/spider/terror_spiderling/S3 = new(get_turf(owner))
			S3.grow_as = /mob/living/simple_animal/hostile/poison/terror_spider/green
			S3.name = "green spiderling"
			if (alternate_ending)
				// This is the alternate ending of the infestation, triggered above by someone bringing back an infection from a gateway mission to the main station.
				// In this ending, we still spawn spiderlings - but we make sure they're stillborn, and don't grow up.
				// In addition, we give you an extra 60 toxin... enough to crit most people.
				S1.stillborn = 1
				S2.stillborn = 1
				S3.stillborn = 1
				// sneaky scumbag case, gib them for their trouble
				owner.gib()
			else
				owner.adjustToxLoss(rand(100,180)) // normal case, range: 100-180, average 140, almost crit (150).
		if (190) // 6m 30s
			to_chat(owner,"<span class='danger'>The spiderlings are gone. Your wound, though, looks worse than ever. Remnants of tiny spider eggs, and dead spiders, inside your flesh. Disgusting.</span>")
			owner.reagents.remove_reagent("terror_white_toxin")
			qdel(src)

/obj/item/organ/internal/body_egg/terror_eggs/remove(var/mob/living/carbon/M, var/special = 0)
	..()
	M.reagents.del_reagent("terror_white_toxin") // prevent reinfection
	qdel(src) // prevent people re-implanting them into others