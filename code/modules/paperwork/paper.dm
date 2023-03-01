/*
 * Paper
 * also scraps of paper
 */

/obj/item/paper
	name = "paper"
	gender = PLURAL
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	layer = 4
	pressure_resistance = 0
	slot_flags = SLOT_HEAD
	body_parts_covered = HEAD
	resistance_flags = FLAMMABLE
	max_integrity = 50
	attack_verb = list("bapped")
	dog_fashion = /datum/dog_fashion/head
	var/header //Above the main body, displayed at the top
	var/info		//What's actually written on the paper.
	var/footer 	//The bottom stuff before the stamp but after the body
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamps		//The (text for the) stamps on the paper.
	var/fields		//Amount of user created fields
	var/list/stamped
	var/ico[0]      //Icons and
	var/offset_x[0] //offsets stored for later
	var/offset_y[0] //usage by the photocopier
	var/rigged = 0
	var/spam_flag = 0
	var/contact_poison // Reagent ID to transfer on contact
	var/contact_poison_volume = 0
	var/contact_poison_poisoner = null
	var/paper_width = 400 //Width of the window that opens
	var/paper_width_big = 600
	var/paper_height = 400 //Height of the window that opens
	var/paper_height_big = 700

	var/const/deffont = "Verdana"
	var/const/signfont = "Times New Roman"
	var/const/crayonfont = "Comic Sans MS"
	var/time = "00:00"

//lipstick wiping is in code/game/objects/items/weapons/cosmetics.dm!

/obj/item/paper/New()
	..()
	pixel_y = rand(-8, 8)
	pixel_x = rand(-9, 9)

	spawn(2)
		update_icon()
		updateinfolinks()

/obj/item/paper/update_icon()
	..()
	if(info)
		icon_state = "paper_words"
		return
	icon_state = "paper"

/obj/item/paper/examine(mob/user)
	. = ..()
	if(user.is_literate())
		if(in_range(user, src) || istype(user, /mob/dead/observer))
			show_content(user)
		else
			. += "<span class='notice'>You have to go closer if you want to read it.</span>"
	else
		. += "<span class='notice'>You don't know how to read.</span>"

/obj/item/paper/proc/show_content(var/mob/user, var/forceshow = 0, var/forcestars = 0, var/infolinks = 0, var/view = 1)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	var/data
	var/stars = (!user.say_understands(null, GLOB.all_languages["Galactic Common"]) && !forceshow) || forcestars
	if(stars) //assuming all paper is written in common is better than hardcoded type checks
		data = "[header][stars(info)][footer][stamps]"
	else
		data = "[header]<div id='markdown'>[infolinks ? info_links : info]</div>[footer][stamps]"
	if(config.twitch_censor)
		for(var/char in config.twich_censor_list)
			data = replacetext(data, char, config.twich_censor_list[char])
	if(view)
		if(!istype(src, /obj/item/paper/form) && length(info) > 1024)
			paper_width = paper_width_big
			paper_height = paper_height_big
		var/datum/browser/popup = new(user, "Paper[UID()]", , paper_width, paper_height)
		popup.stylesheets = list()
		popup.set_content(data)
		if(!stars)
			popup.add_script("marked.js", 'html/browser/marked.js')
			popup.add_script("marked-paradise.js", 'html/browser/marked-paradise.js')
		popup.add_head_content("<title>[name]</title>")
		popup.open()
	return data

/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if((CLUMSY in usr.mutations) && prob(50))
		to_chat(usr, "<span class='warning'>You cut yourself on the paper.</span>")
		return
	if(!usr.is_literate())
		to_chat(usr, "<span class='notice'>You don't know how to read.</span>")
		return
	var/n_name = rename_interactive(usr)
	if(isnull(n_name))
		return
	if(n_name != "")
		desc = "This is a paper titled '" + name + "'."
	else
		desc = initial(desc)
	add_fingerprint(usr)
	return

/obj/item/paper/attack_self(mob/living/user as mob)
	user.examinate(src)
	if(rigged && (SSholiday.holidays && SSholiday.holidays[APRIL_FOOLS]))
		if(spam_flag == 0)
			spam_flag = 1
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			spawn(20)
				spam_flag = 0
	return

/obj/item/paper/attack_ai(var/mob/living/silicon/ai/user as mob)
	var/dist
	if(istype(user) && user.current) //is AI
		dist = get_dist(src, user.current)
	else //cyborg or AI not seeing through a camera
		dist = get_dist(src, user)
	if(dist < 2)
		show_content(user, forceshow = 1)
	else
		show_content(user, forcestars = 1)
	return

/obj/item/paper/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_selected == "eyes")
		user.visible_message("<span class='notice'>You show the paper to [M]. </span>", \
			"<span class='notice'> [user] holds up a paper and shows it to [M]. </span>")
		M.examinate(src)

	else if(user.zone_selected == "mouth")
		if(!istype(M, /mob))	return

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, "<span class='notice'>You wipe off your face with [src].</span>")
				H.lip_style = null
				H.update_body()
			else
				user.visible_message("<span class='warning'>[user] begins to wipe [H]'s face clean with \the [src].</span>", \
								 	 "<span class='notice'>You begin to wipe off [H]'s face.</span>")
				if(do_after(user, 10, target = H) && do_after(H, 10, 0))	//user needs to keep their active hand, H does not.
					user.visible_message("<span class='notice'>[user] wipes [H]'s face clean with \the [src].</span>", \
										 "<span class='notice'>You wipe off [H]'s face.</span>")
					H.lip_style = null
					H.update_body()
	else
		..()

/obj/item/paper/proc/addtofield(var/id, var/text, var/links = 0)
	if(id > MAX_PAPER_FIELDS)
		return

	var/locid = 0
	var/laststart = 1
	var/textindex = 1
	while(locid <= MAX_PAPER_FIELDS)
		var/istart = 0
		if(links)
			istart = findtext(info_links, "<span class=\"paper_field\">", laststart)
		else
			istart = findtext(info, "<span class=\"paper_field\">", laststart)

		if(istart==0)
			return // No field found with matching id

		laststart = istart+1
		locid++
		if(locid == id)
			var/iend = 1
			if(links)
				iend = findtext(info_links, "</span>", istart)
			else
				iend = findtext(info, "</span>", istart)

			//textindex = istart+26
			textindex = iend
			break

	if(links)
		var/before = copytext(info_links, 1, textindex)
		var/after = copytext(info_links, textindex)
		info_links = before + text + after
	else
		var/before = copytext(info, 1, textindex)
		var/after = copytext(info, textindex)
		info = before + text + after
		updateinfolinks()

/obj/item/paper/proc/updateinfolinks()
	info_links = info
	var/i = 0
	for(i=1,i<=fields,i++)
		var/write_1 = "<font face=\"[deffont]\"><A href='?src=[UID()];write=[i]'>write</A></font>"
		var/write_2 = "<font face=\"[deffont]\"><A href='?src=[UID()];auto_write=[i]'><span style=\"color: #409F47; font-size: 10px\">\[A\]</span></A></font>"
		addtofield(i, "[write_1][write_2]", 1)
	info_links = info_links + "<font face=\"[deffont]\"><A href='?src=[UID()];write=end'>write</A></font>"


/obj/item/paper/proc/clearpaper()
	info = null
	stamps = null
	stamped = list()
	overlays.Cut()
	updateinfolinks()
	update_icon()


/obj/item/paper/proc/parsepencode(var/t, var/obj/item/pen/P, mob/user as mob)
	t = pencode_to_html(html_encode(t), usr, P, TRUE, TRUE, TRUE, deffont, signfont, crayonfont)
	return t

/obj/item/paper/proc/populatefields()
		//Count the fields
	var/laststart = 1
	while(fields < MAX_PAPER_FIELDS)
		var/i = findtext(info, "<span class=\"paper_field\">", laststart)
		if(i==0)
			break
		laststart = i+1
		fields++


