/datum/spellbook_entry
	var/name = "Entry Name"

	var/spell_type = null
	var/desc = ""
	var/category = "Offensive"
	var/log_name = "XX" //What it shows up as in logs
	var/cost = 2
	var/refundable = 1
	var/surplus = -1 // -1 for infinite, not used by anything atm
	var/obj/effect/proc_holder/spell/S = null //Since spellbooks can be used by only one person anyway we can track the actual spell
	var/buy_word = "Learn"
	var/limit //used to prevent a spellbook_entry from being bought more than X times with one wizard spellbook

/datum/spellbook_entry/proc/IsSpellAvailable() // For config prefs / gamemode restrictions - these are round applied
	return 1

/datum/spellbook_entry/proc/CanBuy(mob/living/carbon/human/user, obj/item/spellbook/book) // Specific circumstances
	if(book.uses<cost || limit == 0)
		return 0
	return 1

/datum/spellbook_entry/proc/Buy(mob/living/carbon/human/user, obj/item/spellbook/book) //return 1 on success
	if(!S)
		S = new spell_type()

	//Check if we got the spell already
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name)) // Not using directly in case it was learned from one spellbook then upgraded in another
			if(aspell.spell_level >= aspell.level_max)
				to_chat(user, "<span class='warning'>This spell cannot be improved further.</span>")
				return 0
			else
				aspell.name = initial(aspell.name)
				aspell.spell_level++
				aspell.charge_max = round(initial(aspell.charge_max) - aspell.spell_level * (initial(aspell.charge_max) - aspell.cooldown_min)/ aspell.level_max)
				if(aspell.charge_max < aspell.charge_counter)
					aspell.charge_counter = aspell.charge_max
				switch(aspell.spell_level)
					if(1)
						to_chat(user, "<span class='notice'>You have improved [aspell.name] into Efficient [aspell.name].</span>")
						aspell.name = "Efficient [aspell.name]"
					if(2)
						to_chat(user, "<span class='notice'>You have further improved [aspell.name] into Quickened [aspell.name].</span>")
						aspell.name = "Quickened [aspell.name]"
					if(3)
						to_chat(user, "<span class='notice'>You have further improved [aspell.name] into Free [aspell.name].</span>")
						aspell.name = "Free [aspell.name]"
					if(4)
						to_chat(user, "<span class='notice'>You have further improved [aspell.name] into Instant [aspell.name].</span>")
						aspell.name = "Instant [aspell.name]"
				if(aspell.spell_level >= aspell.level_max)
					to_chat(user, "<span class='notice'>This spell cannot be strengthened any further.</span>")
				return 1
	//No same spell found - just learn it
	feedback_add_details("wizard_spell_learned",log_name)
	user.mind.AddSpell(S)
	to_chat(user, "<span class='notice'>You have learned [S.name].</span>")
	return 1

