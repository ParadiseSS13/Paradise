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

/datum/species/xenos
	genitals = 0
	anus = 1

/datum/species/human
	genitals = 1
	anus = 1

/datum/species/unathi
	genitals = 1
	anus = 1

/datum/species/tajaran
	genitals = 1
	anus = 1

/datum/species/human/skrell
	genitals = 0

/datum/species/monkey
	genitals = 1
	anus = 1

/datum/species/monkey/skrell
	genitals = 0

/mob/living/carbon/human/make_interaction()
	set_machine(src)

	var/mob/living/carbon/human/H = usr
	var/mob/living/carbon/human/P = H.partner
	var/obj/item/organ/external/temp = H.organs_by_name["r_hand"]
	var/hashands = (temp && temp.is_usable())
	if (!hashands)
		temp = H.organs_by_name["l_hand"]
		hashands = (temp && temp.is_usable())
	temp = P.organs_by_name["r_hand"]
	var/hashands_p = (temp && temp.is_usable())
	if (!hashands_p)
		temp = P.organs_by_name["l_hand"]
		hashands = (temp && temp.is_usable())
	var/mouthfree = !((H.head && (H.head.flags & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags & MASKCOVERSMOUTH)))
	var/mouthfree_p = !( (P.head && (P.head.flags & HEADCOVERSMOUTH)) || (P.wear_mask && (P.wear_mask.flags & MASKCOVERSMOUTH)))
	var/haspenis = (H.gender == MALE && H.potenzia > -1 && H.species.genitals)
	var/haspenis_p = (P.gender == MALE && H.potenzia > -1  && P.species.genitals)
	var/hasvagina = (H.gender == FEMALE && H.species.genitals && H.species.name != "Unathi" && H.species.name != "Stok")
	var/hasvagina_p = (P.gender == FEMALE && P.species.genitals && P.species.name != "Unathi" && P.species.name != "Stok")
	var/hasanus_p = P.species.anus
	var/isnude = ( !H.wear_suit && !H.w_uniform && H.underwear == "Nude")
	var/isnude_p = ( !P.wear_suit && !P.w_uniform && P.underwear == "Nude")

	H.lastfucked = null
	H.lfhole = ""

	var/dat = "<B><HR><FONT size=3>INTERACTIONS - [H.partner]</FONT></B><BR><HR>"
	var/ya = "&#1103;"

	dat +=  {"� <A href='?src=\ref[usr];interaction=bow'>�������� ������.</A><BR>"}
	//if (Adjacent(P))
	//	dat +=  {"� <A href='?src=\ref[src];interaction=handshake'>����������������.</A><BR>"}
	//else
	//	dat +=  {"� <A href='?src=\ref[src];interaction=wave'>����������������.</A><BR>"}
	if (hashands)
		dat +=  {"<font size=3><B>����:</B></font><BR>"}
		if (Adjacent(P))
			dat +=  {"� <A href='?src=\ref[usr];interaction=hug'>���������!</A><BR>"}
			dat +=  {"� <A href='?src=\ref[usr];interaction=cheer'>��������� �� �����</A><BR>"}
			dat +=  {"� <A href='?src=\ref[usr];interaction=five'>���� �[ya]��.</A><BR>"}
			if (hashands_p)
				dat +=  {"� <A href='?src=\ref[src];interaction=give'>�������� �������.</A><BR>"}
			dat +=  {"� <A href='?src=\ref[usr];interaction=slap'><font color=red>���� ��������!</font></A><BR>"}
			if (isnude_p)
				if (hasanus_p)
					dat += {"� <A href='?src=\ref[usr];interaction=assslap'>�������� �� �������</A><BR>"}
				if (hasvagina_p)
					dat += {"� <A href='?src=\ref[usr];interaction=fingering'>��������� �������...</A><BR>"}
			if (P.species.name == "Tajara")
				dat +=  {"� <A href='?src=\ref[usr];interaction=pull'><font color=red>ĸ����� �� �����!</font></A><BR>"}
				if(P.can_inject(H, 1))
					dat +=  {"� <A href='?src=\ref[usr];interaction=pet'>���������.</A><BR>"}
			dat +=  {"� <A href='?src=\ref[usr];interaction=knock'><font color=red>���� ������������.</font></A><BR>"}
		dat +=  {"� <A href='?src=\ref[usr];interaction=fuckyou'><font color=red>�������� ������� �����.</font></A><BR>"}
		dat +=  {"� <A href='?src=\ref[usr];interaction=threaten'><font color=red>��������� �������.</font></A><BR>"}

	if (mouthfree)
		dat += {"<font size=3><B>����:</B></font><BR>"}
		dat += {"� <A href='?src=\ref[usr];interaction=kiss'>����������.</A><BR>"}
		if (Adjacent(P))
			if (mouthfree_p)
				if (H.species.name == "Tajara")
					dat += {"� <A href='?src=\ref[usr];interaction=lick'>������� � ����.</A><BR>"}
			if (isnude_p)
				if (haspenis_p)
					dat += {"� <A href='?src=\ref[usr];interaction=blowjob'><font color=purple>������� �����.</font></A><BR>"}
				if (hasvagina_p)
					dat += {"� <A href='?src=\ref[usr];interaction=vaglick'><font color=purple>��������.</font></A><BR>"}
				if (hasanus_p)
					dat += {"� <A href='?src=\ref[usr];interaction=asslick'><font color=purple>������������ ������ ���?!</font></A><BR>"}
			dat +=  {"� <A href='?src=\ref[usr];interaction=spit'><font color=red>�������.</font></A><BR>"}
		dat +=  {"� <A href='?src=\ref[usr];interaction=tongue'><font color=red>�������� [ya]���.</font></A><BR>"}

	if (isnude && usr.loc == H.partner.loc)
		if (haspenis && hashands)
			dat += {"<font size=3><B>����:</B></font><BR>"}
			if (isnude_p)
				if (hasvagina_p)
					dat += {"� <A href='?src=\ref[usr];interaction=vaginal'><font color=purple>�������� ����������.</font></A><BR>"}
				if (hasanus_p)
					dat += {"� <A href='?src=\ref[usr];interaction=anal'><font color=purple>�������� �������.</font></A><BR>"}
				if (mouthfree_p)
					dat += {"� <A href='?src=\ref[usr];interaction=oral'><font color=purple>�������� �������.</font></A><BR>"}
	if (isnude && usr.loc == H.partner.loc && hashands)
		if (hasvagina && haspenis_p)
			dat += {"<font size=3><B>����:</B></font><BR>"}
			dat += {"� <A href='?src=\ref[usr];interaction=mount'><font color=purple>��������!</font></A><BR><HR>"}

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
	var/lastmoan = 0
	var/lastfinal = 0