/obj/item/paper/proc/openhelp(mob/user as mob)
	user << browse({"<HTML><meta charset="UTF-8"><HEAD><TITLE>Pen Help</TITLE></HEAD>
	<BODY>
		<b><center>Crayon&Pen commands</center></b><br>
		<br>
		\[br\] : Creates a linebreak.<br>
		\[center\] - \[/center\] : Centers the text.<br>
		\[h1\] - \[/h1\] : Makes the text a first level heading<br>
		\[h2\] - \[/h2\] : Makes the text a second level heading<br>
		\[h3\] - \[/h3\] : Makes the text a third level heading<br>
		\[b\] - \[/b\] : Makes the text <b>bold</b>.<br>
		\[i\] - \[/i\] : Makes the text <i>italic</i>.<br>
		\[u\] - \[/u\] : Makes the text <u>underlined</u>.<br>
		\[large\] - \[/large\] : Increases the <font size = \"4\">size</font> of the text.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		\[small\] - \[/small\] : Decreases the <font size = \"1\">size</font> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule.
		\[time\] : Inserts the current station time in HH:MM:SS.<br>
	</BODY></HTML>"}, "window=paper_help")

/obj/item/paper/proc/topic_href_write(var/id, var/input_element)
	var/obj/item/item_write = usr.get_active_hand() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.
	add_hiddenprint(usr) // No more forging nasty documents as someone else, you jerks
	if(!istype(item_write, /obj/item/pen))
		if(!istype(item_write, /obj/item/toy/crayon))
			return

	// if paper is not in usr, then it must be near them, or in a clipboard or folder, which must be in or near usr
	if(src.loc != usr && !src.Adjacent(usr) && !((istype(src.loc, /obj/item/clipboard) || istype(src.loc, /obj/item/folder)) && (src.loc.loc == usr || src.loc.Adjacent(usr)) ) )
		return

	input_element = parsepencode(input_element, item_write, usr) // Encode everything from pencode to html

	if(id!="end")
		addtofield(text2num(id), input_element) // He wants to edit a field, let him.
	else
		info += input_element // Oh, he wants to edit to the end of the file, let him.

	populatefields()
	updateinfolinks()

	item_write.on_write(src,usr)

	show_content(usr, forceshow = 1, infolinks = 1)

	update_icon()

/obj/item/paper/Topic(href, href_list)
	..()
	if(!usr || (usr.stat || usr.restrained()))
		return

	if(href_list["auto_write"])
		var/id = href_list["auto_write"]

		var/const/sign_text = "\[Поставить подпись\]"
		var/const/time_text = "\[Написать текущее время\]"
		var/const/date_text = "\[Написать текущую дату\]"
		var/const/num_text = "\[Написать номер аккаунта\]"
		var/const/pin_text = "\[Написать пин-код\]"
		var/const/station_text = "\[Написать название станции\]"

		//пункты текста в меню
		var/list/menu_list = list()
		menu_list.Add(usr.real_name) //настоящее имя персонажа, даже если оно спрятано

		//если игрок маскируется или имя отличается, добавляется новый вариант ответа
		if (usr.real_name != usr.name || usr.name != "unknown")
			menu_list.Add("[usr.name]")

		menu_list.Add(usr.job,		//текущая работа
			num_text,		//номер аккаунта
			pin_text,		//номер пин-кода
			sign_text,  	//подпись
			time_text,  	//время
			date_text,  	//дата
			station_text, 	//название станции
			usr.gender,		//пол
			usr.dna.species	//раса
		)

		var/input_element = input("Выберите текст который хотите добавить:", "Выбор пункта") as null|anything in menu_list

		//форматируем выбранные пункты меню в pencode и внутренние данные
		switch(input_element)
			if (sign_text)
				input_element = "\[sign\]"
			if (time_text)
				input_element = "\[time\]"
			if (date_text)
				input_element = "\[date\]"
			if (station_text)
				input_element = "\[station\]"
			if (num_text)
				input_element = usr.mind.initial_account.account_number
			if (pin_text)
				input_element = usr.mind.initial_account.remote_access_pin

		topic_href_write(id, input_element)


	if(href_list["write"] )
		var/id = href_list["write"]
		var/input_element =  input("Enter what you want to write:", "Write", null, null)  as message

		topic_href_write(id, input_element)


/obj/item/paper/attackby(obj/item/P, mob/living/user, params)
	..()

	if(resistance_flags & ON_FIRE)
		return

	var/clown = 0
	if(user.mind && (user.mind.assigned_role == "Clown"))
		clown = 1

	if(istype(P, /obj/item/paper) || istype(P, /obj/item/photo))
		if(istype(P, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = P
			if(!C.iscopy && !C.copied)
				to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
				add_fingerprint(user)
				return
		var/obj/item/paper_bundle/B = new(src.loc, default_papers = FALSE)
		if(name != "paper")
			B.name = name
		else if(P.name != "paper" && P.name != "photo")
			B.name = P.name
		user.unEquip(P)
		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/h_user = user
			if(h_user.r_hand == src)
				h_user.unEquip(src)
				h_user.put_in_r_hand(B)
			else if(h_user.l_hand == src)
				h_user.unEquip(src)
				h_user.put_in_l_hand(B)
			else if(h_user.l_store == src)
				h_user.unEquip(src)
				B.loc = h_user
				B.layer = ABOVE_HUD_LAYER
				B.plane = ABOVE_HUD_PLANE
				h_user.l_store = B
				h_user.update_inv_pockets()
			else if(h_user.r_store == src)
				h_user.unEquip(src)
				B.loc = h_user
				B.layer = ABOVE_HUD_LAYER
				B.plane = ABOVE_HUD_PLANE
				h_user.r_store = B
				h_user.update_inv_pockets()
			else if(h_user.head == src)
				h_user.unEquip(src)
				h_user.put_in_hands(B)
			else if(!istype(src.loc, /turf))
				src.loc = get_turf(h_user)
				if(h_user.client)	h_user.client.screen -= src
				h_user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You clip the [P.name] to [(src.name == "paper") ? "the paper" : src.name].</span>")
		src.loc = B
		P.loc = B
		B.amount++
		B.update_icon()

	else if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		if(user.is_literate())
			var/obj/item/pen/multi/robopen/RP = P
			if(istype(P, /obj/item/pen/multi/robopen) && RP.mode == 2)
				RP.RenamePaper(user,src)
			else
				show_content(user, infolinks = 1)
			//openhelp(user)
			return
		else
			to_chat(user, "<span class='warning'>You don't know how to write!</span>")

	else if(istype(P, /obj/item/stamp))
		if((!in_range(src, usr) && loc != user && !( istype(loc, /obj/item/clipboard) ) && loc.loc != user && user.get_active_hand() != P))
			return

		if(istype(P, /obj/item/stamp/clown))
			if(!clown)
				to_chat(user, "<span class='notice'>You are totally unable to use the stamp. HONK!</span>")
				return

		stamp(P)

		to_chat(user, "<span class='notice'>You stamp the paper with your rubber stamp.</span>")

	if(is_hot(P))
		if((CLUMSY in user.mutations) && prob(10))
			user.visible_message("<span class='warning'>[user] accidentally ignites [user.p_them()]self!</span>", \
								"<span class='userdanger'>You miss the paper and accidentally light yourself on fire!</span>")
			user.unEquip(P)
			user.adjust_fire_stacks(1)
			user.IgniteMob()
			return

		if(!Adjacent(user)) //to prevent issues as a result of telepathically lighting a paper
			return

		user.unEquip(src)
		user.visible_message("<span class='danger'>[user] lights [src] ablaze with [P]!</span>", "<span class='danger'>You light [src] on fire!</span>")
		fire_act()

	add_fingerprint(user)

/obj/item/paper/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		info = "<i>Heat-curled corners and sooty words offer little insight. Whatever was once written on this page has been rendered illegible through fire.</i>"

/obj/item/paper/proc/stamp(var/obj/item/stamp/S)
	stamps += (!stamps || stamps == "" ? "<HR>" : "") + "<img src=large_[S.icon_state].png>"

	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	var/x
	var/y
	if(istype(S, /obj/item/stamp/captain) || istype(S, /obj/item/stamp/centcom))
		x = rand(-2, 0)
		y = rand(-1, 2)
	else
		x = rand(-2, 2)
		y = rand(-3, 2)
	offset_x += x
	offset_y += y
	stampoverlay.pixel_x = x
	stampoverlay.pixel_y = y

	if(!ico)
		ico = new
	ico += "paper_[S.icon_state]"
	stampoverlay.icon_state = "paper_[S.icon_state]"

	if(!stamped)
		stamped = new
	stamped += S.type
	overlays += stampoverlay

	playsound(S, pick(S.stamp_sounds), 35, 1, -1)

/*
 * Premade paper
 */
/obj/item/paper/Court
	name = "Judgement"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/paper/Toxin
	name = "Chemical Information"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Plasma:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter plasma after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep plasma.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSoporific T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effect are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/paper/hydroponics
	name = "Greetings from Billy Bob"
	info = "<B>Hey fellow botanist!</B><BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effect<BR>\nIn Liberty caps, potency = drug power + effect<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/paper/djstation
	name = "DJ Listening Outpost"
	info = "<B>Welcome new owner!</B><BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multi-tool</li><li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li><li>Turn all the machines on, it has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = 1.0

/obj/item/paper/jobs
	name = "Job Information"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Detective</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<BR>\n1. Research plasma<BR>\n2. Make sure all plasma is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"
	item_state = "paper"

/obj/item/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alarms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"

/obj/item/paper/crumpled/update_icon()
	return

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/fortune
	name = "fortune"
	icon_state = "slip"
	paper_height = 150

/obj/item/paper/fortune/New()
	..()
	var/fortunemessage = pick(GLOB.fortune_cookie_messages)
	info = "<p style='text-align:center;font-family:[deffont];font-size:120%;font-weight:bold;'>[fortunemessage]</p>"
	info += "<p style='text-align:center;'><strong>Lucky numbers</strong>: [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)], [rand(1,49)]</p>"

/obj/item/paper/fortune/update_icon()
	..()
	icon_state = initial(icon_state)
/*
 * Premade paper
 */
/obj/item/paper/Court
	name = "Judgement"
	info = "For crimes against the station, the offender is sentenced to:<BR>\n<BR>\n"

/obj/item/paper/Toxin
	name = "Chemical Information"
	info = "Known Onboard Toxins:<BR>\n\tGrade A Semi-Liquid Plasma:<BR>\n\t\tHighly poisonous. You cannot sustain concentrations above 15 units.<BR>\n\t\tA gas mask fails to filter plasma after 50 units.<BR>\n\t\tWill attempt to diffuse like a gas.<BR>\n\t\tFiltered by scrubbers.<BR>\n\t\tThere is a bottled version which is very different<BR>\n\t\t\tfrom the version found in canisters!<BR>\n<BR>\n\t\tWARNING: Highly Flammable. Keep away from heat sources<BR>\n\t\texcept in a enclosed fire area!<BR>\n\t\tWARNING: It is a crime to use this without authorization.<BR>\nKnown Onboard Anti-Toxin:<BR>\n\tAnti-Toxin Type 01P: Works against Grade A Plasma.<BR>\n\t\tBest if injected directly into bloodstream.<BR>\n\t\tA full injection is in every regular Med-Kit.<BR>\n\t\tSpecial toxin Kits hold around 7.<BR>\n<BR>\nKnown Onboard Chemicals (other):<BR>\n\tRejuvenation T#001:<BR>\n\t\tEven 1 unit injected directly into the bloodstream<BR>\n\t\t\twill cure paralysis and sleep plasma.<BR>\n\t\tIf administered to a dying patient it will prevent<BR>\n\t\t\tfurther damage for about units*3 seconds.<BR>\n\t\t\tit will not cure them or allow them to be cured.<BR>\n\t\tIt can be administeredd to a non-dying patient<BR>\n\t\t\tbut the chemicals disappear just as fast.<BR>\n\tSoporific T#054:<BR>\n\t\t5 units wilkl induce precisely 1 minute of sleep.<BR>\n\t\t\tThe effect are cumulative.<BR>\n\t\tWARNING: It is a crime to use this without authorization"

/obj/item/paper/courtroom
	name = "A Crash Course in Legal SOP on SS13"
	info = "<B>Roles:</B><BR>\nThe Detective is basically the investigator and prosecutor.<BR>\nThe Staff Assistant can perform these functions with written authority from the Detective.<BR>\nThe Captain/HoP/Warden is ct as the judicial authority.<BR>\nThe Security Officers are responsible for executing warrants, security during trial, and prisoner transport.<BR>\n<BR>\n<B>Investigative Phase:</B><BR>\nAfter the crime has been committed the Detective's job is to gather evidence and try to ascertain not only who did it but what happened. He must take special care to catalogue everything and don't leave anything out. Write out all the evidence on paper. Make sure you take an appropriate number of fingerprints. IF he must ask someone questions he has permission to confront them. If the person refuses he can ask a judicial authority to write a subpoena for questioning. If again he fails to respond then that person is to be jailed as insubordinate and obstructing justice. Said person will be released after he cooperates.<BR>\n<BR>\nONCE the FT has a clear idea as to who the criminal is he is to write an arrest warrant on the piece of paper. IT MUST LIST THE CHARGES. The FT is to then go to the judicial authority and explain a small version of his case. If the case is moderately acceptable the authority should sign it. Security must then execute said warrant.<BR>\n<BR>\n<B>Pre-Pre-Trial Phase:</B><BR>\nNow a legal representative must be presented to the defendant if said defendant requests one. That person and the defendant are then to be given time to meet (in the jail IS ACCEPTABLE). The defendant and his lawyer are then to be given a copy of all the evidence that will be presented at trial (rewriting it all on paper is fine). THIS IS CALLED THE DISCOVERY PACK. With a few exceptions, THIS IS THE ONLY EVIDENCE BOTH SIDES MAY USE AT TRIAL. IF the prosecution will be seeking the death penalty it MUST be stated at this time. ALSO if the defense will be seeking not guilty by mental defect it must state this at this time to allow ample time for examination.<BR>\nNow at this time each side is to compile a list of witnesses. By default, the defendant is on both lists regardless of anything else. Also the defense and prosecution can compile more evidence beforehand BUT in order for it to be used the evidence MUST also be given to the other side.\nThe defense has time to compile motions against some evidence here.<BR>\n<B>Possible Motions:</B><BR>\n1. <U>Invalidate Evidence-</U> Something with the evidence is wrong and the evidence is to be thrown out. This includes irrelevance or corrupt security.<BR>\n2. <U>Free Movement-</U> Basically the defendant is to be kept uncuffed before and during the trial.<BR>\n3. <U>Subpoena Witness-</U> If the defense presents god reasons for needing a witness but said person fails to cooperate then a subpoena is issued.<BR>\n4. <U>Drop the Charges-</U> Not enough evidence is there for a trial so the charges are to be dropped. The FT CAN RETRY but the judicial authority must carefully reexamine the new evidence.<BR>\n5. <U>Declare Incompetent-</U> Basically the defendant is insane. Once this is granted a medical official is to examine the patient. If he is indeed insane he is to be placed under care of the medical staff until he is deemed competent to stand trial.<BR>\n<BR>\nALL SIDES MOVE TO A COURTROOM<BR>\n<B>Pre-Trial Hearings:</B><BR>\nA judicial authority and the 2 sides are to meet in the trial room. NO ONE ELSE BESIDES A SECURITY DETAIL IS TO BE PRESENT. The defense submits a plea. If the plea is guilty then proceed directly to sentencing phase. Now the sides each present their motions to the judicial authority. He rules on them. Each side can debate each motion. Then the judicial authority gets a list of crew members. He first gets a chance to look at them all and pick out acceptable and available jurors. Those jurors are then called over. Each side can ask a few questions and dismiss jurors they find too biased. HOWEVER before dismissal the judicial authority MUST agree to the reasoning.<BR>\n<BR>\n<B>The Trial:</B><BR>\nThe trial has three phases.<BR>\n1. <B>Opening Arguments</B>- Each side can give a short speech. They may not present ANY evidence.<BR>\n2. <B>Witness Calling/Evidence Presentation</B>- The prosecution goes first and is able to call the witnesses on his approved list in any order. He can recall them if necessary. During the questioning the lawyer may use the evidence in the questions to help prove a point. After every witness the other side has a chance to cross-examine. After both sides are done questioning a witness the prosecution can present another or recall one (even the EXACT same one again!). After prosecution is done the defense can call witnesses. After the initial cases are presented both sides are free to call witnesses on either list.<BR>\nFINALLY once both sides are done calling witnesses we move onto the next phase.<BR>\n3. <B>Closing Arguments</B>- Same as opening.<BR>\nThe jury then deliberates IN PRIVATE. THEY MUST ALL AGREE on a verdict. REMEMBER: They mix between some charges being guilty and others not guilty (IE if you supposedly killed someone with a gun and you unfortunately picked up a gun without authorization then you CAN be found not guilty of murder BUT guilty of possession of illegal weaponry.). Once they have agreed they present their verdict. If unable to reach a verdict and feel they will never they call a deadlocked jury and we restart at Pre-Trial phase with an entirely new set of jurors.<BR>\n<BR>\n<B>Sentencing Phase:</B><BR>\nIf the death penalty was sought (you MUST have gone through a trial for death penalty) then skip to the second part. <BR>\nI. Each side can present more evidence/witnesses in any order. There is NO ban on emotional aspects or anything. The prosecution is to submit a suggested penalty. After all the sides are done then the judicial authority is to give a sentence.<BR>\nII. The jury stays and does the same thing as I. Their sole job is to determine if the death penalty is applicable. If NOT then the judge selects a sentence.<BR>\n<BR>\nTADA you're done. Security then executes the sentence and adds the applicable convictions to the person's record.<BR>\n"

/obj/item/paper/hydroponics
	name = "Greetings from Billy Bob"
	info = "<B>Hey fellow botanist!</B><BR>\n<BR>\nI didn't trust the station folk so I left<BR>\na couple of weeks ago. But here's some<BR>\ninstructions on how to operate things here.<BR>\nYou can grow plants and each iteration they become<BR>\nstronger, more potent and have better yield, if you<BR>\nknow which ones to pick. Use your botanist's analyzer<BR>\nfor that. You can turn harvested plants into seeds<BR>\nat the seed extractor, and replant them for better stuff!<BR>\nSometimes if the weed level gets high in the tray<BR>\nmutations into different mushroom or weed species have<BR>\nbeen witnessed. On the rare occassion even weeds mutate!<BR>\n<BR>\nEither way, have fun!<BR>\n<BR>\nBest regards,<BR>\nBilly Bob Johnson.<BR>\n<BR>\nPS.<BR>\nHere's a few tips:<BR>\nIn nettles, potency = damage<BR>\nIn amanitas, potency = deadliness + side effect<BR>\nIn Liberty caps, potency = drug power + effect<BR>\nIn chilis, potency = heat<BR>\n<B>Nutrients keep mushrooms alive!</B><BR>\n<B>Water keeps weeds such as nettles alive!</B><BR>\n<B>All other plants need both.</B>"

/obj/item/paper/chef
	name = "Cooking advice from Morgan Ramslay"
	info = "Right, so you're wanting to learn how to feed the teeming masses of the station yeah?<BR>\n<BR>\nWell I was asked to write these tips to help you not burn all of your meals and prevent food poisonings.<BR>\n<BR>\nOkay first things first, making a humble ball of dough.<BR>\n<BR>\nCheck the lockers for a bag or two of flour and then find a glass cup or a beaker, something that can hold liquids. Next pour 15 units of flour into the container and then pour 10 units of water in as well. Hey presto! You've made a ball of dough, which can lead to many possibilities.<BR>\n<BR>\nAlso, before I forget, KEEP YOUR FOOD OFF THE DAMN FLOOR! Space ants love getting onto any food not on a table or kept away in a closed locker. You wouldn't believe how many injuries have resulted from space ants...<BR>\n<BR>\nOkay back on topic, let's make some cheese, just follow along with me here.<BR>\n<BR>\nLook in the lockers again for some milk cartons and grab another glass to mix with. Next look around for a bottle named 'Universal Enzyme' unless they changed the look of it, it should be a green bottle with a red label. Now pour 5 units of enzyme into a glass and 40 units of milk into the glass as well. In a matter of moments you'll have a whole wheel of cheese at your disposal.<BR>\n<BR>\nOkay now that you've got the ingredients, let's make a classic crewman food, cheese bread.<BR>\n<BR>\nMake another ball of dough, and cut up your cheese wheel with a knife or something else sharp such as a pair of wire cutters. Okay now look around for an oven in the kitchen and put 2 balls of dough and 2 cheese wedges into the oven and turn it on. After a few seconds a fresh and hot loaf of cheese bread will pop out. Lastly cut it into slices with a knife and serve.<BR>\n<BR>\nCongratulations on making it this far. If you haven't created a burnt mess of slop after following these directions you might just be on your way to becoming a master chef someday.<BR>\n<BR>\nBe sure to look up other recipes and bug the Head of Personnel if Botany isn't providing you with crops, wheat is your friend and lifeblood.<BR>\n<BR>\nGood luck in the kitchen, and try not to burn down the place.<BR>\n<BR>\n-Morgan Ramslay"

/obj/item/paper/djstation
	name = "DJ Listening Outpost"
	info = "<B>Welcome new owner!</B><BR><BR>You have purchased the latest in listening equipment. The telecommunication setup we created is the best in listening to common and private radio fequencies. Here is a step by step guide to start listening in on those saucy radio channels:<br><ol><li>Equip yourself with a multi-tool</li><li>Use the multitool on each machine, that is the broadcaster, receiver and the relay.</li><li>Turn all the machines on, it has already been configured for you to listen on.</li></ol> Simple as that. Now to listen to the private channels, you'll have to configure the intercoms, located on the front desk. Here is a list of frequencies for you to listen on.<br><ul><li>145.7 - Common Channel</li><li>144.7 - Private AI Channel</li><li>135.9 - Security Channel</li><li>135.7 - Engineering Channel</li><li>135.5 - Medical Channel</li><li>135.3 - Command Channel</li><li>135.1 - Science Channel</li><li>134.9 - Mining Channel</li><li>134.7 - Cargo Channel</li>"

/obj/item/paper/monolithren
	name = "For stalkers"
	info = "Sorry Mario, your wishgranter in another castle. Your Friendly God"

/obj/item/paper/flag
	icon_state = "flag_neutral"
	item_state = "paper"
	anchored = 1.0

/obj/item/paper/jobs
	name = "Job Information"
	info = "Information on all formal jobs that can be assigned on Space Station 13 can be found on this document.<BR>\nThe data will be in the following form.<BR>\nGenerally lower ranking positions come first in this list.<BR>\n<BR>\n<B>Job Name</B>   general access>lab access-engine access-systems access (atmosphere control)<BR>\n\tJob Description<BR>\nJob Duties (in no particular order)<BR>\nTips (where applicable)<BR>\n<BR>\n<B>Research Assistant</B> 1>1-0-0<BR>\n\tThis is probably the lowest level position. Anyone who enters the space station after the initial job\nassignment will automatically receive this position. Access with this is restricted. Head of Personnel should\nappropriate the correct level of assistance.<BR>\n1. Assist the researchers.<BR>\n2. Clean up the labs.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Staff Assistant</B> 2>0-0-0<BR>\n\tThis position assists the security officer in his duties. The staff assisstants should primarily br\npatrolling the ship waiting until they are needed to maintain ship safety.\n(Addendum: Updated/Elevated Security Protocols admit issuing of low level weapons to security personnel)<BR>\n1. Patrol ship/Guard key areas<BR>\n2. Assist security officer<BR>\n3. Perform other security duties.<BR>\n<BR>\n<B>Technical Assistant</B> 1>0-0-1<BR>\n\tThis is yet another low level position. The technical assistant helps the engineer and the statian\ntechnician with the upkeep and maintenance of the station. This job is very important because it usually\ngets to be a heavy workload on station technician and these helpers will alleviate that.<BR>\n1. Assist Station technician and Engineers.<BR>\n2. Perform general maintenance of station.<BR>\n3. Prepare materials.<BR>\n<BR>\n<B>Medical Assistant</B> 1>1-0-0<BR>\n\tThis is the fourth position yet it is slightly less common. This position doesn't have much power\noutside of the med bay. Consider this position like a nurse who helps to upkeep medical records and the\nmaterials (filling syringes and checking vitals)<BR>\n1. Assist the medical personnel.<BR>\n2. Update medical files.<BR>\n3. Prepare materials for medical operations.<BR>\n<BR>\n<B>Research Technician</B> 2>3-0-0<BR>\n\tThis job is primarily a step up from research assistant. These people generally do not get their own lab\nbut are more hands on in the experimentation process. At this level they are permitted to work as consultants to\nthe others formally.<BR>\n1. Inform superiors of research.<BR>\n2. Perform research alongside of official researchers.<BR>\n<BR>\n<B>Detective</B> 3>2-0-0<BR>\n\tThis job is in most cases slightly boring at best. Their sole duty is to\nperform investigations of crine scenes and analysis of the crime scene. This\nalleviates SOME of the burden from the security officer. This person's duty\nis to draw conclusions as to what happened and testify in court. Said person\nalso should stroe the evidence ly.<BR>\n1. Perform crime-scene investigations/draw conclusions.<BR>\n2. Store and catalogue evidence properly.<BR>\n3. Testify to superiors/inquieries on findings.<BR>\n<BR>\n<B>Station Technician</B> 2>0-2-3<BR>\n\tPeople assigned to this position must work to make sure all the systems aboard Space Station 13 are operable.\nThey should primarily work in the computer lab and repairing faulty equipment. They should work with the\natmospheric technician.<BR>\n1. Maintain SS13 systems.<BR>\n2. Repair equipment.<BR>\n<BR>\n<B>Atmospheric Technician</B> 3>0-0-4<BR>\n\tThese people should primarily work in the atmospheric control center and lab. They have the very important\njob of maintaining the delicate atmosphere on SS13.<BR>\n1. Maintain atmosphere on SS13<BR>\n2. Research atmospheres on the space station. (safely please!)<BR>\n<BR>\n<B>Engineer</B> 2>1-3-0<BR>\n\tPeople working as this should generally have detailed knowledge as to how the propulsion systems on SS13\nwork. They are one of the few classes that have unrestricted access to the engine area.<BR>\n1. Upkeep the engine.<BR>\n2. Prevent fires in the engine.<BR>\n3. Maintain a safe orbit.<BR>\n<BR>\n<B>Medical Researcher</B> 2>5-0-0<BR>\n\tThis position may need a little clarification. Their duty is to make sure that all experiments are safe and\nto conduct experiments that may help to improve the station. They will be generally idle until a new laboratory\nis constructed.<BR>\n1. Make sure the station is kept safe.<BR>\n2. Research medical properties of materials studied of Space Station 13.<BR>\n<BR>\n<B>Scientist</B> 2>5-0-0<BR>\n\tThese people study the properties, particularly the toxic properties, of materials handled on SS13.\nTechnically they can also be called Plasma Technicians as plasma is the material they routinly handle.<BR>\n1. Research plasma<BR>\n2. Make sure all plasma is properly handled.<BR>\n<BR>\n<B>Medical Doctor (Officer)</B> 2>0-0-0<BR>\n\tPeople working this job should primarily stay in the medical area. They should make sure everyone goes to\nthe medical bay for treatment and examination. Also they should make sure that medical supplies are kept in\norder.<BR>\n1. Heal wounded people.<BR>\n2. Perform examinations of all personnel.<BR>\n3. Moniter usage of medical equipment.<BR>\n<BR>\n<B>Security Officer</B> 3>0-0-0<BR>\n\tThese people should attempt to keep the peace inside the station and make sure the station is kept safe. One\nside duty is to assist in repairing the station. They also work like general maintenance personnel. They are not\ngiven a weapon and must use their own resources.<BR>\n(Addendum: Updated/Elevated Security Protocols admit issuing of weapons to security personnel)<BR>\n1. Maintain order.<BR>\n2. Assist others.<BR>\n3. Repair structural problems.<BR>\n<BR>\n<B>Head of Security</B> 4>5-2-2<BR>\n\tPeople assigned as Head of Security should issue orders to the security staff. They should\nalso carefully moderate the usage of all security equipment. All security matters should be reported to this person.<BR>\n1. Oversee security.<BR>\n2. Assign patrol duties.<BR>\n3. Protect the station and staff.<BR>\n<BR>\n<B>Head of Personnel</B> 4>4-2-2<BR>\n\tPeople assigned as head of personnel will find themselves moderating all actions done by personnel. \nAlso they have the ability to assign jobs and access levels.<BR>\n1. Assign duties.<BR>\n2. Moderate personnel.<BR>\n3. Moderate research. <BR>\n<BR>\n<B>Captain</B> 5>5-5-5 (unrestricted station wide access)<BR>\n\tThis is the highest position youi can aquire on Space Station 13. They are allowed anywhere inside the\nspace station and therefore should protect their ID card. They also have the ability to assign positions\nand access levels. They should not abuse their power.<BR>\n1. Assign all positions on SS13<BR>\n2. Inspect the station for any problems.<BR>\n3. Perform administrative duties.<BR>\n"

/obj/item/paper/photograph
	name = "photo"
	icon_state = "photo"
	item_state = "paper"

/obj/item/paper/sop
	name = "paper- 'Standard Operating Procedure'"
	info = "Alert Levels:<BR>\nBlue- Emergency<BR>\n\t1. Caused by fire<BR>\n\t2. Caused by manual interaction<BR>\n\tAction:<BR>\n\t\tClose all fire doors. These can only be opened by reseting the alarm<BR>\nRed- Ejection/Self Destruct<BR>\n\t1. Caused by module operating computer.<BR>\n\tAction:<BR>\n\t\tAfter the specified time the module will eject completely.<BR>\n<BR>\nEngine Maintenance Instructions:<BR>\n\tShut off ignition systems:<BR>\n\tActivate internal power<BR>\n\tActivate orbital balance matrix<BR>\n\tRemove volatile liquids from area<BR>\n\tWear a fire suit<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nToxin Laboratory Procedure:<BR>\n\tWear a gas mask regardless<BR>\n\tGet an oxygen tank.<BR>\n\tActivate internal atmosphere<BR>\n<BR>\n\tAfter<BR>\n\t\tDecontaminate<BR>\n\t\tVisit medical examiner<BR>\n<BR>\nDisaster Procedure:<BR>\n\tFire:<BR>\n\t\tActivate sector fire alarm.<BR>\n\t\tMove to a safe area.<BR>\n\t\tGet a fire suit<BR>\n\t\tAfter:<BR>\n\t\t\tAssess Damage<BR>\n\t\t\tRepair damages<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tMeteor Shower:<BR>\n\t\tActivate fire alarm<BR>\n\t\tMove to the back of ship<BR>\n\t\tAfter<BR>\n\t\t\tRepair damage<BR>\n\t\t\tIf needed, Evacuate<BR>\n\tAccidental Reentry:<BR>\n\t\tActivate fire alarms in front of ship.<BR>\n\t\tMove volatile matter to a fire proof area!<BR>\n\t\tGet a fire suit.<BR>\n\t\tStay secure until an emergency ship arrives.<BR>\n<BR>\n\t\tIf ship does not arrive-<BR>\n\t\t\tEvacuate to a nearby safe area!"

/obj/item/paper/blueshield
	name = "paper- 'Blueshield Mission Briefing'"
	info = "<b>Blueshield Mission Briefing</b><br>You are charged with the defence of any persons of importance within the station. This includes, but is not limited to, The Captain, The Heads of Staff and Central Command staff. You answer directly to the Nanotrasen Representative who will assist you in achieving your mission.<br>When required to achieve your primary responsibility, you should liaise with security and share resources; however, the day to day security operations of the station are outside of your jurisdiction.<br>Monitor the health and safety of your principals, identify any potential risks and threats, then alert the proper departments to resolve the situation. You are authorized to act as bodyguard to any of the station heads that you determine are most in need of protection; however, additional access to their departments shall be granted solely at their discretion.<br>Observe the station alert system and carry your armaments only as required by the situation, or when authorized by the Head of Security or Captain in exceptional cases.<br>Remember, as an agent of Nanotrasen it is your responsibility to conduct yourself appropriately and you will be held to the highest standard. You will be held accountable for your actions. Security is authorized to search, interrogate or detain you as required by their own procedures. Internal affairs will also monitor and observe your conduct, and their mandate applies equally to security and Blueshield operations."

/obj/item/paper/ntrep
	name = "paper- 'Nanotrasen Representative Mission Briefing'"
	info = "<b>Nanotrasen Representative Mission Briefing</b><br><br>Nanotrasen Central Command has dispatched you to this station in order to liaise with command staff on their behalf. As experienced field officers, the staff on the station are experts in handling their own fields. It is your job, however, to consider the bigger picture and to direct the staff towards Nanotrasen's corporate interests.<br>As a civilian, you should consider yourself an advisor, diplomat and intermediary. The command staff do not answer to you directly and are not required to follow your orders, nor do you have disciplinary authority over personnel. In all station internal matters you answer to the Head of Personnel who will direct you in your conduct within the station. However, you also answer to Central Command who may, as required, direct you in acting on company interests.<br>Central Command may dispatch orders to the staff through you which you are responsible to communicate; however, enforcement of these orders is not your mandate and will be handled directly by Central Command or authorized Nanotrasen personnel. When not specifically directed by Central Command, assist the Head of Personnel in evaluation of the station and receiving departmental reports.<br>Your office has been provided with a direct link to Central Command, through which you can issue any urgent reports or requests for Nanotrasen intervention. Remember that any direct intervention is a costly exercise and should be used only when the situation justifies the request. You will be held accountable for any unnecessary usage of Nanotrasen resources.<br>"

/obj/item/paper/armory
	name = "paper- 'Armory Inventory'"
	info = "4 Deployable Barriers<br>4 Portable Flashers<br>1 Mechanical Toolbox<br>2 Boxes of Spare Handcuffs<br>1 Box of Flashbangs<br>1 Box of Spare R.O.B.U.S.T. Cartridges<br>1 Tracking Implant Kit<br>1 Chemical Implant Kit<br>1 Box of Tear Gas Grenades<br>1 Explosive Ordnance Disposal Suit<br>1 Biohazard Suit<br>6 Gas Masks<br>1 Lockbox of Mindshield Implants<br>1 Ion Rifle<br>3 Sets of Riot Equipment<br>2 Sets of Security Hardsuits<br>1 Ablative Armor Vest<br>3 Bulletproof Vests<br>3 Helmets<br><br>2 Riot Shotguns<br>2 Boxes of Beanbag Shells<br>3 Laser Guns<br>3 Energy Guns<br>3 Advanced Tasers"

/obj/item/paper/firingrange
	name = "paper- 'Firing Range Instructions'"
	info = "Directions:<br><i>First you'll want to make sure there is a target stake in the center of the magnetic platform. Next, take an aluminum target from the crates back there and slip it into the stake. Make sure it clicks! Next, there should be a control console mounted on the wall somewhere in the room.<br><br> This control console dictates the behaviors of the magnetic platform, which can move your firing target around to simulate real-world combat situations. From here, you can turn off the magnets or adjust their electromagnetic levels and magnetic fields. The electricity level dictates the strength of the pull - you will usually want this to be the same value as the speed. The magnetic field level dictates how far the magnetic pull reaches.<br><br>Speed and path are the next two settings. Speed is associated with how fast the machine loops through the designated path. Paths dictate where the magnetic field will be centered at what times. There should be a pre-fabricated path input already. You can enable moving to observe how the path affects the way the stake moves. To script your own path, look at the following key:</i><br><br>N: North<br>S: South<br>E: East<br>W: West<br>C: Center<br>R: Random (results may vary)<br>; or &: separators. They are not necessary but can make the path string better visible."

/obj/item/paper/holodeck
	name = "paper- 'Holodeck Disclaimer'"
	info = "Brusies sustained in the holodeck can be healed simply by sleeping."

/obj/item/paper/syndimemo
	name = "paper- 'Memo'"
	info = "GET DAT FUKKEN DISK"

/obj/item/paper/synditele
	name = "Teleporter Instructions"
	info = "<h3>Teleporter Instruction</h3><hr><ol><li>Install circuit board, glass and wiring to complete Teleporter Control Console</li><li>Use a screwdriver, wirecutter and screwdriver again on the Teleporter Station to connect it</li><li>Set destination with Teleporter Control Computer</li><li>Activate Teleporter Hub with Teleporter Station</li></ol>"

/obj/item/paper/russiantraitorobj
	name = "paper- 'Mission Objectives'"
	info = "The Syndicate have cunningly disguised a Syndicate Uplink as your PDA. Simply enter the code \"678 Bravo\" into the ringtone select to unlock its hidden features. <br><br><b>Objective #1</b>. Kill the God damn AI in a fire blast that it rocks the station. <b>Success!</b>  <br><b>Objective #2</b>. Escape alive. <b>Failed.</b>"

/obj/item/paper/russiannuclearoperativeobj
	name = "paper- 'Objectives of a Nuclear Operative'"
	info = "<b>Objective #1</b>: Destroy the station with a nuclear device."

/obj/item/paper/clownship
	name = "paper- 'Note'"
	info = "The call has gone out! Our ancestral home has been rediscovered! Not a small patch of land, but a true clown nation, a true Clown Planet! We're on our way home at last!"

/obj/item/paper/crumpled
	name = "paper scrap"
	icon_state = "scrap"

/obj/item/paper/syndicate
	name = "paper"
	header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='syndielogo.png' width='220' height='135' /></p><hr />"
	info = ""

/obj/item/paper/nanotrasen
	name = "paper"
	header = "<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ntlogo.png' width='220' height='135' /></p><hr />"
	info =  ""

/obj/item/paper/central_command
	name = "Директива Центрального Командования"
	info = ""

/obj/item/paper/central_command/Initialize(mapload)
	time = "Время: [station_time_timestamp()]"
	if(!(GLOB.genname))
		GLOB.genname = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
	header ="<font face=\"Verdana\" color=black><table></td><tr><td><img src = ntlogo.png><td><table></td><tr><td><font size = \"1\">Форма NT-CC-DRV</font></td><tr><td><font size=\"1\">NAS Trurl</font></td><tr><td><font size=\"1\">[time]</font></td><tr><td></td><tr><td></td><tr><td><B>Директива Центрального Командования</B></td></tr></table></td></tr></table><BR><HR><BR></font>"
	footer = "<br /><br /><font face=\"Verdana\" size = \"1\"><i>Подпись&#58;</font> <font face=\"[signfont]\" size = \"1\">[GLOB.genname]</font></i><font face=\"Verdana\" size = \"1\">, в должности <i>Nanotrasen Navy Officer</i></font><hr /><p style='font-family:Verdana;'><font size = \"1\"><em>*Содержимое данного документа следует считать конфиденциальным. Если не указано иное, распространение содержащейся в данном документе информации среди третьих лиц и сторонних организаций строго запрещено. </em> <br /> <em>*Невыполнение директив, содержащихся в данном документе, считается нарушением политики корпорации и может привести к наложению различных дисциплинарных взысканий. </em> <br /> <em> *Данный документ считается действительным только при наличии подписи и печати офицера Центрального Командования.</em></font></p>"
	populatefields()
	return ..()

/obj/item/paper/thief
	name = "Инструкции"
	header = "<font face=\"Verdana\" color=black>\
			<table cellspacing=0 cellpadding=3  align=\"right\">\
			<tr><td><img src= thieflogo.png></td></tr>\
			<br><HR></font>"
	info = "<font face=\"Verdana\"\
	<BR><center><H2>Инструкции</H2></center> \
	<BR><center><H3>Здравия, товарищ по ремеслу!</H3></center> \
	<BR>\n<BR>\nДанная инструкция поможет тебе разобраться и сразу не попасться.<BR> \
	\nНу... Тут как повезет. Но помни, если тебя поймали - ты никого не знаешь.<BR> \
	\nМы постараемся вытащить тебя как только так сразу. \
	\nА до этого момента сиди держи язык за зубами. Гильдия всегда всё знает.<BR> \
	<BR><HR> \
	<BR>\n<B>Начнем с основ.</B><BR> \
	\nВ твоих руках находится коробка с твоими личным инструментарием, который ты взял с собой. \
	Надеюсь ты тщательно подумал что берешь. В любом случае, думать уже поздно, теперь работай с тем что есть и что под рукой.<BR> \
	\nНадеюсь ты не взял с собой термальные очки. Ты же уважающий себя член нашей гильдии. Ведь так?<BR> \
	\nА даже если взял, наверняка мы заменили тебе их на не-хамелеонные и приложили коробку сладостей. Наслаждайся.<BR> \
	\nЕсли же не взял - мое личное уважение за знание своего ремесла и уверенность.<BR> \
	\nТакже в твой набор вложен портфель и перчатки. \
	\nПортфель позволяет тебе спрятать вещи в него, а после запрятать их где-нибудь под-полом. \
	Конечно ты можешь и без этого спрятать их в бачок унитаза, судить твои методы не буду. Они все хороши.<BR> \
	\nНаши фирменные перчатки не оставляют следов и позволяют стащить вещь у твоей цели прямо на её глазах в твои руки. \
	И она даже ничего не заметит. Конечно если ты не снимаешь с неё трусы. Лёгкий ветерок щекочащий булочки вызывает подозрения.<BR> \
	<BR><HR> \
	<BR>\n<B>А теперь по пунктам:</B><BR>\
	\n1. Получи информацию по цели.<BR> \
	\n2. Найди цель.<BR> \
	\n3. Продумай план с использованием своего снаряжения и снаряжения станции.<BR> \
	\n\t	3.1 Заполучи дополнительное снаряжение при необходимости.<BR> \
	\n\t	3.2 Воспользуйся украденными денежными средствами для получения снаряжения.<BR> \
	\n4. Действуй. Не сиди и не жди. Чем дольше ты ждешь, тем больше шансов что цель пострадает до её заполучения.<BR> \
	\n\t	4.1 Если цель - предмет, просто не потеряй его после кражи.<BR> \
	\n\t	4.2 Если цель - структура, убедись что её не разобрали никакие клоуны.<BR> \
	\n\t	4.3 Если цель - питомец, убедись в её безопасности, помести её в переноску, рюкзак или шкаф, свяжи по возможности.<BR> \
	\n5. Контролируй сохранность цели во избежания её повреждения или... смерти. Иначе задача будет провалена.<BR> \
	\n6. Для успешного выполнения цели необходимо:<BR> \
	\n\t	6.1 Предметы: Храни их на себе, в себе, в карманах или рюкзаке. <BR> \
	\n\t	6.2 Структура: Держи её возле себя по прибытию. <BR> \
	\n\t	6.3 Питомец: Держи его в рюкзаке, в карманах, переноске, шкафу или на голове по прибытию. <BR> \
	\n7. ...<BR> \
	\n8. Profit!<BR></font> \
	<BR>\n<BR>\n<font size = \"1\"><B>Уничтожь улики, коробку и инструкцию во избежании раскрытия работы гильдии.</B></span> \
	<BR>\n\t\t<font size = \"1\">~~~ <B>Твой Куратор:</B> Персональный Управляемый Помощник Согласования ~~~</span>"

/obj/item/paper/dog_detective_explain
	name = "Форма NT-PET-05 - Уведомление агента внутренних дел Нанотрейзен о питомце \"Гав Гавыч\""
	header ="<p><img style='display: block; margin-left: auto; margin-right: auto;' src='ntlogo.png' alt='' width='220' height='135' /></p><hr /><h3 style='text-align: center;font-family: Verdana;'><b> Отдел внутренних дел Нанотрейзен по надзору за животными.</h3><p style='text-align: center;font-family:Verdana;'>Официальное Уведомление</p></b><hr />"
	info = "<font face=\"Verdana\" color=black>ᅠᅠАгенство внутренних дел по надзору за домашними животными находящимися на станции сообщает, приставленный к вам питомец \"Гав Гавыч\" почил. Он верно служил ремеслу дознавателей, сыщиков и детективов. Мы будем помнить о его вкладе и сохраним о нём память в анналах истории о домашних питомцах Нанотрейзен.<BR><HR>"
	footer = "<center><font size=\"4\"><B>Штампы и данные:</B></font></center><BR>Время принятия отчета: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче агенту.<BR>*Данный документ может содержать личную информацию. </font></font>"

/obj/item/paper/crumpled/update_icon()
	return

/obj/item/paper/crumpled/bloody
	icon_state = "scrap_bloodied"

/obj/item/paper/evilfax
	name = "Centcomm Reply"
	info = ""
	var/mytarget = null
	var/myeffect = null
	var/used = 0
	var/countdown = 60
	var/activate_on_timeout = 0
	var/faxmachineid = null

/obj/item/paper/evilfax/show_content(var/mob/user, var/forceshow = 0, var/forcestars = 0, var/infolinks = 0, var/view = 1)
	if(user == mytarget)
		if(istype(user, /mob/living/carbon))
			var/mob/living/carbon/C = user
			evilpaper_specialaction(C)
			..()
		else
			// This should never happen, but just in case someone is adminbussing
			evilpaper_selfdestruct()
	else
		if(mytarget)
			to_chat(user,"<span class='notice'>This page appears to be covered in some sort of bizzare code. The only bit you recognize is the name of [mytarget]. Perhaps [mytarget] can make sense of it?</span>")
		else
			evilpaper_selfdestruct()


/obj/item/paper/evilfax/New()
	..()
	START_PROCESSING(SSobj, src)


/obj/item/paper/evilfax/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(mytarget && !used)
		var/mob/living/carbon/target = mytarget
		target.ForceContractDisease(new /datum/disease/transformation/corgi(0))
	return ..()


/obj/item/paper/evilfax/process()
	if(!countdown)
		if(mytarget)
			if(activate_on_timeout)
				evilpaper_specialaction(mytarget)
			else
				message_admins("[mytarget] ignored an evil fax until it timed out.")
		else
			message_admins("Evil paper '[src]' timed out, after not being assigned a target.")
		used = 1
		evilpaper_selfdestruct()
	else
		countdown--

/obj/item/paper/evilfax/proc/evilpaper_specialaction(var/mob/living/carbon/target)
	spawn(30)
		if(istype(target, /mob/living/carbon))
			var/obj/machinery/photocopier/faxmachine/fax = locateUID(faxmachineid)
			if(myeffect == "Borgification")
				to_chat(target,"<span class='userdanger'>You seem to comprehend the AI a little better. Why are your muscles so stiff?</span>")
				target.ForceContractDisease(new /datum/disease/transformation/robot(0))
			else if(myeffect == "Corgification")
				to_chat(target,"<span class='userdanger'>You hear distant howling as the world seems to grow bigger around you. Boy, that itch sure is getting worse!</span>")
				target.ForceContractDisease(new /datum/disease/transformation/corgi(0))
			else if(myeffect == "Death By Fire")
				to_chat(target,"<span class='userdanger'>You feel hotter than usual. Maybe you should lowe-wait, is that your hand melting?</span>")
				var/turf/simulated/T = get_turf(target)
				new /obj/effect/hotspot(T)
				target.adjustFireLoss(150) // hard crit, the burning takes care of the rest.
			else if(myeffect == "Total Brain Death")
				to_chat(target,"<span class='userdanger'>You see a message appear in front of you in bright red letters: <b>YHWH-3 ACTIVATED. TERMINATION IN 3 SECONDS</b></span>")
				target.mutations.Add(NOCLONE)
				target.adjustBrainLoss(125)
			else if(myeffect == "Honk Tumor")
				if(!target.get_int_organ(/obj/item/organ/internal/honktumor))
					var/obj/item/organ/internal/organ = new /obj/item/organ/internal/honktumor
					to_chat(target,"<span class='userdanger'>Life seems funnier, somehow.</span>")
					organ.insert(target)
			else if(myeffect == "Cluwne")
				if(istype(target, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = target
					to_chat(H, "<span class='userdanger'>You feel surrounded by sadness. Sadness... and HONKS!</span>")
					H.makeCluwne()
			else if(myeffect == "Demote")
				GLOB.event_announcement.Announce("[target.real_name] настоящим приказом был понижен до Гражданского. Немедленно обработайте этот запрос. Невыполнение этих распоряжений является основанием для расторжения контракта.","ВНИМАНИЕ: Приказ ЦК о понижении в должности.")
				for(var/datum/data/record/R in sortRecord(GLOB.data_core.security))
					if(R.fields["name"] == target.real_name)
						R.fields["criminal"] = SEC_RECORD_STATUS_DEMOTE
						R.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<BR> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
				update_all_mob_security_hud()
			else if(myeffect == "Demote with Bot")
				GLOB.event_announcement.Announce("[target.real_name] настоящим приказом был понижен до Гражданского. Немедленно обработайте этот запрос. Невыполнение этих распоряжений является основанием для расторжения контракта.","ВНИМАНИЕ: Приказ ЦК о понижении в должности.")
				for(var/datum/data/record/R in sortRecord(GLOB.data_core.security))
					if(R.fields["name"] == target.real_name)
						R.fields["criminal"] = SEC_RECORD_STATUS_ARREST
						R.fields["comments"] += "Central Command Demotion Order, given on [GLOB.current_date_string] [station_time_timestamp()]<BR> Process this demotion immediately. Failure to comply with these orders is grounds for termination."
				update_all_mob_security_hud()
				if(fax)
					var/turf/T = get_turf(fax)
					new /obj/effect/portal(T)
					new /mob/living/simple_animal/bot/secbot(T)
			else if(myeffect == "Revoke Fax Access")
				GLOB.fax_blacklist += target.real_name
				if(fax)
					fax.authenticated = 0
			else if(myeffect == "Angry Fax Machine")
				if(fax)
					fax.become_mimic()
			else
				message_admins("Evil paper [src] was activated without a proper effect set! This is a bug.")
		used = 1
		evilpaper_selfdestruct()

/obj/item/paper/evilfax/proc/evilpaper_selfdestruct()
	visible_message("<span class='danger'>[src] spontaneously catches fire, and burns up!</span>")
	qdel(src)

/obj/item/paper/pickup(user)
	if(contact_poison && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || G.transfer_prints)
			H.reagents.add_reagent(contact_poison, contact_poison_volume)
			contact_poison = null
			add_attack_logs(src, user, "Picked up [src], the paper poisoned by [contact_poison_poisoner]")
	. = ..()

/obj/item/paper/researchnotes
	name = "paper - 'Research Notes'"
	info = "<b>The notes appear gibberish to you. Perhaps a destructive analyzer in R&D could make sense of them.</b>"
	origin_tech = "combat=4;materials=4;engineering=4;biotech=4"

/obj/item/paper/researchnotes/New()
	..()
	var/list/possible_techs = list("materials", "engineering", "plasmatech", "powerstorage", "bluespace", "biotech", "combat", "magnets", "programming", "syndicate")
	var/mytech = pick(possible_techs)
	var/mylevel = rand(7, 9)
	origin_tech = "[mytech]=[mylevel]"
	name = "research notes - [mytech] [mylevel]"

/obj/item/paper/form
	var/id // official form ID
	var/altername // alternative form name
	var/category // category name
	var/confidential = FALSE
	var/from // = "Научная станция Nanotrasen &#34;Cyberiad&#34;"
	var/notice = "Перед заполнением прочтите от начала до конца | Во всех PDA имеется ручка"
	var/access = null //form visible only with appropriate access
	paper_width = 600 //Width of the window that opens
	paper_height = 700 //Height of the window that opens
	var/is_header_needed = TRUE
	var/const/footer_signstampfax = "<BR><font face=\"Verdana\" color=black><HR><center><font size = \"1\">Подписи глав являются доказательством их согласия.<BR>Данный документ является недействительным при отсутствии релевантной печати.<BR>Пожалуйста, отправьте обратно подписанную/проштампованную копию факсом.</font></center></font>"
	var/const/footer_signstamp = "<BR><font face=\"Verdana\" color=black><HR><center><font size = \"1\">Подписи глав являются доказательством их согласия.<BR>Данный документ является недействительным при отсутствии релевантной печати.</font></center></font>"
	var/const/footer_confidential = "<BR><font face=\"Verdana\" color=black><HR><center><font size = \"1\">Данный документ является недействительным при отсутствии печати.<BR>Отказ от ответственности: Данный факс является конфиденциальным и не может быть прочтен сотрудниками не имеющего доступа. Если вы получили данный факс по ошибке, просим вас сообщить отправителю и удалить его из вашего почтового ящика или любого другого носителя. И Nanotrasen, и любой её агент не несёт ответственность за любые сделанные заявления, они являются исключительно заявлениями отправителя, за исключением если отправителем является Nanotrasen или один из её агентов. Отмечаем, что ни Nanotrasen, ни один из агентов корпорации не несёт ответственности за наличие вирусов, который могут содержаться в данном факсе или его приложения, и это только ваша прерогатива просканировать факс и приложения на них. Никакие контракты не могут быть заключены посредством факсимильной связи.</font></center></font>"
	footer = footer_signstampfax

/obj/item/paper/form/New()
	from = "Научная станция Nanotrasen &#34;[MAP_NAME]&#34;"
	if(is_header_needed)
		header = "<font face=\"Verdana\" color=black><table></td><tr><td><img src = ntlogo.png><td><table></td><tr><td><font size = \"1\">[name][confidential ? " \[КОНФИДЕНЦИАЛЬНО\]" : ""]</font></td><tr><td></td><tr><td><B><font size=\"4\">[altername]</font></B></td><tr><td><table></td><tr><td>[from]<td>[category]</td></tr></table></td></tr></table></td></tr></table><center><font size = \"1\">[notice]</font></center><BR><HR><BR></font>"
	populatefields()
	return ..()

//главы станции
/obj/item/paper/form/NT_COM_ST
	name = "Форма NT-COM-ST"
	id = "NT-COM-ST"
	altername = "Отчет о ситуации на станции"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black><center><B>Приветствую Центральное командование</B></center><BR>Сообщает вам <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>.<BR><BR>В данный момент на станции код: <span class=\"paper_field\"></span><BR>Активные угрозы для станции: <B><span class=\"paper_field\"></span></B><BR>Потери среди экипажа: <span class=\"paper_field\"></span><BR>Повреждения на станции: <span class=\"paper_field\"></span><BR>Общее состояние станции: <span class=\"paper_field\"></span><BR>Дополнительная информация: <span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись: <span class=\"paper_field\"></span><HR><font size = \"1\">*В данном документе описывается полное состояние станции, необходимо перечислить всю доступную информацию. <BR>*Информацию, которую вы считаете нужной, необходимо сообщить в разделе – дополнительная информация. <BR>*<B>Данный документ считается официальным только после подписи уполномоченного лица и наличии на документе его печати.</B> </font></font>"

/obj/item/paper/form/NT_COM_ACAP
	name = "Форма NT-COM-ACAP"
	id = "NT-COM-ACAP"
	altername = "Заявление о повышении главы отдела до и.о. капитана"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black>Я, <span class=\"paper_field\"></span>, в должности главы отделения <span class=\"paper_field\"></span>, прошу согласовать нынешнее командование станции Керберос, в повышении меня до и.о. капитана.<BR><BR>⠀⠀⠀При назначении меня на данную должность, я обязуюсь выполнять все рекомендации и правила, согласно стандартным рабочим процедурам капитана. До появления капитана, я обеспечиваю порядок и управление станцией, сохранность и безопасность <I>диска с кодами авторизации ядерной боеголовки, а также самой боеголовки, коды от сейфов и личные вещи капитана</I>.<BR><BR>⠀⠀⠀При появлении капитана мне необходибо будет сообщить: состояние и статус станции, о своем продвижении до и.о. капитана, и обнулить капитанский доступ при первому требованию капитана.<HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Подпись инициатора повышения: <span class=\"paper_field\"></span><BR>Время вступления в должность и.о. капитана: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченного лица, производившего инициацию повышения, и выдаче заявителю.<BR>*Если один (или более) глав отсутствуют, необходимо собрать подписи, действующих глав.<BR>*Так же в данном документе, главам, которые согласились с кандидатом, необходимо поставить свою печать и подпись.</font></font>"

/obj/item/paper/form/NT_COM_ACOM
	name = "Форма NT-COM-ACOM"
	id = "NT-COM-ACOM"
	altername = "Заявление о повышении сотрудника до и.о. главы отделения"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black><BR>ᅠᅠЯ, <span class=\"paper_field\"></span>, в должности сотрудника отделения <B><span class=\"paper_field\"></span></B>, прошу согласовать нынешнее командование станции Керберос, в повышении меня до звания и.о. главы <span class=\"paper_field\"></span>.<BR><BR>⠀⠀⠀При назначении меня на данную должность, я обязуюсь выполнять все рекомендации, и правила, которые присутствуют на главе отделения <span class=\"paper_field\"></span>. До появления основного главы отделения, я обеспечиваю порядок и управление своим отделом, сохранность и безопасность <I>личных вещей главы отделения</I>.<BR><BR>⠀⠀⠀При появлении главы отделения, мне неообходимо сообщить: состояние и статус своего отдела, о своем продвижении до и.о. главы отделения, и сдать доступ и.о. главы и взятые вещи при первом требовании прибывшего главы.<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Подпись инициатора повышения: <span class=\"paper_field\"></span><BR>Время вступления в и.о. <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR>Подпись главы отделения <span class=\"paper_field\"></span>: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченного лица, производившего инициацию повышения, и выдаче заявителю.<BR>*При указании главы, рекомендуется использовать сокращения:<BR>*СМО (главврач), СЕ (глав. инженер), РД (дир. исследований), КМ (завхоз), ГСБ (глава СБ), ГП (глава персонала).<BR>*Если один (или более) глав отсутствуют, необходимо собрать подписи, действующих глав.<BR>*Так же в данном документе, главам, которые согласились с кандидатом, необходимо поставить свою печать и подпись.</font></font>"

/obj/item/paper/form/NT_COM_LCOM
	name = "Форма NT-COM-LCOM"
	id = "NT-COM-LCOM"
	altername = "Заявление об увольнении главы отделения"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black><BR>ᅠᅠЯ, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, заявляю об официальном увольнении действующего главы <span class=\"paper_field\"></span>, отделения <span class=\"paper_field\"></span>. Причина увольнения:<span class=\"paper_field\"></span><BR>⠀⠀⠀При наличии иных причин, от других глав, они так же могут написать их в данном документе.<BR><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись инициатора увольнения: <span class=\"paper_field\"></span><BR>Подпись увольняемого, о ознакомлении: <span class=\"paper_field\"></span><BR>Дата и время увольнения: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченного лица, производившего инициацию увольнения, и выдаче увольняемому.<BR>*Для полной эффективности данного документа, необходимо собрать как можно больше причин для увольнения, и перечислить их. Инициировать увольнение может только <I> капитан или глава персонала. </I></font></font>"

/obj/item/paper/form/NT_COM_REQ
	name = "Форма NT-COM-REQ"
	id = "NT-COM-REQ"
	altername = "Запрос на поставку с Центрального командования"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black><BR><center><B>Приветствую Центральное командование</B></center><BR><BR>Сообщает вам <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>.<BR><BR><B>Текст запроса:</B> <span class=\"paper_field\"></span><BR><BR><B>Причина запроса:</B><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><BR>Подпись: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*В данном документе описывается запросы на поставку оборудования/ресурсов, необходимо перечислить по пунктно необходимое для поставки. <BR>*Данный документ считается, официальным, только после подписи уполномоченного лица, и наличии на документе его печати.</B> </font></font>"

/obj/item/paper/form/NT_COM_OS
	name = "Форма NT-COM-OS"
	id = "NT-COM-OS"
	altername = "Отчёт о выполнении цели"
	category = "Главы станции"
	info = "<font face=\"Verdana\" color=black><BR>Цель станции: <span class=\"paper_field\"></span><BR>Статус цели: <span class=\"paper_field\"></span><BR>Общее состояние станции: <span class=\"paper_field\"></span><BR>Активные угрозы: <span class=\"paper_field\"></span><BR>Оценка работы экипажа: <span class=\"paper_field\"></span><BR>Дополнительные замечания: <span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center>Должность уполномоченного лица: <span class=\"paper_field\"></span><BR>Подпись уполномоченного лица: <span class=\"paper_field\"></span><HR><font size = \"1\"><I>*Данное сообщение должно сообщить вам о состоянии цели, установленной Центральным командованием Nanotrasen для ИСН &#34;Керберос&#34;. Убедительная просьба внимательно прочитать данное сообщение для вынесения наиболее эффективных указаний для последующей деятельности станции.<BR>*Данный документ считается официальным только при наличии подписи уполномоченного лица и соответствующего его должности штампа. В случае отсутствия любого из указанных элементов данный документ не является официальным и рекомендуется его удалить с любого информационного носителя. <BR>ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ: Корпорация Nanotrasen не несёт ответственности, если данный документ не попал в руки первоначального предполагаемого получателя. Однако, корпорация Nanotrasen запрещает использование любой имеющейся в данном документе информации третьими лицами и сообщает, что это преследуется по закону, даже если информация в данном документе не является достоверной. <center></font>"

//Медицинский Отдел

/obj/item/paper/form/NT_MD_01
	name = "Форма NT-MD-01"
	id = "NT-MD-01"
	altername = "Постановление на поставку медикаментов"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀ Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашиваю следующие медикаменты на поставку в медбей:<BR><B><span class=\"paper_field\"></span></B><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center>Подпись заказчика: <span class=\"paper_field\"></span><BR>Подпись грузчика: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче грузчику или производившему поставку.</font></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_MD_02
	name = "Форма NT-MD-02"
	id = "NT-MD-02"
	altername = "Отчёт о вскрытии"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR><table></td><tr><td>Скончавшийся:<td><span class=\"paper_field\"></span><BR></td><tr><td>Раса:<td><span class=\"paper_field\"></span><BR></td><tr><td>Пол:<td><span class=\"paper_field\"></span><BR></td><tr><td>Возраст:<td><span class=\"paper_field\"></span><BR></td><tr><td>Группа крови:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Отчёт о вскрытии</B></font></center><BR><table></td><tr><td>Тип смерти:<td><span class=\"paper_field\"></span><BR></td><tr><td>Описание тела:<td><span class=\"paper_field\"></span><BR></td><tr><td>Метки и раны:<td><span class=\"paper_field\"></span><BR></td><tr><td>Вероятная причина смерти:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR>Детали:<BR><span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Вскрытие провёл:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_MD_03
	name = "Форма NT-MD-03"
	id = "NT-MD-03"
	altername = "Постановление на изготовление химических препаратов"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀ Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашиваю следующие химические медикаменты, для служебного использования в медбее:<BR><B><span class=\"paper_field\"></span></B><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center>Подпись заказчика: <span class=\"paper_field\"></span><BR>Подпись исполняющего: <span class=\"paper_field\"></span><BR>Время заказа: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче лицу исполнившему заказ</font></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_MD_04
	name = "Форма NT-MD-04"
	id = "NT-MD-04"
	altername = "Сводка о вирусе"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><B>Вирус: <span class=\"paper_field\"></span></B></center><BR><I>Полное название вируса: <span class=\"paper_field\"></span><BR>Свойства вируса: <span class=\"paper_field\"></span><BR>Передача вируса: <span class=\"paper_field\"></span><BR>Побочные эффекты: <span class=\"paper_field\"></span><BR><BR>Дополнительная информация: <span class=\"paper_field\"></span><BR><BR>Лечение вируса: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись вирусолога: <span class=\"paper_field\"></span><HR><font size = \"1\">*В дополнительной информации, указывается вся остальная информация, по поводу данного вируса.</font><BR></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_MD_05
	name = "Форма NT-MD-05"
	id = "NT-MD-05"
	altername = "Отчет об психологическом состоянии"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><BR>Пациент: <span class=\"paper_field\"></span><BR>Раздражители: <span class=\"paper_field\"></span><BR>Симптомы и побочные действия: <span class=\"paper_field\"></span><BR>Дополнительная информация: <span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись психолога: <span class=\"paper_field\"></span><BR>Время обследования: <span class=\"paper_field\"></span><BR><HR><I><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче пациенту</I></font></font>"
	footer = footer_signstamp

//Мед-без нумерации
/obj/item/paper/form/NT_MD_VRR
	name = "Форма NT-MD-VRR"
	id = "NT-MD-VRR"
	altername = "Запрос на распространение вируса"
	category = "Медицинский отдел"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR>Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, запрашиваю право на распространение вируса среди экипажа станции.<BR><table></td><tr><td>Название вируса:<td><span class=\"paper_field\"></span><BR></td><tr><td>Задачи вируса:<td><span class=\"paper_field\"></span><BR></td><tr><td>Лечение:<td><span class=\"paper_field\"></span><BR></td><tr><td>Вакцина была произведена<BR> и в данный момент находится:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Подпись вирусолога:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись глав. Врача:<td><span class=\"paper_field\"></span><BR></td></tr></td><tr><td>Подпись капитана:<td><span class=\"paper_field\"></span><BR></td></tr></table><hr><small>*Производитель вируса несет полную ответственность за его распространение, изолирование и лечение<br>*При возникновении опасных или смертельных побочных эффектов у членов экипажа, производитель должен незамедлительно предоставить вакцину, от данного вируса.</small></font>"
	footer = footer_signstamp

//Исследовательский отдел
/obj/item/paper/form/NT_RND_01
	name = "Форма NT-RND-01"
	id = "NT-RND-01"
	altername = "Отчет о странном предмете"
	category = "Исследовательский отдел"
	info = "<font face=\"Verdana\" color=black><BR>Название предмета: <span class=\"paper_field\"></span><BR>Тип предмета: <span class=\"paper_field\"></span><BR>Строение: <span class=\"paper_field\"></span><BR>Особенности и функционал: <span class=\"paper_field\"></span><BR>Дополнительная информация: <span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись производившего осмотр: <span class=\"paper_field\"></span><BR><HR><I><font size = \"1\">*В дополнительной информации, рекомендуется указать остальную информацию о предмете, любое взаимодействие с ним, модификации, итоговый вариант после модификации.</I></font></font>"

/obj/item/paper/form/NT_RND_02
	name = "Форма NT-RND-02"
	id = "NT-RND-02"
	altername = "Заявление на киберизацию"
	category = "Исследовательский отдел"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀ Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, самовольно подтверждаю согласие на проведение киберизации.<BR>⠀⠀⠀ Я полностью доверяю работнику <span class=\"paper_field\"></span> в должности – <span class=\"paper_field\"></span>. Я хорошо осведомлен о рисках, связанных как с операцией, так и с киберизацией, и понимаю, что Nanotrasen не несет ответственности, если эти процедуры вызовут боль, заражение или иные случаи летального характера.<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Если член экипажа мертв, данный документ нету необходимости создавать.<BR>*Если член экипажа жив, данный документ сохраняется только у уполномоченного лица.<BR>*Данный документ может использоваться как для создания киборгов, так и для ИИ<font size = \"1\"></font>"

/obj/item/paper/form/NT_RND_03
	name = "Форма NT-RND-03"
	id = "NT-RND-03"
	altername = "Заявление на получение и установку импланта"
	category = "Исследовательский отдел"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Требуемый имплантат:<BR><font size = \"1\">Может требовать дополнительного согласования</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Дата и время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись Руководителя Исследований:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись выполняющего установку имплантата:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

//Общие формы
/obj/item/paper/form/NT_BLANK
	name = "Форма NT"
	id = "NT-BLANK"
	altername = "Пустой бланк для любых целей"
	category = "Общие формы"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Заявление</B></font></center><BR><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись (дополнительная):<td><span class=\"paper_field\"></span></font>"
	footer = null

/obj/item/paper/form/NT_E_112
	name = "Форма NT-E-112"
	id = "NT-E-112"
	altername = "Экстренное письмо"
	category = "Общие формы"
	notice = "Форма предназначена только для экстренного использования."
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Отчёт о ситуации</B></font></center><BR><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_signstamp

//Отдел кадров
/obj/item/paper/form/NT_HR_00
	name = "Форма NT-HR-00"
	id = "NT-HR-00"
	altername = "Бланк заявления"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Заявление</B></font></center><BR><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись (дополнительная):<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_HR_01
	name = "Форма NT-HR-01"
	id = "NT-HR-01"
	altername = "Заявление о приеме на работу"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Запрашиваемая должность:<BR><font size = \"1\">Требует наличия квалификации</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Список компетенций:<BR><span class=\"paper_field\"></span><BR><BR></td></tr></table></font><font face=\"Verdana\" color=black><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись будущего главы:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/obj/item/paper/form/NT_HR_02
	name = "Форма NT-HR-02"
	id = "NT-HR-02"
	altername = "Заявление на смену должности"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Запрашиваемая должность:<BR><font size = \"1\">Требует наличия квалификации</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись текущего главы:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись будущего главы:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/obj/item/paper/form/NT_HR_12
	name = "Форма NT-HR-12"
	id = "NT-HR-12"
	altername = "Приказ на смену должности"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Приказ</B></font></center><BR><table></td><tr><td>Имя сотрудника:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта сотрудника:<BR><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Запрашиваемая должность:<BR><font size = \"1\">Требует наличия квалификации</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись инициатора:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/obj/item/paper/form/NT_HR_03
	name = "Форма NT-HR-03"
	id = "NT-HR-03"
	altername = "Заявление об увольнении"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись текущего главы:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/obj/item/paper/form/NT_HR_13
	name = "Форма NT-HR-13"
	id = "NT-HR-13"
	altername = "Приказ об увольнении"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Приказ</B></font></center><BR><table></td><tr><td>Имя увольняемого:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта увольняемого:<BR><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись инициатора:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/obj/item/paper/form/NT_HR_04
	name = "Форма NT-HR-04"
	id = "NT-HR-04"
	altername = "Заявление на выдачу новой ID карты"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/obj/item/paper/form/NT_HR_05
	name = "Форма NT-HR-05"
	id = "NT-HR-05"
	altername = "Заявление на дополнительный доступ"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Заявление</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Требуемый доступ:<BR><font size = \"1\">Может требовать дополнительного согласования</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Причина:<BR><font size = \"1\">Объясните свои намерения</font><BR><span class=\"paper_field\"></span><BR><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы персонала:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись текущего главы:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"

/obj/item/paper/form/NT_HR_06
	name = "Форма NT-HR-06"
	id = "NT-HR-06"
	altername = "Лицензия на создание организации/отдела"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><font size = \"4\"><B>Заявление</B></font></I></center><BR><BR>Я <B><span class=\"paper_field\"></span></B>, прошу Вашего разрешения на создание <B><span class=\"paper_field\"></span></B> для работы с экипажем.<BR><BR>Наше Агенство/Отдел займет <B><span class=\"paper_field\"></span></B>.<BR><BR>Наша Организация обязуется соблюдать Космический Закон. Также я <B><span class=\"paper_field\"></span></B>, как глава отдела, буду нести ответственность за своих сотрудников и обязуюсь наказывать их за несоблюдение Космического Закона. Или же передавать сотрудникам Службы Безопасности.<BR><BR><HR><BR><center><I><font size=\"4\"><B>Подписи и штампы</B></font></I></center><BR><I><BR>Время: <span class=\"paper_field\"></span><BR><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR><BR>Подпись главы персонала: <span class=\"paper_field\"></span></I><BR><HR><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан обладателю лицензии.</font><BR><BR><font size = \"1\">*Данная форма документа, обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей, лицензия будет являться недействительной.</font></font>"

/obj/item/paper/form/NT_HR_07
	name = "Форма NT-HR-07"
	id = "NT-HR-07"
	altername = "Разрешение на перестройку/перестановку"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black><center><I><font size=\"4\"><B>Разрешение</B></font></I></center><BR>Я <B><span class=\"paper_field\"></span></B>, прошу Вашего разрешения на перестройку/перестановку помещения <B><span class=\"paper_field\"></span></B> под свои нужды или нужды организации.<BR><BR>Должность заявителя: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><I><font size=\"4\"><B>Подписи и штампы</B></font></I></center><BR><I><BR>Время: <span class=\"paper_field\"></span><BR><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR><BR>Подпись главы персонала: <span class=\"paper_field\"></span></I><BR><BR><HR><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан заявителю.</font></font>"

/obj/item/paper/form/NT_HR_08
	name = "Форма NT-HR-08"
	id = "NT-HR-08"
	altername = "Запрос о постройке меха"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, прошу произвести постройку меха – <B><span class=\"paper_field\"></span></B>, с данными модификациями – <I><span class=\"paper_field\"></span></I>, для выполнения задач: <I><span class=\"paper_field\"></span></I>.<BR>⠀⠀⠀Так же я, <span class=\"paper_field\"></span>, обязуюсь соблюдать все правила, законы и предупреждения, а также соглашаюсь выполнять все устные или письменные инструкции, или приказы со стороны командования, представителей или агентов Nanotrasen, и Центрального командования.<BR>⠀⠀⠀При получении меха, я становлюсь ответственным за его повреждение, уничтожение, похищение, или попадание в руки людей, относящимся к врагам Nanotrasen.<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Время постройки меха: <span class=\"paper_field\"></span><BR>Время передачи меха заявителю: <span class=\"paper_field\"></span><BR>Подпись изготовителя меха: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче заявителю.</font></font>"

/obj/item/paper/form/NT_HR_09
	name = "Форма NT-HR-09"
	id = "NT-HR-09"
	altername = "Квитанция о продаже пода"
	category = "Отдел кадров"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span> произвожу передачу транспортного средства на платной основе члену экипажа <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>. Продаваемый под имеет модификации: <span class=\"paper_field\"></span>. Стоимость пода: <B><span class=\"paper_field\"></span></B>.<BR>⠀⠀⠀Я, <span class=\"paper_field\"></span>, как покупатель, становлюсь ответственным за его повреждение, уничтожение, похищение, или попадание в руки людей, относящимся к врагам Nanotrasen.<BR>⠀⠀⠀Так же я, обязуюсь соблюдать все правила, законы и предупреждения, а также соглашаюсь выполнять все устные или письменные инструкции, или приказы со стороны командования, представителей или агентов Nanotrasen, и Центрального командования.<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись продавца: <span class=\"paper_field\"></span><BR>Подпись покупателя: <span class=\"paper_field\"></span><BR>Время сделки: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче покупателю.</font></font>"

//Отдел сервиса
/obj/item/paper/form/NT_MR
	name = "Форма NT-MR"
	id = "NT-MR"
	altername = "Свидетельство о заключении брака"
	category = "Отдел сервиса"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Объявляется, что <span class=\"paper_field\"></span>, и <span class=\"paper_field\"></span>, официально прошли процедуру заключения гражданского брака.<BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR>Подпись свидетеля: <span class=\"paper_field\"></span><BR>Подпись свидетеля: <span class=\"paper_field\"></span><BR><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче одному из представителей брака.<BR>*При заявлении о расторжении брака, необходимо наличие двух супругов, и данного документа.</font></font>"

/obj/item/paper/form/NT_MRL
	name = "Форма NT-MRL"
	id = "NT-MRL"
	altername = "Заявление о расторжении брака"
	category = "Отдел сервиса"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Просим произвести регистрацию расторжения брака, подтверждаем взаимное согласие на расторжение брака.<BR><BR></center><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись супруга: <span class=\"paper_field\"></span><BR>Подпись супруги: <span class=\"paper_field\"></span><BR><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче каждому, из супругов.</font></font>"

//Отдел снабжения
/obj/item/paper/form/NT_REQ_01
	name = "Форма NT-REQ-01"
	id = "NT-REQ-01"
	altername = "Запрос на поставку"
	category = "Отдел снабжения"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Сторона запроса</B></font></center><BR><table></td><tr><td>Имя запросившего:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Способ получения:<BR><font size = \"1\">Предпочитаемый способ</font><td><span class=\"paper_field\"></span><BR></td><tr><td><BR>Причина запроса:<BR><span class=\"paper_field\"></span><BR><BR></td><tr><td>Список запроса:<BR><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Сторона поставки</B></font></center><BR><table></td><tr><td>Имя поставщика:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Способ доставки:<BR><font size = \"1\">Утверждённый способ</font><td><span class=\"paper_field\"></span><BR></td><tr><td><BR>Комментарии:<BR><span class=\"paper_field\"></span><BR><BR></td><tr><td>Список поставки и цены:<BR><span class=\"paper_field\"></span><BR><BR></td><tr><td>Итоговая стоимость:<BR><font size = \"1\">Пропустите, если бесплатно</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись стороны запроса:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись стороны поставки:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись главы (если требуется):<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_SUP_01
	name = "Форма NT-SUP-01"
	id = "NT-SUP-01"
	altername = "Регистрационная форма для подтверждения заказа"
	category = "Отдел снабжения"
	info = "<font face=\"Verdana\" color=black><center><H3>Отдел снабжения</H3></center><center><B>Регистрационная форма для подтверждения заказа</B></center><BR>Имя заявителя: <span class=\"paper_field\"></span><BR>Должность заявителя: <span class=\"paper_field\"></span><BR>Подробное объяснение о необходимости заказа: <span class=\"paper_field\"></span><BR><BR>Время: <span class=\"paper_field\"></span><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Подпись руководителя: <span class=\"paper_field\"></span><BR>Подпись сотрудника снабжения: <span class=\"paper_field\"></span><BR><HR><center><font size = \"1\"><I>Данная форма является приложением для оригинального автоматического документа, полученного с рук заявителя. Для подтверждения заказа заявителя необходимы указанные подписи и соответствующие печати отдела по заказу.<BR></font>"
	footer = null

//Служба безопасности
/obj/item/paper/form/NT_SEC_01
	name = "Форма NT-SEC-01"
	id = "NT-SEC-01"
	altername = "Свидетельские показания"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Информация о свидетеле</B></font></center><BR><table></td><tr><td>Имя свидетеля:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта свидетеля:<BR><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Должность свидетеля:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Свидетельство </B></font></center><BR><span class=\"paper_field\"></span><BR><BR><font size = \"1\">Я, (подпись свидетеля) <span class=\"paper_field\"></span>, подтверждаю, что приведенная выше информация является правдивой и точной, насколько мне известно, и передана в меру моих возможностей. Подписываясь ниже, я тем самым подтверждаю, что Верховный Суд может признать меня неуважительным или виновным в лжесвидетельстве согласно Закону SolGov 552 (a) (c) и Постановлению корпорации Nanotrasen 7716 (c).</font><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись сотрудника, получающего показания:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_11
	name = "Форма NT-SEC-11"
	id = "NT-SEC-11"
	altername = "Ордер на обыск"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Информация о свидетеле</B></font></center><BR><table></td><tr><td>Имя свидетеля:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта свидетеля:<BR><font size = \"1\">Эта информация есть у главы персонала</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Должность свидетеля:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Ордер</B></font></center><BR><table></td><tr><td>В целях обыска:<BR><font size = \"1\">(помещения, имущества, лица)</font><td><span class=\"paper_field\"></span></td></tr></table><BR>Ознакомившись с письменными показаниями свидетеля(-ей), у меня появились основания полагать, что на лицах или помещениях, указанных выше, имеются соответствующие доказательства в этой связи или в пределах, в частности:<BR><BR><span class=\"paper_field\"></span><BR><BR>и другое имущество, являющееся доказательством уголовного преступления, контрабанды, плодов преступления или предметов, иным образом принадлежащих преступнику, или имущество, спроектированное или предназначенное для использования, или которое используется или использовалось в качестве средства совершения уголовного преступления, в частности заговор с целью совершения преступления, или совершения злонамеренного предъявления ложных и фиктивных претензий к или против корпорации Нанотрейзен или его дочерних компаний.<BR><BR>Я удовлетворен тем, что показания под присягой и любые записанные показания устанавливают вероятную причину полагать, что описанное имущество в данный момент скрыто в описанных выше помещениях, лицах или имуществе, и устанавливают законные основания для выдачи этого ордера.<BR><BR>ВЫ НАСТОЯЩИМ КОМАНДИРОВАНЫ для обыска вышеуказанного помещения, имущества или лица в течение <span class=\"paper_field\"></span> минут с даты выдачи настоящего ордера на указанное скрытое имущество, и если будет установлено, что имущество изъято, оставить копию этого ордера в качестве доказательства на реквизированную собственность, в соответствии с требованиями указа корпорации Nanotrasen.<BR><BR>Слава Корпорации Nanotrasen!<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_21
	name = "Форма NT-SEC-21"
	id = "NT-SEC-21"
	altername = "Ордер на арест"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Ордер</B></font></center><BR><table></td><tr><td>В целях ареста:<BR><font size = \"1\">Имя полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Должность:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR>Сотрудники Службы Безопасности настоящим уполномочены и направлены на задержание и арест указанного лица. Они будут игнорировать любые заявления о неприкосновенности или привилегии со стороны подозреваемого или агентов, действующих от его имени. Сотрудники немедленно доставят указанное лицо в Бриг для отбывать наказание за следующие преступления:<BR><BR><span class=\"paper_field\"></span><BR><BR>Предполагается, что подозреваемый будет отбывать наказание в <span class=\"paper_field\"></span> за вышеуказанные преступления.<BR><BR>Слава Корпорации Nanotrasen!<BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_02
	name = "Форма NT-SEC-02"
	id = "NT-SEC-02"
	altername = "Отчёт по результатам расследования"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Дело <span class=\"paper_field\"></span></B></font></center><BR><table></td><tr><td>Тип проишествия/преступления:<td><span class=\"paper_field\"></span><BR></td><tr><td>Время проишествия/преступления:<td><span class=\"paper_field\"></span><BR></td><tr><td>Местоположение:<td><span class=\"paper_field\"></span><BR></td><tr><td>Краткое описание:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Участвующие лица</B></font></center><BR><table></td><tr><td>Арестованные:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подозреваемые:<td><span class=\"paper_field\"></span><BR></td><tr><td>Свидетели:<td><span class=\"paper_field\"></span><BR></td><tr><td>Раненные:<td><span class=\"paper_field\"></span><BR></td><tr><td>Пропавшие:<td><span class=\"paper_field\"></span><BR></td><tr><td>Скончавшиеся:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Ход расследования</B></font></center><BR><span class=\"paper_field\"></span><BR><BR><table></td><tr><td>Прикреплённые доказательства:<td><span class=\"paper_field\"></span><BR></td><tr><td>Дополнительные замечания:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_03
	name = "Форма NT-SEC-03"
	id = "NT-SEC-03"
	altername = "Заявление о краже"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, заявляю:<span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись потерпевшего: <span class=\"paper_field\"></span><BR>Подпись принимавшего заявление: <span class=\"paper_field\"></span><BR>Время принятия заявления: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче потерпевшему.<BR>*При обнаружении предмета кражи (предмет, жидкость или существо), данный предмет необходимо передать детективу, для дальнейшего осмотра и обследования.<BR>*После заключения детектива, предмет можно выдать владельцу. </font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_04
	name = "Форма NT-SEC-04"
	id = "NT-SEC-04"
	altername = "Заявление о причинении вреда здоровью или имуществу"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, заявляю:<span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись пострадавшего: <span class=\"paper_field\"></span><BR>Время происшествия: <span class=\"paper_field\"></span><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR>Время принятия заявления: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче пострадавшему.</font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_05
	name = "Форма NT-SEC-05"
	id = "NT-SEC-05"
	altername = "Разрешение на оружие"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black>⠀⠀⠀Члену экипажа, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, было выдано разрешение на оружие. Я соглашаюсь с условиями его использования, хранения и применения. Данное оружие я обязуюсь применять только в целях самообороны, защиты своих личных вещей, и рабочего места, а так же для защиты своих коллег.<BR>⠀⠀⠀При попытке применения оружия, против остальных членов экипажа не предоставляющих угрозу, или при запугивании данным оружием, я лишаюсь лицензии на оружие, а так же понесу наказания, при нарушении закона.<BR><I><B><BR>Название и тип оружия: <span class=\"paper_field\"></span></B><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR>Подпись получателя: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче получателю.<BR>*Документ не является действительным без печати Вардена/ГСБ и его подписи.</font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_06
	name = "Форма NT-SEC-06"
	id = "NT-SEC-06"
	altername = "Разрешение на присваивание канала связи"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><I><font size=\"4\"><B>Разрешение</B></font></I></center><BR>Я <B><span class=\"paper_field\"></span></B>, прошу Вашего разрешения на присваивание канала связи <B><span class=\"paper_field\"></span></B>, для грамотной работы организации.<BR><BR>Должность заявителя: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><I><font size=\"4\"><B>Подписи и штампы</B></font></I></center><BR><I><BR>Время: <span class=\"paper_field\"></span><BR><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR><BR>Подпись главы персонала: <span class=\"paper_field\"></span><BR><BR>Подпись главы службы безопасности: <span class=\"paper_field\"></span></I><BR><BR><HR><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан заявителю.</font><BR><BR><font size = \"1\">*Обязательно провести копирование документа для службы безопасности.</font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_07
	name = "Форма NT-SEC-07"
	id = "NT-SEC-07"
	altername = "Лицензия на использование канала связи и владение дополнительным оборудованием"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><I><font size=\"4\"><B>Лицензия</B></font></I></center><BR>Имя обладателя лицензии: <span class=\"paper_field\"></span><BR><BR>Должность обладателя лицензии: <span class=\"paper_field\"></span><BR><BR>Зарегистрированный канал связи: <span class=\"paper_field\"></span><BR><BR>Перечень зарегистрированной экипировки: <span class=\"paper_field\"></span><BR><HR><BR><center><I><font size=\"4\"><B>Подписи и штампы</B></font></I></center><BR><I><BR>Время: <span class=\"paper_field\"></span><BR><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR><BR>Подпись главы персонала: <span class=\"paper_field\"></span><BR><BR>Подпись главы службы безопасности: <span class=\"paper_field\"></span></I><BR><HR><font size = \"1\">*Обязательно провести копирование документа для главы персонала, оригинал документа должен быть выдан обладателю лицензии.</font><BR><BR><font size = \"1\">*Обязательно провести копирование документа для службы безопасности.</font><BR><BR><font size = \"1\">*Данная форма документа, обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей, лицензия будет являться недействительной.</font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_SEC_08
	name = "Форма NT-SEC-08"
	id = "NT-SEC-08"
	altername = "Лицензирование вооружения и экипировки для исполнения деятельности"
	category = "Служба безопасности"
	info = "<font face=\"Verdana\" color=black><center><I><font size=\"4\"><B>Лицензия</B></font></I></center><BR><BR>Имя обладателя лицензии: <span class=\"paper_field\"></span><BR>Должность обладателя лицензии: <span class=\"paper_field\"></span><BR>Перечень зарегистрированного вооружения: <span class=\"paper_field\"></span><BR>Перечень зарегистрированной экипировки: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><I><font size=\"4\"><B>Подписи и штампы</B></font></I></center><BR><BR>Время: <span class=\"paper_field\"></span><BR>Подпись обладателя  лицензии: <span class=\"paper_field\"></span><BR>Подпись главы службы безопасности: <span class=\"paper_field\"></span><BR><BR><HR><font size = \"1\"><I> *Данная форма документа, обязательно должна подтверждаться печатью ответственного лица. В случае наличия опечаток и отсутствия подписей или печатей, лицензия будет является недействительной. Обязательно провести копирование документа для службы безопасности, оригинал документа должен быть выдан обладателю лицензии. В случае несоответствия должности обладателя лицензии, можно приступить к процедуре аннулирования лицензии и изъятию вооружения, экипировки.<BR></font>"
	footer = footer_confidential

//Юридический отдел
/obj/item/paper/form/NT_LD_00
	name = "Форма NT-LD-00"
	id = "NT-LD-00"
	altername = "Бланк заявления"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Основная информация</B></font></center><BR><table></td><tr><td>Имя заявителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Номер аккаунта заявителя:<BR><font size = \"1\">Эта информация есть в ваших заметках</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Текущая должность:<BR><font size = \"1\">Указано на ID карте</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Заявление</B></font></center><BR><span class=\"paper_field\"></span><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись заявителя:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного сотрудника:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_signstamp

/obj/item/paper/form/NT_LD_01
	name = "Форма NT-LD-01"
	id = "NT-LD-01"
	altername = "Судебный приговор"
	category = "Юридический отдел"
	notice = "Данный документ является законным решением суда.<BR>Пожалуйста внимательно прочитайте его и следуйте предписаниям, указанные в нем."
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Дело <span class=\"paper_field\"></span></B></font></center><BR><table></td><tr><td>Имя обвинителя:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td><tr><td>Имя обвиняемого:<BR><font size = \"1\">Полностью и без ошибок</font><td><span class=\"paper_field\"></span><BR></td></tr></table><BR><center><font size=\"4\"><B>Приговор</B></font></center><BR><span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_02
	name = "Форма NT-LD-02"
	id = "NT-LD-02"
	altername = "Смертный приговор"
	category = "Юридический отдел"
	notice = "Любой смертный приговор, выданный человеком, званием младше, чем капитан, является не действительным, и все казни, действующие от этого приговора являются незаконными. Любой, кто незаконно привел в исполнение смертный приговор действую согласно ложному ордену виновен в убийстве первой степени, и должен быть приговорен минимум к пожизненному заключению и максимум к кибернизации. Этот документ или его факс-копия являются Приговором, который может оспорить только Магистрат или Дивизией защиты активов Nanotrasen (далее именуемой «Компанией»)"
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Дело <span class=\"paper_field\"></span></B></font></center><BR>Принимая во внимание, что <span class=\"paper_field\"></span> <font size = \"1\">(далее именуемый \"подсудимый\")</font>, <BR>сознательно совершил преступления X-5 статей Космического закона <font size = \"1\">(далее указаны как \"преступления\")</font>, <BR>а именно: <span class=\"paper_field\"></span>, <BR>суд приговаривает подсудимого к смертной казни через <span class=\"paper_field\"></span>.<BR><BR>Приговор должен быть приведен в исполнение в течение 15 минут после получения данного приказа. Вещи подсудимого, включая ID-карту, ПДА, униформу и рюкзак, должны быть сохранены и переданы соответствующем органам (ID-карту передать главе персонала или капитану для уничтожения), возвращены в соответсвующий отдел или сложены в хранилище улик. Любая контрабанда должна немедленно помещена в хранилище улик. Любую контрабанду запрещено использовать защитой активов или другими персонами, представляющих компанию или её активы и цели, кроме сотрудников отдела исследований и развития.<BR><BR>Тело подсудимого должно быть помещено в морг и забальзамировано, только если данное действие не будет нести опасность станции, активам компании или её имуществу. Останки подсудимого должны быть собраны и подготовлены к доставке к близлежащему административному центру компании, всё имущество и активы должны быть переданы семье подсудимого после окончания смены.<BR><BR>Слава Nanotrasen!<BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_03
	name = "Форма NT-LD-03"
	id = "NT-LD-03"
	altername = "Заявление о нарушении СРП членом экипажа"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black><BR>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, заявляю, что член экипажа – <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, нарушил один (или несколько) пунктов из <I>Стандартных Рабочих Процедур</I>, а именно:<span class=\"paper_field\"></span><BR><BR>Примерное время нарушения: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR>Подпись принимающего: <span class=\"paper_field\"></span><BR>Время принятия заявления: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче заявителю.<BR>*После вынесения решения в отношении правонарушителя, желательно сообщить о решении заявителю.<BR></font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_04
	name = "Форма NT-LD-04"
	id = "NT-LD-04"
	altername = "Заявление о нарушении СРП одним из отделов"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black><BR>⠀⠀⠀Я, <span class=\"paper_field\"></span>, в должности – <span class=\"paper_field\"></span>, заявляю, что сотрудники в отделении <span class=\"paper_field\"></span>, нарушили один (или несколько) пунктов из <I>Стандартных Рабочих Процедур</I>, а именно:<span class=\"paper_field\"></span><BR><BR>Примерное время нарушения: <span class=\"paper_field\"></span><BR>Подпись заявителя: <span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись принимающего: <span class=\"paper_field\"></span><BR>Время принятия заявления: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче заявителю.<BR>*После вынесения решения в отношении правонарушителей, желательно сообщить о решении заявителю.<BR></font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_05
	name = "Форма NT-LD-05"
	id = "NT-LD-05"
	altername = "Отчет агента внутренних дел"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black>ᅠᅠЯ, <span class=\"paper_field\"></span>, Как агент внутренних дел, сообщаю:<span class=\"paper_field\"></span><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR>Подпись АВД: <span class=\"paper_field\"></span><BR>Подпись уполномоченного: <span class=\"paper_field\"></span><BR>Время принятия отчета: <span class=\"paper_field\"></span><BR><HR><font size = \"1\">*Данный документ подлежит ксерокопированию, для сохранения в архиве уполномоченных лиц, и выдаче агенту.<BR>*Данный документ может содержать нарушения, неправильность выполнения работы, невыполнение правил/сводов/законов/СРП </font></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_LD_06
	name = "Форма NT-LD-06"
	id = "NT-LD-06"
	altername = "Бланк жалоб АВД"
	category = "Юридический отдел"
	info = "<font face=\"Verdana\" color=black><BR><center><I><font size=\"4\"><B>Заявление</B></font></I></center><BR><BR><BR><B>Заявитель: </B><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите своё полное имя, должность и номер акаунта.</font><BR><B>Предмет жалобы:</B><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите на что/кого вы жалуетесь.</font><BR><B>Обстоятельства: </B><span class=\"paper_field\"></span><BR><font size = \"1\">Укажите подробные обстоятельства произошедшего.</font><BR><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><B>Подпись: </B><span class=\"paper_field\"></span><BR><font size = \"1\">Ваша подпись.</font><BR><B>Жалоба рассмотрена: </B><span class=\"paper_field\"></span><BR><font size = \"1\">Имя и фамилия рассмотревшего.</font><BR><BR><HR><BR><font size = \"1\"><I>*Обязательно провести копирование документа для агента внутренних дел, оригинал документа должен быть приложен к отчету о расследовании. Копия документа должна быть сохранена в картотеке офиса агента внутренних дел.</font><BR><BR><font size = \"1\"><I>*Обязательно донести жалобу до главы отдела, который отвечает за данного сотрудника, если таковой имеется. Если главы отдела нет на смене или он отсуствует по какой то причине, жалобу следует донести до вышестоящего сотрудника станции.</font><BR><BR><font size = \"1\"><I>*Если жалоба была написана на главу отдела, следует донести жалобу до вышестоящего сотрудника станции.</font><BR><BR><font size = \"1\"><I>*Глава отдела, которому была донесена жалоба, обязан провести беседу с указаным в жалобе сотрудником станции. В зависимости от тяжести проступка, глава отдела имеет право подать приказ об увольнении.</font></font>"
	footer = footer_confidential

//Центральное командование
/obj/item/paper/form/NT_COM_01
	name = "Форма NT-COM-01"
	id = "NT-COM-01"
	altername = "Запрос отчёта общего состояния станции"
	category = "Центральное командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Запрос</B></font></center><BR>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения об общем состоянии станции.<BR><BR><HR><BR><center><font size=\"4\"><B>Ответ</B></font></center><BR><table></td><tr><td>Общее состояние станции:<td><span class=\"paper_field\"></span><BR></td><tr><td>Криминальный статус:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Повышений:<td><span class=\"paper_field\"></span><BR></td><tr><td>Понижений:<td><span class=\"paper_field\"></span><BR></td><tr><td>Увольнений:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Раненные:<td><span class=\"paper_field\"></span><BR></td><tr><td>Пропавшие:<td><span class=\"paper_field\"></span><BR></td><tr><td>Скончавшиеся:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_COM_02
	name = "Форма NT-COM-02"
	id = "NT-COM-02"
	altername = "Запрос отчёта состояния трудовых активов станции"
	category = "Центральное командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Запрос</B></font></center><BR>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения о состоянии трудовых активов станции.<BR><BR><HR><BR><center><font size=\"4\"><B>Ответ</B></font></center><BR><table></td><tr><td>Количество сотрудников:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество гражданских:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество киборгов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество ИИ:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Заявлений о приёме на работу:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений на смену должности:<td><span class=\"paper_field\"></span><BR></td><tr><td>Приказов на смену должности:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений об увольнении:<td><span class=\"paper_field\"></span><BR></td><tr><td>Приказов об увольнении:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений на выдачу новой ID карты:<td><span class=\"paper_field\"></span><BR></td><tr><td>Заявлений на дополнительный доступ:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Медианный уровень кваллификации смены:<td><span class=\"paper_field\"></span><BR></td><tr><td>Уровень взаимодействия отделов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Самый продуктивный отдел смены:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Приложите все имеющиеся документы:<td>NT-HR-00<BR></td><tr><td><td>NT-HR-01<BR></td><tr><td><td>NT-HR-02<BR></td><tr><td><td>NT-HR-12<BR></td><tr><td><td>NT-HR-03<BR></td><tr><td><td>NT-HR-13<BR></td><tr><td><td>NT-HR-04<BR></td><tr><td><td>NT-HR-05<BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_COM_03
	name = "Форма NT-COM-03"
	id = "NT-COM-03"
	altername = "Запрос отчёта криминального статуса станции"
	category = "Центральное командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = "<font face=\"Verdana\" color=black><center><font size=\"4\"><B>Запрос</B></font></center>\
	<BR>Уполномоченный офицер, <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>, запрашивает сведения о криминальном статусе станции.\
	<BR><BR><HR><BR><center><font size=\"4\"><B>Ответ</B></font></center><BR><table></td>\
	<tr><td>Текущий статус угрозы:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество офицеров в отделе:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество раненных офицеров:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество скончавшихся офицеров:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество серъёзных инцидентов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество незначительных инцидентов:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество раскрытых дел:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество арестованных:<td><span class=\"paper_field\"></span><BR></td><tr><td>Количество сбежавших:<td><span class=\"paper_field\"></span><BR></td></tr></table><BR><table></td><tr><td>Приложите все имеющиеся документы:<td>NT-SEC-01<BR></td><tr><td><td>NT-SEC-11<BR></td><tr><td><td>NT-SEC-21<BR></td><tr><td><td>NT-SEC-02<BR></td><tr><td><td>Лог камер заключения<BR></td></tr></table><BR><HR><BR><center><font size=\"4\"><B>Подписи и штампы</B></font></center><BR><table></td><tr><td>Время:<td><span class=\"paper_field\"></span><BR></td><tr><td>Подпись уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td><tr><td>Должность уполномоченного лица:<td><span class=\"paper_field\"></span><BR></td></tr></table></font>"
	footer = footer_confidential

/obj/item/paper/form/NT_COM_04
	name = "Форма NT-COM-04"
	id = "NT-COM-04"
	altername = "Запрос отчёта здравоохранения станции"
	category = "Центральное командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

/obj/item/paper/form/NT_COM_05
	name = "Форма NT-COM-05"
	id = "NT-COM-05"
	altername = "Запрос отчёта научно-технического прогресса станции"
	category = "Центральное командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

/obj/item/paper/form/NT_COM_06
	name = "Форма NT-COM-06"
	id = "NT-COM-06"
	altername = "Запрос отчёта инженерного обеспечения станции"
	category = "Центральное командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

/obj/item/paper/form/NT_COM_07
	name = "Форма NT-COM-07"
	id = "NT-COM-07"
	altername = "Запрос отчёта статуса снабжения станции "
	category = "Центральное командование"
	from = "Административная станция Nanotrasen &#34;Trurl&#34;"
	notice = "Перед заполнением прочтите от начала до конца | Высокий приоритет"
	confidential = TRUE
	access = ACCESS_CENT_GENERAL
	info = ""
	footer = footer_confidential

//Синдикатские формы

/obj/item/paper/form/syndieform
	name = "ALERT A CODER SYND FORM"
	altername = "ALERT A CODER FORM"
	access = ACCESS_SYNDICATE_COMMAND
	confidential = TRUE
	category = null
	var/const/footer_to_taipan =   "<I><font face=\"Verdana\" color=black size = \"1\">\
									<HR>\
									*Несоблюдение и/или нарушение указаний, содержащихся в данном письме, карается смертью.\
									<BR>*Копирование, распространение и использование содержащейся информации карается смертью, за исключением случаев, описанных в письме.\
									<BR>*Письмо подлежит уничтожению после ознакомления.\
									</font></I>"
	var/const/footer_from_taipan = "<I><font face=\"Verdana\" color=black size = \"1\">\
									<HR>\
									*Целевым получателем запроса является Синдикат\
									<BR>*Копирование, распространение и использование документа и представленной информации \
									за пределами целевого получателя запроса и экипажа станции запрещено.\
									<BR>*Оригинал документа после отправки целевому получателю подлежит хранению в защищённом месте, \
									либо уничтожению с соответствующим указанием.\
									<BR>*В случае проникновения на объект посторонних лиц или угрозы проникновения документ подлежит уничтожению до или после отправки.\
									</font></I>"
	footer = footer_to_taipan

/obj/item/paper/form/syndieform/New()
	. = ..()
	if(is_header_needed)
		header = "	<font face=\"Verdana\" color=black>\
					<table cellspacing=0 cellpadding=3  align=\"right\">\
					<tr><td><img src= syndielogo.png></td></tr>\
					</table><br>\
					<table border=10 cellspacing=0 cellpadding=3 width =\"250\" height=\"100\"  align=\"center\" bgcolor=\"#B50F1D\">\
					<td><center><B>[confidential ? "СОВЕРШЕННО СЕКРЕТНО<BR>" : ""]</B><B>[id]</B></center></td>\
					</table>\
					<br><HR></font>"
	populatefields()

/obj/item/paper/form/syndieform/SYND_COM_TC
	name = "Форма SYND-COM-TC"
	id = "SYND-COM-TC"
	altername = "Официальное письмо"
	category = "Синдикат"
	access = ACCESS_SYNDICATE_COMMAND
	footer = footer_to_taipan
	info = "<font face=\"Verdana\" color=black>\
			<center><H2><U>Официальное письмо объекту</U><BR>&#34;ННКСС Тайпан&#34;</H2></center><HR>\
			<span class=\"paper_field\"></span><BR>\
			<font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<BR>Дата: <span class=\"paper_field\"></span> \
			<BR>Время: <span class=\"paper_field\"></span> \
			<BR></font></font>"

/obj/item/paper/form/syndieform/SYND_COM_SUP
	name = "Форма SYND-COM-SUP"
	id = "SYND-COM-SUP"
	altername = "Запрос особой доставки"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<center><H2>Запрос особой доставки на станцию<BR>Синдиката</H2></center><HR>\
			<center><table>\
			<table border=1 cellspacing=0 cellpadding=3 style='border: 1px solid black;'>\
			<td><center><font size=\"4\">Данные<BR>для<BR>доставки</font></center><td>\
			<center><B><U><font size=\"4\">Получатель</font></U></B></center>\
			<U>Наименование станции</U>: &#34;ННКСС <B>Тайпан</B>&#34;\
			<BR><U>Наименование сектора</U>: Эпсилон Эридана\
			</td></tr></table>\
			</center><BR>В связи с отсутствием в стандартном перечени заказов прошу доставить следующее:\
			<BR><ul><li><U><span class=\"paper_field\"></span></U></ul>\
			<BR>Причина запроса: <B><span class=\"paper_field\"></span></B>\
			<BR><font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<BR>Дата: <span class=\"paper_field\"></span> \
			<BR>Время: <span class=\"paper_field\"></span> \
			<BR></font></font>"

/obj/item/paper/form/syndieform/SYND_TAI_NO00
	name = "Форма SYND-TAI-№00"
	id = "SYND-TAI-№00"
	altername = "Экстренное письмо"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<center><H2><U>Экстренное письмо</U><BR>ННКСС &#34;Тайпан&#34;</H2></center><HR>\
			<span class=\"paper_field\"></span>\
			<BR><font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<BR>Дата: <span class=\"paper_field\"></span> \
			<BR>Время: <span class=\"paper_field\"></span> \
			<BR></font></font>"

/obj/item/paper/form/syndieform/SYND_TAI_NO01
	name = "Форма SYND-TAI-№01"
	id = "SYND-TAI-№01"
	altername = "Отчёт о ситуации на станции"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<H3>Отчёт о ситуации на станции</H3><HR>\
			<U>Наименование станции</U>: ННКСС &#34;Тайпан&#34;<BR>\
			<BR>Общее состояние станции: <span class=\"paper_field\"></span>\
			<BR>Численность персонала станции: <span class=\"paper_field\"></span>\
			<BR>Общее состояние персонала станции: <span class=\"paper_field\"></span>\
			<BR>Непосредственные внешние угрозы: <B><span class=\"paper_field\"></span></B>\
			<BR>Подробности: <span class=\"paper_field\"></span>\
			<BR>Дополнительная информация: <span class=\"paper_field\"></span><BR>\
			<BR><font size = \"1\">\
			Подпись: <span class=\"paper_field\"></span>, в должности <span class=\"paper_field\"></span>\
			<BR>Дата: <span class=\"paper_field\"></span> \
			<BR>Время: <span class=\"paper_field\"></span> \
			<BR></font></font>"

/obj/item/paper/form/syndieform/SYND_TAI_NO02
	name = "Форма SYND-TAI-№02"
	id = "SYND-TAI-№02"
	altername = "Отчёт о разработке вируса"
	category = "Синдикат"
	access = ACCESS_SYNDICATE
	footer = footer_from_taipan
	info = "<font face=\"Verdana\" color=black>\
			<H3>Отчёт о разработке вируса</H3>\
			<HR><U>Наименование вируса</U>: <B><span class=\"paper_field\"></span></B><BR>\
			<BR>Тип вируса: <span class=\"paper_field\"></span>\
			<BR>Способ распространения: <span class=\"paper_field\"></span>\
			<BR>Перечень симптомов: <span class=\"paper_field\"></span>\
			<BR>Описание: <span class=\"paper_field\"></span><BR>\
			<BR><U>Наличие вакцины</U>: <B><span class=\"paper_field\"></span></B>\
			<BR><U>Наименование вакцины</U>: <span class=\"paper_field\"></span><BR>\
			<BR>Дополнительная информация***: <span class=\"paper_field\"></span>\
			<BR>Указания к хранению вируса***: <span class=\"paper_field\"></span><BR>\
			<BR><font size = \"1\">Подпись разработчика: <span class=\"paper_field\"></span>, в должности <B><span class=\"paper_field\"></span></B>\
			<BR>Подпись Директора Исследований**: <span class=\"paper_field\"></span>\
			<BR>Дата: <span class=\"paper_field\"></span> \
			<BR>Время: <span class=\"paper_field\"></span> \
			<HR><I><font size = \"1\">**Отчёт недействителен без подписи Директора Исследований. \
			В случае его отсутствия требуется подпись Офицера Телекоммуникаций или заменяющего его лица с указанием должности.\
			<BR>***Заполняется Директором Исследований. В случае его отсутствия, заполняется Офицером Телекоммуникаций или заменяющим его лицом</font>"

//======
/obj/item/paper/deltainfo
	name = "Информационный буклет НСС Керберос"
	info = "<font face=\"Verdana\" color=black><center><H1>Буклет нового сотрудника \
			на борту НСС &#34;Керберос&#34;</H1></center>\
			<BR><HR><B></B><BR><center><H2>Цель</H2></center>\
			<BR><font size=\"4\">Данное руководство было создано с целью \
			<B>облегчить процесс</B> введения в работу станции <B>нового экипажа</B>, \
			а также для <B>информирования сотрудников</B> об оптимальных маршрутах \
			передвижения. В данном буклете находится <B>основная карта</B> &#34;Кербероса&#34; \
			и несколько интересных фактов о станции.</font>\
			<BR><HR><BR><center><H2>Карта Станции</H2></center>\
			<BR><font size=\"4\">С точки зрения конструкции, станция состоит из 12 зон:\
			<BR><ul><li>Прибытие - <B><B>Серый</B></B> - Отсек прибытия экипажа и ангар космических подов.\
			<BR><li>Мостик - <B>Синий</B> - Отсек командования и VIP-персон.\
			<BR><li>Двор - <B>Зелёный</B> - Отсек сферы услуг.\
			<BR><li>Карго - <B>Оранжевый</B> - Отсек снабжения и поставок.\
			<BR><li>Инженерия - <B>Жёлтый</B> - Отсек технического обслуживания и систем станции.\
			<BR><li>Бриг - <B>Красный</B> - Отсек службы безопасности.\
			<BR><li>Процедурная - <B>Розовый</B> - Юридические зоны и процедурный отсек.\
			<BR><li>Дормы - <B>Розовый</B> - Отсек для отдыха и развлечений.\
			<BR><li>РнД - <B>Фиолетовый</B> - Отсек научных исследований и разработок.\
			<BR><li>Медбей - <B>Голубой</B> - Отсек медицинских услуг и биовирусных разработок.\
			<BR><li>Спутник ИИ - <B>Тёмно-синий</B> - Отсек систем искусственного интеллекта станции.\
			<BR><li>Отбытие - <B>Салатовый</B> - Отсек отбытия и эвакуационного шаттла.\
			<BR><li>Зоны исследователей - <B>Светло-синий</B> - Гейт, ЕВА и экспедиционный склад. \
			<BR><li>Технические туннели - <B>Коричневый</B> - Неэксплуатируемые технические помещения.\
			<BR><li>Библиотека - <B>Зона и путь в чёрном пунктире</B> - Архив и место для получения новых знаний и СРП.\
			<BR><li>Офис Главы Персонала - <B>Зона и путь в белом пунктире</B> - Место для получения работы.\
			<BR></ul><HR></font> \
			<img src=\"https://media.discordapp.net/attachments/911024179984347217/1066699505099096144/map2.png?width=600&height=600\">\
			<font face=\"Verdana\" color=black><BR><BR><HR><BR><center><H2>Технические туннели</H2></center>\
			<BR> За время строительства проект станции претерпел несколько значительных \
			изменений. Изначально новая станция должна была стать туристическим объектом, \
			но после произошедшей в <B>2549 году</B> серии <B>террористических актов</B> \
			объект вошёл в состав парка научно-исследовательских станций корпорации. В \
			нынешних технических туннелях до сих пор можно найти заброшенные комнаты для \
			гостей, бары и клубы. В связи с плачевным состоянием несущих конструкций \
			посещать эти части станции не рекомендуется, однако неиспользуемые площади \
			могут быть использованы для строительства новых отсеков.\
			<BR><HR><BR><center><H2>Особенности станции</H2></center>\
			<BR>В отличие от большинства других научно-исследовательских станций Nanotrasen, \
			таких как &#34;Кибериада&#34;, <B>НСС &#34;Керборос&#34;</B> имеет менее \
			жёсткую систему контроля за личными вещами экипажа. В частности, в отсеках \
			были построены <B>дополнительные автолаты</B>, в том числе <B>публичные</B> \
			(в карго и РНД). Также, благодаря более высокому бюджету, были возведены \
			<B>новые отсеки</B>, такие как <B>ангар</B> или <B>склад</B> в отсеке РнД.\
			Был расширен отдел <B>вирусологии</B> и возведены <B>новые техничесские туннели</B> для \
			новых проектов.</font>"
	icon_state = "pamphlet"

/obj/item/paper/deltainfo/update_icon()
	return

/obj/item/paper/pamphletdeathsquad
	icon_state = "pamphlet-ds"

/obj/item/paper/pamphletdeathsquad/update_icon()
	return