/datum/spellbook_entry/proc/CanRefund(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(!refundable)
		return 0
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			return 1
	return 0

/datum/spellbook_entry/proc/Refund(mob/living/carbon/human/user, obj/item/spellbook/book) //return point value or -1 for failure
	var/area/wizard_station/A = locate()
	if(!(user in A.contents))
		to_chat(user, "<span clas=='warning'>You can only refund spells at the wizard lair</span>")
		return -1
	if(!S)
		S = new spell_type()
	var/spell_levels = 0
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			spell_levels = aspell.spell_level
			user.mind.spell_list.Remove(aspell)
			QDEL_NULL(S)
			return cost * (spell_levels+1)
	return -1

/datum/spellbook_entry/proc/GetInfo()
	if(!S)
		S = new spell_type()
	var/dat =""
	dat += "<b>[initial(S.name)]</b>"
	if(S.charge_type == "recharge")
		dat += " Cooldown:[S.charge_max/10]"
	dat += " Cost:[cost]<br>"
	dat += "<i>[S.desc][desc]</i><br>"
	dat += "[S.clothes_req?"Needs wizard garb":"Can be cast without wizard garb"]<br>"
	return dat

//Main category - Spells
//Offensive
/datum/spellbook_entry/blind
	name = "Blind"
	spell_type = /obj/effect/proc_holder/spell/targeted/trigger/blind
	log_name = "BD"
	category = "Offensive"
	cost = 1

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	spell_type = /obj/effect/proc_holder/spell/targeted/lightning
	log_name = "LB"
	category = "Offensive"
	cost = 1

/datum/spellbook_entry/cluwne
	name = "Curse of the Cluwne"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/cluwne
	log_name = "CC"
	category = "Offensive"

/datum/spellbook_entry/banana_touch
	name = "Banana Touch"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/banana
	log_name = "BT"
	cost = 1

/datum/spellbook_entry/mime_malaise
	name = "Mime Malaise"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/mime_malaise
	log_name = "MI"
	cost = 1

/datum/spellbook_entry/horseman
	name = "Curse of the Horseman"
	spell_type = /obj/effect/proc_holder/spell/targeted/horsemask
	log_name = "HH"
	category = "Offensive"

/datum/spellbook_entry/disintegrate
	name = "Disintegrate"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/disintegrate
	log_name = "DG"
	category = "Offensive"

/datum/spellbook_entry/fireball
	name = "Fireball"
	spell_type = /obj/effect/proc_holder/spell/fireball
	log_name = "FB"
	category = "Offensive"

/datum/spellbook_entry/fleshtostone
	name = "Flesh to Stone"
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/flesh_to_stone
	log_name = "FS"
	category = "Offensive"

/datum/spellbook_entry/mutate
	name = "Mutate"
	spell_type = /obj/effect/proc_holder/spell/targeted/genetic/mutate
	log_name = "MU"
	category = "Offensive"

/datum/spellbook_entry/rod_form
	name = "Rod Form"
	spell_type = /obj/effect/proc_holder/spell/targeted/rod_form
	log_name = "RF"
	category = "Offensive"

/datum/spellbook_entry/infinite_guns
	name = "Lesser Summon Guns"
	spell_type = /obj/effect/proc_holder/spell/targeted/infinite_guns
	log_name = "IG"
	category = "Offensive"
	cost = 4

//Defensive
/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	spell_type = /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	log_name = "DT"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	spell_type = /obj/effect/proc_holder/spell/targeted/forcewall
	log_name = "FW"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/greaterforcewall
	name = "Greater Force Wall"
	spell_type = /obj/effect/proc_holder/spell/targeted/forcewall/greater
	log_name = "GFW"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/repulse
	name = "Repulse"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/repulse
	log_name = "RP"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/smoke
	name = "Smoke"
	spell_type = /obj/effect/proc_holder/spell/targeted/smoke
	log_name = "SM"
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	spell_type = /obj/effect/proc_holder/spell/targeted/lichdom
	log_name = "LD"
	category = "Defensive"

/datum/spellbook_entry/lichdom/IsSpellAvailable()
	if(SSticker.mode.name == "ragin' mages")
		return FALSE
	else
		return TRUE

/datum/spellbook_entry/magicm
	name = "Magic Missile"
	spell_type = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	log_name = "MM"
	category = "Defensive"

/datum/spellbook_entry/timestop
	name = "Time Stop"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop
	log_name = "TS"
	category = "Defensive"

//Mobility
/datum/spellbook_entry/knock
	name = "Knock"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/knock
	log_name = "KN"
	category = "Mobility"
	cost = 1

/datum/spellbook_entry/blink
	name = "Blink"
	spell_type = /obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	log_name = "BL"
	category = "Mobility"

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	spell_type = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	log_name = "EJ"
	category = "Mobility"

/datum/spellbook_entry/greaterknock
	name = "Greater Knock"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/knock/greater
	log_name = "GK"
	category = "Mobility"
	refundable = 0 //global effect on cast

/datum/spellbook_entry/mindswap
	name = "Mindswap"
	spell_type = /obj/effect/proc_holder/spell/targeted/mind_transfer
	log_name = "MT"
	category = "Mobility"

/datum/spellbook_entry/teleport
	name = "Teleport"
	spell_type = /obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	log_name = "TP"
	category = "Mobility"

//Assistance
/datum/spellbook_entry/charge
	name = "Charge"
	spell_type = /obj/effect/proc_holder/spell/targeted/charge
	log_name = "CH"
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/summonitem
	name = "Summon Item"
	spell_type = /obj/effect/proc_holder/spell/targeted/summonitem
	log_name = "IS"
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/noclothes
	name = "Remove Clothes Requirement"
	spell_type = /obj/effect/proc_holder/spell/noclothes
	log_name = "NC"
	category = "Assistance"

//Rituals
/datum/spellbook_entry/summon
	name = "Summon Stuff"
	category = "Rituals"
	refundable = FALSE
	buy_word = "Cast"
	var/active = FALSE

/datum/spellbook_entry/summon/CanBuy(mob/living/carbon/human/user, obj/item/spellbook/book)
	return ..() && !active

/datum/spellbook_entry/summon/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	if(cost>0)
		dat += " Cost:[cost]<br>"
	else
		dat += " No Cost<br>"
	dat += "<i>[desc]</i><br>"
	if(active)
		dat += "<b>Already cast!</b><br>"
	return dat

/datum/spellbook_entry/summon/ghosts
	name = "Summon Ghosts"
	desc = "Spook the crew out by making them see dead people. Be warned, ghosts are capricious and occasionally vindicative, and some will use their incredibly minor abilities to frustrate you."
	cost = 0
	log_name = "SGH"

/datum/spellbook_entry/summon/ghosts/IsSpellAvailable()
	if(!SSticker.mode) // In case spellbook is placed on map
		return FALSE
	if(SSticker.mode.name == "ragin' mages")
		return FALSE
	else
		return TRUE

/datum/spellbook_entry/summon/ghosts/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	new /datum/event/wizard/ghost()
	active = TRUE
	to_chat(user, "<span class='notice'>You have cast summon ghosts!</span>")
	playsound(get_turf(user), 'sound/effects/ghost2.ogg', 50, 1)
	return TRUE

/datum/spellbook_entry/summon/guns
	name = "Summon Guns"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill you. There is a good chance that they will shoot each other first."
	log_name = "SG"

/datum/spellbook_entry/summon/guns/IsSpellAvailable()
	if(!SSticker.mode) // In case spellbook is placed on map
		return FALSE
	if(SSticker.mode.name == "ragin' mages")
		return FALSE
	else
		return TRUE

/datum/spellbook_entry/summon/guns/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	feedback_add_details("wizard_spell_learned", log_name)
	rightandwrong(SUMMON_GUNS, user, 10)
	active = TRUE
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>You have cast summon guns!</span>")
	return TRUE

/datum/spellbook_entry/summon/magic
	name = "Summon Magic"
	desc = "Share the wonders of magic with the crew and show them why they aren't to be trusted with it at the same time."
	log_name = "SU"

/datum/spellbook_entry/summon/magic/IsSpellAvailable()
	if(!SSticker.mode) // In case spellbook is placed on map
		return FALSE
	if(SSticker.mode.name == "ragin' mages")
		return FALSE
	else
		return TRUE

/datum/spellbook_entry/summon/magic/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	feedback_add_details("wizard_spell_learned", log_name)
	rightandwrong(SUMMON_MAGIC, user, 10)
	active = TRUE
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>You have cast summon magic!</span>")
	return TRUE

//Main category - Magical Items
/datum/spellbook_entry/item
	name = "Buy Item"
	refundable = 0
	buy_word = "Summon"
	var/item_path = null

/datum/spellbook_entry/item/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	user.put_in_hands(new item_path)
	feedback_add_details("wizard_spell_learned", log_name)
	return 1

/datum/spellbook_entry/item/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	dat += " Cost:[cost]<br>"
	dat += "<i>[desc]</i><br>"
	if(surplus>=0)
		dat += "[surplus] left.<br>"
	return dat

//Artefacts
/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "A Necromantic stone is able to resurrect three dead individuals as skeletal thralls for you to command."
	item_path = /obj/item/necromantic_stone
	log_name = "NS"
	category = "Artefacts"

/datum/spellbook_entry/item/scryingorb
	name = "Scrying Orb"
	desc = "An incandescent orb of crackling energy, using it will allow you to ghost while alive, allowing you to spy upon the station with ease. In addition, buying it will permanently grant you x-ray vision."
	item_path = /obj/item/scrying
	log_name = "SO"
	category = "Artefacts"

/datum/spellbook_entry/item/scryingorb/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(..())
		if(!(XRAY in user.mutations))
			user.mutations.Add(XRAY)
			user.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
			user.see_in_dark = 8
			user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			to_chat(user, "<span class='notice'>The walls suddenly disappear.</span>")
	return TRUE

/datum/spellbook_entry/item/soulstones
	name = "Six Soul Stone Shards and the spell Artificer"
	desc = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot."
	item_path = /obj/item/storage/belt/soulstone/full
	log_name = "SS"
	category = "Artefacts"

/datum/spellbook_entry/item/soulstones/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	. = ..()
	if(.)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(null))
	return .

