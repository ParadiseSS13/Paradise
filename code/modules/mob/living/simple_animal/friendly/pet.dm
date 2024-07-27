/mob/living/simple_animal/pet
	icon = 'icons/mob/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	blood_volume = BLOOD_VOLUME_NORMAL
	can_collar = TRUE
	speed = 0 // same speed as a person.
	hud_type = /datum/hud/corgi

/mob/living/simple_animal/pet/attackby(obj/item/O, mob/user, params)
	if(!istype(O, /obj/item/newspaper))
		return ..()
	var/obj/item/newspaper/paper = O
	if(stat != CONSCIOUS || !paper.rolled)
		return
	user.visible_message("<span class='notice'>[user] baps [name] on the nose with the rolled up [O].</span>")
	INVOKE_ASYNC(src, PROC_REF(spin), 7 DECISECONDS, 1)
