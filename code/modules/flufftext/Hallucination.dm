/*
Ideas for the subtle effects of hallucination:

Light up oxygen/plasma indicators (done)
Cause health to look critical/dead, even when standing (done)
Characters silently watching you
Brief flashes of fire/space/bombs/c4/dangerous shit (done)
Items that are rare/traitorous/don't exist appearing in your inventory slots (done)
Strange audio (should be rare) (done)
Gunshots/explosions/opening doors/less rare audio (done)

*/

#define SCREWYHUD_NONE 0
#define SCREWYHUD_CRIT 1
#define SCREWYHUD_DEAD 2
#define SCREWYHUD_HEALTHY 3

/mob/living/carbon
	var/image/halimage
	var/image/halbody
	var/obj/halitem
	var/hal_screwyhud = SCREWYHUD_NONE
	var/handling_hal = FALSE

/mob/living/carbon/proc/handle_hallucinations()
	if(handling_hal)
		return

	//Least obvious
	var/list/minor = list("sounds"=25,"bolts_minor"=5,"whispers"=15,"message"=10,"hudscrew"=15)
	//Something's wrong here
	var/list/medium = list("fake_alert"=15,"items"=10,"items_other"=10,"dangerflash"=10,"bolts"=5,"flood"=5,"husks"=10,"battle"=15,"self_delusion"=10)
	//AAAAHg
	var/list/major = list("fake"=20,"death"=10,"xeno"=10,"singulo"=10,"borer"=10,"delusion"=20,"koolaid"=10)

	handling_hal = TRUE
	while(hallucination > 20)
		sleep(rand(200, 500) / (hallucination * 0.04))
		if(prob(20))
			continue
		var/list/current = list()
		switch(rand(100))
			if(1 to 50)
				current = minor
			if(51 to 85)
				current = medium
			if(86 to 100)
				current = major

		hallucinate(pickweight(current))
	handling_hal = FALSE


/obj/effect/hallucination
	invisibility = INVISIBILITY_OBSERVER
	var/mob/living/carbon/target = null

/obj/effect/hallucination/singularity_pull()
	return

/obj/effect/hallucination/singularity_act()
	return

/obj/effect/hallucination/proc/wake_and_restore()
	target.hal_screwyhud = SCREWYHUD_NONE
	target.SetSleeping(0)

/obj/effect/hallucination/simple
	var/image_icon = 'icons/mob/alien.dmi'
	var/image_state = "alienh_pounce"
	var/px = 0
	var/py = 0
	var/col_mod = null
	var/image/current_image = null
	var/image_layer = MOB_LAYER
	var/active = TRUE //qdelery

/obj/effect/hallucination/simple/New(loc, mob/living/carbon/T)
	..()
	target = T
	current_image = GetImage()
	if(target.client)
		target.client.images |= current_image

/obj/effect/hallucination/simple/proc/GetImage()
	var/image/I = image(image_icon, src, image_state, image_layer, dir = dir)
	I.pixel_x = px
	I.pixel_y = py
	if(col_mod)
		I.color = col_mod
	return I

/obj/effect/hallucination/simple/proc/Show(update = 1)
	if(active)
		if(target.client)
			target.client.images.Remove(current_image)
		if(update)
			current_image = GetImage()
		if(target.client)
			target.client.images |= current_image

/obj/effect/hallucination/simple/update_icon(new_state, new_icon, new_px = 0, new_py = 0)
	image_state = new_state
	if(new_icon)
		image_icon = new_icon
	else
		image_icon = initial(image_icon)
	px = new_px
	py = new_py
	Show()

/obj/effect/hallucination/simple/Move()
	..()
	Show()

/obj/effect/hallucination/simple/Destroy()
	if(target.client)
		target.client.images.Remove(current_image)
	active = FALSE
	return ..()

#define FAKE_FLOOD_EXPAND_TIME 20
#define FAKE_FLOOD_MAX_RADIUS 10

/obj/effect/hallucination/fake_flood
	//Plasma starts flooding from the nearby vent
	var/list/flood_images = list()
	var/list/turf/flood_turfs = list()
	var/image_icon = 'icons/effects/tile_effects.dmi'
	var/image_state = "plasma"
	var/radius = 0
	var/next_expand = 0

/obj/effect/hallucination/fake_flood/New(loc, mob/living/carbon/T)
	..()
	target = T
	for(var/obj/machinery/atmospherics/unary/vent_pump/U in orange(7,target))
		if(!U.welded)
			src.loc = U.loc
			break
	flood_images += image(image_icon,src,image_state,MOB_LAYER)
	flood_turfs += get_turf(src.loc)
	if(target.client)
		target.client.images |= flood_images
	next_expand = world.time + FAKE_FLOOD_EXPAND_TIME
	START_PROCESSING(SSobj, src)

/obj/effect/hallucination/fake_flood/process()
	if(!target)
		qdel(src)
	if(next_expand <= world.time)
		radius++
		if(radius > FAKE_FLOOD_MAX_RADIUS)
			qdel(src)
		Expand()
		if((get_turf(target) in flood_turfs) && !target.internal)
			target.hallucinate("fake_alert", "too_much_tox")
		next_expand = world.time + FAKE_FLOOD_EXPAND_TIME

/obj/effect/hallucination/fake_flood/proc/Expand()
	for(var/turf/FT in flood_turfs)
		for(var/dir in GLOB.cardinal)
			var/turf/T = get_step(FT, dir)
			if((T in flood_turfs) || !FT.CanAtmosPass(T))
				continue
			flood_images += image(image_icon,T,image_state,MOB_LAYER)
			flood_turfs += T
	if(target.client)
		target.client.images |= flood_images

