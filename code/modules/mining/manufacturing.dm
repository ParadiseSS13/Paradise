// the entire manufacturing.dm

/datum/manufacture
	var/name = null
	var/item = null
	var/cost1 = null
	var/cost2 = null
	var/cost3 = null
	var/cname1 = null
	var/cname2 = null
	var/cname3 = null
	var/amount1 = 0
	var/amount2 = 0
	var/amount3 = 0
	var/create = 1
	var/time = 5

/obj/machinery/manufacturer
	name = "Manufacturing Unit"
	desc = "A standard fabricator unit capable of producing certain items from mined ore."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fab-idle"
	density = 1
	anchored = 1
	//mats = 25
	var/working = 0
	var/panelopen = 0
	var/powconsumption = 0
	var/hacked = 0
	var/acceptdisk = 0
	var/dl_list = null
	var/list/available = list()
	var/list/diskload = list()
	var/list/download = list()
	var/list/hidden = list()

	New()
		..()

	process()
		..()
		if(src.working) use_power(src.powconsumption)

	ex_act(severity)
		switch(severity)
			if(1.0) qdel(src)
			if(2.0)
				if(prob(60)) stat |= BROKEN
			if(3.0)
				if(prob(30)) stat |= BROKEN
		return

	blob_act()
		if(prob(25)) del src
		return

	power_change()
		if(stat & BROKEN) icon_state = "fab-broken"
		else
			if( powered() )
				if(src.working) src.icon_state = "fab-active"
				else src.icon_state = "fab-idle"
				stat &= ~NOPOWER
			else
				spawn(rand(0, 15))
					src.icon_state = "fab-off"
					stat |= NOPOWER

	attack_hand(var/mob/user as mob)
		if(stat & BROKEN) return
		if(stat & NOPOWER) return

		user.machine = src
		var/dat = "<B>[src.name]</B><BR><HR>"

		if(src.working)
			dat += "This unit is currently busy."
			user << browse(dat, "window=manufact;size=400x500")
			onclose(user, "manufact")
			return

		var/AMTmaux = 0
		var/AMTmoli = 0
		var/AMTphar = 0
		var/AMTclar = 0
		var/AMTbohr = 0
		var/AMTereb = 0
		var/AMTcere = 0
		var/AMTplas = 0
		var/AMTuqil = 0
		var/AMTtele = 0
		var/AMTfabr = 0

		for(var/obj/item/weapon/ore/O in src.contents)
			if(istype(O,/obj/item/weapon/ore/iron)) AMTmaux++
			if(istype(O,/obj/item/weapon/ore/glass)) AMTmoli++
			if(istype(O,/obj/item/weapon/ore/silver)) AMTphar++
			if(istype(O,/obj/item/weapon/ore/diamond)) AMTclar++
			if(istype(O,/obj/item/weapon/ore/gold)) AMTbohr++
			if(istype(O,/obj/item/weapon/ore/coal)) AMTereb++
			if(istype(O,/obj/item/weapon/ore/uranium)) AMTcere++
			if(istype(O,/obj/item/weapon/ore/plasma)) AMTplas++
			if(istype(O,/obj/item/weapon/ore/osmium)) AMTuqil++
			if(istype(O,/obj/item/weapon/ore/hydrogen)) AMTtele++
			if(istype(O,/obj/item/weapon/ore/fabric)) AMTfabr++

		dat += "<B>Available Minerals</B><BR>"
		if(AMTmaux) dat += "<A href='?src=\ref[src];eject=1'><B>Iron:</B></A> [AMTmaux]<br>"
		if(AMTmoli) dat += "<A href='?src=\ref[src];eject=2'><B>Glass:</B></A> [AMTmoli]<br>"
		if(AMTphar) dat += "<A href='?src=\ref[src];eject=3'><B>Silver:</B></A> [AMTphar]<br>"
		if(AMTclar) dat += "<A href='?src=\ref[src];eject=4'><B>Diamond:</B></A> [AMTclar]<br>"
		if(AMTbohr) dat += "<A href='?src=\ref[src];eject=5'><B>Gold:</B></A> [AMTbohr]<br>"
		if(AMTereb) dat += "<A href='?src=\ref[src];eject=6'><B>Coal:</B></A> [AMTereb]<br>"
		if(AMTcere) dat += "<A href='?src=\ref[src];eject=7'><B>Uranium:</B></A> [AMTcere]<br>"
		if(AMTplas) dat += "<A href='?src=\ref[src];eject=8'><B>Plasma:</B></A> [AMTplas]<br>"
		if(AMTuqil) dat += "<A href='?src=\ref[src];eject=9'><B>Platinum:</B></A> [AMTuqil]<br>"
		if(AMTtele) dat += "<A href='?src=\ref[src];eject=10'><B>Hydrogen:</B></A> [AMTtele]<br>"
		if(AMTfabr) dat += "<A href='?src=\ref[src];eject=11'><B>Fabric:</B></A> [AMTfabr]<br>"
		if(!AMTmaux && !AMTmoli && !AMTphar && !AMTclar && !AMTbohr && !AMTereb && !AMTcere && !AMTplas && !AMTuqil && !AMTtele && !AMTfabr)
			dat += "No minerals currently loaded.<br>"

		dat += {"<HR>
		<B>Available Schematics</B>"}

		for(var/datum/manufacture/A in src.available)
			dat += {"<BR><A href='?src=\ref[src];disp=\ref[A]'>
			<b><u>[A.name]</u></b></A><br>
			<b>Cost:</b> [A.amount1] [A.cname1]"}
			if(A.cost2) dat += ", [A.amount2] [A.cname2]"
			if(A.cost3) dat += ", [A.amount3] [A.cname3]"
			dat += "<br><b>Time:</b> [A.time] Seconds<br>"

		for(var/datum/manufacture/A in src.download)
			dat += {"<BR><A href='?src=\ref[src];disp=\ref[A]'>
			<b><u>[A.name]</u></b></A> (Downloaded)<br>
			<b>Cost:</b> [A.amount1] [A.cname1]"}
			if(A.cost2) dat += ", [A.amount2] [A.cname2]"
			if(A.cost3) dat += ", [A.amount3] [A.cname3]"
			dat += "<br><b>Time:</b> [A.time] Seconds<br>"

		for(var/datum/manufacture/A in src.diskload)
			dat += {"<BR><A href='?src=\ref[src];disp=\ref[A]'>
			<b><u>[A.name]</u></b></A> (Disk)<br>
			<b>Cost:</b> [A.amount1] [A.cname1]"}
			if(A.cost2) dat += ", [A.amount2] [A.cname2]"
			if(A.cost3) dat += ", [A.amount3] [A.cname3]"
			dat += "<br><b>Time:</b> [A.time] Seconds<br>"

		if(src.hacked)
			for(var/datum/manufacture/A in src.hidden)
				dat += {"<BR><A href='?src=\ref[src];disp=\ref[A]'>
				<b><u>[A.name]</u></b></A> (Secret)<br>
				<b>Cost:</b> [A.amount1] [A.cname1]"}
				if(A.cost2) dat += ", [A.amount2] [A.cname2]"
				if(A.cost3) dat += ", [A.amount3] [A.cname3]"
				dat += "<br><b>Time:</b> [A.time] Seconds<br>"

		dat += "<hr>"

		if(src.dl_list)
			dat += {"<A href='?src=\ref[src];download=1'>Download Available Schematics</A><BR>
			<A href='?src=\ref[src];delete=2'>Clear Downloaded Schematics</A><BR>"}

		if(src.acceptdisk)
			dat += {"<A href='?src=\ref[src];delete=1'>Clear Disk Schematics</A><BR>"}

		user << browse(dat, "window=manufact;size=400x500")
		onclose(user, "manufact")

	Topic(href, href_list)
		if(stat & BROKEN) return
		if(stat & NOPOWER) return
		if(usr.stat || usr.restrained())
			return

		if((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))))
			usr.machine = src

			if(href_list["download"])
				to_chat(if(!src.dl_list) usr, "\red This unit is not capable of downloading any additional schematics.")
				else
					var/amtdl = 0
					//var/dontload = 0
					if(src.dl_list == "robotics")
						/*for(var/i = robotics_research.starting_tier, i <= robotics_research.max_tiers, i++)
							for(var/datum/roboresearch/X in robotics_research.researched_items[i])
								for(var/datum/manufacture/S in X.schematics)
									for(var/datum/manufacture/A in src.download)
										if(istype(S,A)) dontload = 1
									if(!dontload)
										src.download += new S.type(src)
										amtdl++
									else dontload = 0*/
						to_chat(if(amtdl) usr, "\blue [amtdl] new schematics downloaded from Robotics Research Database.")
						to_chat(else usr, "\red No new schematics currently available in Robotics Research Database.")

			if(href_list["delete"])
				var/operation = text2num(href_list["delete"])
				if(operation == 1) // Clear Disk Schematics
					var/amtgone = 0
					for(var/datum/manufacture/D in src.diskload)
						src.diskload-= D
						amtgone++
					to_chat(if(amtgone) usr, "\blue Cleared [amtgone] schematics from database.")
					to_chat(else usr, "\red No disk-loaded schematics detected in database.")
				if(operation == 2) // Clear Download Schematics
					var/amtgone = 0
					for(var/datum/manufacture/D in src.download)
						src.download-= D
						amtgone++
					to_chat(if(amtgone) usr, "\blue Cleared [amtgone] schematics from database.")
					to_chat(else usr, "\red No downloaded schematics detected in database.")

			if(href_list["eject"])
				var/operation = text2num(href_list["eject"])
				var/ejectamt = 0
				var/ejecting = null
				switch(operation)
					if(1) ejecting = /obj/item/weapon/ore/iron
					if(2) ejecting = /obj/item/weapon/ore/glass
					if(3) ejecting = /obj/item/weapon/ore/silver
					if(4) ejecting = /obj/item/weapon/ore/diamond
					if(5) ejecting = /obj/item/weapon/ore/gold
					if(6) ejecting = /obj/item/weapon/ore/coal
					if(7) ejecting = /obj/item/weapon/ore/uranium
					if(8) ejecting = /obj/item/weapon/ore/plasma
					if(9) ejecting = /obj/item/weapon/ore/osmium
					if(10) ejecting = /obj/item/weapon/ore/hydrogen
					if(11) ejecting = /obj/item/weapon/ore/fabric
					else
						to_chat(usr, "\red Error. Unknown ore type.")
						return
				sleep(3)
				ejectamt = input(usr,"How many units do you want to eject?","Eject Materials") as num
				for(var/obj/item/weapon/ore/O in src.contents)
					if(ejectamt <= 0) break
					if(istype(O, ejecting))
						O.loc = usr.loc
						ejectamt--

			if(href_list["disp"])
				var/datum/manufacture/I = locate(href_list["disp"])
				// Material Check
				var/A1 = 0
				var/A2 = 0
				var/A3 = 0
				for(var/obj/item/weapon/ore/O in src.contents)
					if(istype(O,I.cost1)) A1++
					if(istype(O,I.cost2)) A2++
					if(istype(O,I.cost3)) A3++
				if(A1 < I.amount1 || A2 < I.amount2 || A3 < I.amount3)
					to_chat(usr, "\red Insufficient materials to manufacture that item.")
					return
				// Consume Mats
				var/C1 = I.amount1
				var/C2 = I.amount2
				var/C3 = I.amount3
				for(var/obj/item/weapon/ore/O in src.contents)
					if(istype(O,I.cost1) && C1)
						del O
						C1--
					if(istype(O,I.cost2) && C2)
						del O
						C2--
					if(istype(O,I.cost3) && C3)
						del O
						C3--
				// Manufacture Item
				src.icon_state = "fab-active"
				src.working = 1
				var/worktime = I.time * 10
				var/powconsume = round(1500*worktime/3)
				/*for(var/i = robotics_research.starting_tier, i <= robotics_research.max_tiers, i++)
					for(var/datum/roboresearch/a in robotics_research.researched_items[i])
						if(a.manubonus)
							worktime -= a.timebonus
							if(a.multiplier != 0) worktime /= a.multiplier
							powconsume -= a.powbonus*/
				if(worktime < 1) worktime = 1
				src.powconsumption = powconsume
				src.updateUsrDialog()
				sleep(worktime)
				var/make = I.create
				while(make > 0)
					new I.item(src.loc)
					make--
				src.working = 0
				src.icon_state = "fab-idle"
				src.updateUsrDialog()


	attackby(obj/item/weapon/W as obj, mob/user as mob, params)
		var/load = 0
		if(istype(W, /obj/item/weapon/ore/))
			for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] loads [] into the [].", user, W, src), 1)
			load = 1
		else if(istype(W, /obj/item/stack/sheet))
			var/obj/item/stack/sheet/STACK = W
			for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] loads [] into the [].", user, W, src), 1)
			if(istype(STACK, /obj/item/stack/sheet/metal))
				for(var/amt = STACK.amount, amt > 0, amt--) new /obj/item/weapon/ore/iron(src)
			if(istype(STACK, /obj/item/stack/sheet/plasteel))
				for(var/amt = STACK.amount, amt > 0, amt--)
					new /obj/item/weapon/ore/iron(src)
					new /obj/item/weapon/ore/plasma(src)
			if(istype(STACK, /obj/item/stack/sheet/glass))
				for(var/amt = STACK.amount, amt > 0, amt--) new /obj/item/weapon/ore/glass(src)
			if(istype(STACK, /obj/item/stack/sheet/rglass))
				for(var/amt = STACK.amount, amt > 0, amt--)
					new /obj/item/weapon/ore/iron(src)
					new /obj/item/weapon/ore/glass(src)
			load = 2
		//else if(istype(W, /obj/item/weapon/plant/wheat/metal))
		//	new /obj/item/weapon/ore/iron(src)
		//	load = 2
		/*else if(istype(W, /obj/item/stack/cable_coil/))
			for(var/mob/O in viewers(user, null)) O.show_message(text("\blue [] loads [] into the [].", user, W, src), 1)
			for(var/amt = W:amount, amt > 0, amt--)
				new /obj/item/weapon/ore/silver(src)
				amt--
			load = 2*/
		else if(istype(W, /obj/item/weapon/shard))
			new /obj/item/weapon/ore/glass(src)
			load = 2
		else if(istype(W, /obj/item/stack/rods))
			var/obj/item/stack/RODS = W
			for(var/amt = RODS.amount, amt > 0, amt--) new /obj/item/weapon/ore/iron(src)
			load = 2
		else if(istype(W, /obj/item/clothing/))
			if(istype(W, /obj/item/clothing/under/))
				new /obj/item/weapon/ore/fabric(src)
				load = 2
			if(istype(W, /obj/item/clothing/suit/))
				if(!istype(W,/obj/item/clothing/suit/armor))
					new /obj/item/weapon/ore/fabric(src)
					new /obj/item/weapon/ore/fabric(src)
					if(istype(W,/obj/item/clothing/suit/space/)) new /obj/item/weapon/ore/fabric(src)
					load = 2
		else if(istype(W, /obj/item/weapon/disk/data/schematic))
			to_chat(if(!src.acceptdisk) user, "\red This unit is unable to accept disks.")
			else
				var/amtload = 0
				var/dontload = 0
				for(var/datum/manufacture/WS in W:schematics)
					for(var/datum/manufacture/A in src.available)
						if(istype(WS,A)) dontload = 1
					for(var/datum/manufacture/B in src.download)
						if(istype(WS,B)) dontload = 1
					for(var/datum/manufacture/C in src.diskload)
						if(istype(WS,C)) dontload = 1
					for(var/datum/manufacture/D in src.hidden)
						if(istype(WS,D) && src.hacked) dontload = 1
					if(!dontload)
						src.diskload += new WS.type(src)
						amtload++
					else dontload = 0
				to_chat(if(amtload) user, "\blue [amtload] new schematics downloaded from disk.")
				to_chat(else user, "\red No new schematics available on disk.")
		else if(istype(W, /obj/item/weapon/storage/bag/ore))
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] uses the []'s automatic ore loader on []!", user, src, W), 1)
			var/amtload = 0
			for(var/obj/item/weapon/ore/M in W.contents)
				M.loc = src
				amtload++
			to_chat(if(amtload) user, "\blue [amtload] pieces of ore loaded from [W]!")
			to_chat(else user, "\red No ore loaded!")
		else if(istype(W, /obj/item/weapon/card/emag))
			src.hacked = 1
			to_chat(user, "\blue You remove the [src]'s product locks!")
		else ..()

		if(load == 1)
			user.unEquip(W)
			W.loc = src
			if((user.client && user.s_active != src))
				user.client.screen -= W
			W.dropped()
		else if(load == 2)
			user.unEquip(W)
			W.dropped()
			if((user.client && user.s_active != src))
				user.client.screen -= W
			del W

		src.updateUsrDialog()

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
		if(istype(O, /obj/structure/closet/crate/))
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] uses the []'s automatic ore loader on []!", user, src, O), 1)
			var/amtload = 0
			for(var/obj/item/weapon/ore/M in O.contents)
				M.loc = src
				amtload++
			to_chat(if(amtload) user, "\blue [amtload] pieces of ore loaded from [O]!")
			to_chat(else user, "\red No ore loaded!")
		else if(istype(O, /obj/item/weapon/ore/))
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] begins quickly stuffing ore into []!", user, src), 1)
			var/staystill = user.loc
			for(var/obj/item/weapon/ore/M in view(1,user))
				M.loc = src
				sleep(3)
				if(user.loc != staystill) break
			to_chat(user, "\blue You finish stuffing ore into [src]!")
		/*else if(istype(O, /obj/item/weapon/plant/wheat/metal))
			for(var/mob/V in viewers(user, null)) V.show_message(text("\blue [] begins quickly stuffing [O] into []!", user, src), 1)
			var/staystill = user.loc
			for(var/obj/item/weapon/plant/wheat/metal/M in view(1,user))
				new /obj/item/weapon/ore/iron(src)
				del M
				sleep(3)
				if(user.loc != staystill) break
			to_chat(user, "\blue You finish stuffing [O] into [src]!"*/)
		else ..()
		src.updateUsrDialog()