/datum/spellbook_entry/item/wands
	name = "Wand Assortment"
	desc = "A collection of wands that allow for a wide variety of utility. Wands do not recharge, so be conservative in use. Comes in a handy belt."
	item_path = /obj/item/storage/belt/wands/full
	log_name = "WA"
	category = "Artefacts"

//Weapons and Armors
/datum/spellbook_entry/item/battlemage
	name = "Battlemage Armour"
	desc = "An ensorceled suit of armour, protected by a powerful shield. The shield can completely negate sixteen attacks before being permanently depleted."
	item_path = /obj/item/clothing/suit/space/hardsuit/shielded/wizard
	limit = 1
	category = "Weapons and Armors"
	log_name = "BMA"

/datum/spellbook_entry/item/battlemage_charge
	name = "Battlemage Armour Charges"
	desc = "A powerful defensive rune, it will grant eight additional charges to a suit of battlemage armour."
	item_path = /obj/item/wizard_armour_charge
	category = "Weapons and Armors"
	cost = 1
	log_name = "BMAC"

/datum/spellbook_entry/item/mjolnir
	name = "Mjolnir"
	desc = "A mighty hammer on loan from Thor, God of Thunder. It crackles with barely contained power."
	item_path = /obj/item/twohanded/mjollnir
	log_name = "MJ"
	category = "Weapons and Armors"

