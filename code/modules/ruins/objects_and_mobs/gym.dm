/obj/structure/punching_bag
	name = "punching bag"
	desc = "A punching bag. Can you get to speed level 4???"
	icon = 'icons/goonstation/objects/fitness.dmi'
	icon_state = "punchingbag"
	anchored = TRUE
	layer = WALL_OBJ_LAYER
	var/list/hit_sounds = list('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg',\
	'sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')
	var/material_drop = /obj/item/stack/sheet/cloth
	var/material_drop_amount = 10

/obj/structure/punching_bag/attack_hand(mob/living/user, obj/item/I)
	user.changeNext_move(CLICK_CD_MELEE)
	. = FALSE
	if(.)
		return
	if(istype(I, /obj/item/wirecutters))
		return
	flick("[icon_state]2", src)
	playsound(loc, pick(hit_sounds), 25, TRUE, -1)
	user.overeatduration = max(0, user.overeatduration - 1)

/obj/structure/punching_bag/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	WIRECUTTER_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src,user, 5 SECONDS, volume = I.tool_volume))
		WIRECUTTER_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(TRUE)

/obj/structure/punching_bag/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(flags & NODECONSTRUCT))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/weightmachine
	name = "weight machine"
	desc = "Just looking at this thing makes you feel tired."
	density = TRUE
	anchored = TRUE
	var/icon_state_inuse
	var/material_drop = /obj/item/stack/sheet/metal
	var/material_drop_amount = 5

/obj/structure/weightmachine/proc/AnimateMachine(mob/living/user)
	return

/obj/structure/weightmachine/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(in_use)
		to_chat(user, "It's already in use - wait a bit.")
		return
	else
		in_use = TRUE
		icon_state = icon_state_inuse
		user.setDir(SOUTH)
		user.Stun(8 SECONDS)
		user.forceMove(src.loc)
		var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
		user.visible_message("<B>[user] is [bragmessage]!</B>")
		AnimateMachine(user)

		playsound(user, 'sound/machines/click.ogg', 60, 1)
		in_use = FALSE
		user.pixel_y = 0
		var/finishmessage = pick("You feel stronger!","You feel like you can take on the world!","You feel robust!","You feel indestructible!")
		icon_state = initial(icon_state)
		to_chat(user, finishmessage)
		user.overeatduration = max(0, user.overeatduration - 6)

/obj/structure/weightmachine/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(in_use)
		to_chat(user, "<span class='warning'>It's currently in use - wait a bit.</span>")
		return
	else
		WELDER_ATTEMPT_SLICING_MESSAGE
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			WELDER_SLICING_SUCCESS_MESSAGE
			deconstruct(TRUE)
			return

/obj/structure/weightmachine/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(flags & NODECONSTRUCT))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/weightmachine/stacklifter
	name = "chest press"
	icon = 'icons/goonstation/objects/fitness.dmi'
	icon_state = "fitnesslifter"
	icon_state_inuse = "fitnesslifter2"

/obj/structure/weightmachine/stacklifter/AnimateMachine(mob/living/user)
	var/lifts = 0
	while(lifts++ < 6)
		if(user.loc != src.loc)
			break
		sleep(3)
		animate(user, pixel_y = -2, time = 3)
		sleep(3)
		animate(user, pixel_y = -4, time = 3)
		sleep(3)
		playsound(user, 'sound/goonstation/effects/spring.ogg', 60, 1)

/obj/structure/weightmachine/weightlifter
	name = "bench press"
	icon = 'icons/goonstation/objects/fitness.dmi'
	icon_state = "fitnessweight"
	icon_state_inuse = "fitnessweight-c"

/obj/structure/weightmachine/weightlifter/AnimateMachine(mob/living/user)
	var/mutable_appearance/swole_overlay = mutable_appearance(icon, "fitnessweight-w", WALL_OBJ_LAYER)
	add_overlay(swole_overlay)
	var/reps = 0
	user.pixel_y = 5
	while(reps++ < 6)
		if(user.loc != src.loc)
			break
		for(var/innerReps = max(reps, 1), innerReps > 0, innerReps--)
			sleep(3)
			animate(user, pixel_y = (user.pixel_y == 3) ? 5 : 3, time = 3)
		playsound(user, 'sound/goonstation/effects/spring.ogg', 60, 1)
	sleep(3)
	animate(user, pixel_y = 2, time = 3)
	sleep(3)
	cut_overlay(swole_overlay)
