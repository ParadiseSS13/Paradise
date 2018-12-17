/obj/item/stack/sheet
	name = "sheet"
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	var/perunit = MINERAL_MATERIAL_AMOUNT
	var/sheettype = null //this is used for girders in the creation of walls/false walls
	var/created_window = null		//apparently glass sheets don't share a base type for glass specifically, so each had to define these vars individually
	var/full_window = null			//moving the var declaration to here so this can be checked cleaner until someone is willing to make them share a base type properly
	usesound = 'sound/items/deconstruct.ogg'
	toolspeed = 1
	var/wall_allowed = TRUE	//determines if sheet can be used in wall construction or not.


// Since the sheetsnatcher was consolidated into weapon/storage/bag we now use
// item/attackby() properly, making this unnecessary

/*/obj/item/stack/sheet/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/storage/bag/sheetsnatcher))
		var/obj/item/storage/bag/sheetsnatcher/S = W
		if(!S.mode)
			S.add(src,user)
		else
			for(var/obj/item/stack/sheet/stack in locate(src.x,src.y,src.z))
				S.add(stack,user)
	..()*/
