/mob/living
	var/canEnterVentWith = "/obj/item/implant=0&/obj/item/clothing/mask/facehugger=0&/obj/item/radio/borg=0&/obj/machinery/camera=0"
	var/datum/middleClickOverride/middleClickOverride = null

/mob/living/carbon/Initialize(mapload)
	. = ..()
	GLOB.carbon_list += src

/mob/living/carbon/Destroy()
	// This clause is here due to items falling off from limb deletion
	for(var/obj/item in get_all_slots())
		unEquip(item)
		qdel(item)
	QDEL_LIST(internal_organs)
	QDEL_LIST(stomach_contents)
	QDEL_LIST(processing_patches)
	var/mob/living/simple_animal/borer/B = has_brain_worms()
	if(B)
		B.leave_host()
		qdel(B)
	GLOB.carbon_list -= src
	return ..()

/mob/living/carbon/handle_atom_del(atom/A)
	LAZYREMOVE(processing_patches, A)
	return ..()

/mob/living/carbon/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	else
		show_message("<span class='userdanger'>Блоб атакует!</span>")
		adjustBruteLoss(10)

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(nutrition && stat != DEAD)
			adjust_nutrition(-(hunger_drain * 0.1))
			if(m_intent == MOVE_INTENT_RUN)
				adjust_nutrition(-(hunger_drain * 0.1))
		if((FAT in mutations) && m_intent == MOVE_INTENT_RUN && bodytemperature <= 360)
			bodytemperature += 2

		// Moving around increases germ_level faster
		if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
			germ_level++

#define STOMACH_ATTACK_DELAY 4

/mob/living/carbon/var/last_stomach_attack //defining this here because no one would look in carbon_defines for it

/mob/living/carbon/relaymove(mob/user, direction)
	if(LAZYLEN(stomach_contents))
		if(user in stomach_contents)
			if(last_stomach_attack + STOMACH_ATTACK_DELAY > world.time)
				return

			last_stomach_attack = world.time
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("<span class='warning'>Вы слышите как что-то урчит в животе [src.name]...</span>"), 2)

			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)

				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/obj/item/organ/external/organ = H.get_organ("chest")
					if(istype(organ))
						if(organ.receive_damage(d, 0))
							H.UpdateDamageIcon()

					H.updatehealth("stomach attack")

				else
					take_organ_damage(d)

				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span class='warning'><B>[user] атаку[pluralize_ru(user.gender,"ет","ют")] стенку желудка [src.name], используя [I.name]!</span>"), 2)
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(getBruteLoss() - 50))
					gib()

#undef STOMACH_ATTACK_DELAY

/mob/living/carbon/proc/has_mutated_organs()
	return FALSE


/mob/living/carbon/proc/vomit(var/lost_nutrition = 10, var/blood = 0, var/stun = 1, var/distance = 0, var/message = 1)
	if(ismachineperson(src)) //IPCs do not vomit particulates
		return FALSE
	if(is_muzzled())
		if(message)
			to_chat(src, "<span class='warning'>Намордник препятствует рвоте!</span>")
		return FALSE
	if(stun)
		Stun(4)
	if(nutrition < 100 && !blood)
		if(message)
			visible_message("<span class='warning'>[src.name] сухо кашля[pluralize_ru(src.gender,"ет","ют")]!</span>", \
							"<span class='userdanger'>Вы пытаетесь проблеваться, но в вашем желудке пусто!</span>")
		if(stun)
			Weaken(10)
	else
		if(message)
			visible_message("<span class='danger'>[src.name] блю[pluralize_ru(src.gender,"ет","ют")]!</span>", \
							"<span class='userdanger'>Вас вырвало!</span>")
		playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
		var/turf/T = get_turf(src)
		for(var/i=0 to distance)
			if(blood)
				if(T)
					add_splatter_floor(T)
				if(stun)
					adjustBruteLoss(3)
			else
				if(T)
					T.add_vomit_floor()
				adjust_nutrition(-lost_nutrition)
				if(stun)
					adjustToxLoss(-3)
			T = get_step(T, dir)
			if(is_blocked_turf(T))
				break
	return TRUE

/mob/living/carbon/gib()
	. = death(1)
	if(!.)
		return
	for(var/obj/item/organ/internal/I in internal_organs)
		if(isturf(loc))
			I.remove(src)
			I.forceMove(get_turf(src))
			I.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)

	for(var/mob/M in src)
		LAZYREMOVE(stomach_contents, M)
		M.forceMove(drop_location())
		visible_message("<span class='danger'>[M] вырыва[pluralize_ru(M.gender,"ет","ют")]ся из [src.name]!</span>")

/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = FALSE, override = FALSE, tesla_shock = FALSE, illusion = FALSE, stun = TRUE)
	SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage)
	if(status_flags & GODMODE)	//godmode
		return FALSE
	if(NO_SHOCK in mutations) //shockproof
		return FALSE
	if(tesla_shock && tesla_ignore)
		return FALSE
	shock_damage *= siemens_coeff
	if(dna && dna.species)
		shock_damage *= dna.species.siemens_coeff
	if(shock_damage < 1 && !override)
		return FALSE
	if(reagents.has_reagent("teslium"))
		shock_damage *= 1.5 //If the mob has teslium in their body, shocks are 50% more damaging!
	if(illusion)
		adjustStaminaLoss(shock_damage)
	else
		take_overall_damage(0, shock_damage, TRUE, used_weapon = "Electrocution")
		shock_internal_organs(shock_damage)
	visible_message(
		"<span class='danger'>[src.name] получил[genderize_ru(src.gender,"","а","о","и")] разряд током [source]!</span>",
		"<span class='userdanger'>Вы чувствуете электрический разряд проходящий через ваше тело!</span>",
		"<span class='italics'>Вы слышите сильный электрический треск.</span>")
	AdjustJitter(1000) //High numbers for violent convulsions
	do_jitter_animation(jitteriness)
	AdjustStuttering(2)
	if((!tesla_shock || (tesla_shock && siemens_coeff > 0.5)) && stun)
		Stun(2)
	spawn(20)
		AdjustJitter(-1000, bound_lower = 10) //Still jittery, but vastly less
		if((!tesla_shock || (tesla_shock && siemens_coeff > 0.5)) && stun)
			Stun(2)
			Weaken(2)
	if(shock_damage > 200)
		src.visible_message(
			"<span class='danger'>[src.name] был[genderize_ru(src.gender,"","а","о","и")] прожжен[genderize_ru(src.gender,"","а","о","ы")] дугой [source]!</span>",
			"<span class='userdanger'>Дуга [source] вспыхивает и ударяет вас электрическим током!</span>",
			"<span class='italics'>Вы слышите треск похожий на молнию!</span>")
		playsound(loc, 'sound/effects/eleczap.ogg', 50, 1, -1)
		explosion(loc, -1, 0, 2, 2, cause = "[source] over electrocuted [name]")

	if(override)
		return override
	else
		return shock_damage



