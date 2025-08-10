/obj/machinery/dish_drive
	name = "dish drive"
	desc = "A culinary marvel that uses matter-to-energy conversion to store dishes and shards. Convenient! \
	Additional features include a vacuum function to suck in nearby dishes, and an automatic transfer beam that empties its contents into nearby disposal bins every now and then. \
	Or you can just drop your plates on the floor, like civilized folk."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "synthesizer"
	idle_power_consumption = 8 //5 with default parts
	active_power_consumption = 13 //10 with default parts
	pass_flags = PASSTABLE
	var/static/list/collectable_items = list(/obj/item/trash/waffles,
		/obj/item/trash/plate,
		/obj/item/trash/tray,
		/obj/item/trash/snack_bowl,
		/obj/item/reagent_containers/drinks/drinkingglass,
		/obj/item/kitchen/utensil/fork,
		/obj/item/shard,
		/obj/item/broken_bottle)
	var/static/list/disposable_items = list(/obj/item/trash/waffles,
		/obj/item/trash/plate,
		/obj/item/trash/tray,
		/obj/item/trash/snack_bowl,
		/obj/item/shard,
		/obj/item/broken_bottle)
	var/time_since_dishes = 0
	var/suction_enabled = TRUE
	var/transmit_enabled = TRUE
	var/list/dish_drive_contents

/obj/machinery/dish_drive/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/dish_drive(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/dish_drive/examine(mob/user)
	. = ..()
	if(user.Adjacent(src))
		. += "<span class='notice'>Alt-click it to beam its waste storage contents to any nearby disposal bins.</span>"

/obj/machinery/dish_drive/attack_hand(mob/living/user)
	if(!LAZYLEN(dish_drive_contents))
		to_chat(user, "<span class='warning'>There's nothing in [src]!</span>")
		return
	var/obj/item/I = LAZYACCESS(dish_drive_contents, LAZYLEN(dish_drive_contents)) //the most recently-added item
	LAZYREMOVE(dish_drive_contents, I)
	user.put_in_hands(I)
	to_chat(user, "<span class='notice'>You take out [I] from [src].</span>")
	playsound(src, 'sound/items/pshoom.ogg', 15, TRUE)
	flick("synthesizer_beam", src)

/obj/machinery/dish_drive/screwdriver_act(mob/user, obj/item/I)
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		return TRUE

/obj/machinery/dish_drive/wrench_act(mob/user, obj/item/I)
	if(default_unfasten_wrench(user, I))
		return TRUE

/obj/machinery/dish_drive/RefreshParts()
	idle_power_consumption = initial(idle_power_consumption)
	active_power_consumption = initial(active_power_consumption)
	change_power_mode(initial(power_state))
	var/total_rating = 0
	for(var/obj/item/stock_parts/S in component_parts)
		total_rating += S.rating
	if(total_rating >= 9) //this entire power use section needs to be cleaned up :sob:
		active_power_consumption = 0
		change_power_mode(NO_POWER_USE)
	else
		change_power_mode((idle_power_consumption - total_rating) > 0 ? ACTIVE_POWER_USE : NO_POWER_USE)
		active_power_consumption = max(0, active_power_consumption - total_rating)
	var/obj/item/circuitboard/dish_drive/board = locate() in component_parts
	if(board)
		suction_enabled = board.suction
		transmit_enabled = board.transmit

/obj/machinery/dish_drive/process()
	if(time_since_dishes <= world.time && transmit_enabled)
		do_the_dishes()
	if(!suction_enabled)
		return
	for(var/obj/item/I in view(4, src))
		if(is_type_in_list(I, collectable_items) && I.loc != src && (!I.reagents || !I.reagents.total_volume))
			if(I.Adjacent(src))
				LAZYADD(dish_drive_contents, I)
				visible_message("<span class='notice'>[src] beams up [I]!</span>")
				I.forceMove(src)
				SEND_SIGNAL(src, COMSIG_ATOM_DISINFECTED)
				playsound(src, 'sound/items/pshoom.ogg', 15, TRUE)
				flick("synthesizer_beam", src)
			else
				step_towards(I, src)

/obj/machinery/dish_drive/attack_ai(mob/living/user)
	if(stat)
		return
	to_chat(user, "<span class='notice'>You send a disposal transmission signal to [src].</span>")
	do_the_dishes(TRUE)

/obj/machinery/dish_drive/AltClick(mob/living/user)
	if(user.can_use(src, !issilicon(user)))
		do_the_dishes(TRUE)

/obj/machinery/dish_drive/proc/do_the_dishes(manual)
	if(!LAZYLEN(dish_drive_contents))
		if(manual)
			visible_message("<span class='notice'>[src] is empty!</span>")
		return
	var/obj/machinery/disposal/bin = locate() in view(7, src)
	if(!bin)
		if(manual)
			visible_message("<span class='warning'>[src] buzzes. There are no disposal bins in range!</span>")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 15, TRUE)
		return
	var/disposed = 0
	for(var/obj/item/I in dish_drive_contents)
		if(is_type_in_list(I, disposable_items))
			LAZYREMOVE(dish_drive_contents, I)
			I.forceMove(bin)
			use_power(active_power_consumption)
			disposed++
	if(disposed)
		visible_message("<span class='notice'>[src] [pick("whooshes", "bwooms", "fwooms", "pshooms")] and beams [disposed] stored item\s into the nearby [bin.name].</span>")
		playsound(src, 'sound/items/pshoom.ogg', 15, TRUE)
		playsound(bin, 'sound/items/pshoom.ogg', 15, TRUE)
		Beam(bin, icon_state = "rped_upgrade", icon = 'icons/effects/effects.dmi', time = 5)
		bin.update_icon()
		flick("synthesizer_beam", src)
	else if(manual)
		to_chat(usr, "<span class='notice'>There are no disposable items to be beamed.</span>")
	time_since_dishes = world.time + 60 SECONDS
