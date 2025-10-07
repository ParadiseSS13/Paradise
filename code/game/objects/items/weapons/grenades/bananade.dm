
//	var/turf/T | This was made 14th September 2013, and has no use at all. Its being removed

/obj/item/grenade/bananade
	name = "bananade"
	desc = "A yellow grenade."
	icon_state = "banana"
	var/deliveryamt = 8
	var/spawner_type = /obj/item/grown/bananapeel

/obj/item/grenade/bananade/prime()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/items/bikehorn.ogg', 100, 1)
		for(var/mob/living/carbon/C in viewers(T, null))
			C.flash_eyes()
		for(var/i=1, i<=deliveryamt, i++)
			var/atom/movable/x = new spawner_type
			x.loc = T
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(x, pick(NORTH,SOUTH,EAST,WEST))

	qdel(src)
	return

/obj/item/grenade/bananade/casing
	name = "bananium casing"
	desc = "A grenade casing made of bananium."
	icon_state = "banana_casing"
	deliveryamt = 0

/obj/item/grenade/bananade/casing/attack_hand()
	return // No activating an empty grenade

/obj/item/grenade/bananade/casing/attack_self__legacy__attackchain()
	return // Stop trying to break stuff

/obj/item/grenade/bananade/casing/prime()
	return // The grenade isnt completed yet, dont even try to blow it up

/obj/item/grenade/bananade/casing/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/grown/bananapeel))
		if(deliveryamt < 9)
			to_chat(user, "<span  class='notice'>You add another banana peel to the assembly.</span>")
			deliveryamt += 1
			qdel(I)
		else
			to_chat(user, "<span class='notice'>The bananade is full, screwdriver it shut to ready it.</span>")
		return

	return ..()

/obj/item/grenade/bananade/casing/screwdriver_act(mob/living/user, obj/item/I)
	if(!deliveryamt)
		to_chat(user, "<span class='notice'>You need to add banana peels before you can ready the grenade!</span>")
		return TRUE

	var/obj/item/grenade/bananade/G = new /obj/item/grenade/bananade
	user.drop_item_to_ground(src)
	user.put_in_hands(G)
	G.deliveryamt = deliveryamt
	to_chat(user, "<span class='notice'>You lock the assembly shut, readying it for HONK.</span>")
	qdel(src)
	return TRUE