/mob/living/carbon/swap_hand()
	var/obj/item/item_in_hand = src.get_active_hand()
	if(item_in_hand) //this segment checks if the item in your hand is twohanded.
		if(istype(item_in_hand,/obj/item/twohanded))
			if(item_in_hand:wielded == 1)
				to_chat(usr, "<span class='warning'>Ваша другая рука занята удерживанием [item_in_hand.name]</span>")
				return
	src.hand = !( src.hand )
	if(hud_used && hud_used.inv_slots[slot_l_hand] && hud_used.inv_slots[slot_r_hand])
		var/obj/screen/inventory/hand/H
		H = hud_used.inv_slots[slot_l_hand]
		H.update_icon()
		H = hud_used.inv_slots[slot_r_hand]
		H.update_icon()


/mob/living/carbon/activate_hand(var/selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(health >= HEALTH_THRESHOLD_CRIT)
		if(src == M && ishuman(src))
			check_self_for_injuries()
		else
			if(player_logged)
				M.visible_message("<span class='notice'>[M] встряхива[pluralize_ru(M.gender,"ет","ют")] [src.name], но он[genderize_ru(src.gender,"","а","о","и")] не отвечает. Вероятно у [genderize_ru(src.gender,"него","неё","этого","них")] SSD.", \
				"<span class='notice'>Вы трясете [src.name], но он[genderize_ru(src.gender,"","а","о","и")] не отвечает. Вероятно у [genderize_ru(src.gender,"него","неё","этого","них")] SSD.</span>")
			if(lying) // /vg/: For hugs. This is how update_icon figgers it out, anyway.  - N3X15
				add_attack_logs(M, src, "Shaked", ATKLOG_ALL)
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					if(H.w_uniform)
						H.w_uniform.add_fingerprint(M)
				AdjustSleeping(-5)
				if(sleeping == 0)
					StopResting()
				AdjustParalysis(-3)
				AdjustStunned(-3)
				AdjustWeakened(-3)
				adjustStaminaLoss(-10)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				if(!player_logged)
					M.visible_message( \
						"<span class='notice'>[M] трясет [src.name] пытаясь разбудить [genderize_ru(src.gender,"его","её","это","их")]!</span>",\
						"<span class='notice'>Вы трясете [src.name] пытаясь разбудить [genderize_ru(src.gender,"его","её","это","их")]!</span>",\
						)

			else if(on_fire)
				var/self_message = "<span class='warning'>Вы пытаетесь потушить [src.name]!</span>"
				if(prob(30) && ishuman(M)) // 30% chance of burning your hands
					var/mob/living/carbon/human/H = M
					var/protected = FALSE // Protected from the fire
					if((H.gloves?.max_heat_protection_temperature > 360) || (HEATRES in H.mutations))
						protected = TRUE

					var/obj/item/organ/external/active_hand = H.get_organ("[H.hand ? "l" : "r"]_hand")
					if(active_hand && !protected) // Wouldn't really work without a hand
						active_hand.receive_damage(0, 5)
						self_message = "<span class='danger'>Вы обжигаете ваши руки пытаясь потушить [src.name]!</span>"
						H.update_icons()

				M.visible_message("<span class='warning'>[M] пыта[pluralize_ru(M.gender,"ет","ют")]ся потушить [src.name]!</span>", self_message)
				playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				adjust_fire_stacks(-0.5)

			// BEGIN HUGCODE - N3X
			else
				playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				if(M.zone_selected == "head")
					M.visible_message(\
					"<span class='notice'>[M] глад[pluralize_ru(M.gender,"ит","ят")] [src.name] по голове.</span>",\
					"<span class='notice'>Вы погладили [src.name] по голове.</span>",\
					)
				else

					M.visible_message(\
					"<span class='notice'>[M] [pick("обнима[pluralize_ru(M.gender,"ет","ют")]","тепло обнима[pluralize_ru(M.gender,"ет","ют")]", "прижима[pluralize_ru(M.gender,"ет","ют")] к груди", "приобнима[pluralize_ru(M.gender,"ет","ют")]", "прижима[pluralize_ru(M.gender,"ет","ют")] к груди голову", "приобнял[genderize_ru(M.gender,"","а","о","и")] плечи")] [src.name].</span>",\
					"<span class='notice'>Вы обняли [src.name].</span>",\
					)
					if(ishuman(src))
						var/mob/living/carbon/human/H = src
						if(H.wear_suit)
							H.wear_suit.add_fingerprint(M)
						else if(H.w_uniform)
							H.w_uniform.add_fingerprint(M)

/mob/living/carbon/proc/check_self_for_injuries()
	var/mob/living/carbon/human/H = src
	visible_message( \
		text("<span class='notice'>[src.name] осматрива[pluralize_ru(src.gender,"ет","ют")] себя.</span>"),\
		"<span class='notice'>Вы осмотрели себя на наличие травм.</span>", \
		)

	var/list/missing = list("head", "chest", "groin", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")
	for(var/X in H.bodyparts)
		var/obj/item/organ/external/LB = X
		missing -= LB.limb_name
		var/status = ""
		var/brutedamage = LB.brute_dam
		var/burndamage = LB.burn_dam

		if(brutedamage > 0)
			status = "bruised"
		if(brutedamage > 20)
			status = "battered"
		if(brutedamage > 40)
			status = "mangled"
		if(brutedamage > 0 && burndamage > 0)
			status += " and "
		if(burndamage > 40)
			status += "peeling away"

		else if(burndamage > 10)
			status += "blistered"
		else if(burndamage > 0)
			status += "numb"
		if(LB.status & ORGAN_MUTATED)
			status = "weirdly shapen."
		if(status == "")
			status = "OK"
		to_chat(src, "\t <span class='[status == "OK" ? "notice" : "warning"]'>Your [LB.name] is [status].</span>")

		for(var/obj/item/I in LB.embedded_objects)
			to_chat(src, "\t <a href='byond://?src=[UID()];embedded_object=[I.UID()];embedded_limb=[LB.UID()]' class='warning'>В твоем [LB.name] застрял [I]!</a>")

	for(var/t in missing)
		to_chat(src, "<span class='boldannounce'>У вас отсутствует [parse_zone(t)]!</span>")

	if(H.bleed_rate)
		to_chat(src, "<span class='danger'>У вас кровотечение!</span>")
	if(staminaloss)
		if(staminaloss > 30)
			to_chat(src, "<span class='info'>Вы полностью истощены.</span>")
		else
			to_chat(src, "<span class='info'>Вы чувствуете усталость.</span>")
	if((SKELETON in H.mutations) && (!H.w_uniform) && (!H.wear_suit))
		H.play_xylophone()

/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0)
	. = ..()
	var/damage = intensity - check_eye_prot()
	var/extra_damage = 0
	if(.)
		if(visual)
			return
		if(weakeyes)
			Stun(2)

		var/obj/item/organ/internal/eyes/E = get_int_organ(/obj/item/organ/internal/eyes)
		if(!E || (E && E.weld_proof))
			return

		var/extra_darkview = 0
		if(E.see_in_dark)
			extra_darkview = max(E.see_in_dark - 2, 0)
			extra_damage = extra_darkview

		var/light_amount = 10 // assume full brightness
		if(isturf(src.loc))
			var/turf/T = src.loc
			light_amount = round(T.get_lumcount() * 10)

		// a dark view of 8, in full darkness, will result in maximum 1st tier damage
		var/extra_prob = (10 - light_amount) * extra_darkview

		switch(damage)
			if(1)
				to_chat(src, "<span class='warning'>Ваши глаза немного щиплет.</span>")
				var/minor_damage_multiplier = min(40 + extra_prob, 100) / 100
				var/minor_damage = minor_damage_multiplier * (1 + extra_damage)
				E.receive_damage(minor_damage, 1)
			if(2)
				to_chat(src, "<span class='warning'>Ваши глаза пылают.</span>")
				E.receive_damage(rand(2, 4) + extra_damage, 1)

			else
				to_chat(src, "Глаза сильно чешутся и пылают!</span>")
				E.receive_damage(rand(12, 16) + extra_damage, 1)

		if(E.damage > E.min_bruised_damage)
			AdjustEyeBlind(damage)
			AdjustEyeBlurry(damage * rand(3, 6))

			if(E.damage > (E.min_bruised_damage + E.min_broken_damage) / 2)
				if(!E.is_robotic())
					to_chat(src, "<span class='warning'>Ваши глаза начинают сильно пылать!</span>")
				else //snowflake conditions piss me off for the record
					to_chat(src, "<span class='warning'>Вас ослепила вспышка!</span>")

			else if(E.damage >= E.min_broken_damage)
				to_chat(src, "<span class='warning'>Вы ничего не видите!</span>")

			else
				to_chat(src, "<span class='warning'>Ваши глаза начинают изрядно болеть. Это определенно не очень хорошо!</span>")
		if(mind && has_bane(BANE_LIGHT))
			mind.disrupt_spells(-500)
		return 1

	else if(damage == 0) // just enough protection
		if(prob(20))
			to_chat(src, "<span class='notice'>Что-то яркое вспыхнуло на периферии вашего зрения!</span>")
			if(mind && has_bane(BANE_LIGHT))
				mind.disrupt_spells(0)


/mob/living/carbon/proc/tintcheck()
	return 0

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(var/datum/dna/newDNA)
	dna = newDNA


GLOBAL_LIST_INIT(ventcrawl_machinery, list(/obj/machinery/atmospherics/unary/vent_pump, /obj/machinery/atmospherics/unary/vent_scrubber))

/mob/living/handle_ventcrawl(var/atom/clicked_on) // -- TLE -- Merged by Carn
	if(!Adjacent(clicked_on))
		return

	var/ventcrawlerlocal = 0
	if(ventcrawler)
		ventcrawlerlocal = ventcrawler

	if(!ventcrawlerlocal)
		return

	if(stat)
		to_chat(src, "Вы должны быть в сознании чтобы это сделать!")
		return

	if(lying)
		to_chat(src, "Пока вы оглушены, вы не можете заползти в вентиляцию!")
		return

	if(has_buckled_mobs())
		to_chat(src, "<span class='warning'>Пока на вас другие существа, вы не можете заползти в вентиляцию!</span>")
		return
	if(buckled)
		to_chat(src, "<span class='warning'>Пока вы пристегнуты, вы не можете заползти в вентиляцию!</span>")
		return
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/contortionist))//IMMA SPCHUL SNOWFLAKE
			var/obj/item/clothing/under/contortionist/C = H.w_uniform
			if(!C.check_clothing(src))//return values confuse me right now
				return

	var/obj/machinery/atmospherics/unary/vent_found

	if(clicked_on)
		vent_found = clicked_on
		if(!istype(vent_found) || !vent_found.can_crawl_through())
			vent_found = null


	if(!vent_found)
		for(var/obj/machinery/atmospherics/machine in range(1,src))
			if(is_type_in_list(machine, GLOB.ventcrawl_machinery) && machine.can_crawl_through())
				vent_found = machine
				break

	if(vent_found)
		if(vent_found.parent && (vent_found.parent.members.len || vent_found.parent.other_atmosmch))
			visible_message("<span class='notice'>[src.name] начина[pluralize_ru(src.gender,"ет","ют")] лезть в вентиляцию...</span>", \
							"<span class='notice'>Вы начинаете лезть в вентиляцию...</span>")

			if(!do_after(src, 45, target = src))
				return

			if(has_buckled_mobs())
				to_chat(src, "<span class='warning'>Пока на вас другие существа, вы не можете заползти в вентиляцию!</span>")
				return

			if(buckled)
				to_chat(src, "<span class='warning'>Пока вы пристегнуты, вы не можете заползти в вентиляцию!</span>")
				return

			if(!client)
				return

			if(iscarbon(src) && contents.len && ventcrawlerlocal < 2)//It must have atleast been 1 to get this far
				for(var/obj/item/I in contents)
					var/failed = 0
					if(istype(I, /obj/item/implant))
						continue
					if(istype(I, /obj/item/organ))
						continue
					if(I.flags & ABSTRACT)
						continue
					else
						failed++

					if(failed)
						to_chat(src, "<span class='warning'>Вы не можете ползать по вентиляции с предметами</span>")
						return
			if(isswarmer(src))
				var/mob/living/simple_animal/hostile/swarmer/S = src
				if(S.light_range)
					S.ToggleLight()
			if(issilicon(src))
				var/mob/living/silicon/S = src
				if (S.inventory_head)
					S.drop_hat()
					visible_message("<b>[src.name] опрокинул шляпу при залезании в вентиляцию!</b>", "Помеха корпуса была утеряна.")

			visible_message("<b>[src.name] залез[genderize_ru(src.gender,"","ла","ло","ли")] в вентиляцию!</b>", "Вы залезли в вентиляцию.")
			src.loc = vent_found
			add_ventcrawl(vent_found)

	else
		to_chat(src, "<span class='warning'>Эта вентиляция ни к чему не подключена!</span>")


