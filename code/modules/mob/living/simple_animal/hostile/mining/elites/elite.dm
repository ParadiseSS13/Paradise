#define TUMOR_INACTIVE 0
#define TUMOR_ACTIVE 1
#define TUMOR_PASSIVE 2
#define ARENA_RADIUS 10
#define REVIVE_COOLDOWN_MULT 10
#define REVIVE_COOLDOWN_MULT_ANTAG 2
#define REVIVE_HEALTH_MULT 0.2
#define REVIVE_HEALTH_MULT_ANTAG 0.3
#define STRENGHT_INCREASE_TIME 60 MINUTES

//Elite mining mobs
/mob/living/simple_animal/hostile/asteroid/elite
	name = "elite"
	desc = "An elite monster, found in one of the strange tumors on lavaland."
	icon = 'icons/mob/lavaland/lavaland_elites.dmi'
	faction = list("boss")
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	ranged = TRUE
	obj_damage = 30
	var/mech_damage = 50
	vision_range = 6
	aggro_vision_range = 18
	environment_smash = ENVIRONMENT_SMASH_NONE  //This is to prevent elites smashing up the mining station (entirely), we'll make sure they can smash minerals fine below.
	harm_intent_damage = 0 //Punching elites gets you nowhere
	stat_attack = UNCONSCIOUS
	layer = LARGE_MOB_LAYER
	has_laser_resist = FALSE
	universal_speak = TRUE
	sentience_type = SENTIENCE_BOSS
	response_help = "pets"
	var/scale_with_time = TRUE
	var/reviver = null
	var/dif_mult = 1 // Scales with number of enemies
	var/dif_mult_dmg = 1
	var/chosen_attack = 1
	var/list/attack_action_types = list()
	var/obj/loot_drop = null
	var/revive_cooldown = FALSE // Actually is a flag to check if is revived by a non antag
	var/antag_revived_heal_mod = 0.33 // How much max hp loses if is revived by antag and then healed
	var/enemies_count_scale = 1.3 // 30% stronger per enemy

//Gives player-controlled variants the ability to swap attacks
/mob/living/simple_animal/hostile/asteroid/elite/Initialize(mapload)
	. = ..()
	for(var/action_type in attack_action_types)
		var/datum/action/innate/elite_attack/attack_action = new action_type()
		attack_action.Grant(src)

//Prevents elites from attacking members of their faction (can't hurt themselves either) and lets them mine rock with an attack despite not being able to smash walls.

/mob/living/simple_animal/hostile/asteroid/elite/examine(mob/user)
	. = ..()
	if(reviver)
		. += "However, this one appears appears less wild in nature, and calmer around people."

/mob/living/simple_animal/hostile/asteroid/elite/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/hostile))
		var/mob/living/simple_animal/hostile/M = target
		if(faction_check_mob(M))
			return FALSE
	if(istype(target, /obj/structure/elite_tumor))
		var/obj/structure/elite_tumor/T = target
		if(T.mychild == src && T.activity == TUMOR_PASSIVE)
			var/response = alert(src, "Re-enter the tumor?","Despawn yourself?", "Yes", "No")
			if(response == "No" || QDELETED(src) || !Adjacent(T))
				return
			T.clear_activator(src)
			T.mychild = null
			T.activity = TUMOR_INACTIVE
			T.icon_state = "advanced_tumor"
			qdel(src)
			return FALSE
	. = ..()
	if(ismineralturf(target))
		var/turf/simulated/mineral/M = target
		M.gets_drilled()
	if(istype(target, /obj/mecha))
		var/obj/mecha/M = target
		M.take_damage(mech_damage, BRUTE, "melee", 1)
	if(. && isliving(target)) //Taken from megafauna. This exists purely to stop someone from cheesing a weaker melee fauna by letting it get punched.
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(!client && ranged && ranged_cooldown <= world.time)
				OpenFire()
		else if(L.health < -400)
			L.gib()