/obj/item/weapon/disk/data/schematic
	name = "Manufacturer Schematic Disk"
	desc = "Contains schematics for use in a Manufacturing Unit."
	var/list/schematics = list()

// Fabricator Defines

/obj/machinery/manufacturer/general
	name = "General Manufacturer"
	desc = "A manufacturing unit calibrated to produce tools and general purpose items."

	New()
		..()
		src.available += new /datum/manufacture/screwdriver(src)
		src.available += new /datum/manufacture/wirecutters(src)
		src.available += new /datum/manufacture/wrench(src)
		src.available += new /datum/manufacture/crowbar(src)
		src.available += new /datum/manufacture/extinguisher(src)
		src.available += new /datum/manufacture/welder(src)
		src.available += new /datum/manufacture/weldingmask(src)
		src.available += new /datum/manufacture/multitool(src)
		src.available += new /datum/manufacture/metal5(src)
		src.available += new /datum/manufacture/metalR(src)
		src.available += new /datum/manufacture/glass5(src)
		src.available += new /datum/manufacture/glassR(src)
		src.available += new /datum/manufacture/atmos_can(src)
		//src.available += new /datum/manufacture/cable(src)
		src.available += new /datum/manufacture/light_bulb(src)
		src.available += new /datum/manufacture/light_tube(src)
		src.available += new /datum/manufacture/breathmask(src)
		src.available += new /datum/manufacture/RCDammo(src)
		//src.available += new /datum/manufacture/cola_bottle(src)
		//src.hidden += new /datum/manufacture/vuvuzela(src)
		//src.hidden += new /datum/manufacture/harmonica(src)
		//src.hidden += new /datum/manufacture/bikehorn(src)
		//src.hidden += new /datum/manufacture/stunrounds