/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/starting_machine, obj/machinery/atmospherics/target_move)
	if(!istype(starting_machine) || !starting_machine.returnPipenet(target_move) || !starting_machine.can_see_pipes())
		return
	var/datum/pipeline/pipeline = starting_machine.returnPipenet(target_move)
	var/list/totalMembers = list()
	totalMembers |= pipeline.members
	totalMembers |= pipeline.other_atmosmch
	for(var/obj/machinery/atmospherics/A in totalMembers)
		if(!A.pipe_image)
			A.update_pipe_image()
		pipes_shown += A.pipe_image
		client.images += A.pipe_image

/mob/living/proc/remove_ventcrawl()
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		client.eye = src

	pipes_shown.len = 0

//OOP
/atom/proc/update_pipe_vision()
	return

/mob/living/update_pipe_vision(obj/machinery/atmospherics/target_move)
	if(!client)
		pipes_shown.Cut()
		return
	if(length(pipes_shown) && !target_move)
		if(!is_ventcrawling(src))
			remove_ventcrawl()
	else
		if(is_ventcrawling(src))
			if(target_move)
				remove_ventcrawl()
			add_ventcrawl(loc, target_move)


//Throwing stuff

/mob/living/carbon/throw_impact(atom/hit_atom, throwingdatum)
	. = ..()
	var/hurt = TRUE
	/*if(istype(throwingdatum, /datum/thrownthing))
		var/datum/thrownthing/D = throwingdatum
		if(isrobot(D.thrower))
			var/mob/living/silicon/robot/R = D.thrower
			if(!R.emagged)
				hurt = FALSE*/
	if(hit_atom.density && isturf(hit_atom))
		if(hurt)
			Weaken(1)
			take_organ_damage(10)
	if(iscarbon(hit_atom) && hit_atom != src)
		var/mob/living/carbon/victim = hit_atom
		if(victim.flying)
			return
		if(hurt)
			victim.take_organ_damage(10)
			take_organ_damage(10)
			victim.Weaken(1)
			Weaken(1)
			visible_message("<span class='danger'>[src.name] вреза[pluralize_ru(src.gender,"ет","ют")]ся в [victim.name], сбивая друг друга с ног!</span>", "<span class='userdanger'>Вы жестко врезаетесь в [victim.name]!</span>")
		playsound(src, 'sound/weapons/punch1.ogg', 50, 1)

