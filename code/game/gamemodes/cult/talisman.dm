/obj/item/paper/talisman
	icon = 'icons/obj/paper.dmi'
	icon_state = "paper_talisman"
	var/cultist_name = "talisman"
	var/cultist_desc = "A basic talisman. It serves no purpose."
	var/invocation = "Naise meam!"
	info = "<center><img src='talisman.png'></center><br/><br/>"
	var/uses = 1
	var/health_cost = 0 //The amount of health taken from the user when invoking the talisman

/obj/item/paper/talisman/update_icon()//overriding this so the update_icon doesn't turn them into normal looking paper
	SEND_SIGNAL(src, COMSIG_OBJ_UPDATE_ICON)

/obj/item/paper/talisman/examine(mob/user)
	. = ..()
	if(iscultist(user) || user.stat == DEAD)
		. += "<b>Name:</b> [cultist_name]"
		. += "<b>Effect:</b> [cultist_desc]"
		. += "<b>Uses Remaining:</b> [uses]"
	else
		. += "You see strange symbols on the paper. Are they supposed to mean something?"

/obj/item/paper/talisman/attack_self(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "You see strange symbols on the paper. Are they supposed to mean something?")
		return
	if(invoke(user))
		uses--
	if(uses <= 0)
		user.drop_item()
		qdel(src)

/obj/item/paper/talisman/proc/invoke(mob/living/user, successfuluse = 1)
	. = successfuluse
	if(successfuluse) //if the calling whatever says we succeed, do the fancy stuff
		if(invocation)
			user.whisper(invocation)
		if(health_cost && iscarbon(user))
			var/mob/living/carbon/C = user
			C.apply_damage(health_cost, BRUTE, pick("l_arm", "r_arm"))

//Malformed Talisman: If something goes wrong.
/obj/item/paper/talisman/malformed
	cultist_name = "malformed talisman"
	cultist_desc = "A talisman with gibberish scrawlings. No good can come from invoking this."
	invocation = "Ra'sha yoka!"

