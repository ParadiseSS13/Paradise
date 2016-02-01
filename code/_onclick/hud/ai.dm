/obj/screen/ai
	icon = 'icons/mob/screen_ai.dmi'

/obj/screen/ai/aicore
	name = "AI core"
	icon_state = "ai_core"

/obj/screen/ai/aicore/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.view_core()

/obj/screen/ai/camera_list
	name = "Show Camera List"
	icon_state = "camera"

/obj/screen/ai/camera_list/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		var/camera = input(AI) in AI.get_camera_list()
		AI.ai_camera_list(camera)

/obj/screen/ai/camera_track
	name = "Track With Camera"
	icon_state = "track"

/obj/screen/ai/camera_track/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		var/target_name = input(AI) as null|anything in AI.trackable_mobs()
		if(target_name)
			AI.ai_camera_track(target_name)

/obj/screen/ai/camera_light
	name = "Toggle Camera Light"
	icon_state = "camera_light"

/obj/screen/ai/camera_light/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.toggle_camera_light()

/obj/screen/ai/crew_monitor
	name = "Crew Monitoring Console"
	icon_state = "crew_monitor"

/obj/screen/ai/crew_monitor/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.subsystem_crew_monitor()

/obj/screen/ai/crew_manifest
	name = "Crew Manifest"
	icon_state = "manifest"

/obj/screen/ai/crew_manifest/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.ai_roster()

/obj/screen/ai/alerts
	name = "Show Alerts"
	icon_state = "alerts"

/obj/screen/ai/alerts/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.subsystem_alarm_monitor()

/obj/screen/ai/announcement
	name = "Make Announcement"
	icon_state = "announcement"

/obj/screen/ai/announcement/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.announcement()

/obj/screen/ai/call_shuttle
	name = "Call Emergency Shuttle"
	icon_state = "call_shuttle"

/obj/screen/ai/call_shuttle/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.ai_call_shuttle()

/obj/screen/ai/state_laws
	name = "State Laws"
	icon_state = "state_laws"

/obj/screen/ai/state_laws/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.subsystem_law_manager()

/obj/screen/ai/pda_msg_send
	name = "PDA - Send Message"
	icon_state = "pda_send"

/obj/screen/ai/pda_msg_send/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.cmd_send_pdamesg(usr)

/obj/screen/ai/pda_msg_show
	name = "PDA - Show Message Log"
	icon_state = "pda_receive"

/obj/screen/ai/pda_msg_show/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.cmd_show_message_log(usr)

/obj/screen/ai/image_take
	name = "Take Image"
	icon_state = "take_picture"

/obj/screen/ai/image_take/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.aiCamera.toggle_camera_mode()

/obj/screen/ai/image_view
	name = "View Images"
	icon_state = "view_images"

/obj/screen/ai/image_view/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.aiCamera.viewpictures()

/obj/screen/ai/sensors
	name = "Sensor Augmentation"
	icon_state = "ai_sensor"

/obj/screen/ai/sensors/Click()
	if(isAI(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.sensor_mode()
	else if(isrobot(usr))
		var/mob/living/silicon/robot/borg = usr
		borg.sensor_mode()


/datum/hud/proc/ai_hud()
	adding = list()
	other = list()

	var/obj/screen/using

//AI core
	using = new /obj/screen/ai/aicore()
	using.name = "AI Core"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_core"
	using.screen_loc = ui_ai_core
	using.layer = 20
	adding += using

//Camera list
	using = new /obj/screen/ai/camera_list()
	using.name = "Show Camera List"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera"
	using.screen_loc = ui_ai_camera_list
	using.layer = 20
	adding += using

//Track
	using = new /obj/screen/ai/camera_track()
	using.name = "Track With Camera"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "track"
	using.screen_loc = ui_ai_track_with_camera
	using.layer = 20
	adding += using

//Camera light
	using = new /obj/screen/ai/camera_light()
	using.name = "Toggle Camera Light"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "camera_light"
	using.screen_loc = ui_ai_camera_light
	using.layer = 20
	adding += using

//Crew Monitorting
	using = new  /obj/screen/ai/crew_monitor()
	using.name = "Crew Monitoring"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "crew_monitor"
	using.screen_loc = ui_ai_crew_monitor
	using.layer = 20
	adding += using

//Crew Manifest
	using = new /obj/screen/ai/crew_manifest()
	using.name = "Show Crew Manifest"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "manifest"
	using.screen_loc = ui_ai_crew_manifest
	using.layer = 20
	adding += using

//Alerts
	using = new /obj/screen/ai/alerts()
	using.name = "Show Alerts"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "alerts"
	using.screen_loc = ui_ai_alerts
	using.layer = 20
	adding += using

//Announcement
	using = new /obj/screen/ai/announcement()
	using.name = "Announcement"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "announcement"
	using.screen_loc = ui_ai_announcement
	using.layer = 20
	adding += using

//Shuttle
	using = new /obj/screen/ai/call_shuttle()
	using.name = "Call Emergency Shuttle"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "call_shuttle"
	using.screen_loc = ui_ai_shuttle
	using.layer = 20
	adding += using

//Laws
	using = new /obj/screen/ai/state_laws()
	using.name = "Law Manager"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "state_laws"
	using.screen_loc = ui_ai_state_laws
	using.layer = 20
	adding += using

//PDA message
	using = new /obj/screen/ai/pda_msg_send()
	using.name = "PDA - Send Message"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_send"
	using.screen_loc = ui_ai_pda_send
	using.layer = 20
	adding += using

//PDA log
	using = new /obj/screen/ai/pda_msg_show()
	using.name = "PDA - Show Message Log"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "pda_receive"
	using.screen_loc = ui_ai_pda_log
	using.layer = 20
	adding += using

//Take image
	using = new /obj/screen/ai/image_take()
	using.name = "Take Image"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "take_picture"
	using.screen_loc = ui_ai_take_picture
	using.layer = 20
	adding += using

//View images
	using = new /obj/screen/ai/image_view()
	using.name = "View Images"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "view_images"
	using.screen_loc = ui_ai_view_images
	using.layer = 20
	adding += using

//Medical/Security sensors
	using = new /obj/screen/ai/sensors()
	using.name = "Set Sensor Augmentation"
	using.icon = 'icons/mob/screen_ai.dmi'
	using.icon_state = "ai_sensor"
	using.screen_loc = ui_ai_sensor
	using.layer = 20
	adding += using

	mymob.client.screen += adding + other
	return