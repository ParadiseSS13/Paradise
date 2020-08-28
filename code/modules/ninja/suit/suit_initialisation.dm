
//Verbs link to procs because verb-like procs have a bug which prevents their use if the arguments are not readily referenced.
//^ Old coder words may be false these days, Not taking the risk for now.

/obj/item/clothing/suit/space/space_ninja/verb/toggle_suit()
	set category = "Space Ninja - Equipment"
	set name = "Toggle Suit"

	if(usr.mind.special_role == "Ninja")
		if(suitBusy)
			to_chat(usr, "<span style='color: #ff0000;'><b>ERROR: </b>Suit systems busy, cannot initiate [suitActive ? "de-activation" : "activation"] protocals at this time.</span>")
			return

		suitBusy = 1

		if(suitActive && (alert("Confirm suit systems shutdown? This cannot be halted once it has started.", "Confirm Shutdown", "Yes", "No") == "Yes"))
			to_chat(usr, "<span style='color: #0000ff;'>Now de-initializing...</span>")

			sleep(15)
			to_chat(usr, "<span style='color: #0000ff;'>Logging off, [usr.real_name]. Shutting down <b>SpiderOS</b>.</span>")

			sleep(10)
			to_chat(usr, "<span style='color: #0000ff;'>Primary system status: <B>OFFLINE</B>.\nBackup system status: <b>OFFLINE</b>.</span>")

			sleep(5)
			to_chat(usr, "<span style='color: #0000ff;'>VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>.</span>")
			//TODO: Shut down any active abilities

			sleep(10)
			to_chat(usr, "<span style='color: #0000ff;'>Disconnecting neural-net interface...</span> <span style='color: #32CD32'><b>Success</b>.</span>")

			QDEL_NULL(usr.hud_used)
			usr.create_mob_hud()
			usr.regenerate_icons()

			sleep(5)
			to_chat(usr, "<span style='color: #0000ff;'>Disengaging neural-net interface...</span> <span style='color: #32CD32'><b>Success</b>.</span>")

			sleep(10)
			to_chat(usr, "<span style='color: #0000ff;'>Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>.</span>")
			//TODO: Grant verbs
			toggle_suit_lock(usr)
			usr.regenerate_icons()
			suitBusy = 0
			suitActive = 0

		else if(!suitActive) // Activate the suit.
			to_chat(usr, "<span style='color: #0000ff;'>Now initializing...</span>")

			sleep(15)
			to_chat(usr, "<span style='color: #0000ff;'>Now establishing neural-net interface...")
			if(usr.mind.special_role != "Ninja")
				to_chat(usr, "<span style='color: #ff0000;'><b>FĆAL �Rr�R</b>: ŧer nt recgnized, c-cntr-r䣧-ç äcked.")
				return

			sleep(10)
			to_chat(usr, "<span style='color: #0000ff;'>Neural-net established. Now monitoring brainwave pattern. \nBrainwave pattern</span> <span style='color: #32CD32;'><b>GREEN</b></span><span style='color: #0000ff;'>, proceeding.</span>")

			sleep(10)
			to_chat(usr, "<span style='color: #0000ff;'>Securing external locking mechanism...</span>")
			if(!toggle_suit_lock(usr))
				return

			sleep(5)
			to_chat(usr, "<span style='color: #0000ff;'>Suit secured, extending neural-net interface...</span>")

			QDEL_NULL(usr.hud_used)
			usr.hud_used = new /datum/hud/human(usr, 'icons/mob/screen_ninja.dmi', "#ffffff", 255)
			if(usr.hud_used)
				usr.hud_used.show_hud(usr.hud_used.hud_version)
			usr.regenerate_icons()

			sleep(10)
			to_chat(usr, "<span style='color: #0000ff;'>VOID-shift device status: <b>ONLINE</b>.\nCLOAK-tech device status:<b>ONLINE</b></span>")

			sleep(5)
			to_chat(usr, "<span style='color: #0000ff;'>Primary system status: <b>ONLINE</b>.\nBackup system status: <b>ONLINE</b>.</span>")
			if(suitCell)
				to_chat(usr, "<span style='color: #0000ff;'>Current energy capacity: <b>[suitCell.charge]/[suitCell.maxcharge]</b>.</span>")

			sleep(10)
			to_chat(usr, "<span style='color: #0000ff;'>All systems operational. Welcome to <b>SpiderOS</b>, [usr.real_name].</span>")
			//TODO: Grant ninja verbs here.
			suitBusy = 0
			suitActive = 1

		else
			suitBusy = 0
			to_chat(usr, "<span style='color: #0000ff;'><b>NOTICE: </b>Suit de-activation protocals aborted.</span>")
	else
		to_chat(usr, "<span style='color: #ff0000;'><b>FĆAL �Rr�R</b>: ŧer nt recgnized, c-cntr-r䣧-ç äcked.")
		return
