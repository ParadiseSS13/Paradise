// From Hispania!
//These are the seeds
/obj/item/seeds/coconut
	name = "pack of coconut seeds"
	desc = "These seeds grow into coconut palms."
	icon_state = "coconut-seeds"
	species = "coco"
	plantname = "Coconut Palm"
	product = /obj/item/food/grown/coconut
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/coconut/bombonut)
	reagents_add = list("coconutwater" = 0.2, "vitamin" = 0.04, "plantmatter" = 0.1, "sugar" = 0.01)

//When it grows
/obj/item/food/grown/coconut
	seed = /obj/item/seeds/coconut
	name = "coconut"
	desc = "A seed? A nut? A fruit?"
	icon_state = "coconut-bet"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_range = 3
	attack_verb = list("hit", "bludgeoned", "whacked")
	slice_path = /obj/item/food/sliced/coconut
	slices_num = 2

// We need the food class for the slicing mechanics but I'm sorry, you can't just eat a coconut by biting into it
/obj/item/food/grown/coconut/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(user.a_intent == INTENT_HARM && force)
		return NONE

	user.changeNext_move(CLICK_CD_MELEE)
	if(iscarbon(target))
		to_chat(user, SPAN_NOTICE("[src] is too hard to bite into!"))
		return ITEM_INTERACT_COMPLETE

	return NONE

//Here's the drink
/obj/item/food/sliced/coconut
	name = "coconut half"
	desc = "Full of juice"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "coconut-slice"
	filling_color = "#FF4500"

//BOMBONUT HERE//

/obj/item/seeds/coconut/bombonut
	name = "pack of bombonut seeds"
	desc = "These seeds grow bombonuts, the explosively refreshing cousing of the coconut"
	icon_state = "bombonut-seeds"
	species = "bombo"
	plantname = "Bombonout Palm"
	mutatelist = list()
	product = /obj/item/grown/bombonut
	lifespan = 35
	potency = 30
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("plantmatter" = 0.1, "sorium" = 0.7)

/obj/item/grown/bombonut
	seed = /obj/item/seeds/coconut/bombonut
	name = "bombonut"
	desc = "The explosive variety of coconuts."
	icon_state = "bombonut"
	seed = /obj/item/seeds/coconut/bombonut

/obj/item/grown/bombonut/activate_self(mob/living/user)
	if(..())
		return ITEM_INTERACT_COMPLETE

	var/area/A = get_area(user)
	user.visible_message(
		SPAN_WARNING("[user] primes the [src]!</span>"),
		SPAN_USERDANGER("You prime the [src]!</span>")
	)
	var/message = "[ADMIN_LOOKUPFLW(user)] primed a bombonut for detonation at [A] [ADMIN_COORDJMP(user)]"
	investigate_log("[key_name(user)] primed a bombonut for detonation at [A] [COORD(user)].", INVESTIGATE_BOMB)
	message_admins(message)
	log_game("[key_name(user)] primed a bombonut for detonation at [A] [COORD(user)].")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()
	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/grown/bombonut, prime)), rand(1 SECONDS, 6 SECONDS))
	return ITEM_INTERACT_COMPLETE


/obj/item/grown/bombonut/burn()
	prime()
	..()

/obj/item/grown/bombonut/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.drop_item_to_ground(src)

/obj/item/grown/bombonut/ex_act(severity)
	qdel(src) //Ensuring that it's deleted by its own explosion

/obj/item/grown/bombonut/proc/prime()
	switch(seed.potency) //Bombonaut are alot like IEDs, lots of flame, very little bang.
		if(0 to 30)
			update_mob()
			explosion(loc,-1,-1,2, flame_range = 1)
			qdel(src)
		if(31 to 50)
			update_mob()
			explosion(loc,-1,-1,2, flame_range = 2)
			qdel(src)
		if(51 to 70)
			update_mob()
			explosion(loc,-1,-1,2, flame_range = 3)
			qdel(src)
		if(71 to 90)
			update_mob()
			explosion(loc,-1,-1,2, flame_range = 4)
			qdel(src)
		else
			update_mob()
			explosion(loc,-1,-1,2, flame_range = 5)
			qdel(src)
