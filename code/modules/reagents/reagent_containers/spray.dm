/obj/item/reagent_containers/spray
	name = "spray bottle"
	desc = "A spray bottle, with an unscrewable top."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cleaner"
	item_state = "cleaner"
	flags = NOBLUDGEON
	container_type = OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 7
	var/spray_maxrange = 3 //what the sprayer will set spray_currentrange to in the attack_self.
	var/spray_currentrange = 3 //the range of tiles the sprayer will reach when in fixed mode.
	amount_per_transfer_from_this = 5
	volume = 250
	possible_transfer_amounts = null


/obj/item/reagent_containers/spray/afterattack(atom/A, mob/user)
	if(istype(A, /obj/item/storage) || istype(A, /obj/structure/table) || istype(A, /obj/structure/rack) || istype(A, /obj/structure/closet) \
	|| istype(A, /obj/item/reagent_containers) || istype(A, /obj/structure/sink) || istype(A, /obj/structure/janitorialcart) || istype(A, /obj/machinery/hydroponics))
		return

	if(istype(A, /obj/effect/proc_holder/spell))
		return

	if(istype(A, /obj/structure/reagent_dispensers) && get_dist(src,A) <= 1) //this block copypasted from reagent_containers/glass, for lack of a better solution
		if(!A.reagents.total_volume && A.reagents)
			to_chat(user, "<span class='notice'>[A] is empty.</span>")
			return

		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='notice'>[src] is full.</span>")
			return

		var/trans = A.reagents.trans_to(src, 50) //This is a static amount, otherwise, it'll take forever to fill.
		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the contents of [A].</span>")
		return

	if(reagents.total_volume < amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>[src] is empty!</span>")
		return

	var/contents_log = reagents.reagent_list.Join(", ")
	spray(A)

	playsound(loc, 'sound/effects/spray2.ogg', 50, 1, -6)
	user.changeNext_move(CLICK_CD_RANGE*2)
	user.newtonian_move(get_dir(A, user))

	if(reagents.reagent_list.len == 1 && reagents.has_reagent("cleaner")) // Only show space cleaner logs if it's burning people from being too hot or cold
		if(reagents.chem_temp < 300 && reagents.chem_temp > 280) // 280 is the cold threshold for slimes, 300 the hot threshold for drask
			return

	var/attack_log_type = ATKLOG_MOST
	if(reagents.has_reagent("sacid") || reagents.has_reagent("facid") || reagents.has_reagent("lube"))
		attack_log_type = ATKLOG_FEW
	msg_admin_attack("[key_name_admin(user)] used a spray bottle at [COORD(user)] - Contents: [contents_log] - Temperature: [reagents.chem_temp]K", attack_log_type)
	log_game("[key_name(user)] used a spray bottle at [COORD(user)] - Contents: [contents_log] - Temperature: [reagents.chem_temp]K")
	return


/obj/item/reagent_containers/spray/proc/spray(var/atom/A)
	var/obj/effect/decal/chempuff/D = new /obj/effect/decal/chempuff(get_turf(src))
	D.create_reagents(amount_per_transfer_from_this)
	reagents.trans_to(D, amount_per_transfer_from_this, 1/spray_currentrange)
	D.icon += mix_color_from_reagents(D.reagents.reagent_list)
	spawn(0)
		for(var/i=0, i<spray_currentrange, i++)
			step_towards(D,A)
			D.reagents.reaction(get_turf(D))
			for(var/atom/T in get_turf(D))
				D.reagents.reaction(T)
			sleep(3)
		qdel(D)


/obj/item/reagent_containers/spray/attack_self(var/mob/user)

	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	spray_currentrange = (spray_currentrange == 1 ? spray_maxrange : 1)
	to_chat(user, "<span class='notice'>You [amount_per_transfer_from_this == 10 ? "remove" : "fix"] the nozzle. You'll now use [amount_per_transfer_from_this] units per spray.</span>")

/obj/item/reagent_containers/spray/examine(mob/user)
	. = ..()
	if(get_dist(user, src) && user == loc)
		. += "[round(reagents.total_volume)] units left."

/obj/item/reagent_containers/spray/verb/empty()

	set name = "Empty Spray Bottle"
	set category = "Object"
	set src in usr
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	if(alert(usr, "Are you sure you want to empty that?", "Empty Bottle:", "Yes", "No") != "Yes")
		return
	if(isturf(usr.loc) && loc == usr)
		to_chat(usr, "<span class='notice'>You empty [src] onto the floor.</span>")
		reagents.reaction(usr.loc)
		reagents.clear_reagents()

//space cleaner
/obj/item/reagent_containers/spray/cleaner
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	list_reagents = list("cleaner" = 250)

/obj/item/reagent_containers/spray/cleaner/drone
	name = "space cleaner"
	desc = "BLAM!-brand non-foaming space cleaner!"
	volume = 50
	list_reagents = list("cleaner" = 50)

//spray tan
/obj/item/reagent_containers/spray/spraytan
	name = "spray tan"
	volume = 50
	desc = "Gyaro brand spray tan. Do not spray near eyes or other orifices."
	list_reagents = list("spraytan" = 50)

//pepperspray
/obj/item/reagent_containers/spray/pepper
	name = "pepperspray"
	desc = "Manufactured by UhangInc, used to blind and down an opponent quickly."
	icon = 'icons/obj/items.dmi'
	icon_state = "pepperspray"
	item_state = "pepperspray"
	volume = 40
	spray_maxrange = 4
	amount_per_transfer_from_this = 5
	list_reagents = list("condensedcapsaicin" = 40)

//water flower
/obj/item/reagent_containers/spray/waterflower
	name = "water flower"
	desc = "A seemingly innocent sunflower...with a twist."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "sunflower"
	item_state = "sunflower"
	amount_per_transfer_from_this = 1
	volume = 10
	list_reagents = list("water" = 10)

/obj/item/reagent_containers/spray/waterflower/attack_self(mob/user) //Don't allow changing how much the flower sprays
	return

//chemsprayer
/obj/item/reagent_containers/spray/chemsprayer
	name = "chem sprayer"
	desc = "A utility used to spray large amounts of reagents in a given area."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "chemsprayer"
	item_state = "chemsprayer"
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	spray_maxrange = 7
	spray_currentrange = 7
	amount_per_transfer_from_this = 10
	volume = 600
	origin_tech = "combat=3;materials=3;engineering=3"


/obj/item/reagent_containers/spray/chemsprayer/spray(var/atom/A)
	var/Sprays[3]
	for(var/i=1, i<=3, i++) // intialize sprays
		if(reagents.total_volume < 1) break
		var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(src))
		D.create_reagents(amount_per_transfer_from_this)
		reagents.trans_to(D, amount_per_transfer_from_this)

		D.icon += mix_color_from_reagents(D.reagents.reagent_list)

		Sprays[i] = D

	var/direction = get_dir(src, A)
	var/turf/T = get_turf(A)
	var/turf/T1 = get_step(T,turn(direction, 90))
	var/turf/T2 = get_step(T,turn(direction, -90))
	var/list/the_targets = list(T,T1,T2)

	for(var/i=1, i<=Sprays.len, i++)
		spawn()
			var/obj/effect/decal/chempuff/D = Sprays[i]
			if(!D) continue

			// Spreads the sprays a little bit
			var/turf/my_target = pick(the_targets)
			the_targets -= my_target

			for(var/j=0, j<=spray_currentrange, j++)
				step_towards(D, my_target)
				D.reagents.reaction(get_turf(D))
				for(var/atom/t in get_turf(D))
					D.reagents.reaction(t)
				sleep(2)
			qdel(D)



/obj/item/reagent_containers/spray/chemsprayer/attack_self(var/mob/user)

	amount_per_transfer_from_this = (amount_per_transfer_from_this == 10 ? 5 : 10)
	to_chat(user, "<span class='notice'>You adjust the output switch. You'll now use [amount_per_transfer_from_this] units per spray.</span>")


// Plant-B-Gone
/obj/item/reagent_containers/spray/plantbgone // -- Skie
	name = "Plant-B-Gone"
	desc = "Kills those pesky weeds!"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "plantbgone"
	item_state = "plantbgone"
	volume = 100
	list_reagents = list("glyphosate" = 100)
