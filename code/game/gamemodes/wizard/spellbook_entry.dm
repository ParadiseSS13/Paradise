/*
  * This file contains all of the entries of the wizard spellbook
  * For the actual spellbook, go to spellbook.dm
*/

/datum/spellbook_entry
	var/name = "Entry Name"
	/// FALSE if this is buyable on ragin mages, TRUE if it's not.
	var/is_ragin_restricted = FALSE
	var/spell_type = null
	var/desc = ""
	var/category = "Offensive"
	var/cost = 2
	var/refundable = TRUE
	var/obj/effect/proc_holder/spell/S = null //Since spellbooks can be used by only one person anyway we can track the actual spell
	var/buy_word = "Learn"
	var/limit //used to prevent a spellbook_entry from being bought more than X times with one wizard spellbook

//Main category - Spells
//Offensive
/datum/spellbook_entry/blind
	name = "Blind"
	spell_type = /obj/effect/proc_holder/spell/trigger/blind
	category = "Offensive"
	cost = 1

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	spell_type = /obj/effect/proc_holder/spell/charge_up/bounce/lightning
	category = "Offensive"
	cost = 1

/datum/spellbook_entry/cluwne
	name = "Curse of the Cluwne"
	spell_type = /obj/effect/proc_holder/spell/touch/cluwne
	category = "Offensive"

/datum/spellbook_entry/banana_touch
	name = "Banana Touch"
	spell_type = /obj/effect/proc_holder/spell/touch/banana
	cost = 1

/datum/spellbook_entry/mime_malaise
	name = "Mime Malaise"
	spell_type = /obj/effect/proc_holder/spell/touch/mime_malaise
	cost = 1

/datum/spellbook_entry/horseman
	name = "Curse of the Horseman"
	spell_type = /obj/effect/proc_holder/spell/horsemask
	category = "Offensive"

/datum/spellbook_entry/disintegrate
	name = "Disintegrate"
	spell_type = /obj/effect/proc_holder/spell/touch/disintegrate
	category = "Offensive"

/datum/spellbook_entry/fireball
	name = "Fireball"
	spell_type = /obj/effect/proc_holder/spell/fireball
	category = "Offensive"

/datum/spellbook_entry/summon_toolbox
	name = "Homing Toolbox"
	spell_type = /obj/effect/proc_holder/spell/fireball/toolbox
	category = "Offensive"
	cost = 1

/datum/spellbook_entry/fleshtostone
	name = "Flesh to Stone"
	spell_type = /obj/effect/proc_holder/spell/touch/flesh_to_stone
	category = "Offensive"

/datum/spellbook_entry/mutate
	name = "Mutate"
	spell_type = /obj/effect/proc_holder/spell/genetic/mutate
	category = "Offensive"

/datum/spellbook_entry/rod_form
	name = "Rod Form"
	spell_type = /obj/effect/proc_holder/spell/rod_form
	category = "Offensive"

/datum/spellbook_entry/infinite_guns
	name = "Lesser Summon Guns"
	spell_type = /obj/effect/proc_holder/spell/infinite_guns
	category = "Offensive"

//Defensive
/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	spell_type = /obj/effect/proc_holder/spell/emplosion/disable_tech
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	spell_type = /obj/effect/proc_holder/spell/forcewall
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/rathens
	name = "Rathen's Secret"
	spell_type = /obj/effect/proc_holder/spell/rathens
	category = "Defensive"
	cost = 2

/datum/spellbook_entry/repulse
	name = "Repulse"
	spell_type = /obj/effect/proc_holder/spell/aoe/repulse
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/smoke
	name = "Smoke"
	spell_type = /obj/effect/proc_holder/spell/smoke
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	spell_type = /obj/effect/proc_holder/spell/lichdom
	category = "Defensive"
	is_ragin_restricted = TRUE

/datum/spellbook_entry/magicm
	name = "Magic Missile"
	spell_type = /obj/effect/proc_holder/spell/projectile/magic_missile
	category = "Defensive"

/datum/spellbook_entry/timestop
	name = "Time Stop"
	spell_type = /obj/effect/proc_holder/spell/aoe/conjure/timestop
	category = "Defensive"

/datum/spellbook_entry/sacred_flame
	name = "Sacred Flame and Fire Immunity"
	spell_type = /obj/effect/proc_holder/spell/sacred_flame
	cost = 1
	category = "Defensive"

