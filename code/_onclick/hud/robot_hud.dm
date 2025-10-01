/atom/movable/screen/robot
	icon = 'icons/mob/screen_robot.dmi'

/atom/movable/screen/robot/Click()
	. = ..()
	if(isobserver(usr))
		return TRUE

/atom/movable/screen/robot/module
	name = "cyborg module"
	icon_state = "nomod"

/atom/movable/screen/robot/module/Click()
	if(isrobot(usr) && !..())
		var/mob/living/silicon/robot/R = usr
		if(!R.module)
			R.pick_module()
			return

	// we can let ghosts mess with this one
	usr.hud_used.toggle_show_robot_modules(usr)
	return TRUE


/atom/movable/screen/robot/active_module
	name = "module"
	icon_state = "inv"
	/// If it's slot 1, 2, or 3
	var/module_number = CYBORG_MODULE_ONE
	/// Where the string for the deactivated icon state is stored
	var/deactivated_icon_string
	/// Where the string for the activated icon state is stored
	var/activated_icon_string
	/// If it should have a green background
	var/active = FALSE

/atom/movable/screen/robot/active_module/Initialize(mapload, slot_number)
	. = ..()
	module_number = slot_number
	name = name + "[module_number]"
	icon_state = icon_state + "[module_number]"
	deactivated_icon_string = icon_state
	activated_icon_string = icon_state + " +a"

/// Updates the background of the module to be active
/atom/movable/screen/robot/active_module/proc/activate()
	icon_state = activated_icon_string
	active = TRUE

/// Updates the background of the module to be inactive
/atom/movable/screen/robot/active_module/proc/deactivate()
	icon_state = deactivated_icon_string
	active = FALSE

/atom/movable/screen/robot/active_module/Click()
	if(..() || !module_number)
		return
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_module(module_number)

/atom/movable/screen/robot/radio
	name = "radio"
	icon_state = "radio"

/atom/movable/screen/robot/radio/Click()
	if(..())
		return
	if(issilicon(usr))
		var/mob/living/silicon/robot/R = usr
		R.radio_menu()

/atom/movable/screen/robot/store
	name = "store"
	icon_state = "store"

/atom/movable/screen/robot/store/Click()
	if(..())
		return
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.uneq_active()
		R.hud_used.update_robot_modules_display()

/atom/movable/screen/robot/lamp
	name = "Toggle Headlamp"
	icon_state = "lamp0"
	screen_loc = UI_BORG_LAMP

/atom/movable/screen/robot/lamp/Click()
	if(..())
		return
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.control_headlamp()

/atom/movable/screen/robot/thrusters
	name = "ion thrusters"
	icon_state = "ionpulse0"

/atom/movable/screen/robot/thrusters/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.toggle_ionpulse()

/atom/movable/screen/robot/pda
	name = "internal PDA"
	icon_state = "pda"
	screen_loc = UI_BORG_PDA

/atom/movable/screen/robot/pda/Click()
	if(..())
		return
	var/mob/living/silicon/robot/R = usr
	R.open_pda()

/atom/movable/screen/robot/mov_intent
	name = "fast/slow toggle"
	icon_state = "running"

/atom/movable/screen/robot/mov_intent/Click()
	if(..())
		return
	usr.toggle_move_intent()

/datum/hud/robot
	var/shown_robot_modules = FALSE	// Used to determine whether they have the module menu shown or not
	var/atom/movable/screen/robot_modules_background


/datum/hud/robot/New(mob/user)
	..()


	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	robot_modules_background.layer = HUD_LAYER // Objects that appear on screen are on layer 20, UI should be just below it.
	robot_modules_background.plane = HUD_PLANE

	var/atom/movable/screen/using
	var/mob/living/silicon/robot/mymobR = mymob

//Language menu
	using = new /atom/movable/screen/language_menu
	using.screen_loc = UI_BORG_LANUGAGE_MENU
	static_inventory += using

//Radio
	using = new /atom/movable/screen/robot/radio()
	using.screen_loc = UI_BORG_RADIO
	static_inventory += using

//Module select
	for(var/i in 1 to CYBORG_MAX_MODULES)
		using = new /atom/movable/screen/robot/active_module(src, i)
		using.screen_loc = CYBORG_HUD_LOCATIONS[i]
		static_inventory += using
		mymobR.inventory_screens += using

//Sec/Med HUDs
	using = new /atom/movable/screen/ai/sensors()
	using.screen_loc = UI_BORG_SENSOR
	static_inventory += using

