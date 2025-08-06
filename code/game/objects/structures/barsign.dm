#define BARSIGN_FRAME		0
#define BARSIGN_CIRCUIT		1
#define BARSIGN_WIRED		2
#define BARSIGN_COMPLETE	3

// All Signs are 64 by 32 pixels, they take two tiles
/obj/machinery/barsign
	name = "Bar Sign"
	desc = "A bar sign with no writing on it."
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "off"
	req_access = list(ACCESS_BAR)
	integrity_failure = 160
	idle_power_consumption = 5
	active_power_consumption = 25
	power_state = ACTIVE_POWER_USE
	armor = list(MELEE = 0, BULLET = 0, LASER = 20, ENERGY = 100, BOMB = 0, RAD = 100, FIRE = 50, ACID = 50)
	anchored = TRUE
	layer = ABOVE_WINDOW_LAYER
	var/list/barsigns = list()
	var/list/syndisigns = list()
	var/datum/barsign/current_sign
	var/datum/barsign/prev_sign
	var/build_stage = BARSIGN_COMPLETE

/obj/machinery/barsign/Initialize(mapload)
	. = ..()

	// Fill the barsigns lists
	for(var/bartype in subtypesof(/datum/barsign))
		var/datum/barsign/signinfo = new bartype
		if(signinfo.hidden)
			continue
		if(!signinfo.syndicate)
			barsigns += signinfo
		else
			syndisigns += signinfo

	set_random_sign()
	set_light(1, LIGHTING_MINIMUM_POWER)

/obj/machinery/barsign/proc/set_sign(datum/barsign/sign)
	if(!istype(sign))
		return
	current_sign = sign
	name = sign.name

	if(sign.desc)
		desc = sign.desc
	else
		desc = "It displays \"[name]\"."

	update_icon()

/obj/machinery/barsign/proc/set_random_sign()
	if(!emagged)
		set_sign(pick(barsigns))
	else
		set_sign(pick(syndisigns))

// Saves a /datum/barsign to the prev_sign variable.
/obj/machinery/barsign/proc/save_sign(datum/barsign/S)
	// Broken, blank, and EMPed screens shouldn't be saved.
	if(istype(S, /datum/barsign) && !istype(S, /datum/barsign/hiddensigns))
		prev_sign = S
		return TRUE
	return FALSE

/obj/machinery/barsign/update_icon_state()
	switch(build_stage)
		if(BARSIGN_FRAME)
			if(!istype(current_sign, /datum/barsign/hiddensigns/building/frame))
				set_sign(new /datum/barsign/hiddensigns/building/frame)
				return
		if(BARSIGN_CIRCUIT)
			if(!istype(current_sign, /datum/barsign/hiddensigns/building/circuited))
				set_sign(new /datum/barsign/hiddensigns/building/circuited)
				return
		if(BARSIGN_WIRED)
			if(!istype(current_sign, /datum/barsign/hiddensigns/building/wired))
				set_sign(new /datum/barsign/hiddensigns/building/wired)
				return
		if(BARSIGN_COMPLETE)
			if((stat & BROKEN) && !istype(current_sign, /datum/barsign/hiddensigns/signbroken))
				set_sign(new /datum/barsign/hiddensigns/signbroken)
				return
			if((stat & NOPOWER) && !(stat & BROKEN) && !istype(current_sign, /datum/barsign/hiddensigns/signoff))
				set_sign(new /datum/barsign/hiddensigns/signoff)
				return
			if((stat & EMPED) && !(stat & BROKEN|NOPOWER) && !istype(current_sign, /datum/barsign/hiddensigns/empbarsign))
				set_sign(new /datum/barsign/hiddensigns/empbarsign)
				return
	if(!current_sign)
		turn_off()
		return
	icon_state = current_sign.icon

// Allows the sign to be visible in complete darkness.
/obj/machinery/barsign/update_overlays()
	. = ..()
	underlays.Cut()

	if(!is_on() || stat & (BROKEN|NOPOWER) || !current_sign || build_stage < BARSIGN_COMPLETE)
		return

	underlays |= emissive_appearance(icon, current_sign.icon)