/datum/spellbook_entry/sacred_flame/LearnSpell(mob/living/carbon/human/user, obj/item/spellbook/book, obj/effect/proc_holder/spell/newspell)
	to_chat(user, "<span class='notice'>You feel fireproof.</span>")
	ADD_TRAIT(user, TRAIT_RESISTHEAT, MAGIC_TRAIT)
	ADD_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, MAGIC_TRAIT)
	return ..()

/datum/spellbook_entry/sacred_flame/Refund(mob/living/carbon/human/user, obj/item/spellbook/book)
	to_chat(user, "<span class='warning'>You no longer feel fireproof.</span>")
	REMOVE_TRAIT(user, TRAIT_RESISTHEAT, MAGIC_TRAIT)
	REMOVE_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, MAGIC_TRAIT)
	return ..()

/datum/spellbook_entry/summon_supermatter
	name = "Summon Supermatter Crystal"
	spell_type = /obj/effect/proc_holder/spell/aoe/conjure/summon_supermatter
	cost = 3
	category = "Defensive"

/datum/spellbook_entry/summon_supermatter/LearnSpell(mob/living/carbon/human/user, obj/item/spellbook/book, obj/effect/proc_holder/spell/newspell)
	to_chat(user, "<span class='notice'>You feel a little bit of supermatter enter your body.</span>")
	ADD_TRAIT(user, TRAIT_RADIMMUNE, MAGIC_TRAIT)
	ADD_TRAIT(user, SM_HALLUCINATION_IMMUNE, MAGIC_TRAIT)
	return ..()

/datum/spellbook_entry/summon_supermatter/Refund(mob/living/carbon/human/user, obj/item/spellbook/book)
	to_chat(user, "<span class='warning'>A little bit of supermatter leaves your body. So does that metallic taste in your mouth.</span>")
	REMOVE_TRAIT(user, TRAIT_RADIMMUNE, MAGIC_TRAIT)
	REMOVE_TRAIT(user, SM_HALLUCINATION_IMMUNE, MAGIC_TRAIT)
	return ..()

//Mobility
/datum/spellbook_entry/knock
	name = "Knock"
	spell_type = /obj/effect/proc_holder/spell/aoe/knock
	category = "Mobility"
	cost = 1

/datum/spellbook_entry/blink
	name = "Blink"
	spell_type = /obj/effect/proc_holder/spell/turf_teleport/blink
	category = "Mobility"

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	spell_type = /obj/effect/proc_holder/spell/ethereal_jaunt
	category = "Mobility"

/datum/spellbook_entry/spacetime_dist
	name = "Spacetime Distortion"
	spell_type = /obj/effect/proc_holder/spell/spacetime_dist
	cost = 1 //Better defence than greater forcewall (maybe) but good luck hitting anyone, so 1 point.
	category = "Mobility"

/datum/spellbook_entry/greaterknock
	name = "Greater Knock"
	spell_type = /obj/effect/proc_holder/spell/aoe/knock/greater
	category = "Mobility"
	refundable = 0 //global effect on cast

/datum/spellbook_entry/mindswap
	name = "Mindswap"
	spell_type = /obj/effect/proc_holder/spell/mind_transfer
	category = "Mobility"

/datum/spellbook_entry/teleport
	name = "Teleport"
	spell_type = /obj/effect/proc_holder/spell/area_teleport/teleport
	category = "Mobility"

//Assistance
/datum/spellbook_entry/charge
	name = "Charge"
	spell_type = /obj/effect/proc_holder/spell/charge
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/summonitem
	name = "Summon Item"
	spell_type = /obj/effect/proc_holder/spell/summonitem
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/noclothes
	name = "Remove Clothes Requirement"
	spell_type = /obj/effect/proc_holder/spell/noclothes
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
	if(cost == 0)
		dat += " No Cost<br>"
	else
		dat += " Cost:[cost]<br>"
	dat += "<i>[desc]</i><br>"
	if(active)
		dat += "<b>Already cast!</b><br>"
	return dat

/datum/spellbook_entry/summon/ghosts
	name = "Summon Ghosts"
	desc = "Spook the crew out by making them see dead people. Be warned, ghosts are capricious and occasionally vindicative, and some will use their incredibly minor abilities to frustrate you."
	cost = 0
	is_ragin_restricted = TRUE