/obj/effect/hallucination/fake_flood/Destroy()
	STOP_PROCESSING(SSobj, src)
	flood_turfs.Cut()
	if(target.client)
		target.client.images.Remove(flood_images)
	target = null
	QDEL_LIST(flood_images)
	return ..()

/obj/effect/hallucination/simple/xeno
	image_icon = 'icons/mob/alien.dmi'
	image_state = "alienh_pounce"

/obj/effect/hallucination/simple/xeno/New(loc,var/mob/living/carbon/T)
	..()
	name = "alien hunter ([rand(1, 1000)])"

/obj/effect/hallucination/simple/xeno/throw_impact(A)
	update_icon("alienh_pounce")
	if(A == target)
		target.Weaken(5)
		target.visible_message("<span class='danger'>[target] flails around wildly.</span>","<span class ='userdanger'>[name] pounces on you!</span>")

/obj/effect/hallucination/xeno_attack
	//Xeno crawls from nearby vent,jumps at you, and goes back in
	var/obj/machinery/atmospherics/unary/vent_pump/pump = null
	var/obj/effect/hallucination/simple/xeno/xeno = null

/obj/effect/hallucination/xeno_attack/New(loc, mob/living/carbon/T)
	target = T
	for(var/obj/machinery/atmospherics/unary/vent_pump/U in orange(7,target))
		if(!U.welded)
			pump = U
			break
	if(!pump)
		return
	xeno = new(pump.loc,target)
	sleep(10)
	if(!xeno)
		return
	for(var/i in 0 to 2)
		xeno.update_icon("alienh_leap",'icons/mob/alienleap.dmi',-32,-32)
		xeno.throw_at(target,7,1, spin = 0, diagonals_first = 1)
		sleep(10)
		if(!xeno)
			return
	var/xeno_name = xeno.name
	to_chat(target, "<span class='notice'>[xeno_name] begins climbing into the ventilation system...</span>")
	sleep(10)
	if(!xeno)
		return
	qdel(xeno)
	to_chat(target, "<span class='notice'>[xeno_name] scrambles into the ventilation ducts!</span>")
	qdel(src)

/obj/effect/hallucination/simple/clown
	image_icon = 'icons/mob/simple_human.dmi'
	image_state = "clown"

/obj/effect/hallucination/simple/clown/New(loc, mob/living/carbon/T, duration)
	..(loc, T)
	name = pick(GLOB.clown_names)
	sleep(duration)
	qdel(src)

/obj/effect/hallucination/simple/clown/scary
	image_state = "scary_clown"

/obj/effect/hallucination/simple/borer
	image_icon = 'icons/mob/animal.dmi'
	image_state = "brainslug"

/obj/effect/hallucination/borer
	//A borer paralyzes you and crawls in your ear
	var/obj/machinery/atmospherics/unary/vent_pump/pump = null
	var/obj/effect/hallucination/simple/borer/borer = null

/obj/effect/hallucination/borer/New(loc, mob/living/carbon/T)
	..()
	target = T
	for(var/obj/machinery/atmospherics/unary/vent_pump/U in orange(7, target))
		if(!U.welded)
			pump = U
			break
	if(pump)
		borer = new(pump.loc,target)
		for(var/i in 0 to 10)
			walk_to(borer, get_step(borer, get_cardinal_dir(borer, T)))
			if(borer.Adjacent(T))
				to_chat(T, "<span class='userdanger'>You feel a creeping, horrible sense of dread come over you, freezing your limbs and setting your heart racing.</span>")
				T.Stun(4)
				sleep(50)
				qdel(borer)
				sleep(rand(60, 90))
				to_chat(T, "<span class='changeling'><i>Primary [rand(1000,9999)] states:</i> [pick("Hello","Hi","You're my slave now!","Don't try to get rid of me...")]</span>")
				break
			sleep(4)
		if(!QDELETED(borer))
			qdel(borer)
	qdel(src)

/obj/effect/hallucination/simple/bubblegum
	name = "Bubblegum"
	image_icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	image_state = "bubblegum"
	px = -32

/obj/effect/hallucination/oh_yeah
	var/obj/effect/hallucination/simple/bubblegum/bubblegum
	var/image/fakebroken
	var/image/fakerune

/obj/effect/hallucination/oh_yeah/New(loc, mob/living/carbon/C)
	set waitfor = FALSE
	..()
	target = C
	var/turf/simulated/wall/wall
	for(var/turf/simulated/wall/W in range(7, target))
		wall = W
		break
	if(!wall)
		qdel(src)
		return

	fakebroken = image('icons/turf/floors.dmi', wall, "plating", layer = TURF_LAYER)
	var/turf/landing = get_turf(target)
	var/turf/landing_image_turf = get_step(landing, SOUTHWEST) //the icon is 3x3
	fakerune = image('icons/effects/96x96.dmi', landing_image_turf, "landing", layer = ABOVE_OPEN_TURF_LAYER)
	fakebroken.override = TRUE
	if(target.client)
		target.client.images |= fakebroken
		target.client.images |= fakerune
	target.playsound_local(wall,'sound/effects/meteorimpact.ogg', 150, 1)
	bubblegum = new(wall, target)
	addtimer(CALLBACK(src, .proc/bubble_attack, landing), 10)

