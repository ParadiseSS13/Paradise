var/datum/announcement/minor/slotmachine_announcement = new(do_log = 0)

/obj/machinery/slot_machine
	name = "Slot Machine"
	desc = "Gambling for the antisocial."
	icon = 'icons/obj/objects.dmi'
	icon_state = "slots-off"
	anchored = 1
	density = 1
	var/plays = 0
	var/working = 0
	var/balance=0

/obj/machinery/slot_machine/attack_hand(var/mob/user as mob)
	if(user.mind)
		if(user.mind.initial_account)
			balance = user.mind.initial_account.money
	user.machine = src
	if (working)
		var/dat = {"<B>Slot Machine</B><BR>
		<HR><BR>
		<B>Please wait!</B><BR>"}
		user << browse(dat, "window=slotmachine;size=450x500")
		onclose(user, "slotmachine")
	else
		var/dat = {"<B>Slot Machine</B><BR>
		<HR><BR>
		Five credits to play!<BR>
		<B>Credits Remaining:</B> [balance]<BR>
		[plays] players have tried their luck today!<BR>
		<HR><BR>
		<A href='?src=\ref[src];ops=1'>Play!<BR>"}
		user << browse(dat, "window=slotmachine;size=400x500")
		onclose(user, "slotmachine")

/obj/machinery/slot_machine/Topic(href, href_list)
	if(href_list["ops"])
		var/operation = text2num(href_list["ops"])
		if(operation == 1) // Play
			if (working == 1)
				usr << "<span class='warning'>You need to wait until the machine stops spinning!</span>"
				return
			if (balance < 5)
				usr << "<span class='warning'>Insufficient money to play!</span>"
				return
			usr.mind.initial_account.money -= 5
			plays += 1
			working = 1
			icon_state = "slots-on"
			var/roll = rand(1,10000)
			playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
			spawn(30)
				if (roll == 1)
					playsound(src.loc, 'sound/effects/engine_alert2.ogg', 50, 0)
					visible_message("<b>[src]</b> says, 'JACKPOT! [usr.name] has won two hundred and fifty thousand credits!'")
					slotmachine_announcement.Announce("Congratulations to [usr.name] on winning the jackpot of two hundred and fifty thousand credits!", "Jackpot Winner")
					usr.mind.initial_account.money += 250000
				else if (roll > 1 && roll <= 10)
					playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
					visible_message("<b>[src]</b> says, 'Big Winner! [usr.name] has won five thousand credits!'")
					usr.mind.initial_account.money += 5000
				else if (roll > 10 && roll <= 100)
					playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
					visible_message("<b>[src]</b> says, 'Winner! [usr.name] has won win five hundred credits!'")
					usr.mind.initial_account.money += 500
				else if (roll > 100 && roll <= 1000)
					playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
					usr << "<span class='notice'>You win 5 credits!</span>"
					usr.mind.initial_account.money += 5
				else
					usr << "<span class='warning'>No luck!</span>"
				working = 0
				icon_state = "slots-off"
	add_fingerprint(usr)
	updateUsrDialog()
	return
