#define BLOOD_THRESHOLD 3 //How many souls are needed per stage.
#define TRUE_THRESHOLD 7
#define ARCH_THRESHOLD 12

#define BASIC_DEVIL 0
#define BLOOD_LIZARD 1
#define TRUE_DEVIL 2
#define ARCH_DEVIL 3

#define LOSS_PER_DEATH 2

#define SOULVALUE (soulsOwned.len-reviveNumber)

#define DEVILRESURRECTTIME 600

GLOBAL_LIST_EMPTY(allDevils)
GLOBAL_LIST_INIT(lawlorify, list (
		LORE = list(
			OBLIGATION_FOOD = "This devil seems to always offer it's victims food before slaughtering them.",
			OBLIGATION_FIDDLE = "This devil will never turn down a musical challenge.",
			OBLIGATION_DANCEOFF = "This devil will never turn down a dance off.",
			OBLIGATION_GREET = "This devil seems to only be able to converse with people it knows the name of.",
			OBLIGATION_PRESENCEKNOWN = "This devil seems to be unable to attack from stealth.",
			OBLIGATION_SAYNAME = "He will always chant his name upon killing someone.",
			OBLIGATION_ANNOUNCEKILL = "This devil always loudly announces his kills for the world to hear.",
			OBLIGATION_ANSWERTONAME = "This devil always responds to his truename.",
			BANE_SILVER = "Silver seems to gravely injure this devil.",
			BANE_SALT = "Throwing salt at this devil will hinder his ability to use infernal powers temporarily.",
			BANE_LIGHT = "Bright flashes will disorient the devil, likely causing him to flee.",
			BANE_IRON = "Cold iron will slowly injure him, until he can purge it from his system.",
			BANE_WHITECLOTHES = "Wearing clean white clothing will help ward off this devil.",
			BANE_HARVEST = "Presenting the labors of a harvest will disrupt the devil.",
			BANE_TOOLBOX = "That which holds the means of creation also holds the means of the devil's undoing.",
			BAN_HURTWOMAN = "This devil seems to prefer hunting men.",
			BAN_CHAPEL = "This devil avoids holy ground.",
			BAN_HURTPRIEST = "The anointed clergy appear to be immune to his powers.",
			BAN_AVOIDWATER = "The devil seems to have some sort of aversion to water, though it does not appear to harm him.",
			BAN_STRIKEUNCONCIOUS = "This devil only shows interest in those who are awake.",
			BAN_HURTLIZARD = "This devil will not strike an Unathi first.",
			BAN_HURTANIMAL = "This devil avoids hurting animals.",
			BANISH_WATER = "To banish the devil, you must infuse it's body with holy water.",
			BANISH_COFFIN = "This devil will return to life if it's remains are not placed within a coffin.",
			BANISH_FORMALDYHIDE = "To banish the devil, you must inject it's lifeless body with embalming fluid.",
			BANISH_RUNES = "This devil will resurrect after death, unless it's remains are within a rune.",
			BANISH_CANDLES = "A large number of nearby lit candles will prevent it from resurrecting.",
			BANISH_DESTRUCTION = "It's corpse must be utterly destroyed to prevent resurrection.",
			BANISH_FUNERAL_GARB = "If clad in funeral garments, this devil will be unable to resurrect.  Should the clothes not fit, lay them gently on top of the devil's corpse."
		),
		LAW = list(
			OBLIGATION_FOOD = "When not acting in self defense, you must always offer your victim food before harming them.",
			OBLIGATION_FIDDLE = "When not in immediate danger, if you are challenged to a musical duel, you must accept it.  You are not obligated to duel the same person twice.",
			OBLIGATION_DANCEOFF = "When not in immediate danger, if you are challenged to a dance off, you must accept it. You are not obligated to face off with the same person twice.",
			OBLIGATION_GREET = "You must always greet other people by their last name before talking with them.",
			OBLIGATION_PRESENCEKNOWN = "You must always make your presence known before attacking.",
			OBLIGATION_SAYNAME = "You must always say your true name after you kill someone.",
			OBLIGATION_ANNOUNCEKILL = "Upon killing someone, you must make your deed known to all within earshot, over comms if reasonably possible.",
			OBLIGATION_ANSWERTONAME = "If you are not under attack, you must always respond to your true name.",
			BAN_HURTWOMAN = "You must never harm a female outside of self defense.",
			BAN_CHAPEL = "You must never attempt to enter the chapel.",
			BAN_HURTPRIEST = "You must never attack a priest.",
			BAN_AVOIDWATER = "You must never willingly touch a wet surface.",
			BAN_STRIKEUNCONCIOUS = "You must never strike an unconscious person.",
			BAN_HURTLIZARD = "You must never harm an Unathi outside of self defense.",
			BAN_HURTANIMAL = "You must never harm a non-sentient creature or robot outside of self defense.",
			BANE_SILVER = "Silver, in all of it's forms shall be your downfall.",
			BANE_SALT = "Salt will disrupt your magical abilities.",
			BANE_LIGHT = "Blinding lights will prevent you from using offensive powers for a time.",
			BANE_IRON = "Cold wrought iron shall act as poison to you.",
			BANE_WHITECLOTHES = "Those clad in pristine white garments will strike you true.",
			BANE_HARVEST = "The fruits of the harvest shall be your downfall.",
			BANE_TOOLBOX = "Toolboxes are bad news for you, for some reason.",
			BANISH_WATER = "If your corpse is filled with holy water, you will be unable to resurrect.",
			BANISH_COFFIN = "If your corpse is in a coffin, you will be unable to resurrect.",
			BANISH_FORMALDYHIDE = "If your corpse is embalmed, you will be unable to resurrect.",
			BANISH_RUNES = "If your corpse is placed within a rune, you will be unable to resurrect.",
			BANISH_CANDLES = "If your corpse is near lit candles, you will be unable to resurrect.",
			BANISH_DESTRUCTION = "If your corpse is destroyed, you will be unable to resurrect.",
			BANISH_FUNERAL_GARB = "If your corpse is clad in funeral garments, you will be unable to resurrect."
		)
	))

