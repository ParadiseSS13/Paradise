/obj/item/device/modular_computer/emp_act(severity)
	if(prob(20 / severity))
		take_damage(obj_integrity, BURN)
	..()

/obj/item/device/modular_computer/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(25))
				qdel(src)
			else if(prob(50))
				obj_integrity = 0
		if(3)
			if(prob(25))
				obj_integrity = 0

/obj/item/device/modular_computer/bullet_act(obj/item/projectile/P)
	take_damage(P.damage, P.damage_type)
	..()

/obj/item/device/modular_computer/blob_act()
	if(prob(75))
		take_damage(obj_integrity, BRUTE)

/obj/item/device/modular_computer/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	. = ..()
	var/component_probability = min(50, max(damage_amount*0.1, 1 - obj_integrity/max_integrity))
	switch(damage_flag)
		if("bullet")
			component_probability = damage_amount * 0.5
		if("laser")
			component_probability = damage_amount * 0.66
	if(component_probability)
		for(var/I in all_components)
			var/obj/item/weapon/computer_hardware/H = all_components[I]
			if(prob(component_probability))
				H.take_damage(round(damage_amount*0.5))

/obj/item/device/modular_computer/proc/break_apart(damage = TRUE)
	physical.visible_message("\The [src] breaks apart!")
	var/turf/newloc = get_turf(src)
	new /obj/item/stack/sheet/metal(newloc, round(steel_sheet_cost/2))
	for(var/C in all_components)
		var/obj/item/weapon/computer_hardware/H = all_components[C]
		uninstall_component(H)
		H.forceMove(newloc)
		if(damage && prob(25))
			H.take_damage(rand(10, 30))
	relay_qdel()
	qdel(src)
