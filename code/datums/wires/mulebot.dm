/datum/wires/mulebot
	random = 1
	holder_type = /mob/living/simple_animal/bot/mulebot
	wire_count = 10
	window_x = 410

#define MULEBOT_WIRE_POWER1 1			// power connections
#define MULEBOT_WIRE_POWER2 2
#define MULEBOT_WIRE_AVOIDANCE 4		// mob avoidance
#define MULEBOT_WIRE_LOADCHECK 8		// load checking (non-crate)
#define MULEBOT_WIRE_MOTOR1 16		// motor wires
#define MULEBOT_WIRE_MOTOR2 32		//
#define MULEBOT_WIRE_REMOTE_RX 64		// remote recv functions
#define MULEBOT_WIRE_REMOTE_TX 128	// remote trans status
#define MULEBOT_WIRE_BEACON_RX 256	// beacon ping recv

/datum/wires/mulebot/GetWireName(index)
	switch(index)
		if(MULEBOT_WIRE_POWER1)
			return "Primary Power"
		
		if(MULEBOT_WIRE_POWER2)
			return "Secondary Power"
		
		if(MULEBOT_WIRE_AVOIDANCE)
			return "Mob Avoidance"
			
		if(MULEBOT_WIRE_LOADCHECK)
			return "Load Checking"
		
		if(MULEBOT_WIRE_MOTOR1)
			return "Primary Motor"
		
		if(MULEBOT_WIRE_MOTOR2)
			return "Secondary Motor"
			
		if(MULEBOT_WIRE_REMOTE_RX)
			return "Remote Signal Receiver"

		if(MULEBOT_WIRE_REMOTE_TX)
			return "Remote Signal Sender"

		if(MULEBOT_WIRE_BEACON_RX)
			return "Navigation Beacon Receiver"		

/datum/wires/mulebot/CanUse(mob/living/L)
	var/mob/living/simple_animal/bot/mulebot/M = holder
	if(M.open)
		return 1
	return 0

/datum/wires/mulebot/UpdatePulsed(index)
	switch(index)
		if(MULEBOT_WIRE_POWER1, MULEBOT_WIRE_POWER2)
			holder.visible_message("<span class='notice'>[bicon(holder)] The charge light flickers.</span>")
		if(MULEBOT_WIRE_AVOIDANCE)
			holder.visible_message("<span class='notice'>[bicon(holder)] The external warning lights flash briefly.</span>")
		if(MULEBOT_WIRE_LOADCHECK)
			holder.visible_message("<span class='notice'>[bicon(holder)] The load platform clunks.</span>")
		if(MULEBOT_WIRE_MOTOR1, MULEBOT_WIRE_MOTOR2)
			holder.visible_message("<span class='notice'>[bicon(holder)] The drive motor whines briefly.</span>")
		else
			holder.visible_message("<span class='notice'>[bicon(holder)] You hear a radio crackle.</span>")
	..()

// HELPER PROCS

/datum/wires/mulebot/proc/Motor1()
	return !(wires_status & MULEBOT_WIRE_MOTOR1)

/datum/wires/mulebot/proc/Motor2()
	return !(wires_status & MULEBOT_WIRE_MOTOR2)

/datum/wires/mulebot/proc/HasPower()
	return !(wires_status & MULEBOT_WIRE_POWER1) && !(wires_status & MULEBOT_WIRE_POWER2)

/datum/wires/mulebot/proc/LoadCheck()
	return !(wires_status & MULEBOT_WIRE_LOADCHECK)

/datum/wires/mulebot/proc/MobAvoid()
	return !(wires_status & MULEBOT_WIRE_AVOIDANCE)

/datum/wires/mulebot/proc/RemoteTX()
	return !(wires_status & MULEBOT_WIRE_REMOTE_TX)

/datum/wires/mulebot/proc/RemoteRX()
	return !(wires_status & MULEBOT_WIRE_REMOTE_RX)

/datum/wires/mulebot/proc/BeaconRX()
	return !(wires_status & MULEBOT_WIRE_BEACON_RX)
