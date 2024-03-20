#define BARSIGN_FRAME		0
#define BARSIGN_CIRCUIT		1
#define BARSIGN_WIRED		2
#define BARSIGN_COMPLETE	3



/obj/machinery/barsign // All Signs are 64 by 32 pixels, they take two tiles
	name = "Bar Sign"
	desc = "A bar sign with no writing on it."
	icon = 'icons/obj/barsigns.dmi'
	icon_state = "off"
	req_access = list(ACCESS_BAR)
	max_integrity = 200
	integrity_failure = 160
	idle_power_consumption = 2
	active_power_consumption = 4
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
		if(!signinfo.hidden)
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

// Saves a /datum/barsign (by default the current_sign) to the prev_sign variable.
/obj/machinery/barsign/proc/save_sign(datum/barsign/S=current_sign)
	// Broken, blank, and EMPed screens shouldn't be saved.
	if(istype(S, /datum/barsign) && !istype(S, /datum/barsign/hiddensigns))
		prev_sign = S
		return TRUE
	return FALSE

/obj/machinery/barsign/update_icon_state()
	if(build_stage == BARSIGN_FRAME && !istype(current_sign, /datum/barsign/hiddensigns/building/frame))
		set_sign(new /datum/barsign/hiddensigns/building/frame)
	if(build_stage == BARSIGN_CIRCUIT && !istype(current_sign, /datum/barsign/hiddensigns/building/circuited))
		set_sign(new /datum/barsign/hiddensigns/building/circuited)
	if(build_stage == BARSIGN_WIRED && !istype(current_sign, /datum/barsign/hiddensigns/building/wired))
		set_sign(new /datum/barsign/hiddensigns/building/wired)
	if(build_stage == BARSIGN_COMPLETE)
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

	if(power_state < ACTIVE_POWER_USE || stat & (BROKEN|NOPOWER) || !current_sign || build_stage < BARSIGN_COMPLETE)
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
			. += "<span class='info'><b>Alt-Click</b> to toggle it's power.</span>"
			if(panel_open)
				. += "<span class='notice'>It is disabled by it's <i>unscrewed</i> maintenance panel that exposes an area from which the screen could be <b>pried out</b>.</span>"

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
	save_sign()
	set_light(0)
	// update_icon() won't update the lighting properly, but using a 0 second callback will make it work.  There is almost certainly a better way to do this, but I don't know it.
	addtimer(CALLBACK(src, PROC_REF(update_icon_alt)), 0 SECONDS)
	set_sign(new /datum/barsign/hiddensigns/signoff)
	power_state = IDLE_POWER_USE
	playsound(src, 'sound/machines/lightswitch.ogg', 10, TRUE)
	return TRUE

/obj/machinery/barsign/proc/turn_on()
	if((stat & (BROKEN|NOPOWER|MAINT)) || build_stage < BARSIGN_COMPLETE)
		return FALSE
	if(panel_open)
		return FALSE
	set_light(1, LIGHTING_MINIMUM_POWER)
	addtimer(CALLBACK(src, PROC_REF(update_icon_alt)), 0 SECONDS)
	if(prev_sign)
		set_sign(prev_sign)
	else
		set_random_sign()
	power_state = ACTIVE_POWER_USE
	playsound(src, 'sound/machines/lightswitch.ogg', 10, TRUE)
	return TRUE

/obj/machinery/barsign/proc/update_icon_alt()
	update_icon()

/obj/machinery/barsign/attack_hand(mob/user)
	if(..())
		return
	if(stat & MAINT)
		to_chat(user, "<span class ='warning'>Wait until the repairs are complete!</span>")
		return
	if((stat & (BROKEN|NOPOWER|EMPED)) || build_stage < BARSIGN_COMPLETE)
		to_chat(user, "<span class ='warning'>The controls seem unresponsive.</span>")
		return
	if(panel_open)
		to_chat(user, "<span class ='warning'>Close the maintenance panel first!</span>")
		return
	if(!src.allowed(user))
		to_chat(user, "<span class = 'warning'>Access denied.</span>")
		return
	pick_sign()

/obj/machinery/barsign/AltClick(mob/user)
	add_fingerprint(user)
	if(toggle_on_off())
		return
	attack_hand(user)