/obj/machinery/barsign/examine(mob/user)
	. = ..()
	switch(build_stage)
		if(BARSIGN_FRAME)
			. += "<span class='notice'>It's missing a <i>circuit board</i> and the <b>bolts</b> are exposed.</span>"
		if(BARSIGN_CIRCUIT)
			. += "<span class='notice'>The frame needs <i>wiring</i> and the circuit board could be <b>pried out</b>.</span>"
		if(BARSIGN_WIRED)
			. += "<span class='notice'>The frame lacks a <i>glass screen</i> and is filled with wires that could be <b>cut</b>.</span>"
		if(BARSIGN_COMPLETE)
			. += "<span class='notice'><b>Alt-Click</b> to toggle its power.</span>"
			if(panel_open)
				. += "<span class='notice'>It is disabled by its <i>unscrewed</i> maintenance panel that exposes an area from which the screen could be <b>pried out</b>.</span>"

/obj/machinery/barsign/proc/is_on()
	if(power_state == ACTIVE_POWER_USE)
		return TRUE
	return FALSE

/obj/machinery/barsign/proc/toggle_on_off()
	if(is_on())
		return turn_off()
	else
		return turn_on()

/obj/machinery/barsign/proc/turn_off()
	if((stat & (BROKEN|EMPED|MAINT)) || !is_on() || build_stage < BARSIGN_COMPLETE)
		return FALSE
	save_sign(current_sign)
	set_light(0)
	power_state = IDLE_POWER_USE
	set_sign(new /datum/barsign/hiddensigns/signoff)
	playsound(src, 'sound/machines/lightswitch.ogg', 10, TRUE)
	return TRUE

/obj/machinery/barsign/proc/turn_on()
	if((stat & (BROKEN|NOPOWER|MAINT)) || is_on() || build_stage < BARSIGN_COMPLETE)
		return FALSE
	if(panel_open)
		return FALSE
	set_light(1, LIGHTING_MINIMUM_POWER)
	power_state = ACTIVE_POWER_USE
	if(prev_sign)
		set_sign(prev_sign)
	else
		set_random_sign()
	playsound(src, 'sound/machines/lightswitch.ogg', 10, TRUE)
	return TRUE

/obj/machinery/barsign/attack_hand(mob/user)
	if(..())
		return
	if(stat & MAINT)
		to_chat(user, "<span class='warning'>Wait until the repairs are complete!</span>")
		return
	if((stat & (BROKEN|NOPOWER|EMPED)) || build_stage < BARSIGN_COMPLETE)
		to_chat(user, "<span class='warning'>The controls seem unresponsive.</span>")
		return
	if(panel_open)
		to_chat(user, "<span class='warning'>Close the maintenance panel first!</span>")
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	pick_sign(user)

/obj/machinery/barsign/AltClick(mob/user)
	add_fingerprint(user)
	if(toggle_on_off())
		return
	attack_hand(user)

