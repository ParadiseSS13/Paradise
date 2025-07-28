
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 GREEN TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: reproduction
// -------------: AI: after it kills you, it webs you and lays new terror eggs on your body
// -------------: SPECIAL: can also create webs, web normal objects, etc
// -------------: TO FIGHT IT: kill it however you like - just don't die to it!
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/green
	name = "Green Terror spider"
	desc = "An ominous-looking green spider. It has a small egg-sac attached to it, and dried blood stains on its carapace."
	spider_role_summary = "Average melee spider that webs its victims and lays more spider eggs"
	spider_intro_text = "As a Green Terror Spider, your role is to lay and protect spider eggs so they can hatch and mature into more spiders. \
	You can lay a new set of eggs for every 2 corpses you web, so work with other spiders to collect as many bodies as you can. \
	To aid with this you have moderate health and deal moderate damage, with your bite and webs blurring the vision of any victims."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_green"
	icon_living = "terror_green"
	icon_dead = "terror_green_dead"
	maxHealth = 150
	health = 150
	melee_damage_lower = 10
	web_type = /obj/structure/spider/terrorweb/green
	var/feedings_to_lay = 2


/mob/living/simple_animal/hostile/poison/terror_spider/green/Initialize(mapload)
	. = ..()
	var/datum/action/innate/terrorspider/greeneggs/act = new
	act.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/green/proc/DoLayGreenEggs()
	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
		return
	if(fed < feedings_to_lay)
		to_chat(src, "<span class='warning'>You must wrap more humanoid prey before you can do this!</span>")
		return
	var/list/eggtypes = list(TS_DESC_RED, TS_DESC_GRAY, TS_DESC_GREEN)
	var/list/spider_array = CountSpidersDetailed(FALSE)
	if(spider_array[/mob/living/simple_animal/hostile/poison/terror_spider/brown] < 2)
		eggtypes += TS_DESC_BROWN
	if(spider_array[/mob/living/simple_animal/hostile/poison/terror_spider/black] < 2)
		eggtypes += TS_DESC_BLACK
	var/eggtype = pick(eggtypes)
	if(client)
		eggtype = tgui_input_list(src, "What kind of eggs?", "Egg Laying", eggtypes)
		if(!(eggtype in eggtypes))
			to_chat(src, "<span class='danger'>Unrecognized egg type.</span>")
			return FALSE
	if(!isturf(loc))
		// This has to be checked after we ask the user what egg type. Otherwise they could trigger prompt THEN move into a vent.
		to_chat(src, "<span class='danger'>Eggs can only be laid while standing on a floor.</span>")
		return
	if(fed < feedings_to_lay)
		// We have to check this again after the popup, to account for people spam-clicking the button, then doing all the popups at once.
		to_chat(src, "<span class='warning'>You must wrap more humanoid prey before you can do this!</span>")
		return
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
	if(!L.attack_animal(src))
		return
	if(L.IsStunned() || L.can_inject(null, FALSE, inject_target, FALSE))
		L.AdjustEyeBlurry(20 SECONDS, 0, 120 SECONDS)
		// instead of having a venom that only lasts seconds, we just add the eyeblur directly.
		visible_message("<span class='danger'>[src] buries its fangs deep into the [inject_target] of [target]!</span>")
	else
		visible_message("<span class='danger'>[src] bites [target], but cannot inject venom into [target.p_their()] [inject_target]!</span>")

/obj/structure/spider/terrorweb/green
	name = "slimy web"
	desc = "This web is partly composed of strands of green slime."

/obj/structure/spider/terrorweb/green/web_special_ability(mob/living/carbon/C)
	if(istype(C))
		C.AdjustEyeBlurry(60 SECONDS, 0, 120 SECONDS)

