///The following mini-antag was coded by 	KorPhaeron   for TG Station
//Credits: Concept: KorPhaeron, Sprite:Ausops, Sounds:Cuboos
///Ported for paradise by Aurorablade/Fethas
///Things added for port:
//Various tweeks
//Blood...
/// Made the message tell you waht the demon is sinking into(gibs/blood etc)
///Alot of blood...Alot..Of blood..

//////////////////The Monster

/mob/living/simple_animal/slaughter
	name = "Slaughter Demon"
	real_name = "Slaughter Demon"
	desc = "You should run."
	speak_emote = list("gurgles")
	emote_hear = list("wails","screeches")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	speed = 0
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/misc/demon_attack1.ogg'
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2  = 0
	max_n2  = 0
	minbodytemp = 0
	faction = list("slaughter")
	attacktext = "wildly tears into"
	maxHealth = 250
	health = 250
	environment_smash = 1
	universal_understand = 1
	melee_damage_lower = 30
	melee_damage_upper = 30
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	var/devoured = 0
	var/phased = FALSE
	var/holder = null
	var/eating = FALSE
	var/mob/living/kidnapped = null
	var/list/nearby_mortals = list()
	var/cooldown = 0
	var/vialspawned = FALSE
	var/playstyle_string = "<B>You are the Slaughter Demon, a terible creature from another existence. You have a single desire: To kill.  \
						You may Ctrl+Click on blood pools to travel through them, appearing and dissaapearing from the station at will. \
						Pulling a dead or critical mob while you enter a pool will pull them in with you, allowing you to feast. </B>"
   //Paradise todo:change to altclick,add objectives. need ideas as i want people to be creative, not just RAWR KILL


/mob/living/simple_animal/slaughter/New()
	..()
	spawn()
		if(src.mind)
			src.mind.current.verbs += /mob/living/simple_animal/slaughter/proc/bloodPull
			src.mind.current.verbs += /mob/living/simple_animal/slaughter/proc/slaughterWhisper
			src << src.playstyle_string
			src << "<B><span class ='notice'>You are not currently in the same plane of existence as the station. Ctrl+Click a blood pool to manifest.</span></B>"
			if(!(vialspawned))
				var/datum/objective/slaughter/objective = new
				var/datum/objective/demonFluff/fluffObjective = new
				ticker.mode.traitors |= src.mind
				objective.owner = src.mind
				fluffObjective.owner = src.mind
				//Paradise Port:I added the objective for one spawned like this
				src.mind.objectives += objective
				src.mind.objectives += fluffObjective
				src << "<B>Objective #[1]</B>: [objective.explanation_text]"
				src << "<B>Objective #[2]</B>: [fluffObjective.explanation_text]"


/mob/living/simple_animal/slaughter/death()
	..(1)
	new /obj/effect/decal/cleanable/blood (src.loc)
	new /obj/effect/gibspawner/generic(get_turf(src))
	new /obj/effect/gibspawner/generic(get_turf(src))
	playsound(get_turf(src),'sound/misc/demon_dies.ogg', 200, 1)
	new /obj/item/weapon/demonheart (src.loc)
	visible_message("<span class='danger'>The [src] screams in anger as its form collapes into a pool of viscera.</span>")
	ghostize()
	qdel(src)
	return



////////////////////The Powers

/mob/living/simple_animal/slaughter/proc/phaseout(var/obj/effect/decal/cleanable/B)
	var/turf/mobloc = get_turf(src.loc)
	var/turf/bloodloc = get_turf(B.loc)
	if(Adjacent(bloodloc))
		src.notransform = TRUE
		spawn(0)
			src.visible_message("The [src] sinks into [B].")
			playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, 1, -1)
			var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			animation.name = "odd blood"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/mob/mob.dmi'
			animation.icon_state = "jaunt"
			animation.layer = 5
			animation.master = holder
			animation.dir = src.dir
			src.ExtinguishMob()
			if(src.buckled)
				src.buckled.unbuckle()
			if(src.pulling)
				if(istype(src.pulling, /mob/living/))
					var/mob/living/victim = src.pulling
					if(victim.stat == CONSCIOUS)
						src.visible_message("[victim] kicks free of the [src] at the last second!")
					else
						victim.loc = holder///holder
						src.visible_message("<span class='warning'><B>The [src] drags [victim] into [B]!</B>")
						src.kidnapped = victim
			flick("jaunt",animation)
			src.loc = holder
			src.phased = TRUE
			src.holder = holder

			if(src.kidnapped)
				src << "<B>You being to feast on [kidnapped]. You can not move while you are doing this.</B>"
				src.visible_message("<span class='warning'><B>Loud eating sounds come from the blood...</B>")
				src.eating = TRUE
				sleep(6)
				qdel(animation)
				src.GibEat()
				playsound(get_turf(src),'sound/misc/Demon_consume.ogg', 100, 1)
				sleep(30)
				src.GibEat()
				playsound(get_turf(src),'sound/misc/Demon_consume.ogg', 100, 1)
				sleep(30)
				src.GibEat()
				playsound(get_turf(src),'sound/misc/Demon_consume.ogg', 100, 1)
				sleep(30)
				src << "<B>You devour [kidnapped]. Your health is fully restored.</B>"
				src.adjustBruteLoss(-1000)
				kidnapped.ghostize()
				qdel(kidnapped)
				src.devoured++
				src << "<B> [src.devoured] [src.kidnapped] [src.eating]<B>"//Debug for tracking how many is devoured, use in objective?
				src.kidnapped = null
				src.eating = FALSE
				src.pulling = FALSE
			src.notransform = 0
			if(!(src.eating))
				new /obj/effect/gibspawner/human(get_turf(src))///Somewhere a janitor weeps..
				sleep(6)
				qdel(animation)