/obj/machinery/barsign/attackby(obj/item/I, mob/user, params)
	// Inserting the electronics/circuit
	if(build_stage == BARSIGN_FRAME && istype(I, /obj/item/barsign_electronics))
		var/obj/item/barsign_electronics/bse = I
		if(bse.destroyed)
			emagged = TRUE
		else
			emagged = FALSE
		if(bse.restricts_access)
			req_access = list(ACCESS_BAR)
		else
			req_access = list()
		to_chat(user, "<span class='notice'>You insert the circuit!</span>")
		qdel(bse)
		build_stage = BARSIGN_CIRCUIT
		update_icon()
		playsound(get_turf(src), I.usesound, 50, TRUE)
		add_fingerprint(user)
		return
	// Wiring the bar sign
	else if(build_stage == BARSIGN_CIRCUIT && istype(I, /obj/item/stack/cable_coil))
		if(!I.use(5))
			to_chat(user, "<span class='warning'>You need a total of five cables to wire [src]!</span>")
			return
		stat &= ~EMPED
		build_stage = BARSIGN_WIRED
		update_icon()
		playsound(get_turf(src), I.usesound, 50, TRUE)
		to_chat(user, "<span class='notice'>You wire [src]!</span>")
		power_state = IDLE_POWER_USE
		add_fingerprint(user)
		return
	// Placing in the glass
	else if(build_stage == BARSIGN_WIRED && istype(I, /obj/item/stack/sheet/glass))
		if(!I.use(2))
			to_chat(user, "<span class='warning'>You need at least 2 sheets of glass for this!</span>")
			return
		build_stage = BARSIGN_COMPLETE
		playsound(get_turf(src), I.usesound, 50, TRUE)
		obj_integrity = max_integrity
		if(stat & BROKEN)
			stat &= ~BROKEN
		set_sign(new /datum/barsign/hiddensigns/signoff)
		add_fingerprint(user)
		return
	. = ..()

/obj/machinery/barsign/proc/pick_sign()
	var/picked_name
	if(!emagged)
		picked_name = tgui_input_list(usr, "Available Signage", "Bar Sign", barsigns)
	else
		picked_name = tgui_input_list(usr, "Available Signage", "Bar Sign", syndisigns)
	if(!picked_name)
		return
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
		return
	if(build_stage != BARSIGN_CIRCUIT && build_stage != BARSIGN_COMPLETE)
		return
	. = TRUE
	if(I.tool_behaviour != TOOL_CROWBAR)
		return
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(!(flags & NODECONSTRUCT))
		// Removing the electronics
		if(build_stage == BARSIGN_CIRCUIT)
			var/obj/item/barsign_electronics/bse
			bse = new /obj/item/barsign_electronics
			if(!emagged)
				to_chat(user, "<span class='notice'>You pull the electronics out from [src].</span>")
			else
				// Give fried electronics if the sign is emagged
				to_chat(user, "<span class='notice'>You pull the fried electronics out from [src].</span>")
				bse.destroyed = TRUE
				bse.icon_state = "door_electronics_smoked"
			if(!req_access.len)
				bse.restricts_access = FALSE
			bse.forceMove(get_turf(user))
			build_stage = BARSIGN_FRAME
			update_icon()
			add_fingerprint(user)
		// Removing the glass screen
		else if(build_stage == BARSIGN_COMPLETE)
			if(panel_open)
				// Drop a shard if the glass is broken
				if(stat & BROKEN)
					to_chat(user, "<span class='notice'>You remove the broken screen from [src].</span>")
					new /obj/item/shard(get_turf(user))
				else
					to_chat(user, "<span class='notice'>You pull the glass screen out from [src].</span>")
					var/obj/item/stack/sheet/glass/G
					G = new /obj/item/stack/sheet/glass
					G.amount = 2
					G.forceMove(get_turf(user))
				build_stage = BARSIGN_WIRED
				update_icon()
				add_fingerprint(user)
			else
				to_chat(user, "<span class='warning'>Open the maintenance panel first!</span>")
				return
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
			var/obj/item/stack/cable_coil/C
			C = new /obj/item/stack/cable_coil
			C.amount = 5
			C.forceMove(get_turf(user))
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
			. = ..()

/obj/machinery/barsign/power_change()
	. = ..()
	if(. && (stat & NOPOWER))
		turn_off()

/obj/machinery/barsign/deconstruct(disassembled=FALSE)
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
	..()
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
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'
	var/destroyed = FALSE
	var/restricts_access = TRUE

/obj/item/barsign_electronics/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Use it while in your active hand to toggle the access restrictions.</span>"