/obj/item/paper/talisman/malformed/invoke(mob/living/user, successfuluse = 1)
	to_chat(user, "<span class='cultitalic'>You feel a pain in your head. [SSticker.cultdat.entity_title3] is displeased.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(10, BRUTE, "head")

//Supply Talisman: Has a few unique effects. Granted only to starter cultists.
/obj/item/paper/talisman/supply
	cultist_name = "Supply Talisman"
	icon_state = "supply"
	cultist_desc = "A multi-use talisman that can create various objects. Intended to increase the cult's strength early on."
	invocation = null
	uses = 3

/obj/item/paper/talisman/supply/invoke(mob/living/user, successfuluse = 1)
	var/dat = list()
	dat += "<B>There are [uses] bloody runes on the parchment.</B><BR>"
	dat += "Please choose the chant to be imbued into the fabric of reality.<BR>"
	dat += "<HR>"
	dat += "<A href='?src=[UID()];rune=newtome'>N'ath reth sh'yro eth d'raggathnor!</A> - Summons an arcane tome, used to scribe runes and communicate with other cultists.<BR>"
	dat += "<A href='?src=[UID()];rune=metal'>Bar'tea eas!</A> - Provides 5 runed metal.<BR>"
	dat += "<A href='?src=[UID()];rune=teleport'>Sas'so c'arta forbici!</A> - Allows you to move to a selected teleportation rune.<BR>"
	dat += "<A href='?src=[UID()];rune=emp'>Ta'gh fara'qha fel d'amar det!</A> - Allows you to destroy technology in a short range.<BR>"
	dat += "<A href='?src=[UID()];rune=runestun'>Fuu ma'jin!</A> - Allows you to stun a person by attacking them with the talisman.<BR>"
	dat += "<A href='?src=[UID()];rune=veiling'>Kla'atu barada nikt'o!</A> - Two use talisman, first use makes all nearby runes invisible, second use reveals nearby hidden runes.<BR>"
	dat += "<A href='?src=[UID()];rune=soulstone'>Kal'om neth!</A> - Summons a soul stone, used to capture the spirits of dead or dying humans.<BR>"
	dat += "<A href='?src=[UID()];rune=construct'>Daa'ig osk!</A> - Summons a construct shell for use with soulstone-captured souls. It is too large to carry on your person.<BR>"
	var/datum/browser/popup = new(user, "talisman", "", 400, 400)
	popup.set_content(jointext(dat, ""))
	popup.open()
	return 0

/obj/item/paper/talisman/supply/Topic(href, href_list)
	if(src)
		if(usr.stat || usr.restrained() || !in_range(src, usr))
			return
		if(href_list["rune"])
			switch(href_list["rune"])
				if("newtome")
					var/obj/item/tome/T = new(usr)
					usr.put_in_hands(T)
				if("metal")
					if(istype(src, /obj/item/paper/talisman/supply/weak))
						usr.visible_message("<span class='cultitalic'>Lesser supply talismans lack the strength to materialize runed metal!</span>")
						return
					var/obj/item/stack/sheet/runed_metal/R = new(usr,5)
					usr.put_in_hands(R)
				if("teleport")
					var/obj/item/paper/talisman/teleport/T = new(usr)
					usr.put_in_hands(T)
				if("emp")
					var/obj/item/paper/talisman/emp/T = new(usr)
					usr.put_in_hands(T)
				if("runestun")
					var/obj/item/paper/talisman/stun/T = new(usr)
					usr.put_in_hands(T)
				if("soulstone")
					var/obj/item/soulstone/T = new(usr)
					usr.put_in_hands(T)
				if("construct")
					new /obj/structure/constructshell(get_turf(usr))
				if("veiling")
					var/obj/item/paper/talisman/true_sight/T = new(usr)
					usr.put_in_hands(T)
			uses--
			if(uses <= 0)
				if(iscarbon(usr))
					var/mob/living/carbon/C = usr
					C.drop_item()
					visible_message("<span class='warning'>[src] crumbles to dust.</span>")
				qdel(src)

/obj/item/paper/talisman/supply/weak
	uses = 2

//Rite of Translocation: Same as rune
/obj/item/paper/talisman/teleport
	cultist_name = "Talisman of Teleportation"
	icon_state = "teleport"
	cultist_desc = "A single-use talisman that will teleport a user to a random rune of the same keyword."
	invocation = "Sas'so c'arta forbici!"
	health_cost = 5

/obj/item/paper/talisman/teleport/invoke(mob/living/user, successfuluse = 1)
	var/list/potential_runes = list()
	var/list/teleportnames = list()
	var/list/duplicaterunecount = list()
	for(var/R in teleport_runes)
		var/obj/effect/rune/teleport/T = R
		var/resultkey = T.listkey
		if(resultkey in teleportnames)
			duplicaterunecount[resultkey]++
			resultkey = "[resultkey] ([duplicaterunecount[resultkey]])"
		else
			teleportnames.Add(resultkey)
			duplicaterunecount[resultkey] = 1
		potential_runes[resultkey] = T

	if(!potential_runes.len)
		to_chat(user, "<span class='warning'>There are no valid runes to teleport to!</span>")
		log_game("Teleport talisman failed - no other teleport runes")
		return ..(user, 0)

	if(!is_level_reachable(user.z))
		to_chat(user, "<span class='cultitalic'>You are not in the right dimension!</span>")
		log_game("Teleport talisman failed - user in away mission")
		return ..(user, 0)

	var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes //we know what key they picked
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(!src || QDELETED(src) || !user || user.l_hand != src && user.r_hand != src || user.incapacitated() || !actual_selected_rune)
		return ..(user, 0)

	user.visible_message("<span class='warning'>Dust flows from [user]'s hand, and [user.p_they()] disappear[user.p_s()] in a flash of red light!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman and find yourself somewhere else!</span>")
	user.forceMove(get_turf(actual_selected_rune))
	return ..()


/obj/item/paper/talisman/summon_tome
	cultist_name = "Talisman of Tome Summoning"
	icon_state = "tome"
	cultist_desc = "A one-use talisman that will call an untranslated tome from the archives of a cult."
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	health_cost = 1

/obj/item/paper/talisman/summon_tome/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>[user]'s hand glows red for a moment.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman!</span>")
	new /obj/item/tome(get_turf(user))
	user.visible_message("<span class='warning'>A tome appears at [user]'s feet!</span>", \
			 "<span class='cultitalic'>An arcane tome materializes at your feet.</span>")

/obj/item/paper/talisman/true_sight
	cultist_name = "Talisman of Veiling"
	icon_state = "veil"
	cultist_desc = "A multi-use talisman that hides nearby runes. On its second use, will reveal nearby runes."
	invocation = "Kla'atu barada nikt'o!"
	health_cost = 1
	uses = 2
	var/revealing = FALSE //if it reveals or not

/obj/item/paper/talisman/true_sight/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	if(!revealing)
		user.visible_message("<span class='warning'>Thin grey dust falls from [user]'s hand!</span>", \
			"<span class='cultitalic'>You speak the words of the talisman, hiding nearby runes.</span>")
		invocation = "Nikt'o barada kla'atu!"
		revealing = TRUE
		for(var/obj/effect/rune/R in range(3,user))
			R.talismanhide()
	else
		user.visible_message("<span class='warning'>A flash of light shines from [user]'s hand!</span>", \
			 "<span class='cultitalic'>You speak the words of the talisman, revealing nearby runes.</span>")
		for(var/obj/effect/rune/R in range(3,user))
			R.talismanreveal()

//Rite of False Truths: Same as rune
/obj/item/paper/talisman/make_runes_fake
	cultist_name = "Talisman of Disguising"
	icon_state = "disguising"
	cultist_desc = "A talisman that will make nearby runes appear fake."
	invocation = "By'o nar'nar!"

/obj/item/paper/talisman/make_runes_fake/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>Dust flows from [user]s hand.</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, making nearby runes appear fake.</span>")
	for(var/obj/effect/rune/R in orange(6,user))
		R.talismanfake()
		R.desc = "A rune drawn in crayon."


//Rite of Disruption: Weaker than rune
/obj/item/paper/talisman/emp
	cultist_name = "Talisman of Electromagnetic Pulse"
	icon_state = "emp"
	cultist_desc = "A talisman that will cause a moderately-sized electromagnetic pulse."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	health_cost = 5

/obj/item/paper/talisman/emp/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	user.visible_message("<span class='warning'>[user]'s hand flashes a bright blue!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, emitting an EMP blast.</span>")
	empulse(src, 4, 8, 1)


//Rite of Disorientation: Stuns and inhibit speech on a single target for quite some time
/obj/item/paper/talisman/stun
	cultist_name = "Talisman of Stunning"
	icon_state = "stunning"
	cultist_desc = "A talisman that will stun and inhibit speech on a single target. To use, attack target directly."
	invocation = "Dream sign:Evil sealing talisman!"
	health_cost = 10

/obj/item/paper/talisman/stun/invoke(mob/living/user, successfuluse = 0)
	if(successfuluse) //if we're forced to be successful(we normally aren't) then do the normal stuff
		return ..()
	if(iscultist(user))
		to_chat(user, "<span class='warning'>To use this talisman, attack the target directly.</span>")
	else
		to_chat(user, "You see strange symbols on the paper. Are they supposed to mean something?")
	return 0

/obj/item/paper/talisman/stun/attack(mob/living/target, mob/living/user, successfuluse = 1)
	if(iscultist(user))
		invoke(user, 1)
		user.visible_message("<span class='warning'>[user] holds up [src], which explodes in a flash of red light!</span>", \
							 "<span class='cultitalic'>You stun [target] with the talisman!</span>")
		var/obj/item/nullrod/N = locate() in target
		if(N)
			target.visible_message("<span class='warning'>[target]'s holy weapon absorbs the talisman's light!</span>", \
								   "<span class='userdanger'>Your holy weapon absorbs the blinding light!</span>")
		else
			add_attack_logs(user, target, "Stunned with a talisman")
			target.Weaken(10)
			target.Stun(10)
			target.flash_eyes(1,1)
			if(issilicon(target))
				var/mob/living/silicon/S = target
				S.emp_act(1)
			if(iscarbon(target))
				var/mob/living/carbon/C = target
				C.AdjustSilence(5)
				C.AdjustStuttering(15)
				C.AdjustCultSlur(20)
				C.Jitter(15)
		user.drop_item()
		qdel(src)
		return
	..()


//Rite of Arming: Equips cultist armor on the user, where available
/obj/item/paper/talisman/armor
	cultist_name = "Talisman of Arming"
	icon_state = "arming"
	cultist_desc = "A talisman that will equip the invoker with cultist equipment if there is a slot to equip it to."
	invocation = "N'ath reth sh'yro eth draggathnor!"

/obj/item/paper/talisman/armor/invoke(mob/living/user, successfuluse = 1)
	. = ..()
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='warning'>Otherworldly armor suddenly appears on [user]!</span>", \
						 "<span class='cultitalic'>You speak the words of the talisman, arming yourself!</span>")

	H.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/cultrobes/alt(user), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/storage/backpack/cultpack(user), slot_back)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), slot_shoes)
	H.put_in_hands(new /obj/item/melee/cultblade(user))
	H.put_in_hands(new /obj/item/restraints/legcuffs/bola/cult(user))

