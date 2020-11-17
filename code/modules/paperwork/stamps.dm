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
	/// used for on human stamp marks, each mark will be colored this before adding to image in human stamp_marks
	var/stamp_color = "#6ca151"
	/// this is defined uniquely for each subtype, used in examine.dm for when humans are stamped.
	var/stamp_description = "..."

/obj/item/stamp/afterattack(atom/target, mob/user, proximity, params)
	. = ..()
	if(!ishuman(target) || !ishuman(user) || !proximity)
		return

	var/mob/living/carbon/human/H = target
	var/attackedSide				//the stamp mark will appear on this side, NORTH = forwards, SOUTH = back, EAST = right, WEST = left
	var/list/paramslist = params2list(params)
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

	//Here the base stamp sprite is loaded, in the dmi there are 3 different types of possible marks
	//and for each type there is one state for each direction, although bizzare it going to have to be this way

	var/icon/new_stamp_mark = icon('icons/effects/stamp_marks.dmi', "stamp[rand(1,3)]_[attackedSide]")
	new_stamp_mark.Shift(EAST, xOffset)
	new_stamp_mark.Shift(NORTH, yOffset)

	//targetBaseIcon will be a picture of the human's base body underwear and uniform
	//we will use it so stamp marks cannot be put on backpack or inhand items

	var/mutable_appearance/targetBaseIcon = mutable_appearance()
	targetBaseIcon.dir = H.dir
	targetBaseIcon.overlays += H.overlays_standing[BODY_LAYER]
	targetBaseIcon.overlays += H.overlays_standing[LIMBS_LAYER]
	targetBaseIcon.overlays += H.overlays_standing[TAIL_LAYER]
	targetBaseIcon.overlays += H.overlays_standing[UNDERWEAR_LAYER]
	targetBaseIcon.overlays += H.overlays_standing[HAIR_LAYER]
	targetBaseIcon.overlays += H.overlays_standing[UNIFORM_LAYER]

	new_stamp_mark.Blend(getFlatIcon(targetBaseIcon), BLEND_MULTIPLY)		// cut out any parts of the new mark that arent on target sprite
	var/image/new_stamp_mark_image = image(new_stamp_mark)
	new_stamp_mark_image.color = stamp_color								// it needs to be an image because it's easiest way to color sprites

	H.stamp_marks.overlays += new_stamp_mark_image							// add new mark to existing image of marks

	if(!(stamp_description in H.stamp_marks_desc))							// if its a new stamp type add its desc to list of descs
		H.stamp_marks_desc += stamp_description

	H.update_misc_effects()

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stamps 'VOID' on [user.p_their()] forehead, then promptly falls over, dead.</span>")
	return OXYLOSS

/obj/item/stamp/qm
	name = "Quartermaster's rubber stamp"
	icon_state = "stamp-qm"
	item_color = "qm"
	stamp_color = "#B88F3D"
	stamp_description = "Quartermaster approved"

/obj/item/stamp/law
	name = "Law office's rubber stamp"
	icon_state = "stamp-law"
	item_color = "cargo"
	stamp_color = "#CC0000"
	stamp_description = "Justice Department approved"

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	item_color = "captain"
	stamp_color = "#1F66A0"
	stamp_description = "Captain approved"

/obj/item/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	item_color = "hop"
	stamp_color = "#2A79AD"
	stamp_description = "Head of Personnel approved"

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	item_color = "hosred"
	stamp_color = "#BA0505"
	stamp_description = "Head of Security approved"

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	item_color = "chief"
	stamp_color = "#CC9900"
	stamp_description = "Chief Engineer approved"

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	item_color = "director"
	stamp_color = "#D9D9D9"
	stamp_description = "Research Director approved"

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	item_color = "medical"
	stamp_color = "#48FEFE"
	stamp_description = "Chief Medical Officer approved"

/obj/item/stamp/granted
	name = "\improper GRANTED rubber stamp"
	icon_state = "stamp-ok"
	item_color = "qm"
	stamp_color = "#339900"
	stamp_description = "GRANTED"

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	item_color = "redcoat"
	stamp_color = "#990000"
	stamp_description = "DENIED"

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	item_color = "clown"
	stamp_color = "#FF66CC"
	stamp_description = "HONK"

/obj/item/stamp/rep
	name = "Nanotrasen Representative's rubber stamp"
	icon_state = "stamp-rep"
	item_color = "rep"
	stamp_color = "#C1B640"
	stamp_description = "Nanotrasen Representative approved"

/obj/item/stamp/magistrate
	name = "Magistrate's rubber stamp"
	icon_state = "stamp-magistrate"
	item_color = "rep"
	stamp_color = "#C1B640"
	stamp_description = "Magistrate approved"

/obj/item/stamp/centcom
	name = "Central Command rubber stamp"
	icon_state = "stamp-cent"
	item_color = "centcom"
	stamp_color = "#009900"
	stamp_description = "Central Command approved"

/obj/item/stamp/syndicate
	name = "suspicious rubber stamp"
	icon_state = "stamp-syndicate"
	item_color = "syndicate"
	stamp_color = "#7B0101"
	stamp_description = "Syndicate approved"