/obj/item/barsign_electronics/attack_self(mob/user)
	..()
	if(destroyed)
		return
	if(restricts_access)
		restricts_access = FALSE
		to_chat(user, "<span class='notice'>You disable the access restrictions of [src].</span>")
	else
		restricts_access = TRUE
		to_chat(user, "<span class='notice'>You enable the access restrictions of [src].</span>")

// For the ghost bar since occupants don't have bar access.
/obj/machinery/barsign/ghost_bar
	req_access = list()

/obj/machinery/barsign/ghost_bar/Initialize(mapload)
	..()
	// Also give them access to syndicate signs because why not.
	barsigns |= syndisigns
	set_random_sign()



//Code below is to define useless variables for datums. It errors without these
/datum/barsign
	var/name = "Name"
	var/icon = "Icon"
	var/desc = "desc"
	var/hidden = FALSE
	var/syndicate = FALSE

//Anything below this is where all the specific signs are. If people want to add more signs, add them below.
/datum/barsign/maltesefalcon
	name = "Maltese Falcon"
	icon = "maltesefalcon"
	desc = "The Maltese Falcon, Space Bar and Grill."

/datum/barsign/thebark
	name = "The Bark"
	icon = "thebark"
	desc = "Ian's bar of choice."

/datum/barsign/harmbaton
	name = "The Harmbaton"
	icon = "theharmbaton"
	desc = "A great dining experience for both security members and assistants."


/datum/barsign/thesingulo
	name = "The Singulo"
	icon = "thesingulo"
	desc = "Where people go that'd rather not be called by their name."

/datum/barsign/thedrunkcarp
	name = "The Drunk Carp"
	icon = "thedrunkcarp"
	desc = "Don't drink and swim."

/datum/barsign/scotchservinwill
	name = "Scotch Servin Willy's"
	icon = "scotchservinwill"
	desc = "Willy sure moved up in the world from clown to bartender."

/datum/barsign/officerbeersky
	name = "Officer Beersky's"
	icon = "officerbeersky"
	desc = "Man eat a dong, these drinks are great."

/datum/barsign/thecavern
	name = "The Cavern"
	icon = "thecavern"
	desc = "Fine drinks while listening to some fine tunes."

/datum/barsign/theouterspess
	name = "The Outer Spess"
	icon = "theouterspess"
	desc = "This bar isn't actually located in outer space."

/datum/barsign/slipperyshots
	name = "Slippery Shots"
	icon = "slipperyshots"
	desc = "Slippery slope to drunkenness with our shots!"

/datum/barsign/thegreytide
	name = "The Grey Tide"
	icon = "thegreytide"
	desc = "Abandon your toolboxing ways and enjoy a lazy beer!"

/datum/barsign/honkednloaded
	name = "Honked 'n' Loaded"
	icon = "honkednloaded"
	desc = "Honk."

/datum/barsign/thenest
	name = "The Nest"
	icon = "thenest"
	desc = "A good place to retire for a drink after a long night of crime fighting."

/datum/barsign/thecoderbus
	name = "The Coderbus"
	icon = "thecoderbus"
	desc = "A very controversial bar known for its wide variety of constantly-changing drinks."

/datum/barsign/theadminbus
	name = "The Adminbus"
	icon = "theadminbus"
	desc = "An establishment visited mainly by space-judges. It isn't bombed nearly as much as court hearings."

/datum/barsign/oldcockinn
	name = "The Old Cock Inn"
	icon = "oldcockinn"
	desc = "Something about this sign fills you with despair."

/datum/barsign/thewretchedhive
	name = "The Wretched Hive"
	icon = "thewretchedhive"
	desc = "Legally obligated to instruct you to check your drinks for acid before consumption."

/datum/barsign/robustacafe
	name = "The Robusta Cafe"
	icon = "robustacafe"
	desc = "Holder of the 'Most Lethal Barfights' record 5 years uncontested."

/datum/barsign/emergencyrumparty
	name = "The Emergency Rum Party"
	icon = "emergencyrumparty"
	desc = "Still serving drinks that were banned years ago."

/datum/barsign/combocafe
	name = "The Combo Cafe"
	icon = "combocafe"
	desc = "Renowned system-wide for their utterly uncreative drink combinations."

/datum/barsign/vladssaladbar
	name = "Vlad's Salad Bar"
	icon = "vladssaladbar"
	desc = "Under new management. Vlad was always a bit too trigger happy with that shotgun."

/datum/barsign/theshaken
	name = "The Shaken"
	icon = "theshaken"
	desc = "This establishment does not serve stirred drinks."

