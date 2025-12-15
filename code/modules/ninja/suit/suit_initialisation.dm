
//Verbs link to procs because verb-like procs have a bug which prevents their use if the arguments are not readily referenced.
//^ Old coder words may be false these days, Not taking the risk for now.

/obj/item/clothing/suit/space/space_ninja/verb/toggle_suit()
	set category = "Space Ninja - Equipment"
	set name = "Toggle Suit"

	if(usr.mind.special_role == "Ninja")
		if(suitBusy)
			to_chat(usr, "<span style='color: #ff0000;'><b>ERROR: </b>Suit systems busy, cannot initiate [suitActive ? "de-activation" : "activation"] protocols at this time.</span>")
			return

		suitBusy = 1

		if(suitActive && (tgui_alert(usr, "Confirm suit systems shutdown? This cannot be halted once it has started.", "Confirm Shutdown", list("Yes", "No")) == "Yes"))
			to_chat(usr, SPAN_DARKMBLUE("Now de-initializing..."))

			sleep(15)
			to_chat(usr, SPAN_DARKMBLUE("Logging off, [usr.real_name]. Shutting down <b>SpiderOS</b>."))

			sleep(10)
			to_chat(usr, SPAN_DARKMBLUE("Primary system status: <B>OFFLINE</B>.\nBackup system status: <b>OFFLINE</b>."))

			sleep(5)
			to_chat(usr, SPAN_DARKMBLUE("VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>."))
			//TODO: Shut down any active abilities

			sleep(10)
			to_chat(usr, SPAN_DARKMBLUE("Disconnecting neural-net interface...</span> <span style='color: #32CD32'><b>Success</b>."))

			QDEL_NULL(usr.hud_used)
			usr.create_mob_hud()
			usr.regenerate_icons()

			sleep(5)
			to_chat(usr, SPAN_DARKMBLUE("Disengaging neural-net interface...</span> <span style='color: #32CD32'><b>Success</b>."))

			sleep(10)
			to_chat(usr, SPAN_DARKMBLUE("Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>."))
			//TODO: Grant verbs
			toggle_suit_lock(usr)
			usr.regenerate_icons()
			suitBusy = 0
			suitActive = 0

		else if(!suitActive) // Activate the suit.
			to_chat(usr, SPAN_DARKMBLUE("Now initializing..."))

			sleep(15)
			to_chat(usr, "<span class='darkmblue'>Now establishing neural-net interface...")
			if(usr.mind.special_role != "Ninja")
				to_chat(usr, "<span style='color: #ff0000;'><b>FĆAL �Rr�R</b>: ŧer nt recgnized, c-cntr-r䣧-ç äcked.")
				return

			sleep(10)
			to_chat(usr, SPAN_DARKMBLUE("Neural-net established. Now monitoring brainwave pattern. \nBrainwave pattern</span> <span style='color: #32CD32;'><b>GREEN</b></span><span class='darkmblue'>, proceeding."))

			sleep(10)
			to_chat(usr, SPAN_DARKMBLUE("Securing external locking mechanism..."))
			if(!toggle_suit_lock(usr))
				return

			sleep(5)
			to_chat(usr, SPAN_DARKMBLUE("Suit secured, extending neural-net interface..."))

			QDEL_NULL(usr.hud_used)
			usr.hud_used = new /datum/hud/human(usr, 'icons/mob/screen_ninja.dmi', "#ffffff", 255)
			if(usr.hud_used)
				usr.hud_used.show_hud(usr.hud_used.hud_version)
			usr.regenerate_icons()

			sleep(10)
			to_chat(usr, SPAN_DARKMBLUE("VOID-shift device status: <b>ONLINE</b>.\nCLOAK-tech device status:<b>ONLINE</b>"))

			sleep(5)
			to_chat(usr, SPAN_DARKMBLUE("Primary system status: <b>ONLINE</b>.\nBackup system status: <b>ONLINE</b>."))
			if(suitCell)
				to_chat(usr, SPAN_DARKMBLUE("Current energy capacity: <b>[suitCell.charge]/[suitCell.maxcharge]</b>."))

			sleep(10)
			to_chat(usr, SPAN_DARKMBLUE("All systems operational. Welcome to <b>SpiderOS</b>, [usr.real_name]."))
			//TODO: Grant ninja verbs here.
			suitBusy = 0
			suitActive = 1

		else
			suitBusy = 0
			to_chat(usr, SPAN_DARKMBLUE("<b>NOTICE: </b>Suit de-activation protocols aborted."))
	else
		to_chat(usr, "<span style='color: #ff0000;'><b>FĆAL �Rr�R</b>: ŧer nt recgnized, c-cntr-r䣧-ç äcked.")
		return