/obj/machinery/barsign/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	switch(build_stage)
		// Inserting the electronics/circuit
		if(BARSIGN_FRAME)
			if(istype(used, /obj/item/barsign_electronics))
				var/obj/item/barsign_electronics/electronic = used
				if(electronic.destroyed)
					emagged = TRUE
				else
					emagged = FALSE
				if(electronic.restricts_access)
					req_access = list(ACCESS_BAR)
				else
					req_access = list()
				to_chat(user, "<span class='notice'>You insert the circuit!</span>")
				qdel(electronic)
				build_stage = BARSIGN_CIRCUIT
				update_icon()
				playsound(get_turf(src), used.usesound, 50, TRUE)
				add_fingerprint(user)
				return ITEM_INTERACT_COMPLETE
		// Wiring the bar sign
		if(BARSIGN_CIRCUIT)
			if(istype(used, /obj/item/stack/cable_coil))
				if(!used.use(5))
					to_chat(user, "<span class='warning'>You need a total of five cables to wire [src]!</span>")
					return ITEM_INTERACT_COMPLETE
				stat &= ~EMPED
				build_stage = BARSIGN_WIRED
				update_icon()
				playsound(get_turf(src), used.usesound, 50, TRUE)
				to_chat(user, "<span class='notice'>You wire [src]!</span>")
				power_state = IDLE_POWER_USE
				add_fingerprint(user)
				return ITEM_INTERACT_COMPLETE
		// Placing in the glass
		if(BARSIGN_WIRED)
			if(istype(used, /obj/item/stack/sheet/glass))
				if(!used.use(2))
					to_chat(user, "<span class='warning'>You need at least 2 sheets of glass for this!</span>")
					return ITEM_INTERACT_COMPLETE
				build_stage = BARSIGN_COMPLETE
				playsound(get_turf(src), used.usesound, 50, TRUE)
				obj_integrity = max_integrity
				if(stat & BROKEN)
					stat &= ~BROKEN
				set_sign(new /datum/barsign/hiddensigns/signoff)
				add_fingerprint(user)
				return ITEM_INTERACT_COMPLETE
	return ..()

/obj/machinery/barsign/proc/pick_sign(mob/user)
	var/picked_name
	if(!emagged)
		picked_name = tgui_input_list(user, "Available Signage", "Bar Sign", barsigns)
	else
		picked_name = tgui_input_list(user, "Available Signage", "Bar Sign", syndisigns)
	if(!picked_name)
		return
	turn_on()
	set_sign(picked_name)

/obj/machinery/barsign/obj_break(damage_flag)
	if(!(stat & BROKEN) && !(flags & NODECONSTRUCT))
		turn_off()
		stat |= BROKEN
		// Don't break the glass unless it actually has glass.
		if(build_stage == BARSIGN_COMPLETE)
			set_sign(new /datum/barsign/hiddensigns/signbroken)
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)