/mob/living/simple_animal/slaughter/proc/phasein(var/obj/effect/decal/cleanable/B)
	var/atom/movable/overlay/animation = new /atom/movable/overlay( B.loc )
	animation.name = "odd blood"
	animation.density = 0
	animation.anchored = 1
	animation.icon = 'icons/mob/mob.dmi'
	animation.icon_state = "jauntup" //Paradise Port:I reversed the jaunt animation so it looks like its rising up
	animation.layer = 5
	animation.master = B.loc
	animation.dir = src.dir
	if(src.eating)
		src << "<B>Finish eating first!</B>"
	else
		flick("jauntup",animation)
		src.client.eye = src
		src.loc = B.loc
		src.phased = FALSE
		//Paradise port:The hallucination sounds removed from the demon as of a recent commit..i liked it though..
		if (prob(25))
			var/list/voice = list('sound/hallucinations/behind_you1.ogg','sound/hallucinations/im_here1.ogg','sound/hallucinations/turn_around1.ogg','sound/hallucinations/i_see_you1.ogg')
			playsound(get_turf(src), pick(voice),50, 1, -1)
		src.visible_message("<span class='warning'><B>The [src] rises out of [B]!</B>")
		new /obj/effect/gibspawner/human(get_turf(src))
		playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, 1, -1)
		sleep(6)
		qdel(src.holder)
		qdel(animation)

/obj/effect/decal/cleanable/blood/CtrlClick(var/mob/user)
	..()
	if(istype(user, /mob/living/simple_animal/slaughter))
		var/mob/living/simple_animal/slaughter/S = user
		if(S.phased)
			S.phasein(src)
		else
			S.phaseout(src)


/obj/effect/decal/cleanable/trail_holder/CtrlClick(var/mob/user)
	..()
	if(istype(user, /mob/living/simple_animal/slaughter))
		var/mob/living/simple_animal/slaughter/S = user
		//5 second cooldown
		if(S.phased)
			S.phasein(src)
		else
			S.phaseout(src)



/turf/CtrlClick(var/mob/user)
	..()
	if(istype(user, /mob/living/simple_animal/slaughter))
		var/mob/living/simple_animal/slaughter/S = user
		for(var/obj/effect/decal/cleanable/B in src.contents)
			if((istype(B, /obj/effect/decal/cleanable/blood) || istype(B, /obj/effect/decal/cleanable/trail_holder))&& !istype(B,/obj/effect/decal/cleanable/blood/gibs/robot))
				if(S.phased)
					S.phasein(B)
					break
				else
					S.phaseout(B)
					break

/obj/effect/dummy/slaughter //Can't use the wizard one, blocked by jaunt/slow
	name = "odd blood"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/canmove = 1
	density = 0
	anchored = 1

/obj/effect/dummy/slaughter/relaymove(var/mob/user, direction)
	if (!src.canmove || !direction) return
	var/turf/newLoc = get_step(src,direction)
	loc = newLoc
	src.canmove = 0
	spawn(1)
		src.canmove = 1

/obj/effect/dummy/slaughter/ex_act(severity)
	return 1

/obj/effect/dummy/slaughter/bullet_act(blah)
	return

/obj/effect/dummy/slaughter/singularity_act(blah)
	return


//Paradise Port:I added this cuase..SPOOPY DEMON IN YOUR BRAIN


/mob/living/simple_animal/slaughter/proc/slaughterWhisper()
	set name = "Whisper"
	set desc = "Whisper to a mortal"
	set category = "Daemon"

	var/list/choices = list()
	for(var/mob/living/carbon/C in living_mob_list)
		if(C.stat != 2 && C.mind)
			choices += C

	var/mob/living/carbon/M = input(src,"Who do you wish to talk to?") in null|choices
	spawn(0)
		var/msg = stripped_input(usr, "What do you wish to tell [M]?", null, "")
		if(!(msg))
			return
		usr << "<span class='info'><b>You whisper to [M]:</b> [msg]</span>"
		M << "<span class='deadsay'><b>Suddenly a strange,demonic,voice resonates in your head...</b></span><i><span class='danger'> [msg]</span></I>"


