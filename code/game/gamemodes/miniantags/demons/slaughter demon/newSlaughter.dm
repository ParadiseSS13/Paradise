/mob/living/simple_animal/demon/slaughter_demon
	name = "slaughter demon"
	real_name = "slaughter demon"
	desc = "A large, menacing creature covered in armored black scales. You should run."
	maxHealth = 400
	health = 400
	speak = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri", "orkan", "allaq")
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	obj_damage = 50
	melee_damage_lower = 30
	melee_damage_upper = 30
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	armour_penetration_percentage = 100
	var/channeling = FALSE
	var/lasthealtime = 0
	var/phased = TRUE
	var/phaseoutchaneltime = 0
	var/phaseinchaneltime = 0
	var/stat_amplification = 0.5
	var/max_amplification_stacks = 0.5 //50% max
	var/last_stat_decrease = 0
	var/decay_time = 0
	var/boost = 0
	var/feast_sound = 'sound/misc/demon_consume.ogg'
	var/devoured = 0
	var/mindsabsorbed = 0
	var/list/consumed_mobs = list()
	var/list/nearby_mortals = list()
	var/list/bloodspots = list()
	var/cooldown = 0
	var/gorecooldown = 0
	var/vialspawned = FALSE
	var/turf/channel_target = 0
	var/obj/effect/proc_holder/spell/demon_slam/slam_holder
	var/obj/effect/proc_holder/spell/demon_charge/charge_holder
	loot = list(/obj/effect/decal/cleanable/blood/innards, /obj/effect/decal/cleanable/blood, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic, /obj/item/organ/internal/heart/demon/slaughter)
	var/playstyle_string = "<B>You are the Slaughter Demon, a terrible creature from another existence. You have a single desire: to kill.  \
						You may use the blood crawl icon when on blood pools to travel through them, appearing and dissapearing from the station at will. \
						Pulling a dead or critical mob while you enter a pool will pull them in with you, allowing you to feast. \
						You move quickly upon leaving a pool of blood, but the material world will soon sap your strength and leave you sluggish. </B>"
	del_on_death = TRUE
	deathmessage = "screams in anger as it collapses into a puddle of viscera!"

/mob/living/simple_animal/demon/slaughter_demon/New()
	..()
	remove_from_all_data_huds()
	var/obj/effect/proc_holder/spell/bloodcrawldemon/bloodspell = new
	var/obj/effect/proc_holder/spell/demon_charge/dc = new
	var/obj/effect/proc_holder/spell/demon_slam/ds = new
	charge_holder = dc
	slam_holder = ds
	AddSpell(dc)
	AddSpell(ds)
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/slaughter_demon))
		phased = FALSE
	addtimer(CALLBACK(src, PROC_REF(attempt_objectives)), 5 SECONDS)

/obj/effect/dummy/slaughter_demon //Can't use the wizard one, blocked by jaunt/slow
	name = "odd blood"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	density = FALSE
	anchored = TRUE
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/dummy/slaughter_demon/relaymove(mob/user, direction)
	forceMove(get_step(src, direction))

/obj/effect/dummy/slaughter_demon/ex_act()
	return

/obj/effect/dummy/slaughter_demon/bullet_act()
	return

/obj/effect/dummy/slaughter_demon/singularity_act()
	return

/*/obj/item/antag_spawner/slaughter_demon/spawn_antag(client/C, turf/T, type = "", mob/user)
	var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(T)
	var/mob/living/simple_animal/demon/D = new demon_type(holder)
	if(istype(D, /mob/living/simple_animal/demon/slaughter))
		var/mob/living/simple_animal/demon/slaughter/S = D
		S.vialspawned = TRUE*/

/mob/living/simple_animal/demon/slaughter_demon/Destroy()
	for(var/mob/living/M in consumed_mobs)
		REMOVE_TRAIT(M, TRAIT_UNREVIVABLE, "demon")
		release_consumed(M)
	. = ..()

