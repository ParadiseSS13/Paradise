/mob/living/simple_animal/pet
	icon = 'icons/mob/pets.dmi'
	can_collar = 1
	mob_size = MOB_SIZE_SMALL

/mob/living/simple_animal/pet/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/weapon/newspaper))
		if(!stat)
			user.visible_message("[user] baps [name] on the nose with the rolled up [O].")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2))
					dir = i
					sleep(1)
	else
		..()

/mob/living/simple_animal/pet/revive()
	..()
	regenerate_icons()

/mob/living/simple_animal/pet/death(gibbed)
	..()
	regenerate_icons()

/mob/living/simple_animal/pet/regenerate_icons(cut_overlays = 1)
	if(cut_overlays)
		overlays.Cut()
	if(collar)
		overlays += "[icon_state]collar"
		overlays += "[icon_state]tag"