/mob/living/carbon/proc/toggle_throw_mode()
	if(in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/carbon/proc/throw_mode_off()
	src.in_throw_mode = 0
	if(src.throw_icon) //in case we don't have the HUD and we use the hotkey
		src.throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/proc/throw_mode_on()
	src.in_throw_mode = 1
	if(src.throw_icon)
		src.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	if(!target || !isturf(loc) || istype(target, /obj/screen))
		throw_mode_off()
		return

	var/obj/item/I = src.get_active_hand()

	if(!I || I.override_throw(src, target) || (I.flags & NODROP))
		throw_mode_off()
		return

	throw_mode_off()
	var/atom/movable/thrown_thing

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		var/mob/throwable_mob = G.get_mob_if_throwable() //throw the person instead of the grab
		qdel(G)	//We delete the grab.
		if(throwable_mob)
			thrown_thing = throwable_mob
			if(HAS_TRAIT(src, TRAIT_PACIFISM))
				to_chat(src, "<span class='notice'>[pluralize_ru(src.gender,"Ты","Вы")] осторожно отпускае[pluralize_ru(src.gender,"шь","те")] [throwable_mob.declent_ru(ACCUSATIVE)].</span>")
				return
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			throwable_mob.forceMove(start_T)
			if(start_T && end_T)
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				add_attack_logs(src, throwable_mob, "Thrown from [start_T_descriptor] with the target [end_T_descriptor]")

	else if(!(I.flags & ABSTRACT)) //can't throw abstract items
		thrown_thing = I
		unEquip(I)

		if(HAS_TRAIT(src, TRAIT_PACIFISM) && I.throwforce)
			to_chat(src, "<span class='notice'>[pluralize_ru(src.gender,"Ты","Вы")] осторожно опускае[pluralize_ru(src.gender,"шь","те")] [I.declent_ru(ACCUSATIVE)] на землю.</span>")
			return

	if(thrown_thing)
		visible_message("<span class='danger'>[src.declent_ru(NOMINATIVE)] броса[pluralize_ru(src.gender,"ет","ют")] [thrown_thing.declent_ru(ACCUSATIVE)].</span>")
		newtonian_move(get_dir(target, src))
		thrown_thing.throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src, null, null, null, move_force)

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return FALSE
	if(buckled && ! istype(buckled, /obj/structure/chair)) // buckling does not restrict hands
		return FALSE
	return TRUE

