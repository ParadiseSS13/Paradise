/**********************************
*******Interactions code by HONKERTRON feat TestUnit********
**Contains a lot ammount of ERP and MEHANOYEBLYA**
***********************************/

/mob/living/carbon/human/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(M == src || src == usr || M != usr)		return
	if(usr.restrained())		return

	var/mob/living/carbon/human/H = usr
	H.partner = src
	make_interaction(machine)

/mob/proc/make_interaction()
	return

//Distant interactions
/mob/living/carbon/human/verb/interact(mob/M as mob)
	set name = "Interact"
	set category = "IC"

	if (istype(M, /mob/living/carbon/human) && usr != M)
		partner = M
		make_interaction(machine)

/datum/species/human
	genitals = 1
	anus = 1

/datum/species/plasmaman
	anus = 1

/datum/species/kidan
	anus = 1

/datum/species/wryn
	anus = 1

/datum/species/unathi
	genitals = 1
	anus = 1

/datum/species/tajaran
	genitals = 1
	anus = 1

/datum/species/vulpkanin
	genitals = 1
	anus = 1

/datum/species/human/skrell
	genitals = 0

/datum/species/monkey
	genitals = 1
	anus = 1

/datum/species/monkey/skrell
	genitals = 0

/datum/species/human/machine
	genitals = 0
	anus = 0 //kiss my metal ass

/datum/species/human/diona
	genitals = 0
	anus = 0

/mob/living/carbon/human/proc/is_nude()
	return (!wear_suit && !w_uniform && underwear == "Nude") ? 1 : 0

/mob/living/carbon/human/make_interaction()
	set_machine(src)

	var/mob/living/carbon/human/H = usr
	var/mob/living/carbon/human/P = H.partner
	var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
	var/hashands = (temp && temp.is_usable())
	if (!hashands)
		temp = H.bodyparts_by_name["l_hand"]
		hashands = (temp && temp.is_usable())
	temp = P.bodyparts_by_name["r_hand"]
	var/hashands_p = (temp && temp.is_usable())
	if (!hashands_p)
		temp = P.bodyparts_by_name["l_hand"]
		hashands = (temp && temp.is_usable())
	var/mouthfree = !((H.head && (H.head.flags & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)))
	var/mouthfree_p = !( (P.head && (P.head.flags & HEADCOVERSMOUTH)) || (P.wear_mask && (P.wear_mask.flags & MASKCOVERSMOUTH)))
	var/haspenis = ((H.gender == MALE && H.potenzia > -1 && H.species.genitals))
	var/haspenis_p = ((P.gender == MALE && P.potenzia > -1  && P.species.genitals))
	var/hasvagina = (H.gender == FEMALE && H.species.genitals && H.species.name != "Unathi" && H.species.name != "Stok")
	var/hasvagina_p = (P.gender == FEMALE && P.species.genitals && P.species.name != "Unathi" && P.species.name != "Stok")
	var/hasanus_p = P.species.anus
	var/isnude = H.is_nude()
	var/isnude_p = P.is_nude()

	H.lastfucked = null
	H.lfhole = ""

	var/dat = "<B><HR><FONT size=3>INTERACTIONS - [H.partner]</FONT></B><BR><HR>"
	var/ya = "&#1103;"

	dat +=  {"• <A href='?src=[UID()];interaction=bow'>Отвесить поклон.</A><BR>"}
	//if (Adjacent(P))
	//	dat +=  {"• <A href='?src=\ref[src];interaction=handshake'>Поприветствовать.</A><BR>"}
	//else
	//	dat +=  {"• <A href='?src=\ref[src];interaction=wave'>Поприветствовать.</A><BR>"}
	if (hashands)
		dat +=  {"<font size=3><B>Руки:</B></font><BR>"}
		if (Adjacent(P))
			dat +=  {"• <A href='?src=[UID()];interaction=handshake'>Пожать руку.</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=hug'>Обнимашки!</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=cheer'>Похлопать по плечу</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=five'>Дать п[ya]ть.</A><BR>"}
			if (hashands_p)
				dat +=  {"• <A href='?src=[UID()];interaction=give'>Передать предмет.</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=slap'><font color=red>Дать пощечину!</font></A><BR>"}
			if (isnude_p)
				if (hasanus_p)
					dat += {"• <A href='?src=[UID()];interaction=assslap'>Шлепнуть по заднице</A><BR>"}
				if (hasvagina_p)
					dat += {"• <A href='?src=[UID()];interaction=fingering'>Просунуть пальчик...</A><BR>"}
			if (P.species.name == "Tajaran")
				dat +=  {"• <A href='?src=[UID()];interaction=pull'><font color=red>Дёрнуть за хвост!</font></A><BR>"}
				if(P.can_inject(H, 1))
					dat +=  {"• <A href='?src=[UID()];interaction=pet'>Погладить.</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=knock'><font color=red>Дать подзатыльник.</font></A><BR>"}
		dat +=  {"• <A href='?src=[UID()];interaction=fuckyou'><font color=red>Показать средний палец.</font></A><BR>"}
		dat +=  {"• <A href='?src=[UID()];interaction=threaten'><font color=red>Погрозить кулаком.</font></A><BR>"}

	if (mouthfree)
		dat += {"<font size=3><B>Лицо:</B></font><BR>"}
		dat += {"• <A href='?src=[UID()];interaction=kiss'>Поцеловать.</A><BR>"}
		if (Adjacent(P))
			if (mouthfree_p)
				if (H.species.name == "Tajaran")
					dat += {"• <A href='?src=[UID()];interaction=lick'>Лизнуть в щеку.</A><BR>"}
			if (isnude_p)
				if (haspenis_p)
					dat += {"• <A href='?src=[UID()];interaction=blowjob'><font color=purple>Сделать минет.</font></A><BR>"}
				if (hasvagina_p)
					dat += {"• <A href='?src=[UID()];interaction=vaglick'><font color=purple>Вылизать.</font></A><BR>"}
				if (hasanus_p)
					dat += {"• <A href='?src=[UID()];interaction=asslick'><font color=purple>Отполировать черный ход?!</font></A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=spit'><font color=red>Плюнуть.</font></A><BR>"}
		dat +=  {"• <A href='?src=[UID()];interaction=tongue'><font color=red>Показать [ya]зык.</font></A><BR>"}

	if (isnude && usr.loc == H.partner.loc)
		if (haspenis && hashands)
			dat += {"<font size=3><B>Член:</B></font><BR>"}
			if (isnude_p)
				if (hasvagina_p)
					dat += {"• <A href='?src=[UID()];interaction=vaginal'><font color=purple>Трахнуть вагинально.</font></A><BR>"}
				if (hasanus_p)
					dat += {"• <A href='?src=[UID()];interaction=anal'><font color=purple>Трахнуть анально.</font></A><BR>"}
				if (mouthfree_p)
					dat += {"• <A href='?src=[UID()];interaction=oral'><font color=purple>Трахнуть орально.</font></A><BR>"}
	if (isnude && usr.loc == H.partner.loc && hashands)
		if (hasvagina && haspenis_p)
			dat += {"<font size=3><B>Лоно:</B></font><BR>"}
			dat += {"• <A href='?src=[UID()];interaction=mount'><font color=purple>Оседлать!</font></A><BR><HR>"}

	var/datum/browser/popup = new(usr, "interactions", "Interactions", 340, 480)
	popup.set_content(dat)
	popup.open()

