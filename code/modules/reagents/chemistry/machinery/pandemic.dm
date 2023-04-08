/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	desc = "Used to work with viruses."
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	circuit = /obj/item/circuitboard/pandemic
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = ACID_PROOF
	var/temp_html = ""
	var/printing = null
	var/wait = null
	var/obj/item/reagent_containers/beaker = null

/obj/machinery/computer/pandemic/New()
	..()
	update_icon()

/obj/machinery/computer/pandemic/set_broken()
	icon_state = (beaker ? "mixer1_b" : "mixer0_b")
	overlays.Cut()
	stat |= BROKEN

/obj/machinery/computer/pandemic/proc/GetVirusByIndex(index)
	if(beaker && beaker.reagents)
		if(beaker.reagents.reagent_list.len)
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["viruses"])
					var/list/viruses = BL.data["viruses"]
					return viruses[index]

/obj/machinery/computer/pandemic/proc/GetResistancesByIndex(index)
	if(beaker && beaker.reagents)
		if(beaker.reagents.reagent_list.len)
			var/datum/reagent/blood/BL = locate() in beaker.reagents.reagent_list
			if(BL)
				if(BL.data && BL.data["resistances"])
					var/list/resistances = BL.data["resistances"]
					return resistances[index]

/obj/machinery/computer/pandemic/proc/GetVirusTypeByIndex(index)
	var/datum/disease/D = GetVirusByIndex(index)
	if(D)
		return D.GetDiseaseID()

/obj/machinery/computer/pandemic/proc/replicator_cooldown(waittime)
	wait = 1
	update_icon()
	spawn(waittime)
		wait = null
		update_icon()
		playsound(loc, 'sound/machines/ping.ogg', 30, 1)

/obj/machinery/computer/pandemic/update_icon()
	if(stat & BROKEN)
		icon_state = (beaker ? "mixer1_b" : "mixer0_b")
		return

	icon_state = "mixer[(beaker)?"1":"0"][(powered()) ? "" : "_nopower"]"

	if(wait)
		overlays.Cut()
	else
		overlays += "waitlight"

/obj/machinery/computer/pandemic/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	if(!beaker) return

	if(href_list["create_vaccine"])
		if(!wait)
			var/obj/item/reagent_containers/glass/bottle/B = new/obj/item/reagent_containers/glass/bottle(loc)
			if(B)
				B.pixel_x = rand(-3, 3)
				B.pixel_y = rand(-3, 3)
				var/path = GetResistancesByIndex(text2num(href_list["create_vaccine"]))
				var/vaccine_type = path
				var/vaccine_name = "Unknown"

				if(!ispath(vaccine_type))
					if(GLOB.archive_diseases[path])
						var/datum/disease/D = GLOB.archive_diseases[path]
						if(D)
							vaccine_name = D.name
							vaccine_type = path
				else if(vaccine_type)
					var/datum/disease/D = new vaccine_type
					if(D)
						vaccine_name = D.name

				if(vaccine_type)

					B.name = "[vaccine_name] vaccine bottle"
					B.reagents.add_reagent("vaccine", 15, list(vaccine_type))
					replicator_cooldown(200)
		else
			temp_html = "The replicator is not ready yet."
		updateUsrDialog()
		return
	else if(href_list["create_virus_culture"])
		if(!wait)
			var/type = GetVirusTypeByIndex(text2num(href_list["create_virus_culture"]))//the path is received as string - converting
			var/datum/disease/D = null
			if(!ispath(type))
				D = GetVirusByIndex(text2num(href_list["create_virus_culture"]))
				var/datum/disease/advance/A = GLOB.archive_diseases[D.GetDiseaseID()]
				if(A)
					D = A.Copy()
			else if(type)
				if(type in GLOB.diseases) // Make sure this is a disease
					D = new type()
			if(!D)
				return
			var/name = stripped_input(usr,"Name:","Name the culture",D.name,MAX_NAME_LEN)
			if(name == null || wait)
				return
			var/obj/item/reagent_containers/glass/bottle/B = new/obj/item/reagent_containers/glass/bottle(loc)
			B.icon_state = "round_bottle"
			B.pixel_x = rand(-3, 3)
			B.pixel_y = rand(-3, 3)
			replicator_cooldown(50)
			var/list/data = list("viruses"=list(D))
			B.name = "[name] culture bottle"
			B.desc = "A small bottle. Contains [D.agent] culture in synthblood medium."
			B.reagents.add_reagent("blood",20,data)
			updateUsrDialog()
		else
			temp_html = "The replicator is not ready yet."
		updateUsrDialog()
		return
	else if(href_list["empty_beaker"])
		beaker.reagents.clear_reagents()
		eject_beaker()
		updateUsrDialog()
		return
	else if(href_list["eject"])
		eject_beaker()
		updateUsrDialog()
		return
	else if(href_list["clear"])
		temp_html = ""
		updateUsrDialog()
		return
	else if(href_list["name_disease"])
		var/new_name = stripped_input(usr, "Name the Disease", "New Name", "", MAX_NAME_LEN)
		if(!new_name)
			return
		if(..())
			return
		var/id = GetVirusTypeByIndex(text2num(href_list["name_disease"]))
		if(GLOB.archive_diseases[id])
			var/datum/disease/advance/A = GLOB.archive_diseases[id]
			A.AssignName(new_name)
			for(var/datum/disease/advance/AD in GLOB.active_diseases)
				AD.Refresh()
		updateUsrDialog()
	else if(href_list["print_form"])
		var/datum/disease/D = GetVirusByIndex(text2num(href_list["print_form"]))
		D = GLOB.archive_diseases[D.GetDiseaseID()]//We know it's advanced no need to check
		print_form(D, usr)


	else
		usr << browse(null, "window=pandemic")
		updateUsrDialog()
		return

	add_fingerprint(usr)