/mob/living/carbon/restrained()
	if(get_restraining_item())
		return TRUE
	return FALSE

/mob/living/carbon/get_restraining_item()
	return handcuffed

/mob/living/carbon/unEquip(obj/item/I, force) //THIS PROC DID NOT CALL ..()
	. = ..() //Sets the default return value to what the parent returns.
	if(!. || !I) //We don't want to set anything to null if the parent returned 0.
		return

	if(I == back)
		back = null
		update_inv_back()
	else if(I == wear_mask)
		if(istype(src, /mob/living/carbon/human)) //If we don't do this hair won't be properly rebuilt.
			return
		wear_mask = null
		update_inv_wear_mask()
	else if(I == handcuffed)
		handcuffed = null
		if(buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		update_handcuffed()
	else if(I == legcuffed)
		legcuffed = null
		toggle_move_intent()
		update_inv_legcuffed()

/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)

	var/dat = {"<meta charset="UTF-8"><table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=[UID()];item=[slot_l_hand]'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=[UID()];item=[slot_r_hand]'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=[UID()];item=[slot_back]'>[(back && !(back.flags&ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/tank))
		dat += "&nbsp;<A href='?src=[UID()];internal=[slot_back]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[UID()];item=[slot_head]'>[(head && !(head.flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td><B>Mask:</B></td><td><A href='?src=[UID()];item=[slot_wear_mask]'>[(wear_mask && !(wear_mask.flags&ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		var/obj/item/clothing/mask/muzzle/M = wear_mask
		if(M.security_lock)
			dat += "&nbsp;<A href='?src=[M.UID()];locked=\ref[src]'>[M.locked ? "Disable Lock" : "Set Lock"]</A>"

		dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=[UID()];item=[slot_handcuffed]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><A href='?src=[UID()];item=[slot_legcuffed]'>Legcuffed</A></td></tr>"

	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/Topic(href, href_list)
	..()
	//strip panel
	if(!usr.stat && usr.canmove && !usr.restrained() && in_range(src, usr))
		if(href_list["internal"])
			var/slot = text2num(href_list["internal"])
			var/obj/item/ITEM = get_item_by_slot(slot)
			if(ITEM && istype(ITEM, /obj/item/tank))
				visible_message("<span class='danger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM].</span>", \
								"<span class='userdanger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM].</span>")

				var/no_mask
				if(!get_organ_slot("breathing_tube"))
					if(!(wear_mask && wear_mask.flags & AIRTIGHT))
						if(!(head && head.flags & AIRTIGHT))
							no_mask = 1
				if(no_mask)
					to_chat(usr, "<span class='warning'>[src.name] не нос[pluralize_ru(src.gender,"ит","ят")] подходящую маску или шлем!</span>")
					return

				if(do_mob(usr, src, POCKET_STRIP_DELAY))
					if(internal)
						internal = null
						update_action_buttons_icon()
					else
						var/no_mask2
						if(!get_organ_slot("breathing_tube"))
							if(!(wear_mask && wear_mask.flags & AIRTIGHT))
								if(!(head && head.flags & AIRTIGHT))
									no_mask2 = 1
						if(no_mask2)
							to_chat(usr, "<span class='warning'>[src.name] не нос[pluralize_ru(src.gender,"ит","ят")] подходящую маску или шлем!</span>")
							return
						internal = ITEM
						update_action_buttons_icon()

					visible_message("<span class='danger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM].</span>", \
									"<span class='userdanger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM].</span>")

/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(slot_back)
			return back
		if(slot_wear_mask)
			return wear_mask
		if(slot_wear_suit)
			return wear_suit
		if(slot_l_hand)
			return l_hand
		if(slot_r_hand)
			return r_hand
		if(slot_handcuffed)
			return handcuffed
		if(slot_legcuffed)
			return legcuffed
	return null

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(var/method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^



/mob/living/carbon/proc/canBeHandcuffed()
	return 0

/mob/living/carbon/fall(forced)
    loc?.handle_fall(src, forced)//it's loc so it doesn't call the mob's handle_fall which does nothing

/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))