/obj/item/paper/talisman/armor/attack(mob/living/target, mob/living/user)
	if(iscultist(user) && iscultist(target))
		user.drop_item()
		qdel(src)
		invoke(target)
		return
	..()


//Talisman of Horrors: Breaks the mind of the victim with nightmarish hallucinations
/obj/item/paper/talisman/horror
	cultist_name = "Talisman of Horrors"
	icon_state = "horror"
	cultist_desc = "A talisman that will break the mind of the victim with nightmarish hallucinations."
	invocation = "Lo'Nab Na'Dm!"

/obj/item/paper/talisman/horror/attack(mob/living/target, mob/living/user)
	if(iscultist(user))
		to_chat(user, "<span class='cultitalic'>You disturb [target] with visions of the end!</span>")
		if(iscarbon(target))
			var/mob/living/carbon/H = target
			H.AdjustHallucinate(30)
		qdel(src)


//Talisman of Fabrication: Creates a construct shell out of 25 metal sheets.
/obj/item/paper/talisman/construction
	cultist_name = "Talisman of Construction"
	icon_state = "construction"
	cultist_desc = "Use this talisman on at least twenty-five metal sheets to create an empty construct shell or on plasteel to make runed metal"
	invocation = "Ethra p'ni dedol!"
	uses = 25

