#define TUMOR_INACTIVE 0
#define TUMOR_ACTIVE 1
#define TUMOR_PASSIVE 2
#define ARENA_RADIUS 12

//Elite mining mobs
/mob/living/simple_animal/hostile/asteroid/elite
	name = "elite"
	desc = "An elite monster, found in one of the strange tumors on lavaland."
	icon = 'icons/mob/lavaland/lavaland_elites.dmi'
	faction = list("boss")
	robust_searching = TRUE
	ranged_ignores_vision = TRUE
	ranged = TRUE
	vision_range = 6
	aggro_vision_range = 18
	environment_smash = ENVIRONMENT_SMASH_NONE  //This is to prevent elites smashing up the mining station (entirely), we'll make sure they can smash minerals fine below.
	harm_intent_damage = 0 //Punching elites gets you nowhere
	stat_attack = UNCONSCIOUS
	layer = LARGE_MOB_LAYER
	has_laser_resist = FALSE
	universal_speak = TRUE
	sentience_type = SENTIENCE_BOSS
	var/chosen_attack = 1
	var/list/attack_action_types = list()
	var/obj/loot_drop = null
	var/revive_cooldown = FALSE

//Gives player-controlled variants the ability to swap attacks
/mob/living/simple_animal/hostile/asteroid/elite/Initialize(mapload)
	. = ..()
	for(var/action_type in attack_action_types)
		var/datum/action/innate/elite_attack/attack_action = new action_type()
		attack_action.Grant(src)

//Prevents elites from attacking members of their faction (can't hurt themselves either) and lets them mine rock with an attack despite not being able to smash walls.

/mob/living/simple_animal/hostile/asteroid/elite/examine(mob/user)
	. = ..()
	if(del_on_death)
		. += "However, this one appears appears less wild in nature, and calmer around people."

/mob/living/simple_animal/hostile/asteroid/elite/AttackingTarget()
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/M = target
		if(faction_check_mob(M))
			return FALSE
	if(istype(target, /obj/structure/elite_tumor))
		var/obj/structure/elite_tumor/T = target
		if(T.mychild == src && T.activity == TUMOR_PASSIVE)
			var/response = tgui_alert(src, "Re-enter the tumor?", "Despawn yourself?", list("Yes", "No"))
			if(response != "Yes" || QDELETED(src) || !Adjacent(T))
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
	if(ismecha(target))
		var/obj/mecha/M = target
		M.take_damage(50, BRUTE, MELEE, 1)
	if(. && isliving(target)) //Taken from megafauna. This exists purely to stop someone from cheesing a weaker melee fauna by letting it get punched.
		var/mob/living/L = target
		if(L.stat != DEAD)
			if(!client && ranged && ranged_cooldown <= world.time)
				OpenFire()


/mob/living/simple_animal/hostile/asteroid/elite/proc/revive_multiplier() //If on lavaland, return 1, or 1x cooldown. 10 if revived by a non antag, 2 if by an antag. 1 otherwise
	if(is_mining_level(z))
		return 1
	if(revive_cooldown)
		return 10
	if(del_on_death)
		return 2
	return 1

/mob/living/simple_animal/hostile/asteroid/elite/adjustHealth(damage, updating_health)
	. = ..()
	if(del_on_death)
		maxHealth -= damage / 3

/mob/living/simple_animal/hostile/asteroid/elite/ex_act(severity, origin) //No surrounding the tumor with gibtonite and one shotting them.
	switch(severity)
		if(EXPLODE_DEVASTATE)
			adjustBruteLoss(75)

		if(EXPLODE_HEAVY)
			adjustBruteLoss(50)

		if(EXPLODE_LIGHT)
			adjustBruteLoss(25)


/*Basic setup for elite attacks, based on Whoneedspace's megafauna attack setup.
While using this makes the system rely on OnFire, it still gives options for timers not tied to OnFire, and it makes using attacks consistent accross the board for player-controlled elites.*/

/datum/action/innate/elite_attack
	name = "Elite Attack"
	button_icon = 'icons/mob/actions/actions_elites.dmi'
	button_icon_state = ""
	background_icon_state = "bg_default"
	///The displayed message into chat when this attack is selected
	var/chosen_message
	///The internal attack ID for the elite's OpenFire() proc to use
	var/chosen_attack_num = 0

