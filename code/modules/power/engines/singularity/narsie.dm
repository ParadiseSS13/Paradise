/// Moving narsie to a child object of the singularity so it can be made to function differently. --NEO
/obj/singularity/narsie
	name = "Nar'sie's Avatar"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/magic_terror.dmi'
	icon_state = null
	pixel_x = -89
	pixel_y = -85
	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO
	dissipate = FALSE
	grav_pull = 5
	consume_range = 6
	gender = FEMALE

/obj/singularity/narsie/admin_investigate_setup()
	return

/obj/singularity/narsie/large
	name = "Nar'Sie"
	icon = 'icons/obj/narsie.dmi'
	icon_state = "narsie"
	// Pixel stuff centers Narsie.
	pixel_x = -236
	pixel_y = -256
	current_size = 12
	grav_pull = 10
	consume_range = 12 //How many tiles out do we eat

/obj/singularity/narsie/large/Initialize(mapload, starting_energy)
	. = ..()
	icon_state = GET_CULT_DATA(entity_icon_state, initial(icon_state))
	name = GET_CULT_DATA(entity_name, initial(name))

	var/sound/cry = sound(pick('sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg'))

	for(var/mob/living/player in GLOB.player_list)
		if(isnewplayer(player))
			continue

		to_chat(player, "<font size='15' color='red'><b> [uppertext(name)] HAS RISEN</b></font>")
		SEND_SOUND(player, cry)

	SSticker.mode?.cult_team?.successful_summon()

	var/area/A = get_area(src)
	if(A)
		var/image/alert_overlay = image('icons/effects/cult_effects.dmi', "ghostalertsie")
		notify_ghosts("[name] has risen in \the [A.name]. Reach out to the Geometer to be given a new shell for your soul.", source = src, alert_overlay = alert_overlay, action = NOTIFY_ATTACK)

	INVOKE_ASYNC(src, PROC_REF(narsie_spawn_animation))
	addtimer(CALLBACK(src, PROC_REF(call_shuttle)), 7 SECONDS)

/obj/singularity/narsie/large/proc/call_shuttle()
	SSshuttle.emergency.request(null, 0.3)
	SSshuttle.emergency.canRecall = FALSE // Cannot recall

/obj/singularity/narsie/large/Destroy()
	to_chat(world, "<font size='15' color='red'><b> [uppertext(name)] HAS FALLEN</b></font>")
	SEND_SOUND(world, sound('sound/hallucinations/wail.ogg'))
	SSticker.mode?.cult_team?.narsie_death()
	return ..()

/obj/singularity/narsie/large/attack_ghost(mob/dead/observer/user as mob)
	user.forceMove(get_turf(src)) //make_new_construct spawns harvesters at observers locations, could be used to get into admin rooms/CC
	make_new_construct(/mob/living/simple_animal/hostile/construct/harvester, user, cult_override = TRUE, create_smoke = TRUE)

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
	if(isobj(A))
		var/obj/O = A
		O.ex_act(EXPLODE_DEVASTATE)
		if(O) qdel(O)

	else if(isturf(A))
		var/turf/T = A
		T.ChangeTurf(/turf/simulated/floor/engine/cult)

/obj/singularity/narsie/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(!IS_CULTIST(M))
				to_chat(M, "<span class='warning'>You feel your sanity crumble away in an instant as you gaze upon [src.name]...</span>")
				M.Stun(6 SECONDS)


/obj/singularity/narsie/consume(atom/A)
	A.narsie_act()

/obj/singularity/narsie/ex_act() //No throwing bombs at it either. --NEO
	return

/obj/singularity/narsie/singularity_act() //handled in /obj/singularity/proc/consume
	return

/obj/singularity/narsie/notify_dead()
	return

/obj/singularity/narsie/proc/pickcultist() //Narsie rewards his cultists with being devoured first, then picks a ghost to follow. --NEO
	var/list/noncultists = list()
	for(var/mob/living/carbon/food in GLOB.alive_mob_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
		var/turf/pos = get_turf(food)
		if(!pos) // The GLOB mob list (alive or dead) can contain null entries, so we gotta check if we're trying to get the turf of something that doesn't exist
			return
		if(pos.z != src.z)
			continue

		if(!IS_CULTIST(food))
			noncultists += food

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
		noncultists += ghost
	if(length(noncultists))
		acquire(pick(noncultists))


/obj/singularity/narsie/proc/acquire(mob/food)
	if(food == target)
		return
	if(!target)
		return
	to_chat(target, "<span class='cultlarge'>[uppertext(GET_CULT_DATA(entity_name, name))] HAS LOST INTEREST IN YOU</span>")
	target = food
	if(ishuman(target))
		to_chat(target, "<span class ='cultlarge'>[uppertext(GET_CULT_DATA(entity_name, name))] HUNGERS FOR YOUR SOUL</span>")
	else
		to_chat(target, "<span class ='cultlarge'>[uppertext(GET_CULT_DATA(entity_name, name))] HAS CHOSEN YOU TO LEAD HER TO HER NEXT MEAL</span>")

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
	flick(GET_CULT_DATA(entity_spawn_animation, "narsie_spawn_anim"), src)
	sleep(11)
	move_self = TRUE
	icon = initial(icon)
