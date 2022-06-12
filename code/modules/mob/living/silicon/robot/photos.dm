/mob/living/silicon/robot/proc/photosync()
	var/obj/item/camera/siliconcam/master_cam = connected_ai ? connected_ai.aiCamera : null
	if(!master_cam)
		return

	var/syncedr
	syncedr = 0
	for(var/datum/picture/z in aiCamera.aipictures)
		if(!(master_cam.aipictures.Find(z)))
			aiCamera.printpicture(null, z)
			syncedr = 1
	if(syncedr)
		to_chat(src, "<span class='notice'>Locally saved images synced with AI. Images were retained in local database in case of loss of connection with the AI.</span>")
