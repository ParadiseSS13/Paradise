/obj/screen/robot
	icon = 'icons/mob/screen_robot.dmi'

/obj/screen/robot/module
	name = "cyborg module"
	icon_state = "nomod"

/obj/screen/robot/module/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		if(R.module)
			R.hud_used.toggle_show_robot_modules()
			return 1
		R.pick_module()

/obj/screen/robot/module1
	name = "module1"
	icon_state = "inv1"

/obj/screen/robot/module1/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_module(1)

/obj/screen/robot/module2
	name = "module2"
	icon_state = "inv2"

/obj/screen/robot/module2/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_module(2)

/obj/screen/robot/module3
	name = "module3"
	icon_state = "inv3"

/obj/screen/robot/module3/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.toggle_module(3)


/obj/screen/robot/radio
	name = "radio"
	icon_state = "radio"

/obj/screen/robot/radio/Click()
	if(issilicon(usr))
		var/mob/living/silicon/robot/R = usr
		R.radio_menu()

/obj/screen/robot/store
	name = "store"
	icon_state = "store"

/obj/screen/robot/store/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.uneq_active()
		R.hud_used.update_robot_modules_display()

/obj/screen/robot/lamp
	name = "Toggle Headlamp"
	icon_state = "lamp0"
	screen_loc = ui_borg_lamp

/obj/screen/robot/lamp/Click()
	if(isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		R.control_headlamp()

/obj/screen/robot/panel
	name = "installed modules"
	icon_state = "panel"

/obj/screen/robot/panel/Click()
	if(issilicon(usr))
		var/mob/living/silicon/robot/R = usr
		R.installed_modules()

/mob/living/silicon/robot/create_mob_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/robot(src)

/datum/hud/robot/New(mob/user)
	..()

	var/obj/screen/using
	var/mob/living/silicon/robot/mymobR = mymob

//Radio
	using = new /obj/screen/robot/radio()
	using.screen_loc = ui_borg_radio
	static_inventory += using

//Module select
	using = new /obj/screen/robot/module1()
	using.screen_loc = ui_inv1
	static_inventory += using
	mymobR.inv1 = using

	using = new /obj/screen/robot/module2()
	using.screen_loc = ui_inv2
	static_inventory += using
	mymobR.inv2 = using

	using = new /obj/screen/robot/module3()
	using.screen_loc = ui_inv3
	static_inventory += using
	mymobR.inv3 = using

//End of module select

//Sec/Med HUDs
	using = new /obj/screen/ai/sensors()
	using.screen_loc = ui_borg_sensor
	static_inventory += using

//Intent
	using = new /obj/screen/act_intent/robot()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using

//Health
	mymob.healths = new /obj/screen/healths/robot()
	infodisplay += mymob.healths

//Installed Module
	mymob.hands = new /obj/screen/robot/module()
	mymob.hands.screen_loc = ui_borg_module
	static_inventory += mymob.hands

	module_store_icon = new /obj/screen/robot/store()
	module_store_icon.screen_loc = ui_borg_store

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen_robot.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_borg_pull
	hotkeybuttons += mymob.pullin

	mymob.zone_sel = new /obj/screen/zone_sel/robot()
	mymob.zone_sel.update_icon(mymob)
	static_inventory += mymob.zone_sel

//Headlamp
	mymobR.lamp_button = new /obj/screen/robot/lamp()
	mymobR.lamp_button.screen_loc = ui_borg_lamp
	static_inventory += mymobR.lamp_button


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

		var/display_rows = Ceiling(R.module.modules.len / 8)
		R.robot_modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		R.client.screen += R.robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		//Unfortunately adding the emag module to the list of modules has to be here. This is because a borg can
		//be emagged before they actually select a module. - or some situation can cause them to get a new module
		// - or some situation might cause them to get de-emagged or something.
		if(R.emagged)
			if(!(R.module.emag in R.module.modules))
				R.module.modules.Add(R.module.emag)
		else
			if(R.module.emag in R.module.modules)
				R.module.modules.Remove(R.module.emag)

		for(var/atom/movable/A in R.module.modules)
			if( (A != R.module_state_1) && (A != R.module_state_2) && (A != R.module_state_3) )
				//Module is not currently active
				R.client.screen += A
				if(x < 0)
					A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
				else
					A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
				A.layer = 20
				A.plane = HUD_PLANE

				x++
				if(x == 4)
					x = -4
					y++

	else
		//Modules display is hidden
		R.client.screen -= module_store_icon

		for(var/atom/A in R.module.modules)
			if( (A != R.module_state_1) && (A != R.module_state_2) && (A != R.module_state_3) )
				//Module is not currently active
				R.client.screen -= A
		R.shown_robot_modules = 0
		R.client.screen -= R.robot_modules_background
