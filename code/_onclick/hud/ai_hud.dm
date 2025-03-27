/atom/movable/screen/ai
	icon = 'icons/mob/screen_ai.dmi'

/atom/movable/screen/ai/Click()
	if(isobserver(usr) || usr.incapacitated())
		return TRUE

/atom/movable/screen/ai/aicore
	name = "AI core"
	icon_state = "ai_core"

/atom/movable/screen/ai/aicore/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.view_core()

/atom/movable/screen/ai/camera_list
	name = "Show Camera List"
	icon_state = "camera"

/atom/movable/screen/ai/camera_list/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	var/camera = tgui_input_list(AI, "Choose which camera you want to view", "Cameras", AI.get_camera_list())
	AI.ai_camera_list(camera)

/atom/movable/screen/ai/camera_track
	name = "Track With Camera"
	icon_state = "track"

/atom/movable/screen/ai/camera_track/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	var/target_name = tgui_input_list(AI, "Choose a target you want to track", "Tracking", AI.trackable_mobs())
	if(target_name)
		AI.ai_camera_track(target_name)

/atom/movable/screen/ai/camera_light
	name = "Toggle Camera Light"
	icon_state = "camera_light"

/atom/movable/screen/ai/camera_light/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.toggle_camera_light()

/atom/movable/screen/ai/crew_monitor
	name = "Crew Monitoring Console"
	icon_state = "crew_monitor"

/atom/movable/screen/ai/crew_monitor/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.subsystem_crew_monitor()

/atom/movable/screen/ai/crew_manifest
	name = "Crew Manifest"
	icon_state = "manifest"

/atom/movable/screen/ai/crew_manifest/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.ai_roster()

/atom/movable/screen/ai/alerts
	name = "Show Alerts"
	icon_state = "alerts"

/atom/movable/screen/ai/alerts/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.ai_alerts()

/atom/movable/screen/ai/announcement
	name = "Make Announcement"
	icon_state = "announcement"

/atom/movable/screen/ai/announcement/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.announcement()

/atom/movable/screen/ai/call_shuttle
	name = "Call Emergency Shuttle"
	icon_state = "call_shuttle"

/atom/movable/screen/ai/call_shuttle/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.ai_call_shuttle()

/atom/movable/screen/ai/state_laws
	name = "Law Manager"
	icon_state = "state_laws"

/atom/movable/screen/ai/state_laws/Click()
	if(..())
		return
	if(is_ai(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.subsystem_law_manager()

/atom/movable/screen/ai/pda_msg_send
	name = "PDA - Send Message"
	icon_state = "pda_send"

/atom/movable/screen/ai/pda_msg_send/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.aiPDA.cmd_send_pdamesg()

/atom/movable/screen/ai/pda_msg_show
	name = "PDA - Show Message Log"
	icon_state = "pda_receive"

/atom/movable/screen/ai/pda_msg_show/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.aiPDA.cmd_show_message_log()

/atom/movable/screen/ai/image_take
	name = "Take Image"
	icon_state = "take_picture"

/atom/movable/screen/ai/image_take/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.aiCamera.toggle_camera_mode()

/atom/movable/screen/ai/image_view
	name = "View Images"
	icon_state = "view_images"

/atom/movable/screen/ai/image_view/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.aiCamera.viewpictures()

/atom/movable/screen/ai/sensors
	name = "Toggle Sensor Augmentation"
	icon_state = "ai_sensor"

/atom/movable/screen/ai/sensors/Click()
	if(..())
		return
	if(is_ai(usr))
		var/mob/living/silicon/ai/AI = usr
		AI.sensor_mode()
	else if(isrobot(usr))
		var/mob/living/silicon/robot/borg = usr
		borg.sensor_mode()

/datum/hud/ai/New(mob/owner)
	..()

	var/atom/movable/screen/using

	using = new /atom/movable/screen/language_menu
	using.screen_loc = ui_borg_lanugage_menu
	static_inventory += using

//AI core
	using = new /atom/movable/screen/ai/aicore()
	using.screen_loc = ui_ai_core
	static_inventory += using

//Camera list
	using = new /atom/movable/screen/ai/camera_list()
	using.screen_loc = ui_ai_camera_list
	static_inventory += using

//Track
	using = new /atom/movable/screen/ai/camera_track()
	using.screen_loc = ui_ai_track_with_camera
	static_inventory += using

//Camera light
	using = new /atom/movable/screen/ai/camera_light()
	using.screen_loc = ui_ai_camera_light
	static_inventory += using

//Crew Monitorting
	using = new  /atom/movable/screen/ai/crew_monitor()
	using.screen_loc = ui_ai_crew_monitor
	static_inventory += using

//Crew Manifest
	using = new /atom/movable/screen/ai/crew_manifest()
	using.screen_loc = ui_ai_crew_manifest
	static_inventory += using

//Alerts
	using = new /atom/movable/screen/ai/alerts()
	using.screen_loc = ui_ai_alerts
	static_inventory += using

//Announcement
	using = new /atom/movable/screen/ai/announcement()
	using.screen_loc = ui_ai_announcement
	static_inventory += using

//Shuttle
	using = new /atom/movable/screen/ai/call_shuttle()
	using.screen_loc = ui_ai_shuttle
	static_inventory += using

//Laws
	using = new /atom/movable/screen/ai/state_laws()
	using.screen_loc = ui_ai_state_laws
	static_inventory += using

//PDA message
	using = new /atom/movable/screen/ai/pda_msg_send()
	using.screen_loc = ui_ai_pda_send
	static_inventory += using

//PDA log
	using = new /atom/movable/screen/ai/pda_msg_show()
	using.screen_loc = ui_ai_pda_log
	static_inventory += using

//Take image
	using = new /atom/movable/screen/ai/image_take()
	using.screen_loc = ui_ai_take_picture
	static_inventory += using

//View images
	using = new /atom/movable/screen/ai/image_view()
	using.screen_loc = ui_ai_view_images
	static_inventory += using

//Medical/Security sensors
	using = new /atom/movable/screen/ai/sensors()
	using.screen_loc = ui_ai_sensor
	static_inventory += using

//Intent
	using = new /atom/movable/screen/act_intent/robot/ai()
	using.icon_state = mymob.a_intent
	static_inventory += using
	action_intent = using
