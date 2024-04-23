/atom/movable/screen/robot
	icon = 'icons/mob/screen_robot.dmi'

/atom/movable/screen/robot/module
	name = "cyborg module"
	icon_state = "nomod"

/atom/movable/screen/robot/module/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		if(R.module)
			R.hud_used.toggle_show_robot_modules()
			return 1
		R.pick_module()

/atom/movable/screen/robot/module1
	name = "module1"
	icon_state = "inv1"

/atom/movable/screen/robot/module1/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_module(1)

/atom/movable/screen/robot/module2
	name = "module2"
	icon_state = "inv2"

/atom/movable/screen/robot/module2/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_module(2)

/atom/movable/screen/robot/module3
	name = "module3"
	icon_state = "inv3"

/atom/movable/screen/robot/module3/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_module(3)


/atom/movable/screen/robot/radio
	name = "radio"
	icon_state = "radio"

/atom/movable/screen/robot/radio/Click()
	if(issilicon(usr))
		var/mob/living/silicon/robot/R = usr
		R.radio_menu()

/atom/movable/screen/robot/store
	name = "store"
	icon_state = "store"

/atom/movable/screen/robot/store/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.uneq_active()
		R.hud_used.update_robot_modules_display()

/atom/movable/screen/robot/lamp
	name = "Toggle Headlamp"
	icon_state = "lamp0"
	screen_loc = ui_borg_lamp

/atom/movable/screen/robot/lamp/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.control_headlamp()

/atom/movable/screen/robot/thrusters
	name = "ion thrusters"
	icon_state = "ionpulse0"

/atom/movable/screen/robot/thrusters/Click()
	var/mob/living/silicon/robot/R = usr
	R.toggle_ionpulse()

/atom/movable/screen/robot/mov_intent
	name = "fast/slow toggle"
	icon_state = "running"

/atom/movable/screen/robot/mov_intent/Click()
	usr.toggle_move_intent()

/datum/hud/robot/New(mob/user)
	..()

	var/atom/movable/screen/using
	var/mob/living/silicon/robot/mymobR = mymob

//Language menu
	using = new /atom/movable/screen/language_menu
	using.screen_loc = ui_borg_lanugage_menu
	static_inventory += using

//Radio
	using = new /atom/movable/screen/robot/radio()
	using.screen_loc = ui_borg_radio
	static_inventory += using

//Module select
	using = new /atom/movable/screen/robot/module1()
	using.screen_loc = ui_inv1
	static_inventory += using
	mymobR.inv1 = using

	using = new /atom/movable/screen/robot/module2()
	using.screen_loc = ui_inv2
	static_inventory += using
	mymobR.inv2 = using

	using = new /atom/movable/screen/robot/module3()
	using.screen_loc = ui_inv3
	static_inventory += using
	mymobR.inv3 = using

//End of module select

//Sec/Med HUDs
	using = new /atom/movable/screen/ai/sensors()
	using.screen_loc = ui_borg_sensor
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
	using.screen_loc = ui_movi
	move_intent = using

//Health
	mymob.healths = new /atom/movable/screen/healths/robot()
	infodisplay += mymob.healths

//Installed Module
	mymobR.hands = new /atom/movable/screen/robot/module()
	mymobR.hands.screen_loc = ui_borg_module
	static_inventory += mymobR.hands

	module_store_icon = new /atom/movable/screen/robot/store()
	module_store_icon.screen_loc = ui_borg_store

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_robot.dmi'
	mymob.pullin.hud = src
	mymob.pullin.update_icon(UPDATE_ICON_STATE)
	mymob.pullin.screen_loc = ui_borg_pull
	hotkeybuttons += mymob.pullin

	zone_select = new /atom/movable/screen/zone_sel/robot()
	zone_select.hud = src
	zone_select.update_icon(UPDATE_OVERLAYS)
	static_inventory += zone_select

//Headlamp
	mymobR.lamp_button = new /atom/movable/screen/robot/lamp()
	mymobR.lamp_button.screen_loc = ui_borg_lamp
	static_inventory += mymobR.lamp_button

//Thrusters
	using = new /atom/movable/screen/robot/thrusters()
	using.screen_loc = ui_borg_thrusters
	static_inventory += using
	mymobR.thruster_button = using

/datum/hud/robot/Destroy()
	var/mob/living/silicon/robot/myrob = mymob
	myrob.inv1 = null
	myrob.hands = null
	myrob.inv2 = null
	myrob.inv3 = null
	myrob.lamp_button = null
	myrob.thruster_button = null

	return ..()

/datum/hud/proc/toggle_show_robot_modules()
	if(!isrobot(mymob))
		return

	var/mob/living/silicon/robot/R = mymob

	R.shown_robot_modules = !R.shown_robot_modules
	update_robot_modules_display()

/datum/hud/proc/update_robot_modules_display()
	if(!isrobot(mymob))
		return

	var/mob/living/silicon/robot/R = mymob

	if(!R.client)
		return

	if(!R.module)
		return

	if(R.shown_robot_modules && hud_shown)
		//Modules display is shown
		R.client.screen += module_store_icon	//"store" icon

		if(!R.module.modules)
			to_chat(usr, "<span class='danger'>Selected module has no modules to select.</span>")
			return

		if(!R.robot_modules_background)
			return

		var/display_rows = CEILING(length(R.module.modules) / 8, 1)
		R.robot_modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		R.client.screen += R.robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		for(var/atom/movable/A in R.module.modules)
			if((A != R.module_state_1) && (A != R.module_state_2) && (A != R.module_state_3))
				//Module is not currently active
				R.client.screen += A
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
		R.client.screen -= module_store_icon

		for(var/atom/A in R.module.modules)
			if((A != R.module_state_1) && (A != R.module_state_2) && (A != R.module_state_3))
				//Module is not currently active
				R.client.screen -= A
		R.shown_robot_modules = FALSE
		R.client.screen -= R.robot_modules_background
