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
	//var/cooldown = 0
	var/playstyle_string = "<B>You are the Slaughter Demon, a terible creature from another existence. You have a single desire: To kill.  \
						You may Ctrl+Click on blood pools to travel through them, appearing and dissaapearing from the station at will. \
						Pulling a dead or critical mob while you enter a pool will pull them in with you, allowing you to feast. </B>"
   //Paradise todo:change to altclick,add objectives. need ideas as i want people to be creative, not just RAWR KILL


/mob/living/simple_animal/slaughter/New()
	..()
	spawn(5)
		src.mind.AddSpell(new /obj/effect/proc_holder/spell/wizard/targeted/slaughter_whisper(src))
		src.mind.AddSpell(new /obj/effect/proc_holder/spell/wizard/aoe_turf/bloodpull(src))

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
				src.GibEat(src.kidnapped)
				playsound(get_turf(src),'sound/misc/Demon_consume.ogg', 100, 1)
				sleep(30)
				src.GibEat(src.kidnapped)
				playsound(get_turf(src),'sound/misc/Demon_consume.ogg', 100, 1)
				sleep(30)
				src.GibEat(src.kidnapped)
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
			if(istype(B, /obj/effect/decal/cleanable/blood) || istype(B, /obj/effect/decal/cleanable/trail_holder))
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


/obj/effect/dummy/slaughter/singularity_act(blah)
	return


//Paradise Port:I added this cuase..SPOOPY DEMON IN YOUR BRAIN

/obj/effect/proc_holder/spell/wizard/targeted/slaughter_whisper
	name = "Whisper"
	desc = "Telepathically transmits a message to the target."
	panel = "Daemon"
	charge_max = 50
	clothes_req = 0
	range = -1
	include_user = 1


/obj/effect/proc_holder/spell/wizard/targeted/slaughter_whisper/cast(list/targets, var/mob/living/simple_animal/slaughter/user = usr)

	for(var/mob/living/M in targets)
		spawn(0)
			var/msg = stripped_input(usr, "What do you wish to tell [M]?", null, "")
			if(!msg)
				charge_counter = charge_max
				return
			usr << "<span class='info'><b>You whisper to [M]:</b> [msg]</span>"
			M << "<span class='deadsay'><b>Suddenly a strange,demonic,voice resonates in your head...</b></span><i> [msg]</I>"



/obj/effect/proc_holder/spell/wizard/aoe_turf/bloodpull //Janitor and janiborg doing thier job? No problem....
	name = "Exsanguinate"
	desc = "Cuase blood to be torn our of mortals to help acess the plane."
	panel = "Daemon"
	charge_max = 1800
	clothes_req = 0
	range = 5
	//include_user = 1


/obj/effect/proc_holder/spell/wizard/aoe_turf/bloodpull/cast(list/targets, var/mob/living/simple_animal/slaughter/user = usr)

	for(var/turf/T in targets)
		for(var/mob/living/carbon/human/target in T.contents)
			playsound(src.loc, pick('sound/hallucinations/wail.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/far_noise.ogg'), 50, 1, -3)

			var/targetPart = pick("chest","groin","head","l_arm","r_arm","r_leg","l_leg","l_hand","r_hand","l_foot","r_foot")
			target.apply_damage(rand(5, 10), BRUTE, targetPart)
			target << "\red The skin on your [parse_zone(targetPart)] feels like it's ripping apart, and a stream of blood flies out."
			var/obj/effect/decal/cleanable/blood/splatter/animated/aniBlood = new(target.loc)
			aniBlood.target_turf = pick(range(1, src))
			aniBlood.blood_DNA = list()
			aniBlood.blood_DNA[target.dna.unique_enzymes] = target.dna.b_type
			target.vessel.remove_reagent("blood",rand(25,50))


//////////The Loot

/obj/item/weapon/demonheart
	name = "demon's heart"
	desc = "It's still faintly beating with rage"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-on"
	origin_tech = "combat=5;biotech=8"

//Event
//Gib helperfunc
/mob/living/simple_animal/slaughter/proc/GibEat(var/gibType)

	var/mob/living/carbon/human/victimType = gibType
	if (victimType.species.flags & IS_SYNTHETIC)
		new /obj/effect/gibspawner/robot(get_turf(src))
	else
		new /obj/effect/gibspawner/generic(get_turf(src))