/mob/living/simple_animal/demon/slaughter_demon/proc/release_consumed(mob/living/M)
	M.forceMove(get_turf(src))

/mob/living/simple_animal/demon/slaughter_demon/proc/perform_phasein()
	var/foundtarget = FALSE
	var/turf/origin_turf = channel_target
	var/turf/tele_turf = channel_target
	for(var/obj/effect/decal/cleanable/C in tele_turf)
		if(C.can_bloodcrawl_in())
			foundtarget = TRUE
			break
	var/foundblood = FALSE
	if(!foundtarget)
		for(var/obj/effect/decal/cleanable/C in view(2, tele_turf))
			if(C.can_bloodcrawl_in())
				if(!foundblood)
					foundblood = TRUE
					tele_turf = get_turf(C)
					break
	if(!foundblood && !foundtarget)
		channeling = FALSE
		to_chat(src, "The blood has all been cleaned!")
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "channelingblood")
		return
	for(var/obj/effect/decal/cleanable/C in view(2, origin_turf))
		if(C.can_bloodcrawl_in())
			for(var/mob/living/M in get_turf(C))
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					H.bleed_rate += 10
				M.Weaken(5 SECONDS)
				new /obj/effect/temp_visual/cult/sparks(get_turf(M))
	src.forceMove(tele_turf)
	src.client.eye = src
	phased = TRUE
	channeling = FALSE
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "channelingblood")
	icon_state = "daemon"
	new /obj/effect/temp_visual/dir_setting/bloodcrawl(tele_turf, src.dir, "jaunt")
	if(prob(25))
		var/list/voice = list('sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/i_see_you1.ogg')
		playsound(tele_turf, pick(voice), 50, TRUE, -1)
	channel_target.visible_message("<span class='warning'><b>[src] rises out of [channel_target]!</b>")
	playsound(tele_turf, 'sound/misc/exit_blood.ogg', 100, TRUE, -1)
	bloodspots = list()

/mob/living/simple_animal/demon/slaughter_demon/proc/absorb()
	for(var/mob/living/L in range(1, get_turf(src)))
		if(L.stat != DEAD)
			continue
		devoured++
		L.forceMove(src)
		ADD_TRAIT(L, TRAIT_UNREVIVABLE, "demon")
		consumed_mobs.Add(L)
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = H.w_uniform
				U.sensor_mode = SENSOR_OFF
		if(L.mind)
			if(!charge_holder.bloodcharge || !slam_holder.bloodcharge)
				charge_holder.bloodcharge = TRUE
				slam_holder.bloodcharge = TRUE
			mindsabsorbed++
			maxHealth += 10
			adjustHealth(-100)
			L.forceMove(src)
	while(mindsabsorbed % 4 == 0 && mindsabsorbed > 0)
		mindsabsorbed -= 4
		maxHealth += 50

/mob/living/simple_animal/demon/slaughter_demon/proc/perform_phaseout()
	icon_state = "daemon"
	var/obj/effect/decal/foundblood = 0
	for(var/obj/effect/decal/cleanable/C in channel_target)
		if(C.can_bloodcrawl_in())
			foundblood = C
			break
	if(!foundblood)
		to_chat(src, "<span class='warning'>The blood you were channeling has been cleaned away!<span>")
		channeling = FALSE
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "channelingblood")
		return
	if(!in_range(channel_target, src))
		to_chat(src, "The blood is far away!")
		channeling = FALSE
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "channelingblood")
		return
	phased = FALSE
	channeling = FALSE
	absorb()
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "channelingblood")
	var/obj/effect/dummy/slaughter_demon/holder = new /obj/effect/dummy/slaughter_demon(get_turf(src))
	sink_animation(foundblood)
	src.ExtinguishMob()
	src.forceMove(holder)