/datum/action/innate/elite_attack/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
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
	build_all_button_icons()

/datum/action/innate/elite_attack/build_button_icon(atom/movable/screen/movable/action_button/button, update_flags, force)
	. = ..()
	if(update_flags & UPDATE_BUTTON_STATUS)
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
	desc = "An odd, pulsing tumor sticking out of the ground. You feel compelled to reach out and touch it..."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/obj/lavaland/tumor.dmi'
	icon_state = "tumor"
	pixel_x = -16
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_range = 3
	anchored = TRUE
	var/activity = TUMOR_INACTIVE
	var/boosted = FALSE
	var/times_won = 0
	var/mob/living/carbon/human/activator = null
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
	var/datum/proximity_monitor/proximity_monitor

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
			user.visible_message("<span class='userdanger'>[src] convulses as [user]'s arm enters its radius. Uh-oh...</span>",
				"<span class='userdanger'>[src] convulses as your arm enters its radius. Your instincts tell you to step back.</span>")
			make_activator(user)
			if(boosted)
				mychild.playsound_local(get_turf(mychild), 'sound/magic/cult_spell.ogg', 40, 0)
				to_chat(mychild, "<span class='warning'>Someone has activated your tumor. You will be returned to fight shortly, get ready!</span>")
			addtimer(CALLBACK(src, PROC_REF(return_elite)), 3 SECONDS)
		if(TUMOR_INACTIVE)
			if(HAS_TRAIT(src, TRAIT_ELITE_CHALLENGER))
				user.visible_message("<span class='warning'>[user] reaches for [src] with [user.p_their()] arm, but nothing happens.</span>",
					"<span class='warning'>You reach for [src] with your arm... but nothing happens.</span>")
				return
			activity = TUMOR_ACTIVE
			var/mob/dead/observer/elitemind = null
			visible_message("<span class='userdanger'>[src] begins to convulse. Your instincts tell you to step back.</span>")
			make_activator(user)
			if(!boosted)
				addtimer(CALLBACK(src, PROC_REF(spawn_elite)), 3 SECONDS)
				return
			visible_message("<span class='danger'>Something within [src] stirs...</span>")
			var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a lavaland elite?", ROLE_ELITE, TRUE, 10 SECONDS, source = src)
			if(length(candidates))
				audible_message("<span class='userdanger'>The stirring sounds increase in volume!</span>")
				elitemind = pick(candidates)
				SEND_SOUND(elitemind, 'sound/magic/cult_spell.ogg')
				to_chat(elitemind, "<b>You have been chosen to play as a Lavaland Elite.\nIn a few seconds, you will be summoned on Lavaland as a monster to fight your activator, in a fight to the death.\n\
					Your attacks can be switched using the buttons on the top left of the HUD, and used by clicking on targets or tiles similar to a gun.\n\
					While the opponent might have an upper hand with powerful mining equipment and tools, you have great power normally limited by AI mobs.\n\
					If you want to win, you'll have to use your powers in creative ways to ensure the kill. It's suggested you try using them all as soon as possible.\n\
					Should you win, you'll receive extra information regarding what to do after. Good luck!</b>")
				addtimer(CALLBACK(src, PROC_REF(spawn_elite), elitemind), 10 SECONDS)
			else
				visible_message("<span class='warning'>The stirring stops, and nothing emerges. Perhaps try again later.</span>")
				activity = TUMOR_INACTIVE
				clear_activator(user)

/obj/structure/elite_tumor/proc/spawn_elite(mob/dead/observer/elitemind)
	var/selectedspawn = pick(potentialspawns)
	mychild = new selectedspawn(loc)
	visible_message("<span class='userdanger'>[mychild] emerges from [src]!</span>")
	playsound(loc,'sound/effects/phasein.ogg', 200, FALSE, 50, TRUE, TRUE)
	if(boosted)
		mychild.key = elitemind.key
		mychild.sentience_act()
		dust_if_respawnable(elitemind)
		notify_ghosts("\A [mychild] has been awakened in \the [get_area(src)]!", enter_link="<a href=byond://?src=[UID()];follow=1>(Click to help)</a>", source = mychild, action = NOTIFY_FOLLOW)
	icon_state = "tumor_popped"
	RegisterSignal(mychild, COMSIG_PARENT_QDELETING, PROC_REF(onEliteLoss))
	INVOKE_ASYNC(src, PROC_REF(arena_checks))
	proximity_monitor = new(src, ARENA_RADIUS) //Boots out humanoid invaders. Minebots / random fauna / that colossus you forgot to clear away allowed.

