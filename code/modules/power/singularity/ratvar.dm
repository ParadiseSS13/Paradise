/obj/singularity/ratvar
	name = "Ratvar, the Clockwork Justiciar"
	desc = "..."
	icon = 'icons/obj/512x512.dmi'
	icon_state = "ratvar"
	pixel_x = -235
	pixel_y = -248
	current_size = 12
	move_self = TRUE
	contained = FALSE
	dissipate = FALSE
	move_self = TRUE
	grav_pull = 10
	consume_range = 12
	gender = NEUTER

/obj/singularity/ratvar/admin_investigate_setup()
	return

/obj/singularity/ratvar/New()
	..()
	set_light(15, 1, "#BE8700")
	to_chat(world, "<span class='ratvar'>ONCE AGAIN MY LIGHT SHINES AMONG THESE PATHETIC STARS</span>")
	SEND_SOUND(world, 'sound/effects/ratvar_reveal.ogg')

	var/datum/game_mode/gamemode = SSticker.mode
	if(gamemode)
		gamemode.clocker_objs.succesful_summon()

	var/area/A = get_area(src)
	if(A)
		var/image/alert_overlay = image('icons/effects/clockwork_effects.dmi', "ghostalert")
		notify_ghosts("The Justiciar's light calls to you! Reach out to Ratvar in [A.name] to be granted a shell to spread his glory!", source = src, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)

	ratvar_spawn_animation()

	addtimer(CALLBACK(src, .proc/call_shuttle), 7 SECONDS)

/obj/singularity/ratvar/proc/call_shuttle()
	SSshuttle.emergency.request(null, 0.3)
	SSshuttle.emergency.canRecall = FALSE // Cannot recall

/obj/singularity/ratvar/Destroy()
	to_chat(world, "<span class='ratvar'>RATVAR HAS FALLEN</span>")
	SEND_SOUND(world, 'sound/hallucinations/wail.ogg')
	var/datum/game_mode/gamemode = SSticker.mode
	if(gamemode)
		gamemode.clocker_objs.ratvar_death()
		for(var/datum/mind/clock_mind in SSticker.mode.clockwork_cult)
			if(clock_mind && clock_mind.current)
				to_chat(clock_mind.current, "<span class='clocklarge'>RETRIBUTION!</span>")
				to_chat(clock_mind.current, "<span class='clock'>Current goal: Slaughter the heretics!</span>")
	return ..()

/obj/singularity/ratvar/attack_ghost(mob/dead/observer/user)
	var/mob/living/simple_animal/hostile/clockwork/marauder/cog = new (get_turf(src))
	cog.key = user.key
	SSticker.mode.add_clocker(cog.mind)


/obj/singularity/ratvar/process()
	eat()
	move()
	if(prob(25))
		mezzer()


/obj/singularity/ratvar/Bump(atom/A)//you dare stand before a god?!
	godsmack(A)
	return

/obj/singularity/ratvar/Bumped(atom/A)
	godsmack(A)
	return

/obj/singularity/ratvar/proc/godsmack(atom/A)
	if(istype(A,/obj/))
		var/obj/O = A
		O.ex_act(1)
		if(O) qdel(O)

	else if(isturf(A))
		var/turf/T = A
		T.ChangeTurf(/turf/simulated/floor/clockwork)

/obj/singularity/ratvar/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(!isclocker(M))
				to_chat(M, "<span class='warning'>You feel your sanity crumble away in an instant as you gaze upon [src.name]...</span>")
				M.apply_effect(3, STUN)

/obj/singularity/ratvar/consume(atom/A)
	A.ratvar_act()

/obj/singularity/ratvar/ex_act()
	return

/obj/singularity/ratvar/singularity_act() //handled in /obj/singularity/proc/consume
	return

/obj/singularity/ratvar/proc/ratvar_spawn_animation()
	icon = 'icons/obj/ratvar_spawn_anim.dmi'
	dir = SOUTH
	move_self = FALSE
	flick("ratvar", src)
	sleep(1.1 SECONDS)
	move_self = TRUE
	icon = initial(icon)
