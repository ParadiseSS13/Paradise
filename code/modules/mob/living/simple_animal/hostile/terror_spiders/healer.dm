
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: T1 HEALER TERROR ------------------------------
// --------------------------------------------------------------------------------
// -------------: ROLE: reproduction
// -------------: AI: after it kills you, it webs you and lays new terror eggs on your body
// -------------: SPECIAL: can also create webs, web normal objects, etc
// -------------: TO FIGHT IT: kill it however you like - just don't die to it!
// -------------: SPRITES FROM: FoS, https://www.paradisestation.org/forum/profile/335-fos

/mob/living/simple_animal/hostile/poison/terror_spider/healer
	name = "Healer of Terror"
	desc = "An ominous-looking green spider. It has a small egg-sac attached to it, and dried blood stains on its carapace."
	ai_target_method = TS_DAMAGE_BRUTE
	icon_state = "terror_green"
	icon_living = "terror_green"
	icon_dead = "terror_green_dead"
	maxHealth = 110
	health = 110
	death_sound = 'sound/creatures/terrorspiders/death4.ogg'
	speed = -0.1
	delay_web = 20
	melee_damage_lower = 10
	melee_damage_upper = 15
	web_type = /obj/structure/spider/terrorweb/green
	special_abillity = list(/obj/effect/proc_holder/spell/aoe_turf/terror/healing_lesser)
	spider_intro_text = "Будучи Лекарем Ужаса, ваша задача исцелять других пауков и откладывать яйца. Чем больше трупов вы поглотили, тем эффективнее исцеление, однако, для откладывания яиц, вам также необходимы трупы."
	var/feedings_to_lay = 2
	var/datum/action/innate/terrorspider/greeneggs/greeneggs_action
	tts_seed = "Mortred"


/mob/living/simple_animal/hostile/poison/terror_spider/healer/New()
	..()
	greeneggs_action = new()
	greeneggs_action.Grant(src)

/mob/living/simple_animal/hostile/poison/terror_spider/healer/proc/DoLayGreenEggs()
	var/obj/structure/spider/eggcluster/E = locate() in get_turf(src)
	if(E)
		to_chat(src, "<span class='notice'>There is already a cluster of eggs here!</span>")
		return
	if(fed < feedings_to_lay)
		to_chat(src, "<span class='warning'>You must wrap more humanoid prey before you can do this!</span>")
		return
	var/list/eggtypes = list(TS_DESC_KNIGHT, TS_DESC_LURKER, TS_DESC_HEALER, TS_DESC_REAPER, TS_DESC_BUILDER)
	var/list/spider_array = CountSpidersDetailed(FALSE)
	if(spider_array[/mob/living/simple_animal/hostile/poison/terror_spider/destroyer] < 2)
		eggtypes += TS_DESC_DESTROYER
	if(spider_array[/mob/living/simple_animal/hostile/poison/terror_spider/widow] < 2)
		eggtypes += TS_DESC_WIDOW
	var/eggtype = pick(eggtypes)
	if(client)
		eggtype = input("What kind of eggs?") as null|anything in eggtypes
		if(!(eggtype in eggtypes))
			to_chat(src, "<span class='danger'>Unrecognized egg type.</span>")
			return 0
	if(!isturf(loc))
		// This has to be checked after we ask the user what egg type. Otherwise they could trigger prompt THEN move into a vent.
		to_chat(src, "<span class='danger'>Eggs can only be laid while standing on a floor.</span>")
		return
	if(fed < feedings_to_lay)
		// We have to check this again after the popup, to account for people spam-clicking the button, then doing all the popups at once.
		to_chat(src, "<span class='warning'>You must wrap more humanoid prey before you can do this!</span>")
		return
	visible_message("<span class='notice'>[src] lays a cluster of eggs.</span>")
	if(eggtype == TS_DESC_KNIGHT)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/knight, 1)
	else if(eggtype == TS_DESC_LURKER)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/lurker, 1)
	else if(eggtype == TS_DESC_HEALER)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/healer, 1)
	else if(eggtype == TS_DESC_REAPER)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/reaper, 1)
	else if(eggtype == TS_DESC_BUILDER)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/builder, 1)
	else if(eggtype == TS_DESC_WIDOW)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/widow, 1)
	else if(eggtype == TS_DESC_DESTROYER)
		DoLayTerrorEggs(/mob/living/simple_animal/hostile/poison/terror_spider/destroyer, 1)
	else
		to_chat(src, "<span class='warning'>Unrecognized egg type!</span>")
		fed += feedings_to_lay
	fed -= feedings_to_lay

/mob/living/simple_animal/hostile/poison/terror_spider/healer/spider_special_action()
	if(cocoon_target)
		handle_cocoon_target()
	else if(fed >= feedings_to_lay)
		DoLayGreenEggs()
	else if(world.time > (last_cocoon_object + freq_cocoon_object))
		seek_cocoon_target()

/mob/living/simple_animal/hostile/poison/terror_spider/healer/spider_specialattack(mob/living/carbon/human/L, poisonable)
	if(!poisonable)
		..()
		return
	var/inject_target = pick("chest","head")
	if(L.stunned || L.can_inject(null, FALSE, inject_target, FALSE))
		if(L.eye_blurry < 60)
			L.AdjustEyeBlurry(10)
		// instead of having a venom that only lasts seconds, we just add the eyeblur directly.
		visible_message("<span class='danger'>[src] buries its fangs deep into the [inject_target] of [target]!</span>")
	else
		visible_message("<span class='danger'>[src] bites [target], but cannot inject venom into [target.p_their()] [inject_target]!</span>")
	L.attack_animal(src)

/mob/living/simple_animal/hostile/poison/terror_spider/healer/AttackingTarget()
	. = ..()
	if(isterrorspider(target) && target != src) //no self healing
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(fed <= 1)
				new /obj/effect/temp_visual/heal(get_turf(L), "#00ff00")
				L.adjustBruteLoss(-3)
			if(fed == 2)
				new /obj/effect/temp_visual/heal(get_turf(L), "#0077ff")
				L.adjustBruteLoss(-5)
			if(fed >= 3)
				new /obj/effect/temp_visual/heal(get_turf(L), "#ff0000")
				L.adjustBruteLoss(-6)

/obj/structure/spider/terrorweb/green
	name = "slimy web"
	desc = "This web is partly composed of strands of green slime."

/obj/structure/spider/terrorweb/green/web_special_ability(mob/living/carbon/C)
	if(istype(C))
		if(C.eye_blurry < 60)
			C.AdjustEyeBlurry(30)