/obj/effect/hallucination/oh_yeah/proc/bubble_attack(turf/landing)
	var/charged = FALSE //only get hit once
	while(get_turf(bubblegum) != landing && target && target.stat != DEAD)
		bubblegum.forceMove(get_step_towards(bubblegum, landing))
		bubblegum.setDir(get_dir(bubblegum, landing))
		target.playsound_local(get_turf(bubblegum), 'sound/effects/meteorimpact.ogg', 150, 1)
		shake_camera(target, 2, 1)
		if(bubblegum.Adjacent(target) && !charged)
			charged = TRUE
			target.Weaken(4)
			target.adjustStaminaLoss(40)
			step_away(target, bubblegum)
			shake_camera(target, 4, 3)
			target.visible_message("<span class='warning'>[target] jumps backwards, falling on the ground!</span>", "<span class='userdanger'>[bubblegum] slams into you!</span>")
		sleep(2)
	sleep(30)
	qdel(src)

/obj/effect/hallucination/oh_yeah/Destroy()
	if(target.client)
		target.client.images.Remove(fakebroken)
		target.client.images.Remove(fakerune)
	QDEL_NULL(fakebroken)
	QDEL_NULL(fakerune)
	QDEL_NULL(bubblegum)
	return ..()

/obj/effect/hallucination/singularity_scare
	//Singularity moving towards you.
	//todo Hide where it moved with fake space images
	var/obj/effect/hallucination/simple/singularity/s = null

/obj/effect/hallucination/singularity_scare/New(loc, mob/living/carbon/T)
	target = T
	var/turf/start = get_turf(T)
	var/screen_border = pick(GLOB.cardinal)
	for(var/i in 0 to 10)
		start = get_step(start, screen_border)
	s = new(start,target)
	for(var/i in 0 to 10)
		sleep(5)
		s.loc = get_step(get_turf(s), get_dir(s, target))
		s.Show()
		s.Eat()
		addtimer(CALLBACK(src, .proc/wake_and_restore), rand(50, 100))
	qdel(s)

/obj/effect/hallucination/simple/singularity
	image_icon = 'icons/effects/224x224.dmi'
	image_state = "singularity_s7"
	image_layer = 6
	px = -96
	py = -96

/obj/effect/hallucination/simple/singularity/proc/Eat(atom/OldLoc, Dir)
	var/target_dist = get_dist(src, target)
	if(target_dist <= 3) //"Eaten"
		target.hal_screwyhud = SCREWYHUD_CRIT
		target.SetSleeping(8, no_alert = TRUE)

/obj/effect/hallucination/battle

/obj/effect/hallucination/battle/New(loc, mob/living/carbon/T)
	target = T
	var/hits = rand(2,5)
	switch(rand(1,5))
		if(1) //Laser fight
			for(var/i in 0 to hits)
				target.playsound_local(null, 'sound/weapons/laser.ogg', 25, 1)
				if(prob(75))
					addtimer(CALLBACK(target, /mob/.proc/playsound_local, null, 'sound/weapons/sear.ogg', 25, 1), rand(10,20))
				else
					addtimer(CALLBACK(target, /mob/.proc/playsound_local, null, 'sound/weapons/effects/searwall.ogg', 25, 1), rand(10,20))
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 8))
			target.playsound_local(null, get_sfx("bodyfall"), 25)
		if(2) //Esword fight
			target.playsound_local(null, 'sound/weapons/saberon.ogg', 15, 1)
			for(var/i in 0 to hits)
				target.playsound_local(null, 'sound/weapons/blade1.ogg', 25, 1)
				sleep(rand(CLICK_CD_MELEE, CLICK_CD_MELEE + 8))
			target.playsound_local(null, get_sfx("bodyfall"), 25, 1)
			target.playsound_local(null, 'sound/weapons/saberoff.ogg', 15, 1)
		if(3) //Gun fight
			for(var/i in 0 to hits)
				target.playsound_local(null, get_sfx("gunshot"), 25)
				if(prob(75))
					addtimer(CALLBACK(target, /mob/.proc/playsound_local, null, 'sound/weapons/pierce.ogg', 25, 1), rand(10,20))
				else
					addtimer(CALLBACK(target, /mob/.proc/playsound_local, null, "ricochet", 25, 1), rand(10,20))
				sleep(rand(CLICK_CD_RANGE, CLICK_CD_RANGE + 8))
			target.playsound_local(null, get_sfx("bodyfall"), 25, 1)
		if(4) //Stunprod + cablecuff
			target.playsound_local(null, 'sound/weapons/Egloves.ogg', 40, 1)
			target.playsound_local(null, get_sfx("bodyfall"), 25, 1)
			sleep(20)
			target.playsound_local(null, 'sound/weapons/cablecuff.ogg', 15, 1)
		if(5) // Tick Tock
			for(var/i in 0 to hits)
				target.playsound_local(null, 'sound/items/timer.ogg', 25, 1)
				sleep(15)
	qdel(src)

/obj/effect/hallucination/items_other

