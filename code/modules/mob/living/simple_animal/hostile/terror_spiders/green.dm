
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GREEN TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: reproduction
// -------------: AI: after it kills you, it webs you and lays new terror eggs on your body
// -------------: SPECIAL: can also create webs, web normal objects, etc
// -------------: TO FIGHT IT: kill it however you like - just don't die to it!
// -------------: SPRITES FROM: FoS, http://nanotrasen.se/phpBB3/memberlist.php?mode=viewprofile&u=386

/mob/living/simple_animal/hostile/poison/terror_spider/green
	name = "Green Terror spider"
	desc = "An ominous-looking green spider. It has a small egg-sac attached to it, and dried blood stains on its carapace."
	spider_role_summary = "Average melee spider that webs its victims and lays more spider eggs"
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_green"
	icon_living = "terror_green"
	icon_dead = "terror_green_dead"
	maxHealth = 150
	health = 150
	melee_damage_lower = 10
	melee_damage_upper = 20
	web_type = /obj/structure/spider/terrorweb/green
	var/feedings_to_lay = 2
	var/datum/action/innate/terrorspider/greeneggs/greeneggs_action


/mob/living/simple_animal/hostile/poison/terror_spider/green/New()
	..()
	greeneggs_action = new()
	greeneggs_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/green/proc/DoLayGreenEggs()
	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
		return
	if(fed < feedings_to_lay)
		to_chat(src, "<span class='warning'>You must wrap more humanoid prey before you can do this!</span>")
		return
	var/list/eggtypes = list(TS_DESC_RED, TS_DESC_GRAY, TS_DESC_GREEN)
	var/num_brown = CountSpidersType(/mob/living/simple_animal/hostile/poison/terror_spider/brown)
	if(num_brown < 2)
		eggtypes += TS_DESC_BROWN
	var/num_black = CountSpidersType(/mob/living/simple_animal/hostile/poison/terror_spider/black)
	if(num_black < 2)
		eggtypes += TS_DESC_BLACK
	var/eggtype = pick(eggtypes)
	if(client)
		eggtype = input("What kind of eggs?") as null|anything in eggtypes
		if(!(eggtype in eggtypes))
			to_chat(src, "<span class='danger'>Unrecognized egg type.</span>")
			return 0
	visible_message("<span class='notice'>[src] lays a cluster of eggs.</span>")
	if(eggtype == TS_DESC_RED)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/red, 1)
	else if(eggtype == TS_DESC_GRAY)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/gray, 1)
	else if(eggtype == TS_DESC_GREEN)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/green, 1)
	else if(eggtype == TS_DESC_BLACK)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/black, 1)
	else if(eggtype == TS_DESC_BROWN)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/brown, 1)
	else
		to_chat(src, "<span class='warning'>Unrecognized egg type!</span>")
		fed += feedings_to_lay
	fed -= feedings_to_lay

/mob/living/simple_animal/hostile/poison/terror_spider/green/spider_special_action()
	if(cocoon_target)
		handle_cocoon_target()
	else if(fed >= feedings_to_lay)
		DoLayGreenEggs()
	else if(world.time > (last_cocoon_object + freq_cocoon_object))
		seek_cocoon_target()

/mob/living/simple_animal/hostile/poison/terror_spider/green/spider_specialattack(mob/living/carbon/human/L, poisonable)
	if(!poisonable)
		..()
		return
	var/inject_target = pick("chest","head")
	if(L.stunned || L.can_inject(null,0,inject_target,0))
		if(L.eye_blurry < 60)
			L.AdjustEyeBlurry(10)
		// instead of having a venom that only lasts seconds, we just add the eyeblur directly.
		visible_message("<span class='danger'>[src] buries its fangs deep into the [inject_target] of [target]!</span>")
	else
		visible_message("<span class='danger'>[src] bites [target], but cannot inject venom into [target.p_their()] [inject_target]!</span>")
	L.attack_animal(src)

/obj/structure/spider/terrorweb/green
	name = "slimy web"
	desc = "This web is partly composed of strands of green slime."

/obj/structure/spider/terrorweb/green/web_special_ability(mob/living/carbon/C)
	if(istype(C))
		if(C.eye_blurry < 60)
			C.AdjustEyeBlurry(30)

