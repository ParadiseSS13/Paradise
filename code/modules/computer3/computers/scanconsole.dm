/obj/machinery/computer3/scan_consolenew
	default_prog = /datum/file/program/dnascanner
	spawn_parts = list(/obj/item/part/computer/storage/hdd,/obj/item/part/computer/storage/removable,/obj/item/part/computer/networking/prox)


#define MAX_UIBLOCK 13
#define MAX_SEBLOCK 14

/datum/file/program/dnascanner
	name = "DNA Scanner and Manipulator"
	desc = "The DNA ScaM is sure to change your life forever."
	active_state = "dna"
	var/obj/machinery/dna_scannernew/scanner				= null

	var/ui_block = 1
	var/se_block = 1
	var/subblock = 1

	var/uitarget = 1
	var/uitargethex = "1"

	var/radduration = 2
	var/radstrength = 1

	var/injectorready = 0	//Quick fix for issue 286 (screwdriver the screen twice to restore injector)	-Pete

	var/mode		= 0
	// These keep track of the patient status
	var/present		= 0
	var/viable		= 0

	var/bufferlabel = ""
	var/datum/dna/buffer = null
	var/obj/item/part/computer/target_drive = null

	Reset()
		..()
		mode = 0
		scanner = null
		ui_block = 1
		se_block = 1
		subblock = 1
		buffer = null
		bufferlabel = ""


	Topic(var/href, var/list/href_list)
		if(!interactable() || !computer.net || ..(href,href_list))
			return

		scanner = computer.net.connect_to(/obj/machinery/dna_scannernew, scanner) // if exists, will be verified
		if(!scanner)
			computer.Crash(NETWORK_FAILURE)
			return

		// todo check everything goddamnit
		present = scanner.occupant && scanner.occupant.dna
		viable	= present && !(NOCLONE in scanner.occupant.mutations)

		// current screen/function
		if("mode" in href_list)
			mode = text2num(href_list["mode"])
		// locks scanner door
		if("lock" in href_list)
			scanner.locked = !scanner.locked

		// inject good-juice
		if("rejuv" in href_list)
			rejuv()

		// expose to radiation, controlled otherwise
		if("pulse" in href_list)
			pulse(href_list["pulse"]) // ui, se, or nothing/null

		if("duration" in href_list)
			var/modifier = text2num(href_list["duration"])
			radduration	+= modifier
		if("strength" in href_list)
			var/modifier = text2num(href_list["strength"])
			radstrength += modifier

		if("uiblock" in href_list)
			ui_block	= text2num(href_list["uiblock"])
		if("seblock" in href_list)
			se_block	= text2num(href_list["seblock"])
		if("subblock" in href_list)
			subblock	= text2num(href_list["subblock"])
		if("uitarget" in href_list)
			uitarget = text2num(href_list["uitarget"])
			uitargethex = num2hex(uitarget)

		// save dna to buffer - buffer=se,ui,ue,all,clear
		if("buffer" in href_list)
			if(!viable)
				return
			var/which = href_list["buffer"]
			if(!which || which == "clear")
				buffer = null
			else
				if(!buffer)
					buffer = new
				if( which == "all" )
					buffer.unique_enzymes	= scanner.occupant.dna.unique_enzymes
					buffer.struc_enzymes	= scanner.occupant.dna.struc_enzymes
					buffer.uni_identity		= scanner.occupant.dna.uni_identity
					buffer.real_name		= scanner.occupant.dna.real_name
					buffer.mutantrace		= scanner.occupant.dna.mutantrace
				if( which == "se" )
					buffer.struc_enzymes	= scanner.occupant.dna.struc_enzymes
					buffer.mutantrace		= scanner.occupant.dna.mutantrace
				if( which == "ui" )
					buffer.uni_identity		= scanner.occupant.dna.uni_identity
				if( which == "ue" )
					buffer.uni_identity		= scanner.occupant.dna.uni_identity
					buffer.unique_enzymes	= scanner.occupant.dna.unique_enzymes
					buffer.real_name		= scanner.occupant.dna.real_name

		// save buffer to file -
		if("save" in href_list)
			if(!viable || !buffer)
				return
			var/datum/file/data/genome/G = null
			var/obj/item/part/computer/dest = device
			if(target_drive)
				dest = target_drive

			switch(href_list["save"])
				if("se")
					if(buffer.struc_enzymes)
						G = new /datum/file/data/genome/SE()
						G.content = buffer.struc_enzymes
						G:mutantrace = buffer.mutantrace // : not . due to inheritance
						G.real_name = buffer.real_name
				if("ui")
					if(buffer.uni_identity)
						G = new /datum/file/data/genome/UI()
						G.content = buffer.uni_identity
						G.real_name = buffer.real_name
				if("ue")
					if(buffer.uni_identity)
						G = new /datum/file/data/genome/UI/UE()
						G.content = buffer.uni_identity
						G.real_name = buffer.real_name
			if(G && dest)
				var/label = input(usr, "Enter a filename:", "Save file", buffer.real_name) as text
				G.name = G.name + "([label])"
				dest:addfile(G)

		// load buffer from file
		if("load" in href_list)
			var/datum/file/data/genome/G = locate(href_list["load"])
			if(G)
				if(!buffer)
					buffer = new
				switch(G.type)
					if(/datum/file/data/genome/SE)
						buffer.struc_enzymes = G.content
						buffer.mutantrace = G:mutantrace
					if(/datum/file/data/genome/UI/UE)
						buffer.uni_identity = G.content
						buffer.real_name = G.real_name
						buffer.unique_enzymes = md5(buffer.real_name)
					if(/datum/file/data/genome/UI)
						buffer.uni_identity = G.content
					if(/datum/file/data/genome/cloning)
						var/datum/dna/record = G:record
						buffer.unique_enzymes	= record.unique_enzymes
						buffer.struc_enzymes	= record.struc_enzymes
						buffer.uni_identity		= record.uni_identity
						buffer.real_name		= record.real_name
						buffer.mutantrace		= record.mutantrace


		// inject genetics into occupant
		if("inject" in href_list)
			if(!buffer || !viable)
				return

			var/which = href_list["inject"]
			var/datum/dna/target = scanner.occupant.dna
			switch(which)
				if("all",null)
					if(buffer.struc_enzymes)
						target.struc_enzymes = buffer.struc_enzymes
					if(buffer.uni_identity)
						target.uni_identity = buffer.uni_identity
					if(buffer.real_name)
						target.real_name = buffer.real_name
						target.unique_enzymes = md5(target.real_name)
					updateappearance(scanner.occupant,target.uni_identity)
					domutcheck(scanner.occupant, scanner, 1)

					if(ishuman(scanner.occupant))
						target.mutantrace = buffer.mutantrace
						scanner.occupant:update_mutantrace()
				if("se")
					if(buffer.struc_enzymes)
						target.struc_enzymes = buffer.struc_enzymes
					domutcheck(scanner.occupant, scanner, 1)
					if(ishuman(scanner.occupant))
						target.mutantrace = buffer.mutantrace
						scanner.occupant:update_mutantrace()
				if("ui")
					if(buffer.uni_identity)
						target.uni_identity = buffer.uni_identity
					updateappearance(scanner.occupant,target.uni_identity)
				if("ue")
					if(buffer.uni_identity)
						target.uni_identity = buffer.uni_identity
					if(buffer.real_name)
						target.real_name = buffer.real_name
						target.unique_enzymes = md5(target.real_name)
					updateappearance(scanner.occupant,target.uni_identity)

		// generate dna injector
		if("generate" in href_list)
			if(!buffer || !injectorready)
				return
			buffer.check_integrity()
			var/which = href_list["generate"]
			var/obj/item/weapon/dnainjector/inj
			switch(which)
				if("se")
					inj = new(computer.loc)
					inj.dnatype = "se"
					inj.dna = buffer.struc_enzymes
					inj.mutantrace = buffer.mutantrace
					inj.name = "Structural Enzymes"
				if("ui")
					inj = new(computer.loc)
					inj.dnatype = "ui"
					inj.dna = buffer.uni_identity
					inj.ue = null
					inj.name = "Unique Identifiers"
				if("ue")
					inj = new(computer.loc)
					inj.dnatype = "ui"
					inj.dna = buffer.uni_identity
					inj.ue = buffer.real_name
					inj.name = "Unique Enzymes + Unique Identifiers"
			if(inj)
				injectorready = 0
				spawn(300)
					injectorready = 1
				var/label = input(usr, "Enter a label", "Label [inj.name] Injector", buffer.real_name) as null|text
				if(label && inj) // it's possible it was deleted before we get here, input suspends execution
					inj.name += " ([label])"

		interact()
		return // putting this in there to visually mark the end of topic() while I do other things

	proc/menu()
		if(!present && (mode==1 || mode==2)) // require viable occupant
			mode = 0
		switch(mode)
			if(0) // MAIN MENU
				return main_menu()

			if(1)
				return ui_menu()
			if(2)
				return se_menu()

			if(3)
				return emitter_menu()

			if(4)
				return buffer_menu()

	// unified header with health data
	// option to show UI,UE,SE as plaintext
	proc/status_display(var/dna_summary = 0)
		var/mob/living/occupant = scanner.occupant
		var/status_html
		if(viable)
			status_html = "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [occupant.health]%;' class='progressFill good'></div></div><div class='statusValue'>[occupant.health]%</div></div>"
			status_html += "<div class='line'><div class='statusLabel'>Radiation Level:</div><div class='progressBar'><div style='width: [occupant.radiation]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.radiation]%</div></div>"
			if(ishuman(occupant))
				var/rejuvenators = round(occupant.reagents.get_reagent_amount("inaprovaline") / REJUVENATORS_MAX * 100)
				status_html += "<div class='line'><div class='statusLabel'>Rejuvenators:</div><div class='progressBar'><div style='width: [rejuvenators]%;' class='progressFill highlight'></div></div><div class='statusValue'>[occupant.reagents.get_reagent_amount("inaprovaline")] units</div></div>"

			if(dna_summary)
				status_html += "<div class='line'><div class='statusLabel'>Unique Enzymes :</div><div class='statusValue'><span class='highlight'>[uppertext(occupant.dna.unique_enzymes)]</span></div></div>"
				status_html += "<div class='line'><div class='statusLabel'>Unique Identifier:</div><div class='statusValue'><span class='highlight'>[occupant.dna.uni_identity]</span></div></div>"
				status_html += "<div class='line'><div class='statusLabel'>Structural Enzymes:</div><div class='statusValue'><span class='highlight'>[occupant.dna.struc_enzymes]</span></div></div>"

		var/occupant_status = "Scanner Unoccupied"
		if(present)
			if(!viable)
				occupant_status = "<span class='bad'>Invalid DNA structure</span>"
			else
				switch(occupant.stat) // obvious, see what their status is
					if(0)
						occupant_status = "<span class='good'>Conscious</span>"
					if(1)
						occupant_status = "<span class='average'>Unconscious</span>"
					else
						occupant_status = "<span class='bad'>DEAD</span>"

			occupant_status = "[occupant.name] => [occupant_status]<br />"
		var/dat = "<h3>Scanner Status</h3>[topic_link(src,"","Scan")]<div class='statusDisplay'>[occupant_status][status_html]</div>"
		if(present)
			dat += topic_link(src,"lock",scanner.locked?"Unlock Scanner":"Lock Scanner") + " " + topic_link(src,"rejuv","Inject Rejuvenators")
		else
			dat += "<span class='linkOff'>[scanner.locked?"Unlock Scanner":"Lock Scanner"]</span> <span class='linkOff'>Inject Rejuvenators</span>"
		return dat

	proc/main_menu()
		var/dat = status_display(dna_summary = 1)
		dat += "<br><br><h3>Main Menu</h3>"
		if(present)
			dat += topic_link(src,"mode=1","Modify Unique Identifier") + "<br>" + topic_link(src,"mode=2","Modify Structural Enzymes") + "<br><br>"
		else
			dat += "<span class='linkOff'>Modify Unique Identifier</span><br><span class='linkOff'>Modify Structural Enzymes</span><br><br>"
		dat += topic_link(src,"mode=3","Radiation Emitter Settings") + "<br><br>" + topic_link(src,"mode=4","Transfer Buffer")
		return dat


	proc/block_plus_minus(var/topicstr, var/blockval,var/min,var/max)
		var/left = blockval - 1
		var/right = blockval + 1
		if(left < min)
			left = max
		if(right > max)
			right = min
		return topic_link(src,"[topicstr]=[left]","<-") + "&nbsp;<b>[blockval]</b>&nbsp;" + topic_link(src,"[topicstr]=[right]","->")


	proc/getblockstring(var/ui = 0)
		var/mainblock = "seblock"
		var/block = se_block
		var/input = scanner.occupant.dna.struc_enzymes
		if(ui)
			mainblock = "uiblock"
			block = ui_block
			input = scanner.occupant.dna.uni_identity

		var/string = "<div class='getblockstring'><div class='blockString'>"
		var/subpos = 1 // keeps track of the current sub block
		var/blockpos = 1

		for(var/i = 1, i <= length(input), i++) // loop through each letter

			if(blockpos == block && subpos == subblock) // if the current block/subblock is selected, mark it
				string += fake_link(copytext(input,i,i+1))
			else
				string += topic_link(src,"[mainblock]=[blockpos];subblock=[subpos]",copytext(input,i,i+1))

			subpos++
			if(subpos > 3) // add a line break for every block
				string += "</div> <div class='blockString'>"
				subpos = 1
				blockpos++

		string += "</div></div>"
		return string

	proc/ui_menu()
		if(!viable)
			return "No viable occupant detected."
		to_chat(var/dat = topic_link(src,"mode=0",", Main Menu") + "<br>")
		dat += "<h3>Modify Unique Identifier</h3>"
		dat += "<div align='center'>Unique Identifier:<br />[getblockstring(ui=1)]<br /><br />"

		dat += "Selected Block: " + block_plus_minus("uiblock",ui_block,1,MAX_UIBLOCK) + "<br /><br />"
		dat += "Selected Sub-Block: " + block_plus_minus("subblock",subblock,1,3) + "<br /><br />"
		dat += "Selected Target: " + block_plus_minus("uitarget",uitarget,0,15) + "<br /><br />"
		dat += "<B>Modify Block</B><br />"
		dat += topic_link(src,"pulse=ui","Irradiate") + "</div>"
		return dat

	proc/se_menu()
		if(!viable)
			return "No viable occupant detected."
		to_chat(var/dat = topic_link(src,"mode=0",", Main Menu") + "<br>")
		dat += "<h3>Modify Structural Enzymes</h3>"
		dat += "<div align='center'>Structural Enzymes: [getblockstring(ui=0)]<br /><br />"
		dat += "Selected Block: " + block_plus_minus("seblock",se_block,1,MAX_SEBLOCK) + "<br /><br />"
		dat += "Selected Sub-Block: " + block_plus_minus("subblock",subblock,1,3) + "<br /><br />"
		dat += "<B>Modify Block</B><br />"
		dat += topic_link(src,"pulse=se","Irradiate") + "</div>"
		return dat

	proc/emitter_menu()
		to_chat(var/dat = topic_link(src,"mode=0",", Main Menu") + "<br>")
		dat += "<h3>Radiation Emitter Settings</h3>"
		if(viable)
			dat += topic_link(src,"pulse","Pulse Radiation")
		else
			dat += fake_link("Pulse Radiation")
		dat += "<br /><br />"
		dat += "Radiation Duration: " + block_plus_minus("duration",radduration,1,20) + "<br />"
		dat += "Radiation Intensity: " + block_plus_minus("strength",radstrength,1,10) + "<br /><br />"
		return dat

	proc/buffer_menu()

	interact()
		if(!interactable())
			return
		popup.add_stylesheet("scannernew", 'html/browser/scannernew.css')

		if(!computer.net)
			computer.Crash(MISSING_PERIPHERAL)
			return

		scanner = computer.net.connect_to(/obj/machinery/dna_scannernew, scanner) // if exists, will be verified
		if(!scanner)
			computer.Crash(NETWORK_FAILURE)
			return

		// todo check everything goddamnit

		present = scanner.occupant && scanner.occupant.dna
		viable	= present && !(NOCLONE in scanner.occupant.mutations)

		popup.set_content(menu())
		popup.open()

	proc/pulse(var/target as null|anything in list("ui","se"))

		//Makes sure someone is in there (And valid) before trying anything
		//More than anything, this just acts as a sanity check in case the option DOES appear for whatever reason

		if(target != "ui" && target != "se")
			target = null

		// transforms into the fail condition instead of having it in yet another nested if block
		else if( prob(20 - (radduration / 2)))
			target += "-f"

		if(!viable)
			popup.set_content("No viable occupant detected.")
			popup.open()
		else
			popup.set_content("Working ... Please wait ([radduration]) Seconds)")
			popup.open()

			var/lock_state = scanner.locked
			scanner.locked = 1//lock it
			sleep(10*radduration)

			switch(target)
				if("ui")
					var/ui = scanner.occupant.dna.uni_identity
					var/block = getblock(ui,ui_block,3)
					var/result = ""
					for(var/sb = 1; sb <=3; sb++)
						var/temp = copytext(block,sb,sb+1)
						if(sb == subblock)
							temp = miniscramble("[uitargethex]",radstrength,radduration)
						result += temp
					scanner.occupant.dna.uni_identity = setblock(ui, ui_block, result,3)
					updateappearance(scanner.occupant,scanner.occupant.dna.uni_identity)
					scanner.occupant.apply_effect(radstrength+radduration, IRRADIATE)
				if("ui-f")
					if(prob(20+radstrength))
						randmutb(scanner.occupant)
						domutcheck(scanner.occupant,scanner)
					else
						randmuti(scanner.occupant)
						updateappearance(scanner.occupant,scanner.occupant.dna.uni_identity)
					scanner.occupant.apply_effect((radstrength*2)+radduration, IRRADIATE)

				if("se")
					var/se = scanner.occupant.dna.struc_enzymes
					var/targetblock = se_block

					if(!(se_block in list(2,8,10,12)) && prob (20)) // shifts the target slightly
						if(se_block <= 5)
							targetblock++
						else
							targetblock--
					var/block = getblock(scanner.occupant.dna.struc_enzymes,targetblock,3)

					var/result = ""
					for(var/sb = 1; sb <=3; sb++)
						var/temp = copytext(block,sb,sb+1)
						if(sb == subblock)
							temp = miniscramble(temp,radstrength,radduration)
						result += temp

					scanner.occupant.dna.struc_enzymes = setblock(se, se_block, result,3)
					domutcheck(scanner.occupant,scanner)
					scanner.occupant.apply_effect(radstrength+radduration, IRRADIATE)
				if("se-f")
					if(prob(80-radduration))
						randmutb(scanner.occupant)
						domutcheck(scanner.occupant,scanner)
					else
						randmuti(scanner.occupant)
						updateappearance(scanner.occupant,scanner.occupant.dna.uni_identity)
					scanner.occupant.apply_effect((radstrength*2)+radduration, IRRADIATE)

				if(null)
					if(prob(95))
						if(prob(75))
							randmutb(scanner.occupant)
						else
							randmuti(scanner.occupant)
					else
						if(prob(95))
							randmutg(scanner.occupant)
						else
							randmuti(scanner.occupant)
					scanner.occupant.apply_effect((radstrength*3)+radduration*3, IRRADIATE)


			scanner.locked = lock_state
			interact()

	proc/rejuv()
		if(!viable)
			popup.set_content("No viable occupant detected.")
			popup.open()
		var/mob/living/carbon/human/H = scanner.occupant
		if(istype(H))
			var/inap = H.reagents.get_reagent_amount("inaprovaline") // oh my *god* this section was ugly before I shortened it

			if(inap < (REJUVENATORS_MAX - REJUVENATORS_INJECT))
				H.reagents.add_reagent("inaprovaline", REJUVENATORS_INJECT)
			else
				H.reagents.add_reagent("inaprovaline", max(REJUVENATORS_MAX - inap,0))

