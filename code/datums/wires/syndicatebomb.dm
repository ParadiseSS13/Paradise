/datum/wires/syndicatebomb
	randomize = TRUE
	holder_type = /obj/machinery/syndicatebomb
	wire_count = 5
	proper_name = "Syndicate bomb"
	window_x = 320
	window_y = 22

/datum/wires/syndicatebomb/New(atom/_holder)
	wires = list(WIRE_BOMB_DELAY, WIRE_EXPLODE, WIRE_BOMB_UNBOLT,WIRE_BOMB_PROCEED, WIRE_BOMB_ACTIVATE)
	return ..()

/datum/wires/syndicatebomb/interactable(mob/user)
	var/obj/machinery/syndicatebomb/P = holder
	if(P.open_panel)
		return TRUE
	return FALSE

/datum/wires/syndicatebomb/on_pulse(wire)
	var/obj/machinery/syndicatebomb/B = holder
	switch(wire)
		if(WIRE_EXPLODE)
			if(B.active)
				holder.visible_message("<span class='danger'>[bicon(B)] An alarm sounds! It's go-</span>")
				B.explode_now = TRUE
		if(WIRE_BOMB_UNBOLT)
			holder.visible_message("<span class='notice'>[bicon(holder)] The bolts spin in place for a moment.</span>")
		if(WIRE_BOMB_DELAY)
			if(B.delayedbig)
				holder.visible_message("<span class='notice'>[bicon(B)] The bomb has already been delayed.</span>")
			else
				holder.visible_message("<span class='notice'>[bicon(B)] The bomb chirps.</span>")
				playsound(B, 'sound/machines/chime.ogg', 30, 1)
				B.detonation_timer += 300
				B.delayedbig = TRUE
		if(WIRE_BOMB_PROCEED)
			holder.visible_message("<span class='danger'>[bicon(B)] The bomb buzzes ominously!</span>")
			playsound(B, 'sound/machines/buzz-sigh.ogg', 30, 1)
			var/seconds = B.seconds_remaining()
			if(seconds >= 61) // Long fuse bombs can suddenly become more dangerous if you tinker with them.
				B.detonation_timer = world.time + 600
			else if(seconds >= 21)
				B.detonation_timer -= 100
			else if(seconds >= 11) // Both to prevent negative timers and to have a little mercy.
				B.detonation_timer = world.time + 100
		if(WIRE_BOMB_ACTIVATE)
			if(!B.active && !B.defused)
				holder.visible_message("<span class='danger'>[bicon(B)] You hear the bomb start ticking!</span>")
				B.activate()
				B.update_icon()
			else if(B.delayedlittle)
				holder.visible_message("<span class='notice'>[bicon(B)] Nothing happens.</span>")
			else
				holder.visible_message("<span class='notice'>[bicon(B)] The bomb seems to hesitate for a moment.</span>")
				B.detonation_timer += 100
				B.delayedlittle = TRUE
	..()

/datum/wires/syndicatebomb/on_cut(wire, mend)
	var/obj/machinery/syndicatebomb/B = holder
	switch(wire)
		if(WIRE_EXPLODE)
			if(mend)
				B.defused = FALSE // Cutting and mending all the wires of an inactive bomb will thus cure any sabotage.
			else
				if(B.active)
					holder.visible_message("<span class='danger'>[bicon(B)] An alarm sounds! It's go-</span>")
					B.explode_now = TRUE
				else
					B.defused = TRUE
		if(WIRE_BOMB_UNBOLT)
			if(!mend && B.anchored)
				holder.visible_message("<span class='notice'>[bicon(B)] The bolts lift out of the ground!</span>")
				playsound(B, 'sound/effects/stealthoff.ogg', 30, 1)
				B.anchored = FALSE
		if(WIRE_BOMB_PROCEED)
			if(!mend && B.active)
				holder.visible_message("<span class='danger'>[bicon(B)] An alarm sounds! It's go-</span>")
				B.explode_now = TRUE
		if(WIRE_BOMB_ACTIVATE)
			if(!mend && B.active)
				holder.visible_message("<span class='notice'>[bicon(B)] The timer stops! The bomb has been defused!</span>")
				B.defused = TRUE
				B.update_icon()
	..()
