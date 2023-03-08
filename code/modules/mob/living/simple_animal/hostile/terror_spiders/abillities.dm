//TERROR SPIDERS ABILLITIES

//TIER 1 SPIDERS

//LURKER//

//STEALTH AKA INVISIBILLITY
/obj/effect/proc_holder/spell/targeted/genetic/terror/stealth
	name = "Stealth"
	desc = "Become completely invisible for a short time."
	charge_max = 300
	action_icon_state = "stealth"
	action_background_icon_state = "bg_terror"
	clothes_req = FALSE
	range = -1
	include_user = 1
	duration = 70
	sound = 'sound/creatures/terrorspiders/stealth.ogg'

/obj/effect/proc_holder/spell/targeted/genetic/terror/stealth/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		target.alpha = 0
		target.visible_message("<span class='warning'>[target] suddenly disappears!</span>", "<span class='purple'>You are invisible now!</span>")
		spawn(duration)
			target.alpha = 255
			target.visible_message("<span class='warning'>[target] appears from nowhere!</span>", "<span class='purple'>You are visible again!</span>")
			playsound(usr, 'sound/creatures/terrorspiders/stealth_out.ogg', 150, 1)

	..()

//HEALER//

//LESSER HEALING
/obj/effect/proc_holder/spell/aoe_turf/terror/healing_lesser
	name = "Heal"
	desc = "Exude feromones to heal your allies"
	action_icon_state = "heal"
	action_background_icon_state = "bg_terror"
	charge_max = 300
	clothes_req = FALSE
	range = 6
	sound = 'sound/creatures/terrorspiders/heal.ogg'

/obj/effect/proc_holder/spell/aoe_turf/terror/healing_lesser/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		for(var/mob/target in T.contents)
			if(isterrorspider(target))
				var/mob/living/M  = target
				visible_message("<span class='green'>[src] exudes feromones and heals spiders around!</span>")
				M.adjustBruteLoss(-20)
				new /obj/effect/temp_visual/heal(get_turf(M), "#00ff0d")
				new /obj/effect/temp_visual/heal(get_turf(M), "#09ff00")
				new /obj/effect/temp_visual/heal(get_turf(M), "#09ff00")

//TIER 2 SPIDERS

//WIDOW//

//VENOM SPIT
/obj/effect/proc_holder/spell/targeted/click/fireball/terror
	name = "Venom spit"
	desc = "Spit an acid that creates smoke filled with drugs and venom on impact."
	charge_max = 250
	invocation_type = "none"
	selection_activated_message	= "<span class='notice'>Your prepare your venom spit! <B>Left-click to spit at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You cancel your spit.</span>"
	fireball_type = /obj/item/projectile/terrorspider/widow/venom
	action_icon_state = "fake_death"
	action_background_icon_state = "bg_terror"
	sound = 'sound/creatures/terrorspiders/spit2.ogg'

/obj/effect/proc_holder/spell/targeted/click/fireball/terror/update_icon()
	return

/obj/item/projectile/terrorspider/widow/venom
	name = "venom acid"
	damage = 5

/obj/item/projectile/terrorspider/widow/venom/on_hit(var/target)
	. = ..()
	var/datum/effect_system/smoke_spread/chem/S = new
	var/turf/T = get_turf(target)
	create_reagents(1250)
	reagents.add_reagent("thc", 250)
	reagents.add_reagent("psilocybin", 250)
	reagents.add_reagent("lsd", 250)
	reagents.add_reagent("space_drugs", 250)
	reagents.add_reagent("terror_black_toxin", 250)
	S.set_up(reagents, T, TRUE)
	S.start()

	return ..()

//SMOKE SPIT
/obj/effect/proc_holder/spell/targeted/click/fireball/terror/smoke
	name = "Smoke spit"
	desc = "Spit an acid that creates smoke on impact."
	charge_max = 100
	selection_activated_message	= "<span class='notice'>Your prepare your smoke spit! <B>Left-click to spit at a target!</B></span>"
	fireball_type = /obj/item/projectile/terrorspider/widow/smoke
	action_icon_state = "smoke"
	sound = 'sound/creatures/terrorspiders/spit2.ogg'

/obj/item/projectile/terrorspider/widow/smoke
	name = "smoke acid"
	damage = 5

/obj/item/projectile/terrorspider/widow/smoke/on_hit(var/target)
	. = ..()
	var/datum/effect_system/smoke_spread/smoke = new
	var/turf/T = get_turf(target)
	smoke.set_up(15, 0, T)
	smoke.start()

	return ..()

//DESTROYER//

