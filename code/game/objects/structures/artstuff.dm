/////////////////
// NEW DEFINES //
/////////////////

/client
	var/viewingCanvas = 0 //If this is 1, as soon as client /TRIES/ to move the view resets.

///////////
// EASEL //
///////////

/obj/structure/easel
	name = "easel"
	desc = "only for the finest of art!"
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "easel"
	density = 1
	burn_state = FLAMMABLE
	burntime = 15
	var/obj/item/weapon/canvas/painting = null


//Adding canvases
/obj/structure/easel/attackby(var/obj/item/I, var/mob/user, params)
	if(istype(I, /obj/item/weapon/canvas))
		var/obj/item/weapon/canvas/C = I
		user.unEquip(C)
		painting = C
		C.loc = get_turf(src)
		C.layer = layer+0.1
		user.visible_message("<span class='notice'>[user] puts \the [C] on \the [src].</span>","<span class='notice'>You place \the [C] on \the [src].</span>")
		return

	..()


//Stick to the easel like glue
/obj/structure/easel/Move()
	var/turf/T = get_turf(src)
	..()
	if(painting && painting.loc == T) //Only move if it's near us.
		painting.loc = get_turf(src)
	else
		painting = null


//////////////
// CANVASES //
//////////////

#define AMT_OF_CANVASES	4 //Keep this up to date or shit will break.

//To safe memory on making /icons we cache the blanks..
var/global/list/globalBlankCanvases[AMT_OF_CANVASES]

/obj/item/weapon/canvas
	name = "11px by 11px canvas"
	desc = "Draw out your soul on this canvas! Only crayons can draw on it. Examine it to focus on the canvas."
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "11x11"
	burn_state = FLAMMABLE
	var/whichGlobalBackup = 1 //List index

/obj/item/weapon/canvas/nineteenXnineteen
	name = "19px by 19px canvas"
	icon_state = "19x19"
	whichGlobalBackup = 2

/obj/item/weapon/canvas/twentythreeXnineteen
	name = "23px by 19px canvas"
	icon_state = "23x19"
	whichGlobalBackup = 3

/obj/item/weapon/canvas/twentythreeXtwentythree
	name = "23px by 23px canvas"
	icon_state = "23x23"
	whichGlobalBackup = 4


//Find the right size blank canvas
/obj/item/weapon/canvas/proc/getGlobalBackup()
	. = null
	if(globalBlankCanvases[whichGlobalBackup])
		. = globalBlankCanvases[whichGlobalBackup]
	else
		var/icon/I = icon(initial(icon),initial(icon_state))
		globalBlankCanvases[whichGlobalBackup] = I
		. = I



//One pixel increments
/obj/item/weapon/canvas/attackby(var/obj/item/I, var/mob/user, params)
	//Click info
	var/list/click_params = params2list(params)
	var/pixX = text2num(click_params["icon-x"])
	var/pixY = text2num(click_params["icon-y"])

	//Should always be true, otherwise you didn't click the object, but let's check because SS13~
	if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
		return

	var/icon/masterpiece = icon(icon,icon_state)
	//Cleaning one pixel with a soap or rag
	if(istype(I, /obj/item/weapon/soap) || istype(I, /obj/item/weapon/reagent_containers/glass/rag))
		//Pixel info created only when needed
		var/thePix = masterpiece.GetPixel(pixX,pixY)
		var/icon/Ico = getGlobalBackup()
		if(!Ico)
			qdel(masterpiece)
			return

		var/theOriginalPix = Ico.GetPixel(pixX,pixY)
		if(thePix != theOriginalPix) //colour changed
			DrawPixelOn(theOriginalPix,pixX,pixY)
		qdel(masterpiece)
		return 1

	//Drawing one pixel with a crayon
	if(istype(I, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = I
		var/pix = masterpiece.GetPixel(pixX, pixY)
		if(pix && pix != C.colour) // if the located pixel isn't blank (null))
			DrawPixelOn(C.colour, pixX, pixY)
		qdel(masterpiece)
		return 1

	..()

//Clean the whole canvas
/obj/item/weapon/canvas/attack_self(var/mob/user)
	if(!user)
		return
	var/icon/blank = getGlobalBackup()
	if(blank)
		//it's basically a giant etch-a-sketch
		icon = blank
		user.visible_message("<span class='notice'>[user] cleans the canvas.</span>","<span class='notice'>You clean the canvas.</span>")

//Examine to enlarge
/obj/item/weapon/canvas/examine(mob/user)
	..(user)
	if(in_range(user, src) && get_turf(src) && user.client && ishuman(user)) //Let only humans be the robust zoominators. I'm too spooked other mobs trying to use it may get broken huds.
		if(src.loc == user || get_turf(src) == get_turf(user))
			to_chat(user, "<span class='notice'>[src] has to be on the ground to focus on it!</span>")
			return
		to_chat(user, "<span class='notice'>You focus on \the [src].</span>")
		user.client.screen = list() //This is because screen objects go way past the view bounds we set, therefore not allowing stretch to fit to zoom in properly.
		user.client.reset_stretch = winget(user.client, "mapwindow.map", "icon-size") //Remember previous icon-size
		user.client.view = 3 //Decrease view
		winset(user.client, "mapwindow.map", "icon-size=0") //Enable stretch-to-fit
		user.client.viewingCanvas = 1 //Reset everything we just changed as soon as client tries to move
	else
		to_chat(user, "<span class='notice'>It is too far away.</span>")

#undef AMT_OF_CANVASES