//INTERACTIONS
/mob/living/carbon/human
	var/mob/living/carbon/human/partner
	var/mob/living/carbon/human/lastfucked
	var/lfhole
	var/potenzia = 10
	var/resistenza = 200
	var/lust = 0
	var/erpcooldown = 0
	var/multiorgasms = 0
	var/lastmoan

mob/living/carbon/human/proc/cum(mob/living/carbon/human/H as mob, mob/living/carbon/human/P as mob, var/hole = "floor")
	var/message = "кончает на пол!"
	var/ya = "&#1103;"
	var/turf/T

	if (H.gender == MALE)
		var/datum/reagent/blood/source = H.get_blood_id()
		if (P)
			T = get_turf(P)
		else
			T = get_turf(H)
		if (H.multiorgasms < H.potenzia)
			var/obj/effect/decal/cleanable/cum/C = new(T)
			// Update cum information.
			C.blood_DNA = list()
			if(source.data["blood_type"])
				C.blood_DNA[source.data["blood_DNA"]] = source.data["blood_type"]
			else
				C.blood_DNA[source.data["blood_DNA"]] = "O+"

		if (H.species.genitals)
			if (hole == "mouth" || H.zone_sel.selecting == "mouth")
				message = pick("кончает [P] в рот.", "целитс[ya] в лицо [P], стрел[ya]ет тугой струёй малафьи, но промахиваетс[ya].", "разбрызгивает сем[ya] на лицо [P].", "кончает на пол.")

			else if (hole == "vagina")
				message = pick("кончает в [P]", "резко выт[ya]гивает член из [P], а затем спускает на пол.", "проникает в [P] последний раз, затем содрагаетс[ya]. Сперма медленно вытекает из щели [P].")

			else if (hole == "anus")
				message = pick("кончает [P] в зад.", "выдергивает член из [P], а затем обильно кончает на [P.gender == MALE ? "его" : "её"] попку.", "выт[ya]гивает член из задницы [P] и сразу же спускает на пол.")

			else if (hole == "floor")
				message = "кончает на пол!"

		else
			message = pick("извиваетс[ya] в приступе оргазма", "прикрывает глаза и мелко дрожит", "содрагаетс[ya], а затем резко расслабл[ya]етс[ya]", "замирает, закатив глаза")

		playsound(loc, "honk/sound/interactions/final_m[rand(1, 5)].ogg", 70, 1, frequency = get_age_pitch())

		H.visible_message("<B>[H] [message]</B>")
		if (istype(P.loc, /obj/structure/closet))
			P.visible_message("<B>[H] [message]</B>")
		H.lust = 5
		H.resistenza += 50

	else
		message = pick("извиваетс[ya] в приступе оргазма", "прикрывает глаза и мелко дрожит", "содрагаетс[ya], а затем резко расслабл[ya]етс[ya]", "замирает, закатив глаза")
		H.visible_message("<B>[H] [message].</B>")
		if (istype(P.loc, /obj/structure/closet))
			P.visible_message("<B>[H] [message].</B>")
		playsound(loc, "honk/sound/interactions/final_f[rand(1, 3)].ogg", 90, 1, frequency = get_age_pitch())
		var/delta = pick(20, 30, 40, 50)
		src.lust -= delta

	H.druggy = 60
	H.multiorgasms += 1
	if (H.multiorgasms == 1)
		add_logs(H, P, "came on")
	H.erpcooldown = rand(200, 450)
	if (H.multiorgasms > H.potenzia / 3)
		if (H.staminaloss < P.potenzia * 4)
			H.staminaloss += H.potenzia
		if (H.staminaloss > 100)
			H.druggy = 300
			H.erpcooldown = 600

