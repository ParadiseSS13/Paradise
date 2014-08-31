/obj/machinery/computer3/laptop/vended
	default_prog = /datum/file/program/welcome


/datum/file/program/welcome
	name 		= "Welcome Screen"
	desc 		= "First time boot splash screen"
	active_state = "osod"
	image			= 'icons/ntos/program.png'


	interact()
		usr.set_machine(src)
		if(!interactable())
			return
		var/dat = ""
		dat += "<center><span style='font-size:24pt'><b>Welcome to NTOS</b></span></center>"
		dat += "<center><span style='font-size:8pt'>Thank you for choosing NTOS, your gateway to the future of mobile computing technology, sponsored by Nanotrasen (R)</span></center><br>"
		dat += "<span style='font-size:12pt'><b>Getting started with NTOS:</b></span><br>"
		dat += "To leave a current program, click the X button in the top right corner of the window. This will return you to the NTOS desktop. \
		From the desktop, you can open the hard drive, usually located in the top left corner to access all the programs installed on your computer. \
		When you rented your laptop, you were supplied with programs that your Nanotrasen Issued ID has given you access to use. \
		In the event of a serious error, the right click menu will give you the ability to reset your computer. To open and close your laptop, alt-click your device.\
		 If you have any questions or technical issues, please contact your local computer technical experts at your local Central Command."
		popup.set_content(dat)
		popup.set_title_image(usr.browse_rsc_icon(computer.icon, computer.icon_state))
		popup.open()
		return

	Topic(href, href_list)
		if(!interactable() || ..(href,href_list))
			return
		interact()
		return