/datum/spellbook_entry/item/singularity_hammer
	name = "Singularity Hammer"
	desc = "A hammer that creates an intensely powerful field of gravity where it strikes, pulling everthing nearby to the point of impact."
	item_path = /obj/item/twohanded/singularityhammer
	log_name = "SI"
	category = "Weapons and Armors"

//Staves
/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "A particular staff that can mold solid metal into ornate wooden doors. Useful for getting around in the absence of other transportation. Does not work on glass."
	item_path = /obj/item/gun/magic/staff/door
	log_name = "SD"
	category = "Staves"
	cost = 1

/datum/spellbook_entry/item/staffhealing
	name = "Staff of Healing"
	desc = "An altruistic staff that can heal the lame and raise the dead."
	item_path = /obj/item/gun/magic/staff/healing
	log_name = "SH"
	category = "Staves"
	cost = 1

/datum/spellbook_entry/item/staffslipping
	name = "Staff of Slipping"
	desc = "A staff that shoots magical bananas. These bananas will either slip or stun the target when hit. Surprisingly reliable!"
	item_path = /obj/item/gun/magic/staff/slipping
	log_name = "SL"
	category = "Staves"
	cost = 1

/datum/spellbook_entry/item/staffanimation
	name = "Staff of Animation"
	desc = "An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines."
	item_path = /obj/item/gun/magic/staff/animate
	log_name = "SA"
	category = "Staves"

/datum/spellbook_entry/item/staffchange
	name = "Staff of Change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	item_path = /obj/item/gun/magic/staff/change
	log_name = "ST"
	category = "Staves"

/datum/spellbook_entry/item/staffchaos
	name = "Staff of Chaos"
	desc = "A caprious tool that can fire all sorts of magic without any rhyme or reason. Using it on people you care about is not recommended."
	item_path = /obj/item/gun/magic/staff/chaos
	log_name = "SC"
	category = "Staves"

//Summons
/datum/spellbook_entry/item/oozebottle
	name = "Bottle of Ooze"
	desc = "A bottle of magically infused ooze, which will awake an all-consuming Morph, capable of cunningly disguising itself as any object it comes in contact with and even casting some very basic spells. Be careful though, as Morph diet includes Wizards."
	item_path = /obj/item/antag_spawner/morph
	log_name = "BO"
	category = "Summons"
	limit = 3
	cost = 1

/datum/spellbook_entry/item/hugbottle
	name = "Bottle of Tickles"
	desc = "A bottle of magically infused fun, the smell of which will \
		attract adorable extradimensional beings when broken. These beings \
		are similar to slaughter demons, but are a little weaker and they do not permamently \
		kill their victims, instead putting them in an extradimensional hugspace, \
		to be released on the demon's death. Chaotic, but not ultimately \
		damaging. The crew's reaction to the other hand could be very \
		destructive."
	item_path = /obj/item/antag_spawner/slaughter_demon/laughter
	log_name = "HB"
	category = "Summons"
	limit = 3
	cost = 1 // Non-destructive; it's just a jape, sibling!

