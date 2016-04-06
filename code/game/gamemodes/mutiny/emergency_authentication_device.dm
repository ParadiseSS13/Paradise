/obj/machinery/emergency_authentication_device
	var/datum/game_mode/mutiny/mode

	name = "\improper Emergency Authentication Device"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	density = 1
	anchored = 1

	var/captains_key
	var/secondary_key
	var/activated = 0

	use_power = 0

	New(loc, mode)
		src.mode = mode
		..(loc)

	proc/check_key_existence()
		if(!mode.captains_key)
			captains_key = 1

		if(!mode.secondary_key)
			secondary_key = 1

	proc/get_status()
		if(activated)
			return "Activated"
		if(captains_key && secondary_key)
			return "Both Keys Authenticated"
		if(captains_key)
			return "Captain's Key Authenticated"
		if(secondary_key)
			return "Secondary Key Authenticated"
		else
			return "Inactive"

	proc/launch_shuttle()
		spawn(rand(5 SECONDS, 45 SECONDS))
			if(shuttle_master.requestEvac(usr, "Directive X"))
				spawn(20 SECONDS)
					var/text = "[station_name()], we have confirmed your completion of Directive X. An evacuation shuttle is en route to receive your crew for debriefing."
					command_announcement.Announce(text, "Emergency Transmission")

/obj/machinery/emergency_authentication_device/attack_hand(mob/user)
	if(activated)
		to_chat(user, "\blue \The [src] is already active!")
		return

	if(!mode.current_directive.directives_complete())
		state("Command aborted. Communication with CentComm is prohibited until Directive X has been completed.")
		return

	check_key_existence()
	if(captains_key && secondary_key)
		activated = 1
		to_chat(user, "\blue You activate \the [src]!")
		state("Command acknowledged. Initiating quantum entanglement relay to Nanotrasen High Command.")
		launch_shuttle()
		return

	if(!captains_key && !secondary_key)
		state("Command aborted. Please present the authentication keys before proceeding.")
		return

	if(!captains_key)
		state("Command aborted. Please present the Captain's Authentication Key.")
		return

	if(!secondary_key)
		state("Command aborted. Please present the Emergency Secondary Authentication Key.")
		return

	// Impossible!
	state("Command aborted. This unit is defective.")

/obj/machinery/emergency_authentication_device/attackby(obj/item/weapon/O, mob/user, params)
	if(activated)
		to_chat(user, "\blue \The [src] is already active!")
		return

	if(!mode.current_directive.directives_complete())
		state({"Command aborted. Communication with CentComm is prohibited until Directive X has been completed."})
		return

	check_key_existence()
	if(istype(O, /obj/item/weapon/mutiny/auth_key/captain) && !captains_key)
		captains_key = O
		user.drop_item()
		O.loc = src

		state("Key received. Thank you, Captain [mode.head_loyalist].")
		spawn(5)
			state(secondary_key ? "Your keys have been authenticated. Communication with CentComm is now authorized." : "Please insert the Emergency Secondary Authentication Key now.")
		return

	if(istype(O, /obj/item/weapon/mutiny/auth_key/secondary) && !secondary_key)
		secondary_key = O
		user.drop_item()
		O.loc = src

		state("Key received. Thank you, Secondary Authenticator [mode.head_mutineer].")
		spawn(5)
			state(captains_key ? "Your keys have been authenticated. Communication with CentComm is now authorized." : "Please insert the Captain's Authentication Key now.")
		return
	..()

/obj/machinery/emergency_authentication_device/examine(mob/user)
	to_chat(user, {"This is a specialized communications device that is able to instantly send a message to <b>Nanotrasen High Command</b> via quantum entanglement
	                with a sister device at CentComm.<br>
			        The EAD's status is [get_status()]."})
