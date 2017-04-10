/obj/item/device/assembly/voice
	name = "voice analyzer"
	desc = "A small electronic device able to record a voice sample, and send a signal when that sample is repeated."
	icon_state = "voice"
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	origin_tech = "magnets=1"
	var/listening = 0
	var/recorded = null	//the activation message
	var/recorded_type = 0 // 0 for say, 1 for emote

	bomb_name = "voice-activated bomb"

	describe()
		if(recorded || listening)
			return "A meter on [src] flickers with every nearby sound."
		else
			return "[src] is deactivated."

	hear_talk(mob/living/M as mob, msg)
		hear_input(M, msg, 0)
	
	hear_message(mob/living/M as mob, msg)
		hear_input(M, msg, 1)
		
	proc/hear_input(mob/living/M as mob, msg, type)
		if(!istype(M,/mob/living))
			return
		if(listening)
			recorded = msg
			recorded_type = type
			listening = 0
			var/turf/T = get_turf(src)	//otherwise it won't work in hand
			T.visible_message("[bicon(src)] beeps, \"Activation message is [type ? "the sound when one [recorded]" : "'[recorded]'."]\"")
		else
			if(findtext(msg, recorded) && type == recorded_type)
				pulse(0)
				var/turf/T = get_turf(src)  //otherwise it won't work in hand
				T.visible_message("[bicon(src)] \red beeps!")

	activate()
		return // previously this toggled listning when not in a holder, that's a little silly.  It was only called in attack_self that way.


	attack_self(mob/user)
		if(!user || !secured)	return 0

		listening = !listening
		var/turf/T = get_turf(src)
		T.visible_message("[bicon(src)] beeps, \"[listening ? "Now" : "No longer"] recording input.\"")
		return 1


	toggle_secure()
		. = ..()
		listening = 0