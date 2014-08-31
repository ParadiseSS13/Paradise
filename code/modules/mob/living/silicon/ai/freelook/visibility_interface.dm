/datum/visibility_interface/ai_eye
	chunk_type = /datum/visibility_chunk/camera
	
/datum/visibility_interface/ai_eye/getClient()
	var/mob/aiEye/eye = controller
	if (!eye)
		return FALSE
	if (!eye.ai)
		return FALSE
	return eye.ai.client