/obj/item/paper/talisman/construction/attack_self(mob/living/user)
	if(iscultist(user))
		to_chat(user, "<span class='warning'>To use this talisman, place it upon a stack of metal sheets or plasteel sheets!.</span>")
	else
		to_chat(user, "<span class='warning'>You see strange symbols on the paper. Are they supposed to mean something?</span>")


/obj/item/paper/talisman/construction/attack(obj/M,mob/living/user)
	if(iscultist(user))
		to_chat(user, "<span class='cultitalic'>This talisman will only work on a stack of metal sheets or plasteel sheets!!</span>")
		log_game("Construct talisman failed - not a valid target")

/obj/item/paper/talisman/construction/afterattack(obj/item/stack/sheet/target, mob/user, proximity_flag, click_parameters)
	..()
	if(proximity_flag && iscultist(user))
		if(istype(target, /obj/item/stack/sheet/metal))
			var/turf/T = get_turf(target)
			if(target.use(25))
				new /obj/structure/constructshell(T)
				to_chat(user, "<span class='warning'>The talisman clings to the metal and twists it into a construct shell!</span>")
				user << sound('sound/magic/staff_chaos.ogg',0,1,25)
				qdel(src)
				return
		if(istype(target, /obj/item/stack/sheet/plasteel))
			var/turf/T = get_turf(target)
			var/quantity = min(target.amount, uses)
			uses -= quantity
			new /obj/item/stack/sheet/runed_metal(T,quantity)
			target.use(quantity)
			to_chat(user, "<span class='warning'>The talisman clings to the plasteel, transforming it into runed metal!</span>")
			user << sound('sound/magic/staff_chaos.ogg',0,1,25)
			invoke(user, 1)
			if(uses <= 0)
				qdel(src)
		else
			to_chat(user, "<span class='warning'>The talisman must be used on metal or plasteel!</span>")