/mob/living/simple_animal/hostile/asteroid/elite/proc/revive_multiplier() //If on lavaland, return 1, or 1x cooldown. 10 if revived by a non antag, 2 if by an antag. 1 otherwise
	if(is_mining_level(z))
		return 1
	if(revive_cooldown)
		return REVIVE_COOLDOWN_MULT
	if(del_on_death)
		return REVIVE_COOLDOWN_MULT_ANTAG
	return 1

/mob/living/simple_animal/hostile/asteroid/elite/adjustHealth(damage, updating_health)
	. = ..()
	if(del_on_death)
		maxHealth -= damage * antag_revived_heal_mod

/mob/living/simple_animal/hostile/asteroid/elite/ex_act(severity, origin) //No surrounding the tumor with gibtonite and one shotting them.
	switch(severity)
		if(EXPLODE_DEVASTATE)
			adjustBruteLoss(75)

		if(EXPLODE_HEAVY)
			adjustBruteLoss(50)

		if(EXPLODE_LIGHT)
			adjustBruteLoss(25)

/mob/living/simple_animal/hostile/asteroid/elite/proc/scale_stats(var/list/activators)
	dif_mult = enemies_count_scale ** (length(activators)-1)
	dif_mult_dmg = (dif_mult + 1) * 0.5
	if(scale_with_time && world.time > STRENGHT_INCREASE_TIME)
		dif_mult *= 1.4
	maxHealth = initial(maxHealth) * dif_mult
	health = initial(health) * dif_mult
	melee_damage_lower = initial(melee_damage_lower) * dif_mult_dmg
	melee_damage_upper = initial(melee_damage_upper) * dif_mult_dmg

/mob/living/simple_animal/hostile/asteroid/elite/can_die()
	return ..() && health <= 0

/mob/living/simple_animal/hostile/asteroid/elite/AltShiftClickOn(atom/A)
	. = ..()
	if(isliving(A))
		var/mob/living/mob = A
		var/mobref = "\ref[mob]"
		if(mob == reviver)
			return
		if(mobref in faction)
			faction -= mobref
			friends -= mob
			to_chat(src, "<span class='warning'>You removed [mob] from your friends list.</span>")
		else
			faction += mobref
			friends += mob
			to_chat(src, "<span class='notice'>You added [mob] to your friends list.</span>")


/*Basic setup for elite attacks, based on Whoneedspace's megafauna attack setup.
While using this makes the system rely on OnFire, it still gives options for timers not tied to OnFire, and it makes using attacks consistent accross the board for player-controlled elites.*/

/datum/action/innate/elite_attack
	name = "Elite Attack"
	icon_icon = 'icons/mob/actions/actions_elites.dmi'
	button_icon_state = ""
	background_icon_state = "bg_default"
	///The displayed message into chat when this attack is selected
	var/chosen_message
	///The internal attack ID for the elite's OpenFire() proc to use
	var/chosen_attack_num = 0

/datum/action/innate/elite_attack/New(Target)
	. = ..()
	button.maptext = ""
	button.maptext_x = 8
	button.maptext_y = 0
	button.maptext_width = 24
	button.maptext_height = 12
	return button

/datum/action/innate/elite_attack/process()
	if(owner == null)
		STOP_PROCESSING(SSfastprocess, src)
		qdel(src)
		return
	UpdateButton()

/datum/action/innate/elite_attack/proc/UpdateButton(status_only = FALSE)
	if(status_only)
		return
	var/mob/living/simple_animal/hostile/asteroid/elite/elite_owner = owner
	var/timeleft = max(elite_owner.ranged_cooldown - world.time, 0)
	if(timeleft == 0)
		button.maptext = ""
	else
		button.maptext = "<b class='maptext'>[round(timeleft/10, 0.1)]</b>"

/datum/action/innate/elite_attack/Grant(mob/living/L)
	if(istype(L, /mob/living/simple_animal/hostile/asteroid/elite))
		START_PROCESSING(SSfastprocess, src)
		return ..()
	return FALSE

/datum/action/innate/elite_attack/Activate()
	var/mob/living/simple_animal/hostile/asteroid/elite/elite_owner = owner
	elite_owner.chosen_attack = chosen_attack_num
	to_chat(elite_owner, chosen_message)

//The Pulsing Tumor, the actual "spawn-point" of elites, handles the spawning, arena, and procs for dealing with basic scenarios.