/obj/effect/hallucination/items_other/New(loc, mob/living/carbon/T)
	..()
	target = T
	var/item = pick(list("esword","dual_esword","stunpaper","chainsaw","ttv","flash","armblade"))
	var/image_file
	var/image/A = null
	for(var/mob/living/carbon/human/H in view(7,target))
		if(H != target)
			var/hand = H.l_hand
			if(!hand)
				image_file = 'icons/mob/inhands/items_lefthand.dmi'
			else
				hand = H.r_hand
				if(!hand)
					image_file = 'icons/mob/inhands/items_righthand.dmi'
			if(image_file)
				switch(item)
					if("esword")
						target.playsound_local(H, 'sound/weapons/saberon.ogg',35,1)
						A = image(image_file,H,"swordred", layer=ABOVE_MOB_LAYER)
					if("dual_esword")
						target.playsound_local(H, 'sound/weapons/saberon.ogg',35,1)
						A = image(image_file,H,"dualsaberred1", layer=ABOVE_MOB_LAYER)
					if("stunpaper")
						A = image(image_file,H,"paper", layer=ABOVE_MOB_LAYER)
						A.color = rgb(255,0,0)
					if("chainsaw")
						A = image(image_file,H,"chainsaw1", layer=ABOVE_MOB_LAYER)
					if("ttv")
						A = image(image_file,H,"ttv", layer=ABOVE_MOB_LAYER)
					if("flash")
						A = image(image_file,H,"flashtool", layer=ABOVE_MOB_LAYER)
					if("armblade")
						A = image(image_file,H,"arm_blade", layer=ABOVE_MOB_LAYER)
				if(target.client)
					target.client.images |= A
					sleep(rand(150,250))
					if(item == "esword" || item == "dual_esword")
						target.playsound_local(H, 'sound/weapons/saberoff.ogg',35,1)
					target.client.images.Remove(A)
				break
	qdel(src)


/obj/effect/hallucination/delusion
	var/list/image/delusions = list()

/obj/effect/hallucination/delusion/New(loc, mob/living/carbon/T, force_kind = null, duration = 300,skip_nearby = 1, custom_icon = null, custom_icon_file = null)
	target = T
	var/image/A = null
	var/kind = force_kind ? force_kind : pick("clown", "corgi", "carp", "skeleton", "demon","zombie")
	for(var/mob/living/carbon/human/H in GLOB.living_mob_list)
		if(H == target)
			continue
		if(skip_nearby && (H in view(target)))
			continue
		switch(kind)
			if("clown")//Clown
				A = image('icons/mob/animal.dmi',H,"clown")
			if("carp")//Carp
				A = image('icons/mob/animal.dmi',H,"carp")
			if("corgi")//Corgi
				A = image('icons/mob/pets.dmi',H,"corgi")
			if("skeleton")//Skeletons
				A = image('icons/mob/human.dmi',H,"skeleton_s")
			if("zombie")//Zombies
				A = image('icons/mob/human.dmi',H,"zombie2_s")
			if("demon")//Demon
				A = image('icons/mob/mob.dmi',H,"daemon")
			if("custom")
				A = image(custom_icon_file, H, custom_icon)
		A.override = 1
		if(target.client)
			delusions |= A
			target.client.images |= A
	sleep(duration)
	qdel(src)

/obj/effect/hallucination/delusion/Destroy()
	for(var/image/I in delusions)
		if(target.client)
			target.client.images.Remove(I)
	return ..()

/obj/effect/hallucination/self_delusion
	var/image/delusion

/obj/effect/hallucination/self_delusion/New(loc, mob/living/carbon/T, force_kind = null , duration = 300, custom_icon = null, custom_icon_file = null)
	..()
	target = T
	var/image/A = null
	var/kind = force_kind ? force_kind : pick("clown","corgi","carp","skeleton","demon","zombie","robot")
	switch(kind)
		if("clown")//Clown
			A = image('icons/mob/animal.dmi',target,"clown")
		if("carp")//Carp
			A = image('icons/mob/animal.dmi',target,"carp")
		if("corgi")//Corgi
			A = image('icons/mob/pets.dmi',target,"corgi")
		if("skeleton")//Skeletons
			A = image('icons/mob/human.dmi',target,"skeleton_s")
		if("zombie")//Zombies
			A = image('icons/mob/human.dmi',target,"zombie2_s")
		if("demon")//Demon
			A = image('icons/mob/mob.dmi',target,"daemon")
		if("robot")//Cyborg
			A = image('icons/mob/robots.dmi',target,"robot")
			target.playsound_local(target,'sound/voice/liveagain.ogg', 75, 1)
		if("custom")
			A = image(custom_icon_file, target, custom_icon)
	A.override = 1
	if(target.client)
		to_chat(target, "<span class='italics'>...wabbajack...wabbajack...</span>")
		target.playsound_local(target,'sound/magic/staff_change.ogg', 50, 1, -1)
		delusion = A
		target.client.images |= A
	sleep(duration)
	qdel(src)

/obj/effect/hallucination/self_delusion/Destroy()
	if(target.client)
		target.client.images.Remove(delusion)
	return ..()

/obj/effect/hallucination/fakeattacker/New(loc, mob/living/carbon/T)
	..()
	target = T
	var/mob/living/carbon/human/clone = null
	var/clone_weapon = null

	for(var/mob/living/carbon/human/H in GLOB.living_mob_list)
		if(H.stat || H.lying)
			continue
		clone = H
		break

	if(!clone)
		return

	var/obj/effect/fake_attacker/F = new/obj/effect/fake_attacker(get_turf(target),target)
	if(clone.l_hand)
		if(!(locate(clone.l_hand) in GLOB.non_fakeattack_weapons))
			clone_weapon = clone.l_hand.name
			F.weap = clone.l_hand
	else if(clone.r_hand)
		if(!(locate(clone.r_hand) in GLOB.non_fakeattack_weapons))
			clone_weapon = clone.r_hand.name
			F.weap = clone.r_hand

	F.name = clone.name
	F.my_target = target
	F.weapon_name = clone_weapon

	F.left = image(clone,dir = WEST)
	F.right = image(clone,dir = EAST)
	F.up = image(clone,dir = NORTH)
	F.down = image(clone,dir = SOUTH)

	F.updateimage()
	qdel(src)

