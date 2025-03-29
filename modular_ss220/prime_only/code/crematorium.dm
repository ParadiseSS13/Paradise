/obj/structure/crematorium/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			obj_break()
		if(EXPLODE_HEAVY)
			take_damage(150)
		if(EXPLODE_LIGHT)
			take_damage(50)

