/obj/item/stamp
	name = "\improper rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-ok"
	item_state = "stamp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(MAT_METAL=60)
	item_color = "cargo"
	pressure_resistance = 2
	attack_verb = list("stamped")
	var/stamp_color = "#264715"		//used for stamp marks, based on the item sprites.. not the on paper images(those are very bland)
	var/static/list/stamp_examine_list = list(
		"stamp-qm" = "Quartermaster approved",
		"stamp-law" = "Justice Department approved",
		"stamp-cap" = "Captain approved",
		"stamp-hop" = "Head of Personnel approved",
		"stamp-hos" = "Head of Security approved",
		"stamp-ce" = "Chief Engineer approved",
		"stamp-rd" = "Research Director approved",
		"stamp-cmo" = "Chief Medical Officer approved",
		"stamp-ok" = "GRANTED",
		"stamp-deny" = "DENIED",
		"stamp-clown" = "HONK",
		"stamp-rep" = "Nanotrasen Representative approved",
		"stamp-magistrate" = "Magistrate approved",
		"stamp-cent" = "Central Command approved",
		"stamp-syndicate" = "Syndicate approved")

/obj/item/stamp/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!ishuman(target) || !ishuman(user) || !proximity)
		return

	var/mob/living/carbon/human/H = target
	var/list/paramslist = list()
	var/attackedSide				//the stamp mark will appear on this side, NORTH = forwards, SOUTH = back, EAST = right, WEST = left
	paramslist = params2list(params)
	var/xOffset = text2num(paramslist["icon-x"]) - 16
	var/yOffset = text2num(paramslist["icon-y"]) - 16

	switch(H.dir)					//This makes the attackSide be the side that currently faces the 'camera'
		if(NORTH)
			attackedSide = SOUTH
		if(SOUTH)
			attackedSide = NORTH
		if(EAST)
			attackedSide = EAST
		if(WEST)
			attackedSide = WEST

	var/icon/new_stamp_mark = icon('icons/effects/stamp_marks.dmi', "stamp[rand(1,3)]_[attackedSide]")
	new_stamp_mark.Shift(EAST, xOffset)
	new_stamp_mark.Shift(NORTH, yOffset)

	var/mutable_appearance/targetBaseIcon = mutable_appearance()			//we will use this so the stamps only appear on the human's body and not
	targetBaseIcon.dir = H.dir												//on their backpack or items they hold in their hand
	targetBaseIcon.overlays += H.overlays_standing[BODY_LAYER]
	targetBaseIcon.overlays += H.overlays_standing[LIMBS_LAYER]				//Currently this is here and not in update_icons because my only known
	targetBaseIcon.overlays += H.overlays_standing[TAIL_LAYER]
	targetBaseIcon.overlays += H.overlays_standing[UNDERWEAR_LAYER]			//method of turning an image into an icon destroys its directionality
	targetBaseIcon.overlays += H.overlays_standing[HAIR_LAYER]				//	->and it needs to be an icon for the blending step
	targetBaseIcon.overlays += H.overlays_standing[UNIFORM_LAYER]			//some species' bodies dont take up all the space their uniforms do
	new_stamp_mark.Blend(getFlatIcon(targetBaseIcon), BLEND_MULTIPLY)		//cut out any parts of the stamp mark that aren't on base human

	var/image/stamp_image = image(new_stamp_mark)
	stamp_image.text = stamp_examine_list[icon_state]
	stamp_image.color = stamp_color
	var/stamp_reference = null

	for(var/I in 1 to length(H.ink_marks))										//this code insures that there is only one image for each stamp of a given
		var/image/ink_marks_image = H.ink_marks[I]							//type, cutting down on the image count...
		if(ink_marks_image.text == stamp_image.text)
			stamp_reference = I
			break

	if(!stamp_reference)
		H.ink_marks += stamp_image											//the human hasnt been stamped with this stamp yet? add it to the list then
	else
		var/image/stamp_mark_type_image = H.ink_marks[stamp_reference]
		stamp_mark_type_image.overlays += stamp_image						//the human has been stamped with this stamp.. add new stamp mark to existing image

	H.update_misc_effects()

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead.</span>")
	return OXYLOSS

/obj/item/stamp/qm
	name = "Quartermaster's rubber stamp"
	icon_state = "stamp-qm"
	item_color = "qm"
	stamp_color = "#B88F3D"

/obj/item/stamp/law
	name = "Law office's rubber stamp"
	icon_state = "stamp-law"
	item_color = "cargo"
	stamp_color = "#CC0000"

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	item_color = "captain"
	stamp_color = "#1F66A0"

/obj/item/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	item_color = "hop"
	stamp_color = "#2A79AD"

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	item_color = "hosred"
	stamp_color = "#BA0505"

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	item_color = "chief"
	stamp_color = "#CC9900"

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	item_color = "director"
	stamp_color = "#D9D9D9"

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	item_color = "medical"
	stamp_color = "#48FEFE"

/obj/item/stamp/granted
	name = "\improper GRANTED rubber stamp"
	icon_state = "stamp-ok"
	item_color = "qm"
	stamp_color = "#339900"

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	item_color = "redcoat"
	stamp_color = "#990000"

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	item_color = "clown"
	stamp_color = "#FF66CC"

/obj/item/stamp/rep
	name = "Nanotrasen Representative's rubber stamp"
	icon_state = "stamp-rep"
	item_color = "rep"
	stamp_color = "#C1B640"

/obj/item/stamp/magistrate
	name = "Magistrate's rubber stamp"
	icon_state = "stamp-magistrate"
	item_color = "rep"
	stamp_color = "#C1B640"

/obj/item/stamp/centcom
	name = "Central Command rubber stamp"
	icon_state = "stamp-cent"
	item_color = "centcom"
	stamp_color = "#009900"

/obj/item/stamp/syndicate
	name = "suspicious rubber stamp"
	icon_state = "stamp-syndicate"
	item_color = "syndicate"
	stamp_color = "#7B0101"
