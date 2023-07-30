/obj/item/paicard
	name = "personal AI device"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = SLOT_BELT
	origin_tech = "programming=2"
	var/request_cooldown = 5 // five seconds
	var/last_request
	var/obj/item/radio/headset/radio
	var/looking_for_personality = 0
	var/mob/living/silicon/pai/pai
	var/list/faction = list("neutral") // The factions the pAI will inherit from the card
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	var/next_ping_at = 0

	/// for Syndicate pAI type
	var/is_syndicate_type = FALSE
	var/extra_memory = 0
	var/obj/item/paicard_upgrade/upgrade

/obj/item/paicard/syndicate // Only seems that it is syndicard
	name = "syndicate personal AI device"
	faction = list("syndicate")
	is_syndicate_type = TRUE
	extra_memory = 50

/obj/item/paicard/New()
	..()
	overlays += "pai-off"

/obj/item/paicard/Destroy()
	if(pai)
		pai.ghostize()
		QDEL_NULL(pai)
	QDEL_NULL(radio)
	return ..()

/obj/item/paicard/attack_self(mob/user)
	if(!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = {"
		<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">
		<html>
			<meta charset="UTF-8">
			<head>
				<style>
					body {
					    margin-top:5px;
					    font-family:Verdana;
					    color:white;
					    font-size:13px;
					    background-image:url('uiBackground.png');
					    background-repeat:repeat-x;
					    background-color:#272727;
						background-position:center top;
					}
					table {
					    font-size:13px;
					    margin-left:-2px;
					}
					table.request {
					    border-collapse:collapse;
					}
					table.desc {
					    border-collapse:collapse;
					    font-size:13px;
					    border: 1px solid #161616;
					    width:100%;
					}
					table.download {
					    border-collapse:collapse;
					    font-size:13px;
					    border: 1px solid #161616;
					    width:100%;
					}
					tr.d0 td, tr.d0 th {
					    background-color: #506070;
					    color: white;
					}
					tr.d1 td, tr.d1 th {
					    background-color: #708090;
					    color: white;
					}
					tr.d2 td {
					    background-color: #00FF00;
					    color: white;
					    text-align:center;
					}
					td.button {
					    border: 1px solid #161616;
					    background-color: #40628a;
					}
					td.button {
					    border: 1px solid #161616;
					    background-color: #40628a;
					    text-align: center;
					}
					td.button_red {
					    border: 1px solid #161616;
					    background-color: #B04040;
					    text-align: center;
					}
					td.download {
					    border: 1px solid #161616;
					    background-color: #40628a;
					    text-align: center;
					}
					th {
					    text-align:left;
					    width:125px;
					}
					td.request {
					    width:140px;
					    vertical-align:top;
					}
					td.radio {
					    width:90px;
					    vertical-align:top;
					}
					td.request {
					    vertical-align:top;
					}
					a {
					    color:#4477E0;
					}
					a.button {
					    color:white;
					    text-decoration: none;
					}
					h2 {
					    font-size:15px;
					}
				</style>
			</head>
			<body>
	"}

	if(pai)
		dat += {"
			<b><font size='3px'>Personal AI Device</font></b><br><br>
			<table class="request">
				<tr>
					<td class="request">Installed Personality:</td>
					<td>[pai.name]</td>
				</tr>
				<tr>
					<td class="request">Prime directive:</td>
					<td>[pai.pai_law0]</td>
				</tr>
				<tr>
					<td class="request">Additional directives:</td>
					<td>[pai.pai_laws]</td>
				</tr>
			</table>
			<br>
		"}
		dat += {"
			<table>
				<td class="button">
					<a href='byond://?src=[UID()];setlaws=1' class='button'>Configure Directives</a>
				</td>
			</table>
		"}
		if(pai && (!pai.master_dna || !pai.master))
			dat += {"
				<table>
					<td class="button">
						<a href='byond://?src=[UID()];setdna=1' class='button'>Imprint Master DNA</a>
					</td>
				</table>
			"}
		dat += "<br>"
		if(radio)
			dat += "<b>Radio Uplink</b>"
			dat += {"
				<table class="request">
					<tr>
						<td class="radio">Transmit:</td>
						<td><a href='byond://?src=[UID()];wires=4'>[radio.broadcasting ? "<font color=#55FF55>En" : "<font color=#FF5555>Dis" ]abled</font></a>

						</td>
					</tr>
					<tr>
						<td class="radio">Receive:</td>
						<td><a href='byond://?src=[UID()];wires=2'>[radio.listening ? "<font color=#55FF55>En" : "<font color=#FF5555>Dis" ]abled</font></a>

						</td>
					</tr>
				</table>
				<br>
			"}
		else
			dat += "<b>Radio Uplink</b><br>"
			dat += "<font color=red><i>Radio firmware not loaded. Please install a pAI personality to load firmware.</i></font><br>"
		dat += {"
			<table>
				<td class="button_red"><a href='byond://?src=[UID()];wipe=1' class='button'>Wipe current pAI personality</a>

				</td>
			</table>
		"}
	else
		if(looking_for_personality)
			dat += {"
				<b><font size='3px'>pAI Request Module</font></b><br><br>
				<p>Requesting AI personalities from central database... If there are no entries, or if a suitable entry is not listed, check again later as more personalities may be added.</p>
				Searching for personalities, please wait...<br><br>

				<table>
					<tr>
						<td class="button">
							<a href='byond://?src=[UID()];request=1' class="button">Refresh available personalities</a>
						</td>
					</tr>
				</table><br>
			"}
		else
			dat += {"
				<b><font size='3px'>pAI Request Module</font></b><br><br>
			    <p>No personality is installed.</p>
				<table>
					<tr>
						<td class="button"><a href='byond://?src=[UID()];request=1' class="button">Request personality</a>
						</td>
					</tr>
				</table>
				<br>
				<p>Each time this button is pressed, a request will be sent out to any available personalities. Check back often give plenty of time for personalities to respond. This process could take anywhere from 15 seconds to several minutes, depending on the available personalities' timeliness.</p>
			"}
	user << browse(dat, "window=paicard")
	onclose(user, "paicard")
	return

/obj/item/paicard/Topic(href, href_list)

	var/mob/U = usr

	if(!usr || usr.stat)
		return

	if(pai)
		if(!in_range(src, U))
			U << browse(null, "window=paicard")
			usr.unset_machine()
			return

	if(href_list["setdna"])
		if(pai.master_dna)
			return
		var/mob/M = usr
		if(!istype(M, /mob/living/carbon))
			to_chat(usr, "<font color=blue>You don't have any DNA, or your DNA is incompatible with this device.</font>")
		else
			var/datum/dna/dna = usr.dna
			pai.master = M.real_name
			pai.master_dna = dna.unique_enzymes
			to_chat(pai, "<font color = red><h3>You have been bound to a new master.</h3></font>")
	if(href_list["request"])
		var/delta = (world.time / 10) - last_request
		if(request_cooldown > delta)
			var/cooldown_time = round(request_cooldown - ((world.time / 10) - last_request), 1)
			to_chat(usr, "<span class='warning'>The request system is currently offline. Please wait another [cooldown_time] seconds.</span>")
			return
		last_request = world.time / 10
		looking_for_personality = 1
		GLOB.paiController.findPAI(src, usr)
	if(href_list["wipe"])
		var/confirm = input("Are you CERTAIN you wish to delete the current personality? This action cannot be undone.", "Personality Wipe") in list("Yes", "No")
		if(confirm == "Yes")
			for(var/mob/M in src)
				to_chat(M, "<font color = #ff0000><h2>You feel yourself slipping away from reality.</h2></font>")
				to_chat(M, "<font color = #ff4d4d><h3>Byte by byte you lose your sense of self.</h3></font>")
				to_chat(M, "<font color = #ff8787><h4>Your mental faculties leave you.</h4></font>")
				to_chat(M, "<font color = #ffc4c4><h5>oblivion... </h5></font>")
				var/mob/living/silicon/pai/P = M
				if(istype(P))
					if(P.resting || P.canmove)
						P.close_up()
				M.death(0, 1)
			removePersonality()
	if(href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		switch(t1)
			if(4)
				radio.ToggleBroadcast()
			if(2)
				radio.ToggleReception()
	if(href_list["setlaws"])
		var/newlaws = sanitize(copytext_char(input("Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", pai.pai_laws) as message,1,MAX_MESSAGE_LEN))
		if(newlaws)
			pai.pai_laws = newlaws
			to_chat(pai, "Your supplemental directives have been updated. Your new directives are:")
			to_chat(pai, "Prime Directive: <br>[pai.pai_law0]")
			to_chat(pai, "Supplemental Directives: <br>[pai.pai_laws]")
	attack_self(usr)

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	pai = personality
	overlays += "pai-happy"

/obj/item/paicard/proc/removePersonality()
	pai = null
	overlays.Cut()
	overlays += "pai-off"

/obj/item/paicard
	var/current_emotion = 1
/obj/item/paicard/proc/setEmotion(var/emotion)
	if(pai)
		overlays.Cut()
		switch(emotion)
			if(1) overlays += "pai-happy"
			if(2) overlays += "pai-cat"
			if(3) overlays += "pai-extremely-happy"
			if(4) overlays += "pai-face"
			if(5) overlays += "pai-laugh"
			if(6) overlays += "pai-off"
			if(7) overlays += "pai-sad"
			if(8) overlays += "pai-angry"
			if(9) overlays += "pai-what"
			if(10) overlays += "pai-spai"
		current_emotion = emotion

/obj/item/paicard/proc/alertUpdate()
	var/turf/T = get_turf_or_move(loc)
	for(var/mob/M in viewers(T))
		M.show_message("<span class='notice'>[src] flashes a message across its screen, \"Additional personalities available for download.\"</span>", 3, "<span class='notice'>[src] bleeps electronically.</span>", 2)

/obj/item/paicard/emp_act(severity)
	for(var/mob/M in src)
		M.emp_act(severity)
	..()

/obj/item/paicard/extinguish_light(force = FALSE)
	if(pai)
		pai.extinguish_light()
		set_light(0)

/obj/item/paicard/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/paicard_upgrade))
		var/obj/item/paicard_upgrade/P = I
		if(pai)
			if(pai.syndipai)
				return
			pai.reset_software()
			pai.ram += P.extra_memory
			pai.syndipai = TRUE
			qdel(P)
			return
		if(upgrade || is_syndicate_type)
			return
		to_chat(user, "<span class='notice'>You install upgrade.</span>")
		upgrade = P
		user.drop_transfer_item_to_loc(P, src)
		extra_memory += P.extra_memory
		is_syndicate_type = TRUE
		return

	if(istype(I, /obj/item/encryptionkey))
		if(!radio)
			return

		if(radio.keyslot1)
			to_chat(user, "The headset can't hold another key!")
			return
		else
			user.drop_transfer_item_to_loc(I, radio)
			radio.keyslot1 = I

		radio.recalculateChannels()
		return

/obj/item/paicard/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE

	if(!I.use_tool(src, user, 0, volume = 0))
		return
	var/turf/T = get_turf(user)

	if(upgrade && !pai)
		extra_memory -= upgrade.extra_memory
		is_syndicate_type = FALSE
		if(T)
			upgrade.forceMove(T)
			upgrade = null
		to_chat(user, span_notice("You remove paicard upgrade."))

	if(radio?.keyslot1)
		for(var/ch_name in radio.channels)
			SSradio.remove_object(radio, SSradio.radiochannels[ch_name])
			radio.secure_radio_connections[ch_name] = null
		if(T)
			radio.keyslot1.forceMove(T)
			radio.keyslot1 = null
		radio.recalculateChannels()
		to_chat(user, span_notice("You pop out the encryption key in the headset!"))
		I.play_tool_sound(user, I.tool_volume)

/obj/item/paicard/attack_ghost(mob/dead/observer/user)
	if(pai)
		return
	if(looking_for_personality)
		GLOB.paiController.recruitWindow(user)
		return
	if(!GLOB.paiController.check_recruit(user))
		to_chat(user, "<span class='warning'>You are not eligible to become a pAI.</span>")
		return
	if(world.time >= next_ping_at)
		next_ping_at = world.time + 20 SECONDS
		playsound(get_turf(src), 'sound/items/posiping.ogg', 80, 0)
		visible_message("<span class='notice'>[src] pings softly.</span>")

/obj/item/paicard_upgrade
	name = "PAI upgrade"
	desc = "A data cartridge for portable AI."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pai-spai"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "programming=2;syndicate=2"
	var/extra_memory = 50
	var/used = TRUE

/obj/item/paicard_upgrade/check_uplink_validity()
	return !used

/obj/item/paicard_upgrade/unused
	used = FALSE

/obj/item/paicard_upgrade/protolate

/obj/item/paper/pai_upgrade
	name = "Инструкция по применению"
	icon_state = "paper"
	info = {"<center> <b>Инструкция по применению СпИИ</b> </center><br>

 <b>В набор СпИИ входит:</b><br>
 1.Картридж СпИИ<br>
 2.Обычная карта для пИИ<br>
 3.Отвертка<br>
 4.Инструкция по применению<br>
 <br>
 <b>Использование:</b><br>
 Вариант №1<br>
 Вставить картридж в пИИ и запросить личность. Нужно подождать пока из базы данных загрузится пИИ. Примерное время ожидания от 30 секунд до 5 минут.<br>
 Вариант №2<br>
 Если у вас уже есть активный пИИ, то вставьте в него картридж. Он получит все обновления и перезагрузку ЦПУ.<br>
 Вариант №3<br>
 Если из базы данных не было предоставлено личности пИИ, то вы можете достать картридж с помощью отвертки, чтобы вернуть потраченные средства.<br>
 <br>
 <b>После обновления ваш пИИ получит дополнительную память, а также возможность установить новые программы:</b><br>
 1.Доступ к видеокамерам станции.<br>
 2.Возможность синтезировать и вводить лечащие реагенты в хозяина.<br>
 3.Возмоность взаимодействия со шлюзами раз в 10 секунд (открытие, болтировка, электризация)<br>
 4.Доступ к продвинутым записям СБ, для выставления и снятия статусов ареста или ввода в манифест.<br>
 5.Термальное зрение для пИИ<br>
"}

/obj/item/paper/pai_upgrade/update_icon()
	return

/obj/item/storage/box/syndie_kit/pai
	name = "Набор ПИИ"

/obj/item/storage/box/syndie_kit/pai/populate_contents()
	new /obj/item/paicard(src)
	new /obj/item/paicard_upgrade/unused(src)
	new /obj/item/screwdriver(src)
	new /obj/item/paper/pai_upgrade(src)