/obj/machinery/computer/pandemic/proc/eject_beaker()
	beaker.forceMove(loc)
	beaker = null
	icon_state = "mixer0"

//Prints a nice virus release form. Props to Urbanliner for the layout
/obj/machinery/computer/pandemic/proc/print_form(var/datum/disease/advance/D, mob/living/user)
	D = GLOB.archive_diseases[D.GetDiseaseID()]
	if(!(printing) && D)
		var/reason = input(user,"Укажите причину выпуска", "Указать", null) as message
		reason += "<span class=\"paper_field\"></span>"
		var/english_symptoms = list()
		for(var/I in D.symptoms)
			var/datum/symptom/S = I
			english_symptoms += S.name
		var/symtoms = english_list(english_symptoms)


		var/signature
		if(alert(user,"Вы хотите подписать этот документ?",,"Да","Нет") == "Да")
			signature = "<font face=\"[SIGNFONT]\"><i>[user ? user.real_name : "Аноним"]</i></font>"
		else
			signature = "<span class=\"paper_field\"></span>"

		printing = 1
		var/obj/item/paper/P = new /obj/item/paper(loc)
		visible_message("<span class='notice'>[src] гремит и печатает лист бумаги.</span>")
		playsound(loc, 'sound/goonstation/machines/printer_dotmatrix.ogg', 50, 1)

		P.info = "<U><font size=\"4\"><B><center> Выпуск вируса </B></center></font></U>"
		P.info += "<HR>"
		P.info += "<U>Название вируса:</U> [D.name] <BR>"
		P.info += "<U>Симптомы:</U> [symtoms]<BR>"
		P.info += "<U>Путь передачи:</U> [D.spread_text]<BR>"
		P.info += "<U>Лекарство от вируса:</U> [D.cure_text]<BR>"
		P.info += "<BR>"
		P.info += "<U>Причина выпуска:</U> [reason]"
		P.info += "<HR>"
		P.info += "Вирусолог, ответственный за любые биологические угрозы, возникшие вследствие выпуска вируса.<BR>"
		P.info += "<U>Подпись вирусолога:</U> [signature]<BR>"
		P.info += "Печать ответственного лица, разрешившего выпуск вируса:"
		P.populatefields()
		P.updateinfolinks()
		P.name = "Выпуск вируса «[D.name]»"
		printing = null

