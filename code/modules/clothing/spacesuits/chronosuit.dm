/obj/item/clothing/head/helmet/space/chronos
	name = "chronosuit helmet"
	desc = "A white helmet with an opaque blue visor."
	icon_state = "chronohelmet"
	slowdown = 1
	armor = list(MELEE = 75, BULLET = 75, LASER = 75, ENERGY = 75, BOMB = 30, RAD = 90, FIRE = INFINITY, ACID = INFINITY)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/obj/item/clothing/suit/space/chronos/suit = null

/obj/item/clothing/head/helmet/space/chronos/dropped()
	if(suit)
		suit.deactivate()
	..()

/obj/item/clothing/head/helmet/space/chronos/Destroy()
	dropped()
	return ..()

/obj/item/clothing/suit/space/chronos
	name = "chronosuit"
	desc = "An advanced spacesuit equipped with teleportation and anti-compression technology."
	icon_state = "chronosuit"
	actions_types = list(/datum/action/item_action/toggle)
	armor = list(MELEE = 75, BULLET = 75, LASER = 75, ENERGY = 75, BOMB = 30, RAD = 90, FIRE = INFINITY, ACID = INFINITY)
	resistance_flags = FIRE_PROOF | ACID_PROOF

	var/obj/item/clothing/head/helmet/space/chronos/helmet = null
	var/obj/effect/chronos_cam/camera = null
	var/activating = FALSE
	var/activated = FALSE
	var/cooldowntime = 5 SECONDS
	var/teleporting = FALSE


/obj/item/clothing/suit/space/chronos/proc/new_camera(mob/user)
	if(camera)
		qdel(camera)
	camera = new /obj/effect/chronos_cam(get_turf(user))
	camera.holder = user
	user.remote_control = camera

/obj/item/clothing/suit/space/chronos/ui_action_click()
	if((cooldown <= world.time) && !teleporting && !activating)
		if(!activated)
			activate()
		else
			deactivate()

/obj/item/clothing/suit/space/chronos/dropped()
	if(activated)
		deactivate()
	..()

/obj/item/clothing/suit/space/chronos/Destroy()
	dropped()
	return ..()

/obj/item/clothing/suit/space/chronos/emp_act(severity)
	var/mob/living/carbon/human/user = loc
	switch(severity)
		if(1)
			if(user && ishuman(user) && (user.wear_suit == src))
				to_chat(user, "<span class='userdanger'>Elecrtromagnetic pulse detected, shutting down systems to preserve integrity...</span>")
			deactivate()

/obj/item/clothing/suit/space/chronos/proc/chronowalk(mob/living/carbon/human/user)
	if(!teleporting && user && (user.stat == CONSCIOUS))
		teleporting = TRUE
		var/turf/from_turf = get_turf(user)
		if(!from_turf) //sanity, things happen
			teleporting = FALSE
			return
		var/turf/to_turf = from_turf
		var/atom/movable/overlay/phaseanim = new(from_turf)
		var/obj/holder = new(camera)
		phaseanim.name = "phasing [user.name]"
		phaseanim.icon = 'icons/mob/mob.dmi'
		phaseanim.icon_state = "chronostuck"
		phaseanim.density = TRUE
		phaseanim.layer = FLY_LAYER
		phaseanim.master = user
		user.ExtinguishMob()
		user.forceMove(holder)
		flick("chronophase", phaseanim)
		spawn(7)
			if(user)
				if(phaseanim)
					if(camera && camera.loc)
						to_turf = camera.loc
						flick("chronounphase", phaseanim)
					else
						flick("chronostuck", phaseanim)
					phaseanim.loc = to_turf
					sleep(7)
			if(holder)
				if(user && (user in holder.contents))
					user.loc = to_turf
					if(user.client)
						if(camera)
							user.client.eye = camera
						else
							user.client.eye = user
				qdel(holder)
			else if(user)
				user.loc = from_turf
			if(phaseanim)
				qdel(phaseanim)
			teleporting = FALSE
			if(user && !user.loc) //ubersanity
				user.loc = locate(0,0,1)
				user.gib()

