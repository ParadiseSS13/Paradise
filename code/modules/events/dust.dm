/datum/event/dust
	var/qnty = 1

/datum/event/dust/setup()
	qnty = rand(1,5)

/datum/event/dust/start()
	while(qnty-- > 0)
		new /obj/effect/space_dust/weak()

/obj/effect/space_dust
	name = "Space Dust"
	desc = "Dust in space."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "dust"
	density = TRUE
	var/strength = 2 //ex_act severity number
	var/life = 2 //how many things we hit before qdel(src)
	var/atom/goal = null
	var/shake_chance = 50

/obj/effect/space_dust/weak
	strength = 3
	life = 1

/obj/effect/space_dust/strong
	strength = 1
	life = 6

/obj/effect/space_dust/super
	strength = 1
	life = 40

/obj/effect/space_dust/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_EDGE_TRANSITIONS, ROUNDSTART_TRAIT)

	var/startside = pick(GLOB.cardinal)
	GLOB.meteor_list += src

	var/turf/start = pick_edge_loc(startside, level_name_to_num(MAIN_STATION))
	forceMove(start)
	goal = pick_edge_loc(REVERSE_DIR(startside), level_name_to_num(MAIN_STATION))
	GLOB.move_manager.home_onto(src, goal, 1)

/obj/effect/space_dust/Bump(atom/A)
	if(QDELETED(src))
		return
	if(prob(shake_chance))
		for(var/mob/M in range(10, src))
			if(!M.stat && !is_ai(M))
				shake_camera(M, 3, 1)
	playsound(loc, 'sound/effects/meteorimpact.ogg', 40, 1)

	INVOKE_ASYNC(src, PROC_REF(impact_meteor), A) // ex_act can have some sleeps in it

/obj/effect/space_dust/proc/impact_meteor(atom/A)
	var/turf/where = get_turf(A)
	if(ismob(A))
		A.ex_act(strength)//This should work for now I guess
	else if(!istype(A, /obj/machinery/power/emitter) && !istype(A, /obj/machinery/field/generator)) //Protect the singularity from getting released every round!
		A.ex_act(strength) //Changing emitter/field gen ex_act would make it immune to bombs and C4

	life--
	if(life <= 0)
		GLOB.move_manager.stop_looping(src)
		on_shatter(where)
		qdel(src)

/obj/effect/space_dust/proc/on_shatter(turf/where)
	return

/obj/effect/space_dust/Bumped(atom/A)
	Bump(A)
	return

/obj/effect/space_dust/ex_act(severity)
	qdel(src)

/obj/effect/space_dust/Destroy()
	GLOB.meteor_list -= src
	return ..()
