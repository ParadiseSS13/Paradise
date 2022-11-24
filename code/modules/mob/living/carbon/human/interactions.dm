/**********************************
*******Interactions code by HONKERTRON feat TestUnit********
***********************************/

/mob/living/carbon/human/MouseDrop(mob/M as mob)
	..()
	if(src == usr)
		interact(M)

/mob/proc/make_interaction()
	return

//Distant interactions
/mob/living/carbon/human/verb/interact(mob/M as mob)
	set name = "Interact"
	set category = "IC"

	if (istype(M, /mob/living/carbon/human) && usr != M && src != M)
		partner = M
		make_interaction(machine)


/mob/living/carbon/human/proc/is_nude()
	return (!wear_suit && !w_uniform) ? 1 : 0 //TODO: Nudity check for underwear

/mob/living/carbon/human/make_interaction()
	set_machine(src)

	var/mob/living/carbon/human/H = usr
	var/mob/living/carbon/human/P = H.partner
	var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
	var/hashands = (temp?.is_usable())
	if (!hashands)
		temp = H.bodyparts_by_name["l_hand"]
		hashands = (temp?.is_usable())
	temp = P.bodyparts_by_name["r_hand"]
	var/hashands_p = (temp?.is_usable())
	if (!hashands_p)
		temp = P.bodyparts_by_name["l_hand"]
		hashands = (temp?.is_usable())
	var/mouthfree = !((H.head && (H.head.flags_cover & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags_cover & MASKCOVERSMOUTH)))
	var/mouthfree_p = !((P.head && (P.head.flags_cover & HEADCOVERSMOUTH)) || (P.wear_mask && (P.wear_mask.flags_cover & MASKCOVERSMOUTH)))


	var/dat = {"<meta charset="UTF-8"><B><HR><FONT size=3>[H.partner]</FONT></B><BR><HR>"}

	dat +=  {"• <A href='?src=[UID()];interaction=bow'>Отвесить поклон.</A><BR>"}
	if (hashands)
		dat +=  {"<font size=3><B>Руки:</B></font><BR>"}
		dat +=  {"• <A href='?src=[UID()];interaction=wave'>Приветливо помахать.</A><BR>"}
		dat +=  {"• <A href='?src=[UID()];interaction=bow_affably'>Приветливо кивнуть.</A><BR>"}
		if (Adjacent(P))
			dat +=  {"• <A href='?src=[UID()];interaction=handshake'>Пожать руку.</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=hug'>Обнимашки!</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=cheer'>Похлопать по плечу</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=five'>Дать пять.</A><BR>"}
			if (hashands_p)
				dat +=  {"• <A href='?src=[UID()];interaction=give'>Передать предмет.</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=slap'><font color=darkred>Дать пощечину!</font></A><BR>"}
			if (P.dna.species.name == "Nian")
				dat +=  {"• <A href='?src=[UID()];interaction=pullwing'><font color=darkred>Дёрнуть за крылья!</font></A><BR>"}
			if ((P.dna.species.name == "Tajaran")  || (P.dna.species.name == "Vox")|| (P.dna.species.name == "Vulpkanin") || (P.dna.species.name == "Unathi"))
				dat +=  {"• <A href='?src=[UID()];interaction=pull'><font color=darkred>Дёрнуть за хвост!</font></A><BR>"}
				if(P.can_inject(H))
					dat +=  {"• <A href='?src=[UID()];interaction=pet'>Погладить.</A><BR>"}
					dat +=  {"• <A href='?src=[UID()];interaction=scratch'>Почесать.</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=knock'><font color=darkred>Дать подзатыльник.</font></A><BR>"}
		dat +=  {"• <A href='?src=[UID()];interaction=fuckyou'><font color=darkred>Показать средний палец.</font></A><BR>"}
		dat +=  {"• <A href='?src=[UID()];interaction=threaten'><font color=darkred>Погрозить кулаком.</font></A><BR>"}

	if (mouthfree && H.dna.species.name != "Diona")
		dat += {"<font size=3><B>Лицо:</B></font><BR>"}
		dat += {"• <A href='?src=[UID()];interaction=kiss'>Поцеловать.</A><BR>"}
		if (Adjacent(P))
			if (mouthfree_p)
				dat += {"• <A href='?src=[UID()];interaction=lick'>Лизнуть в щеку.</A><BR>"}
			dat +=  {"• <A href='?src=[UID()];interaction=spit'><font color=darkred>Плюнуть.</font></A><BR>"}
		dat +=  {"• <A href='?src=[UID()];interaction=tongue'><font color=darkred>Показать язык.</font></A><BR>"}

	var/datum/browser/popup = new(usr, "interactions", "Взаимодействие", 340, 520)
	popup.set_content(dat)
	popup.open()


/mob/living/carbon/human
	var/mob/living/carbon/human/partner
	var/mob/living/carbon/human/last_interract