/obj/structure/elite_tumor
	name = "pulsing tumor"
	desc = "An odd, pulsing tumor sticking out of the ground.  You feel compelled to reach out and touch it..."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/obj/lavaland/tumor.dmi'
	icon_state = "tumor"
	pixel_x = -16
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_range = 3
	anchored = TRUE
	density = FALSE
	var/activity = TUMOR_INACTIVE
	var/boosted = FALSE
	var/times_won = 0
	var/list/mob/living/carbon/human/activators
	var/mob/living/simple_animal/hostile/asteroid/elite/mychild = null
	var/gps
	///List of all potentially spawned elites
	var/potentialspawns = list(
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother,
		/mob/living/simple_animal/hostile/asteroid/elite/pandora,
		/mob/living/simple_animal/hostile/asteroid/elite/legionnaire,
		/mob/living/simple_animal/hostile/asteroid/elite/herald,
	)

	///List of invaders that have teleportes into the arena *multiple times*. They will be suffering.
	var/list/invaders = list()

/obj/structure/elite_tumor/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!ishuman(user))
		return
	switch(activity)
		if(TUMOR_PASSIVE)
			// Prevents the user from being forcemoved back and forth between two elite arenas.
			if(HAS_TRAIT(src, TRAIT_ELITE_CHALLENGER))
				user.visible_message("<span class='warning'>[user] reaches for [src] with [user.p_their()] arm, but nothing happens.</span>",
					"<span class='warning'>You reach for [src] with your arm... but nothing happens.</span>")
				return
			activity = TUMOR_ACTIVE
			user.visible_message("<span class='userdanger'>[src] convulses as [user]'s arm enters its radius.  Uh-oh...</span>",
				"<span class='userdanger'>[src] convulses as your arm enters its radius.  Your instincts tell you to step back.</span>")
			activators = list()
			for(var/mob/living/carbon/human/fighter in range(12, src.loc))
				make_activator(fighter)
			if(boosted)
				mychild.playsound_local(get_turf(mychild), 'sound/magic/cult_spell.ogg', 40, 0)
				to_chat(mychild, "<span class='warning'>Someone has activated your tumor.  You will be returned to fight shortly, get ready!</span>")
			addtimer(CALLBACK(src, .proc/return_elite), 3 SECONDS)
			INVOKE_ASYNC(src, .proc/arena_checks)
		if(TUMOR_INACTIVE)
			if(HAS_TRAIT(src, TRAIT_ELITE_CHALLENGER))
				user.visible_message("<span class='warning'>[user] reaches for [src] with [user.p_their()] arm, but nothing happens.</span>",
					"<span class='warning'>You reach for [src] with your arm... but nothing happens.</span>")
				return
			activity = TUMOR_ACTIVE
			var/mob/dead/observer/elitemind = null
			visible_message("<span class='userdanger'>[src] begins to convulse. Your instincts tell you to step back.</span>")
			activators = list()
			for(var/mob/living/carbon/human/fighter in range(12, src.loc))
				make_activator(fighter)
			if(!boosted)
				addtimer(CALLBACK(src, .proc/spawn_elite), 3 SECONDS)
				return
			visible_message("<span class='danger'>Something within [src] stirs...</span>")
			var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a lavaland elite?", ROLE_ELITE, TRUE, 10 SECONDS, source = src)
			if(length(candidates))
				audible_message("<span class='userdanger'>The stirring sounds increase in volume!</span>")
				elitemind = pick(candidates)
				SEND_SOUND(elitemind, 'sound/magic/cult_spell.ogg')
				to_chat(elitemind, "<b>Вы были избраны на роль Элиты Лаваленда.\nЧерез несколько секунд вы появитесь в виде сильного монстра, с целью убить призвавшего вас.\n\
					Вы можете выбирать разные атаки, нажимая на кнопки в верхнем левом углу экрана, а так же использовать их с помощью нажатия на тайл или моба.\n\
					Хоть и оппонент снаряжен шахтерской экипировкой и различными артефактами, у вас есть мощные способности, которые обычно были ограничены ИИ.\n\
					Если вы захотите победить, вам придется использовать свои способности с умом. Вам лучше ознакомиться с ними всеми так быстро, насколько возможно.\n\
					Good luck!</b>")
				addtimer(CALLBACK(src, .proc/spawn_elite, elitemind), 10 SECONDS)
			else
				visible_message("<span class='warning'>The stirring stops, and nothing emerges.  Perhaps try again later.</span>")
				activity = TUMOR_INACTIVE
				for(var/mob/living/carbon/human/activator in activators)
					clear_activator(activator)