/obj/machinery/manufacturer/robotics
	name = "Robotics Fabricator"
	desc = "A manufacturing unit calibrated to produce robot-related equipment."
	acceptdisk = 1
	dl_list = "robotics"

	New()
		..()
		src.available += new /datum/manufacture/robo_frame(src)
		src.available += new /datum/manufacture/robo_head(src)
		src.available += new /datum/manufacture/robo_chest(src)
		src.available += new /datum/manufacture/robo_arm_r(src)
		src.available += new /datum/manufacture/robo_arm_l(src)
		src.available += new /datum/manufacture/robo_leg_r(src)
		src.available += new /datum/manufacture/robo_leg_l(src)
		src.available += new /datum/manufacture/robo_stmodule(src)
		//src.available += new /datum/manufacture/cable(src)
		src.available += new /datum/manufacture/powercell(src)
		src.available += new /datum/manufacture/crowbar(src)
		src.available += new /datum/manufacture/scalpel(src)
		src.available += new /datum/manufacture/circular_saw(src)
		src.available += new /datum/manufacture/implanter
		src.hidden += new /datum/manufacture/flash(src)

// Schematic Defines
// General/Miscellaneous

/datum/manufacture/crowbar
	name = "Crowbar"
	item = /obj/item/weapon/crowbar
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/screwdriver
	name = "Screwdriver"
	item = /obj/item/weapon/screwdriver
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/wirecutters
	name = "Wirecutters"
	item = /obj/item/weapon/wirecutters
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/wrench
	name = "Wrench"
	item = /obj/item/weapon/wrench
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	time = 5
	create = 1