/mob/living/carbon/resist_buckle()
	spawn(0)
		resist_muzzle()
	var/obj/item/I
	if((I = get_restraining_item())) // If there is nothing to restrain him then he is not restrained
		var/breakouttime = I.breakouttime
		var/displaytime = breakouttime / 10
		visible_message("<span class='warning'>[src.name] пыта[pluralize_ru(src.gender,"ет","ют")]ся себя отстегнуть!</span>", \
					"<span class='notice'>Вы пытаетесь себя отстегнуть... (Это займет около [displaytime] секунд и вам не нужно двигаться.)</span>")
		if(do_after(src, breakouttime, 0, target = src))
			if(!buckled)
				return
			buckled.user_unbuckle_mob(src,src)
		else
			if(src && buckled)
				to_chat(src, "<span class='warning'>Вам не удалось себя отстегнуть!</span>")
	else
		buckled.user_unbuckle_mob(src,src)

/mob/living/carbon/resist_fire()
	fire_stacks -= 5
	Weaken(3, 1, 1) //We dont check for CANWEAKEN, I don't care how immune to weakening you are, if you're rolling on the ground, you're busy.
	update_canmove()
	spin(32,2)
	visible_message("<span class='danger'>[src.name] ката[pluralize_ru(src.gender,"ет","ют")]ся по полу, пытаясь потушиться!</span>", \
		"<span class='notice'>Вы остановились, упали и катаетесь!</span>")
	sleep(30)
	if(fire_stacks <= 0)
		visible_message("<span class='danger'>[src.name] успешно потушился!</span>", \
			"<span class='notice'>Вы потушились.</span>")
		ExtinguishMob()


/mob/living/carbon/resist_restraints()
	spawn(0)
		resist_muzzle()
	var/obj/item/I = null
	if(handcuffed)
		I = handcuffed
	else if(legcuffed)
		I = legcuffed
	if(I)
		cuff_resist(I)

/mob/living/carbon/resist_muzzle()
	if(!istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return
	var/obj/item/clothing/mask/muzzle/I = wear_mask
	var/time = I.resist_time
	if(I.resist_time == 0)//if it's 0, you can't get out of it
		to_chat(src, "[I] слишком хорошо зафиксирован, для него вам понадобятся руки!")
	else
		visible_message("<span class='warning'>[src.name] грыз[pluralize_ru(src.gender,"ет","ут")] [I], пытаясь избавиться от него!</span>")
		to_chat(src, "<span class='notice'>Вы пытаетесь избавиться от [I]... (Это займет около [time/10] секунд и вам не нужно двигаться.)</span>")
		if(do_after(src, time, 0, target = src))
			visible_message("<span class='warning'>[src.name] избавил[genderize_ru(src.gender,"ся","ась","ось","ись")] от [I]!</span>")
			to_chat(src, "<span class='notice'>Вы избавились от [I]!</span>")
			if(I.security_lock)
				I.do_break()
			unEquip(I)


/mob/living/carbon/proc/cuff_resist(obj/item/I, breakouttime = 600, cuff_break = 0)
	breakouttime = I.breakouttime

	var/displaytime = breakouttime / 10
	if(!cuff_break)
		visible_message("<span class='warning'>[src.name] пыта[pluralize_ru(src.gender,"ет","ют")]ся снять [I]!</span>")
		to_chat(src, "<span class='notice'>Вы пытаетесь снять [I]... (Это займет около [displaytime] секунд и вам не нужно двигаться.)</span>")
		if(do_after(src, breakouttime, 0, target = src))
			if(I.loc != src || buckled)
				return
			visible_message("<span class='danger'>[src.name] удалось снять [I]!</span>")
			to_chat(src, "<span class='notice'>Вы успешно сняли [I].</span>")

			if(I == handcuffed)
				handcuffed.forceMove(drop_location())
				handcuffed.dropped(src)
				handcuffed = null
				if(buckled && buckled.buckle_requires_restraints)
					buckled.unbuckle_mob(src)
				update_handcuffed()
				return
			if(I == legcuffed)
				legcuffed.forceMove(drop_location())
				legcuffed.dropped()
				legcuffed = null
				toggle_move_intent()
				update_inv_legcuffed()
				return
			else
				unEquip(I)
				I.dropped()
				return
		else
			to_chat(src, "<span class='warning'>Вам не удалось снять [I]!</span>")

	else
		breakouttime = 50
		visible_message("<span class='warning'>[src.name] пыта[pluralize_ru(src.gender,"ет","ют")]ся сломать [I]!</span>")
		to_chat(src, "<span class='notice'>Вы пытаетесь сломать [I]... (Это займет у вас приблизительно 5 секунд и вам не нужно двигаться)</span>")
		if(do_after(src, breakouttime, 0, target = src))
			if(!I.loc || buckled)
				return
			visible_message("<span class='danger'>[src.name] успешно сломал[genderize_ru(src.gender,"","а","о","и")] [I]!</span>")
			to_chat(src, "<span class='notice'>Вы успешно сломали [I].</span>")
			qdel(I)

			if(I == handcuffed)
				handcuffed = null
				update_handcuffed()
				return
			else if(I == legcuffed)
				legcuffed = null
				toggle_move_intent()
				update_inv_legcuffed()
				return
			return 1
		else
			to_chat(src, "<span class='warning'>Вам не удалось сломать [I]!</span>")

//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed()
	if(handcuffed)
		//we don't want problems with nodrop shit if there ever is more than one nodrop twohanded
		var/obj/item/I = get_active_hand()
		if(istype(I, /obj/item/twohanded))
			var/obj/item/twohanded/TH = I //FML
			if(TH.wielded)
				TH.unwield()
		drop_r_hand()
		drop_l_hand()
		stop_pulling()
		throw_alert("handcuffed", /obj/screen/alert/restrained/handcuffed, new_master = src.handcuffed)
	else
		clear_alert("handcuffed")
	update_action_buttons_icon() //some of our action buttons might be unusable when we're handcuffed.
	update_inv_handcuffed()
	update_hud_handcuffed()

/mob/living/carbon/get_standard_pixel_y_offset(lying = 0)
	if(lying)
		if(buckled)
			return buckled.buckle_offset //tg just has this whole block removed, always returning -6. Paradise is special.
		else
			return -6
	else
		return initial(pixel_y)

/mob/living/carbon/emp_act(severity)
	..()
	for(var/X in internal_organs)
		var/obj/item/organ/internal/O = X
		O.emp_act(severity)

/mob/living/carbon/Stat()
	..()
	if(statpanel("Status"))
		var/obj/item/organ/internal/xenos/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/xenos/plasmavessel)
		if(vessel)
			stat(null, "Plasma Stored: [vessel.stored_plasma]/[vessel.max_plasma]")
		var/obj/item/organ/internal/wryn/glands/glands = get_int_organ(/obj/item/organ/internal/wryn/glands)
		if(glands)
			stat(null, "Wax: [glands.wax]")

