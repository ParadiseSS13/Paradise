/datum/wires/mulebot
	randomize = TRUE
	holder_type = /mob/living/simple_animal/bot/mulebot
	wire_count = 10
	proper_name = "Mulebot"

/datum/wires/mulebot/New(atom/_holder)
	wires = list(
		WIRE_MAIN_POWER1, WIRE_MAIN_POWER2, WIRE_MOB_AVOIDANCE,
		WIRE_LOADCHECK, WIRE_MOTOR1, WIRE_MOTOR2,
		WIRE_REMOTE_RX, WIRE_REMOTE_TX, WIRE_BEACON_RX
	)
	return ..()

/datum/wires/mulebot/interactable(mob/user)
	var/mob/living/simple_animal/bot/mulebot/M = holder
	if(M.open)
		return TRUE
	return FALSE

/datum/wires/mulebot/on_pulse(wire)
	switch(wire)
		if(WIRE_MAIN_POWER1, WIRE_MAIN_POWER2)
			holder.visible_message("<span class='notice'>[bicon(holder)] The charge light flickers.</span>")
		if(WIRE_MOB_AVOIDANCE)
			holder.visible_message("<span class='notice'>[bicon(holder)] The external warning lights flash briefly.</span>")
		if(WIRE_LOADCHECK)
			holder.visible_message("<span class='notice'>[bicon(holder)] The load platform clunks.</span>")
		if(WIRE_MOTOR1, WIRE_MOTOR2)
			holder.visible_message("<span class='notice'>[bicon(holder)] The drive motor whines briefly.</span>")
		else
			holder.visible_message("<span class='notice'>[bicon(holder)] You hear a radio crackle.</span>")
	..()