/*
/datum/manufacture/vuvuzela
	name = "Vuvuzela"
	item = /obj/item/weapon/vuvuzela
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/harmonica
	name = "Harmonica"
	item = /obj/item/weapon/harmonica
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/cola_bottle
	name = "Glass Bottle"
	item = /obj/item/weapon/reagent_containers/food/drinks/cola_bottle
	cost1 = /obj/item/weapon/ore/glass
	cname1 = "Glass"
	amount1 = 1
	time = 4
	create = 1

/datum/manufacture/bikehorn
	name = "Bicycle Horn"
	item = /obj/item/weapon/bikehorn
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/stunrounds
	name = ".38 Stunner Rounds"
	item = /obj/item/weapon/ammo/bullets/a38/stun
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 7
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 3
	time = 25
	create = 1
*/
/datum/manufacture/extinguisher
	name = "Fire Extinguisher"
	item = /obj/item/weapon/extinguisher
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 1
	time = 8
	create = 1

/datum/manufacture/welder
	name = "Welding Tool"
	item = /obj/item/weapon/weldingtool
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 1
	time = 8
	create = 1

/datum/manufacture/multitool
	name = "Multi Tool"
	item = /obj/item/device/multitool
	cost1 = /obj/item/weapon/ore/glass
	cname1 = "Glass"
	amount1 = 1
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 1
	time = 8
	create = 1