/datum/spellbook_entry/item/bloodbottle
	name = "Bottle of Blood"
	desc = "A bottle of magically infused blood, the smell of which will attract extradimensional beings when broken. Be careful though, the kinds of creatures summoned by blood magic are indiscriminate in their killing, and you yourself may become a victim."
	item_path = /obj/item/antag_spawner/slaughter_demon
	log_name = "BB"
	category = "Summons"
	limit = 3

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service, using it will summon them to your side."
	item_path = /obj/item/contract
	log_name = "CT"
	category = "Summons"

/datum/spellbook_entry/item/tarotdeck
	name = "Guardian Deck"
	desc = "A deck of guardian tarot cards, capable of binding a personal guardian to your body. There are multiple types of guardian available, but all of them will transfer some amount of damage to you. \
	It would be wise to avoid buying these with anything capable of causing you to swap bodies with others."
	item_path = /obj/item/guardiancreator
	log_name = "TD"
	category = "Summons"
	limit = 1

/obj/item/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state = "spellbook"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/uses = 10
	var/temp = null
	var/op = 1
	var/tab = null
	var/main_tab = null
	var/mob/living/carbon/human/owner
	var/list/datum/spellbook_entry/entries = list()
	var/list/categories = list()
	var/list/main_categories = list("Spells", "Magical Items")
	var/list/spell_categories = list("Offensive", "Defensive", "Mobility", "Assistance", "Rituals")
	var/list/item_categories = list("Artefacts", "Weapons and Armors", "Staves", "Summons")

/obj/item/spellbook/proc/initialize()
	var/entry_types = subtypesof(/datum/spellbook_entry) - /datum/spellbook_entry/item - /datum/spellbook_entry/summon
	for(var/T in entry_types)
		var/datum/spellbook_entry/E = new T
		if(E.IsSpellAvailable())
			entries |= E
			categories |= E.category
		else
			qdel(E)
	main_tab = main_categories[1]
	tab = categories[1]

/obj/item/spellbook/New()
	..()
	initialize()

/obj/item/spellbook/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/contract))
		var/obj/item/contract/contract = O
		if(contract.used)
			to_chat(user, "<span class='warning'>The contract has been used, you can't get your points back now!</span>")
		else
			to_chat(user, "<span class='notice'>You feed the contract back into the spellbook, refunding your points.</span>")
			uses+=2
			qdel(O)
		return

	if(istype(O, /obj/item/antag_spawner/slaughter_demon))
		to_chat(user, "<span class='notice'>On second thought, maybe summoning a demon is a bad idea. You refund your points.</span>")
		if(istype(O, /obj/item/antag_spawner/slaughter_demon/laughter))
			uses += 1
			for(var/datum/spellbook_entry/item/hugbottle/HB in entries)
				if(!isnull(HB.limit))
					HB.limit++
		else
			uses += 2
			for(var/datum/spellbook_entry/item/bloodbottle/BB in entries)
				if(!isnull(BB.limit))
					BB.limit++
		qdel(O)
		return

	if(istype(O, /obj/item/antag_spawner/morph))
		to_chat(user, "<span class='notice'>On second thought, maybe awakening a morph is a bad idea. You refund your points.</span>")
		uses += 1
		for(var/datum/spellbook_entry/item/oozebottle/OB in entries)
			if(!isnull(OB.limit))
				OB.limit++
		qdel(O)
		return
	return ..()

/obj/item/spellbook/proc/GetCategoryHeader(category)
	var/dat = ""
	switch(category)
		if("Offensive")
			dat += "Spells geared towards debilitating and destroying.<BR><BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Defensive")
			dat += "Spells geared towards improving your survivabilty or reducing foes ability to attack.<BR><BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Mobility")
			dat += "Spells geared towards improving your ability to move. It is a good idea to take at least one.<BR><BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Assistance")
			dat += "Spells geared towards improving your other items and abilities.<BR><BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Rituals")
			dat += "These powerful spells are capable of changing the very fabric of reality. Not always in your favour.<BR>"
		if("Weapons and Armors")
			dat += "Various weapons and armors to crush your enemies and protect you from harm.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
		if("Staves")
			dat += "Various staves granting you their power, which they slowly recharge over time.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
		if("Artefacts")
			dat += "Various magical artefacts to aid you.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
		if("Summons")
			dat += "Magical items geared towards bringing in outside forces to aid you.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
	return dat