/*
/obj/machinery/computer/scan_consolenew/Topic(href, href_list)

	temp_html = null
	var/temp_header_html = null
	var/temp_footer_html = null

	scanner_status_html = null // Scanner status is reset each update
	var/mob/living/occupant = scanner.occupant
	var/viable_occupant = (occupant && occupant.dna && !(NOCLONE in occupant.mutations))
	var/mob/living/carbon/human/human_occupant = scanner.occupant

	if(href_list["screen"]) // Passing a screen is only a request, we set current_screen here but it can be overridden below if necessary
		current_screen = href_list["screen"]

	if(!viable_occupant) // If there is no viable occupant only allow certain screens
		var/allowed_no_occupant_screens = list("mainmenu", "radsetmenu", "buffermenu") //These are the screens which will be allowed if there's no occupant
		if(!(current_screen in allowed_no_occupant_screens))
			href_list = new /list(0) // clear list of options
			current_screen = "mainmenu"


	if(!current_screen) // If no screen is set default to mainmenu
		current_screen = "mainmenu"


	if(!scanner) //Is the scanner not connected?
		scanner_status_html = "<span class='bad'>ERROR: No DNA Scanner connected.</span>"
		current_screen = null // blank does not exist in the switch below, so no screen will be outputted
		updateUsrDialog()
		return

	usr.set_machine(src)
	if(href_list["locked"])
		if(scanner.occupant)
			scanner.locked = !( scanner.locked )
	////////////////////////////////////////////////////////
	if(href_list["genpulse"])
		if(!viable_occupant)//Makes sure someone is in there (And valid) before trying anything
			temp_html = text("No viable occupant detected.")//More than anything, this just acts as a sanity check in case the option DOES appear for whatever reason
			//usr << browse(temp_html, "window=scannernew;size=550x650")
			//onclose(usr, "scannernew")
			popup.set_content(temp_html)
			popup.open()
		else

			temp_html = text("Working ... Please wait ([] Seconds)", radduration)
			popup.set_content(temp_html)
			popup.open()
			var/lock_state = scanner.locked
			scanner.locked = 1//lock it
			sleep(10*radduration)
			if(!scanner.occupant)
				temp_html = null
				return null
			if(prob(95))
				if(prob(75))
					randmutb(scanner.occupant)
				else
					randmuti(scanner.occupant)
			else
				if(prob(95))
					randmutg(scanner.occupant)
				else
					randmuti(scanner.occupant)
			scanner.occupant.apply_effect((radstrength*3)+radduration*3, IRRADIATE)
			scanner.locked = lock_state
			temp_html = null
			dopage(src,"screen=radsetmenu")
	if(href_list["radleplus"])
		if(!viable_occupant)
			temp_html = text("No viable occupant detected.")
			popup.set_content(temp_html)
			popup.open()
		if(radduration < 20)
			radduration++
			radduration++
		dopage(src,"screen=radsetmenu")
	if(href_list["radleminus"])
		if(!viable_occupant)
			temp_html = text("No viable occupant detected.")
			popup.set_content(temp_html)
			popup.open()
		if(radduration > 2)
			radduration--
			radduration--
		dopage(src,"screen=radsetmenu")
	if(href_list["radinplus"])
		if(radstrength < 10)
			radstrength++
		dopage(src,"screen=radsetmenu")
	if(href_list["radinminus"])
		if(radstrength > 1)
			radstrength--
		dopage(src,"screen=radsetmenu")
	////////////////////////////////////////////////////////
	if(href_list["unimenuplus"])
		if(ui_block < 13)
			ui_block++
		else
			ui_block = 1
		dopage(src,"screen=unimenu")
	if(href_list["unimenuminus"])
		if(ui_block > 1)
			ui_block--
		else
			ui_block = 13
		dopage(src,"screen=unimenu")
	if(href_list["unimenusubplus"])
		if(subblock < 3)
			subblock++
		else
			subblock = 1
		dopage(src,"screen=unimenu")
	if(href_list["unimenusubminus"])
		if(subblock > 1)
			subblock--
		else
			subblock = 3
		dopage(src,"screen=unimenu")
	if(href_list["unimenutargetplus"])
		if(unitarget < 15)
			unitarget++
			unitargethex = unitarget
			switch(unitarget)
				if(10)
					unitargethex = "A"
				if(11)
					unitargethex = "B"
				if(12)
					unitargethex = "C"
				if(13)
					unitargethex = "D"
				if(14)
					unitargethex = "E"
				if(15)
					unitargethex = "F"
		else
			unitarget = 0
			unitargethex = 0
		dopage(src,"screen=unimenu")
	if(href_list["unimenutargetminus"])
		if(unitarget > 0)
			unitarget--
			unitargethex = unitarget
			switch(unitarget)
				if(10)
					unitargethex = "A"
				if(11)
					unitargethex = "B"
				if(12)
					unitargethex = "C"
				if(13)
					unitargethex = "D"
				if(14)
					unitargethex = "E"
		else
			unitarget = 15
			unitargethex = "F"
		dopage(src,"screen=unimenu")
	if(href_list["uimenuset"] && href_list["uimenusubset"]) // This chunk of code updates selected block / sub-block based on click
		var/menuset = text2num(href_list["uimenuset"])
		var/menusubset = text2num(href_list["uimenusubset"])
		if((menuset <= 13) && (menuset >= 1))
			ui_block = menuset
		if((menusubset <= 3) && (menusubset >= 1))
			subblock = menusubset
		dopage(src, "unimenu")
	if(href_list["unipulse"])
		if(scanner.occupant)
			var/block
			var/newblock
			var/tstructure2
			block = getblock(getblock(scanner.occupant.dna.uni_identity,ui_block,3),subblock,1)

			temp_html = text("Working ... Please wait ([] Seconds)", radduration)
			popup.set_content(temp_html)
			popup.open()
			var/lock_state = scanner.locked
			scanner.locked = 1//lock it
			sleep(10*radduration)
			if(!scanner.occupant)
				temp_html = null
				return null
			///
			if(prob((80 + (radduration / 2))))
				block = miniscrambletarget(num2text(unitarget), radstrength, radduration)
				newblock = null
				if(subblock == 1) newblock = block + getblock(getblock(scanner.occupant.dna.uni_identity,ui_block,3),2,1) + getblock(getblock(scanner.occupant.dna.uni_identity,ui_block,3),3,1)
				if(subblock == 2) newblock = getblock(getblock(scanner.occupant.dna.uni_identity,ui_block,3),1,1) + block + getblock(getblock(scanner.occupant.dna.uni_identity,ui_block,3),3,1)
				if(subblock == 3) newblock = getblock(getblock(scanner.occupant.dna.uni_identity,ui_block,3),1,1) + getblock(getblock(scanner.occupant.dna.uni_identity,ui_block,3),2,1) + block
				tstructure2 = setblock(scanner.occupant.dna.uni_identity, ui_block, newblock,3)
				scanner.occupant.dna.uni_identity = tstructure2
				updateappearance(scanner.occupant,scanner.occupant.dna.uni_identity)
				scanner.occupant.apply_effect(radstrength+radduration, IRRADIATE)
			else
				if(prob(20+radstrength))
					randmutb(scanner.occupant)
					domutcheck(scanner.occupant,scanner)
				else
					randmuti(scanner.occupant)
					updateappearance(scanner.occupant,scanner.occupant.dna.uni_identity)
				scanner.occupant.apply_effect((radstrength*2)+radduration, IRRADIATE)
			scanner.locked = lock_state
		dopage(src,"screen=unimenu")

	////////////////////////////////////////////////////////
	if(href_list["rejuv"])
		if(!viable_occupant)
			temp_html = text("No viable occupant detected.")
			popup.set_content(temp_html)
			popup.open()
		else
			if(human_occupant)
				if(human_occupant.reagents.get_reagent_amount("inaprovaline") < REJUVENATORS_MAX)
					if(human_occupant.reagents.get_reagent_amount("inaprovaline") < (REJUVENATORS_MAX - REJUVENATORS_INJECT))
						human_occupant.reagents.add_reagent("inaprovaline", REJUVENATORS_INJECT)
					else
						human_occupant.reagents.add_reagent("inaprovaline", round(REJUVENATORS_MAX - human_occupant.reagents.get_reagent_amount("inaprovaline")))
//				to_chat(usr, text("Occupant now has [] units of rejuvenation in his/her bloodstream.", human_occupant.reagents.get_reagent_amount("inaprovaline")))

	////////////////////////////////////////////////////////
	if(href_list["strucmenuplus"])
		if(se_block < 14)
			se_block++
		else
			se_block = 1
		dopage(src,"screen=strucmenu")
	if(href_list["strucmenuminus"])
		if(se_block > 1)
			se_block--
		else
			se_block = 14
		dopage(src,"screen=strucmenu")
	if(href_list["strucmenusubplus"])
		if(subblock < 3)
			subblock++
		else
			subblock = 1
		dopage(src,"screen=strucmenu")
	if(href_list["strucmenusubminus"])
		if(subblock > 1)
			subblock--
		else
			subblock = 3
		dopage(src,"screen=strucmenu")
	if(href_list["semenuset"] && href_list["semenusubset"]) // This chunk of code updates selected block / sub-block based on click (se stands for strutural enzymes)
		var/menuset = text2num(href_list["semenuset"])
		var/menusubset = text2num(href_list["semenusubset"])
		if((menuset <= 14) && (menuset >= 1))
			se_block = menuset
		if((menusubset <= 3) && (menusubset >= 1))
			subblock = menusubset
		dopage(src, "strucmenu")
	if(href_list["strucpulse"])
		var/block
		var/newblock
		var/tstructure2
		var/oldblock
		var/lock_state = scanner.locked
		scanner.locked = 1//lock it
		if(viable_occupant)
			block = getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),subblock,1)

			temp_html = text("Working ... Please wait ([] Seconds)", radduration)
			popup.set_content(temp_html)
			popup.open()
			sleep(10*radduration)
		else
			temp_html = null
			return null
		///
		if(viable_occupant)
			if(prob((80 + (radduration / 2))))
				if((se_block != 2 || se_block != 12 || se_block != 8 || se_block || 10) && prob (20))
					oldblock = se_block
					block = miniscramble(block, radstrength, radduration)
					newblock = null
					if(se_block > 1 && se_block < 5)
						se_block++
					else if(se_block > 5 && se_block < 14)
						se_block--
					if(subblock == 1) newblock = block + getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),2,1) + getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),3,1)
					if(subblock == 2) newblock = getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),1,1) + block + getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),3,1)
					if(subblock == 3) newblock = getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),1,1) + getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),2,1) + block
					tstructure2 = setblock(scanner.occupant.dna.struc_enzymes, se_block, newblock,3)
					scanner.occupant.dna.struc_enzymes = tstructure2
					domutcheck(scanner.occupant,scanner)
					scanner.occupant.apply_effect(radstrength+radduration, IRRADIATE)
					se_block = oldblock
				else
				//
					block = miniscramble(block, radstrength, radduration)
					newblock = null
					if(subblock == 1) newblock = block + getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),2,1) + getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),3,1)
					if(subblock == 2) newblock = getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),1,1) + block + getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),3,1)
					if(subblock == 3) newblock = getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),1,1) + getblock(getblock(scanner.occupant.dna.struc_enzymes,se_block,3),2,1) + block
					tstructure2 = setblock(scanner.occupant.dna.struc_enzymes, se_block, newblock,3)
					scanner.occupant.dna.struc_enzymes = tstructure2
					domutcheck(scanner.occupant,scanner)
					scanner.occupant.apply_effect(radstrength+radduration, IRRADIATE)
			else
				if(prob(80-radduration))
					randmutb(scanner.occupant)
					domutcheck(scanner.occupant,scanner)
				else
					randmuti(scanner.occupant)
					updateappearance(scanner.occupant,scanner.occupant.dna.uni_identity)
				scanner.occupant.apply_effect((radstrength*2)+radduration, IRRADIATE)
		scanner.locked = lock_state
		///
		dopage(src,"screen=strucmenu")

	////////////////////////////////////////////////////////
	if(href_list["b1addui"])
		if(scanner.occupant && scanner.occupant.dna)
			buffer1iue = 0
			buffer1 = scanner.occupant.dna.uni_identity
			if(!istype(scanner.occupant,/mob/living/carbon/human))
				buffer1owner = scanner.occupant.name
			else
				buffer1owner = scanner.occupant.real_name
			buffer1label = "Unique Identifier"
			buffer1type = "ui"
			dopage(src,"screen=buffermenu")
	if(href_list["b1adduiue"])
		if(scanner.occupant && scanner.occupant.dna)
			buffer1 = scanner.occupant.dna.uni_identity
			if(!istype(scanner.occupant,/mob/living/carbon/human))
				buffer1owner = scanner.occupant.name
			else
				buffer1owner = scanner.occupant.real_name
			buffer1label = "Unique Identifier & Unique Enzymes"
			buffer1type = "ui"
			buffer1iue = 1
			dopage(src,"screen=buffermenu")
	if(href_list["b2adduiue"])
		if(scanner.occupant && scanner.occupant.dna)
			buffer2 = scanner.occupant.dna.uni_identity
			if(!istype(scanner.occupant,/mob/living/carbon/human))
				buffer2owner = scanner.occupant.name
			else
				buffer2owner = scanner.occupant.real_name
			buffer2label = "Unique Identifier & Unique Enzymes"
			buffer2type = "ui"
			buffer2iue = 1
			dopage(src,"screen=buffermenu")
	if(href_list["b3adduiue"])
		if(scanner.occupant && scanner.occupant.dna)
			buffer3 = scanner.occupant.dna.uni_identity
			if(!istype(scanner.occupant,/mob/living/carbon/human))
				buffer3owner = scanner.occupant.name
			else
				buffer3owner = scanner.occupant.real_name
			buffer3label = "Unique Identifier & Unique Enzymes"
			buffer3type = "ui"
			buffer3iue = 1
			dopage(src,"screen=buffermenu")
	if(href_list["b2addui"])
		if(scanner.occupant && scanner.occupant.dna)
			buffer2iue = 0
			buffer2 = scanner.occupant.dna.uni_identity
			if(!istype(scanner.occupant,/mob/living/carbon/human))
				buffer2owner = scanner.occupant.name
			else
				buffer2owner = scanner.occupant.real_name
			buffer2label = "Unique Identifier"
			buffer2type = "ui"
			dopage(src,"screen=buffermenu")
	if(href_list["b3addui"])
		if(scanner.occupant && scanner.occupant.dna)
			buffer3iue = 0
			buffer3 = scanner.occupant.dna.uni_identity
			if(!istype(scanner.occupant,/mob/living/carbon/human))
				buffer3owner = scanner.occupant.name
			else
				buffer3owner = scanner.occupant.real_name
			buffer3label = "Unique Identifier"
			buffer3type = "ui"
			dopage(src,"screen=buffermenu")
	if(href_list["b1addse"])
		if(scanner.occupant && scanner.occupant.dna)
			buffer1iue = 0
			buffer1 = scanner.occupant.dna.struc_enzymes
			if(!istype(scanner.occupant,/mob/living/carbon/human))
				buffer1owner = scanner.occupant.name
			else
				buffer1owner = scanner.occupant.real_name
			buffer1label = "Structural Enzymes"
			buffer1type = "se"
			dopage(src,"screen=buffermenu")
	if(href_list["b2addse"])
		if(scanner.occupant && scanner.occupant.dna)
			buffer2iue = 0
			buffer2 = scanner.occupant.dna.struc_enzymes
			if(!istype(scanner.occupant,/mob/living/carbon/human))
				buffer2owner = scanner.occupant.name
			else
				buffer2owner = scanner.occupant.real_name
			buffer2label = "Structural Enzymes"
			buffer2type = "se"
			dopage(src,"screen=buffermenu")
	if(href_list["b3addse"])
		if(scanner.occupant && scanner.occupant.dna)
			buffer3iue = 0
			buffer3 = scanner.occupant.dna.struc_enzymes
			if(!istype(scanner.occupant,/mob/living/carbon/human))
				buffer3owner = scanner.occupant.name
			else
				buffer3owner = scanner.occupant.real_name
			buffer3label = "Structural Enzymes"
			buffer3type = "se"
			dopage(src,"screen=buffermenu")
	if(href_list["b1clear"])
		buffer1 = null
		buffer1owner = null
		buffer1label = null
		buffer1iue = null
		dopage(src,"screen=buffermenu")
	if(href_list["b2clear"])
		buffer2 = null
		buffer2owner = null
		buffer2label = null
		buffer2iue = null
		dopage(src,"screen=buffermenu")
	if(href_list["b3clear"])
		buffer3 = null
		buffer3owner = null
		buffer3label = null
		buffer3iue = null
		dopage(src,"screen=buffermenu")
	if(href_list["b1label"])
		buffer1label = sanitize(input("New Label:","Edit Label","Infos here"))
		dopage(src,"screen=buffermenu")
	if(href_list["b2label"])
		buffer2label = sanitize(input("New Label:","Edit Label","Infos here"))
		dopage(src,"screen=buffermenu")
	if(href_list["b3label"])
		buffer3label = sanitize(input("New Label:","Edit Label","Infos here"))
		dopage(src,"screen=buffermenu")
	if(href_list["b1transfer"])
		if(!scanner.occupant || (NOCLONE in scanner.occupant.mutations) || !scanner.occupant.dna)
			return
		if(buffer1type == "ui")
			if(buffer1iue)
				scanner.occupant.real_name = buffer1owner
				scanner.occupant.name = buffer1owner
			scanner.occupant.dna.uni_identity = buffer1
			updateappearance(scanner.occupant,scanner.occupant.dna.uni_identity)
		else if(buffer1type == "se")
			scanner.occupant.dna.struc_enzymes = buffer1
			domutcheck(scanner.occupant,scanner)
		temp_html = "Transfered."
		scanner.occupant.apply_effect(rand(20,50), IRRADIATE)

	if(href_list["b2transfer"])
		if(!scanner.occupant || (NOCLONE in scanner.occupant.mutations) || !scanner.occupant.dna)
			return
		if(buffer2type == "ui")
			if(buffer2iue)
				scanner.occupant.real_name = buffer2owner
				scanner.occupant.name = buffer2owner
			scanner.occupant.dna.uni_identity = buffer2
			updateappearance(scanner.occupant,scanner.occupant.dna.uni_identity)
		else if(buffer2type == "se")
			scanner.occupant.dna.struc_enzymes = buffer2
			domutcheck(scanner.occupant,scanner)
		temp_html = "Transfered."
		scanner.occupant.apply_effect(rand(20,50), IRRADIATE)

	if(href_list["b3transfer"])
		if(!scanner.occupant || (NOCLONE in scanner.occupant.mutations) || !scanner.occupant.dna)
			return
		if(buffer3type == "ui")
			if(buffer3iue)
				scanner.occupant.real_name = buffer3owner
				scanner.occupant.name = buffer3owner
			scanner.occupant.dna.uni_identity = buffer3
			updateappearance(scanner.occupant,scanner.occupant.dna.uni_identity)
		else if(buffer3type == "se")
			scanner.occupant.dna.struc_enzymes = buffer3
			domutcheck(scanner.occupant,scanner)
		temp_html = "Transfered."
		scanner.occupant.apply_effect(rand(20,50), IRRADIATE)

	if(href_list["b1injector"])
		if(injectorready)
			var/obj/item/tool/medical/dnainjector/I = new /obj/item/tool/medical/dnainjector
			I.dna = buffer1
			I.dnatype = buffer1type
			I.loc = loc
			I.name += " ([buffer1label])"
			if(buffer1iue) I.ue = buffer1owner //lazy haw haw
			temp_html = "Injector created."

			injectorready = 0
			spawn(300)
				injectorready = 1
		else
			temp_html = "Replicator not ready yet."

	if(href_list["b2injector"])
		if(injectorready)
			var/obj/item/tool/medical/dnainjector/I = new /obj/item/tool/medical/dnainjector
			I.dna = buffer2
			I.dnatype = buffer2type
			I.loc = loc
			I.name += " ([buffer2label])"
			if(buffer2iue) I.ue = buffer2owner //lazy haw haw
			temp_html = "Injector created."

			injectorready = 0
			spawn(300)
				injectorready = 1
		else
			temp_html = "Replicator not ready yet."

	if(href_list["b3injector"])
		if(injectorready)
			var/obj/item/tool/medical/dnainjector/I = new /obj/item/tool/medical/dnainjector
			I.dna = buffer3
			I.dnatype = buffer3type
			I.loc = loc
			I.name += " ([buffer3label])"
			if(buffer3iue) I.ue = buffer3owner //lazy haw haw
			temp_html = "Injector created."

			injectorready = 0
			spawn(300)
				injectorready = 1
		else
			temp_html = "Replicator not ready yet."

	////////////////////////////////////////////////////////
	if(href_list["load_disk"])
		var/buffernum = text2num(href_list["load_disk"])
		if((buffernum > 3) || (buffernum < 1))
			return
		if((isnull(diskette)) || (!diskette.data) || (diskette.data == ""))
			return
		switch(buffernum)
			if(1)
				buffer1 = diskette.data
				buffer1type = diskette.data_type
				buffer1iue = diskette.ue
				buffer1owner = diskette.owner
			if(2)
				buffer2 = diskette.data
				buffer2type = diskette.data_type
				buffer2iue = diskette.ue
				buffer2owner = diskette.owner
			if(3)
				buffer3 = diskette.data
				buffer3type = diskette.data_type
				buffer3iue = diskette.ue
				buffer3owner = diskette.owner
		temp_html = "Data loaded."

	if(href_list["save_disk"])
		var/buffernum = text2num(href_list["save_disk"])
		if((buffernum > 3) || (buffernum < 1))
			return
		if((isnull(diskette)) || (diskette.read_only))
			return
		switch(buffernum)
			if(1)
				diskette.data = buffer1
				diskette.data_type = buffer1type
				diskette.ue = buffer1iue
				diskette.owner = buffer1owner
				diskette.name = "data disk - '[buffer1owner]'"
			if(2)
				diskette.data = buffer2
				diskette.data_type = buffer2type
				diskette.ue = buffer2iue
				diskette.owner = buffer2owner
				diskette.name = "data disk - '[buffer2owner]'"
			if(3)
				diskette.data = buffer3
				diskette.data_type = buffer3type
				diskette.ue = buffer3iue
				diskette.owner = buffer3owner
				diskette.name = "data disk - '[buffer3owner]'"
		temp_html = "Data saved."
	if(href_list["eject_disk"])
		if(!diskette)
			return
		diskette.loc = get_turf(src)
		diskette = null
	////////////////////////////////////////////////////////

	temp_html = temp_header_html
	switch(current_screen)
		if("mainmenu")
			temp_html += "<h3>Main Menu</h3>"
			if(viable_occupant) //is there REALLY someone in there who can be modified?
				temp_html += "<A href='?src=[UID()];screen=unimenu'>Modify Unique Identifier</A><br />"
				temp_html += "<A href='?src=[UID()];screen=strucmenu'>Modify Structural Enzymes</A><br /><br />"
			else
				temp_html += "<span class='linkOff'>Modify Unique Identifier</span><br />"
				temp_html += "<span class='linkOff'>Modify Structural Enzymes</span><br /><br />"
			temp_html += "<A href='?src=[UID()];screen=radsetmenu'>Radiation Emitter Settings</A><br /><br />"
			temp_html += "<A href='?src=[UID()];screen=buffermenu'>Transfer Buffer</A><br /><br />"

		if("unimenu")
			if(!viable_occupant)
				temp_html = text("No viable occupant detected.")
				popup.set_content(temp_html)
				popup.open()
			else
				temp_html = "<A href='?src=[UID()];screen=mainmenu'><< Main Menu</A><br />"
				temp_html += "<h3>Modify Unique Identifier</h3>"
				temp_html += "<div align='center'>Unique Identifier:<br />[getblockstring(scanner.occupant.dna.uni_identity,ui_block,subblock,3, src,1)]<br /><br />"
				temp_html += "Selected Block: <A href='?src=[UID()];unimenuminus=1'><-</A> <B>[ui_block]</B> <A href='?src=[UID()];unimenuplus=1'>-></A><br /><br />"
				temp_html += "Selected Sub-Block: <A href='?src=[UID()];unimenusubminus=1'><-</A> <B>[subblock]</B> <A href='?src=[UID()];unimenusubplus=1'>-></A><br /><br />"
				temp_html += "Selected Target: <A href='?src=[UID()];unimenutargetminus=1'><-</A> <B>[unitargethex]</B> <A href='?src=[UID()];unimenutargetplus=1'>-></A><br /><br />"
				temp_html += "<B>Modify Block</B><br />"
				temp_html += "<A href='?src=[UID()];unipulse=1'>Irradiate</A></div>"

		if("strucmenu")
			if(!viable_occupant)
				temp_html = text("No viable occupant detected.")
				popup.set_content(temp_html)
				popup.open()
			else
				temp_html = "<A href='?src=[UID()];screen=mainmenu'><< Main Menu</A><br />"
				temp_html += "<h3>Modify Structural Enzymes</h3>"
				temp_html += "<div align='center'>Structural Enzymes: [getblockstring(scanner.occupant.dna.struc_enzymes,se_block,subblock,3,src,0)]<br /><br />"
				temp_html += "Selected Block: <A href='?src=[UID()];strucmenuminus=1'><-</A> <B>[se_block]</B> <A href='?src=[UID()];strucmenuplus=1'>-></A><br /><br />"
				temp_html += "Selected Sub-Block: <A href='?src=[UID()];strucmenusubminus=1'><-</A> <B>[subblock]</B> <A href='?src=[UID()];strucmenusubplus=1'>-></A><br /><br />"
				temp_html += "<B>Modify Block</B><br />"
				temp_html += "<A href='?src=[UID()];strucpulse=1'>Irradiate</A></div>"

		if("radsetmenu")
			temp_html = "<A href='?src=[UID()];screen=mainmenu'><< Main Menu</A><br />"
			temp_html += "<h3>Radiation Emitter Settings</h3>"
			if(viable_occupant)
				temp_html += "<A href='?src=[UID()];genpulse=1'>Pulse Radiation</A>"
			else
				temp_html += "<span class='linkOff'>Pulse Radiation</span>"
			temp_html += "<br /><br />Radiation Duration: <A href='?src=[UID()];radleminus=1'>-</A> <font color='green'><B>[radduration]</B></FONT> <A href='?src=[UID()];radleplus=1'>+</A><br />"
			temp_html += "Radiation Intensity: <A href='?src=[UID()];radinminus=1'>-</A> <font color='green'><B>[radstrength]</B></FONT> <A href='?src=[UID()];radinplus=1'>+</A><br /><br />"

		if("buffermenu")
			temp_html = "<A href='?src=[UID()];screen=mainmenu'><< Main Menu</A><br />"
			temp_html += "<h3>Transfer Buffer</h3>"
			temp_html += "<h4>Buffer 1:</h4>"
			if(!(buffer1))
				temp_html += "<i>Buffer Empty</i><br />"
			else
				temp_html += text("Data: <font class='highlight'>[]</FONT><br />", buffer1)
				temp_html += text("By: <font class='highlight'>[]</FONT><br />", buffer1owner)
				temp_html += text("Label: <font class='highlight'>[]</FONT><br />", buffer1label)
			if(viable_occupant) temp_html += "Save : <A href='?src=[UID()];b1addui=1'>UI</A> - <A href='?src=[UID()];b1adduiue=1'>UI+UE</A> - <A href='?src=[UID()];b1addse=1'>SE</A><br />"
			if(buffer1) temp_html += "Transfer to: <A href='?src=[UID()];b1transfer=1'>Occupant</A> - <A href='?src=[UID()];b1injector=1'>Injector</A><br />"
			//if(buffer1) temp_html += "<A href='?src=[UID()];b1iso=1'>Isolate Block</A><br />"
			if(buffer1) temp_html += "Disk: <A href='?src=[UID()];save_disk=1'>Save To</a> | <A href='?src=[UID()];load_disk=1'>Load From</a><br />"
			if(buffer1) temp_html += "<A href='?src=[UID()];b1label=1'>Edit Label</A><br />"
			if(buffer1) temp_html += "<A href='?src=[UID()];b1clear=1'>Clear Buffer</A><br /><br />"
			if(!buffer1) temp_html += "<br />"
			temp_html += "<h4>Buffer 2:</h4>"
			if(!(buffer2))
				temp_html += "<i>Buffer Empty</i><br />"
			else
				temp_html += text("Data: <font class='highlight'>[]</FONT><br />", buffer2)
				temp_html += text("By: <font class='highlight'>[]</FONT><br />", buffer2owner)
				temp_html += text("Label: <font class='highlight'>[]</FONT><br />", buffer2label)
			if(viable_occupant) temp_html += "Save : <A href='?src=[UID()];b2addui=1'>UI</A> - <A href='?src=[UID()];b2adduiue=1'>UI+UE</A> - <A href='?src=[UID()];b2addse=1'>SE</A><br />"
			if(buffer2) temp_html += "Transfer to: <A href='?src=[UID()];b2transfer=1'>Occupant</A> - <A href='?src=[UID()];b2injector=1'>Injector</A><br />"
			//if(buffer2) temp_html += "<A href='?src=[UID()];b2iso=1'>Isolate Block</A><br />"
			if(buffer2) temp_html += "Disk: <A href='?src=[UID()];save_disk=2'>Save To</a> | <A href='?src=[UID()];load_disk=2'>Load From</a><br />"
			if(buffer2) temp_html += "<A href='?src=[UID()];b2label=1'>Edit Label</A><br />"
			if(buffer2) temp_html += "<A href='?src=[UID()];b2clear=1'>Clear Buffer</A><br /><br />"
			if(!buffer2) temp_html += "<br />"
			temp_html += "<h4>Buffer 3:</h4>"
			if(!(buffer3))
				temp_html += "<i>Buffer Empty</i><br />"
			else
				temp_html += text("Data: <font class='highlight'>[]</FONT><br />", buffer3)
				temp_html += text("By: <font class='highlight'>[]</FONT><br />", buffer3owner)
				temp_html += text("Label: <font class='highlight'>[]</FONT><br />", buffer3label)
			if(viable_occupant) temp_html += "Save : <A href='?src=[UID()];b3addui=1'>UI</A> - <A href='?src=[UID()];b3adduiue=1'>UI+UE</A> - <A href='?src=[UID()];b3addse=1'>SE</A><br />"
			if(buffer3) temp_html += "Transfer to: <A href='?src=[UID()];b3transfer=1'>Occupant</A> - <A href='?src=[UID()];b3injector=1'>Injector</A><br />"
			//if(buffer3) temp_html += "<A href='?src=[UID()];b3iso=1'>Isolate Block</A><br />"
			if(buffer3) temp_html += "Disk: <A href='?src=[UID()];save_disk=3'>Save To</a> | <A href='?src=[UID()];load_disk=3'>Load From</a><br />"
			if(buffer3) temp_html += "<A href='?src=[UID()];b3label=1'>Edit Label</A><br />"
			if(buffer3) temp_html += "<A href='?src=[UID()];b3clear=1'>Clear Buffer</A><br /><br />"
			if(!buffer3) temp_html += "<br />"
	temp_html += temp_footer_html

	if(viable_occupant && !scanner_status_html && occupant) //is there REALLY someone in there?
		scanner_status_html = "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [occupant.health]%;' class='progressFill good'></div></div><div class='statusValue'>[occupant.health]%</div></div>"
		scanner_status_html += "<div class='line'><div class='statusLabel'>Radiation Level:</div><div class='progressBar'><div style='width: [occupant.radiation]%;' class='progressFill bad'></div></div><div class='statusValue'>[occupant.radiation]%</div></div>"
		if(human_occupant)
			var/rejuvenators = round(human_occupant.reagents.get_reagent_amount("inaprovaline") / REJUVENATORS_MAX * 100)
			scanner_status_html += "<div class='line'><div class='statusLabel'>Rejuvenators:</div><div class='progressBar'><div style='width: [rejuvenators]%;' class='progressFill highlight'></div></div><div class='statusValue'>[human_occupant.reagents.get_reagent_amount("inaprovaline")] units</div></div>"

		if(current_screen == "mainmenu")
			scanner_status_html += "<div class='line'><div class='statusLabel'>Unique Enzymes :</div><div class='statusValue'><span class='highlight'>[uppertext(occupant.dna.unique_enzymes)]</span></div></div>"
			scanner_status_html += "<div class='line'><div class='statusLabel'>Unique Identifier:</div><div class='statusValue'><span class='highlight'>[occupant.dna.uni_identity]</span></div></div>"
			scanner_status_html += "<div class='line'><div class='statusLabel'>Structural Enzymes:</div><div class='statusValue'><span class='highlight'>[occupant.dna.struc_enzymes]</span></div></div>"

	var/dat = "<h3>Scanner Status</h3>"

	var/occupant_status = "Scanner Unoccupied"
	if(occupant && occupant.dna) //is there REALLY someone in there?
		if(!istype(occupant,/mob/living/carbon/human))
			sleep(1)
		if(NOCLONE in occupant.mutations)
			occupant_status = "<span class='bad'>Invalid DNA structure</span>"
		else
			switch(occupant.stat) // obvious, see what their status is
				if(0)
					occupant_status = "<span class='good'>Conscious</span>"
				if(1)
					occupant_status = "<span class='average'>Unconscious</span>"
				else
					occupant_status = "<span class='bad'>DEAD</span>"

		occupant_status = "[occupant.name] => [occupant_status]<br />"

	dat += "<div class='statusDisplay'>[occupant_status][scanner_status_html]</div>"

	var/scanner_access_text = "Lock Scanner"
	if(scanner.locked)
		scanner_access_text = "Unlock Scanner"

	dat += "<A href='?src=[UID()];'>Scan</A> "

	if(occupant && occupant.dna)
		dat += "<A href='?src=[UID()];locked=1'>[scanner_access_text]</A> "
		if(human_occupant)
			dat += "<A href='?src=[UID()];rejuv=1'>Inject Rejuvenators</A><br />"
		else
			dat += "<span class='linkOff'>Inject Rejuvenators</span><br />"
	else
		dat += "<span class='linkOff'>[scanner_access_text]</span> "
		dat += "<span class='linkOff'>Inject Rejuvenators</span><br />"

	if(!isnull(diskette))
		dat += "<A href='?src=[UID()];eject_disk=1'>Eject Disk</A><br />"

	dat += "<br />"

	if(temp_html)
		dat += temp_html

	popup.set_content(dat)
	popup.open()
*/