mob/living/carbon/human/proc/cum(mob/living/carbon/human/H as mob, mob/living/carbon/human/P as mob, var/hole)
	var/message = "������� �� ���!"
	var/ya = "&#255;"
	var/turf/T

	if (istype(H.species, /datum/species/xenos))
		message = pick("���������[ya] � �������� �������", "����������[ya], � ����� ����� ��������[ya]���[ya]")
		src.visible_message("<B>[src] [message].</B>")
		if (multiorgasms == 0)
			playsound(loc, "sound/voice/hiss6.ogg", 50, 0, -1)
	else if (H.gender == MALE)
		var/datum/reagent/blood/source = H.get_blood(H.vessel)
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
				message = pick("������� [P] � ���.", "������[ya] � ���� [P], �����[ya]�� ����� ����� �������, �� ������������[ya].", "������������� ���[ya] �� ���� [P].", "������� �� ���.")
				playsound(loc, "sound/interactions/final_m[rand(1, 2)].ogg", 50, 1, -1)
			else if (hole == "vagina")
				message = pick("������� � [P]", "����� ���[ya]������ ���� �� [P], � ����� �������� �� ���.", "��������� � [P] ��������� ���, ����� ����������[ya]. ������ �������� �������� �� ���� [P].")
				playsound(loc, "sound/interactions/final_m[rand(1, 2)].ogg", 50, 1, -1)
			else if (hole == "anus")
				message = pick("������� [P] � ���.", "����������� ���� �� [P], � ����� ������� ������� �� [P.gender == MALE ? "���" : "�"] �����.", "���[ya]������ ���� �� ������� [P] � ����� �� �������� �� ���.")
				playsound(loc, "sound/interactions/final_m[rand(1, 2)].ogg", 50, 1, -1)
			else
				playsound(loc, "sound/interactions/final_m[rand(3, 6)].ogg", 50, 1, -1)
		else
			message = pick("���������[ya] � �������� �������", "���������� ����� � ����� ������", "����������[ya], � ����� ����� ��������[ya]���[ya]", "��������, ������� �����")
			playsound(loc, "sound/interactions/final_m[rand(3, 6)].ogg", 50, 1, -1)

		H.visible_message("<B>[H] [message]</B>")
		if (istype(P.loc, /obj/structure/closet))
			P.visible_message("<B>[H] [message]</B>")
		H.lust = 5
		H.resistenza += 50

	else
		message = pick("���������[ya] � �������� �������", "���������� ����� � ����� ������", "����������[ya], � ����� ����� ��������[ya]���[ya]", "��������, ������� �����")
		H.visible_message("<B>[H] [message].</B>")
		if (istype(P.loc, /obj/structure/closet))
			P.visible_message("<B>[H] [message].</B>")
		var/final = rand(1, 3)
		if (final == lastfinal)
			final = ((final+1) % 3) + 1
		playsound(loc, "sound/interactions/final_f[final].ogg", 50, 1, -1)
		lastfinal = final
		var/delta = pick(20, 30, 40, 50)
		src.lust -= delta

	H.druggy = 60
	H.multiorgasms += 1
	if (H.multiorgasms == 1)
		add_logs(H, P, "Came", "Became a target of a cumshot", "is cumming on")
	H.erpcooldown = rand(200, 450)
	/*if (H.multiorgasms > H.potenzia / 3)
		if (H.halloss < P.potenzia * 4)
			H.halloss += H.potenzia
		if (H.halloss > 100)
			H.druggy = 300
			H.erpcooldown = 600*/

