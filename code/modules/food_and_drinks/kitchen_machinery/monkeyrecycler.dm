/obj/machinery/monkey_recycler
	name = "Monkey Recycler"
	desc = "A machine used for recycling dead monkeys into monkey cubes."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	var/grinded = 0
	var/required_grind = 5
	var/cube_production = 1
	var/cycle_through = 0
	var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube_type = /obj/item/weapon/reagent_containers/food/snacks/monkeycube

/obj/machinery/monkey_recycler/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/monkey_recycler(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	RefreshParts()

/obj/machinery/monkey_recycler/RefreshParts()
	var/req_grind = 5
	var/cubes_made = 1
	for(var/obj/item/weapon/stock_parts/manipulator/B in component_parts)
		req_grind -= B.rating
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		cubes_made = M.rating
	cube_production = cubes_made
	required_grind = req_grind

/obj/machinery/monkey_recycler/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(default_deconstruction_screwdriver(user, "grinder_open", "grinder", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_unfasten_wrench(user, O))
		power_change()
		return

	default_deconstruction_crowbar(O)

	if(istype(O, /obj/item/device/multitool))
		cycle_through++
		switch(cycle_through)
			if(1)
				cube_type = /obj/item/weapon/reagent_containers/food/snacks/monkeycube/farwacube
			if(2)
				cube_type = /obj/item/weapon/reagent_containers/food/snacks/monkeycube/wolpincube
			if(3)
				cube_type = /obj/item/weapon/reagent_containers/food/snacks/monkeycube/stokcube
			if(4)
				cube_type = /obj/item/weapon/reagent_containers/food/snacks/monkeycube/neaeracube
			if(5)
				cube_type = /obj/item/weapon/reagent_containers/food/snacks/monkeycube
				cycle_through = 0
		to_chat(user, "<span class='notice'>You change the monkeycube type to [initial(cube_type.name)].</span>")

	if(src.stat != 0) //NOPOWER etc
		return
	if(istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		var/grabbed = G.affecting
		if(istype(grabbed, /mob/living/carbon/human))
			var/mob/living/carbon/human/target = grabbed
			if(issmall(target))
				if(target.stat == 0)
					to_chat(user, "<span class='warning'>The monkey is struggling far too much to put it in the recycler.</span>")
				else
					user.drop_item()
					qdel(target)
					to_chat(user, "<span class='notice'>You stuff the monkey in the machine.</span>")
					playsound(src.loc, 'sound/machines/juicer.ogg', 50, 1)
					var/offset = prob(50) ? -2 : 2
					animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking
					use_power(500)
					src.grinded++
					sleep(50)
					pixel_x = initial(pixel_x)
					to_chat(user, "<span class='notice'>The machine now has [grinded] monkey\s worth of material stored.</span>")
			else
				to_chat(user, "<span class='warning'>The machine only accepts monkeys!</span>")
		else
			to_chat(user, "<span class='warning'>The machine only accepts monkeys!</span>")
	return

/obj/machinery/monkey_recycler/attack_hand(var/mob/user as mob)
	if(src.stat != 0) //NOPOWER etc
		return
	if(grinded >= required_grind)
		to_chat(user, "<span class='notice'>The machine hisses loudly as it condenses the grinded monkey meat. After a moment, it dispenses a brand new monkey cube.</span>")
		playsound(src.loc, 'sound/machines/hiss.ogg', 50, 1)
		grinded -= required_grind
		for(var/i = 0, i < cube_production, i++) // Forgot to fix this bit the first time through
			new cube_type(src.loc)
		to_chat(user, "<span class='notice'>The machine's display flashes that it has [grinded] monkey\s worth of material left.</span>")
	else // I'm not sure if the \s macro works with a word in between; I'll play it safe
		to_chat(user, "<span class='warning'>The machine needs at least [required_grind] monkey\s worth of material to compress [cube_production] monkey\s. It only has [grinded].</span>")
	return