/datum/manufacture/weldingmask
	name = "Welding Mask"
	item = /obj/item/clothing/head/welding
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 2
	time = 10
	create = 1

/datum/manufacture/light_bulb
	name = "Light Bulb"
	item = /obj/item/weapon/light/bulb
	cost1 = /obj/item/weapon/ore/glass
	cname1 = "Glass"
	amount1 = 1
	time = 4
	create = 1

/datum/manufacture/light_tube
	name = "Light Tube"
	item = /obj/item/weapon/light/tube
	cost1 = /obj/item/weapon/ore/glass
	cname1 = "Glass"
	amount1 = 1
	time = 4
	create = 1

/datum/manufacture/metal5
	name = "Sheet Metal (x5)"
	item = /obj/item/stack/sheet/metal
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 5
	time = 8
	create = 5

/datum/manufacture/metalR
	name = "Reinforced Metal"
	item = /obj/item/stack/sheet/plasteel
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	cost2 = /obj/item/weapon/ore/plasma
	cname2 = "Plasma"
	amount2 = 1
	time = 6
	create = 1

/datum/manufacture/glass5
	name = "Glass Panel (x5)"
	item = /obj/item/stack/sheet/glass
	cost1 = /obj/item/weapon/ore/glass
	cname1 = "Glass"
	amount1 = 5
	time = 8
	create = 5

