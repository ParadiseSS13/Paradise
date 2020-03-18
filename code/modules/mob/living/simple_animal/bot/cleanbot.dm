//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot0"
	density = 0
	anchored = 0
	health = 25
	maxHealth = 25
	radio_channel = "Service" //Service
	bot_filter = RADIO_CLEANBOT
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_purpose = "seek out messes and clean them"
	bot_core_type = /obj/machinery/bot_core/cleanbot
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.1"
	pass_flags = PASSMOB
	path_image_color = "#993299"


	var/blood = 1
	var/list/target_types = list()
	var/obj/effect/decal/cleanable/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc

/mob/living/simple_animal/bot/cleanbot/New()
	..()
	get_targets()
	icon_state = "cleanbot[on]"

	var/datum/job/janitor/J = new/datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access

/mob/living/simple_animal/bot/cleanbot/turn_on()
	..()
	icon_state = "cleanbot[on]"

/mob/living/simple_animal/bot/cleanbot/turn_off()
	..()
	icon_state = "cleanbot[on]"

/mob/living/simple_animal/bot/cleanbot/bot_reset()
	..()
	ignore_list = list() //Allows the bot to clean targets it previously ignored due to being unreachable.
	target = null
	oldloc = null

/mob/living/simple_animal/bot/cleanbot/set_custom_texts()
	text_hack = "You corrupt [name]'s cleaning software."
	text_dehack = "[name]'s software has been reset!"
	text_dehack_fail = "[name] does not seem to respond to your repair code!"

/mob/living/simple_animal/bot/cleanbot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id)||istype(W, /obj/item/pda))
		if(bot_core.allowed(user) && !open && !emagged)
			locked = !locked
			to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] \the [src] behaviour controls.</span>")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='notice'>\The [src] doesn't seem to respect your authority.</span>")
	else
		return ..()

/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, "<span class='danger'>[src] buzzes and beeps.</span>")

/mob/living/simple_animal/bot/cleanbot/process_scan(obj/effect/decal/cleanable/D)
	for(var/T in target_types)
		if(istype(D, T))
			return D

/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_CLEANING)
		return

	if(emagged == 2) //Emag functions
		if(istype(loc,/turf/simulated))
			if(prob(10)) //Wets floors randomly
				var/turf/simulated/T = loc
				T.MakeSlippery()

			if(prob(5)) //Spawns foam!
				visible_message("<span class='danger'>[src] whirs and bubbles violently, before releasing a plume of froth!</span>")
				new /obj/effect/particle_effect/foam(loc)

	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(!target) //Search for cleanables it can see.
		target = scan(/obj/effect/decal/cleanable/)

	if(!target && auto_patrol) //Search for cleanables it can see.
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	if(target)
		if(!path || path.len == 0) //No path, need a new one
			//Try to produce a path to the target, and ignore airlocks to which it has access.
			path = get_path_to(src, target.loc, /turf/proc/Distance_cardinal, 0, 30, id=access_card)
			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				path = list()
				return
			mode = BOT_MOVING
		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return

	if(target && loc == target.loc)
		clean(target)
		path = list()
		target = null

	oldloc = loc

/mob/living/simple_animal/bot/cleanbot/proc/get_targets()
	target_types = new/list()

	target_types += /obj/effect/decal/cleanable/blood/oil
	target_types += /obj/effect/decal/cleanable/vomit
	target_types += /obj/effect/decal/cleanable/blood/gibs/robot
	target_types += /obj/effect/decal/cleanable/crayon
	target_types += /obj/effect/decal/cleanable/liquid_fuel
	target_types += /obj/effect/decal/cleanable/molten_object
	target_types += /obj/effect/decal/cleanable/tomato_smudge
	target_types += /obj/effect/decal/cleanable/egg_smudge
	target_types += /obj/effect/decal/cleanable/pie_smudge
	target_types += /obj/effect/decal/cleanable/flour
	target_types += /obj/effect/decal/cleanable/ash
	target_types += /obj/effect/decal/cleanable/greenglow
	target_types += /obj/effect/decal/cleanable/dirt

	if(blood)
		target_types += /obj/effect/decal/cleanable/blood/xeno/
		target_types += /obj/effect/decal/cleanable/blood/gibs/xeno
		target_types += /obj/effect/decal/cleanable/blood/
		target_types += /obj/effect/decal/cleanable/blood/gibs/
		target_types += /obj/effect/decal/cleanable/blood/tracks
		target_types += /obj/effect/decal/cleanable/dirt
		target_types += /obj/effect/decal/cleanable/trail_holder

/mob/living/simple_animal/bot/cleanbot/proc/clean(obj/effect/decal/cleanable/target)
	anchored = 1
	icon_state = "cleanbot-c"
	visible_message("<span class='notice'>[src] begins to clean up [target]</span>")
	mode = BOT_CLEANING
	spawn(50)
		if(mode == BOT_CLEANING)
			QDEL_NULL(target)
			anchored = 0
		mode = BOT_IDLE
		icon_state = "cleanbot[on]"

/mob/living/simple_animal/bot/cleanbot/explode()
	on = 0
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)
	new /obj/item/reagent_containers/glass/bucket(Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)
	do_sparks(3, 1, src)
	..()

/obj/machinery/bot_core/cleanbot
	req_one_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)


/mob/living/simple_animal/bot/cleanbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
<TT><B>Cleaner v1.1 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"},
text("<A href='?src=[UID()];power=1'>[on ? "On" : "Off"]</A>"))
	if(!locked || issilicon(user) || user.can_admin_interact())
		dat += text({"<BR>Cleans Blood: []<BR>"}, text("<A href='?src=[UID()];operation=blood'>[blood ? "Yes" : "No"]</A>"))
		dat += text({"<BR>Patrol station: []<BR>"}, text("<A href='?src=[UID()];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A>"))
	return dat

/mob/living/simple_animal/bot/cleanbot/Topic(href, href_list)
	if(..())
		return 1
	switch(href_list["operation"])
		if("blood")
			blood =!blood
			get_targets()
			update_controls()

/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/A)
	if(istype(A,/obj/effect/decal/cleanable))
		clean(A)
	else
		..()