/datum/barsign/thealenath
	name = "The Ale' Nath"
	icon = "thealenath"
	desc = "All right, buddy. I think you've had EI NATH. Time to get a cab."

/datum/barsign/thealohasnackbar
	name = "The Aloha Snackbar"
	icon = "alohasnackbar"
	desc = "A tasteful, inoffensive tiki bar sign."

/datum/barsign/thenet
	name = "The Net"
	icon = "thenet"
	desc = "The sea of drinkformation." //you couldn't come up with something better?

/datum/barsign/armok
	name = "Armok's Bar and Grill"
	icon = "armokbar"
	desc = "Dorfs need not apply."

/datum/barsign/meadbay
	name = "Mead Bay"
	icon = "meadbay"
	desc = "Still probably a better place to get treated than the real one."

/datum/barsign/whiskeyimplant
	name = "Whiskey Implant"
	icon = "whiskeyimplant"
	desc = "A bar known for its unconventional means of serving you drinks,whether you want them or not."

/datum/barsign/redshirt
	name = "The Red Shirt"
	icon = "theredshirt"
	desc = "A number of famous patrons have attended this bar, including:..."

/datum/barsign/lv426
	name = "LV-426"
	icon = "lv426"
	desc = "Drinking with fancy facemasks is clearly more important than going to medbay."

/datum/barsign/zocalo
	name = "Zocalo"
	icon = "zocalo"
	desc = "Anteriormente ubicado en Spessmerica."

/datum/barsign/fourtheemprah
	name = "4 The Emprah"
	icon = "4theemprah"
	desc = "Enjoyed by fanatics, heretics, and brain-damaged patrons alike."

/datum/barsign/ishimura
	name = "Ishimura"
	icon = "ishimura"
	desc = "Well known for their quality brownstar and delicious crackers."

/datum/barsign/tardis
	name = "Tardis"
	icon = "tardis"
	desc = "This establishment has been through at least 5,343 iterations."

/datum/barsign/quarks
	name = "Quark's"
	icon = "quarks"
	desc = "Frequenters of this establishment are often seen wearing meson scanners; how quaint."

/datum/barsign/tenforward
	name = "Ten Forward"
	icon = "tenforward"
	desc = "Totally not a rip-off of an established bar or anything like that."

/datum/barsign/thepranicngpony
	name = "The Prancing Pony"
	icon = "thepranicngpony"
	desc = "Ok, we don't take to kindly to you short folk pokin' round looking for some ranger scum."

/datum/barsign/vault13
	name = "Vault 13"
	icon = "vault13"
	desc = "Coincidence is intentional."

/datum/barsign/solaris
	name = "Solaris"
	icon = "solaris"
	desc = "When is a plasma giant not a plasma giant? When it's a bar serving plasma from a plasma giant."

/datum/barsign/thehive
	name = "The Hive"
	icon = "thehive"
	desc = "Dedicated to and founded in memory of those who died aboard the NT Class 4407 Research Stations."

/datum/barsign/cantina
	name = "Chalmun's Cantina"
	icon = "cantina"
	desc = "The bar was founded on the principles of originality; they have the same music playing 24/7."

/datum/barsign/milliways42
	name = "Milliways 42"
	icon = "milliways42"
	desc = "It's not really the end; it's the beginning, meaning, and answer for all your beverage needs."

/datum/barsign/timeofeve
	name = "The Time of Eve"
	icon = "thetimeofeve"
	desc = "Vintage drinks from 2453!."

/datum/barsign/spaceasshole
	name = "Space Asshole"
	icon = "spaceasshole"
	desc = "Open since 2125, Not much has changed since then; the engineers still release the singulo and the damn miners still are more likely to cave your face in that deliver ores."

/datum/barsign/themaint
	name = "The Maint"
	icon = "themaint"
	desc = "Home to Greytiders, Security and other unholy creations."

/datum/barsign/syndicat
	name = "The SyndiCat"
	icon = "thesyndicat"
	desc = "Syndicate or die."
	syndicate = TRUE

/datum/barsign/hiddensigns
	hidden = TRUE

//Hidden signs list below this point
/datum/barsign/hiddensigns/empbarsign
	name = "Haywire Barsign"
	icon = "empbarsign"
	desc = "Something has gone very wrong."

/datum/barsign/hiddensigns/signoff
	name = "Bar Sign"
	icon = "off"
	desc = "This sign doesn't seem to be on."

/datum/barsign/hiddensigns/signbroken
	name = "Broken Bar Sign"
	icon = "broken"
	desc = "This sign has a massive crack in it!"

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