/datum/manufacture/glassR
	name = "Reinforced Glass Panel"
	item = /obj/item/stack/sheet/rglass
	cost1 = /obj/item/weapon/ore/glass
	cname1 = "Glass"
	amount1 = 1
	cost2 = /obj/item/weapon/ore/iron
	cname2 = "Iron"
	amount2 = 1
	time = 12
	create = 1

/datum/manufacture/atmos_can
	name = "Portable Gas Canister"
	item = /obj/machinery/portable_atmospherics/canister
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 5
	time = 10
	create = 1

/*
/datum/manufacture/cable
	name = "Electrical Cable Piece"
	item = /obj/item/stack/cable_coil/cut
	cost1 = /obj/item/weapon/ore/silver
	cname1 = "Silver"
	amount1 = 1
	time = 3
	create = 1
*/
/datum/manufacture/RCD
	name = "Rapid Construction Device"
	item = /obj/item/weapon/rcd
	cost1 = /obj/item/weapon/ore/gold
	cname1 = "Gold"
	amount1 = 5
	cost2 = /obj/item/weapon/ore/osmium
	cname2 = "Platinum"
	amount2 = 1
	cost3 = /obj/item/weapon/ore/silver
	cname3 = "Silver"
	amount3 = 10
	time = 90
	create = 1

/datum/manufacture/RCDammo
	name = "Compressed Matter Cartridge"
	item = /obj/item/weapon/rcd_ammo
	cost1 = /obj/item/weapon/ore/osmium
	cname1 = "Platinum"
	amount1 = 1
	time = 15
	create = 1


/******************** Robotics **************************/

/datum/manufacture/robo_frame
	name = "Cyborg Frame"
	item = /obj/item/robot_parts/robot_suit
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 18
	time = 45
	create = 1