mob/living/carbon/human/proc/fuck(mob/living/carbon/human/H as mob, mob/living/carbon/human/P as mob, var/hole)
	var/ya = "&#255;"
	var/message = ""

	if (hole == "vaglick")

		message = pick("���������� [P].", "���������� [P].")
		if (prob(35))
			if (P.species.name == "Human")
				message = pick("���������� [P].", "�������� ����������� [P] [ya]�����.", "���������� [P].", "������� [P] [ya]������.", "��������� ���� [ya]��� � [P]", "�������[ya] � [P] [ya]������", "�������� �������� [ya]����� ����� ����������� [P]")
			if (P.species.name == "Tajara")
				message = pick("���������� [P].", "�������� ����������� [P] [ya]�����.", "���������� [P].", "������� [P] [ya]������.", "��������� ���� [ya]��� � [P]", "�������[ya] � [P] [ya]������", "�������� �������� [ya]����� ����� ����������� [P]")

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

	else if (hole == "fingering")

		message = pick("������ ��� ������ � ������ [P].", "������� [P] ��������.")
		if (prob(35))
			if (P.species.name == "Human")
				message = pick("������ ��� ������ � ������ [P].", "������� �������� [P].", "����� �������� [P].", "������� [P] ����������.", "����� ����������� ����������� [P].", "��������� ������ ������� � [P], �����[ya] � �������.", "������� ������� [P].")
			else if (P.species.name == "Tajara")
				message = pick("������ ��� ������ � �������� ������ [P].", "������� �������� [P].", "����� �������� [P].", "������� [P] ����������.", "����� ����������� ����������� [P].", "��������� ������ ������� � [P], �����[ya] � �������.", "������� ������� [P].")

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
		playsound(loc, "sound/interactions/champ_fingering.ogg", 50, 1, -1)

	else if (hole == "blowjob")

		if (H.species.name == "Human" || H.species.name == "Skrell" || H.species.name == "Arachna")
			message = pick("���������� [P].", "����� ���� [P].", "����������� ���� [P] [ya]�����.")
			if (prob(35))
				message = pick("������ ����� [P], ������� ����� �� �����������[ya].", "�����������, ������� �����, �� ������[ya] ���� [P] ��� ���.", "������� ���� [P] [ya]������, ����������[ya] ��� �����.", "���������� ���� [P] �� ���� �����.", "��������� ���� [P] ��� ������ ���� � ���.", "�������� [ya]���� ���������� ������� ����� [P].", "����� �� ������ ����� [P] � ����� ���� ��� � ���.", "���� ������� [P].", "������� ������� ����-�����, ���������[ya] ���� [P].", "��������� ���������� ���� [P].", "������������, ��������� ����������� ������ [P].", "������� ���� [P], ������[ya] ���� ������.")
			if (H.lastfucked != P || H.lfhole != hole)
				message = pick("�[ya]��� ����������� ���� [P] ������.", "���������� ������ ���� [P].")
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "sucked")

		else if (H.species.name == "Unathi")
			message = pick("���������� ���� [P].", "����������� ����� [P] [ya]�����.", "��� ���� [P] � ���� [ya]���.", "������������ ���� [P] ���� � �����, �����[ya]�� �� �������� ��� ������.", "����������� ���� [P] [ya]�����.")
			if (prob(35))
				message = pick("���������� ����� [P], ������� ����� �� �����������[ya].", "�����������, ������� �����, �� ������[ya] ���� [P] �� �����.", "������� ���� [P] [ya]������, ����������[ya] ��� �����.", "���������� ���� [P] �� ���� �����.", "��������� ���� [P] ��� ������ ���� � �����.", "�������� [ya]���� ���������� ������� ����� [P].", "����� �� ������ ����� [P] � ������������ ��� ���� � ������.", "���������� ������� [P].", "������� ������� ����-�����, ���������[ya] ���� [P].", "��������� ���������� ���� [P].", "������������, ��������� ����������� ������ [P].", "������� ���� [P], ������[ya] ���� ������.")
			if (H.lastfucked != P || H.lfhole != hole)
				message = pick("�������� [ya]���� �������[ya] ����� [P].", "���������� ���������� ���� [P].")
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "sucked")

		else if (H.species.name == "Tajara")
			message = pick("���������� ���� [P].", "������� ����� �������� [ya]������ ������ ����� [P].", "������������ ���� [P] ���� � �����, �����[ya]�� �� �������� ��� ������.", "����������� ���� [P] [ya]�����.")
			if (prob(35))
				message = pick("���������� ����� [P], ������� ����� �� �����������[ya].", "�����������, ������� �����, �� ������[ya] ���� [P] �� �����.", "������� ���� [P] [ya]������, ����������[ya] ��� ������.", "���������� ���� [P] �� ���� �����.", "��������� ���� [P] ��� ������ ���� � �����.", "�������� [ya]���� ���������� ������� ����� [P].", "����� �� ������ ����� [P] � ������������ ��� ���� � ������.", "���������� ������� [P].", "������� ������� ����-�����, ���������[ya] ���� [P].", "��������� ���������� ���� [P].", "������������, ��������� ����������� ������ [P].", "������� ���� [P], ������[ya] ���� ������.")
			if (H.lastfucked != P || H.lfhole != hole)
				message = pick("�������� [ya]���� �������[ya] ����� [P].", "���������� ���������� ���� [P].")
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "sucked")

		else if (H.species.name == "Vox")
			message = pick("���������� ���� [P].", "����������� ����� [P] [ya]�����.", "��� ���� [P] � ���� [ya]���.", "������������ ���� [P] ���� � ������, �����[ya]�� �� �������� ��� ������.", "����������� ���� [P] [ya]�����.")
			if (prob(35))
				message = pick("���������� ����� [P], ������� ����� �� �����������[ya].", "�����������, ������� �����, �� ������[ya] ���� [P] �� �����.", "������� ���� [P] [ya]������, ����������[ya] ��� ������.", "���������� ���� [P] �� ���� �����.", "��������� ���� [P] ��� ������ ���� � ����.", "�������� [ya]���� ���������� ������� ����� [P].", "����� �� ������ ����� [P] � ������������ ��� ���� � ������.", " ���������� ������� [P].", "������� ������� ����-�����, ���������[ya] ���� [P].", "��������� ���������� ���� [P].", "������������, ��������� ����������� ������ [P].", "������� ���� [P] [ya]�����.")
			if (H.lastfucked != P || H.lfhole != hole)
				message = pick("�������� [ya]���� �������[ya] ����� [P].", "���������� ���������� ���� [P].")
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "sucked")

		else if (istype(H.species, /datum/species/xenos))
			message = pick("���������� ���� [P].", "����������� ����� [P] [ya]�����.", "��� ���� [P] � ���� [ya]���.")
			if (prob(35))
				message = pick("���������� ����� [P]", "�����������, ������� �����, �� ������[ya] ���� [P] �� ������ ����� ����� �������.", "������� ���� [P] [ya]������, ����������[ya] ��� ��������� ������.", "���������� ���� [P] �� ���� �����.", "��������� ���� [P] ��� ������ ���� � ����� �������.", "�������� [ya]���� ���������� ������� ����� [P].", "����� �� ������ ����� [P] � ����� ���� ��� � ����� �������.", " ���������� ������� [P].", "������� ������������ ������� ����-�����, ���������[ya] ���� [P].", "��������� ���������� ���� [P].", "��������� ����������� ������ [P].")
			if (H.lastfucked != P || H.lfhole != hole)
				message = pick("�������� [ya]���� �������[ya] ����� [P].", "���������� ���������� ���� [P].")
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "sucked")

		else if (H.species.name == "Slime")
			message = pick("���������� [P].", "����� ���� [P].", "����������� ���� [P] [ya]�����.")
			if (prob(35))
				message = pick("������ ������ ����� [P], ������� ����� �� �����������[ya].", "�����������, ������� �����, �� ������[ya] ���� [P] ��� ���.", "������� ���� [P] [ya]������, �������[ya] ��� �[ya]���� ������.", "���������� ���� [P] �� ���� �����, ������[ya][ya] ���� �� �����.", "��������� ���� [P] ��� ������ ���� � ���.", "�������� [ya]���� ���������� ������� ����� [P].", "��������� ������ ����� [P] ������ ������ � ����� ���� ��� � ���.", "����� ������� [P].", "������� ������� ����-�����, ���������[ya] ���� [P].", "��������� ���������� ���� [P].", "������������, ��������� ����������� ������ [P].", "������� ���� [P], ������[ya] ���� ������.")
			if (H.lastfucked != P || H.lfhole != hole)
				message = pick("�[ya]��� ����������� ���� [P] ������, ����������[ya] ��� ������.", "���������� ������ ���� [P].")
				H.lastfucked = P
				H.lfhole = hole
				add_logs(H, P, "sucked")

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
		playsound(loc, "sound/interactions/bj[rand(1, 11)].ogg", 50, 1, -1)

		if (prob(P.potenzia))
			H.oxyloss += 3
			H.visible_message("<B>[H]</B> [pick("������[ya] ������������ <B>[P]</B>", "���������[ya]", "�������[ya] � ������� ������")].")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<B>[H]</B> [pick("������[ya] ������������ <B>[P]</B>", "���������[ya]", "�������[ya] � ������� ������")].")

	else if (hole == "vaginal")

		message = pick("������� [P].", "������� [P].", "������ [P].")
		if (prob(35))
			if (P.species.name == "Human")
				//adverb = pick(" [ya]������", " ��������", " �����", ", �[ya]���� ����,", ", ��� ����� �����,")
				message = pick("����� ������� [P].", "�������[ya] ��������� ����� � [P].", "������ ��������� ����������[ya] ������ [P].", "�������[ya] ������ [P].", "������� �����, ��������[ya] ���� � [P].", "������, ��������[ya]�� �� [P].", "������ ����������[ya] ����� � [P].", "���������� [P] �� ���� ����.", "���������� ����� [P].")
			else if (P.species.name == "Tajara")
				message = pick("����� ������� [P].", "�������[ya] ��������� ����� � [P].", "������ ��������� ����������[ya] ������ [P].", "�������[ya] ������ [P].", "������� �����, ��������[ya] ���� � [P].", "������, ��������[ya]�� �� [P].", "������ ����������[ya] ����� � [P].", "���������� [P] �� ���� ����.", "���������� ����� [P].")
			else if (P.species.name == "Slime")
				message = pick("����� ������� [P].", "�������[ya] ��������� ����� � [P].", "������ ��������� ����������[ya] ������ [P].", "�������[ya] ������ [P].", "������� �����, ��������[ya] ���� � [P].", "������, ��������[ya]�� �� [P].", "������ ����������[ya] ����� � [P].", "���������� [P] �� ���� ����.", "���������� ����� [P].")

		if (H.lastfucked != P || H.lfhole != hole)
			message = pick("��������� ���� ���� �� ����� [ya]��� � [P].", "������ ���� ����� ����� � ���� [P].", "��������� ���� ������ ������ ������ [P].", "��������� � [P].")
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
		H.moan()
		if (P.stat != DEAD && P.stat != UNCONSCIOUS)
			P.lust += H.potenzia
			if (P.lust >= P.resistenza)
				P.cum(P, H)
			else
				P.moan()
		playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)
		if (P.species.name == "Slime")
			playsound(loc, "sound/interactions/champ[rand(1, 2)].ogg", 50, 1, -1)

	else if (hole == "anal")

		message = pick("������ [P] � ����.", "������� ������� [P].", "������� [P] � ����.")
		if (prob(35))
			if (P.species.name == "Human")
				message = pick("������� [P] � �������.", "��������� ���� [P] � �������� ������ �� ����� [ya]���.", "����� ����� � ����� [P].", "��������� [P] ���� �������� ������y��.", "��������� ������ ������� � �������� ����� [P].")
			else if (P.species.name == "Unathi")
				message = pick("������� [P] � ������.", "��������� ���� [P] � �������� ������ �� ����� [ya]���.", "����� ����� � ����� [P].", "��������� [P] ���� �������� ������y��.", "��������� ������ ������� � �������� ����� [P].")
			else if (P.species.name == "Tajara")
				message = pick("������� [P] ��� �����.", "��������� ���� [P] � �������� ������ �� ����� [ya]���.", "������ [P] ��� �������� �������.", "����� ����� � ����� [P].", "��������� [P] ���� �������� ������y��.", "��������� ������ ������� � �������� ����� [P].")
			else if (P.species.name == "Skrell")
				message = pick("������� [P] � ������.", "��������� ���� [P] � �������� ������ �� ����� [ya]���.", "����� ����� � ����� [P].", "��������� [P] ���� �������� ������y��.", "��������� ������ ������� � �������� ����� [P].")
			else if (istype(H.species, /datum/species/xenos))
				message = pick("������� [P] � �������� ������.", "��������� ���� [P] � �������� ������ �� ����� [ya]���.", "����� ����� � ����� [P].", "��������� [P] ���� �������� ������y��.", "��������� ������ ������� � �������� ����� [P].")
			if (P.species.name == "Slime")
				message = pick("������� [P] � �������.", "��������� ���� [P] � �������� ������ �� ����� [ya]���, �[ya]��[ya]�� � �[ya]���� �����.", "��������� [P] ���� �������� ������y��.")

		if (H.lastfucked != P || H.lfhole != hole)
			message = pick(" ����������� ��������� �������� ��������� [P].", "��������� ���� [P] � ����.")
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
		H.moan()
		if (P.stat != DEAD && P.stat != UNCONSCIOUS)
			P.lust += H.potenzia * 0.5
			if (P.lust >= P.resistenza)
				P.cum(P, H)
			else
				P.moan()
		playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)
		if (P.species.name == "Slime")
			playsound(loc, "sound/interactions/champ[rand(1, 2)].ogg", 50, 1, -1)

	else if (hole == "oral")

		message = pick(" ������� [P], ��������[ya] ���� ���� [P.gender == FEMALE ? "��" : "���"] � ������.", " ������� ������� [P].")
		if (prob(35))
			if (P.species.name == "Human")
				message = pick(" ��������[ya] �� ����� [P], ����������[ya] [P.gender==FEMALE ? "�" : "���"] � ��������[ya] ���� �� ������� � ������� [P.gender==FEMALE ? "��" : "���"] � ������.", " ������� [P] � ���.", " ���������� ������ [P] �� ���� ����.", " ������ [P] �� ������ ����[ya] ������ � ��������� �������[ya] �����.", " ��� �������� [P], ��������[ya] ����� ������ � ���.", " ��������� ���������[ya] ������� [P].", ", ���� ������ ����, ���[ya]������ ������ [P] �� ������ ������.")
			else if (P.species.name == "Unathi")
				message = pick(" ��������[ya] �� ����� [P], ����������[ya] [P.gender==FEMALE ? "�" : "���"] � ��������[ya] ���� �� ������� � ������� [P.gender==FEMALE ? "��" : "���"] � ������.", " ������� [P] � �������� �����.", " ���������� ������ [P] �� ���� ����.", " ������ [P] �� ������ ����[ya] ������ � ��������� �������[ya] �����.", " ��� �������� [P], ��������[ya] ����� [P.gender == FEMALE ? "������ [ya]�����" : "������� [ya]����"] � �����.", " ��������� ���������[ya] ������� [P].", ", ���� ������ ����, ���[ya]������ ������ [P] �� ������ ������.")
			else if (P.species.name == "Tajara")
				message = pick(" ��������[ya] �� ����� [P], ����������[ya] [P.gender==FEMALE ? "�" : "���"] � ��������[ya] ���� �� ������� � ������� [P.gender==FEMALE ? "��" : "���"] � ������.", " ������� [P] � �������� �����.", " ���������� ������ [P] �� ���� ����.", " ������ [P] �� ������ ����[ya] ������ � ��������� �������[ya] �����.", " ��� �������� [P], ��������[ya] ����� [P.gender == FEMALE ? "������ �������" : "������� ������"] � �����.", " ��������� ���������[ya] ������� [P].", ", ���� ������ ����, ���[ya]������ ������ [P] �� ������ ������.")
			else if (P.species.name == "Skrell")
				message = pick(" ��������[ya] �� ����� [P], ����������[ya] [P.gender==FEMALE ? "�" : "���"] � ��������[ya] ���� �� ������� � ������� [P.gender==FEMALE ? "��" : "���"] � ������.", " ������� [P] � ���.", " ���������� ������ [P] �� ���� ����.", " ������ [P] �� ������ ����[ya] ������ � ��������� �������[ya] �����.", " ��� �������� [P], ��������[ya] ����� ������ � ���.", " ��������� ���������[ya] ������� [P].", ", ���� ������ ����, ���[ya]������ ������ [P] �� ������ ������.")
			else if (P.species.name == "Vox")
				message = pick(" ��������[ya] �� ����� [P], ����������[ya] [P.gender==FEMALE ? "�" : "���"] � ��������[ya] ���� �� ������� � ������� [P.gender==FEMALE ? "��" : "���"] � ������.", " ������� [P] ��[ya]�� � ����.", " ���������� ������ [P] �� ���� ����, �����[ya]�� �� ���������[ya] � ������� �� �����.", " ������ [P] �� ������ ����[ya] ������ � ��������� �������[ya] �����.", " ������� ����[ya] �� ������ [P], ��������[ya] ����� ������ ������ � ���.", " ��������� ���������[ya] ������� [P].", ", ���� ������ ����, ���[ya]������ ������ [P] �� ������ ������.")
			else if (istype(H.species, /datum/species/xenos))
				message = pick(" ��������[ya] �� ����� [P], ����������[ya] � � ��������[ya] ���� �� ������� � ������� � � ���������� �������.", " ������� [P] � ����� �������.", " ���������� ������ [P] �� ���� ����.", " ������ [P] �� ������������ ������ ����[ya] ������ � ��������� �������[ya] �����.", " ��������� ���������[ya] ������� [P].", ", ���� ������ ����, ���[ya]������ ������ [P] �� ������ ������.")
			else if (P.species.name == "Arachna")
				message = pick(" ��������[ya] �� ����� [P], ����������[ya] ������� � ��������[ya] ���� �� ������� � ������� �� � ������.", " ������� [P] � ���.", " ���������� ������ [P] �� ���� ����.", " ������ [P] �� ������ ����[ya] ������ � ��������� �������[ya] �����.", " ��� �������� [P], ��������[ya] ����� ������� � ���.", " ��������� ���������[ya] ������� [P].", ", ���� ������ ����, ���[ya]������ ������ [P] �� ������ ������.")
			else if (P.species.name == "Slime")
				message = pick(" ��������[ya] �� ������������ ����� [P], ����������[ya] [P.gender==FEMALE ? "�" : "���"] � ��������[ya] ���� �� ������� � ������� [P.gender==FEMALE ? "��" : "���"] � ������.", " ������� [P] � ���, ���[ya]����[ya] ���� ���� � ������ �����.", " ���������� ������ [P] �� ���� ����.", " ������ [P] �� ������ ����[ya] ������ � ��������� �������[ya] �����.", " ���������� ����� [P.gender == FEMALE ? "������ �����������" : "������� �����[ya]"] � ���.", " ��������� ���������[ya] ������� [P].", ", ���������� ���������, ������ ������ ���� ��� [P] � ������ �� ��������� ��������.", " ������� �������� ������ [P].")

		if (H.lastfucked != P || H.lfhole != hole)
			message = pick(" ������������ ������������ ���� ���� [P] � ������.")
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
		else
			H.moan()
		playsound(loc, "sound/interactions/oral[rand(1, 2)].ogg", 50, 1, -1)
		if (P.species.name == "Slime")
			playsound(loc, "sound/interactions/champ[rand(1, 2)].ogg", 50, 1, -1)
		if (prob(H.potenzia))
			P.oxyloss += 3
			H.visible_message("<B>[P]</B> [pick("������[ya] ������������ <B>[H]</B>", "���������[ya]", "�������[ya] � ������� ������")].")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<B>[P]</B> [pick("������[ya] ������������ <B>[H]</B>", "���������[ya]", "�������[ya] � ������� ������")].")


	else if (hole == "mount")

		message = pick("������ �� ����� [P]", "������� �� ������������ [P]", "�����������[ya] �� [P]")
		if (prob(35))
			message = pick("������� ���� [P], ������ ���������", "������ �� ������ [P]", "������� �� [P], ����[ya][ya]�� � ��� ������� ����", "�������� ������������, �������[ya][ya] ������������ ���� � [P]", "�������� ����� � [P] � ������, ��� �����", "������ �������� �� ������� ������ [P]", "���������� �����������[ya] �� [P], ��[ya]� ������ ��� ����", "����������� ��� ���� �� ������ [P], ���[ya] �� ���� ����� �����", "�������� ������ ���[ya] ������� [P]")

		if (H.lastfucked != P || H.lfhole != hole)
			message = pick("��������� �����������[ya] �� ������� ����� [P]")
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
		H.lust += P.potenzia * 1.5
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
		playsound(loc, "sound/interactions/bang[rand(1, 3)].ogg", 70, 1, -1)
		if (H.species.name == "Slime")
			playsound(loc, "sound/interactions/champ[rand(1, 2)].ogg", 70, 1, -1)