/datum/spellbook_entry/summon/ghosts/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	new /datum/event/wizard/ghost()
	active = TRUE
	to_chat(user, "<span class='notice'>You have cast summon ghosts!</span>")
	playsound(get_turf(user), 'sound/effects/ghost2.ogg', 50, 1)
	return TRUE

/datum/spellbook_entry/summon/slience_ghosts
	name = "Silence Ghosts"
	desc = "Tired of people talking behind your back, and spooking you? Why not silence them, and make the dead deader."
	cost = 2
	is_ragin_restricted = TRUE //Salt needs to flow here, to be honest

/datum/spellbook_entry/summon/slience_ghosts/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	new /datum/event/wizard/ghost_mute()
	active = TRUE
	to_chat(user, "<span class='notice'>You have silenced all ghosts!</span>")
	playsound(get_turf(user), 'sound/effects/ghost.ogg', 50, 1)
	message_admins("[key_name_admin(usr)] silenced all ghosts as a wizard! (Deadchat is now DISABLED)")
	return TRUE

/datum/spellbook_entry/summon/guns
	name = "Summon Guns"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill you. There is a good chance that they will shoot each other first. Hopefully. Gives you 2 extra spell points on purchase."
	cost = -2
	is_ragin_restricted = TRUE

/datum/spellbook_entry/summon/guns/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	rightandwrong(SUMMON_GUNS, user, 10)
	active = TRUE
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>You have cast summon guns!</span>")
	return TRUE

/datum/spellbook_entry/summon/magic
	name = "Summon Magic"
	desc = "Share the wonders of magic with the crew and show them why they aren't to be trusted with it at the same time. Gives you 2 extra spell points on purchase."
	cost = -2
	is_ragin_restricted = TRUE

/datum/spellbook_entry/summon/magic/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
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
	var/spawn_on_floor = FALSE
	var/item_path = null

/datum/spellbook_entry/item/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(spawn_on_floor == FALSE)
		user.put_in_hands(new item_path)
	else
		new item_path(user.loc)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	return 1

/datum/spellbook_entry/item/GetInfo()
	var/dat =""
	dat += "<b>[name]</b>"
	dat += " Cost:[cost]<br>"
	dat += "<i>[desc]</i><br>"
	return dat

//Artefacts
/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "A Necromantic stone is able to resurrect three dead individuals as skeletal thralls for you to command."
	item_path = /obj/item/necromantic_stone
	category = "Artefacts"

/datum/spellbook_entry/item/scryingorb
	name = "Scrying Orb"
	desc = "An incandescent orb of crackling energy, using it will allow you to ghost while alive, allowing you to spy upon the station with ease. In addition, buying it will permanently grant you x-ray vision."
	item_path = /obj/item/scrying
	category = "Artefacts"

/datum/spellbook_entry/item/soulstones
	name = "Six Soul Stone Shards and the spell Artificer"
	desc = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot."
	item_path = /obj/item/storage/belt/soulstone/full
	category = "Artefacts"

/datum/spellbook_entry/item/soulstones/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	. = ..()
	if(.)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/construct(null))
	return .

/datum/spellbook_entry/item/wands
	name = "Wand Assortment"
	desc = "A collection of wands that allow for a wide variety of utility. Wands do not recharge, so be conservative in use. Comes in a handy belt."
	item_path = /obj/item/storage/belt/wands/full
	category = "Artefacts"

/datum/spellbook_entry/item/magic_nanny_bag
	name = "Magic Nanny Bag"
	desc = "A magical bottomless bag that comes filled with many random goodies, and sticks well in your hand. Will have a melee weapon, a staff, a wand, an artifact, and a special food treat! Can't fit on your back."
	item_path = /obj/item/storage/backpack/duffel/magic_nanny_bag
	cost = 4
	spawn_on_floor = TRUE // it isn't happy if it has to remake itself in hand
	is_ragin_restricted = TRUE //No blocked magic items on raging, sorry!
	category = "Artefacts"