/datum/manufacture/robo_chest
	name = "Cyborg Chest"
	item = /obj/item/robot_parts/chest
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 12
	time = 30
	create = 1

/datum/manufacture/robo_head
	name = "Cyborg Head"
	item = /obj/item/robot_parts/head
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 12
	time = 30
	create = 1

/datum/manufacture/robo_arm_r
	name = "Cyborg Arm (Right)"
	item = /obj/item/robot_parts/r_arm
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 6
	time = 15
	create = 1

/datum/manufacture/robo_arm_l
	name = "Cyborg Arm (Left)"
	item = /obj/item/robot_parts/l_arm
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 6
	time = 15
	create = 1

/datum/manufacture/robo_leg_r
	name = "Cyborg Leg (Right)"
	item = /obj/item/robot_parts/r_leg
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 6
	time = 15
	create = 1

/datum/manufacture/robo_leg_l
	name = "Cyborg Leg (Left)"
	item = /obj/item/robot_parts/l_leg
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 6
	time = 15
	create = 1

/datum/manufacture/robo_stmodule
	name = "Standard Cyborg Module"
	item = /obj/item/weapon/robot_module/standard
	cost1 = /obj/item/weapon/ore/silver
	cname1 = "Silver"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 3
	time = 40
	create = 1

/datum/manufacture/scalpel
	name = "Scalpel"
	item = /obj/item/weapon/scalpel
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/circular_saw
	name = "Circular Saw"
	item = /obj/item/weapon/circular_saw
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	time = 5
	create = 1

/datum/manufacture/powercell
	name = "Power Cell"
	item = /obj/item/weapon/stock_parts/cell
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 4
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 4
	cost3 = /obj/item/weapon/ore/silver
	cname3 = "Silver"
	amount3 = 4
	time = 30
	create = 1

/datum/manufacture/flash
	name = "Flash"
	item = /obj/item/device/flash
	cost1 = /obj/item/weapon/ore/glass
	cname1 = "Glass"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 2
	time = 15
	create = 1



// Robotics Research

/datum/manufacture/implanter
	name = "Implanter"
	item = /obj/item/weapon/implanter
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 1
	time = 3
	create = 1

/datum/manufacture/secbot
	name = "Security Drone"
	item = /obj/machinery/bot/secbot
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/glass
	cname3 = "Glass"
	amount3 = 5
	time = 60
	create = 1

/datum/manufacture/floorbot
	name = "Construction Drone"
	item = /obj/machinery/bot/floorbot
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/glass
	cname3 = "Glass"
	amount3 = 5
	time = 60
	create = 1

/datum/manufacture/medbot
	name = "Medical Drone"
	item = /obj/machinery/bot/medbot
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/glass
	cname3 = "Glass"
	amount3 = 5
	time = 60
	create = 1
/*
/datum/manufacture/firebot
	name = "Firefighting Drone"
	item = /obj/machinery/bot/firebot
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/glass
	cname3 = "Glass"
	amount3 = 5
	time = 60
	create = 1
*/
/datum/manufacture/cleanbot
	name = "Sanitation Drone"
	item = /obj/machinery/bot/cleanbot
	cost1 = /obj/item/weapon/ore/iron
	cname1 = "Iron"
	amount1 = 10
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/glass
	cname3 = "Glass"
	amount3 = 5
	time = 60
	create = 1