/obj/structure/elite_tumor/proc/spawn_elite(mob/dead/observer/elitemind)
	var/selectedspawn = pick(potentialspawns)
	mychild = new selectedspawn(loc)
	mychild.scale_stats(activators)
	visible_message("<span class='userdanger'>[mychild] emerges from [src]!</span>")
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	if(boosted)
		mychild.key = elitemind.key
		mychild.sentience_act()
		notify_ghosts("\A [mychild] has been awakened in \the [get_area(src)]!", enter_link="<a href=?src=[UID()];follow=1>(Click to help)</a>", source = mychild, action = NOTIFY_FOLLOW)
	icon_state = "tumor_popped"
	INVOKE_ASYNC(src, .proc/arena_checks)

/obj/structure/elite_tumor/proc/return_elite()
	mychild.forceMove(loc)
	visible_message("<span class='userdanger'>[mychild] emerges from [src]!</span>")
	playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	mychild.revive()
	if(boosted)
		mychild.maxHealth = mychild.maxHealth * 2.5
		mychild.health = mychild.maxHealth
		mychild.grab_ghost()
		notify_ghosts("\A [mychild] has been challenged in \the [get_area(src)]!", enter_link="<a href=?src=[UID()];follow=1>(Click to help)</a>", source = mychild, action = NOTIFY_FOLLOW)
	INVOKE_ASYNC(src, .proc/arena_checks)

/obj/structure/elite_tumor/Initialize(mapload)
	. = ..()
	gps = new /obj/item/gps/internal/tumor(src)
	START_PROCESSING(SSobj, src)

/obj/structure/elite_tumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(gps)
	invaders.Cut()
	for(var/mob/living/carbon/human/activator in activators)
		clear_activator(activator)
	if(mychild)
		clear_activator(mychild)
	return ..()

/obj/structure/elite_tumor/proc/make_activator(mob/user)
	activators += user
	ADD_TRAIT(user, TRAIT_ELITE_CHALLENGER, "activation")
	RegisterSignal(user, COMSIG_PARENT_QDELETING, .proc/clear_activator)

/obj/structure/elite_tumor/proc/clear_activator(mob/source)
	SIGNAL_HANDLER
	if(source in activators)
		activators -= source
	else
		mychild = null
	REMOVE_TRAIT(source, TRAIT_ELITE_CHALLENGER, "activation")
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/obj/structure/elite_tumor/process()
	if(!isturf(loc))
		return

	for(var/mob/living/simple_animal/hostile/asteroid/elite/elitehere in loc)
		if(elitehere == mychild && activity == TUMOR_PASSIVE)
			mychild.adjustHealth(-mychild.maxHealth * 0.025)
			var/obj/effect/temp_visual/heal/H = new(get_turf(mychild))
			H.color = "#FF0000"

/obj/structure/elite_tumor/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/organ/internal/regenerative_core) && activity == TUMOR_INACTIVE && !boosted)
		var/obj/item/organ/internal/regenerative_core/core = attacking_item
		visible_message("<span class='warning'>As [user] drops the core into [src], [src] appears to swell.</span>")
		icon_state = "advanced_tumor"
		boosted = TRUE
		set_light(6)
		qdel(core)
		return TRUE

/obj/structure/elite_tumor/examine(mob/user)
	. = ..()
	if(boosted)
		. += "this one glows with a strong intensity"