/mob/living/simple_animal/demon/slaughter_demon/proc/sink_animation(atom/A)
	var/turf/mob_loc = get_turf(channel_target)
	visible_message("<span class='danger'>[src] sinks into [A].</span>")
	playsound(mob_loc, 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
	new /obj/effect/temp_visual/dir_setting/bloodcrawl(mob_loc, src.dir, "jaunt")

/mob/living/simple_animal/demon/slaughter_demon/proc/attempt_objectives()
	if(mind)
		var/list/messages = list()
		messages.Add(playstyle_string)
		messages.Add("<b><span class ='notice'>You are not currently in the same plane of existence as the station. Use the blood crawl action at a blood pool to manifest.</span></b>")
		SEND_SOUND(src, sound('sound/misc/demon_dies.ogg'))
		if(!vialspawned)
			SSticker.mode.traitors |= mind
			mind.add_mind_objective(/datum/objective/slaughter)
			mind.add_mind_objective(/datum/objective/demon_fluff)
			messages.Add(mind.prepare_announce_objectives(FALSE))
		messages.Add("<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Slaughter_Demon)</span>")
		to_chat(src, chat_box_red(messages.Join("<br>")))

/mob/living/simple_animal/demon/slaughter_demon/adjustHealth(amount, updating_health = TRUE)
	to_chat(world, "Took [amount] Damage")
	if(stat_amplification && amount > 0)
		to_chat(world, "Subtracting [amount * stat_amplification]")
		amount = amount - (amount * stat_amplification)
		to_chat(world, "Suffered [amount] damage!")
	..(amount, updating_health)

/mob/living/simple_animal/demon/slaughter_demon/UnarmedAttack(atom/A)
	if(istype(A, /mob/living/carbon))
		if(stat_amplification > 0)
			melee_damage_lower = round(melee_damage_lower + (melee_damage_lower * stat_amplification))
			melee_damage_upper = round(melee_damage_upper + (melee_damage_upper * stat_amplification))
			to_chat(world, "Modified melee damage is [melee_damage_lower]")
		..()
		melee_damage_lower = 30
		melee_damage_upper = 30
		var/mob/living/carbon/T = A
		if(T.stat == DEAD || !T.ckey)
			to_chat(src, "No life force to consume!")
			return
		boost = world.time + 5 SECONDS
		decay_time = world.time + 5 SECONDS
		if(stat_amplification < max_amplification_stacks)
			stat_amplification += 0.05
		heal_overall_damage(10, 0, updating_health = TRUE)
		boost = world.time + 5 SECONDS
	..()

/mob/living/simple_animal/demon/slaughter_demon/Move(NewLoc, direct)
	. = ..()
	if(!locate(/obj/effect/decal/cleanable/blood) in get_turf(src))
		createFootprintsFrom(src, direct, get_turf(src))

/mob/living/simple_animal/demon/slaughter_demon/Life(seconds, times_fired)
	..()
	if(boost < world.time)
		speed = 1
		src << "Boost has been set to 1"
	else
		speed = 0
	if(phaseoutchaneltime < world.time && channeling && phased)
		perform_phaseout()
	if(phaseinchaneltime < world.time && channeling && !phased)
		perform_phasein()
	if(!phased && health < 200 && lasthealtime < world.time)
		lasthealtime = world.time + 1 SECONDS
		adjustHealth(-(maxHealth * 0.05))
	if(decay_time < world.time && stat_amplification)
		if(last_stat_decrease < world.time)
			to_chat(src, "Decreasing stat amp")
			to_chat(src, "Stat amp is currently [stat_amplification]")
			stat_amplification -= 0.1
			stat_amplification = round(stat_amplification, 0.05)
			if(stat_amplification < 0)
				stat_amplification = 0
				return
			to_chat(src, "Stat amp is now set to [stat_amplification]")
			last_stat_decrease = world.time + 1 SECONDS


//temporary visual effects(/obj/effect/temp_visual) used by clockcult stuff
/obj/effect/temp_visual/bloodstorm
	name = "blood storm"
	icon = 'icons/effects/224x224.dmi'
	icon_state = "singularity_s7"
	duration = 5 SECONDS
	randomdir = 0
	pixel_x = -96
	pixel_y = -96
	layer = ABOVE_NORMAL_TURF_LAYER