/*
/datum/manufacture/robup_jetpack
	name = "Propulsion Upgrade"
	item = /obj/item/weapon/roboupgrade/jetpack
	cost1 = /obj/item/weapon/ore/silver
	cname1 = "Silver"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/iron
	cname2 = "Iron"
	amount2 = 5
	time = 60
	create = 1

/datum/manufacture/robup_speed
	name = "Speed Upgrade"
	item = /obj/item/weapon/roboupgrade/speed
	cost1 = /obj/item/weapon/ore/silver
	cname1 = "Silver"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 5
	time = 60
	create = 1

/datum/manufacture/robup_recharge
	name = "Recharge Pack"
	item = /obj/item/weapon/roboupgrade/rechargepack
	cost1 = /obj/item/weapon/ore/silver
	cname1 = "Silver"
	amount1 = 5
	time = 60
	create = 1

/datum/manufacture/robup_repairpack
	name = "Repair Pack"
	item = /obj/item/weapon/roboupgrade/repairpack
	cost1 = /obj/item/weapon/ore/silver
	cname1 = "Silver"
	amount1 = 5
	time = 60
	create = 1

/datum/manufacture/robup_physshield
	name = "Force Shield Upgrade"
	item = /obj/item/weapon/roboupgrade/physshield
	cost1 = /obj/item/weapon/ore/diamond
	cname1 = "Claretine"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/iron
	cname2 = "Iron"
	amount2 = 10
	time = 90
	create = 1

/datum/manufacture/robup_fireshield
	name = "Heat Shield Upgrade"
	item = /obj/item/weapon/roboupgrade/fireshield
	cost1 = /obj/item/weapon/ore/diamond
	cname1 = "Claretine"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 10
	time = 90
	create = 1

/datum/manufacture/robup_aware
	name = "Operational Upgrade"
	item = /obj/item/weapon/roboupgrade/aware
	cost1 = /obj/item/weapon/ore/diamond
	cname1 = "Claretine"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 5
	cost3 = /obj/item/weapon/ore/silver
	cname3 = "Silver"
	amount3 = 5
	time = 90
	create = 1

/datum/manufacture/robup_efficiency
	name = "Efficiency Upgrade"
	item = /obj/item/weapon/roboupgrade/efficiency
	cost1 = /obj/item/weapon/ore/osmium
	cname1 = "Platinum"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/diamond
	cname2 = "Claretine"
	amount2 = 10
	time = 120
	create = 1

/datum/manufacture/robup_repair
	name = "Self-Repair Upgrade"
	item = /obj/item/weapon/roboupgrade/repair
	cost1 = /obj/item/weapon/ore/osmium
	cname1 = "Platinum"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/gold
	cname2 = "Gold"
	amount2 = 10
	time = 120
	create = 1

/datum/manufacture/robup_teleport
	name = "Teleport Upgrade"
	item = /obj/item/weapon/roboupgrade/teleport
	cost1 = /obj/item/weapon/ore/osmium
	cname1 = "Platinum"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/hydrogen
	cname2 = "Telecrystal"
	amount2 = 2
	time = 120
	create = 1

/datum/manufacture/robup_expand
	name = "Expansion Upgrade"
	item = /obj/item/weapon/roboupgrade/expand
	cost1 = /obj/item/weapon/ore/osmium
	cname1 = "Platinum"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/uranium
	cname2 = "Cerenkite"
	amount2 = 1
	time = 120
	create = 1

/datum/manufacture/robup_chargexpand
	name = "Charge Expander Upgrade"
	item = /obj/item/weapon/roboupgrade/chargeexpand
	cost1 = /obj/item/weapon/ore/diamond
	cname1 = "Claretine"
	amount1 = 5
	time = 70
	create = 1

/datum/manufacture/robup_meson
	name = "Optical Meson Upgrade"
	item = /obj/item/weapon/roboupgrade/opticmeson
	cost1 = /obj/item/weapon/ore/glass
	cname1 = "Glass"
	amount1 = 2
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 4
	time = 90
	create = 1

/datum/manufacture/robup_thermal
	name = "Optical Thermal Upgrade"
	item = /obj/item/weapon/roboupgrade/opticthermal
	cost1 = /obj/item/weapon/ore/glass
	cname1 = "Glass"
	amount1 = 4
	cost2 = /obj/item/weapon/ore/silver
	cname2 = "Silver"
	amount2 = 8
	time = 90
	create = 1

/datum/manufacture/deafhs
	name = "Auditory Headset"
	item = /obj/item/device/radio/headset/deaf
	cost1 = /obj/item/weapon/ore/silver
	cname1 = "Silver"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 3
	time = 40
	create = 1

/datum/manufacture/visor
	name = "VISOR Prosthesis"
	item = /obj/item/clothing/glasses/visor
	cost1 = /obj/item/weapon/ore/silver
	cname1 = "Silver"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 3
	time = 40
	create = 1

/datum/manufacture/implant_robotalk
	name = "Machine Translator Implant"
	item = /obj/item/weapon/implantcase/robotalk
	cost1 = /obj/item/weapon/ore/silver
	cname1 = "Silver"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 3
	time = 40
	create = 1

/datum/manufacture/implant_bloodmonitor
	name = "Blood Monitor Implant"
	item = /obj/item/weapon/implantcase/bloodmonitor
	cost1 = /obj/item/weapon/ore/silver
	cname1 = "Silver"
	amount1 = 3
	cost2 = /obj/item/weapon/ore/glass
	cname2 = "Glass"
	amount2 = 3
	time = 40
	create = 1
*/