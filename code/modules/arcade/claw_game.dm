GLOBAL_VAR(claw_game_html)

/obj/machinery/economy/arcade/claw
	name = "Claw Game"
	desc = "One of the most infuriating ways to win a toy."
	token_price = 5
	window_name = "Claw Game"
	var/machine_image = "_1"
	/// Chance to dispense a SECOND prize if you win, increased by matter bin rating
	var/bonus_prize_chance = 5

/obj/machinery/economy/arcade/claw/Initialize(mapload)
	. = ..()
	machine_image = pick("_1", "_2")
	update_icon(UPDATE_ICON_STATE)

	component_parts = list()
	component_parts += new /obj/item/circuitboard/clawgame(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil(null, 5)
	component_parts += new /obj/item/stack/sheet/glass(null, 1)
	RefreshParts()

	if(!GLOB.claw_game_html)
		GLOB.claw_game_html = file2text('code/modules/arcade/crane.html')

/obj/machinery/economy/arcade/claw/RefreshParts()
	var/bin_upgrades = 0
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		bin_upgrades = B.rating
	bonus_prize_chance = bin_upgrades * 5	//equals +5% chance per matter bin rating level (+20% with rating 4)

/obj/machinery/economy/arcade/claw/update_icon_state()
	if(stat & BROKEN)
		icon_state = "clawmachine[machine_image]_broken"
	else if(panel_open)
		icon_state = "clawmachine[machine_image]_open"
	else if(stat & NOPOWER)
		icon_state = "clawmachine[machine_image]_off"
	else
		icon_state = "clawmachine[machine_image]_on"

/obj/machinery/economy/arcade/claw/win()
	icon_state = "clawmachine[machine_image]_win"
	if(prob(bonus_prize_chance))	//double prize mania!
		atom_say("DOUBLE PRIZE!")
		new /obj/item/toy/prizeball(get_turf(src))
	else
		atom_say("WINNER!")
	new /obj/item/toy/prizeball(get_turf(src))
	playsound(loc, 'sound/arcade/win.ogg', 50, TRUE)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_ICON_STATE), 10)

/obj/machinery/economy/arcade/claw/start_play(mob/user as mob)
	..()
	var/datum/asset/claw_game_page_asset = get_asset_datum(/datum/asset/group/claw_game)
	claw_game_page_asset.send(user)

	var/my_game_html = replacetext(GLOB.claw_game_html, "/* ref src */", UID())
	var/datum/browser/popup = new(user, window_name, name, 915, 700, src)
	popup.set_content(my_game_html)
	popup.add_stylesheet("page", 'code/modules/arcade/page.css')
	popup.add_script("jquery-1.8.2.min", 'html/browser/jquery-1.8.2.min.js')
	popup.add_script("jquery-ui-1.8.24.custom.min", 'html/browser/jquery-ui-1.8.24.custom.min.js')
	popup.open()
	user.set_machine(src)

/obj/machinery/economy/arcade/claw/Topic(href, list/href_list)
	if(..())
		return
	var/prize_won = null
	prize_won = href_list["prizeWon"]
	if(!isnull(prize_won))
		close_game()
		if(prize_won == "1")
			win()

/obj/machinery/economy/arcade/claw/syndi
	desc = "No longer one of the most infuriating ways to win a toy, thanks to the hacking device granting infinite credits."
	freeplay = TRUE
