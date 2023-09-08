/obj/item/gun/energy/laser/awaymission_aeg
	name = "Wireless Energy Gun"
	desc = "An energy gun that recharges wirelessly during away missions. Does not work outside the gate."
	icon = 'modular_ss220/awaymission_gun/icons/items/energy.dmi'
	lefthand_file = 'modular_ss220/awaymission_gun/icons/inhands/lefthand.dmi'
	righthand_file = 'modular_ss220/awaymission_gun/icons/inhands/righthand.dmi'
	icon_state = "laser_gate"
	item_state = "nucgun"
	force = 10
	origin_tech = "combat=5;magnets=3;powerstorage=4"
	selfcharge = TRUE // Selfcharge is enabled and disabled, and used as the away mission tracker
	can_charge = 0
	emagged = FALSE

/obj/item/gun/energy/laser/awaymission_aeg/rnd
	name = "Exploreverse Mk I"
	desc = "Первый прототип оружия с миниатюрным реактором для исследований в крайне отдаленных секторах. Данную модель невозможно подключить к зарядной станции, во избежание истощения подключенных источников питания, в связи с протоколами безопасности, опустошающие заряд при нахождении вне предназначенных мест использования устройств."

/obj/item/gun/energy/laser/awaymission_aeg/Initialize(mapload)
	. = ..()
	// Force update it incase it spawns outside an away mission and shouldnt be charged
	onTransitZ(new_z = loc.z)

/obj/item/gun/energy/laser/awaymission_aeg/onTransitZ(old_z, new_z)
	if(emagged)
		return

	if(is_away_level(new_z))
		if(ismob(loc))
			to_chat(loc, "<span class='notice'>Ваш [src.name] активируется, начиная потреблять энергию от ближайшего беспроводного источника питания.</span>")
		selfcharge = TRUE
	else
		if(selfcharge)
			if(ismob(loc))
				to_chat(loc, "<span class='danger'>Ваш [src.name] деактивируется, так как он находится вне зоны действия источника питания.</span>")
			cell.charge = 0
			selfcharge = FALSE
			update_icon()

/obj/item/gun/energy/laser/awaymission_aeg/emag_act(mob/user)
	. = ..()
	if (emagged)
		return

	user.visible_message("<span class='warning'>От [src.name] летят искры!</span>", "<span class='notice'>Вы взломали [src.name], что привело к перезаписи протоколов безопасности. Устройство может быть использовано вне ограничений.</span>")
	playsound(src.loc, 'sound/effects/sparks4.ogg', 30, 1)
	do_sparks(5, 1, src)

	emagged = TRUE
	selfcharge = TRUE
