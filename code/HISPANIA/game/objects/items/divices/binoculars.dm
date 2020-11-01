/obj/item/device/binoculars
	name = "binoculars"
	desc = "A pair of binoculars, hopefully you can avoid dangers and spot people on the act with these."
	icon = 'icons/hispania/obj/bino.dmi'
	icon_state = "binoculars"
	item_state = "binoculars"
	force = 5
	w_class	= WEIGHT_CLASS_TINY
	throwforce = 5
	throw_range = 15
	throw_speed = 3
	materials = list(MAT_METAL = 750, MAT_GLASS = 400)
		//Var de zoom
	var/zoomed = FALSE //Pregunta si esta activo
	var/zoom_amt = 3 //Distancia del zoom

/obj/item/device/binoculars/mining
	name = "mining binoculars"
	desc = "To spot how many aliens are on that tendril without getting kill"
	icon_state = "binosup"
	item_state = "binosup"
	materials = list(MAT_METAL=750, MAT_GLASS=300, MAT_SILVER=50, MAT_TITANIUM=25)
	zoom_amt = 7

/obj/item/device/binoculars/security
	name = "security binoculars"
	icon_state = "binosec"
	item_state = "binosec"
	materials = list(MAT_METAL = 750, MAT_GLASS = 800)
	zoom_amt = 10

/obj/item/device/binoculars/bluespace
	name = "bluespace binoculars"
	desc = "I can see my mom from here! Hi mom!"
	icon_state = "binoblue"
	item_state = "binoblue"
	zoom_amt = 20  //MIS OJOS!
	materials = list(MAT_METAL = 950, MAT_GLASS = 900, MAT_BLUESPACE = 1000)
	origin_tech = "engineering=5;materials=6;bluespace=5"

///Funciones de Binoculares
/obj/item/device/binoculars/attack_self(mob/user)
	if(!zoomed)
		zoom(user, TRUE)
		to_chat(viewers(user), "<span class='notice'>[user] sees trought [src]</span>")
	else
		zoom(user, FALSE)
		to_chat(viewers(user), "<span class='notice'>[user] stops watching through [src]</span>")

/obj/item/device/binoculars/equipped(mob/user)
	..()
	zoom(user, FALSE)

/obj/item/device/binoculars/dropped(mob/user)
	zoom(user,FALSE)
	..()

/obj/item/device/binoculars/proc/zoom(mob/living/user, forced_zoom)
	if(!user || !user.client)
		return
	switch(forced_zoom)
		if(FALSE)
			zoomed = FALSE
		if(TRUE)
			zoomed = TRUE
		else
			zoomed = !zoomed

	if(zoomed)
		var/_x = 0
		var/_y = 0
		switch(user.dir)
			if(NORTH)
				_y = zoom_amt
			if(EAST)
				_x = zoom_amt
			if(SOUTH)
				_y = -zoom_amt
			if(WEST)
				_x = -zoom_amt

		user.client.pixel_x = world.icon_size*_x
		user.client.pixel_y = world.icon_size*_y
	else
		user.client.pixel_x = 0
		user.client.pixel_y = 0
