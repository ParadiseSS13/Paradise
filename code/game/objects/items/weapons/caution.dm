/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = 2
	attack_verb = list("warned", "cautioned", "smashed")

	proximity_sign
		var/timing = 0
		var/armed = 0
		var/timepassed = 0

		attack_self(mob/user as mob)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(H.mind.assigned_role != "Janitor")
					return
				if(armed)
					armed = 0
					to_chat(user, "\blue You disarm \the [src].")
					return
				timing = !timing
				if(timing)
					processing_objects.Add(src)
				else
					armed = 0
					timepassed = 0
				to_chat(H, "\blue You [timing ? "activate \the [src]'s timer, you have 15 seconds." : "de-activate \the [src]'s timer."]")

		process()
			if(!timing)
				processing_objects.Remove(src)
			timepassed++
			if(timepassed >= 15 && !armed)
				armed = 1
				timing = 0

		HasProximity(atom/movable/AM as mob|obj)
			if(armed)
				if(istype(AM, /mob/living/carbon) && !istype(AM, /mob/living/carbon/brain))
					var/mob/living/carbon/C = AM
					if(C.m_intent != "walk")
						src.visible_message("The [src.name] beeps, \"Running on wet floors is hazardous to your health.\"")
						explosion(src.loc,-1,0,2)
						if(ishuman(C))
							dead_legs(C)
						if(src)
							qdel(src)

		proc/dead_legs(mob/living/carbon/human/H as mob)
			var/obj/item/organ/external/l = H.get_organ("l_leg")
			var/obj/item/organ/external/r = H.get_organ("r_leg")
			if(l && !(l.status & ORGAN_DESTROYED))
				l.status |= ORGAN_DESTROYED
			if(r && !(r.status & ORGAN_DESTROYED))
				r.status |= ORGAN_DESTROYED