/obj/effect/fake_attacker
	icon = null
	icon_state = null
	name = ""
	desc = ""
	density = 0
	anchored = 1
	opacity = 0
	var/mob/living/carbon/human/my_target = null
	var/weapon_name = null
	var/obj/item/weap = null
	var/image/stand_icon = null
	var/image/currentimage = null
	var/icon/base = null
	var/skin_tone
	var/mob/living/clone = null
	var/image/left
	var/image/right
	var/image/up
	var/collapse
	var/image/down

	var/health = 100

/obj/effect/fake_attacker/attackby(obj/item/P, mob/living/user, params)
	step_away(src,my_target,2)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	my_target.playsound_local(src, P.hitsound, 1)
	my_target.visible_message("<span class='danger'>[my_target] flails around wildly.</span>", \
							"<span class='danger'>[my_target] has attacked [src]!</span>")

	health -= P.force
	return

/obj/effect/fake_attacker/Crossed(mob/M, oldloc)
	if(M == my_target)
		step_away(src,my_target,2)
		if(prob(30))
			for(var/mob/O in oviewers(world.view , my_target))
				to_chat(O, "<span class='danger'>[my_target] stumbles around.</span>")

/obj/effect/fake_attacker/New(loc, mob/living/carbon/T)
	..()
	my_target = T
	addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, src), 300)
	step_away(src,my_target,2)
	INVOKE_ASYNC(src, .proc/attack_loop)

/obj/effect/fake_attacker/proc/updateimage()
//	qdel(src.currentimage)
	switch(dir)
		if(NORTH)
			qdel(src.currentimage)
			currentimage = new /image(up, src)
		if(SOUTH)
			qdel(src.currentimage)
			currentimage = new /image(down, src)
		if(EAST)
			qdel(src.currentimage)
			currentimage = new /image(right, src)
		if(WEST)
			qdel(src.currentimage)
			currentimage = new /image(left, src)
	my_target << currentimage


/obj/effect/fake_attacker/proc/attack_loop()
	while(1)
		sleep(rand(5,10))
		if(src.health < 0 || my_target.stat)
			collapse()
			continue
		if(get_dist(src,my_target) > 1)
			src.dir = get_dir(src,my_target)
			step_towards(src,my_target)
			updateimage()
		else
			if(prob(15))
				do_attack_animation(my_target, ATTACK_EFFECT_PUNCH)
				if(weapon_name)
					my_target.playsound_local(my_target, weap.hitsound, 1)
					my_target.show_message("<span class='danger'>[src.name] has attacked [my_target] with [weapon_name]!</span>", 1)
					my_target.adjustStaminaLoss(30)
					if(prob(20))
						my_target.AdjustEyeBlurry(3)
					if(prob(33))
						if(!locate(/obj/effect/overlay) in my_target.loc)
							fake_blood(my_target)
				else
					my_target.playsound_local(my_target, pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg'), 25, 1, -1)
					my_target.show_message("<span class='userdanger'>[src.name] has punched [my_target]!</span>", 1)
					my_target.adjustStaminaLoss(30)
					if(prob(33))
						if(!locate(/obj/effect/overlay) in my_target.loc)
							fake_blood(my_target)

		if(prob(15))
			step_away(src,my_target,2)

/obj/effect/fake_attacker/proc/collapse()
	collapse = 1
	updateimage()
	qdel(src)

/obj/effect/fake_attacker/proc/fake_blood(mob/target)
	var/obj/effect/overlay/O = new/obj/effect/overlay(target.loc)
	O.name = "blood"
	var/image/I = image('icons/effects/blood.dmi',O,"floor[rand(1,7)]",O.dir,1)
	target << I
	addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, O), 300)
	return

GLOBAL_LIST_INIT(non_fakeattack_weapons, list(/obj/item/gun/projectile, /obj/item/ammo_box/a357,\
	/obj/item/gun/energy/kinetic_accelerator/crossbow,\
	/obj/item/storage/box/syndicate, /obj/item/storage/box/emps,\
	/obj/item/cartridge/syndicate, /obj/item/clothing/under/chameleon,\
	/obj/item/clothing/shoes/chameleon/noslip, /obj/item/card/id/syndicate,\
	/obj/item/clothing/mask/chameleon, /obj/item/clothing/glasses/thermal,\
	/obj/item/chameleon, /obj/item/card/emag,\
	/obj/item/storage/toolbox/syndicate, /obj/item/aiModule,\
	/obj/item/radio/headset/syndicate,	/obj/item/grenade/plastic/c4,\
	/obj/item/powersink, /obj/item/storage/box/syndie_kit,\
	/obj/item/toy/syndicateballoon, /obj/item/gun/energy/laser/captain,\
	/obj/item/hand_tele, /obj/item/rcd, /obj/item/tank/jetpack,\
	/obj/item/clothing/under/rank/captain, /obj/item/aicard,\
	/obj/item/clothing/shoes/magboots, /obj/item/areaeditor/blueprints, /obj/item/disk/nuclear,\
	/obj/item/clothing/suit/space/nasavoid, /obj/item/tank))

/obj/effect/hallucination/bolts
	var/list/doors = list()