//Talisman of Shackling: Applies special cuffs directly from the talisman
/obj/item/paper/talisman/shackle
	cultist_name = "Talisman of Shackling"
	icon_state = "shackling"
	cultist_desc = "Use this talisman on a victim to handcuff them with dark bindings."
	invocation = "In'totum Lig'abis!"
	uses = 4

/obj/item/paper/talisman/shackle/invoke(mob/living/user, successfuluse = 0)
	if(successfuluse) //if we're forced to be successful(we normally aren't) then do the normal stuff
		return ..()
	if(iscultist(user))
		to_chat(user, "<span class='warning'>To use this talisman, attack the target directly.</span>")
	else
		to_chat(user, "You see strange symbols on the paper. Are they supposed to mean something?")
	return 0

/obj/item/paper/talisman/shackle/attack(mob/living/carbon/target, mob/living/user)
	if(iscultist(user) && istype(target))
		if(target.stat == DEAD)
			user.visible_message("<span class='cultitalic'>This talisman's magic does not affect the dead!</span>")
			return
		CuffAttack(target, user)
		return
	..()

/obj/item/paper/talisman/shackle/proc/CuffAttack(mob/living/carbon/C, mob/living/user)
	if(!C.handcuffed)
		invoke(user, 1)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, 1, -2)
		C.visible_message("<span class='danger'>[user] begins restraining [C] with dark magic!</span>", \
								"<span class='userdanger'>[user] begins shaping a dark magic around your wrists!</span>")
		if(do_mob(user, C, 30))
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/restraints/handcuffs/energy/cult/used(C)
				C.update_handcuffed()
				to_chat(user, "<span class='notice'>You shackle [C].</span>")
				add_attack_logs(user, C, "Handcuffed (shackle talisman)")
				uses--
			else
				to_chat(user, "<span class='warning'>[C] is already bound.</span>")
		else
			to_chat(user, "<span class='warning'>You fail to shackle [C].</span>")
	else
		to_chat(user, "<span class='warning'>[C] is already bound.</span>")
	if(uses <= 0)
		user.drop_item()
		qdel(src)
	return

/obj/item/restraints/handcuffs/energy/cult //For the talisman of shackling
	name = "cult shackles"
	desc = "Shackles that bind the wrists with sinister magic."
	trashtype = /obj/item/restraints/handcuffs/energy/used
	origin_tech = "materials=2;magnets=5"

/obj/item/restraints/handcuffs/energy/used
	desc = "energy discharge"
	flags = DROPDEL

/obj/item/restraints/handcuffs/energy/cult/used/dropped(mob/user)
	user.visible_message("<span class='danger'>[user]'s shackles shatter in a discharge of dark magic!</span>", \
							"<span class='userdanger'>Your [src] shatters in a discharge of dark magic!</span>")
	qdel(src)
	. = ..()
