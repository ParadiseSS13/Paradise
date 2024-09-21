/obj/machinery/power/transmission_laser/proc/send_ptl_announcement()
	/// The message we send
	var/message
	var/flavor_text
	if(announcement_treshold == 1 MW)
		message = "PTL account successfully made"
		flavor_text = "From now on, you will receive regular updates on the power exported via the onboard PTL. Good luck [station_name()]!"
		INVOKE_ASYNC(src, PROC_REF(send_regular_ptl_announcement)) // starts giving the station regular updates on the PTL since our station just got an account

	message = "New milestone reached!\n[message]"

	priority_announce(
		sender_override = "[command_name()] energy unit",
		title = "Power Transmission Laser report",
		text = "[message]\n[flavor_text]",
		color_override = "orange",
	)

	announcement_treshold *= 1000


/obj/machinery/power/transmission_laser/proc/send_regular_ptl_announcement()
	sleep(30 MINUTES) // simple loop, we are called once and then repeat ourselfes forever
	INVOKE_ASYNC(src, PROC_REF(send_regular_ptl_announcement))

	// the total_energy variable converted into readable amounts of energy, because 100.000.000.000.000 was for some reason hard to read
	var/readable_energy

	switch(total_energy)
		if(1 MJ to (1 GJ) - 1)
			readable_energy = "[total_energy / (1 MJ)] Megajoules"

		if(1 GJ to (1 TJ) - 1)
			readable_energy = "[total_energy / (1 GJ)] Gigajoules"

		if(1 TJ to (1 PJ) - 1)
			readable_energy = "[total_energy / (1 TJ)] Terajoules"

		if(1 PJ to (1 EJ) - 1)
			readable_energy = "[total_energy / (1 PJ)] Petajoules"

		if(1 EJ to INFINITY)
			readable_energy = "[total_energy / (1 EJ)] Exojoules"

	priority_announce(
		sender_override = "[command_name()] energy unit",
		title = "Regular Power Transmission Laser report",
		text = "Total power exported via the PTL: [readable_energy]\n\
				Total earnings: [total_earnings] credits",
		color_override = "orange",
	)
