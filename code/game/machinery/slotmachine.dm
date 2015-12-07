var/datum/announcement/minor/slotmachine_announcement = new(do_log = 0)
/obj/machinery/slot_machine
	name = "slot machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/objects.dmi'
	icon_state = "slots-off"
	anchored = 1
	density = 1
//	mats = 10
	var/money = 25000
	var/plays = 0
	var/working = 0
	var/balance=0

	attack_hand(var/mob/user as mob)
		if(user.mind)
			if(user.mind.initial_account)
				balance = user.mind.initial_account.money
		user.machine = src
		if (src.working)
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			<B>Please wait!</B><BR>"}
			user << browse(dat, "window=slotmachine;size=450x500")
			onclose(user, "slotmachine")
		else
			var/dat = {"<B>Slot Machine</B><BR>
			<HR><BR>
			Five credits to play!<BR>
			<B>Prize Money Available:</B> [src.money]<BR>
			<B>Credits Remaining:</B> [balance]<BR>
			[src.plays] players have tried their luck today!<BR>
			<HR><BR>
			<A href='?src=\ref[src];ops=1'>Play!<BR>"}
			user << browse(dat, "window=slotmachine;size=400x500")
			onclose(user, "slotmachine")

	Topic(href, href_list)
		if(href_list["ops"])
			var/operation = text2num(href_list["ops"])
			if(operation == 1) // Play
/*				if (src.working == 1)
					usr << "\red You need to wait until the machine stops spinning!"
					return */
				if (balance < 5)
					usr << "\red Insufficient money to play!"
					return
				usr.mind.initial_account.money -= 5
				src.money += 5
				src.plays += 1
				src.working = 1
				src.icon_state = "slots-on"
				usr << "Let's roll!"
				var/roll = rand(1,10000)
				spawn(100)
					if (roll == 1)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<b>[]</b> says, 'JACKPOT! You win [src.money]!'", src), 1)
						slotmachine_announcement.Announce("Congratulations [usr.name] on winning the Jackpot!", "Jackpot Winner")
						usr.mind.initial_account.money += src.money
						src.money = 0
					else if (roll > 1 && roll <= 10)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<b>[]</b> says, 'Big Winner! You win five thousand credits!'", src), 1)
						usr.mind.initial_account.money += 5000
						src.money -= 5000
					else if (roll > 10 && roll <= 100)
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<b>[]</b> says, 'Winner! You win five hundred credits!'", src), 1)
						usr.mind.initial_account.money += 500
						src.money -= 500
					else if (roll > 100 && roll <= 1000)
						usr << "\blue You win a free game!"
						usr.mind.initial_account.money += 5
						src.money -= 5
					else
						usr << "\red No luck!"
					src.working = 0
					src.icon_state = "slots-off"
		src.add_fingerprint(usr)
		src.updateUsrDialog()
		return
