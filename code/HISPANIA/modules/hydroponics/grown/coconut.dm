//These are the seeds
/obj/item/seeds/coconut
	name = "pack of coconut seeds"
	desc = "These seeds grow into coconut palms."
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "coconut-seeds"
	species = "coco"
	plantname = "Coconut Palm"
	product = /obj/item/grown/coconut
	lifespan = 55
	endurance = 35
	yield = 5
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/coconut/bombonut)
	reagents_add = list("vitamin" = 0.04, "plantmatter" = 0.1, "sugar" =0.01)


//When it grows
/obj/item/grown/coconut
	seed = /obj/item/seeds/coconut
	name = "coconut"
	desc = "A seed? A nut? A fruit?"
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "coconut-bet"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 2
	throw_range = 3
	attack_verb = list("hit", "bludgeoned", "whacked")
	var/coconut_wacked = /obj/item/reagent_containers/food/drinks/grown/coconut
	var/wacked_name = "Coconut drink"

/obj/item/grown/coconut/New()
	..()

//Attack with sharp object will make holes on it
/obj/item/grown/coconut/attackby(obj/item/W, mob/user, params)
	if(is_sharp(W))
		user.show_message("<span class='notice'>You make a [wacked_name] by cutting \the [src] and making some holes on it!</span>", 1)
		new coconut_wacked(user.loc, 1)
		qdel(src)

//Here's the drink
/obj/item/reagent_containers/food/drinks/grown/coconut
	name = "coconut drink"
	desc = "Full of juice"
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "coconut-slice"
	item_state = "coconut-slice"
	list_reagents = list("coconutwater" = 45)
	var/coconut_sliced = /obj/item/reagent_containers/food/snacks/grown/coconutsliced
	var/sliced_name = "sliced coconut"


//Attack the drink with sharp will cut it in half
/obj/item/reagent_containers/food/drinks/grown/coconut/attackby(obj/item/W, mob/user, params)
	if(is_sharp(W))
		user.show_message("<span class='notice'>You cut \the [src] in half to make [sliced_name] </span>", 1)
		var/obj/item/reagent_containers/food/snacks/grown/coconutsliced/C = new coconut_sliced(user.loc, 2)
		qdel(src)
		usr.put_in_active_hand(C)


//Here's the food
/obj/item/reagent_containers/food/snacks/grown/coconutsliced
	name = "sliced coconut"
	desc = "A coconut split in half"
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "coconut-slice"
	filling_color = "#FF4500"
	bitesize = 2

//BOMBONUT HERE//

/obj/item/seeds/coconut/bombonut
	name = "pack of bombonut seeds"
	desc = "These seeds grow bombonuts, the explosively refreshing cousing of the coconut"
	icon = 'icons/hispania/obj/hydroponics/seeds.dmi'
	icon_state = "bombonut-seeds"
	species = "bombo"
	plantname = "Bombonout Palm"
	mutatelist = list()
	product = /obj/item/reagent_containers/food/snacks/grown/bombonut
	lifespan = 35
	endurance = 35
	yield = 5
	potency = 30
	growing_icon = 'icons/hispania/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	reagents_add = list("plantmatter" = 0.1, "sorium" = 0.7)

/obj/item/reagent_containers/food/snacks/grown/bombonut
	seed = /obj/item/seeds/coconut/bombonut
	name = "bombonut"
	desc = "The explosive variety of coconuts."
	icon = 'icons/hispania/obj/hydroponics/harvest.dmi'
	icon_state = "bombonut"
	volume = 150 //big boom boom
	seed = /obj/item/seeds/coconut/bombonut

/obj/item/reagent_containers/food/snacks/grown/bombonut/attack_self(mob/living/user) //Avisamos a un admin y se guarda en log que el usuario detonara esto
	var/area/A = get_area(user)
	user.visible_message("<span class='warning'>[user] primes the [src]!</span>", "<span class='userdanger'>You prime the [src]!</span>")
	var/message = "[ADMIN_LOOKUPFLW(user)] primed a bombonut for detonation at [A] [ADMIN_COORDJMP(user)]"
	investigate_log("[key_name(user)] primed a bombonut for detonation at [A] [COORD(user)].", INVESTIGATE_BOMB)
	message_admins(message)
	log_game("[key_name(user)] primed a bombonut for detonation at [A] [COORD(user)].")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()
	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	addtimer(CALLBACK(src, .proc/prime), rand(10, 60))

/obj/item/reagent_containers/food/snacks/grown/bombonut/burn()
	prime()
	..()

/obj/item/reagent_containers/food/snacks/grown/bombonut/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.unEquip(src)

/obj/item/reagent_containers/food/snacks/grown/bombonut/ex_act(severity)
	qdel(src) //Ensuring that it's deleted by its own explosion

/obj/item/reagent_containers/food/snacks/grown/bombonut/proc/prime()
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
