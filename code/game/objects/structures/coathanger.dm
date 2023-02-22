/obj/structure/coatrack
	name = "coat rack"
	desc = "Rack that holds coats."
	icon = 'icons/obj/coatrack.dmi'
	icon_state = "coatrack0"
	density = 1
	anchored = 1
	var/obj/item/clothing/suit/coat
	var/list/allowed = list(
		/obj/item/clothing/suit/storage/labcoat,
		/obj/item/clothing/suit/storage/det_suit,
		/obj/item/clothing/suit/storage/blueshield,
		/obj/item/clothing/suit/leathercoat,
		/obj/item/clothing/suit/browntrenchcoat
	)

/obj/structure/coatrack/Initialize(mapload)
	. = ..()
	icon_state = "coatrack[rand(0, 1)]"

/obj/structure/coatrack/attack_hand(mob/living/user)
	if(coat)
		user.visible_message("[user] takes [coat] off \the [src].", "You take [coat] off the \the [src].")
		if(!user.put_in_active_hand(coat))
			coat.loc = get_turf(user)
		coat = null
		update_icon()

/obj/structure/coatrack/attackby(obj/item/W, mob/living/user, params)
	var/can_hang = FALSE
	for(var/T in allowed)
		if(istype(W,T))
			can_hang = TRUE
			continue

	if(can_hang && !coat)
		user.visible_message("[user] hangs [W] on \the [src].", "You hang [W] on the \the [src].")
		coat = W
		user.drop_item(src)
		coat.loc = src
		update_icon()
	else
		return ..()

/obj/structure/coatrack/CanPass(atom/movable/mover, turf/target, height=0)
	var/can_hang = FALSE
	for(var/T in allowed)
		if(istype(mover,T))
			can_hang = TRUE
			continue

	if(can_hang && !coat)
		visible_message("[mover] lands on \the [src].")
		coat = mover
		coat.loc = src
		update_icon()
		return 0
	else
		return ..()

/obj/structure/coatrack/update_icon()
	overlays.Cut()
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat))
		overlays += image(icon, icon_state = "coat_lab")
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat/cmo))
		overlays += image(icon, icon_state = "coat_cmo")
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat/mad))
		overlays += image(icon, icon_state = "coat_mad")
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat/genetics))
		overlays += image(icon, icon_state = "coat_gen")
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat/chemist))
		overlays += image(icon, icon_state = "coat_chem")
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat/virologist))
		overlays += image(icon, icon_state = "coat_vir")
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat/science))
		overlays += image(icon, icon_state = "coat_sci")
	if(istype(coat, /obj/item/clothing/suit/storage/labcoat/mortician))
		overlays += image(icon, icon_state = "coat_mor")
	if(istype(coat, /obj/item/clothing/suit/storage/blueshield))
		overlays += image(icon, icon_state = "coat_blue")
	if(istype(coat, /obj/item/clothing/suit/storage/det_suit))
		overlays += image(icon, icon_state = "coat_det")
	if(istype(coat, /obj/item/clothing/suit/browntrenchcoat))
		overlays += image(icon, icon_state = "coat_brtrench")
	if(istype(coat, /obj/item/clothing/suit/leathercoat))
		overlays += image(icon, icon_state = "coat_leather")

/obj/structure/coatrack/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		deconstruct(disassembled = TRUE)

/obj/structure/coatrack/wrench_act(mob/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, time = 10)

/obj/structure/coatrack/deconstruct(disassembled = FALSE)
	var/mat_drop = 2
	if(disassembled)
		mat_drop = 10
	new /obj/item/stack/sheet/wood(drop_location(), mat_drop)
	if(coat)
		coat.loc = get_turf(src)
		coat = null
	..()
