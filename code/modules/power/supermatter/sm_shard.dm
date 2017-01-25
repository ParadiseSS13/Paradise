
/obj/item/weapon/shard/supermatter
	name = "supermatter shard"
	desc = "A shard of supermatter. Incredibly dangerous, though not large enough to go critical."
	force = 10.0
	throwforce = 20.0
	icon_state = "supermatter"
	sharp = 1
	edge = 1
	w_class = 2
	flags = CONDUCT
	light_color = "#8A8A00"
	var/brightness = 2

/obj/item/weapon/shard/supermatter/New()
	src.icon_state = "supermatter" + pick("large", "medium", "small")
	switch(src.icon_state)
		if("supermattersmall")
			src.pixel_x = rand(-12, 12)
			src.pixel_y = rand(-12, 12)
		if("supermattermedium")
			src.pixel_x = rand(-8, 8)
			src.pixel_y = rand(-8, 8)
		if("supermatterlarge")
			src.pixel_x = rand(-5, 5)
			src.pixel_y = rand(-5, 5)
		else

	set_light(brightness)

/obj/item/weapon/shard/supermatter/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if( istype( W, /obj/item/weapon/tongs ))
		var/obj/item/weapon/tongs/T = W
		T.pick_up( src )
		T.icon_state = "tongs_supermatter"
		return

	..()

/obj/item/weapon/shard/supermatter/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/shard/supermatter/Crossed(AM as mob|obj)
	if(ismob(AM))
		var/mob/M = AM
		to_chat(M, "<span class='danger'>You step on \the [src]!</span>")
		playsound(src.loc, 'sound/effects/glass_step_sm.ogg', 70, 1) // not sure how to handle metal shards with sounds
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.species.flags & IS_SYNTHETIC) //Thick skin.
				return

			if( !H.shoes && ( !H.wear_suit || !(H.wear_suit.body_parts_covered & FEET) ) )
				var/obj/item/organ/external/affecting = H.get_organ(pick("l_foot", "r_foot"))
				if(affecting.status & ORGAN_ROBOT)
					return
				if(affecting.take_damage(5, 20))
					H.UpdateDamageIcon()
				H.updatehealth()
				if(!(H.species && (H.species.flags & NO_PAIN)))
					H.Weaken(3)
	..()


/obj/item/weapon/shard/supermatter/attack_hand(var/mob/user)
	if(!istype(user,/mob/living/carbon/human/nucleation))
		to_chat(user, pick( "\red You think twice before touching that without protection.",)
					  "\red You don't want to touch that without some protection.",
					  "\red You probably should get something else to pick that up.",
					  "\red You aren't sure that's a good idea.",
					  "\red You aren't in the mood to get vaporized today.",
					  "\red You really don't feel like frying your hand off.",
					  "\red You assume that's a bad idea." )
		return

	..()

/obj/item/weapon/tongs
	name = "tongs"
	desc = "Tungsten-alloy tongs used for handling dangerous materials."
	force = 7.0
	throwforce = 12.0
	icon = 'icons/obj/weapons.dmi'
	icon_state = "tongs"
	edge = 1
	w_class = 2
	flags = CONDUCT
	var/obj/item/held = null // The item currently being held

/obj/item/weapon/tongs/proc/pick_up( var/obj/item/I )
	held = I
	I.loc = src
	playsound(loc, 'sound/effects/tong_pickup.ogg', 50, 1, -1)

/obj/item/weapon/tongs/attack_self(var/mob/user as mob)
	if( held )
		var/turf/T = get_turf(user.loc)
		held.loc = T
		held = null
		icon_state = initial(icon_state)
	..()