//Intent
// Attack intent
	using = new /atom/movable/screen/act_intent/robot()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

// Movement intent
	using = new /atom/movable/screen/robot/mov_intent()
	using.icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	using.screen_loc = UI_MOVI
	move_intent = using

//Health
	mymob.healths = new /atom/movable/screen/healths/robot()
	infodisplay += mymob.healths
	mymob.staminas = new /atom/movable/screen/healths/stamina()
	infodisplay += mymob.staminas

//Installed Module
	mymobR.hands = new /atom/movable/screen/robot/module()
	mymobR.hands.screen_loc = UI_BORG_MODULE
	static_inventory += mymobR.hands

	module_store_icon = new /atom/movable/screen/robot/store()
	module_store_icon.screen_loc = UI_BORG_STORE

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_robot.dmi'
	mymob.pullin.hud = src
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = UI_BORG_PULL
	hotkeybuttons += mymob.pullin

	zone_select = new /atom/movable/screen/zone_sel/robot()
	zone_select.hud = src
	zone_select.update_icon(UPDATE_OVERLAYS)
	static_inventory += zone_select

//Headlamp
	mymobR.lamp_button = new /atom/movable/screen/robot/lamp()
	mymobR.lamp_button.screen_loc = UI_BORG_LAMP
	static_inventory += mymobR.lamp_button

//Thrusters
	using = new /atom/movable/screen/robot/thrusters()
	using.screen_loc = UI_BORG_THRUSTERS
	static_inventory += using
	mymobR.thruster_button = using

// PDA
	using = new /atom/movable/screen/robot/pda()
	static_inventory += using
	mymobR.pda_button = using

/datum/hud/robot/Destroy()
	var/mob/living/silicon/robot/myrob = mymob
	myrob.hands = null
	QDEL_LAZYLIST(myrob.inventory_screens)
	myrob.lamp_button = null
	myrob.thruster_button = null

	return ..()

/datum/hud/proc/toggle_show_robot_modules(mob/viewmob)
	return

/datum/hud/robot/toggle_show_robot_modules(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	if(istype(viewmob.hud_used, /datum/hud/robot))
		var/datum/hud/robot/robohud = screenmob.hud_used
		robohud.shown_robot_modules = !robohud.shown_robot_modules

	update_robot_modules_display(viewmob)

/datum/hud/proc/update_robot_modules_display(mob/viewer)
	return

/datum/hud/robot/update_robot_modules_display(mob/viewer)
	if(!isrobot(mymob))
		return

	var/mob/living/silicon/robot/R = mymob

	var/mob/screenmob = viewer || R

	if(!R.client)
		return

	if(!R.module)
		shown_robot_modules = FALSE
		screenmob.client.screen -= robot_modules_background
		screenmob.client?.screen -= screenmob.hud_used.module_store_icon
		return

	if(shown_robot_modules && hud_shown && hud_version == HUD_STYLE_STANDARD)
		//Modules display is shown
		screenmob.client.screen += module_store_icon	//"store" icon

		if(!R.module.modules)
			to_chat(usr, "<span class='danger'>Selected module has no modules to select.</span>")
			return

		if(!robot_modules_background)
			return

		var/display_rows = CEILING(length(R.module.modules) / 8, 1)
		robot_modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		screenmob.client.screen += robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		for(var/atom/movable/A in R.module.modules)
			if(A in R.all_active_items) // Don't need to display it if it's already active
				continue
			screenmob.client.screen += A
			if(x < 0)
				A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
			else
				A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
			A.layer = ABOVE_HUD_LAYER
			A.plane = ABOVE_HUD_PLANE

			x++
			if(x == 4)
				x = -4
				y++

	else
		//Modules display is hidden
		screenmob.client.screen -= module_store_icon

		for(var/atom/A in R.module.modules)
			if(A in R.all_active_items) // Don't need to display it if it's already active
				continue
			screenmob.client.screen -= A
		shown_robot_modules = FALSE
		screenmob.client.screen -= robot_modules_background

/datum/hud/robot/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return
	var/mob/living/silicon/robot/R = mymob

	var/mob/screenmob = viewer || R

	if(!screenmob.hud_used)
		return
	if(screenmob.hud_used.hud_shown)
		for(var/i in 1 to length(R.all_active_items))
			var/obj/item/active_item = R.all_active_items[i]
			if(active_item)
				active_item.screen_loc = CYBORG_HUD_LOCATIONS[i]
				screenmob.client.screen |= active_item
	else
		for(var/obj/item/I in R.all_active_items)
			screenmob.client.screen -= I