/obj/machinery/barsign/welder_act(mob/living/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>[src] does not need repairs.</span>")
		return
	if(I.tool_behaviour != TOOL_WELDER)
		return
	if(!I.tool_use_check(user, 0))
		return
	var/time = max(50 * (1 - obj_integrity / max_integrity), 5)
	WELDER_ATTEMPT_REPAIR_MESSAGE
	turn_off()
	stat |= MAINT
	if(I.use_tool(src, user, time, volume = I.tool_volume))
		WELDER_REPAIR_SUCCESS_MESSAGE
		obj_integrity = max_integrity
		stat &= ~BROKEN
		set_sign(new /datum/barsign/hiddensigns/signoff)
		add_fingerprint(user)
	stat &= ~MAINT

/obj/machinery/barsign/screwdriver_act(mob/living/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	. = TRUE
	if(I.tool_behaviour != TOOL_SCREWDRIVER)
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(!(flags & NODECONSTRUCT))
		if(!panel_open)
			panel_open = TRUE
			turn_off()
			to_chat(user, "<span class='notice'>You open the maintenance panel of [src].</span>")
		else
			panel_open = FALSE
			to_chat(user, "<span class='notice'>You close the maintenance panel of [src].</span>")
		I.play_tool_sound(user, I.tool_volume)
		add_fingerprint(user)

/obj/machinery/barsign/wrench_act(mob/living/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	if(build_stage != BARSIGN_FRAME)
		return
	. = TRUE
	if(I.tool_behaviour != TOOL_WRENCH)
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(!(flags & NODECONSTRUCT))
		WRENCH_UNANCHOR_WALL_MESSAGE
		I.play_tool_sound(user, I.tool_volume)
		deconstruct(TRUE)

/obj/machinery/barsign/crowbar_act(mob/living/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return FALSE
	if(build_stage != BARSIGN_CIRCUIT && build_stage != BARSIGN_COMPLETE)
		return FALSE
	. = TRUE
	if(I.tool_behaviour != TOOL_CROWBAR)
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(flags & NODECONSTRUCT)
		return
		// Removing the electronics
	if(build_stage == BARSIGN_CIRCUIT)
		var/obj/item/barsign_electronics/electronic
		electronic = new /obj/item/barsign_electronics
		if(!emagged)
			to_chat(user, "<span class='notice'>You pull the electronics out from [src].</span>")
		else
			// Give fried electronics if the sign is emagged
			to_chat(user, "<span class='notice'>You pull the fried electronics out from [src].</span>")
			electronic.destroyed = TRUE
			electronic.icon_state = "door_electronics_smoked"
		if(!length(req_access))
			electronic.restricts_access = FALSE
		electronic.forceMove(get_turf(user))
		build_stage = BARSIGN_FRAME
		update_icon()
		add_fingerprint(user)
	// Removing the glass screen
	else if(build_stage == BARSIGN_COMPLETE)
		if(!panel_open)
			to_chat(user, "<span class='warning'>Open the maintenance panel first!</span>")
			return
			// Drop a shard if the glass is broken
		if(stat & BROKEN)
			to_chat(user, "<span class='notice'>You remove the broken screen from [src].</span>")
			new /obj/item/shard(get_turf(user))
		else
			to_chat(user, "<span class='notice'>You pull the glass screen out from [src].</span>")
			new /obj/item/stack/sheet/glass(get_turf(user), 2)
		build_stage = BARSIGN_WIRED
		update_icon()
		add_fingerprint(user)
	I.play_tool_sound(user, I.tool_volume)

/obj/machinery/barsign/wirecutter_act(mob/living/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	if(build_stage != BARSIGN_WIRED)
		return
	. = TRUE
	if(I.tool_behaviour != TOOL_WIRECUTTER)
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(!(flags & NODECONSTRUCT))
		if(stat & EMPED)
			to_chat(user, "<span class='notice'>You remove the burnt wires out from [src].</span>")
		else
			to_chat(user, "<span class='notice'>You cut the wires out from [src].</span>")
			new /obj/item/stack/cable_coil(get_turf(user), 5)
		build_stage = BARSIGN_CIRCUIT
		update_icon()
		power_state = NO_POWER_USE
		I.play_tool_sound(user, I.tool_volume)
		add_fingerprint(user)

/obj/machinery/barsign/emag_act(mob/user)
	if(stat & (BROKEN|NOPOWER|EMPED))
		to_chat(user, "<span class='warning'>[src] cannot be taken over right now!</span>")
		return
	if(emagged)
		to_chat(user, "<span class='warning'>[src] is already taken over!</span>")
		return
	to_chat(user, "<span class='notice'>You emag the barsign. Takeover in progress...</span>")
	add_fingerprint(user)
	addtimer(CALLBACK(src, PROC_REF(post_emag)), 10 SECONDS)
	return TRUE

/obj/machinery/barsign/proc/post_emag()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return
	emagged = TRUE
	set_random_sign()
	req_access = list()

/obj/machinery/barsign/emp_act(severity)
	if(build_stage >= BARSIGN_WIRED)
		if(!(stat & EMPED))
			stat |= EMPED
			turn_on()
			set_sign(new /datum/barsign/hiddensigns/empbarsign)
			playsound(loc, 'sound/effects/sparks4.ogg', 60, TRUE)
			return ..()

/obj/machinery/barsign/power_change()
	. = ..()
	if(. && (stat & NOPOWER))
		turn_off()

/obj/machinery/barsign/deconstruct(disassembled = FALSE)
	if(disassembled)
		new /obj/item/stack/sheet/metal(drop_location(), 4)
	else
		new /obj/item/stack/sheet/metal(drop_location(), 2)
		if(build_stage >= BARSIGN_WIRED && !(stat & EMPED))
			new /obj/item/stack/cable_coil(drop_location(), 3)
		if(build_stage >= BARSIGN_COMPLETE)
			new /obj/item/shard(drop_location())
	qdel(src)


/datum/stack_recipe/barsign_frame

/datum/stack_recipe/barsign_frame/try_build(mob/user, obj/item/stack/S, multiplier)
	if(!..())
		return FALSE
	var/user_turf = get_turf(user)
	var/placing_on = get_step(user_turf, user.dir)
	// Return FALSE if the user isn't facing a wall/window.
	if(!is_valid_turf(placing_on))
		to_chat(user, "<span class='warning'>You need to be facing a wall or window to place the [title].</span>")
		return FALSE
	// Return FALSE if there isn't space for the entire sign.
	if((user.dir != NORTH && user.dir != SOUTH) || !is_valid_turf(get_step(placing_on, EAST)))
		to_chat(user, "<span class='warning'>There is not enough space to place the [title].</span>")
		return FALSE
	// Return FALSE if there's already stuff on the wall.
	if(gotwallitem(user_turf, FLIP_DIR_VERTICALLY(user.dir)) || gotwallitem(get_step(user_turf, EAST), FLIP_DIR_VERTICALLY(user.dir)))
		to_chat(user, "<span class='warning'>There's already an item on the wall!</span>")
		return FALSE
	// Return FALSE if it would cause two bar signs to overlap.
	if((locate(/obj/machinery/barsign) in get_step(user_turf, WEST)))
		to_chat(user, "<span class='warning'>There's already a bar sign here!</span>")
		return FALSE
	return TRUE

/datum/stack_recipe/barsign_frame/proc/is_valid_turf(turf/T)
	if(!istype(T))
		return FALSE
	if(iswallturf(T))
		return TRUE
	if(locate(/obj/structure/window/full) in T)
		return TRUE
	return FALSE

/datum/stack_recipe/barsign_frame/post_build(mob/user, obj/item/stack/S, obj/machinery/barsign/O)
	.= ..()
	playsound(O, 'sound/items/deconstruct.ogg', 10, TRUE)
	O.build_stage = BARSIGN_FRAME
	O.power_state = NO_POWER_USE
	O.set_light(0)
	O.update_icon()
	if(user.dir == SOUTH)
		O.pixel_y = -32
	else
		O.pixel_y = 32


/obj/item/barsign_electronics
	name = "bar sign electronics"
	desc = "A circuit. It has a small data storage component filled with various bar sign designs."
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 100, MAT_GLASS = 100)
	origin_tech = "engineering=2;programming=1"
	usesound = 'sound/items/deconstruct.ogg'
	var/destroyed = FALSE
	/// Restricts the sign to bar access if TRUE
	var/restricts_access = TRUE

/obj/item/barsign_electronics/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use it while in your active hand to toggle the access restrictions.</span>"

/obj/item/barsign_electronics/attack_self__legacy__attackchain(mob/user)
	. = ..()
	if(destroyed)
		return
	restricts_access = !restricts_access
	to_chat(user, "<span class='notice'>You [restricts_access ? "enable" : "disable"] the access restrictions of [src].</span>")

// For the ghost bar since occupants don't have bar access.
/obj/machinery/barsign/ghost_bar
	req_access = list()

/obj/machinery/barsign/ghost_bar/Initialize(mapload)
	. = ..()
	// Also give them access to syndicate signs because why not.
	barsigns |= syndisigns
	set_random_sign()


/datum/barsign
	var/name = "Name"
	var/desc = "desc"
	var/icon = "Icon"
	/// Signs that should never be accessed by players via the selection menu.
	var/hidden = FALSE
	/// Signs that have a syndicate theme. Normally accessed by emagging the sign.
	var/syndicate = FALSE

//Anything below this is where all the specific signs are. If people want to add more signs, add them below.
/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	desc = "The Maltese Falcon, Space Bar and Grill."
	icon = "maltesefalcon"

/datum/barsign/thebark
	name = "The Bark"
	desc = "Ian's bar of choice."
	icon = "thebark"

/datum/barsign/harmbaton
	name = "The Harmbaton"
	desc = "A great dining experience for both security members and assistants."
	icon = "theharmbaton"

/datum/barsign/thesingulo
	name = "The Singulo"
	desc = "Where people go that'd rather not be called by their name."
	icon = "thesingulo"

/datum/barsign/thedrunkcarp
	name = "The Drunk Carp"
	desc = "Don't drink and swim."
	icon = "thedrunkcarp"

/datum/barsign/scotchservinwill
	name = "Scotch Servin Willy's"
	desc = "Willy sure moved up in the world from clown to bartender."
	icon = "scotchservinwill"

/datum/barsign/officerbeersky
	name = "Officer Beersky's"
	desc = "Man eat a dong, these drinks are great."
	icon = "officerbeersky"

/datum/barsign/thecavern
	name = "The Cavern"
	desc = "Fine drinks while listening to some fine tunes."
	icon = "thecavern"

/datum/barsign/theouterspess
	name = "The Outer Spess"
	desc = "This bar isn't actually located in outer space."
	icon = "theouterspess"

/datum/barsign/slipperyshots
	name = "Slippery Shots"
	desc = "Slippery slope to drunkenness with our shots!"
	icon = "slipperyshots"

/datum/barsign/thegreytide
	name = "The Grey Tide"
	desc = "Abandon your toolboxing ways and enjoy a lazy beer!"
	icon = "thegreytide"

/datum/barsign/honkednloaded
	name = "Honked 'n' Loaded"
	desc = "Honk."
	icon = "honkednloaded"

/datum/barsign/thenest
	name = "The Nest"
	desc = "A good place to retire for a drink after a long night of crime fighting."
	icon = "thenest"

/datum/barsign/thecoderbus
	name = "The Coderbus"
	desc = "A very controversial bar known for its wide variety of constantly-changing drinks."
	icon = "thecoderbus"

/datum/barsign/theadminbus
	name = "The Adminbus"
	desc = "An establishment visited mainly by space-judges. It isn't bombed nearly as much as court hearings."
	icon = "theadminbus"

/datum/barsign/oldcockinn
	name = "The Old Cock Inn"
	desc = "Something about this sign fills you with despair."
	icon = "oldcockinn"

/datum/barsign/thewretchedhive
	name = "The Wretched Hive"
	desc = "Legally obligated to instruct you to check your drinks for acid before consumption."
	icon = "thewretchedhive"

/datum/barsign/robustacafe
	name = "The Robusta Cafe"
	desc = "Holder of the 'Most Lethal Barfights' record 5 years uncontested."
	icon = "robustacafe"

/datum/barsign/emergencyrumparty
	name = "The Emergency Rum Party"
	desc = "Still serving drinks that were banned years ago."
	icon = "emergencyrumparty"

/datum/barsign/combocafe
	name = "The Combo Cafe"
	desc = "Renowned system-wide for their utterly uncreative drink combinations."
	icon = "combocafe"

/datum/barsign/vladssaladbar
	name = "Vlad's Salad Bar"
	desc = "Under new management. Vlad was always a bit too trigger happy with that shotgun."
	icon = "vladssaladbar"

/datum/barsign/theshaken
	name = "The Shaken"
	desc = "This establishment does not serve stirred drinks."
	icon = "theshaken"

/datum/barsign/thealenath
	name = "The Ale' Nath"
	desc = "All right, buddy. I think you've had EI NATH. Time to get a cab."
	icon = "thealenath"

/datum/barsign/thealohasnackbar
	name = "The Aloha Snackbar"
	desc = "A tasteful, inoffensive tiki bar sign."
	icon = "alohasnackbar"

/datum/barsign/thenet
	name = "The Net"
	desc = "The sea of drinkformation." //you couldn't come up with something better?
	icon = "thenet"

/datum/barsign/armok
	name = "Armok's Bar and Grill"
	desc = "Dorfs need not apply."
	icon = "armokbar"

/datum/barsign/meadbay
	name = "Mead Bay"
	desc = "Still probably a better place to get treated than the real one."
	icon = "meadbay"

/datum/barsign/whiskeyimplant
	name = "Whiskey Implant"
	desc = "A bar known for its unconventional means of serving you drinks, whether you want them or not."
	icon = "whiskeyimplant"

/datum/barsign/redshirt
	name = "The Red Shirt"
	desc = "A number of famous patrons have attended this bar, including:..."
	icon = "theredshirt"

/datum/barsign/lv426
	name = "LV-426"
	desc = "Drinking with fancy facemasks is clearly more important than going to medbay."
	icon = "lv426"

/datum/barsign/zocalo
	name = "Zocalo"
	desc = "Anteriormente ubicado en Spessmerica."
	icon = "zocalo"

/datum/barsign/fourtheemprah
	name = "4 The Emprah"
	desc = "Enjoyed by fanatics, heretics, and brain-damaged patrons alike."
	icon = "4theemprah"

/datum/barsign/ishimura
	name = "Ishimura"
	desc = "Well known for their quality brownstar and delicious crackers."
	icon = "ishimura"

/datum/barsign/tardis
	name = "Tardis"
	desc = "This establishment has been through at least 5,343 iterations."
	icon = "tardis"

/datum/barsign/quarks
	name = "Quark's"
	desc = "Frequenters of this establishment are often seen wearing meson scanners; how quaint."
	icon = "quarks"

/datum/barsign/tenforward
	name = "Ten Forward"
	desc = "Totally not a rip-off of an established bar or anything like that."
	icon = "tenforward"

/datum/barsign/thepranicngpony
	name = "The Prancing Pony"
	desc = "Ok, we don't take to kindly to you short folk pokin' round looking for some ranger scum."
	icon = "thepranicngpony"

/datum/barsign/vault13
	name = "Vault 13"
	desc = "Coincidence is intentional."
	icon = "vault13"

/datum/barsign/solaris
	name = "Solaris"
	desc = "When is a plasma giant not a plasma giant? When it's a bar serving plasma from a plasma giant."
	icon = "solaris"

/datum/barsign/thehive
	name = "The Hive"
	desc = "Dedicated to and founded in memory of those who died aboard the NT Class 4407 Research Stations."
	icon = "thehive"

/datum/barsign/cantina
	name = "Chalmun's Cantina"
	desc = "The bar was founded on the principles of originality; they have the same music playing 24/7."
	icon = "cantina"

/datum/barsign/milliways42
	name = "Milliways 42"
	desc = "It's not really the end; it's the beginning, meaning, and answer for all your beverage needs."
	icon = "milliways42"

/datum/barsign/timeofeve
	name = "The Time of Eve"
	desc = "Vintage drinks from 2453!."
	icon = "thetimeofeve"

/datum/barsign/spaceasshole
	name = "Space Asshole"
	desc = "Open since 2125, Not much has changed since then; the engineers still release the singulo and the damn miners still are more likely to cave your face in that deliver ores."
	icon = "spaceasshole"

/datum/barsign/themaint
	name = "The Maint"
	desc = "Home to Greytiders, Security and other unholy creations."
	icon = "themaint"

/datum/barsign/syndicat
	name = "The SyndiCat"
	desc = "Syndicate or die."
	icon = "thesyndicat"
	syndicate = TRUE

/datum/barsign/hiddensigns
	hidden = TRUE

//Hidden signs list below this point
/datum/barsign/hiddensigns/empbarsign
	name = "Haywire Barsign"
	desc = "Something has gone very wrong."
	icon = "empbarsign"

/datum/barsign/hiddensigns/signoff
	name = "Bar Sign"
	desc = "This sign doesn't seem to be on."
	icon = "off"

/datum/barsign/hiddensigns/signbroken
	name = "Broken Bar Sign"
	desc = "This sign has a massive crack in it!"
	icon = "broken"

/datum/barsign/hiddensigns/building
	name = "Bar Sign Frame"
	desc = "This isn't advertising anything except that the bar is under renovations."

/datum/barsign/hiddensigns/building/frame
	icon = "frame"

/datum/barsign/hiddensigns/building/circuited
	icon = "circuited"

/datum/barsign/hiddensigns/building/wired
	icon = "wired"


#undef BARSIGN_FRAME
#undef BARSIGN_CIRCUIT
#undef BARSIGN_WIRED
#undef BARSIGN_COMPLETE
