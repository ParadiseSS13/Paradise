/obj/singularity/narsie //Moving narsie to a child object of the singularity so it can be made to function differently. --NEO
	name = "Nar-sie's Avatar"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/magic_terror.dmi'
	pixel_x = -89
	pixel_y = -85
	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO
	contained = 0 //Are we going to move around?
	dissipate = 0 //Do we lose energy over time?
	move_self = 1 //Do we move on our own?
	grav_pull = 5 //How many tiles out do we pull?
	consume_range = 6 //How many tiles out do we eat
	gender = FEMALE

/obj/singularity/narsie/large
	name = "Nar-Sie"
	icon = 'icons/obj/narsie.dmi'
	// Pixel stuff centers Narsie.
	pixel_x = -236
	pixel_y = -256
	current_size = 12
	move_self = 1 //Do we move on our own?
	grav_pull = 10
	consume_range = 12 //How many tiles out do we eat

/obj/singularity/narsie/large/New()
	..()
	icon_state = ticker.cultdat.entity_icon_state
	name = ticker.cultdat.entity_name
	to_chat(world, "<font size='15' color='red'><b> [name] HAS RISEN</b></font>")
	world << pick(sound('sound/hallucinations/im_here1.ogg'), sound('sound/hallucinations/im_here2.ogg'))

	var/area/A = get_area(src)
	if(A)
		var/image/alert_overlay = image('icons/effects/cult_effects.dmi', "ghostalertsie")
		notify_ghosts("Nar-Sie has risen in \the [A.name]. Reach out to the Geometer to be given a new shell for your soul.", source = src, alert_overlay = alert_overlay, action=NOTIFY_ATTACK)

	narsie_spawn_animation()

	sleep(70)
	SSshuttle.emergency.request(null, 0.3) // Cannot recall
	SSshuttle.emergency.canRecall = FALSE

/obj/singularity/narsie/large/attack_ghost(mob/dead/observer/user as mob)
	makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, user, null, 1)
	new /obj/effect/particle_effect/smoke/sleeping(user.loc)


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

/obj/singularity/narsie/proc/godsmack(var/atom/A)
	if(istype(A,/obj/))
		var/obj/O = A
		O.ex_act(1.0)
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


/obj/singularity/narsie/consume(var/atom/A)
	A.narsie_act()


/obj/singularity/narsie/ex_act() //No throwing bombs at it either. --NEO
	return


/obj/singularity/narsie/proc/pickcultist() //Narsie rewards his cultists with being devoured first, then picks a ghost to follow. --NEO
	var/list/cultists = list()
	var/list/noncultists = list()
	for(var/mob/living/carbon/food in GLOB.living_mob_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
		var/turf/pos = get_turf(food)
		if(pos.z != src.z)
			continue

		if(iscultist(food))
			cultists += food
		else
			noncultists += food

		if(cultists.len) //cultists get higher priority
			acquire(pick(cultists))
			return

		if(noncultists.len)
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
	if(cultists.len)
		acquire(pick(cultists))
		return


/obj/singularity/narsie/proc/acquire(var/mob/food)
	if(food == target)
		return
	to_chat(target, "<span class='cultlarge'>[uppertext(ticker.cultdat.entity_name)] HAS LOST INTEREST IN YOU</span>")
	target = food
	if(ishuman(target))
		to_chat(target, "<span class ='cultlarge'>[uppertext(ticker.cultdat.entity_name)] HUNGERS FOR YOUR SOUL</span>")
	else
		to_chat(target, "<span class ='cultlarge'>[uppertext(ticker.cultdat.entity_name)] HAS CHOSEN YOU TO LEAD HER TO HER NEXT MEAL</span>")

//Wizard narsie
/obj/singularity/narsie/wizard
	grav_pull = 0

/obj/singularity/narsie/wizard/eat()
	set background = BACKGROUND_ENABLED
	for(var/atom/X in orange(consume_range,src))
		if(isturf(X) || istype(X, /atom/movable))
			consume(X)
	return


/obj/singularity/narsie/proc/narsie_spawn_animation()
	icon = 'icons/obj/narsie_spawn_anim.dmi'
	dir = SOUTH
	move_self = 0
	flick("narsie_spawn_anim",src)
	sleep(11)
	move_self = 1
	icon = initial(icon)