/datum/devilinfo
	var/datum/mind/owner = null
	var/obligation
	var/ban
	var/bane
	var/banish
	var/truename
	var/list/datum/mind/soulsOwned = new
	var/datum/dna/humanform = null
	var/reviveNumber = 0
	var/form = BASIC_DEVIL
	var/exists = 0
	var/static/list/dont_remove_spells = list(
	/obj/effect/proc_holder/spell/targeted/click/summon_contract,
	/obj/effect/proc_holder/spell/targeted/conjure_item/violin,
	/obj/effect/proc_holder/spell/targeted/summon_dancefloor)
	var/ascendable = FALSE

/datum/devilinfo/New()
	..()
	dont_remove_spells = typecacheof(dont_remove_spells)

/proc/randomDevilInfo(name = randomDevilName())
	var/datum/devilinfo/devil = new
	devil.truename = name
	devil.bane = randomdevilbane()
	devil.obligation = randomdevilobligation()
	devil.ban = randomdevilban()
	devil.banish = randomdevilbanish()
	return devil

/proc/devilInfo(name, saveDetails = 0)
	if(GLOB.allDevils[lowertext(name)])
		return GLOB.allDevils[lowertext(name)]
	else
		var/datum/devilinfo/devil = randomDevilInfo(name)
		GLOB.allDevils[lowertext(name)] = devil
		devil.exists = saveDetails
		return devil



/proc/randomDevilName()
	var/preTitle = ""
	var/title = ""
	var/mainName = ""
	var/suffix = ""
	if(prob(65))
		if(prob(35))
			preTitle = pick("Dark ", "Hellish ", "Fiery ", "Sinful ", "Blood ")
		title = pick("Lord ", "Fallen Prelate ", "Count ", "Viscount ", "Vizier ", "Elder ", "Adept ")
	var/probability = 100
	mainName = pick("Hal", "Ve", "Odr", "Neit", "Ci", "Quon", "Mya", "Folth", "Wren", "Gyer", "Geyr", "Hil", "Niet", "Twou", "Hu", "Don")
	while(prob(probability))
		mainName += pick("hal", "ve", "odr", "neit", "ca", "quon", "mya", "folth", "wren", "gyer", "geyr", "hil", "niet", "twoe", "phi", "coa")
		probability -= 20
	if(prob(40))
		suffix = pick(" the Red", " the Soulless", " the Master", ", the Lord of all things", ", Jr.")
	return preTitle + title + mainName + suffix

/proc/randomdevilobligation()
	return pick(OBLIGATION_FOOD, OBLIGATION_FIDDLE, OBLIGATION_DANCEOFF, OBLIGATION_GREET, OBLIGATION_PRESENCEKNOWN, OBLIGATION_SAYNAME, OBLIGATION_ANNOUNCEKILL, OBLIGATION_ANSWERTONAME)

