/mob/living/carbon/human/Topic(href, href_list)
	///////Interactions!!///////
	if(href_list["interaction"])
		if (usr.stat == DEAD || usr.stat == UNCONSCIOUS || usr.restrained())
			return

		//CONDITIONS
		var/mob/living/carbon/human/H = usr
		var/mob/living/carbon/human/P = H.partner
		if (!(P in view(H.loc)))
			return
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

		if(world.time <= H.last_interract + 1 SECONDS)
			return
		else
			H.last_interract = world.time

		if (href_list["interaction"] == "bow")
			H.visible_message("<B>[H]</B> кланяется <B>[P]</B>.")
			if (istype(P.loc, /obj/structure/closet) && P.loc == H.loc)
				P.visible_message("<B>[H]</B> кланяется <B>[P]</B>.")

		else if (href_list["interaction"] == "pet")
			if(((!istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && hashands && H.Adjacent(P))
				H.visible_message("<B>[H]</B> [pick("гладит", "поглаживает")] <B>[P]</B>.")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("<B>[H]</B> [pick("гладит", "поглаживает")] <B>[P]</B>.")

		else if (href_list["interaction"] == "scratch")
			if(((!istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && hashands && H.Adjacent(P))
				if(H.zone_selected == "head" && !((P.dna.species.name == "Machine") || (P.dna.species.name == "Grey") || (P.dna.species.name == "Unathi")))
					H.visible_message("<B>[H]</B> [pick("чешет за ухом", "чешет голову")] <B>[P]</B>.")
					if (istype(P.loc, /obj/structure/closet))
						P.visible_message("<B>[H]</B> [pick("чешет за ухом", "чешет голову")] <B>[P]</B>.")
				else
					H.visible_message("<B>[H]</B> [pick("чешет")] <B>[P]</B>.")
					if (istype(P.loc, /obj/structure/closet))
						P.visible_message("<B>[H]</B> [pick("чешет")] <B>[P]</B>.")

		else if (href_list["interaction"] == "give")
			if(H.Adjacent(P))
				if (((!istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && hashands)
					H.give(P)

		else if (href_list["interaction"] == "kiss")
			if( ((H.Adjacent(P) && !istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)))
				H.visible_message("<B>[H]</B> целует <B>[P]</B>.")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("<B>[H]</B> целует <B>[P]</B>.")
			else if (mouthfree)
				H.visible_message("<B>[H]</B> посылает <B>[P]</B> воздушный поцелуй.")

		else if (href_list["interaction"] == "lick")
			if( ((H.Adjacent(P) && !istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && mouthfree && mouthfree_p)
				if (prob(90))
					H.visible_message("<B>[H]</B> [H.gender == FEMALE ? "лизнула" : "лизнул"] <B>[P]</B> в щеку.")
					if (istype(P.loc, /obj/structure/closet))
						P.visible_message("<B>[H]</B> [H.gender == FEMALE ? "лизнула" : "лизнул"] <B>[P]</B> в щеку.")
				else
					H.visible_message("<B>[H]</B> особо тщательно [H.gender == FEMALE ? "лизнула" : "лизнул"] <B>[P]</B>.")
					if (istype(P.loc, /obj/structure/closet))
						P.visible_message("<B>[H]</B> особо тщательно [H.gender == FEMALE ? "лизнула" : "лизнул"] <B>[P]</B>.")

		else if (href_list["interaction"] == "hug")
			if(((H.Adjacent(P) && !istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && hashands)
				H.visible_message("<B>[H]</B> обнимает <B>[P]</B>.")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("<B>[H]</B> обнимает <B>[P]</B>.")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

		else if (href_list["interaction"] == "cheer")
			if(((H.Adjacent(P) && !istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && hashands)
				H.visible_message("<B>[H]</B> похлопывает <B>[P]</B> по плечу.")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("<B>[H]</B> похлопывает <B>[P]</B> по плечу.")

		else if (href_list["interaction"] == "five")
			if(((H.Adjacent(P) && !istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && hashands)
				H.visible_message("<B>[H]</B> даёт <B>[P]</B> пять.")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("<B>[H]</B> даёт <B>[P]</B> пять.")
				playsound(loc, 'sound/effects/snap.ogg', 25, 1, -1)

		else if (href_list["interaction"] == "handshake")
			if(((H.Adjacent(P) && !istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && hashands && hashands_p)
				H.visible_message("<B>[H]</B> жмёт руку <B>[P]</B>.")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("<B>[H]</B> жмёт руку <B>[P]</B>.")

		else if (href_list["interaction"] == "bow_affably")
			H.visible_message("<B>[H]</B> приветливо кивнул[H.gender == FEMALE ? "а" : ""] в сторону <B>[P]</B>.")
			if (istype(P.loc, /obj/structure/closet))
				P.visible_message("<B>[H]</B> приветливо кивнул[H.gender == FEMALE ? "а" : ""] в сторону <B>[P]</B>.")

		else if (href_list["interaction"] == "wave")
			if (!(H.Adjacent(P)) && hashands)
				H.visible_message("<B>[H]</B> приветливо машет в сторону <B>[P]</B>.")
			else
				H.visible_message("<B>[H]</B> приветливо машет в сторону <B>[P]</B>.")


		else if (href_list["interaction"] == "slap")
			if(((H.Adjacent(P) && !istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && hashands)
				switch(H.zone_selected)
					if("head")
						H.visible_message("<span class='danger'>[H] дает [P] пощечину!</span>")
						if (istype(P.loc, /obj/structure/closet))
							P.visible_message("<span class='danger'>[H] дает [P] пощечину!</span>")
						playsound(loc, 'sound/effects/snap.ogg', 50, 1, -1)
						var/obj/item/organ/external/head/O = P.get_organ("head")
						if(O.brute_dam < 5)
							O.receive_damage(1)
						H.do_attack_animation(P)

					if("groin")
						H.visible_message("<span class='danger'>[H] шлёпает [P] по заднице!</span>")
						if (istype(P.loc, /obj/structure/closet))
							P.visible_message("<span class='danger'>[H] шлёпает [P] по заднице!</span>")
						playsound(loc, 'sound/effects/snap.ogg', 50, 1, -1)
						var/obj/item/organ/external/groin/G = P.get_organ("groin")
						if(G.brute_dam < 5)
							G.receive_damage(1)
						H.do_attack_animation(P)

					if("mouth")
						H.visible_message("<span class='danger'>[H] дает [P] по губе!</span>")
						if (istype(P.loc, /obj/structure/closet))
							P.visible_message("<span class='danger'>[H] дает [P] по губе!</span>")
						playsound(loc, 'sound/effects/snap.ogg', 50, 1, -1)
						H.do_attack_animation(P)

		else if (href_list["interaction"] == "fuckyou")
			if(hashands)
				H.visible_message("<span class='danger'>[H] показывает [P] средний палец!</span>")
				if (istype(P.loc, /obj/structure/closet) && P.loc == H.loc)
					P.visible_message("<span class='danger'>[H] показывает [P] средний палец!</span>")

		else if (href_list["interaction"] == "knock")
			if(((H.Adjacent(P) && !istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && hashands)
				H.visible_message("<span class='danger'>[H] дает [P] подзатыльник!</span>")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("<span class='danger'>[H] дает [P] подзатыльник!</span>")
				playsound(loc, 'sound/weapons/throwtap.ogg', 50, 1, -1)
				var/obj/item/organ/external/head/O = P.get_organ("head")
				if(O.brute_dam < 3)
					O.receive_damage(1)
				H.do_attack_animation(P)

		else if (href_list["interaction"] == "spit")
			if(((H.Adjacent(P) && !istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && mouthfree)
				H.visible_message("<span class='danger'>[H] плюёт в [P]!</span>")
				if (istype(P.loc, /obj/structure/closet))
					P.visible_message("<span class='danger'>[H] плюёт в [P]!</span>")

		else if (href_list["interaction"] == "threaten")
			if(hashands)
				H.visible_message("<span class='danger'>[H] грозит [P] кулаком!</span>")
				if (istype(P.loc, /obj/structure/closet) && H.loc == P.loc)
					P.visible_message("<span class='danger'>[H] грозит [P] кулаком!</span>")

		else if (href_list["interaction"] == "tongue")
			if(mouthfree)
				H.visible_message("<span class='danger'>[H] показывает [P] язык!</span>")
				if (istype(P.loc, /obj/structure/closet) && H.loc == P.loc)
					P.visible_message("<span class='danger'>[H] показывает [P] язык!</span>")

		else if (href_list["interaction"] == "pull")
			if(((H.Adjacent(P) && !istype(P.loc, /obj/structure/closet)) || (H.loc == P.loc)) && hashands && !H.restrained())
				if (prob(30))
					H.visible_message("<span class='danger'>[H] дёргает [P] за хвост!</span>")
					if (istype(P.loc, /obj/structure/closet))
						P.visible_message("<span class='danger'>[H] дёргает [P] за хвост!</span>")
					var/obj/item/organ/external/groin/O = P.get_organ("groin")
					if(O.brute_dam < 10)
						O.receive_damage(1)
				else
					H.visible_message("<B>[H]</B> пытается поймать <B>[P]</B> за хвост!")
					if (istype(P.loc, /obj/structure/closet))
						P.visible_message("<B>[H]</B> пытается поймать <B>[P]</B> за хвост!")
		return
	..()
