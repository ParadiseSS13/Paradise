//In here: Hatch and Ascendance
var/list/possibleShadowlingNames = list("U'ruan", "Y`shej", "Nex", "Hel-uae", "Noaey'gief", "Mii`mahza", "Amerziox", "Gyrg-mylin", "Kanet'pruunance", "Vigistaezian") //Unpronouncable 2: electric boogalo)
/obj/effect/proc_holder/spell/targeted/shadowling_hatch
	name = "Hatch"
	desc = "Casts off your disguise."
	panel = "Shadowling Evolution"
	charge_max = 3000
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "hatch"

/obj/effect/proc_holder/spell/targeted/shadowling_hatch/cast(list/targets)
	if(usr.stat || !ishuman(usr) || !usr || !is_shadow(usr || isinspace(usr)))
		return
	if(!isturf(usr.loc))
		to_chat(usr, "<span class='warning'>You can't hatch here!</span>")
		return
	for(var/mob/living/carbon/human/H in targets)
		var/hatch_or_no = alert(H,"Are you sure you want to hatch? You cannot undo this!",,"Yes","No")
		switch(hatch_or_no)
			if("No")
				to_chat(H, "<span class='warning'>You decide against hatching for now.")
				charge_counter = charge_max
				return
			if("Yes")
				H.Stun(INFINITY) //This is bad but notransform won't work.
				H.visible_message("<span class='warning'>[H]'s things suddenly slip off. They hunch over and vomit up a copious amount of purple goo which begins to shape around them!</span>", \
									"<span class='shadowling'>You remove any equipment which would hinder your hatching and begin regurgitating the resin which will protect you.</span>")

				for(var/obj/item/I in H.contents - (H.organs | H.internal_organs)) //drops all items except organs
					H.unEquip(I)

				sleep(50)
				var/turf/simulated/floor/F
				var/turf/shadowturf = get_turf(usr)
				for(F in orange(1, usr))
					new /obj/structure/alien/resin/wall/shadowling(F)
				for(var/obj/structure/alien/resin/wall/shadowling/R in shadowturf) //extremely hacky
					qdel(R)
					new /obj/structure/alien/weeds/node(shadowturf) //Dim lighting in the chrysalis -- removes itself afterwards
				var/temp_flags = H.status_flags
				H.status_flags |= GODMODE //Can't die while hatching

				H.visible_message("<span class='warning'>A chrysalis forms around [H], sealing them inside.</span>", \
									"<span class='shadowling'>You create your chrysalis and begin to contort within.</span>")

				sleep(100)
				H.visible_message("<span class='warning'><b>The skin on [H]'s back begins to split apart. Black spines slowly emerge from the divide.</b></span>", \
									"<span class='shadowling'>Spines pierce your back. Your claws break apart your fingers. You feel excruciating pain as your true form begins its exit.</span>")

				sleep(90)
				H.visible_message("<span class='warning'><b>[H], skin shifting, begins tearing at the walls around them.</b></span>", \
								"<span class='shadowling'>Your false skin slips away. You begin tearing at the fragile membrane protecting you.</span>")

				sleep(80)
				playsound(H.loc, 'sound/weapons/slash.ogg', 25, 1)
				to_chat(H, "<i><b>You rip and slice.</b></i>")
				sleep(10)
				playsound(H.loc, 'sound/weapons/slashmiss.ogg', 25, 1)
				to_chat(H, "<i><b>The chrysalis falls like water before you.</b></i>")
				sleep(10)
				playsound(H.loc, 'sound/weapons/slice.ogg', 25, 1)
				to_chat(H, "<i><b>You are free!</b></i>")
				H.status_flags = temp_flags
				sleep(10)
				playsound(H.loc, 'sound/effects/ghost.ogg', 100, 1)
				var/newNameId = pick(possibleShadowlingNames)
				possibleShadowlingNames.Remove(newNameId)
				H.real_name = newNameId
				H.name = usr.real_name
				H.SetStunned(0)
				to_chat(H, "<i><b><font size=3>YOU LIVE!!!</i></b></font>")

				for(var/obj/structure/alien/resin/wall/shadowling/W in orange(H, 1))
					playsound(W, 'sound/effects/splat.ogg', 50, 1)
					qdel(W)
				for(var/obj/structure/alien/weeds/node/N in shadowturf)
					qdel(N)
				H.visible_message("<span class='warning'>The chrysalis explodes in a shower of purple flesh and fluid!</span>")
				H.underwear = "None"
				H.undershirt = "None"
				H.socks = "None"
				H.faction |= "faithless"

				H.equip_to_slot_or_del(new /obj/item/clothing/under/shadowling(usr), slot_w_uniform)
				H.equip_to_slot_or_del(new /obj/item/clothing/shoes/shadowling(usr), slot_shoes)
				H.equip_to_slot_or_del(new /obj/item/clothing/suit/space/shadowling(usr), slot_wear_suit)
				H.equip_to_slot_or_del(new /obj/item/clothing/head/shadowling(usr), slot_head)
				H.equip_to_slot_or_del(new /obj/item/clothing/gloves/shadowling(usr), slot_gloves)
				H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/shadowling(usr), slot_wear_mask)
				H.equip_to_slot_or_del(new /obj/item/clothing/glasses/shadowling(usr), slot_glasses)
				H.set_species("Shadowling")	//can't be a shadowling without being a shadowling

				H.mind.RemoveSpell(src)

				sleep(10)
				to_chat(H, "<span class='shadowling'><b><i>Your powers are awoken. You may now live to your fullest extent. Remember your goal. Cooperate with your thralls and allies.</b></i></span>")
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadow_vision(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/enthrall(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/glare(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/veil(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadow_walk(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/flashfreeze(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/collective_mind(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_regenarmor(null))
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_extend_shuttle(null))

/obj/effect/proc_holder/spell/targeted/shadowling_ascend
	name = "Ascend"
	desc = "Enters your true form."
	panel = "Shadowling Evolution"
	charge_max = 3000
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "ascend"

/obj/effect/proc_holder/spell/targeted/shadowling_ascend/cast(list/targets)
	var/mob/living/carbon/human/H = usr
	if(!shadowling_check(H))
		return
	for(H in targets)
		var/hatch_or_no = alert(H,"It is time to ascend. Are you sure about this?",,"Yes","No")
		switch(hatch_or_no)
			if("No")
				to_chat(H, "<span class='warning'>You decide against ascending for now.")
				charge_counter = charge_max
				return
			if("Yes")
				H.notransform = 1
				H.visible_message("<span class='warning'>[H] gently rises into the air, red light glowing in its eyes.</span>", \
									"<span class='shadowling'>You rise into the air and get ready for your transformation.</span>")

				sleep(50)

				H.visible_message("<span class='warning'>[H]'s skin begins to crack and harden.</span>", \
									"<span class='shadowling'>Your flesh begins creating a shield around yourself.</span>")

				sleep(100)
				H.visible_message("<span class='warning'>The small horns on [H]'s head slowly grow and elongate.</span>", \
								  "<span class='shadowling'>Your body continues to mutate. Your telepathic abilities grow.</span>") //y-your horns are so big, senpai...!~

				sleep(90)
				H.visible_message("<span class='warning'>[H]'s body begins to violently stretch and contort.</span>", \
								  "<span class='shadowling'>You begin to rend apart the final barries to godhood.</span>")

				sleep(40)
				to_chat(H, "<i><b>Yes!</b></i>")
				sleep(10)
				to_chat(H, "<i><b><span class='big'>YES!!</span></b></i>")
				sleep(10)
				to_chat(H, "<i><b><span class='reallybig'>YE--</span></b></i>")
				sleep(1)
				for(var/mob/living/M in orange(7, H))
					M.Weaken(10)
					to_chat(M, "<span class='userdanger'>An immense pressure slams you onto the ground!</span>")
				to_chat(world, "<font size=5><span class='shadowling'><b>\"VYSHA NERADA YEKHEZET U'RUU!!\"</font></span>")
				world << 'sound/hallucinations/veryfar_noise.ogg'
				for(var/obj/machinery/power/apc/A in apcs)
					A.overload_lighting()
				var/mob/A = new /mob/living/simple_animal/ascendant_shadowling(H.loc)
				for(var/obj/effect/proc_holder/spell/S in H.mind.spell_list)
					if(S == src) continue
					H.mind.RemoveSpell(S)
				H.mind.transfer_to(A)
				A.name = H.real_name
				A.languages = H.languages
				A.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/annihilate(null))
				A.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/hypnosis(null))
				A.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowling_phase_shift(null))
				A.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/ascendant_storm(null))
				A.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/shadowlingAscendantTransmit(null))
				if(A.real_name)
					A.real_name = H.real_name
				H.invisibility = 60 //This is pretty bad, but is also necessary for the shuttle call to function properly
				H.loc = A
				sleep(50)
				if(!ticker.mode.shadowling_ascended)
					shuttle_master.emergency.request(null, 0.3)
				ticker.mode.shadowling_ascended = 1
				A.mind.RemoveSpell(src)
				qdel(H)