/datum/spellbook_entry/item/cursed_heart
	name = "Cursed Heart"
	desc = "A heart that has been empowered with magic to heal the user. The user must ensure the heart is manually beaten or their blood circulation will suffer, but every beat heals their injuries. It must beat every 6 seconds. Not reccomended for first time wizards."
	item_path = /obj/item/organ/internal/heart/cursed/wizard
	cost = 1
	category = "Artefacts"

/datum/spellbook_entry/item/voice_of_god
	name = "Voice of God"
	desc = "A magical vocal cord that can be used to yell out with the voice of a god, be it to harm, help, or confuse the target."
	item_path = /obj/item/organ/internal/vocal_cords/colossus/wizard
	category = "Artefacts"

/datum/spellbook_entry/item/warp_cubes
	name = "Warp Cubes"
	desc = "Two magic cubes, that when they are twisted in hand, teleports the user to the location of the other cube instantly. Great for silently teleporting to a fixed location, or teleporting you to an apprentice, or vice versa. Do not leave on the wizard den, it will not work."
	item_path = /obj/item/warp_cube/red
	cost = 1
	spawn_on_floor = TRUE // breaks if spawned in hand
	category = "Artefacts"

/datum/spellbook_entry/item/everfull_mug
	name = "Everfull Mug"
	desc = "A magical mug that can be filled with omnizine at will, though beware of addiction! It can also produce alchohol and other less useful substances."
	item_path = /obj/item/reagent_containers/food/drinks/everfull
	cost = 1
	category = "Artefacts"

//Weapons and Armors
/datum/spellbook_entry/item/battlemage
	name = "Battlemage Armor"
	desc = "An ensorceled spaceproof suit of protective yet light armor, protected by a powerful shield. The shield can completely negate 15 attacks before permanently failing."
	item_path = /obj/item/storage/box/wizard/hardsuit
	limit = 1
	category = "Weapons and Armors"

/datum/spellbook_entry/item/mjolnir
	name = "Mjolnir"
	desc = "A mighty hammer on loan from Thor, God of Thunder. It crackles with barely contained power."
	item_path = /obj/item/mjollnir
	category = "Weapons and Armors"

/datum/spellbook_entry/item/singularity_hammer
	name = "Singularity Hammer"
	desc = "A hammer that creates an intensely powerful field of gravity where it strikes, pulling everything nearby to the point of impact."
	item_path = /obj/item/singularityhammer
	category = "Weapons and Armors"

/datum/spellbook_entry/item/cursed_katana
	name = "Cursed Katana"
	desc = "A cursed artefact, used to seal a horrible being inside the katana, which has now reformed. Can be used to make multiple powerful combos, examine it to see them. Can not be dropped. On death, you will dust."
	item_path = /obj/item/organ/internal/cyberimp/arm/katana
	cost = 1
	category = "Weapons and Armors"

/datum/spellbook_entry/item/spell_blade
	name = "Spellblade"
	desc = "A magical sword that can be enchanted by using it in hand to have a unique on-hit effect. Lighting: arcs electricity between nearby targets, stunning and damaging them. Fire: creates a massive ball of fire on hit, and makes the wielder immune to fire. Bluespace: allows you to strike people from a range, teleporting you to them. Forceshield: on hit, makes you stun immune for 3 seconds and reduces damage by half."
	item_path = /obj/item/melee/spellblade
	category = "Weapons and Armors"

/datum/spellbook_entry/item/meat_hook
	name = "Meat hook"
	desc = "An enchanted hook, that can be used to hook people, hurt them, and bring them right to you. Quite bulky, works well as a belt though."
	item_path = /obj/item/gun/magic/hook
	cost = 1
	category = "Weapons and Armors"

//Staves
/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "A particular staff that can mold solid metal into ornate wooden doors. Useful for getting around in the absence of other transportation. Does not work on glass."
	item_path = /obj/item/gun/magic/staff/door
	category = "Staves"
	cost = 1

/datum/spellbook_entry/item/staffhealing
	name = "Staff of Healing"
	desc = "An altruistic staff that can heal the lame and raise the dead."
	item_path = /obj/item/gun/magic/staff/healing
	category = "Staves"
	cost = 1

/datum/spellbook_entry/item/staffslipping
	name = "Staff of Slipping"
	desc = "A staff that shoots magical bananas. These bananas will either slip or stun the target when hit. Surprisingly reliable!"
	item_path = /obj/item/gun/magic/staff/slipping
	category = "Staves"
	cost = 1