/obj/item/clothing/suit/space/chronos/process()
	if(activated)
		var/mob/living/carbon/human/user = loc
		if(user && ishuman(user) && (user.wear_suit == src))
			if(camera && (user.remote_control == camera))
				if(!teleporting && !((camera.x == user.x) && (camera.y == user.y) && (camera.z == user.z))) //cheaper than a couple get_turf calls???
					chronowalk(user)
			else
				new_camera(user)
	else
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/suit/space/chronos/proc/activate()
	if(!activating && !activated && !teleporting)
		activating = TRUE
		var/mob/living/carbon/human/user = loc
		if(user && ishuman(user))
			if(user.wear_suit == src)
				to_chat(user, "\nChronosuitMK4 login: root")
				to_chat(user, "Password:\n")
				to_chat(user, "root@ChronosuitMK4# chronowalk4 --start\n")
				if(user.head && istype(user.head, /obj/item/clothing/head/helmet/space/chronos))
					to_chat(user, "\[ <span style='color: #00ff00;'>ok</span> \] Mounting /dev/helmet")
					helmet = user.head
					helmet.set_nodrop(TRUE, loc)
					helmet.suit = src
					set_nodrop(TRUE, loc)
					to_chat(user, "\[ <span style='color: #00ff00;'>ok</span> \] Starting brainwave scanner")
					to_chat(user, "\[ <span style='color: #00ff00;'>ok</span> \] Starting ui display driver")
					to_chat(user, "\[ <span style='color: #00ff00;'>ok</span> \] Initializing chronowalk4-view")
					new_camera(user)
					START_PROCESSING(SSobj, src)
					activated = TRUE
				else
					to_chat(user, "\[ <span style='color: #ff0000;'>fail</span> \] Mounting /dev/helmet")
					to_chat(user, "<span style='color: #ff0000;'><b>FATAL: </b>Unable to locate /dev/helmet. <b>Aborting...</b>")
		cooldown = world.time + cooldowntime
		activating = FALSE
		return 0

/obj/item/clothing/suit/space/chronos/proc/deactivate()
	if(activated)
		activating = TRUE
		var/mob/living/carbon/human/user = loc
		if(user && ishuman(user))
			if(user.wear_suit == src)
				to_chat(user, "\nroot@ChronosuitMK4# chronowalk4 --stop\n")
				if(camera)
					to_chat(user, "\[ <span style='color: #ff5500;'>ok</span> \] Sending TERM signal to chronowalk4-view")//yes I know they aren't a different color when shutting down, but they were too similar at a glance

					qdel(camera)
				if(helmet)
					to_chat(user, "\[ <span style='color: #ff5500;'>ok</span> \] Stopping ui display driver")
					to_chat(user, "\[ <span style='color: #ff5500;'>ok</span> \] Stopping brainwave scanner")
					to_chat(user, "\[ <span style='color: #ff5500;'>ok</span> \] Unmounting /dev/helmet")
					helmet.set_nodrop(FALSE, loc)
					helmet.suit = null
					helmet = null
				to_chat(user, "logout")
		set_nodrop(FALSE, loc)
		cooldown = world.time + cooldowntime * 1.5
		activated = FALSE
		activating = FALSE


/obj/effect/chronos_cam
	name = "chronosuit view"
	invisibility = 101
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/mob/holder = null

/obj/effect/chronos_cam/singularity_act()
	return

/obj/effect/chronos_cam/singularity_pull()
	return

/obj/effect/chronos_cam/relaymove(mob/user, direction)
	if(holder)
		if(user == holder)
			if(user.client && user.client.eye != src)
				loc = get_turf(user)
				user.client.eye = src
			var/step = get_step(src, direction)
			if(step)
				if(isspaceturf(step))
					if(!Move(step))
						loc = step
				else
					loc = step
	else
		qdel(src)

/obj/effect/chronos_cam/Destroy()
	if(holder)
		if(holder.remote_control == src)
			holder.remote_control = null
		if(holder.client && (holder.client.eye == src))
			holder.client.eye = holder
	return ..()
