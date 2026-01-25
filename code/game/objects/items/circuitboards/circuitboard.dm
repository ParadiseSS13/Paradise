/obj/item/circuitboard
	/// Use `board_name` instead of this.
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	inhand_icon_state = "electronic"
	origin_tech = "programming=2"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_GLASS=200)
	usesound = 'sound/items/deconstruct.ogg'
	/// Use this instead of `name`. Formats as: `circuit board ([board_name])`
	var/board_name = null
	var/build_path = null
	var/board_type = "computer"
	var/list/req_components = null

/obj/item/circuitboard/computer

/obj/item/circuitboard/machine
	board_type = "machine"

/obj/item/circuitboard/Initialize(mapload)
	. = ..()
	format_board_name()

/obj/item/circuitboard/proc/format_board_name()
	if(board_name) // Should always have this, but just in case.
		name = "[initial(name)] ([board_name])"
	else
		name = "[initial(name)]"

/obj/item/circuitboard/examine(mob/user)
	. = ..()
	if(LAZYLEN(req_components))
		var/list/nice_list = list()
		for(var/B in req_components)
			var/atom/A = B
			if(!ispath(A))
				continue
			nice_list += list("[req_components[A]] [initial(A.name)]\s")
		. += SPAN_NOTICE("Required components: [english_list(nice_list)].")