/datum/spellbook_entry/item/staffanimation
	name = "Staff of Animation"
	desc = "An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines."
	item_path = /obj/item/gun/magic/staff/animate
	category = "Staves"

/datum/spellbook_entry/item/staffchange
	name = "Staff of Change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	item_path = /obj/item/gun/magic/staff/change
	category = "Staves"
	is_ragin_restricted = TRUE

/datum/spellbook_entry/item/staffchaos
	name = "Staff of Chaos"
	desc = "A caprious tool that can fire all sorts of magic without any rhyme or reason. Using it on people you care about is not recommended."
	item_path = /obj/item/gun/magic/staff/chaos
	category = "Staves"

//Summons
/datum/spellbook_entry/item/oozebottle
	name = "Bottle of Ooze"
	desc = "A bottle of magically infused ooze, which will awake an all-consuming Morph, capable of cunningly disguising itself as any object it comes in contact with and even casting some very basic spells. Be careful though, as Morph diet includes Wizards."
	item_path = /obj/item/antag_spawner/morph
	category = "Summons"
	limit = 3
	cost = 1

/datum/spellbook_entry/item/hugbottle
	name = "Bottle of Tickles"
	desc = "A bottle of magically infused fun, the smell of which will \
		attract adorable extradimensional beings when broken. These beings \
		are similar to slaughter demons, but are a little weaker and they do not permanently \
		kill their victims, instead putting them in an extradimensional hugspace, \
		to be released on the demon's death. Chaotic, but not ultimately \
		damaging. The crew's reaction to the other hand could be very \
		destructive."
	item_path = /obj/item/antag_spawner/slaughter_demon/laughter
	category = "Summons"
	limit = 3
	cost = 1 // Non-destructive; it's just a jape, sibling!

/datum/spellbook_entry/item/bloodbottle
	name = "Bottle of Blood"
	desc = "A bottle of magically infused blood, the smell of which will attract extradimensional beings when broken. Be careful though, the kinds of creatures summoned by blood magic are indiscriminate in their killing, and you yourself may become a victim."
	item_path = /obj/item/antag_spawner/slaughter_demon
	category = "Summons"
	limit = 3

/datum/spellbook_entry/item/shadowbottle
	name = "Bottle of Shadows"
	desc = "A bottle of pure darkness, the smell of which will attract extradimensional beings when broken. Be careful though, the kinds of creatures summoned from the shadows are indiscriminate in their killing, and you yourself may become a victim."
	item_path = /obj/item/antag_spawner/slaughter_demon/shadow
	category = "Summons"
	limit = 3
	cost = 1 //Unless you blackout the station this ain't going to do much, wizard doesn't get NV, still dies easily to a group of 2 and it doesn't eat bodies.

/datum/spellbook_entry/item/revenantbottle
	name = "Bottle of Ectoplasm"
	desc = "A magically infused bottle of ectoplasm, effectively pure salt from the spectral realm. Be careful though, these salty spirits are indiscriminate in their harvesting, and you yourself may become a victim."
	item_path = /obj/item/antag_spawner/revenant
	category = "Summons"
	limit = 3
	cost = 1 //Needs essence to live. Needs crew to die for essence, doubt xenobio will be making many monkeys. As such, weaker. Also can hardstun the wizard.

/datum/spellbook_entry/item/pulsedemonbottle
	name = "Living Lightbulb"
	desc = "A magically sealed lightbulb confining some manner of electricity based creature. Beware, these creatures are indiscriminate in their shocking antics, and you yourself may become a victim."
	item_path = /obj/item/antag_spawner/pulse_demon
	category = "Summons"
	limit = 3
	cost = 1 // Needs station power to live. Also can kill the wizard trivially in maints (get shock protection).

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service, using it will summon them to your side."
	item_path = /obj/item/contract
	category = "Summons"

/datum/spellbook_entry/item/tarotdeck
	name = "Guardian Deck"
	desc = "A deck of guardian tarot cards, capable of binding a personal guardian to your body. There are multiple types of guardian available, but all of them will transfer some amount of damage to you. \
	It would be wise to avoid buying these with anything capable of causing you to swap bodies with others."
	item_path = /obj/item/guardiancreator
	category = "Summons"
	limit = 1