mob/living/carbon/human/proc/moan()
	var/ya = "&#255;"
	var/mob/living/carbon/human/H = src
	if (H.species.name == "Human" || H.species.name == "Skrell" || H.species.name == "Arachna" || H.species.name == "Slime")
		if (prob(H.lust / H.resistenza * 70))
			var/message = pick("�����������", "������ �� �����������[ya]", "���������� �����", "���������� ����")
			H.visible_message("<B>[H]</B> [message].")
			var/moan = 0
			if (H.gender == FEMALE)
				if (H.lust > H.lust * 0.75)
					moan = rand(14, 18)
					if (moan == H.lastmoan)
						moan -= 1
					playsound(loc, "sound/interactions/moan_f[moan].ogg", 50, 0, -1)
					src.lastmoan = moan
				else
					moan = rand(2, 13)
					if (moan == H.lastmoan)
						moan -= 1
					playsound(loc, "sound/interactions/moan_f[moan].ogg", 50, 0, -1)
					H.lastmoan = moan
			if (istype(H.head, /obj/item/clothing/head/kitty)  || istype(H.head, /obj/item/clothing/head/collectable/kitty))
				playsound(loc, "sound/interactions/purr_f[rand(1, 2)].ogg", 50, 0, -1)
	else if (H.species.name == "Tajara")
		if (prob(H.lust / src.resistenza * 70))
			var/message = pick("��������", "�������� �� �����������[ya]", "���������� �����", "�������� �����������[ya]")
			H.visible_message("<B>[H]</B> [message].")
			if (src.gender == FEMALE)
				playsound(loc, "sound/interactions/purr_f[rand(1, 2)].ogg", 50, 0, -1)
	else if (istype(H.species, /datum/species/xenos))
		if (prob(H.lust / H.resistenza * 70))
			var/message = pick("�������� �����", "���������[ya] �� �����������[ya]")
			H.visible_message("<B>[H]</B> [message].")
			playsound(loc, "sound/voice/hiss[rand(2, 4)].ogg", 50, 0, -1)
	else if (H.species.name == "Unathi")
		if (prob(H.lust / H.resistenza * 70))
			var/message = pick("�������� �����", "���������[ya] �� �����������[ya]")
			H.visible_message("<B>[H]</B> [message].")

mob/living/carbon/human/proc/handle_lust()
	lust -= 4
	if (lust <= 0)
		lust = 0
		lastfucked = null
		lfhole = ""
	if (lust == 0)
		erpcooldown -= 1
	if (erpcooldown < 0)
		erpcooldown = 0
