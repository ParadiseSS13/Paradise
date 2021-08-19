/obj/item/circuitboard/gashapon
	name = "circuit board (Gashapon)"
	build_path = /obj/machinery/arcade/gashapon
	board_type = "machine"
	origin_tech = "programming=1"
	req_components = list(
							/obj/item/stock_parts/matter_bin = 1,
							/obj/item/stock_parts/manipulator = 1,
							/obj/item/stack/cable_coil = 5,
							/obj/item/stack/sheet/glass = 1)

/obj/machinery/arcade/gashapon
	name = "Gashapon"
	desc = "One of the most easy ways to win a toy, but its a little expensive."
	icon = 'icons/hispania/obj/arcade.dmi'
	icon_state = "gashapon_on"
	token_price = 100 //Blue Whales love it
	var/bonus_prize_chance = 5

/obj/machinery/arcade/gashapon/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/gashapon(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	component_parts += new /obj/item/stack/sheet/glass(null, 1)

/obj/machinery/arcade/gashapon/RefreshParts()
	var/bin_upgrades = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		bin_upgrades = B.rating
	bonus_prize_chance = bin_upgrades * 5

/obj/machinery/arcade/gashapon/win()
	if(prob(bonus_prize_chance))	//double prize mania!
		atom_say("DOUBLE PRIZE!")
		new /obj/item/toy/prizeball(get_turf(src))
	else
		atom_say("YOU ARE A WINNER!")
	new /obj/item/toy/prizeball(get_turf(src))
	playsound(loc, 'sound/arcade/win.ogg', 50, TRUE)
	addtimer(CALLBACK(src, .proc/update_icon), 10)

/obj/machinery/arcade/gashapon/start_play(mob/user)
	..()
	usr.visible_message("<span class='notice'>[user] hits the claim button from the [src].</span>")
	close_game()
	win()

/obj/machinery/arcade/gashapon/update_icon()
	if(stat & BROKEN)
		icon_state = "gashapon_broken"
	else if(panel_open)
		icon_state = "gashapon_open"
	else if(stat & NOPOWER)
		icon_state = "gashapon_off"
	else
		icon_state = "gashapon_on"
