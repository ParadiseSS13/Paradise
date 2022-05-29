/obj/singularity/narsie //Moving narsie to a child object of the singularity so it can be made to function differently. --NEO
	name = "Nar'sie's Avatar"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/magic_terror.dmi'
	pixel_x = -89
	pixel_y = -85
	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO
	contained = FALSE
	dissipate = FALSE
	move_self = TRUE
	grav_pull = 5
	consume_range = 6
	gender = FEMALE

/obj/singularity/narsie/admin_investigate_setup()
	return

/obj/singularity/narsie/large
	name = "Nar'Sie"
	icon = 'icons/obj/narsie.dmi'
	// Pixel stuff centers Narsie.
	pixel_x = -236
	pixel_y = -256
	current_size = 12
	move_self = TRUE //Do we move on our own?
	grav_pull = 10
	consume_range = 12 //How many tiles out do we eat

/obj/singularity/narsie/large/New()
	..()
	icon_state = SSticker.cultdat?.entity_icon_state
	name = SSticker.cultdat?.entity_name
	to_chat(world, "<font size='15' color='red'><b> [uppertext(name)] HAS RISEN</b></font>")
	SEND_SOUND(world, 'sound/effects/narsie_risen.ogg')

	var/datum/game_mode/gamemode = SSticker.mode
	if(gamemode)
		gamemode.cult_objs.succesful_summon()

	var/area/A = get_area(src)
	if(A)
		var/image/alert_overlay = image('icons/effects/cult_effects.dmi', "ghostalertsie")
		notify_ghosts("[name] has risen in \the [A.name]. Reach out to the Geometer to be given a new shell for your soul.", source = src, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)

	narsie_spawn_animation()

	addtimer(CALLBACK(src, .proc/call_shuttle), 7 SECONDS)

/obj/singularity/narsie/large/proc/call_shuttle()
	SSshuttle.emergency.request(null, 0.3)
	SSshuttle.emergency.canRecall = FALSE // Cannot recall


/obj/singularity/narsie/large/Destroy()
	to_chat(world, "<font size='15' color='red'><b> [uppertext(name)] HAS FALLEN</b></font>")
	SEND_SOUND(world, 'sound/hallucinations/wail.ogg')
	var/datum/game_mode/gamemode = SSticker.mode
	if(gamemode)
		gamemode.cult_objs.narsie_death()
		for(var/datum/mind/cult_mind in SSticker.mode.cult)
			if(cult_mind && cult_mind.current)
				to_chat(cult_mind.current, "<span class='cultlarge'>RETRIBUTION!</span>")
				to_chat(cult_mind.current, "<span class='cult'>Current goal: Slaughter the heretics!</span>")
	..()

/obj/singularity/narsie/large/attack_ghost(mob/dead/observer/user)
	make_new_construct(/mob/living/simple_animal/hostile/construct/harvester, user, cult_override = TRUE)

/obj/singularity/narsie/process()
	eat()
	if(!target || prob(5))
		pickcultist()
	move()
	if(prob(25))
		mezzer()


/obj/singularity/narsie/Bump(atom/A)//you dare stand before a god?!
	godsmack(A)
	return

/obj/singularity/narsie/Bumped(atom/A)
	godsmack(A)
	return

/obj/singularity/narsie/proc/godsmack(atom/A)
	if(istype(A,/obj/))
		var/obj/O = A
		O.ex_act(1)
		if(O) qdel(O)

	else if(isturf(A))
		var/turf/T = A
		T.ChangeTurf(/turf/simulated/floor/engine/cult)

/obj/singularity/narsie/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(!iscultist(M))
				to_chat(M, "<span class='warning'>You feel your sanity crumble away in an instant as you gaze upon [src.name]...</span>")
				M.apply_effect(3, STUN)


/obj/singularity/narsie/consume(atom/A)
	A.narsie_act()

/obj/singularity/narsie/ex_act() //No throwing bombs at it either. --NEO
	return

/obj/singularity/narsie/singularity_act() //handled in /obj/singularity/proc/consume
	return

/obj/singularity/narsie/proc/pickcultist() //Narsie rewards his cultists with being devoured first, then picks a ghost to follow. --NEO
	var/list/cultists = list()
	var/list/noncultists = list()
	for(var/mob/living/carbon/food in GLOB.alive_mob_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
		var/turf/pos = get_turf(food)
		if(pos.z != src.z)
			continue

		if(iscultist(food))
			cultists += food
		else
			noncultists += food

		if(length(cultists)) //cultists get higher priority
			acquire(pick(cultists))
			return

		if(length(noncultists))
			acquire(pick(noncultists))
			return

	//no living humans, follow a ghost instead.
	for(var/mob/dead/observer/ghost in GLOB.player_list)
		if(!ghost.client)
			continue
		var/turf/pos = get_turf(ghost)
		if(pos.z != src.z)
			continue
		cultists += ghost
	if(length(cultists))
		acquire(pick(cultists))
		return


/obj/singularity/narsie/proc/acquire(mob/food)
	if(food == target)
		return
	if(!target)
		return
	to_chat(target, "<span class='cultlarge'>[uppertext(SSticker.cultdat.entity_name)] HAS LOST INTEREST IN YOU</span>")
	target = food
	if(ishuman(target))
		to_chat(target, "<span class ='cultlarge'>[uppertext(SSticker.cultdat.entity_name)] HUNGERS FOR YOUR SOUL</span>")
	else
		to_chat(target, "<span class ='cultlarge'>[uppertext(SSticker.cultdat.entity_name)] HAS CHOSEN YOU TO LEAD HER TO HER NEXT MEAL</span>")

//Wizard narsie
/obj/singularity/narsie/wizard
	grav_pull = 0

/obj/singularity/narsie/wizard/eat()
	for(var/atom/X in orange(consume_range,src))
		if(isturf(X) || istype(X, /atom/movable))
			consume(X)
	return


/obj/singularity/narsie/proc/narsie_spawn_animation()
	icon = 'icons/obj/narsie_spawn_anim.dmi'
	dir = SOUTH
	move_self = FALSE
	flick(SSticker.cultdat?.entity_spawn_animation, src)
	sleep(11)
	move_self = TRUE
	icon = initial(icon)
