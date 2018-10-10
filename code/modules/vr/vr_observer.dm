/obj/item/device/observer
	name = "observer"
	icon = 'icons/obj/items.dmi'
	desc = "the all seeing eye always watching."
	icon_state = "observingeye"
	item_state = "observingeye"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_EARS
	flags = NODROP
	var/on = 0
	var/obj/machinery/camera/camera
	var/canhear_range = 7

/obj/item/device/observer/equipped()
	..()
	var/mob/living/carbon/human/H = loc
	if(camera)
		camera.network = list("news")
		camera.c_tag = H.name
	else
		camera = new /obj/machinery/camera(src)
		camera.network = list("news")
		cameranet.removeCamera(camera)
		camera.c_tag = H.name

/obj/item/device/observer/examine(mob/user)
	if(..(user, 1))
		to_chat(user, "This video camera can send live feeds to the entertainment network. It's [camera ? "" : "in"]active.")

/obj/item/device/observer/hear_talk(mob/M as mob, msg)
	if(camera && on)
		if(get_dist(src, M) <= canhear_range)
			talk_into(M, msg)
		for(var/obj/machinery/computer/security/telescreen/T in machines)
			if(T.watchers[M] == camera)
				T.audible_message("<span class='game radio'><span class='name'>(Newscaster) [M]</span> says, '[msg]'", hearing_distance = 2)

/obj/item/device/observer/hear_message(mob/M as mob, msg)
	if(camera && on)
		for(var/obj/machinery/computer/security/telescreen/T in machines)
			if(T.watchers[M] == camera)
				T.audible_message("<span class='game radio'><span class='name'>(Newscaster) [M]</span> [msg]", hearing_distance = 2)