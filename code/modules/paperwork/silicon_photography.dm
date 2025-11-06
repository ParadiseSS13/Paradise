/**************
* AI-specific *
**************/
/datum/picture
	var/name = "image"
	var/list/fields = list()

/obj/item/camera/siliconcam
	var/in_camera_mode = 0
	var/photos_taken = 0
	var/list/aipictures = list()
	flashing_light = FALSE
	actions_types = list()

/// camera AI can take pictures with
/obj/item/camera/siliconcam/ai_camera
	name = "AI photo camera"
	see_cult = FALSE

/// camera cyborgs can take pictures with
/obj/item/camera/siliconcam/robot_camera
	name = "Cyborg photo camera"

/// currently doesn't offer the verbs, thus cannot be used
/obj/item/camera/siliconcam/drone_camera
	name = "Drone photo camera"

/obj/item/camera/siliconcam/proc/injectaialbum(datum/picture/P, sufix = "") //stores image information to a list similar to that of the datacore
	photos_taken++
	P.fields["name"] = "Image [photos_taken][sufix]"
	aipictures += P

/obj/item/camera/siliconcam/proc/injectmasteralbum(datum/picture/P) //stores image information to a list similar to that of the datacore
	var/mob/living/silicon/robot/C = src.loc
	if(C.connected_ai)
		var/mob/A = P.fields["author"]
		C.connected_ai.aiCamera.injectaialbum(P, " (taken by [A.name])")
		to_chat(C.connected_ai, "<span class='unconscious'>Image recorded and saved by [name]</span>")
		to_chat(usr, "<span class='unconscious'>Image recorded and saved to remote database</span>")//feedback to the Cyborg player that the picture was taken

	else
		injectaialbum(P)
		to_chat(usr, "<span class='unconscious'>Image recorded</span>")

/obj/item/camera/siliconcam/proc/selectpicture(obj/item/camera/siliconcam/cam)
	if(!cam)
		cam = getsource()

	var/list/nametemp = list()
	var/find
	if(length(cam.aipictures) == 0)
		to_chat(usr, "<span class='userdanger'>No images saved</span>")
		return
	for(var/datum/picture/t in cam.aipictures)
		nametemp += t.fields["name"]
	find = tgui_input_list(usr, "Select image (numbered in order taken)", "Pick Image", nametemp)

	for(var/datum/picture/q in cam.aipictures)
		if(q.fields["name"] == find)
			return q

/obj/item/camera/siliconcam/proc/viewpictures()
	var/datum/picture/selection = selectpicture()

	if(!selection)
		return

	var/obj/item/photo/P = new /obj/item/photo()
	P.construct(selection)
	P.show(usr)
	if(P.desc)
		to_chat(usr, P.desc, MESSAGE_TYPE_INFO)

	// TG uses a special garbage collector.. qdel(P)
	qdel(P) //so 10 thousand pictures items are not left in memory should an AI take them and then view them all.

/obj/item/camera/siliconcam/proc/deletepicture(obj/item/camera/siliconcam/cam)
	var/datum/picture/selection = selectpicture(cam)

	if(!selection)
		return

	cam.aipictures -= selection
	to_chat(usr, "<span class='unconscious'>Image deleted</span>")

/obj/item/camera/siliconcam/ai_camera/can_capture_turf(turf/T, mob/user)
	var/mob/living/silicon/ai = user
	return ai.TurfAdjacent(T)

/obj/item/camera/siliconcam/proc/toggle_camera_mode()
	if(in_camera_mode)
		camera_mode_off()
	else
		camera_mode_on()

/obj/item/camera/siliconcam/proc/camera_mode_off()
	src.in_camera_mode = 0
	to_chat(usr, "<B>Camera Mode deactivated</B>")

/obj/item/camera/siliconcam/proc/camera_mode_on()
	src.in_camera_mode = 1
	to_chat(usr, "<B>Camera Mode activated</B>")

/obj/item/camera/siliconcam/ai_camera/printpicture(mob/user, datum/picture/P)
	injectaialbum(P)
	to_chat(usr, "<span class='unconscious'>Image recorded</span>")

/obj/item/camera/siliconcam/robot_camera/printpicture(mob/user, datum/picture/P)
	injectmasteralbum(P)

/obj/item/camera/siliconcam/ai_camera/verb/take_image()
	set category = "AI Commands"
	set name = "Take Image"
	set desc = "Takes an image"

	toggle_camera_mode()

/obj/item/camera/siliconcam/ai_camera/verb/change_lens()
	set category = "AI Commands"
	set name = "Set Photo Focus"
	set desc = "Changes the lens size of your photo camera"

	change_size()

/obj/item/camera/siliconcam/ai_camera/verb/view_images()
	set category = "AI Commands"
	set name = "View Images"
	set desc = "View images"

	viewpictures()

/obj/item/camera/siliconcam/ai_camera/verb/delete_images()
	set category = "AI Commands"
	set name = "Delete Image"
	set desc = "Delete image"

	deletepicture(src)

/obj/item/camera/siliconcam/robot_camera/verb/take_image()
	set category ="Robot Commands"
	set name = "Take Image"
	set desc = "Takes an image"

	toggle_camera_mode()

/obj/item/camera/siliconcam/robot_camera/verb/change_lens()
	set category = "Robot Commands"
	set name = "Set Photo Focus"
	set desc = "Changes the lens size of your photo camera"

	change_size()

/obj/item/camera/siliconcam/robot_camera/verb/view_images()
	set category ="Robot Commands"
	set name = "View Images"
	set desc = "View images"

	viewpictures()

/obj/item/camera/siliconcam/robot_camera/verb/delete_images()
	set category = "Robot Commands"
	set name = "Delete Image"
	set desc = "Delete a local image"

	// Explicitly only allow deletion from the local camera
	deletepicture(src)

/obj/item/camera/siliconcam/proc/getsource()
	if(is_ai(loc))
		return src

	var/mob/living/silicon/robot/C = loc
	var/obj/item/camera/siliconcam/Cinfo
	if(C.connected_ai)
		Cinfo = C.connected_ai.aiCamera
	else
		Cinfo = src
	return Cinfo