/mob/living/simple_animal/slaughter/proc/bloodPull()
	set name = "Exsanguinate"
	set desc = "Cuase blood to be torn our of mortals to help acess the plane.."
	set category = "Daemon"

	for(var/mob/living/carbon/human/H in view(10,(src.holder || src.loc)))
		nearby_mortals.Add(H)

	if (cooldown == 0 || world.time - cooldown > 1800)
		for(var/mob/living/carbon/human/H in view(7,(src.holder || src.loc)))
			nearby_mortals.Add(H)
		//var/mob/living/carbon/human/M = pop(nearby_mortals)
		if(nearby_mortals.len)
			playsound(src.loc, pick('sound/hallucinations/wail.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/far_noise.ogg'), 50, 1, -3)
			new /datum/artifact_effect/badfeeling/DoEffectPulse()
			for (var/mob/living/carbon/human/portal in nearby_mortals)
				var/targetPart = pick("chest","groin","head","l_arm","r_arm","r_leg","l_leg","l_hand","r_hand","l_foot","r_foot")
				portal.apply_damage(rand(5, 10), BRUTE, targetPart)
				portal << "\red The skin on your [parse_zone(targetPart)] feels like it's ripping apart, and a stream of blood flies out."
				var/obj/effect/decal/cleanable/blood/splatter/animated/aniBlood = new(portal.loc)
				aniBlood.target_turf = pick(range(1, src))
				aniBlood.blood_DNA = list()
				aniBlood.blood_DNA[portal.dna.unique_enzymes] = portal.dna.b_type
				portal.vessel.remove_reagent("blood",rand(25,50))
			cooldown = world.time
	else
		usr << "<span class='info'>You cannot Exsanguinate mortals yet!"



//////////The Loot

/obj/item/weapon/demonheart
	name = "demon's heart"
	desc = "It's still faintly beating with rage"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-on"
	origin_tech = "combat=5;biotech=8"

/obj/item/weapon/guts
	name = "guts"
	desc = "Ewwwwwwwwwwww"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "innards"

//Event
//Gib helperfunc
/mob/living/simple_animal/slaughter/proc/GibEat()

	//at some point we may eat a robot..and its gonna throw out gibs..
	//don't question...When a demon drags you into a blood portal you have no idea whos gibs you are actually seeing
	//...Or we can just blame bluespace.
	var/atom/throwtarget = get_edge_target_turf(src.holder, get_dir(src.holder, get_step_away(src.holder, src.holder)))

	if(istype(src.kidnapped,/mob/living/carbon/human))
		var/mob/living/carbon/human/victimType = src.kidnapped

		var/obj/effect/decal/cleanable/blood/gibs/gore = new victimType.species.single_gib_type(get_turf(src))
		src << "[victimType.species]"//debug
		if(victimType.species.flesh_color)
			gore.fleshcolor = victimType.species.flesh_color
		if(victimType.species.blood_color)
			gore.basecolor = victimType.species.blood_color
		gore.update_icon()
		spawn()//Wait for itt....
			gore.throw_at(get_edge_target_turf(throwtarget,pick(alldirs)),rand(10,20),40)

	else//in case we eat ian.
		new /obj/effect/gibspawner/human(get_turf(src))

	var/obj/tossGuts = new /obj/item/weapon/guts (get_turf(src.holder))
	tossGuts.throw_at(get_edge_target_turf(throwtarget,pick(alldirs)),rand(10,20),10)


//Objective info, Based on Reverent mini Atang
/datum/objective/slaughter
	var/targetKill = 10

/datum/objective/slaughter/New()
	targetKill = rand(10,20)
	explanation_text = "Devour [targetKill] mortals."
	..()

/datum/objective/slaughter/check_completion()
	if(!istype(owner.current, /mob/living/simple_animal/slaughter) || !owner.current)
		return 0
	var/mob/living/simple_animal/slaughter/R = owner.current
	if(!R || R.stat == DEAD)
		return 0
	var/deathCount = R.devoured
	if(deathCount < targetKill)
		return 0
	return 1

/datum/objective/demonFluff


/datum/objective/demonFluff/New()
	find_target()
	var/targetname = "someone"
	if(target && target.current)
		targetname = target.current.real_name
	var/list/explanationTexts = list("Attempt to make your presence unknown to the crew.", \
									 "Kill or Dystroy all Janitors or Sanitation bots.", \
									 "Drive [targetname] insane."
									 )

	if(target && target.current)
		explanationTexts += "Drive [target.current.real_name] insane."

	explanation_text = pick(explanationTexts)
	..()

/datum/objective/demonFluff/check_completion()
	return 1