/mob/living/carbon/get_all_slots()
	return list(l_hand,
				r_hand,
				handcuffed,
				legcuffed,
				back,
				wear_mask)

/mob/living/carbon/proc/uncuff()
	if(handcuffed)
		var/obj/item/W = handcuffed
		handcuffed = null
		if(buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		update_handcuffed()
		if(client)
			client.screen -= W
		if(W)
			W.forceMove(drop_location())
			W.dropped(src)
			if(W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)
	if(legcuffed)
		var/obj/item/W = legcuffed
		legcuffed = null
		toggle_move_intent()
		update_inv_legcuffed()
		if(client)
			client.screen -= W
		if(W)
			W.forceMove(drop_location())
			W.dropped(src)
			if(W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)


/mob/living/carbon/proc/slip(description, stun, weaken, tilesSlipped, walkSafely, slipAny, grav_ignore = FALSE, slipVerb = "поскользнулись")
	if(flying || buckled || (walkSafely && m_intent == MOVE_INTENT_WALK))
		return FALSE

	if((lying) && (!(tilesSlipped)))
		return FALSE

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/turf/simulated/T = get_turf(H)
		if(!(slipAny) && isobj(H.shoes) && (H.shoes.flags & NOSLIP))
			return FALSE
		if(istype(H.shoes, /obj/item/clothing/shoes/magboots)) //Only for lubeprotection magboots and lube slip
			var/obj/item/clothing/shoes/magboots/humanmagboots = H.shoes
			if((T.wet == TURF_WET_LUBE||TURF_WET_PERMAFROST) && humanmagboots.magpulse && humanmagboots.lubeprotection)
				return FALSE
		if(!has_gravity(H) && !grav_ignore)
			if(istype(H.shoes, /obj/item/clothing/shoes/magboots)) //Only for magboots and lube slip (no grav && no lubeprotection)
				var/obj/item/clothing/shoes/magboots/humanmagboots = H.shoes
				if(!((T.wet == TURF_WET_LUBE||TURF_WET_PERMAFROST) && humanmagboots.magpulse))
					return FALSE
			else
				return FALSE

	if(tilesSlipped)
		for(var/i in 1 to tilesSlipped)
			spawn(i)
				step(src, dir)

	stop_pulling()
	to_chat(src, "<span class='notice'>Вы [slipVerb] на [description]!</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -3)
	// Something something don't run with scissors
	moving_diagonally = 0 //If this was part of diagonal move slipping will stop it.
	Stun(stun)
	Weaken(weaken)
	return TRUE

/mob/living/carbon/proc/eat(var/obj/item/reagent_containers/food/toEat, mob/user, var/bitesize_override)
	if(!istype(toEat))
		return 0
	var/fullness = nutrition + 10
	if(istype(toEat, /obj/item/reagent_containers/food/snacks))
		for(var/datum/reagent/consumable/C in reagents.reagent_list) //we add the nutrition value of what we're currently digesting
			fullness += C.nutriment_factor * C.volume / (C.metabolization_rate * metabolism_efficiency * digestion_ratio)
	if(user == src)
		if(istype(toEat, /obj/item/reagent_containers/food/drinks))
			if(!selfDrink(toEat))
				return 0
		else
			if(!selfFeed(toEat, fullness))
				return 0
		if(toEat.log_eating)
			var/this_bite = bitesize_override ? bitesize_override : toEat.bitesize
			add_game_logs("Ate [toEat](bite volume: [this_bite*toEat.transfer_efficiency]) containing [toEat.reagents.log_list()]", src)
	else
		if(!forceFed(toEat, user, fullness))
			return 0
		var/this_bite = bitesize_override ? bitesize_override : toEat.bitesize
		add_attack_logs(user, src, "Force Fed [toEat](bite volume: [this_bite*toEat.transfer_efficiency]u) containing [toEat.reagents.log_list()]")
	consume(toEat, bitesize_override, can_taste_container = toEat.can_taste)
	GLOB.score_foodeaten++
	return 1

/mob/living/carbon/proc/selfFeed(var/obj/item/reagent_containers/food/toEat, fullness)
	if(ispill(toEat))
		to_chat(src, "<span class='notify'>You [toEat.apply_method] [toEat].</span>")
	else
		if(toEat.junkiness && satiety < -150 && nutrition > NUTRITION_LEVEL_STARVING + 50 )
			to_chat(src, "<span class='notice'>You don't feel like eating any more junk food at the moment.</span>")
			return 0
		if(fullness <= 50)
			to_chat(src, "<span class='warning'>You hungrily chew out a piece of [toEat] and gobble it!</span>")
		else if(fullness > 50 && fullness < 150)
			to_chat(src, "<span class='notice'>You hungrily begin to eat [toEat].</span>")
		else if(fullness > 150 && fullness < 500)
			to_chat(src, "<span class='notice'>You take a bite of [toEat].</span>")
		else if(fullness > 500 && fullness < 600)
			to_chat(src, "<span class='notice'>You unwillingly chew a bit of [toEat].</span>")
		else if(fullness > (600 * (1 + overeatduration / 2000)))	// The more you eat - the more you can eat
			to_chat(src, "<span class='warning'>You cannot force any more of [toEat] to go down your throat.</span>")
			return 0
	return 1

/mob/living/carbon/proc/selfDrink(var/obj/item/reagent_containers/food/drinks/toDrink, mob/user)
	return 1

/mob/living/carbon/proc/forceFed(var/obj/item/reagent_containers/food/toEat, mob/user, fullness)
	if(ispill(toEat) || fullness <= (600 * (1 + overeatduration / 1000)))
		if(!toEat.instant_application)
			visible_message("<span class='warning'>[user] attempts to force [src] to [toEat.apply_method] [toEat].</span>")
	else
		visible_message("<span class='warning'>[user] cannot force anymore of [toEat] down [src]'s throat.</span>")
		return 0
	if(!toEat.instant_application)
		if(!do_mob(user, src))
			return 0
	visible_message("<span class='warning'>[user] forces [src] to [toEat.apply_method] [toEat].</span>")
	return 1


/*TO DO - If/when stomach organs are introduced, override this at the human level sending the item to the stomach
so that different stomachs can handle things in different ways VB*/
/mob/living/carbon/proc/consume(var/obj/item/reagent_containers/food/toEat, var/bitesize_override, var/can_taste_container = TRUE)
	var/this_bite = bitesize_override ? bitesize_override : toEat.bitesize
	if(!toEat.reagents)
		return
	if(satiety > -200)
		satiety -= toEat.junkiness
	if(toEat.consume_sound)
		playsound(loc, toEat.consume_sound, rand(10,50), 1)
	if(toEat.reagents.total_volume)
		var/fraction = min(this_bite/toEat.reagents.total_volume, 1)
		if(fraction)
			if(can_taste_container)
				taste(toEat.reagents)
				toEat.check_liked(fraction, src)
			toEat.reagents.reaction(src, toEat.apply_type, fraction)
			toEat.reagents.trans_to(src, this_bite*toEat.transfer_efficiency)

/mob/living/carbon/get_access_locations()
	. = ..()
	. |= list(get_active_hand(), get_inactive_hand())

/mob/living/carbon/proc/can_breathe_gas()
	if(NO_BREATHE in src.dna.species.species_traits)
		return FALSE

	if(!wear_mask)
		return TRUE

	if(!(wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT) && internal == null)
		return TRUE

	return FALSE

//to recalculate and update the mob's total tint from tinted equipment it's wearing.
/mob/living/carbon/proc/update_tint()
	if(!GLOB.tinted_weldhelh)
		return
	var/tinttotal = get_total_tint()
	if(tinttotal >= TINT_BLIND)
		overlay_fullscreen("tint", /obj/screen/fullscreen/blind)
	else if(tinttotal >= TINT_IMPAIR)
		overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, 2)
	else
		clear_fullscreen("tint", 0)

/mob/living/carbon/proc/get_total_tint()
	. = 0
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = head
		. += HT.tint
	if(wear_mask)
		. += wear_mask.tint

/mob/living/carbon/human/get_total_tint()
	. = ..()
	if(glasses)
		var/obj/item/clothing/glasses/G = glasses
		. += G.tint


//handle stuff to update when a mob equips/unequips a mask.
/mob/living/proc/wear_mask_update(obj/item/clothing/C, toggle_off = 1)
	update_inv_wear_mask()

/mob/living/carbon/wear_mask_update(obj/item/clothing/C, toggle_off = 1)
	if(C.tint || initial(C.tint))
		update_tint()
	update_inv_wear_mask()

//handle stuff to update when a mob equips/unequips a headgear.
/mob/living/carbon/proc/head_update(obj/item/I, forced)
	if(istype(I, /obj/item/clothing))
		var/obj/item/clothing/C = I
		if(C.tint || initial(C.tint))
			update_tint()
		update_sight()
	if(I.flags_inv & HIDEMASK || forced)
		update_inv_wear_mask()
	update_inv_head()

/mob/living/carbon/proc/shock_internal_organs(intensity)
	for(var/obj/item/organ/O in internal_organs)
		O.shock_organ(intensity)

/mob/living/carbon/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)

	for(var/obj/item/organ/internal/cyberimp/eyes/E in internal_organs)
		sight |= E.vision_flags
		if(E.see_in_dark)
			see_in_dark = max(see_in_dark, E.see_in_dark)
		if(E.see_invisible)
			see_invisible = min(see_invisible, E.see_invisible)
		if(!isnull(E.lighting_alpha))
			lighting_alpha = min(lighting_alpha, E.lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(XRAY in mutations)
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/living/carbon/ExtinguishMob()
	for(var/X in get_equipped_items())
		var/obj/item/I = X
		I.acid_level = 0 //washes off the acid on our clothes
		I.extinguish() //extinguishes our clothes
	..()

/mob/living/carbon/clean_blood(clean_hands = TRUE, clean_mask = TRUE, clean_feet = TRUE)
	if(head)
		if(head.clean_blood())
			update_inv_head()
		if(head.flags_inv & HIDEMASK)
			clean_mask = FALSE
	if(wear_suit)
		if(wear_suit.clean_blood())
			update_inv_wear_suit()
		if(wear_suit.flags_inv & HIDESHOES)
			clean_feet = FALSE
		if(wear_suit.flags_inv & HIDEGLOVES)
			clean_hands = FALSE
	..(clean_hands, clean_mask, clean_feet)
