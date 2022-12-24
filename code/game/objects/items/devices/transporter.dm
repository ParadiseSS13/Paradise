//Transporter
//This item allow regular player to change value of pixel_x and pixel_y vars for some types of objects and items

#define TRANSPORTER_RANGE 32

/obj/item/transporter
	name = "transporter"
	icon = 'icons/obj/device.dmi'
	icon_state = "transporter"
	item_state = "transporter"
	desc = "A special device, that allow user to change a position of certain objects\n\nUSE IN HAND - Change target values\nHELP - Move object to target values\nGRAB - Choose object to move using mouse\nDISARM - Move object using mouse"
	usesound = 'sound/items/ratchet.ogg'
	hitsound = "swing_hit"

	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	slot_flags = SLOT_BELT

	force = 5
	throwforce = 7
	materials = list(MAT_METAL=150, MAT_GLASS = 50)
	origin_tech = "materials=1;engineering=1"

	var/target_x = 0
	var/target_y = 0
	var/admin_ignore_type = 0 //For admin building
	var/obj/target

	var/static/list/allowed_types = list(
		/obj/machinery/firealarm,
		/obj/machinery/power/apc,
		/obj/machinery/alarm,
		/obj/machinery/status_display,
		/obj/machinery/requests_console,
		/obj/item/twohanded/required/kirbyplants,
		/obj/structure/extinguisher_cabinet,
		/obj/structure/sign,
		/obj/item/radio/intercom,
		/obj/machinery/atm,
		/obj/structure/closet/fireaxecabinet,
		/obj/machinery/photocopier,
		/obj/machinery/microscope,
		/obj/machinery/computer,
		/obj/machinery/newscaster,
		/obj/machinery/flasher,
		/obj/machinery/door_control,
		/obj/machinery/camera,
		/obj/structure/reagent_dispensers,
		/obj/machinery/disposal,
		/obj/structure/filingcabinet,
		/obj/structure/closet,
		/obj/structure/rack,
		/obj/machinery/light,
		/obj/machinery/recharger,
		/obj/item/flag,
		/obj/structure/bookcase,
		/obj/machinery/vending,
		/obj/machinery/smartfridge,
		/obj/structure/sink,
		/obj/machinery/shower,
		/obj/machinery/iv_drip,
		/obj/machinery/holosign_switch,
		/obj/machinery/light_switch,
		/obj/structure/window,
		/obj/structure/dresser,
		/obj/machinery/suit_storage_unit,
		/obj/structure/disposaloutlet,
		/obj/item/bedsheet
	)

/obj/item/transporter/attack_self(var/mob/user)
	target_x = clamp(round(input(user, "Enter the target X-axis moving between -[TRANSPORTER_RANGE] and [TRANSPORTER_RANGE]") as null|num), -TRANSPORTER_RANGE, TRANSPORTER_RANGE)
	target_y = clamp(round(input(user, "Enter the target Y-axis moving between -[TRANSPORTER_RANGE] and [TRANSPORTER_RANGE]") as null|num), -TRANSPORTER_RANGE, TRANSPORTER_RANGE)

/obj/item/transporter/afterattack(var/atom/A, var/mob/user, proximity, params)
	if(!proximity)
		return

	if(user.a_intent == INTENT_GRAB) //Choose a target
		if((is_type_in_list(A, allowed_types)) || admin_ignore_type)
			target = A
			to_chat(user, "<span class='notice'>Object Linked</span>")
			return
		else
			to_chat(user, "<span class='warning'>\The [src] can't be used on this type of object</span>")
			return

	if(user.a_intent == INTENT_HELP) //Move by values
		if((is_type_in_list(A, allowed_types)) || admin_ignore_type)
			A.pixel_x = target_x
			A.pixel_y = target_y
			A.layer = max(A.layer, ABOVE_WINDOW_LAYER)
			playsound(loc, usesound, 30, TRUE)

	var/list/click_params = params2list(params)

	if(user.a_intent == INTENT_DISARM) //Move by mouse
		if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
			return

		if(!target)
			to_chat(user, "<span class='warning'>Use grab intent to choose an object</span>")
			return

		if(abs((text2num(click_params["icon-x"]) - TRANSPORTER_RANGE/2) + ((A.x - target.x) * TRANSPORTER_RANGE)) > TRANSPORTER_RANGE || abs((text2num(click_params["icon-y"]) - TRANSPORTER_RANGE/2) + ((A.y - target.y) * TRANSPORTER_RANGE)) > TRANSPORTER_RANGE)
			to_chat(user, "<span class='warning'>Linked object is too far away</span>")
			return

		target.pixel_x = clamp((text2num(click_params["icon-x"]) - TRANSPORTER_RANGE/2) + ((A.x - target.x) * TRANSPORTER_RANGE) + A.pixel_x, -TRANSPORTER_RANGE, TRANSPORTER_RANGE)
		target.pixel_y = clamp((text2num(click_params["icon-y"]) - TRANSPORTER_RANGE/2) + ((A.y - target.y) * TRANSPORTER_RANGE) + A.pixel_y, -TRANSPORTER_RANGE, TRANSPORTER_RANGE)
		target.layer = max(A.layer, ABOVE_WINDOW_LAYER)
		playsound(loc, usesound, 30, TRUE)
		return

/obj/item/transporter/attack_obj(mob/living/target, mob/living/user, def_zone)
	if(user.a_intent == INTENT_HARM)
		return ..()
	return FALSE

#undef TRANSPORTER_RANGE