mob/living/carbon/human/proc/fuck(mob/living/carbon/human/H as mob, mob/living/carbon/human/P as mob, var/hole)
	var/ya = "&#1103;"
	var/message = ""

	switch(hole)

		if("vaglick")

			message = pick("вылизывает [P].", "отлизывает [P].")
			if (prob(35))
				switch(P.species.name)
					if("Human", "Slime People")
						message = pick("вылизывает [P].", "полирует промежность [P] [ya]зыком.", "отлизывает [P].", "ласкает [P] [ya]зычком.", "погружает свой [ya]зык в [P]", "играетс[ya] с [P] [ya]зычком", "медленно проводит [ya]зыком вдоль промежности [P]")
					if("Tajaran", "Vulpkanin")
						message = pick("вылизывает [P].", "полирует промежность [P] [ya]зыком.", "отлизывает [P].", "ласкает [P] [ya]зычком.", "погружает свой [ya]зык в [P]", "играетс[ya] с [P] [ya]зычком", "медленно проводит [ya]зыком вдоль промежности [P]")

			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "licked")

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [message]</B></font>")
				P.lust += 10
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 10
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)

		if("fingering")

			message = pick("вводит два пальца в вагину [P].", "трахает [P] пальцами.")
			if (prob(35))
				switch(P.species.name)
					if("Human", "Slime People")
						message = pick("вводит два пальца в вагину [P].", "теребит горошину [P].", "тычет пальцами [P].", "ласкает [P] пальчиками.", "нежно поглаживает промежность [P].", "погружает пальцы глубоко в [P], ласка[ya] её изнутри.", "изучает глубины [P].")
					if("Tajaran", "Vulpkanin")
						message = pick("вводит два пальца в пушистую вагину [P].", "теребит горошину [P].", "тычет пальцами [P].", "ласкает [P] пальчиками.", "нежно поглаживает промежность [P].", "погружает пальцы глубоко в [P], ласка[ya] её изнутри.", "изучает глубины [P].")

			if (H.lastfucked != P || H.lfhole != hole)
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "fingered")

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [message]</B></font>")
				P.lust += 8
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 8
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			playsound(loc, "honk/sound/interactions/champ_fingering.ogg", 50, 1, -1)
			H.do_fucking_animation(P)

		if("blowjob")

			switch(H.species.name)
				if("Human", "Skrell", "Grey", "Nucleation", "Plasmaman")
					message = pick("отсасывает [P].", "сосет член [P].", "стимулирует член [P] [ya]зыком.")
					if (prob(35))
						message = pick("целует орган [P], прикрыв глаза от удовольстви[ya].", "постанывает, прикрыв глаза, не вынима[ya] член [P] изо рта.", "ласкает член [P] [ya]зычком, придержива[ya] его рукой.", "облизывает член [P] по всей длине.", "погружает член [P] все глубже себе в рот.", "кончиком [ya]зыка облизывает головку члена [P].", "плюёт на кончик члена [P] и снова берёт его в рот.", "сосёт леденец [P].", "двигает головой взад-вперёд, стимулиру[ya] член [P].", "тщательно вылизывает член [P].", "зажмурившись, полностью заглатывает малыша [P].", "ласкает член [P], помога[ya] себе руками.")
					if (H.lastfucked != P || H.lfhole != hole)
						message = pick("м[ya]гко обхватывает член [P] губами.", "приступает сосать член [P].")
						H.lastfucked = P
						H.lfhole = hole
						add_logs(H, P, "sucked")

				if("Unathi")
					message = pick("облизывает член [P].", "стимулирует орган [P] [ya]зыком.", "трёт член [P] о свой [ya]зык.", "проталкивает член [P] себе в пасть, стара[ya]сь не зацепить его зубами.", "стимулирует член [P] [ya]зыком.")
					if (prob(35))
						message = pick("облизывает орган [P], прикрыв глаза от удовольстви[ya].", "постанывает, прикрыв глаза, не вынима[ya] член [P] из пасти.", "ласкает член [P] [ya]зычком, придержива[ya] его рукой.", "облизывает член [P] по всей длине.", "погружает член [P] все глубже себе в пасть.", "кончиком [ya]зыка облизывает головку члена [P].", "плюёт на кончик члена [P] и проталкивает его себе в глотку.", "облизывает леденец [P].", "двигает головой взад-вперёд, стимулиру[ya] член [P].", "тщательно вылизывает член [P].", "зажмурившись, полностью заглатывает малыша [P].", "ласкает член [P], помога[ya] себе руками.")
					if (H.lastfucked != P || H.lfhole != hole)
						message = pick("кончиком [ya]зыка касаетс[ya] члена [P].", "приступает облизывать член [P].")
						H.lastfucked = P
						H.lfhole = hole
						add_logs(H, P, "sucked")

				if("Tajaran", "Vulpkanin")
					message = pick("вылизывает член [P].", "обводит своим шершавым [ya]зычком вокруг члена [P].", "проталкивает член [P] себе в пасть, стара[ya]сь не зацепить его зубами.", "стимулирует член [P] [ya]зыком.")
					if (prob(35))
						message = pick("вылизывает орган [P], прикрыв глаза от удовольстви[ya].", "постанывает, прикрыв глаза, не вынима[ya] член [P] из пасти.", "ласкает член [P] [ya]зычком, придержива[ya] его лапкой.", "облизывает член [P] по всей длине.", "погружает член [P] все глубже себе в пасть.", "кончиком [ya]зыка облизывает головку члена [P].", "плюёт на кончик члена [P] и проталкивает его себе в глотку.", "вылизывает леденец [P].", "двигает головой взад-вперёд, стимулиру[ya] член [P].", "тщательно вылизывает член [P].", "зажмурившись, полностью заглатывает малыша [P].", "ласкает член [P], помога[ya] себе руками.")
					if (H.lastfucked != P || H.lfhole != hole)
						message = pick("кончиком [ya]зыка касаетс[ya] члена [P].", "приступает вылизывать член [P].")
						H.lastfucked = P
						H.lfhole = hole
						add_logs(H, P, "sucked")

				if("Vox", "Vox Armalis")
					message = pick("облизывает член [P].", "стимулирует орган [P] [ya]зыком.", "трёт член [P] о свой [ya]зык.", "проталкивает член [P] себе в глотку, стара[ya]сь не зацепить его клювом.", "стимулирует член [P] [ya]зыком.")
					if (prob(35))
						message = pick("облизывает орган [P], прикрыв глаза от удовольстви[ya].", "постанывает, прикрыв глаза, не вынима[ya] член [P] из клюва.", "ласкает член [P] [ya]зычком, придержива[ya] его крылом.", "облизывает член [P] по всей длине.", "погружает член [P] все глубже себе в клюв.", "кончиком [ya]зыка облизывает головку члена [P].", "плюёт на кончик члена [P] и проталкивает его себе в глотку.", " облизывает леденец [P].", "двигает головой взад-вперёд, стимулиру[ya] член [P].", "тщательно вылизывает член [P].", "зажмурившись, полностью заглатывает малыша [P].", "ласкает член [P] [ya]зыком.")
					if (H.lastfucked != P || H.lfhole != hole)
						message = pick("кончиком [ya]зыка касаетс[ya] члена [P].", "приступает облизывать член [P].")
						H.lastfucked = P
						H.lfhole = hole
						add_logs(H, P, "sucked")

				if("Slime People")
					message = pick("отсасывает [P].", "сосет член [P].", "стимулирует член [P] [ya]зыком.")
					if (prob(35))
						message = pick("смачно целует орган [P], прикрыв глаза от удовольстви[ya].", "постанывает, прикрыв глаза, не вынима[ya] член [P] изо рта.", "ласкает член [P] [ya]зычком, покрыва[ya] его в[ya]зкой слизью.", "облизывает член [P] по всей длине, оставл[ya][ya] след из слизи.", "погружает член [P] все глубже себе в рот.", "кончиком [ya]зыка облизывает головку члена [P].", "смачивает кончик члена [P] липкой слизью и снова берёт его в рот.", "сосет леденец [P].", "двигает головой взад-вперёд, стимулиру[ya] член [P].", "тщательно вылизывает член [P].", "зажмурившись, полностью заглатывает малыша [P].", "ласкает член [P], помога[ya] себе руками.")
					if (H.lastfucked != P || H.lfhole != hole)
						message = pick("м[ya]гко обхватывает член [P] губами, обволакива[ya] его слизью.", "приступает сосать член [P].")
						H.lastfucked = P
						H.lfhole = hole
						add_logs(H, P, "sucked")

				if("Diona")
					return

				if("Kidan")
					return

				if("Wryn")
					return

				if("Machine")
					return

			if (H.lust < 6)
				H.lust += 6
			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [message]</B></font>")
				P.lust += 10
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += 10
				if (P.lust >= P.resistenza)
					P.cum(P, H, "mouth")
			playsound(loc, "honk/sound/interactions/bj[rand(1, 11)].ogg", 50, 1, -1)
			H.do_fucking_animation(P)
			if (prob(P.potenzia))
				H.oxyloss += 3
				H.visible_message("<B>[H]</B> [pick("давитс[ya] инструментом <B>[P]</B>", "задыхаетс[ya]", "корчитс[ya] в рвотном позыве")].")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("<B>[H]</B> [pick("давитс[ya] инструментом <B>[P]</B>", "задыхаетс[ya]", "корчитс[ya] в рвотном позыве")].")

		if("vaginal")

			message = pick("трахает [P].", "сношает [P].", "долбит [P].")
			if (prob(35))
				switch(P.species.name)
					if("Human")
						message = pick("грубо трахает [P].", "предаётс[ya] страстной любви с [P].", "резким движением погружаетс[ya] внутрь [P].", "движетс[ya] внутри [P].", "двигает тазом, засажива[ya] член в [P].", "стонет, навалива[ya]сь на [P].", "сильно прижимаетс[ya] пахом к [P].", "насаживает [P] на свой член.", "чувственно имеет [P].")
					if("Tajaran", "Vulpkanin")
						message = pick("грубо трахает [P].", "предаётс[ya] страстной любви с [P].", "резким движением погружаетс[ya] внутрь [P].", "движетс[ya] внутри [P].", "двигает тазом, засажива[ya] член в [P].", "стонет, навалива[ya]сь на [P].", "сильно прижимаетс[ya] пахом к [P].", "насаживает [P] на свой член.", "чувственно имеет [P].")
					if("Slime People")
						message = pick("грубо трахает [P].", "предаётс[ya] страстной любви с [P].", "резким движением погружаетс[ya] внутрь [P].", "движетс[ya] внутри [P].", "двигает тазом, засажива[ya] член в [P].", "стонет, навалива[ya]сь на [P].", "сильно прижимаетс[ya] пахом к [P].", "насаживает [P] на свой член.", "чувственно имеет [P].")
						playsound(loc, "honk/sound/interactions/champ[rand(1, 2)].ogg", 50, 1, -1)

			if (H.lastfucked != P || H.lfhole != hole)
				message = pick("всаживает свой член по самые [ya]йца в [P].", "вводит свой орган любви в лоно [P].", "погружает свой корень похоти внутрь [P].", "проникает в [P].")
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "fucked")

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [message]</B></font>")
				P.lust += H.potenzia * 2
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += 10
			if (H.lust >= H.resistenza)
				H.cum(H, P, "vagina")

			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += H.potenzia * 0.5
				if (H.potenzia > 20)
					P.staminaloss += H.potenzia * 0.25
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)
			playsound(loc, "honk/sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)

		if("anal")

			message = pick("долбит [P] в очко.", "анально сношает [P].", "трахает [P] в анус.")
			if (prob(35))
				switch(P.species.name)
					if("Human", "Nucleation")
						message = pick("трахает [P] в задницу.", "всаживает член [P] в анальное кольцо по самые [ya]йца.", "месит глину в шахте [P].", "разрывает [P] очко бешеными фрикциyми.", "запускает своего шахтера в угольные шахты [P].")
					if("Unathi")
						message = pick("трахает [P] в клоаку.", "всаживает член [P] в анальное кольцо по самые [ya]йца.", "месит глину в шахте [P].", "разрывает [P] очко бешеными фрикциyми.", "запускает своего шахтера в угольные шахты [P].")
					if("Tajaran", "Vulpkanin")
						message = pick("трахает [P] под хвост.", "всаживает член [P] в анальное кольцо по самые [ya]йца.", "долбит [P] под пушистый хвостик.", "месит глину в шахте [P].", "разрывает [P] очко бешеными фрикциyми.", "запускает своего шахтера в угольные шахты [P].")
					if("Skrell", "Grey")
						message = pick("трахает [P] в клоаку.", "всаживает член [P] в анальное кольцо по самые [ya]йца.", "месит глину в шахте [P].", "разрывает [P] очко бешеными фрикциyми.", "запускает своего шахтера в угольные шахты [P].")
					if("Slime People")
						message = pick("трахает [P] в задницу.", "всаживает член [P] в анальное кольцо по самые [ya]йца, л[ya]па[ya]сь в в[ya]зкой слизи.", "раcт[ya]гивает [P] очко бешеными фрикциyми.")
						playsound(loc, "honk/sound/interactions/champ[rand(1, 2)].ogg", 50, 1, -1)

			if (H.lastfucked != P || H.lfhole != hole)
				message = pick(" безжалостно прорывает анальное отверстие [P].", "всаживает член [P] в очко.")
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "fucked in anus")

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [message]</B></font>")
				P.lust += H.potenzia * 2
			else
				H.visible_message("<font color=purple>[H] [message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message]</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += 12
			if (H.lust >= H.resistenza)
				H.cum(H, P, "anus")

			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				if (H.potenzia > 13)
					P.lust += H.potenzia * 0.25
					P.staminaloss += H.potenzia * 0.25
				else
					P.lust += H.potenzia * 0.75
				if (P.lust >= P.resistenza)
					P.cum(P, H)
				else
					P.moan()
			H.do_fucking_animation(P)
			playsound(loc, "honk/sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)

		if("oral")

			message = pick(" трахает [P], засажива[ya] свой член [P.gender == FEMALE ? "ей" : "ему"] в глотку.", " орально сношает [P].")
			if (prob(35))
				switch(P.species.name)
					if ("Human", "Skrell", "Grey", "Plasmaman")
						message = pick(" опираетс[ya] на плечи [P], придержива[ya] [P.gender==FEMALE ? "её" : "его"] и засажива[ya] член всё сильнее и сильнее [P.gender==FEMALE ? "ей" : "ему"] в глотку.", " трахает [P] в рот.", " насаживает голову [P] на свой член.", " держит [P] за голову двум[ya] руками и совершает движени[ya] тазом.", " даёт пощёчины [P], продолжа[ya] ебать жертву в рот.", " безжастно пользуетс[ya] глоткой [P].", ", рыча сквозь зубы, нат[ya]гивает глотку [P] на своего малыша.")
					if("Unathi")
						message = pick(" опираетс[ya] на плечи [P], придержива[ya] [P.gender==FEMALE ? "её" : "его"] и засажива[ya] член всё сильнее и сильнее [P.gender==FEMALE ? "ей" : "ему"] в глотку.", " трахает [P] в зубастую пасть.", " насаживает голову [P] на свой член.", " держит [P] за голову двум[ya] руками и совершает движени[ya] тазом.", " даёт пощёчины [P], продолжа[ya] ебать [P.gender == FEMALE ? "бедную [ya]щерку" : "бедного [ya]щера"] в пасть.", " безжастно пользуетс[ya] глоткой [P].", ", рыча сквозь зубы, нат[ya]гивает глотку [P] на своего малыша.")
					if("Tajaran", "Vulpkanin")
						message = pick(" опираетс[ya] на плечи [P], придержива[ya] [P.gender==FEMALE ? "её" : "его"] и засажива[ya] член всё сильнее и сильнее [P.gender==FEMALE ? "ей" : "ему"] в глотку.", " трахает [P] в зубастую пасть.", " насаживает голову [P] на свой член.", " держит [P] за голову двум[ya] руками и совершает движени[ya] тазом.", " даёт пощёчины [P], продолжа[ya] ебать [P.gender == FEMALE ? "бедную кошечку" : "бедного котёнка"] в пасть.", " безжастно пользуетс[ya] глоткой [P].", ", рыча сквозь зубы, нат[ya]гивает глотку [P] на своего малыша.")
					if("Vox", "Vox Armalis")
						message = pick(" опираетс[ya] на плечи [P], придержива[ya] [P.gender==FEMALE ? "её" : "его"] и засажива[ya] член всё сильнее и сильнее [P.gender==FEMALE ? "ей" : "ему"] в глотку.", " трахает [P] пр[ya]мо в клюв.", " насаживает голову [P] на свой член, стара[ya]сь не порезатьс[ya] о выступы на клюве.", " держит [P] за голову двум[ya] руками и совершает движени[ya] тазом.", " сжимает перь[ya] на голове [P], продолжа[ya] ебать бедную птичку в рот.", " безжастно пользуетс[ya] глоткой [P].", ", рыча сквозь зубы, нат[ya]гивает глотку [P] на своего малыша.")
					if("Slime People")
						message = pick(" опираетс[ya] на желеобразные плечи [P], придержива[ya] [P.gender==FEMALE ? "её" : "его"] и засажива[ya] член всё сильнее и сильнее [P.gender==FEMALE ? "ей" : "ему"] в глотку.", " трахает [P] в рот, зал[ya]пыва[ya] свой член в липкой слизи.", " насаживает голову [P] на свой член.", " держит [P] за голову двум[ya] руками и совершает движени[ya] тазом.", " продолжает ебать [P.gender == FEMALE ? "бедную слизнедевку" : "бедного слизн[ya]"] в рот.", " безжастно пользуетс[ya] ротиком [P].", ", черезмерно увлекшись, тыкает членом мимо рта [P] и дрожит от внезапных ощущений.", " нещадно насилует глотку [P].")

			if (H.lastfucked != P || H.lfhole != hole)
				message = pick(" бесцеремонно проталкивает свой член [P] в глотку.")
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "fucked in mouth")

			if (prob(5) && H.stat != DEAD)
				H.visible_message("<font color=purple><B>[H][message]</B></font>")
				H.lust += 15
			else
				H.visible_message("<font color=purple>[H][message]</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H][message]</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += 15
			if (H.lust >= H.resistenza)
				H.cum(H, P, "mouth")

			H.do_fucking_animation(P)
			playsound(loc, "honk/sound/interactions/oral[rand(1, 2)].ogg", 70, 1, -1)
			if (P.species.name == "Slime People")
				playsound(loc, "honk/sound/interactions/champ[rand(1, 2)].ogg", 50, 1, -1)
			if (prob(H.potenzia))
				P.oxyloss += 3
				H.visible_message("<B>[P]</B> [pick("давитс[ya] инструментом <B>[H]</B>", "задыхаетс[ya]", "корчитс[ya] в рвотном позыве")].")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("<B>[P]</B> [pick("давитс[ya] инструментом <B>[H]</B>", "задыхаетс[ya]", "корчитс[ya] в рвотном позыве")].")


		if("mount")

			message = pick("скачет на члене [P]", "прыгает на инструменете [P]", "насаживаетс[ya] на [P]")
			if (prob(35))
				message = pick("седлает тело [P], словно наездница", "скачет на малыше [P]", "прыгает на [P], удар[ya][ya]сь о его гладкую кожу", "радостно подпрыгивает, доставл[ya][ya] удовольствие себе и [P]", "уперлась тазом в [P] и елозит, как егоза", "делает кульбиты на половом органе [P]", "вприпрыжку наваливаетс[ya] на [P], вз[ya]в внутрь его член", "набрасывает своё лоно на крючок [P], дав[ya] на него своим тазом", "впускает внутрь себ[ya] зверька [P]")

			if (H.lastfucked != P || H.lfhole != hole)
				message = pick("осторожно насаживаетс[ya] на половой орган [P]")
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "fucked")

			if (prob(5) && P.stat != DEAD)
				H.visible_message("<font color=purple><B>[H] [message].</B></font>")
				P.lust += H.potenzia * 2
			else
				H.visible_message("<font color=purple>[H] [message].</font>")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<font color=purple>[H] [message].</font>")
				playsound(P.loc.loc, 'sound/effects/clang.ogg', 50, 0, 0)
			H.lust += P.potenzia
			if (P.potenzia > 20)
				H.staminaloss += P.potenzia * 0.25
			if (H.lust >= H.resistenza)
				H.cum(H, P)
			else
				H.moan()
			if (P.stat != DEAD && P.stat != UNCONSCIOUS)
				P.lust += H.potenzia
				if (P.lust >= P.resistenza)
					P.cum(P, H, "vagina")
				else
					P.moan()
			H.do_fucking_animation(P)
			playsound(loc, "honk/sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)
			if (H.species.name == "Slime People")
				playsound(loc, "honk/sound/interactions/champ[rand(1, 2)].ogg", 50, 1, -1)

mob/living/carbon/human/proc/moan()
	var/ya = "&#1103;"
	var/mob/living/carbon/human/H = src
	switch(species.name)
		if ("Human", "Skrell", "Slime People", "Grey", "Nucleation", "Plasmaman")
			if (prob(H.lust / H.resistenza * 65))
				var/message = pick("постанывает", "стонет от удовольстви[ya]", "закатывает глаза", "закусывает губу")
				H.visible_message("<B>[H]</B> [message].")
				var/g = H.gender == FEMALE ? "f" : "m"
				var/moan = rand(1, 7)
				if (moan == lastmoan)
					moan--
				if(!istype(loc, /obj/structure/closet))
					playsound(loc, "honk/sound/interactions/moan_[g][moan].ogg", 70, 1, frequency = get_age_pitch())
				else if (g == "f")
					playsound(loc, "honk/sound/interactions/under_moan_f[rand(1, 4)].ogg", 70, 1, frequency = get_age_pitch())
				lastmoan = moan

				if (istype(H.head, /obj/item/clothing/head/kitty)  || istype(H.head, /obj/item/clothing/head/collectable/kitty))
					playsound(loc, "honk/sound/interactions/purr_f[rand(1, 3)].ogg", 70, 1, 0)

		if("Tajaran")
			if (prob(H.lust / src.resistenza * 70))
				var/message = pick("мурлычет", "мурлычет от удовольстви[ya]", "закатывает глаза", "довольно облизываетс[ya]")
				H.visible_message("<B>[H]</B> [message].")
				playsound(loc, "honk/sound/interactions/purr[rand(1, 3)].ogg", 70, 1, frequency = get_age_pitch())

		if("Vulpkanin")
			if (prob(H.lust / src.resistenza * 70))
				var/message = pick("поскуливает", "поскуливает от удовольстви[ya]", "закатывает глаза", "довольно облизываетс[ya]")
				H.visible_message("<B>[H]</B> [message].")

		if("Unathi")
			if (prob(H.lust / H.resistenza * 70))
				var/message = pick("довольно шипит", "извиваетс[ya] от удовольстви[ya]")
				H.visible_message("<B>[H]</B> [message].")

		if("Kidan", "Wryn")
			if (prob(H.lust / H.resistenza * 70))
				var/message = pick("довольно стрекочет", "извиваетс[ya] от удовольстви[ya]")
				H.visible_message("<B>[H]</B> [message].")


mob/living/carbon/human/proc/handle_lust()
	lust -= 4
	if (lust <= 0)
		lust = 0
		lastfucked = null
		lfhole = ""
		multiorgasms = 0
	if (lust == 0)
		erpcooldown -= 1
	if (erpcooldown < 0)
		erpcooldown = 0

/mob/living/carbon/human/proc/do_fucking_animation(mob/living/carbon/human/P)
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/final_pixel_y = initial(pixel_y)

	var/direction = get_dir(src, P)
	if(direction & NORTH)
		pixel_y_diff = 8
	else if(direction & SOUTH)
		pixel_y_diff = -8

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	if(pixel_x_diff == 0 && pixel_y_diff == 0)
		pixel_x_diff = rand(-3,3)
		pixel_y_diff = rand(-3,3)
		animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
		animate(pixel_x = initial(pixel_x), pixel_y = initial(pixel_y), time = 2)
		return

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = initial(pixel_x), pixel_y = final_pixel_y, time = 2)

/obj/item/weapon/enlarger
	name = "penis enlarger"
	desc = "Very special DNA mixture which helps YOU to enlarge your little captain."
	icon = 'icons/obj/items.dmi'
	icon_state = "dnainjector"
	item_state = "dnainjector"
	hitsound = null
	throwforce = 0
	w_class = 1
	throw_speed = 3
	throw_range = 15
	attack_verb = list("stabbed")

/obj/item/weapon/enlarger/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(istype(M, /mob/living/carbon/human) && (M.gender == MALE))
		M.potenzia = 30
		to_chat(user, "<span class='warning'>Your penis extends!</span>")

	else if (istype(M, /mob/living/carbon/human) && M.gender == FEMALE)
		to_chat(user, "<span class='warning'>It didn't affect you since you're female!</span>")

	..()

	qdel(src)

/obj/item/weapon/enlarger/attack_self(mob/user as mob)
	to_chat(user, "<span class='warning'>You break the syringe. Gooey mass is dripping on the floor.</span>")
	qdel(src)

/obj/item/weapon/dildo
	name = "dildo"
	desc = "Hm-m-m, deal thow"
	icon = 'honk/icons/obj/items/dildo.dmi'
	icon_state = "dildo"
	item_state = "c_tube"
	throwforce = 0
	force = 10
	w_class = 1
	throw_speed = 3
	throw_range = 15
	attack_verb = list("slammed", "bashed", "whipped")
	var/hole = "vagina" //or "anus"
	var/rus_name = "дилдо"
	var/ya = "&#1103;"
	var/pleasure = 10

/obj/item/weapon/dildo/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	var/hasvagina = (M.gender == FEMALE && M.species.genitals && M.species.name != "Unathi" && M.species.name != "Stok")
	var/hasanus = M.species.anus
	var/message = ""

	if(istype(M, /mob/living/carbon/human) && user.zone_sel.selecting == "groin" && M.is_nude())
		if (hole == "vagina" && hasvagina)
			if (user == M)
				message = pick("удовлетвор[ya]ет себ[ya] с помощью [rus_name]", "заталкивает в себ[ya] [rus_name]", "погружает [rus_name] в свое лоно")
			else
				message = pick("удовлетвор[ya]ет [M] с помощью [rus_name]", "заталкивает в [M] [rus_name]", "погружает [rus_name] в лоно [M]")

			if (prob(5) && M.stat != DEAD && M.stat != UNCONSCIOUS)
				user.visible_message("<font color=purple><B>[user] [message].</B></font>")
				M.lust += pleasure * 2

			else if (M.stat != DEAD && M.stat != UNCONSCIOUS)
				user.visible_message("<font color=purple>[user] [message].</font>")
				M.lust += pleasure

			if (M.lust >= M.resistenza)
				M.cum(M, user, "floor")
			else
				M.moan()

			user.do_fucking_animation(M)
			playsound(loc, "honk/sound/interactions/bang[rand(4, 6)].ogg", 70, 1, -1)

		else if (hole == "anus" && hasanus)
			if (user == M)
				message = pick("удовлетвор[ya]ет себ[ya] анально с помощью [rus_name]", "заталкивает [rus_name] себе в анус", "чистит свой дымоход, использу[ya] [rus_name]")
			else
				message = pick("удовлетвор[ya]ет [M] анально с помощью [rus_name]", "заталкивает [rus_name] [M] в анус", "чистит дымоход [M], использу[ya] [rus_name]")

			if (prob(5) && M.stat != DEAD && M.stat != UNCONSCIOUS)
				user.visible_message("<font color=purple><B>[user] [message].</B></font>")
				M.lust += pleasure * 2

			else if (M.stat != DEAD && M.stat != UNCONSCIOUS)
				user.visible_message("<font color=purple>[user] [message].</font>")
				M.lust += pleasure

			if (M.lust >= M.resistenza)
				M.cum(M, user, "floor")
			else
				M.moan()

			user.do_fucking_animation(M)
			playsound(loc, "honk/sound/interactions/bang[rand(4, 6)].ogg", 70, 1, -1)

		else
			..()
	else
		..()

/obj/item/weapon/dildo/attack_self(mob/user as mob)
	if(hole == "vagina")
		hole = "anus"
	else
		hole = "vagina"
	to_chat(user, "<span class='warning'>Hm-m-m. Maybe we should put it in [hole]?!</span>")