/proc/randomdevilban()
	return pick(BAN_HURTWOMAN, BAN_CHAPEL, BAN_HURTPRIEST, BAN_AVOIDWATER, BAN_STRIKEUNCONCIOUS, BAN_HURTLIZARD, BAN_HURTANIMAL)

/proc/randomdevilbane()
	return pick(BANE_SALT, BANE_LIGHT, BANE_IRON, BANE_WHITECLOTHES, BANE_SILVER, BANE_HARVEST, BANE_TOOLBOX)

/proc/randomdevilbanish()
	return pick(BANISH_WATER, BANISH_COFFIN, BANISH_FORMALDYHIDE, BANISH_RUNES, BANISH_CANDLES, BANISH_DESTRUCTION, BANISH_FUNERAL_GARB)

/datum/devilinfo/proc/link_with_mob(mob/living/L)
	if(istype(L, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = L
		humanform = H.dna.Clone()
	owner = L.mind
	give_base_spells(1)

/datum/devilinfo/proc/add_soul(datum/mind/soul)
	if(soulsOwned.Find(soul))
		return
	soulsOwned += soul
	owner.current.set_nutrition(NUTRITION_LEVEL_FULL)
	to_chat(owner.current, "<span class='warning'>You feel satiated as you received a new soul.</span>")
	update_hud()
	switch(SOULVALUE)
		if(0)
			to_chat(owner.current, "<span class='warning'>Your hellish powers have been restored.</span>")
			give_base_spells()
		if(BLOOD_THRESHOLD)
			to_chat(owner.current, "<span class='warning'>You feel as though your humanoid form is about to shed.  You will soon turn into a blood lizard.</span>")
			sleep(50)
			increase_blood_lizard()
		if(TRUE_THRESHOLD)
			to_chat(owner.current, "<span class='warning'>You feel as though your current form is about to shed.  You will soon turn into a true devil.</span>")
			sleep(50)
			increase_true_devil()
		if(ARCH_THRESHOLD)
			arch_devil_prelude()
			increase_arch_devil()

/datum/devilinfo/proc/remove_soul(datum/mind/soul)
	if(soulsOwned.Remove(soul))
		to_chat(owner.current, "<span class='warning'>You feel as though a soul has slipped from your grasp.</span>")
		check_regression()
		update_hud()

/datum/devilinfo/proc/check_regression()
	if(form == ARCH_DEVIL)
		return //arch devil can't regress
	//Yes, fallthrough behavior is intended, so I can't use a switch statement.
	if(form == TRUE_DEVIL && SOULVALUE < TRUE_THRESHOLD)
		regress_blood_lizard()
	if(form == BLOOD_LIZARD && SOULVALUE < BLOOD_THRESHOLD)
		regress_humanoid()
	if(SOULVALUE < 0)
		remove_spells()
		to_chat(owner.current, "<span class='warning'>As punishment for your failures, all of your powers except contract creation have been revoked.</span>")

/datum/devilinfo/proc/regress_humanoid()
	to_chat(owner.current, "<span class='warning'>Your powers weaken, have more contracts be signed to regain power.</span>")
	if(istype(owner.current, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner.current
		if(humanform)
			H.set_species(humanform.species)
			H.dna = humanform.Clone()
			H.sync_organ_dna(assimilate = 0)
		else
			H.set_species(/datum/species/human)
			// TODO: Add some appearance randomization here or something
			humanform = H.dna.Clone()
		H.regenerate_icons()
	else
		owner.current.color = ""
	give_base_spells()
	if(istype(owner.current.loc, /obj/effect/dummy/slaughter))
		owner.current.forceMove(get_turf(owner.current))//Fixes dying while jaunted leaving you permajaunted.
	form = BASIC_DEVIL

/datum/devilinfo/proc/regress_blood_lizard()
	var/mob/living/carbon/true_devil/D = owner.current
	to_chat(D, "<span class='warning'>Your powers weaken, have more contracts be signed to regain power.</span>")
	D.oldform.loc = D.loc
	owner.transfer_to(D.oldform)
	D.oldform.status_flags &= ~GODMODE
	give_lizard_spells()
	qdel(D)
	form = BLOOD_LIZARD
	update_hud()


/datum/devilinfo/proc/increase_blood_lizard()
	if(ishuman(owner.current))
		var/mob/living/carbon/human/H = owner.current
		var/list/language_temp = H.languages.Copy()
		H.set_species(/datum/species/unathi)
		H.languages = language_temp
		H.underwear = "Nude"
		H.undershirt = "Nude"
		H.socks = "Nude"
		H.change_skin_color(80, 16, 16) //A deep red
		H.regenerate_icons()
	else //Did the devil get hit by a staff of transmutation?
		owner.current.color = "#501010"
	give_lizard_spells()
	form = BLOOD_LIZARD



/datum/devilinfo/proc/increase_true_devil()
	var/mob/living/carbon/true_devil/A = new /mob/living/carbon/true_devil(owner.current.loc, owner.current)
	A.faction |= "hell"
	// Put the old body in stasis
	owner.current.status_flags |= GODMODE
	owner.current.loc = A
	A.oldform = owner.current
	owner.transfer_to(A)
	A.set_name()
	give_true_spells()
	form = TRUE_DEVIL
	update_hud()

/datum/devilinfo/proc/arch_devil_prelude()
	if(!ascendable)
		return
	var/mob/living/carbon/true_devil/D = owner.current
	to_chat(D, "<span class='warning'>You feel as though your form is about to ascend.</span>")
	sleep(50)
	if(!D)
		return
	D.visible_message("<span class='warning'>[D]'s skin begins to erupt with spikes.</span>", \
		"<span class='warning'>Your flesh begins creating a shield around yourself.</span>")
	sleep(100)
	if(!D)
		return
	D.visible_message("<span class='warning'>The horns on [D]'s head slowly grow and elongate.</span>", \
		"<span class='warning'>Your body continues to mutate. Your telepathic abilities grow.</span>")
	sleep(90)
	if(!D)
		return
	D.visible_message("<span class='warning'>[D]'s body begins to violently stretch and contort.</span>", \
		"<span class='warning'>You begin to rend apart the final barriers to ultimate power.</span>")
	sleep(40)
	if(!D)
		return
	to_chat(D, "<span class='sinister'>Yes!</span>")
	sleep(10)
	if(!D)
		return
	to_chat(D, "<span class='big sinister'>YES!!</span>")
	sleep(10)
	if(!D)
		return
	to_chat(D, "<span class='reallybig sinister'>YE--</span>")
	sleep(1)
	if(!D)
		return
	to_chat(world, "<font size=5><span class='danger'>SLOTH, WRATH, GLUTTONY, ACEDIA, ENVY, GREED, PRIDE! FIRES OF HELL AWAKEN!!</span></font>")
	world << 'sound/hallucinations/veryfar_noise.ogg'
	sleep(50)
	if(!SSticker.mode.devil_ascended)
		SSshuttle.emergency.request(null, 0.3)
	SSticker.mode.devil_ascended++

/datum/devilinfo/proc/increase_arch_devil()
	if(!ascendable)
		return
	var/mob/living/carbon/true_devil/D = owner.current
	if(!istype(D))
		return
	give_arch_spells()
	D.convert_to_archdevil()
	if(istype(D.loc, /obj/effect/dummy/slaughter))
		D.forceMove(get_turf(D))
	var/area/A = get_area(owner.current)
	if(A)
		notify_ghosts("An arch devil has ascended in [A.name]. Reach out to the devil to start climbing the infernal corporate ladder.", title = "Arch Devil Ascended", source = owner.current, action = NOTIFY_ATTACK)
	form = ARCH_DEVIL

/datum/devilinfo/proc/remove_spells()
	for(var/X in owner.spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(!is_type_in_typecache(S, dont_remove_spells))
			owner.RemoveSpell(S)

/datum/devilinfo/proc/give_summon_contract()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/summon_contract(null))


/datum/devilinfo/proc/give_base_spells(give_summon_contract = 0)
	remove_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/fireball/hellish(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/pitchfork(null))
	if(give_summon_contract)
		give_summon_contract()
		if(obligation == OBLIGATION_FIDDLE)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/violin(null))
		if(obligation == OBLIGATION_DANCEOFF)
			owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/summon_dancefloor(null))

/datum/devilinfo/proc/give_lizard_spells()
	remove_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/pitchfork(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/fireball/hellish(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/infernal_jaunt(null))

/datum/devilinfo/proc/give_true_spells()
	remove_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/pitchfork/greater(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/click/fireball/hellish(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/infernal_jaunt(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/sintouch(null))

/datum/devilinfo/proc/give_arch_spells()
	remove_spells()
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/conjure_item/pitchfork/ascended(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/sintouch/ascended(null))

/datum/devilinfo/proc/beginResurrectionCheck(mob/living/body)
	if(owner.current != body)
		body = owner.current
	if(SOULVALUE > 0)
		to_chat(owner.current, "<span class='userdanger'>Your body has been damaged to the point that you may no longer use it.  At the cost of some of your power, you will return to life soon.</span>")
		addtimer(CALLBACK(src, "activateResurrection", body), DEVILRESURRECTTIME)
	else
		to_chat(owner.messageable_mob(), "<span class='userdanger'>Your hellish powers are too weak to resurrect yourself.</span>")

/datum/devilinfo/proc/activateResurrection(mob/living/body)
	if(QDELETED(body) ||  body.stat == DEAD)
		if(SOULVALUE > 0)
			if(check_banishment(body))
				to_chat(owner.messageable_mob(), "<span class='userdanger'>Unfortunately, the mortals have finished a ritual that prevents your resurrection.</span>")
				return -1
			else
				to_chat(owner.messageable_mob(), "<span class='userdanger'>WE LIVE AGAIN!</span>")
				return hellish_resurrection(body)
		else
			to_chat(owner.messageable_mob(), "<span class='userdanger'>Unfortunately, the power that stemmed from your contracts has been extinguished.  You no longer have enough power to resurrect.</span>")
			return -1
	else
		to_chat(owner.current, "<span class='danger'>You seem to have resurrected without your hellish powers.</span>")

/datum/devilinfo/proc/check_banishment(mob/living/body)
	switch(banish)
		if(BANISH_WATER)
			if(!QDELETED(body) && iscarbon(body))
				var/mob/living/carbon/H = body
				return H.reagents.has_reagent("holy water")
			return 0
		if(BANISH_COFFIN)
			return (!QDELETED(body) && istype(body.loc, /obj/structure/closet/coffin))
		if(BANISH_FORMALDYHIDE)
			if(!QDELETED(body) && iscarbon(body))
				var/mob/living/carbon/H = body
				return H.reagents.has_reagent("formaldehyde")
			return 0
		if(BANISH_RUNES)
			if(!QDELETED(body))
				for(var/obj/effect/decal/cleanable/crayon/R in range(0,body))
					if (R.name == "rune")
						return 1
			return 0
		if(BANISH_CANDLES)
			if(!QDELETED(body))
				var/count = 0
				for(var/obj/item/candle/C in range(1,body))
					count += C.lit
				if(count>=4)
					return 1
			return 0
		if(BANISH_DESTRUCTION)
			if(!QDELETED(body))
				return 0
			return 1
		if(BANISH_FUNERAL_GARB)
			if(!QDELETED(body) && iscarbon(body))
				var/mob/living/carbon/human/H = body
				if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/burial))
					return 1
				return 0
			else
				for(var/obj/item/clothing/under/burial/B in range(0,body))
					if(B.loc == get_turf(B)) //Make sure it's not in someone's inventory or something.
						return 1
				return 0

/datum/devilinfo/proc/hellish_resurrection(mob/living/body)
	message_admins("[owner.name] (true name is: [truename]) is resurrecting using hellish energy.</a>")
	if(SOULVALUE <= ARCH_THRESHOLD && ascendable) // once ascended, arch devils do not go down in power by any means.
		reviveNumber += LOSS_PER_DEATH
		update_hud()
	if(!QDELETED(body))
		body.revive()
		if(!body.client)
			var/mob/dead/observer/O = owner.get_ghost()
			O.reenter_corpse()
		if(istype(body.loc, /obj/effect/dummy/slaughter))
			body.forceMove(get_turf(body))//Fixes dying while jaunted leaving you permajaunted.
		if(istype(body, /mob/living/carbon/true_devil))
			var/mob/living/carbon/true_devil/D = body
			if(D.oldform)
				D.oldform.revive() // Heal the old body too, so the devil doesn't resurrect, then immediately regress into a dead body.
		if(body.stat == DEAD) // Not sure why this would happen
			create_new_body()
		else if(GLOB.blobstart.len > 0)
			// teleport the body so repeated beatdowns aren't an option)
			body.forceMove(get_turf(pick(GLOB.blobstart)))
			// give them the devil lawyer outfit in case they got stripped
			if(ishuman(body))
				var/mob/living/carbon/human/H = body
				H.equipOutfit(/datum/outfit/devil_lawyer)
	else
		create_new_body()
	check_regression()

/datum/devilinfo/proc/create_new_body()
	if(GLOB.blobstart.len > 0)
		var/turf/targetturf = get_turf(pick(GLOB.blobstart))
		var/mob/currentMob = owner.current
		if(QDELETED(currentMob))
			currentMob = owner.get_ghost()
			if(!currentMob)
				message_admins("[owner.name]'s devil resurrection failed due to client logoff.  Aborting.")
				return -1
			if(currentMob.mind != owner)
				message_admins("[owner.name]'s devil resurrection failed due to becoming a new mob.  Aborting.")
				return -1
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(targetturf)
		owner.transfer_to(H)
		if(isobserver(currentMob))
			var/mob/dead/observer/O = currentMob
			O.reenter_corpse()
		if(humanform)
			H.set_species(humanform.species)
			H.dna = humanform.Clone()

			H.dna.UpdateSE()
			H.dna.UpdateUI()

			H.sync_organ_dna(1) // It's literally a fresh body as you can get, so all organs properly belong to it
			H.UpdateAppearance()
		else
			// gibbed cyborg or similar - create a randomized "humanform" appearance
			H.scramble_appearance()
			humanform = H.dna.Clone()


		H.equipOutfit(/datum/outfit/devil_lawyer)
		give_base_spells(TRUE)
		if(SOULVALUE >= BLOOD_THRESHOLD)
			increase_blood_lizard()
			if(SOULVALUE >= TRUE_THRESHOLD) //Yes, BOTH this and the above if statement are to run if soulpower is high enough.
				increase_true_devil()
				if(SOULVALUE >= ARCH_THRESHOLD && ascendable)
					increase_arch_devil()
	else
		throw EXCEPTION("Unable to find a blobstart landmark for hellish resurrection")

/datum/devilinfo/proc/update_hud()
	if(istype(owner.current, /mob/living/carbon))
		var/mob/living/C = owner.current
		if(C.hud_used && C.hud_used.devilsouldisplay)
			C.hud_used.devilsouldisplay.update_counter(SOULVALUE)

// SECTION: Messages and explanations

/datum/devilinfo/proc/announce_laws(mob/living/owner)
	to_chat(owner, "<span class='boldwarning'>You remember your link to the infernal.  You are [truename], an agent of hell, a devil.  And you were sent to the plane of creation for a reason.  A greater purpose.  Convince the crew to sin, and embroiden Hell's grasp.</span>")
	to_chat(owner, "<span class='boldwarning'>However, your infernal form is not without weaknesses.</span>")
	to_chat(owner, "You may not use violence to coerce someone into selling their soul.")
	to_chat(owner, "You may not directly and knowingly physically harm a devil, other than yourself.")
	to_chat(owner,GLOB.lawlorify[LAW][bane])
	to_chat(owner,GLOB.lawlorify[LAW][ban])
	to_chat(owner,GLOB.lawlorify[LAW][obligation])
	to_chat(owner,GLOB.lawlorify[LAW][banish])
	to_chat(owner, "<br/><br/><span class='warning'>Remember, the crew can research your weaknesses if they find out your devil name.</span><br>")


#undef BLOOD_THRESHOLD
#undef TRUE_THRESHOLD
#undef ARCH_THRESHOLD
#undef BASIC_DEVIL
#undef BLOOD_LIZARD
#undef TRUE_DEVIL
#undef ARCH_DEVIL
#undef LOSS_PER_DEATH
#undef SOULVALUE
#undef DEVILRESURRECTTIME

/datum/outfit/devil_lawyer
	name = "Devil Lawyer"
	uniform = /obj/item/clothing/under/lawyer/black
	shoes = /obj/item/clothing/shoes/laceup
	back = /obj/item/storage/backpack
	l_hand = /obj/item/storage/briefcase
	l_pocket = /obj/item/pen
	l_ear = /obj/item/radio/headset

	id = /obj/item/card/id

/datum/outfit/devil_lawyer/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/card/id/W = H.wear_id
	if(!istype(W) || W.assignment) // either doesn't have a card, or the card is already written to
		return
	var/name_to_use = H.real_name
	if(H.mind && H.mind.devilinfo)
		// Having hell create an ID for you causes its risks
		name_to_use = H.mind.devilinfo.truename

	W.name = "[name_to_use]'s ID Card (Lawyer)"
	W.registered_name = name_to_use
	W.assignment = "Lawyer"
	W.rank = W.assignment
	W.age = H.age
	W.sex = capitalize(H.gender)
	W.access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS)
	W.photo = get_id_photo(H)