/obj/effect/hallucination/bolts/New(loc, mob/living/carbon/T, door_number = -1) //-1 for sever 1-2 for subtle
	target = T
	var/image/I = null
	var/count = 0
	for(var/obj/machinery/door/airlock/A in range(target,7))
		if(count>door_number && door_number>0)
			break
		count++
		I = image(A.icon, get_turf(A), "door_locked", layer=A.layer+0.1)
		doors += I
		if(target.client)
			target.client.images |= I
			target.playsound_local(get_turf(A), 'sound/machines/boltsdown.ogg',30,0,3)
		sleep(rand(6,12))
	sleep(100)
	for(var/image/B in doors)
		if(target.client)
			target.client.images.Remove(B)
			target.playsound_local(get_turf(B), 'sound/machines/boltsup.ogg',30,0,3)
		sleep(rand(6,12))
	qdel(src)

/obj/effect/hallucination/whispers

/obj/effect/hallucination/whispers/New(loc,var/mob/living/carbon/T)
	target = T
	var/speak_messages = list("I'm watching you...","[target.name]!","Get out!","Kchck-Chkck? Kchchck!","Did you hear that?","What did you do ?","Why?","Give me that!","Honk!","HELP!!", "EI NATH!!", "RUN!!", "Kill me!","O bidai nabora se'sma!")
	var/radio_messages = list("Xenos!","Singularity loose!","Comms down!","They are arming the nuke!","They butchered Ian!","H-help!","[pick("Cult", "Wizard", "Ling", "Ops", "Revenant", "Murderer", "Harm", "I hear flashing", "Help")] in [pick(GLOB.teleportlocs)][prob(50)?"!":"!!"]","Where's [target.name]?","Call the shuttle!","AI rogue!!")

	var/list/mob/living/carbon/people = list()
	var/list/mob/living/carbon/person = null
	for(var/mob/living/carbon/H in view(target))
		if(H == target)
			continue
		if(!person)
			person = H
		else
			if(get_dist(target,H)<get_dist(target,person))
				person = H
		people += H
	if(person) //Basic talk
		var/image/speech_overlay = image('icons/mob/talk.dmi', person, "h0", layer = ABOVE_MOB_LAYER)
		target.hear_say(message_to_multilingual(pick(speak_messages), pick(person.languages)), speaker = person)
		if(target.client)
			target.client.images |= speech_overlay
			sleep(30)
			target.client.images.Remove(speech_overlay)
	else // Radio talk
		var/list/humans = list()
		for(var/mob/living/carbon/human/H in GLOB.living_mob_list)
			humans += H
		person = pick(humans)
		target.hear_radio(message_to_multilingual(pick(radio_messages), pick(person.languages)), speaker = person, part_a = "<span class='[SSradio.frequency_span_class(PUB_FREQ)]'><b>\[[get_frequency_name(PUB_FREQ)]\]</b> <span class='name'>", part_b = "</span> <span class='message'>")
	qdel(src)

/obj/effect/hallucination/message

/obj/effect/hallucination/message/New(loc,var/mob/living/carbon/T)
	target = T
	var/chosen = pick("<span class='userdanger'>The light burns you!</span>",
		"<span class='danger'>You don't feel like yourself.</span>",
		"<span class='userdanger'>Unknown has punched [target]!</span>",
		"<span class='notice'>You hear something squeezing through the ducts...</span>",
		"<span class='notice'>You hear a distant scream.</span>",
		"<span class='notice'>You feel invincible, nothing can hurt you!</span>",
		"<span class='warning'>You feel a tiny prick!</span>",
		"<B>[target]</B> sneezes.",
		"<span class='warning'>You feel faint.</span>",
		"<span class='noticealien'>You hear a strange, alien voice in your head...</span> [pick("Hiss","Ssss")]",
		"<span class='notice'>You can see...everything!</span>")
	to_chat(target, chosen)
	qdel(src)

/mob/living/carbon/proc/hallucinate(hal_type, specific) // specific is used to specify a particular hallucination
	switch(hal_type)
		if("xeno")
			new /obj/effect/hallucination/xeno_attack(loc, src)
		if("borer")
			new /obj/effect/hallucination/borer(loc, src)
		if("singulo")
			new /obj/effect/hallucination/singularity_scare(loc, src)
		if("koolaid")
			new /obj/effect/hallucination/oh_yeah(loc, src)
		if("battle")
			new /obj/effect/hallucination/battle(loc, src)
		if("flood")
			new /obj/effect/hallucination/fake_flood(loc, src)
		if("delusion")
			new /obj/effect/hallucination/delusion(loc, src)
		if("self_delusion")
			new /obj/effect/hallucination/self_delusion(loc, src)
		if("fake")
			new /obj/effect/hallucination/fakeattacker(loc, src)
		if("bolts")
			new /obj/effect/hallucination/bolts(loc, src)
		if("bolts_minor")
			new /obj/effect/hallucination/bolts(loc,src, rand(1,2))
		if("whispers")
			new /obj/effect/hallucination/whispers(loc, src)
		if("message")
			new /obj/effect/hallucination/message(loc, src)
		if("items_other")
			new /obj/effect/hallucination/items_other(src.loc,src)
		if("sounds")
			//Strange audio
