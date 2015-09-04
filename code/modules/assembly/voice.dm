/obj/item/device/assembly/voice
	name = "voice analyzer"
	desc = "A small electronic device able to record a voice sample, and send a signal when that sample is repeated."
	icon_state = "voice"
	materials = list(MAT_METAL=500, MAT_GLASS=50)
	origin_tech = "magnets=1"
	var/listening = 0
	var/recorded = null	//the activation message

	bomb_name = "voice-activated bomb"

	describe()
		if(recorded || listening)
			return "A meter on [src] flickers with every nearby sound."
		else
			return "[src] is deactivated."

	hear_talk(mob/living/M as mob, msg)
		if(!istype(M,/mob/living))
			return
		if(listening)
			recorded = msg
			listening = 0
			var/turf/T = get_turf(src)	//otherwise it won't work in hand
			T.visible_message("\icon[src] beeps, \"Activation message is '[recorded]'.\"")
		else
			if(findtext(msg, recorded))
				pulse(0)
				var/turf/T = get_turf(src)  //otherwise it won't work in hand
				T.visible_message("\icon[src] \red beeps!")

	activate()
		return // previously this toggled listning when not in a holder, that's a little silly.  It was only called in attack_self that way.


	attack_self(mob/user)
		if(!user || !secured)	return 0

		listening = !listening
		var/turf/T = get_turf(src)
		T.visible_message("\icon[src] beeps, \"[listening ? "Now" : "No longer"] recording input.\"")
		return 1


	toggle_secure()
		. = ..()
		listening = 0