/obj/structure/elite_tumor/proc/return_elite()
	mychild.forceMove(loc)
	visible_message("<span class='userdanger'>[mychild] emerges from [src]!</span>")
	playsound(loc,'sound/effects/phasein.ogg', 200, FALSE, 50, TRUE, TRUE)
	mychild.revive()
	if(boosted)
		mychild.maxHealth = mychild.maxHealth * 2.5
		mychild.health = mychild.maxHealth
		mychild.grab_ghost()
		notify_ghosts("\A [mychild] has been challenged in \the [get_area(src)]!", enter_link="<a href=byond://?src=[UID()];follow=1>(Click to help)</a>", source = mychild, action = NOTIFY_FOLLOW)
	INVOKE_ASYNC(src, PROC_REF(arena_checks))
	proximity_monitor = new(src, ARENA_RADIUS)

/obj/structure/elite_tumor/Initialize(mapload)
	. = ..()
	gps = new /obj/item/gps/internal/tumor(src)
	START_PROCESSING(SSobj, src)

/obj/structure/elite_tumor/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(gps)
	invaders.Cut()
	if(activator)
		clear_activator(activator)
	if(mychild)
		clear_activator(mychild)
	return ..()

/obj/structure/elite_tumor/proc/make_activator(mob/user)
	if(activator)
		return
	activator = user
	ADD_TRAIT(user, TRAIT_ELITE_CHALLENGER, "activation")
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(clear_activator))

/obj/structure/elite_tumor/proc/clear_activator(mob/source)
	SIGNAL_HANDLER
	if(source == activator)
		activator = null
	else
		mychild = null
	REMOVE_TRAIT(source, TRAIT_ELITE_CHALLENGER, "clear activation")
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/obj/structure/elite_tumor/process()
	if(!isturf(loc))
		return

	for(var/mob/living/simple_animal/hostile/asteroid/elite/elitehere in loc)
		if(elitehere == mychild && activity == TUMOR_PASSIVE)
			mychild.adjustHealth(-mychild.maxHealth * 0.025)
			var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(mychild))
			H.color = "#FF0000"

/obj/structure/elite_tumor/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/organ/internal/regenerative_core) && activity == TUMOR_INACTIVE && !boosted)
		var/obj/item/organ/internal/regenerative_core/core = used
		visible_message("<span class='warning'>As [user] drops the core into [src], [src] appears to swell.</span>")
		icon_state = "advanced_tumor"
		boosted = TRUE
		set_light(6)
		qdel(core)
		return ITEM_INTERACT_COMPLETE

/obj/structure/elite_tumor/examine(mob/user)
	. = ..()
	if(boosted)
		. += "this one glows with a strong intensity"

/obj/structure/elite_tumor/proc/arena_checks()
	if(activity != TUMOR_ACTIVE || QDELETED(src))
		return
	INVOKE_ASYNC(src, PROC_REF(fighters_check))  //Checks to see if our fighters died.
	INVOKE_ASYNC(src, PROC_REF(arena_trap))  //Gets another arena trap queued up for when this one runs out.
	INVOKE_ASYNC(src, PROC_REF(border_check))  //Checks to see if our fighters got out of the arena somehow.
	addtimer(CALLBACK(src, PROC_REF(arena_checks)), 5 SECONDS)

/obj/structure/elite_tumor/proc/fighters_check()
	if(QDELETED(mychild) || mychild.stat == DEAD)
		onEliteLoss()
		return
	if(QDELETED(activator) || activator.stat == DEAD || (activator.health <= HEALTH_THRESHOLD_DEAD))
		onEliteWon()

/obj/structure/elite_tumor/proc/arena_trap()
	var/turf/tumor_turf = get_turf(src)
	if(loc == null)
		return
	for(var/tumor_range_turfs in RANGE_EDGE_TURFS(ARENA_RADIUS, tumor_turf))
		new /obj/effect/temp_visual/elite_tumor_wall(tumor_range_turfs, src)