//			to_chat(src, "Strange Audio")
			switch(rand(1,18))
				if(1)
					playsound_local(null,'sound/machines/airlock_open.ogg', 15, 1)
				if(2)
					if(prob(50))
						playsound_local(null,'sound/effects/explosion1.ogg', 50, 1)
					else
						playsound_local(null, 'sound/effects/explosion2.ogg', 50, 1)
				if(3)
					playsound_local(null, 'sound/effects/explosionfar.ogg', 50, 1)
				if(4)
					playsound_local(null, pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg'), 50, 1)
				if(5)
					playsound_local(null, 'sound/weapons/ring.ogg', 35)
					for(var/i in 0 to 2)
						sleep(15)
						playsound_local(null, 'sound/weapons/ring.ogg', 35)
				if(6)
					playsound_local(null, 'sound/magic/summon_guns.ogg', 50, 1)
				if(7)
					playsound_local(null, 'sound/machines/alarm.ogg', 100, 0)
				if(8)
					playsound_local(null, 'sound/voice/bfreeze.ogg', 35, 0)
				if(9)
					//To make it more realistic, I added two gunshots (enough to kill)
					playsound_local(null, 'sound/weapons/gunshots/gunshot.ogg', 25, 1)
					var/timer_pause = rand(10,30)
					addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound_local, null, 'sound/weapons/gunshots/gunshot.ogg', 25, 1), timer_pause)
					addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound_local, null, sound(get_sfx("bodyfall"), 25), 25, 1), timer_pause+rand(5,10))
				if(10)
					playsound_local(null, 'sound/effects/pray_chaplain.ogg', 50)
				if(11)
					//Same as above, but with tasers.
					playsound_local(null, 'sound/weapons/taser.ogg', 25, 1)
					var/timer_pause = rand(10,30)
					addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound_local, null, 'sound/weapons/taser.ogg', 25, 1), timer_pause)
					addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound_local, null, sound(get_sfx("bodyfall"), 25), 25, 1), timer_pause+rand(5,10))
			//Rare audio
				if(12)
			//These sounds are (mostly) taken from Hidden: Source
					var/list/creepyasssounds = list('sound/effects/ghost.ogg', 'sound/effects/ghost2.ogg', 'sound/effects/heartbeat.ogg', 'sound/effects/screech.ogg',\
						'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg', 'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg',\
						'sound/hallucinations/growl3.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg',\
						'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg', 'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',\
						'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg', 'sound/hallucinations/wail.ogg')
					playsound_local(null, pick(creepyasssounds), 50, 1)
				if(13)
					to_chat(src, "<span class='warning'>You feel a tiny prick!</span>")
				if(14)
					to_chat(src, "<h1 class='alert'>Priority Announcement</h1>")
					to_chat(src, "<br><br><span class='alert'>The Emergency Shuttle has docked with the station. You have 3 minutes to board the Emergency Shuttle.</span><br><br>")
					playsound_local(null, 'sound/AI/shuttledock.ogg', 100)
				if(15)
					playsound_local(null, 'sound/items/welder.ogg', 15, 1)
					sleep(105)
					playsound_local(null, 'sound/items/welder2.ogg', 15, 1)
					sleep(15)
					playsound_local(null, 'sound/items/ratchet.ogg', 15, 1)
				if(16)
					playsound_local(null, 'sound/items/screwdriver.ogg', 15, 1)
					sleep(rand(10,30))
					for(var/i in 0 to rand(1,3))
						playsound_local(null, 'sound/weapons/empty.ogg', 15, 1)
						sleep(rand(10,30))
					playsound_local(null, 'sound/machines/airlockforced.ogg', 15, 1)
				if(17)
					playsound_local(null, 'sound/weapons/saberon.ogg', 35, 1)
				if(18)
					to_chat(src, "<h1 class='alert'>Biohazard Alert</h1>")
					to_chat(src, "<br><br><span class='alert'>Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.</span><br><br>")
					playsound_local(null, 'sound/AI/outbreak5.ogg')
				if(19) //Tesla loose!
					playsound_local(null, 'sound/magic/lightningbolt.ogg', 35, 1)
					for(var/i in 0 to 2)
						sleep(20)
						playsound_local(null, 'sound/magic/lightningbolt.ogg', 65+(35*(i-1)), 1)	//65%, then 100% volume.
				if(20) //AI is doomsdaying!
					to_chat(src, "<h1 class='alert'>Anomaly Alert</h1>")
					to_chat(src, "<br><br><span class='alert'>Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.</span><br><br>")
					playsound_local(null, 'sound/AI/aimalf.ogg')
		if("hudscrew")
			//Screwy HUD
			hal_screwyhud = pick(SCREWYHUD_NONE, SCREWYHUD_CRIT, SCREWYHUD_DEAD, SCREWYHUD_HEALTHY)
			sleep(rand(100,250))
			hal_screwyhud = SCREWYHUD_NONE
		if("fake_alert")
			var/alert_type = pick("not_enough_oxy","not_enough_tox","not_enough_co2","too_much_oxy","too_much_co2","too_much_tox","newlaw","nutrition","charge","weightless","fire","locked","hacked","temp","pressure")
			if(specific)
				alert_type = specific
			switch(alert_type)
				if("not_enough_oxy")
					throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy, override = TRUE)
				if("not_enough_tox")
					throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox, override = TRUE)
				if("not_enough_co2")
					throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2, override = TRUE)
				if("too_much_oxy")
					throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy, override = TRUE)
				if("too_much_co2")
					throw_alert("too_much_co2", /obj/screen/alert/too_much_co2, override = TRUE)
				if("too_much_tox")
					throw_alert("too_much_tox", /obj/screen/alert/too_much_tox, override = TRUE)
				if("nutrition")
					if(prob(50))
						throw_alert("nutrition", /obj/screen/alert/fat, override = TRUE)
					else
						throw_alert("nutrition", /obj/screen/alert/starving, override = TRUE)
				if("weightless")
					throw_alert("weightless", /obj/screen/alert/weightless, override = TRUE)
				if("fire")
					throw_alert("fire", /obj/screen/alert/fire, override = TRUE)
				if("temp")
					if(prob(50))
						throw_alert("temp", /obj/screen/alert/hot, 3, override = TRUE)
					else
						throw_alert("temp", /obj/screen/alert/cold, 3, override = TRUE)
				if("pressure")
					if(prob(50))
						throw_alert("pressure", /obj/screen/alert/highpressure, 2, override = TRUE)
					else
						throw_alert("pressure", /obj/screen/alert/lowpressure, 2, override = TRUE)
				//BEEP BOOP I AM A ROBOT
				if("newlaw")
					throw_alert("newlaw", /obj/screen/alert/newlaw, override = TRUE)
				if("locked")
					throw_alert("locked", /obj/screen/alert/locked, override = TRUE)
				if("hacked")
					throw_alert("hacked", /obj/screen/alert/hacked, override = TRUE)
				if("charge")
					throw_alert("charge",/obj/screen/alert/emptycell, override = TRUE)
			sleep(rand(100,200))
			clear_alert(alert_type, clear_override = TRUE)
		if("items")
			//Strange items
