/obj/screen/robot
	icon = 'icons/mob/screen1_robot.dmi'

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
	name = "headlamp"
	icon_state = "lamp0"

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

/datum/hud/proc/robot_hud()

	src.adding = list()
	src.other = list()

	var/obj/screen/using


//Radio
	using = new /obj/screen/robot/radio()
	using.name = "radio"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_borg_radio
	using.layer = 20
	src.adding += using

//Module select

	using = new /obj/screen/robot/module1()
	using.name = "module1"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv1
	using.layer = 20
	src.adding += using
	mymob:inv1 = using

	using = new /obj/screen/robot/module2()
	using.name = "module2"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv2"
	using.screen_loc = ui_inv2
	using.layer = 20
	src.adding += using
	mymob:inv2 = using

	using = new /obj/screen/robot/module3()
	using.name = "module3"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = "inv3"
	using.screen_loc = ui_inv3
	using.layer = 20
	src.adding += using
	mymob:inv3 = using

//End of module select

//Sec/Med HUDs
	using = new /obj/screen/ai/sensors()
	using.name = "Toggle Sensor Augmentation"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_sensor"
	using.screen_loc = ui_borg_sensor
	using.layer = 20
	adding += using

//Intent
	using = new /obj/screen/act_intent()
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_robot.dmi'
	using.icon_state = (mymob.a_intent == "harm" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_borg_intents
	using.layer = 20
	src.adding += using
	action_intent = using

//Cell
	mymob:cells = new /obj/screen()
	mymob:cells.icon = 'icons/mob/screen1_robot.dmi'
	mymob:cells.icon_state = "charge-empty"
	mymob:cells.name = "cell"
	mymob:cells.screen_loc = ui_toxin

//Health
	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_robot.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_borg_health

//Installed Module
	mymob.hands = new /obj/screen/robot/module()
	mymob.hands.icon = 'icons/mob/screen1_robot.dmi'
	mymob.hands.icon_state = "nomod"
	mymob.hands.name = "module"
	mymob.hands.screen_loc = ui_borg_module


//Store
	mymob.throw_icon = new /obj/screen/robot/store()
	mymob.throw_icon.icon = 'icons/mob/screen1_robot.dmi'
	mymob.throw_icon.icon_state = "store"
	mymob.throw_icon.name = "store"
	mymob.throw_icon.screen_loc = ui_borg_store

//Headlamp
	mymob:lamp_button = new /obj/screen/robot/lamp()
	mymob:lamp_button.icon = 'icons/mob/screen1_robot.dmi'
	mymob:lamp_button.icon_state = "lamp0"
	mymob:lamp_button.name = "Toggle Headlamp"
	mymob:lamp_button.screen_loc = ui_borg_lamp

//Temp
	mymob.bodytemp = new /obj/screen()
	mymob.bodytemp.icon_state = "temp0"
	mymob.bodytemp.name = "body temperature"
	mymob.bodytemp.screen_loc = ui_temp


	mymob.oxygen = new /obj/screen()
	mymob.oxygen.icon = 'icons/mob/screen1_robot.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.fire = new /obj/screen()
	mymob.fire.icon = 'icons/mob/screen1_robot.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen1_robot.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_borg_pull

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/mob/screen1_robot.dmi'
	mymob.zone_sel.overlays.Cut()
	mymob.zone_sel.overlays += image('icons/mob/zone_sel.dmi', "[mymob.zone_sel.selecting]")

	mymob.gun_setting_icon = new /obj/screen/gun/mode(null)
	mymob.item_use_icon = new /obj/screen/gun/item(null)

	mymob.client.screen = list()

	mymob.client.screen += list(mymob.zone_sel, mymob.oxygen, mymob.fire, mymob.hands, mymob.healths, mymob:cells, mymob.pullin, mymob.gun_setting_icon, mymob:lamp_button) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other
	mymob.client.screen += mymob.client.void
	return


/datum/hud/proc/toggle_show_robot_modules()
	if(!isrobot(mymob)) return

	var/mob/living/silicon/robot/r = mymob

	r.shown_robot_modules = !r.shown_robot_modules
	update_robot_modules_display()

/datum/hud/proc/update_robot_modules_display()
	if(!isrobot(mymob)) return

	var/mob/living/silicon/robot/r = mymob

	if(!r.client) return

	if(r.shown_robot_modules)
		//Modules display is shown
		r.client.screen += r.throw_icon	//"store" icon

		if(!r.module)
			to_chat(usr, "\red No module selected")

			return

		if(!r.module.modules)
			to_chat(usr, "\red Selected module has no modules to select")

			return

		if(!r.robot_modules_background)
			return

		var/display_rows = round((r.module.modules.len) / 8) +1 //+1 because round() returns floor of number
		r.robot_modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		r.client.screen += r.robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		//Unfortunately adding the emag module to the list of modules has to be here. This is because a borg can
		//be emagged before they actually select a module. - or some situation can cause them to get a new module
		// - or some situation might cause them to get de-emagged or something.
		if(r.emagged)
			if(!(r.module.emag in r.module.modules))
				r.module.modules.Add(r.module.emag)
		else
			if(r.module.emag in r.module.modules)
				r.module.modules.Remove(r.module.emag)

		for(var/atom/movable/A in r.module.modules)
			if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
				//Module is not currently active
				r.client.screen += A
				if(x < 0)
					A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
				else
					A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
				A.layer = 20

				x++
				if(x == 4)
					x = -4
					y++

	else
		//Modules display is hidden
		r.client.screen -= r.throw_icon	//"store" icon

		for(var/atom/A in r.module.modules)
			if( (A != r.module_state_1) && (A != r.module_state_2) && (A != r.module_state_3) )
				//Module is not currently active
				r.client.screen -= A
		r.shown_robot_modules = 0
		r.client.screen -= r.robot_modules_background