//EMP
/obj/effect/proc_holder/spell/targeted/terror/emp
	name = "EMP shriek"
	desc = "Emits a shriek that causes EMP pulse."
	action_icon_state = "emp_new"
	action_background_icon_state = "bg_terror"
	charge_max = 400
	clothes_req = FALSE
	range = -1
	include_user = 1
	sound = 'sound/creatures/terrorspiders/brown_shriek.ogg'

/obj/effect/proc_holder/spell/targeted/terror/emp/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(isturf(usr.loc)) //to avoid cast from vents
			empulse(usr.loc, 3, 2, TRUE, cause = usr)

//EXPLOSION
/obj/effect/proc_holder/spell/targeted/terror/burn
	name = "Burn!"
	desc = "Release your energy to create a massive fire ring."
	action_icon_state = "explosion"
	action_background_icon_state = "bg_terror"
	charge_max = 600
	clothes_req = FALSE
	range = -1
	include_user = 1
	sound = 'sound/creatures/terrorspiders/brown_shriek.ogg'

/obj/effect/proc_holder/spell/targeted/terror/burn/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(isturf(usr.loc)) //to avoid cast from vents
			explosion(usr.loc, flame_range = 5, cause = usr)

//GUARD//

//SHIELD
/obj/effect/proc_holder/spell/aoe_turf/conjure/terror/shield
	name = "Guardian shield"
	desc = "Create a temporary organic shield to protect your hive."
	action_icon_state = "terror_shield"
	action_background_icon_state = "bg_terror"
	charge_max = 80
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	delay = 0
	range = 0
	cast_sound = 'sound/creatures/terrorspiders/mod_defence.ogg'
	summon_type = list(/obj/effect/forcefield/terror)

/obj/effect/forcefield/terror
	desc = "Thick protective membrane produced by Guardians of Terror."
	name = "Guardian shield"
	icon = 'icons/effects/effects.dmi'
	icon_state = "terror_shield"
	lifetime = 165                       //max 2 shields existing at one time
	light_color = LIGHT_COLOR_PURPLE

/obj/effect/forcefield/terror/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASS_OTHER_THINGS))
		return TRUE
	var/mob/living/M = get_mob_in_atom_without_warning(mover)
	if("terrorspiders" in M.faction)
		return TRUE
	return FALSE

//DEFILER//

//SMOKE
/obj/effect/proc_holder/spell/targeted/terror/smoke
	name = "Smoke"
	desc = "Erupt a smoke to confuse your enemies."
	charge_max = 100
	clothes_req = FALSE
	range = -1
	include_user = 1
	sound = 'sound/creatures/terrorspiders/attack2.ogg'
	action_icon_state = "smoke"
	action_background_icon_state = "bg_terror"

/obj/effect/proc_holder/spell/targeted/terror/smoke/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(isturf(usr.loc)) //to avoid cast from vents
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(15, 0, usr)
			smoke.start()

//PARALYSING SMOKE
/obj/effect/proc_holder/spell/targeted/terror/parasmoke
	name = "Paralyzing Smoke"
	desc = "Erupt a smoke to paralyze your enemies."
	charge_max = 400
	clothes_req = FALSE
	range = -1
	include_user = 1
	sound = 'sound/creatures/terrorspiders/attack2.ogg'
	action_icon_state = "biohazard"
	action_background_icon_state = "bg_terror"

/obj/effect/proc_holder/spell/targeted/terror/parasmoke/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(isturf(usr.loc)) //to avoid cast from vents
			var/datum/effect_system/smoke_spread/chem/S = new
			create_reagents(600)
			reagents.add_reagent("neurotoxin", 300)
			reagents.add_reagent("capulettium_plus", 300)
			S.set_up(reagents, usr, TRUE)
			S.start()

//INFESTING SMOKE
/obj/effect/proc_holder/spell/targeted/terror/infest
	name = "Infesting Smoke"
	desc = "Erupt a smoke to infest your enemies with spider eggs."
	charge_max = 600
	clothes_req = FALSE
	range = -1
	include_user = 1
	sound = 'sound/creatures/terrorspiders/white_shriek.ogg'
	action_icon_state = "biohazard2"
	action_background_icon_state = "bg_terror"

/obj/effect/proc_holder/spell/targeted/terror/infest/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(isturf(usr.loc)) //to avoid cast from vents
			var/datum/effect_system/smoke_spread/chem/S = new
			create_reagents(900)
			reagents.add_reagent("terror_eggs", 600)
			reagents.add_reagent("space_drugs", 300)
			S.set_up(reagents, usr, TRUE)
			S.start()

//TIER 3

//PRINCESS//