/obj/structure/elite_tumor/proc/arena_checks()
	if(activity != TUMOR_ACTIVE || QDELETED(src))
		return
	INVOKE_ASYNC(src, .proc/arena_trap)  //Gets another arena trap queued up for when this one runs out.
	INVOKE_ASYNC(src, .proc/border_check)  //Checks to see if our fighters got out of the arena somehow.
	INVOKE_ASYNC(src, .proc/fighters_check)  //Checks to see if our fighters died.
	addtimer(CALLBACK(src, .proc/arena_checks), 5 SECONDS)

/obj/structure/elite_tumor/proc/fighters_check()
	if(QDELETED(mychild) || mychild.stat == DEAD)
		onEliteLoss()
		return
	for(var/mob/living/carbon/human/activator in activators)
		if(QDELETED(activator) || activator.stat == DEAD || (activator.health <= HEALTH_THRESHOLD_DEAD))
			continue
		else
			return
	onEliteWon()

/obj/structure/elite_tumor/proc/arena_trap()
	var/turf/tumor_turf = get_turf(src)
	if(loc == null)
		return
	for(var/tumor_range_turf in RANGE_EDGE_TURFS(ARENA_RADIUS, tumor_turf))
		new /obj/effect/temp_visual/elite_tumor_wall(tumor_range_turf, src)

/obj/structure/elite_tumor/proc/border_check()
	if(length(activators))
		for(var/mob/living/carbon/human/activator in activators)
			if(get_dist(src, activator) >= ARENA_RADIUS)
				activator.forceMove(loc)
				visible_message("<span class='warning'>[activator] suddenly reappears above [src]!</span>")
				playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	if(mychild != null && get_dist(src, mychild) >= ARENA_RADIUS)
		mychild.forceMove(loc)
		visible_message("<span class='warning'>[mychild] suddenly reappears above [src]!</span>")
		playsound(loc,'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)
	for(var/mob/living/carbon/human/invader in range(ARENA_RADIUS, src.loc))
		if(invader in activators)
			continue
		if(invader in invaders)
			to_chat(invader, "<span class='colossus'><b>You dare to try to break the sanctity of our arena? SUFFER...</b></span>")
			for(var/i in 1 to 4)
				invader.apply_status_effect(STATUS_EFFECT_VOID_PRICE) /// Hey kids, want 60 brute damage, increased by 40 each time you do it? Well, here you go!
		else
			to_chat(invader, "<span class='userdanger'>Only spectators are allowed, while the arena is in combat...</span>")
			invaders += invader
		var/list/valid_turfs = RANGE_EDGE_TURFS(ARENA_RADIUS + 2, src)
		invader.forceMove(pick(valid_turfs)) //Doesn't check for lava. Don't cheese it.
		playsound(invader, 'sound/effects/phasein.ogg', 200, 0, 50, TRUE, TRUE)

/obj/structure/elite_tumor/proc/onEliteLoss()
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, 0, 50, TRUE, TRUE)
	visible_message("<span class='warning'>[src] begins to convulse violently before beginning to dissipate.</span>")
	visible_message("<span class='warning'>As [src] closes, something is forced up from down below.</span>")
	var/lootloc = loc
	if(boosted)
		lootloc = new /obj/structure/closet/crate/necropolis/tendril(loc)
		new /obj/item/tumor_shard(lootloc)
		to_chat(mychild, "<span class='warning'>Dont leave your body, if you want to be revived.</span>")
		SSblackbox.record_feedback("tally", "Player controlled Elite loss", 1, mychild.name)
	else
		SSblackbox.record_feedback("tally", "AI controlled Elite loss", 1, mychild.name)
	new mychild.loot_drop(lootloc)
	mychild.dif_mult = 1
	mychild.dif_mult_dmg = 1
	qdel(src)

/obj/structure/elite_tumor/proc/onEliteWon()
	to_chat(mychild, "<span class='danger'>You have won the fight. Elite tumor has been defended once again.</span>")
	activity = TUMOR_INACTIVE
	icon_state = "tumor"
	if(length(activators))
		for(var/mob/living/carbon/human/activator in activators)
			clear_activator(activator)
	sleep(300)
	to_chat(mychild, "<span class='danger'>You have fulfilled your role and are going to a well-deserved rest.</span>")
	qdel(mychild)
	var/obj/structure/elite_tumor/copy = new(loc)
	if(boosted)
		copy.boosted = TRUE
		copy.icon_state = "advanced_tumor"
		SSblackbox.record_feedback("tally", "Player controlled Elite win", 1, mychild.name)
		times_won++
	else
		SSblackbox.record_feedback("tally", "AI controlled Elite win", 1, mychild.name)
	qdel(src)