//			to_chat(src, "Traitor Items")
			if(!halitem)
				halitem = new
				var/list/slots_free = list(ui_lhand,ui_rhand)
				if(l_hand)
					slots_free -= ui_lhand
				if(r_hand)
					slots_free -= ui_rhand
				if(istype(src,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					if(!H.belt)
						slots_free += ui_belt
					if(!H.l_store)
						slots_free += ui_storage1
					if(!H.r_store)
						slots_free += ui_storage2
				if(slots_free.len)
					halitem.screen_loc = pick(slots_free)
					halitem.layer = 50
					halitem.plane = HUD_PLANE
					switch(rand(1,6))
						if(1) //revolver
							halitem.icon = 'icons/obj/guns/projectile.dmi'
							halitem.icon_state = "revolver"
							halitem.name = "Revolver"
						if(2) //c4
							halitem.icon = 'icons/obj/assemblies.dmi'
							halitem.icon_state = "plastic-explosive0"
							halitem.name = "Mysterious Package"
							if(prob(25))
								halitem.icon_state = "c4small_1"
						if(3) //sword
							halitem.icon = 'icons/obj/items.dmi'
							halitem.icon_state = "sword1"
							halitem.name = "Sword"
						if(4) //stun baton
							halitem.icon = 'icons/obj/items.dmi'
							halitem.icon_state = "stunbaton"
							halitem.name = "Stun Baton"
						if(5) //emag
							halitem.icon = 'icons/obj/card.dmi'
							halitem.icon_state = "emag"
							halitem.name = "Cryptographic Sequencer"
						if(6) //flashbang
							halitem.icon = 'icons/obj/grenade.dmi'
							halitem.icon_state = "flashbang1"
							halitem.name = "Flashbang"
					if(client) client.screen += halitem
					addtimer(CALLBACK(GLOBAL_PROC, .proc/qdel, halitem), rand(100,250))
		if("dangerflash")
			//Flashes of danger
			if(!halimage)
				var/list/possible_points = list()
				for(var/turf/simulated/floor/F in view(src,world.view))
					possible_points += F
				if(possible_points.len)
					var/turf/simulated/floor/target = pick(possible_points)

					switch(rand(1,4))
						if(1)
							halimage = image('icons/turf/space.dmi',target,"[rand(1,25)]",TURF_LAYER)
						if(2)
							halimage = image('icons/turf/floors/lava.dmi',target,"smooth",TURF_LAYER)
						if(3)
							halimage = image('icons/turf/floors/Chasms.dmi',target,"smooth",TURF_LAYER)
						if(4)
							halimage = image('icons/obj/assemblies.dmi',target,"plastic-explosive2",OBJ_LAYER+0.01)

					if(client)
						client.images += halimage
					sleep(rand(40,60)) //Only seen for a brief moment.
					if(client)
						client.images -= halimage
					halimage = null
		if("death")
			hal_screwyhud = SCREWYHUD_DEAD
			SetSleeping(20, no_alert = TRUE)
			if(prob(50))
				var/list/dead_people = list()
				for(var/mob/dead/observer/G in GLOB.player_list)
					dead_people += G
				var/mob/dead/observer/fakemob = pick(dead_people)
				if(fakemob)
					sleep(rand(30, 60))
					to_chat(src, "<span class='deadsay'><span class='name'>[fakemob.name]</span>(FOLLOW) [pick("complains", "moans", "whines", "laments", "blubbers", "salts")], <span class='message'>\"[pick("rip","welcome [name]","you too?","is the AI malf?",\
					 "i[prob(50)?" fucking":""] hate [pick("blood cult", "clock cult", "revenants", "abductors","double agents","viruses","badmins","you")]")]\"</span></span>")
			sleep(rand(50,70))
			hal_screwyhud = SCREWYHUD_NONE
			SetSleeping(0)
		if("husks")
			if(!halbody)
				var/list/possible_points = list()
				for(var/turf/simulated/floor/F in view(src,world.view))
					possible_points += F
				if(possible_points.len)
					var/turf/simulated/floor/target = pick(possible_points)
					switch(rand(1,4))
						if(1)
							var/image/body = image('icons/mob/human.dmi', target, "husk_s", TURF_LAYER)
							var/matrix/M = matrix()
							M.Turn(90)
							body.transform = M
							halbody = body
						if(2,3)
							halbody = image('icons/mob/human.dmi', target, "husk_s", TURF_LAYER)
						if(4)
							halbody = image('icons/mob/alien.dmi', target, "alienother", TURF_LAYER)

					if(client)
						client.images += halbody
					spawn(rand(30,50)) //Only seen for a brief moment.
						if(client)
							client.images -= halbody
						halbody = null