/obj/structure/elite_tumor/proc/border_check()
	if(activator != null && get_dist(src, activator) >= ARENA_RADIUS)
		activator.forceMove(loc)
		visible_message("<span class='warning'>[activator] suddenly reappears above [src]!</span>")
		playsound(loc,'sound/effects/phasein.ogg', 200, FALSE, 50, TRUE, TRUE)
	if(mychild != null && get_dist(src, mychild) >= ARENA_RADIUS)
		mychild.forceMove(loc)
		visible_message("<span class='warning'>[mychild] suddenly reappears above [src]!</span>")
		playsound(loc,'sound/effects/phasein.ogg', 200, FALSE, 50, TRUE, TRUE)

/obj/structure/elite_tumor/HasProximity(atom/movable/AM)
	if(!ishuman(AM) && !isrobot(AM))
		return
	var/mob/living/M = AM
	if(M == activator)
		return
	if(M in invaders)
		to_chat(M, "<span class='colossus'><b>You dare to try to break the sanctity of our arena? SUFFER...</b></span>")
		for(var/i in 1 to 4)
			M.apply_status_effect(STATUS_EFFECT_VOID_PRICE) /// Hey kids, want 60 brute damage, increased by 40 each time you do it? Well, here you go!
	else
		to_chat(M, "<span class='userdanger'>Only spectators are allowed, while the arena is in combat...</span>")
		invaders += M
	var/list/valid_turfs = RANGE_EDGE_TURFS(ARENA_RADIUS + 2, src) // extra safety
	M.forceMove(pick(valid_turfs)) //Doesn't check for lava. Don't cheese it.
	playsound(M, 'sound/effects/phasein.ogg', 200, FALSE, 50, TRUE, TRUE)


/obj/structure/elite_tumor/proc/onEliteLoss()
	playsound(loc,'sound/effects/tendril_destroyed.ogg', 200, FALSE, 50, TRUE, TRUE)
	visible_message("<span class='warning'>[src] begins to convulse violently before beginning to dissipate.</span>")
	visible_message("<span class='warning'>As [src] closes, something is forced up from down below.</span>")
	var/obj/structure/closet/crate/necropolis/tendril/lootbox = new /obj/structure/closet/crate/necropolis/tendril(loc)
	if(boosted)
		if(mychild.loot_drop != null && prob(50))
			new mychild.loot_drop(lootbox)
		else
			new /obj/item/tumor_shard(lootbox)
		SSblackbox.record_feedback("tally", "player_controlled_elite_loss", 1, mychild.name)
	else
		SSblackbox.record_feedback("tally", "ai_controlled_elite_loss", 1, mychild.name)
	qdel(src)

/obj/structure/elite_tumor/proc/onEliteWon()
	activity = TUMOR_PASSIVE
	if(activator)
		clear_activator(activator)
	mychild.revive()
	if(boosted)
		SSblackbox.record_feedback("tally", "player_controlled_elite_win", 1, mychild.name)
		times_won++
		mychild.maxHealth = mychild.maxHealth * 0.4
		mychild.health = mychild.maxHealth
		var/sound/elite_sound = sound('sound/magic/wandodeath.ogg')
		var/turf/T = get_turf(src)
		for(var/mob/M in GLOB.player_list)
			if(M.z == z && M.client)
				to_chat(M, "<span class='danger'>Thunder rumbles. Light glows in the distance. Something big happened... somewhere.</span>")
				M.playsound_local(T, null, 100, FALSE, 0, FALSE, pressure_affected = FALSE, S = elite_sound)
				M.flash_screen_color("#FF0000", 2.5 SECONDS)
	else
		SSblackbox.record_feedback("tally", "ai_controlled_elite_win", 1, mychild.name)
	if(times_won == 1)
		mychild.playsound_local(get_turf(mychild), 'sound/magic/cult_spell.ogg', 40, FALSE)
		var/list/text = list()
		text += "<span class='warning'>As the life in the activator's eyes fade, the forcefield around you dies out and you feel your power subside.</span>"
		text += "<span class='warning'>Despite this inferno being your home, you feel as if you aren't welcome here anymore.</span>"
		text += "<span class='warning'>Without any guidance, your purpose is now for you to decide.\n</span>"
		text += "<b>Your max health has been halved, but can now heal by standing on your tumor. Note, it's your only way to heal.</b>"
		text += "<b>Bear in mind, if anyone interacts with your tumor, you'll be resummoned here to carry out another fight. In such a case, you will regain your full max health.</b>"
		text += "<b>Also, be wary of your fellow inhabitants, they likely won't be happy to see you! \n</b>"
		text += "<span class='big bold'>Note that you are a lavaland monster, and thus not allied to the station.</span>"
		text += "<span class='big bold'>You should not cooperate or act friendly with any station crew unless under extreme circumstances!</span>"
		text += "<span class='warning'>Do not attack the Mining Station or Labour Camp, unless the Shaft Miner you are actively fighting runs into the Station/Camp.</span>"
		text += "<span class='warning'>After they are killed, you must withdraw. If you wish to continue attacking the Station, you MUST ahelp.</span>"
		text += "<span class='warning'>If teleported to the Station by jaunter, you are allowed to attack people on Station, until you get killed.</span>"
		to_chat(mychild, text.Join(" "))

	QDEL_NULL(proximity_monitor)