/obj/item/tumor_shard
	name = "tumor shard"
	desc = "A strange, sharp, crystal shard from an odd tumor on Lavaland. Stabbing the corpse of a lavaland elite with this will revive them, assuming their soul still lingers. Revived lavaland elites only have half their max health, but are completely loyal to their reviver."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "crevice_shard"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5

/obj/item/tumor_shard/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite) && proximity_flag)
		var/mob/living/simple_animal/hostile/asteroid/elite/E = target
		if(E.stat != DEAD || E.sentience_type != SENTIENCE_BOSS || !E.key)
			user.visible_message("It appears [E] is unable to be revived right now. Perhaps try again later.")
			return
		E.faction = list("\ref[user]")
		E.friends += user
		E.reviver = user
		E.revive()
		user.visible_message("<span class='notice'>[user] stabs [E] with [src], reviving it.</span>")
		SEND_SOUND(E, 'sound/magic/cult_spell.ogg')
		to_chat(user, "<span class='notice'>Вы воспользовались осколком опухоли и подчинили себе её бывшего защитника.\nОн не может причинить вам вреда и во всем будет повиноваться вам.</span>")
		to_chat(E, "<span class='userdanger'>Вы были возрождены [user], и вы обязаны [user].  Помогай [user.p_them()] в достижении [user.p_their()] целей, несмотря на риск.</span>")
		to_chat(E, "<span class='big bold'>Помните, что вы разделяете интересы [user].  От вас ожидается не мешать союзникам хозяина, пока вам не прикажут!</span>")
		E.mind.store_memory("Я теперь разделяю интересы [user].  От меня ожидается не мешать союзникам хозяина, пока вам не прикажут!")
		if(user.mind.special_role)
			E.maxHealth = initial(E.maxHealth) * REVIVE_HEALTH_MULT_ANTAG
			E.health = initial(E.health) * REVIVE_HEALTH_MULT_ANTAG
			E.del_on_death = TRUE
		else
			E.maxHealth = initial(E.maxHealth) * REVIVE_HEALTH_MULT
			E.health = initial(E.health) * REVIVE_HEALTH_MULT
			E.revive_cooldown = TRUE
		E.sentience_type = SENTIENCE_ORGANIC
		qdel(src)
	else
		to_chat(user, "<span class='notice'>[src] only works on the corpse of a sentient lavaland elite.</span>")

/obj/effect/temp_visual/elite_tumor_wall
	name = "magic wall"
	icon = 'icons/turf/walls/hierophant_wall_temp.dmi'
	icon_state = "wall"
	duration = 50
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	color = rgb(255,0,0)
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = LIGHT_COLOR_PURE_RED
	smooth = SMOOTH_TRUE

/obj/effect/temp_visual/elite_tumor_wall/Initialize(mapload, new_caster)
	. = ..()
	queue_smooth_neighbors(src)
	queue_smooth(src)

/obj/effect/temp_visual/elite_tumor_wall/Destroy()
	queue_smooth_neighbors(src)
	return ..()

/obj/effect/temp_visual/elite_tumor_wall/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(isliving(mover) || isprojectile(mover))
		return FALSE

/obj/item/gps/internal/tumor
	icon_state = null
	gpstag = "Cancerous Signal"
	desc = "Ghosts in a fauna? That's cancerous!"
	invisibility = 100

#undef TUMOR_INACTIVE
#undef TUMOR_ACTIVE
#undef TUMOR_PASSIVE
#undef ARENA_RADIUS
#undef REVIVE_COOLDOWN_MULT
#undef REVIVE_COOLDOWN_MULT_ANTAG
#undef REVIVE_HEALTH_MULT
#undef REVIVE_HEALTH_MULT_ANTAG
#undef STRENGHT_INCREASE_TIME