//SHRIEK
/obj/effect/proc_holder/spell/aoe_turf/terror/princess
	name = "Princess Shriek"
	desc = "Emits a loud shriek that weakens your enemies."
	action_icon_state = "terror_shriek"
	action_background_icon_state = "bg_terror"
	charge_max = 600
	clothes_req = FALSE
	range = 6
	sound = 'sound/creatures/terrorspiders/princess_shriek.ogg'

/obj/effect/proc_holder/spell/aoe_turf/terror/princess/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		for(var/mob/target in T.contents)
			if(iscarbon(target))
				var/mob/living/carbon/M = target
				to_chat(M, "<span class='danger'><b>A spike of pain drives into your head and scrambles your thoughts!</b></span>")
				M.AdjustConfused(5)
				M.Jitter(7)
				M.adjustStaminaLoss(33)
				M.slowed = 3
			else if(issilicon(target))
				var/mob/living/silicon/S = target
				to_chat(S, "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>")
				S << 'sound/misc/interference.ogg'
				playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
				do_sparks(5, 1, S)
				S.Weaken(4)

//PRINCE//

//SLAM
/obj/effect/proc_holder/spell/aoe_turf/terror/slam
	name = "Slam"
	desc = "Slam the ground with your body."
	action_icon_state = "slam"
	action_background_icon_state = "bg_terror"
	charge_max = 350
	clothes_req = FALSE
	range = 2

/obj/effect/proc_holder/spell/aoe_turf/terror/slam/cast(list/targets, mob/user = usr)
	playsound(usr, 'sound/creatures/terrorspiders/prince_attack.ogg', 150, 0)
	for(var/turf/T in targets)
		for(var/mob/target in T.contents)
			if(iscarbon(target))
				var/mob/living/carbon/M = target
				M.AdjustWeakened(1)
				M.slowed = 3
				M.adjustBruteLoss(20)
		var/turf/simulated/floor/tile = user.loc
		for(tile in range(2, user))
			tile.break_tile()

//MOTHER//

//JELLY PRODUCTION
/obj/effect/proc_holder/spell/aoe_turf/conjure/terror/jelly
	name = "Produce jelly"
	desc = "Produce an organic jelly that heals spiders."
	action_icon_state = "spiderjelly"
	action_background_icon_state = "bg_terror"
	charge_max = 350
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	delay = 33
	range = 0
	cast_sound = 'sound/creatures/terrorspiders/jelly.ogg'
	summon_type = list(/obj/structure/spider/royaljelly)

//MASS HEAL
/obj/effect/proc_holder/spell/aoe_turf/terror/healing
	name = "Massive healing"
	desc = "Exude feromones to heal your allies"
	action_icon_state = "heal"
	action_background_icon_state = "bg_terror"
	charge_max = 350
	clothes_req = FALSE
	range = 7
	sound = 'sound/creatures/terrorspiders/heal.ogg'

/obj/effect/proc_holder/spell/aoe_turf/terror/healing/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		for(var/mob/target in T.contents)
			if(isterrorspider(target))
				var/mob/living/M  = target
				visible_message("<span class='green'>[src] exudes feromones and heals spiders around!</span>")
				M.apply_status_effect(STATUS_EFFECT_TERROR_REGEN)
				new /obj/effect/temp_visual/heal(get_turf(M), "#8c00ff")
				new /obj/effect/temp_visual/heal(get_turf(M), "#8c00ff")
				new /obj/effect/temp_visual/heal(get_turf(M), "#8c00ff")

//TIER 4

//ALL HAIL THE QUEEN//

//SHRIEK
/obj/effect/proc_holder/spell/aoe_turf/terror/queen
	name = "Queen Shriek"
	desc = "Emit a loud shriek that weakens your enemies."
	action_icon_state = "terror_shriek"
	action_background_icon_state = "bg_terror"
	charge_max = 450
	clothes_req = FALSE
	range = 7
	sound = 'sound/creatures/terrorspiders/queen_shriek.ogg'

/obj/effect/proc_holder/spell/aoe_turf/terror/queen/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		for(var/mob/target in T.contents)
			if(iscarbon(target))
				var/mob/living/carbon/M = target
				to_chat(M, "<span class='danger'><b>A spike of pain drives into your head and scrambles your thoughts!</b></span>")
				M.AdjustConfused(10)
				M.AdjustWeakened(2)
				M.Jitter(14)
				M.adjustStaminaLoss(50)
				M.slowed = 7
			else if(issilicon(target))
				var/mob/living/silicon/S = target
				to_chat(S, "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>")
				S << 'sound/misc/interference.ogg'
				playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
				do_sparks(5, 1, S)
				S.Weaken(6)
		for(var/obj/machinery/light/L in T.contents)
			L.break_light_tube()

//KING??// one day..