/obj/item/tumor_shard
	name = "tumor shard"
	desc = "A strange, sharp, crystal shard from an odd tumor on Lavaland. Stabbing the corpse of a lavaland elite with this will revive them, assuming their soul still lingers. Revived lavaland elites only have half their max health, but are completely loyal to their reviver."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "crevice_shard"
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	new_attack_chain = TRUE

/obj/item/tumor_shard/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(target)

	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite))
		var/mob/living/simple_animal/hostile/asteroid/elite/E = target
		if(E.stat != DEAD || E.sentience_type != SENTIENCE_BOSS || !E.key)
			user.visible_message("It appears [E] is unable to be revived right now. Perhaps try again later.")
			return ITEM_INTERACT_COMPLETE
		E.faction = list("\ref[user]")
		E.friends += user
		E.revive()
		user.visible_message("<span class='notice'>[user] stabs [E] with [src], reviving it.</span>")
		SEND_SOUND(E, 'sound/magic/cult_spell.ogg')
		to_chat(E, "<span class='userdanger'>You have been revived by [user], and you owe [user] a great debt. Assist [user.p_them()] in achieving [user.p_their()] goals, regardless of risk.</span>")
		to_chat(E, "<span class='big bold'>Note that you now share the loyalties of [user]. You are expected not to intentionally sabotage their faction unless commanded to!</span>")
		if(user.mind.special_role)
			E.maxHealth = 300
			E.health = 300
		else
			E.maxHealth = 200
			E.health = 200
			E.revive_cooldown = TRUE
		E.sentience_type = SENTIENCE_ORGANIC
		E.del_on_death = TRUE
		qdel(src)
	else
		to_chat(user, "<span class='notice'>[src] only works on the corpse of a sentient lavaland elite.</span>")

	return ITEM_INTERACT_COMPLETE

/obj/effect/temp_visual/elite_tumor_wall
	name = "magic wall"
	icon = 'icons/turf/walls/hierophant_wall_temp.dmi'
	icon_state = "hierophant_wall_temp-0"
	base_icon_state = "hierophant_wall_temp"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_HIERO_WALL)
	canSmoothWith = list(SMOOTH_GROUP_HIERO_WALL)
	duration = 5 SECONDS
	layer = BELOW_MOB_LAYER
	color = rgb(255,0,0)
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = LIGHT_COLOR_PURE_RED

/obj/effect/temp_visual/elite_tumor_wall/Initialize(mapload, new_caster)
	. = ..()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
		QUEUE_SMOOTH(src)

/obj/effect/temp_visual/elite_tumor_wall/Destroy()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/temp_visual/elite_tumor_wall/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(isliving(mover))
		return FALSE

/obj/effect/temp_visual/elite_tumor_wall/gargantua
	duration = 35 SECONDS // A bit longer than the spell lasts, it should be cleaned up by the spell otherwise it might not GC properly

/obj/effect/temp_visual/elite_tumor_wall/gargantua/CanPass(atom/movable/mover, border_dir)
	return FALSE

/obj/item/gps/internal/tumor
	icon_state = null
	gpstag = "Cancerous Signal"
	desc = "Ghosts in a fauna? That's cancerous!"

#undef TUMOR_INACTIVE
#undef TUMOR_ACTIVE
#undef TUMOR_PASSIVE
#undef ARENA_RADIUS