/obj/machinery/computer/pandemic/attack_hand(mob/user)
	if(..())
		return
	user.set_machine(src)
	var/dat = {"<meta charset="UTF-8">"}
	if(temp_html)
		dat += "[temp_html]<BR><BR><A href='?src=[UID()];clear=1'>Главное меню</A>"
	else if(!beaker)
		dat += "Пожалуйста, вставьте мензурку.<BR>"
		dat += "<A href='?src=[user.UID()];mach_close=pandemic'>Закрыть</A>"
	else
		var/datum/reagents/R = beaker.reagents
		var/datum/reagent/blood/Blood = null
		for(var/datum/reagent/blood/B in R.reagent_list)
			if(B)
				Blood = B
				break
		if(!R.total_volume||!R.reagent_list.len)
			dat += "Мензурка пуста<BR>"
		else if(!Blood)
			dat += "В мензурке отсутствует образец крови."
		else if(!Blood.data)
			dat += "В мензурке отсутствует данные крови."
		else
			dat += "<h3>Данные образца крови:</h3>"
			dat += "<b>ДНК крови:</b> [(Blood.data["blood_DNA"]||"нет")]<BR>"
			dat += "<b>Тип крови:</b> [(Blood.data["blood_type"]||"нет")]<BR>"
			dat += "<b>Тип расовой крови:</b> [(Blood.data["blood_species"]||"нет")]<BR>"


			if(Blood.data["viruses"])
				var/list/vir = Blood.data["viruses"]
				if(vir.len)
					var/i = 0
					for(var/thing in Blood.data["viruses"])
						var/datum/disease/D = thing
						i++
						if(!(D.visibility_flags & HIDDEN_PANDEMIC))

							if(istype(D, /datum/disease/advance))

								var/datum/disease/advance/A = D
								D = GLOB.archive_diseases[A.GetDiseaseID()]
								if(D)
									if(D.name == "Unknown")
										dat += "<b><a href='?src=[UID()];name_disease=[i]'>Назвать вирус</a></b><BR>"
									else
										dat += "<b><a href='?src=[UID()];print_form=[i]'>Напечатать форму выпуска</a></b><BR>"

							if(!D)
								CRASH("We weren't able to get the advance disease from the archive.")

							dat += "<b>Болезнетворный агент:</b> [D?"[D.agent] — <A href='?src=[UID()];create_virus_culture=[i]'>Создать бутылёк с вирусной культурой</A>":"нет"]<BR>"
							dat += "<b>Общепринятое название:</b> [(D.name||"нет")]<BR>"
							dat += "<b>Описание: </b> [(D.desc||"нет")]<BR>"
							dat += "<b>Путь передачи:</b> [(D.spread_text||"нет")]<BR>"
							dat += "<b>Возможное лекарство:</b> [(D.cure_text||"нет")]<BR><BR>"

							if(istype(D, /datum/disease/advance))
								var/datum/disease/advance/A = D
								dat += "<b>Симптомы:</b> "
								var/english_symptoms = list()
								for(var/datum/symptom/S in A.symptoms)
									english_symptoms += S.name
								dat += english_list(english_symptoms)

						else
							dat += "В образце не обнаружен вирус."
			else
				dat += "В образце не обнаружен вирус."

			dat += "<BR><b>Содержит антитела к:</b> "
			if(Blood.data["resistances"])
				var/list/res = Blood.data["resistances"]
				if(res.len)
					dat += "<ul>"
					var/i = 0
					for(var/type in Blood.data["resistances"])
						i++
						var/disease_name = "Unknown"

						if(!ispath(type))
							var/datum/disease/advance/A = GLOB.archive_diseases[type]
							if(A)
								disease_name = A.name
						else
							var/datum/disease/D = new type()
							disease_name = D.name

						dat += "<li>[disease_name] - <A href='?src=[UID()];create_vaccine=[i]'>Создать бутылёк с вакциной</A></li>"
					dat += "</ul><BR>"
				else
					dat += "ничему<BR>"
			else
				dat += "nothing<BR>"
		dat += "<BR><A href='?src=[UID()];eject=1'>Извлечь мензурку</A>[((R.total_volume&&R.reagent_list.len) ? "-- <A href='?src=[UID()];empty_beaker=1'>Очистить и извлечь мензурку</A>":"")]<BR>"
		dat += "<A href='?src=[user.UID()];mach_close=pandemic'>Закрыть</A>"

	var/datum/browser/popup = new(user, "pandemic", name, 575, 400)
	popup.set_content(dat)
	popup.open(0)
	onclose(user, "pandemic")


/obj/machinery/computer/pandemic/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		power_change()
		return
	if(istype(I, /obj/item/reagent_containers) && (I.container_type & OPENCONTAINER))
		if(stat & (NOPOWER|BROKEN))
			return
		if(beaker)
			to_chat(user, "<span class='warning'>В машину уже вставлена мензурка!</span>")
			return
		if(!user.drop_item())
			return

		beaker =  I
		beaker.loc = src
		to_chat(user, "<span class='notice'>Вы вставили мензурку в машину.</span>")
		updateUsrDialog()
		icon_state = "mixer1"

	else if(istype(I, /obj/item/screwdriver))
		if(beaker)
			beaker.forceMove(get_turf(src))
	else
		return ..()