/obj/item/spellbook/proc/wrap(content)
	var/dat = ""
	dat +="<html><head><title>Spellbook</title></head>"
	dat += {"
	<head>
		<style type="text/css">
      		body { font-size: 80%; font-family: 'Lucida Grande', Verdana, Arial, Sans-Serif; }
      		ul#tabs { list-style-type: none; margin: 10px 0 0 0; padding: 0 0 0.6em 0; }
      		ul#tabs li { display: inline; }
      		ul#tabs li a { color: #42454a; background-color: #dedbde; border: 1px solid #c9c3ba; border-bottom: none; padding: 0.6em; text-decoration: none; }
      		ul#tabs li a:hover { background-color: #f1f0ee; }
      		ul#tabs li a.selected { color: #000; background-color: #f1f0ee; border-bottom: 1px solid #f1f0ee; font-weight: bold; padding: 0.6em 0.6em 0.6em 0.6em; }
			ul#maintabs { list-style-type: none; margin: 30px 0 0 0; padding: 0 0 1em 0; font-size: 14px; }
			ul#maintabs li { display: inline; }
      		ul#maintabs li a { color: #42454a; background-color: #dedbde; border: 1px solid #c9c3ba; padding: 1em; text-decoration: none; }
      		ul#maintabs li a:hover { background-color: #f1f0ee; }
      		ul#maintabs li a.selected { color: #000; background-color: #f1f0ee; font-weight: bold; padding: 1.4em 1.2em 1em 1.2em; }
      		div.tabContent { border: 1px solid #c9c3ba; padding: 0.5em; background-color: #f1f0ee; }
      		div.tabContent.hide { display: none; }
    	</style>
  	</head>
	"}
	dat += {"[content]</body></html>"}
	return dat

/obj/item/spellbook/attack_self(mob/user as mob)
	if(!owner)
		to_chat(user, "<span class='notice'>You bind the spellbook to yourself.</span>")
		owner = user
		return
	if(user != owner)
		to_chat(user, "<span class='warning'>The [name] does not recognize you as it's owner and refuses to open!</span>")
		return
	user.set_machine(src)
	var/dat = ""

	dat += "<ul id=\"maintabs\">"
	var/list/cat_dat = list()
	for(var/main_category in main_categories)
		cat_dat[main_category] = "<hr>"
		dat += "<li><a [main_tab==main_category?"class=selected":""] href='byond://?src=[UID()];mainpage=[main_category]'>[main_category]</a></li>"
	dat += "</ul>"
	switch(main_tab)
		if("Spells")
			dat += "<ul id=\"tabs\">"
			for(var/category in categories)
				if(category in item_categories)
					continue
				cat_dat[category] = "<hr>"
				dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=[UID()];page=[category]'>[category]</a></li>"
			dat += "<li><a><b>Points remaining : [uses]</b></a></li>"
		if("Magical Items")
			dat += "<ul id=\"tabs\">"
			for(var/category in categories)
				if(category in spell_categories)
					continue
				cat_dat[category] = "<hr>"
				dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=[UID()];page=[category]'>[category]</a></li>"
			dat += "<li><a><b>Points remaining : [uses]</b></a></li>"
	dat += "</ul>"

	var/datum/spellbook_entry/E
	for(var/i=1,i<=entries.len,i++)
		var/spell_info = ""
		E = entries[i]
		spell_info += E.GetInfo()
		if(E.CanBuy(user,src))
			spell_info+= "<a href='byond://?src=[UID()];buy=[i]'>[E.buy_word]</A><br>"
		else
			spell_info+= "<span>Can't [E.buy_word]</span><br>"
		if(E.CanRefund(user,src))
			spell_info+= "<a href='byond://?src=[UID()];refund=[i]'>Refund</A><br>"
		spell_info += "<hr>"
		if(cat_dat[E.category])
			cat_dat[E.category] += spell_info

	for(var/category in categories)
		dat += "<div class=\"[tab==category?"tabContent":"tabContent hide"]\" id=\"[category]\">"
		dat += GetCategoryHeader(category)
		dat += cat_dat[category]
		dat += "</div>"

	user << browse(wrap(dat), "window=spellbook;size=800x600")
	onclose(user, "spellbook")
	return

/obj/item/spellbook/Topic(href, href_list)
	if(..())
		return 1
	var/mob/living/carbon/human/H = usr

	if(!ishuman(H))
		return 1

	if(H.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)
		temp = "If you got caught sneaking a peak from your teacher's spellbook, you'd likely be expelled from the Wizard Academy. Better not."
		return 1

	var/datum/spellbook_entry/E = null
	if(loc == H || (in_range(src, H) && istype(loc, /turf)))
		H.set_machine(src)
		if(href_list["buy"])
			E = entries[text2num(href_list["buy"])]
			if(E && E.CanBuy(H,src))
				if(E.Buy(H,src))
					if(E.limit)
						E.limit--
					uses -= E.cost
		else if(href_list["refund"])
			E = entries[text2num(href_list["refund"])]
			if(E && E.refundable)
				var/result = E.Refund(H,src)
				if(result > 0)
					if(!isnull(E.limit))
						E.limit += result
					uses += result
		else if(href_list["mainpage"])
			main_tab = sanitize(href_list["mainpage"])
			tab = sanitize(href_list["page"])
			if(main_tab == "Spells")
				tab = spell_categories[1]
			else if(main_tab == "Magical Items")
				tab = item_categories[1]
		else if(href_list["page"])
			tab = sanitize(href_list["page"])
	attack_self(H)
	return 1

//Single Use Spellbooks
/obj/item/spellbook/oneuse
	var/spell = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile //just a placeholder to avoid runtimes if someone spawned the generic
	var/spellname = "sandbox"
	var/used = 0
	name = "spellbook of "
	uses = 1
	desc = "This template spellbook was never meant for the eyes of man..."

/obj/item/spellbook/oneuse/New()
	..()
	name += spellname

/obj/item/spellbook/oneuse/initialize() //No need to init
	return

/obj/item/spellbook/oneuse/attack_self(mob/user)
	var/obj/effect/proc_holder/spell/S = new spell
	for(var/obj/effect/proc_holder/spell/knownspell in user.mind.spell_list)
		if(knownspell.type == S.type)
			if(user.mind)
				if(user.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE || user.mind.special_role == SPECIAL_ROLE_WIZARD)
					to_chat(user, "<span class='notice'>You're already far more versed in this spell than this flimsy how-to book can provide.</span>")
				else
					to_chat(user, "<span class='notice'>You've already read this one.</span>")
			return
	if(used)
		recoil(user)
	else
		user.mind.AddSpell(S)
		to_chat(user, "<span class='notice'>you rapidly read through the arcane book. Suddenly you realize you understand [spellname]!</span>")
		user.create_log(MISC_LOG, "learned the spell [spellname] ([S])")
		user.create_attack_log("<font color='orange'>[key_name(user)] learned the spell [spellname] ([S]).</font>")
		onlearned(user)

/obj/item/spellbook/oneuse/proc/recoil(mob/user)
	user.visible_message("<span class='warning'>[src] glows in a black light!</span>")

/obj/item/spellbook/oneuse/proc/onlearned(mob/user)
	used = 1
	user.visible_message("<span class='caution'>[src] glows dark for a second!</span>")

/obj/item/spellbook/oneuse/attackby()
	return

/obj/item/spellbook/oneuse/fireball
	spell = /obj/effect/proc_holder/spell/fireball
	spellname = "fireball"
	icon_state = "bookfireball"
	desc = "This book feels warm to the touch."

/obj/item/spellbook/oneuse/fireball/recoil(mob/user as mob)
	..()
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2)
	qdel(src)

/obj/item/spellbook/oneuse/smoke
	spell = /obj/effect/proc_holder/spell/targeted/smoke
	spellname = "smoke"
	icon_state = "booksmoke"
	desc = "This book is overflowing with the dank arts."

/obj/item/spellbook/oneuse/smoke/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='caution'>Your stomach rumbles...</span>")
	user.adjust_nutrition(-200)

/obj/item/spellbook/oneuse/blind
	spell = /obj/effect/proc_holder/spell/targeted/trigger/blind
	spellname = "blind"
	icon_state = "bookblind"
	desc = "This book looks blurry, no matter how you look at it."

/obj/item/spellbook/oneuse/blind/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>You go blind!</span>")
	user.EyeBlind(10)

/obj/item/spellbook/oneuse/mindswap
	spell = /obj/effect/proc_holder/spell/targeted/mind_transfer
	spellname = "mindswap"
	icon_state = "bookmindswap"
	desc = "This book's cover is pristine, though its pages look ragged and torn."
	var/mob/stored_swap = null //Used in used book recoils to store an identity for mindswaps

/obj/item/spellbook/oneuse/mindswap/onlearned()
	spellname = pick("fireball","smoke","blind","forcewall","knock","horses","charge")
	icon_state = "book[spellname]"
	name = "spellbook of [spellname]" //Note, desc doesn't change by design
	..()

/obj/item/spellbook/oneuse/mindswap/recoil(mob/user)
	..()
	if(stored_swap in GLOB.dead_mob_list)
		stored_swap = null
	if(!stored_swap)
		stored_swap = user
		to_chat(user, "<span class='warning'>For a moment you feel like you don't even know who you are anymore.</span>")
		return
	if(stored_swap == user)
		to_chat(user, "<span class='notice'>You stare at the book some more, but there doesn't seem to be anything else to learn...</span>")
		return

	var/obj/effect/proc_holder/spell/targeted/mind_transfer/swapper = new
	swapper.cast(user, stored_swap, 1)

	to_chat(stored_swap, "<span class='warning'>You're suddenly somewhere else... and someone else?!</span>")
	to_chat(user, "<span class='warning'>Suddenly you're staring at [src] again... where are you, who are you?!</span>")
	stored_swap = null

/obj/item/spellbook/oneuse/forcewall
	spell = /obj/effect/proc_holder/spell/targeted/forcewall
	spellname = "forcewall"
	icon_state = "bookforcewall"
	desc = "This book has a dedication to mimes everywhere inside the front cover."

/obj/item/spellbook/oneuse/forcewall/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>You suddenly feel very solid!</span>")
	var/obj/structure/closet/statue/S = new /obj/structure/closet/statue(user.loc, user)
	S.timer = 30
	user.drop_item()

/obj/item/spellbook/oneuse/knock
	spell = /obj/effect/proc_holder/spell/aoe_turf/knock
	spellname = "knock"
	icon_state = "bookknock"
	desc = "This book is hard to hold closed properly."

/obj/item/spellbook/oneuse/knock/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>You're knocked down!</span>")
	user.Weaken(20)

/obj/item/spellbook/oneuse/horsemask
	spell = /obj/effect/proc_holder/spell/targeted/horsemask
	spellname = "horses"
	icon_state = "bookhorses"
	desc = "This book is more horse than your mind has room for."

/obj/item/spellbook/oneuse/horsemask/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		to_chat(user, "<font size='15' color='red'><b>HOR-SIE HAS RISEN</b></font>")
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.flags |= NODROP | DROPDEL	//curses!
		magichead.flags_inv = null	//so you can still see their face
		magichead.voicechange = 1	//NEEEEIIGHH
		if(!user.unEquip(user.wear_mask))
			qdel(user.wear_mask)
		user.equip_to_slot_if_possible(magichead, slot_wear_mask, 1, 1)
		qdel(src)
	else
		to_chat(user, "<span class='notice'>I say thee neigh</span>")

/obj/item/spellbook/oneuse/charge
	spell = /obj/effect/proc_holder/spell/targeted/charge
	spellname = "charging"
	icon_state = "bookcharge"
	desc = "This book is made of 100% post-consumer wizard."

/obj/item/spellbook/oneuse/charge/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>[src] suddenly feels very warm!</span>")
	empulse(src, 1, 1)

/obj/item/spellbook/oneuse/summonitem
	spell = /obj/effect/proc_holder/spell/targeted/summonitem
	spellname = "instant summons"
	icon_state = "booksummons"
	desc = "This book is bright and garish, very hard to miss."

/obj/item/spellbook/oneuse/summonitem/recoil(mob/user as mob)
	..()
	to_chat(user, "<span class='warning'>[src] suddenly vanishes!</span>")
	qdel(src)

/obj/item/spellbook/oneuse/fake_gib
	spell = /obj/effect/proc_holder/spell/targeted/touch/fake_disintegrate
	spellname = "disintegrate"
	icon_state = "bookfireball"
	desc = "This book feels like it will rip stuff apart."

/obj/item/spellbook/oneuse/sacredflame
	spell = /obj/effect/proc_holder/spell/targeted/sacred_flame
	spellname = "sacred flame"
	icon_state = "booksacredflame"
	desc = "Become one with the flames that burn within... and invite others to do so as well."

/obj/item/spellbook/oneuse/random
	icon_state = "random_book"

/obj/item/spellbook/oneuse/random/initialize()
	. = ..()
	var/static/banned_spells = list(/obj/item/spellbook/oneuse/mime, /obj/item/spellbook/oneuse/mime/fingergun, /obj/item/spellbook/oneuse/mime/fingergun/fake, /obj/item/spellbook/oneuse/mime/greaterwall)
	var/real_type = pick(subtypesof(/obj/item/spellbook/oneuse) - banned_spells)
	new real_type(loc)
	qdel(src)
