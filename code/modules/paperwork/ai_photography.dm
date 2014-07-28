/**************
* AI-specific *
**************/
/datum/picture
	var/name = "image"
	var/list/fields = list()

obj/item/device/camera/ai_camera //camera AI can take pictures with
	name = "AI photo camera"
	var/in_camera_mode = 0
	var/list/aipictures = list()

/obj/item/device/camera/ai_camera/proc/injectaialbum(var/icon, var/img, var/desc, var/pixel_x, var/pixel_y) //stores image information to a list similar to that of the datacore
	var/numberer = 1
	for(var/datum/picture in src.aipictures)
		numberer++
	var/datum/picture/P = new()
	P.fields["name"] = "Image [numberer]"
	P.fields["icon"] = icon
	P.fields["img"] = img
	P.fields["desc"] = desc
	P.fields["pixel_x"] = pixel_x
	P.fields["pixel_y"] = pixel_y

	aipictures += P
	usr << "<FONT COLOR=blue><B>Image recorded</B>"

/obj/item/device/camera/ai_camera/proc/viewpictures()
	var/list/nametemp = list()
	var/find
	var/datum/picture/selection
	if(src.aipictures.len == 0)
		usr << "<FONT COLOR=red><B>No images saved</B>"
		return
	for(var/datum/picture/t in src.aipictures)
		nametemp += t.fields["name"]
	find = input("Select image (numbered in order taken)") in nametemp
	var/obj/item/weapon/photo/P = new/obj/item/weapon/photo()
	for(var/datum/picture/q in src.aipictures)
		if(q.fields["name"] == find)
			selection = q
			break
	P.icon = selection.fields["icon"]
	P.img = selection.fields["img"]
	P.desc = selection.fields["desc"]
	P.pixel_x = selection.fields["pixel_x"]
	P.pixel_y = selection.fields["pixel_y"]

	P.show(usr)
	usr << P.desc

	// TG uses a special garbage collector.. qdel(P)
	del(P)    //so 10 thousand pictures items are not left in memory should an AI take them and then view them all.

/obj/item/device/camera/ai_camera/printpicture(mob/user, icon/temp, mobs, flag)
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	var/icon = ic
	var/img = temp
	var/desc = mobs
	var/pixel_x = rand(-10, 10)
	var/pixel_y = rand(-10, 10)

	injectaialbum(icon, img, desc, pixel_x, pixel_y)

/obj/item/device/camera/ai_camera/can_capture_turf(turf/T, mob/user)
	var/mob/living/silicon/ai = user
	return ai.TurfAdjacent(T)

/obj/item/device/camera/ai_camera/proc/toggle_camera_mode()
	if(in_camera_mode)
		camera_mode_off()
	else
		camera_mode_on()

/obj/item/device/camera/ai_camera/proc/camera_mode_off()
	src.in_camera_mode = 0
	usr << "<B>Camera Mode deactivated</B>"

/obj/item/device/camera/ai_camera/proc/camera_mode_on()
	src.in_camera_mode = 1
	usr << "<B>Camera Mode activated</B>"

/mob/living/silicon/ai/proc/ai_take_image()
	set category = "AI Commands"
	set name = "Take Image"
	set desc = "Takes an image"
	aicamera.toggle_camera_mode()

/mob/living/silicon/ai/proc/ai_view_images()
	set category = "AI Commands"
	set name = "View Images"
	set desc = "View images"
	aicamera.viewpictures()