//Contains wizard loadouts and associated unique spells

//Standard loadouts, which are meant to be suggestions for beginners. Should always be worth exactly 10 spell points, and only contain standard wizard spells/items.
/datum/spellbook_entry/loadout/mutant
	name = "Offense Focus : Mutant"
	desc = "A spellset focused around the Mutate spell as its main source of damage, which provides stun protection, laser eyes, and strong punches. <br> \
		Ethereal Jaunt and Blink provide escape and mobility, while Magic Missile and Disintegrate can be used together for dangerous or key targets. <br> \
		As this set lacks any form of healing or resurrection, healing items should be acquired from the station, and you should be careful to avoid being hurt in the first place. <br><br> \
		</i>Provides Mutate, Ethereal Jaunt, Blink, Magic Missile, and Disintegrate.<i>"
	log_name = "OM"
	spells_path = list(/obj/effect/proc_holder/spell/targeted/genetic/mutate, /obj/effect/proc_holder/spell/targeted/ethereal_jaunt, /obj/effect/proc_holder/spell/targeted/turf_teleport/blink, \
		/obj/effect/proc_holder/spell/targeted/projectile/magic_missile, /obj/effect/proc_holder/spell/targeted/touch/disintegrate)

/datum/spellbook_entry/loadout/lich
	name = "Defense Focus : Lich"
	desc = "This spellset uses the Bind Soul spell to safeguard your life as a lich and allow for more dangerous offensive spells to be used. <br> \
		Ethereal Jaunt provides escape, Fireball and Rod Form are your offensive spells, and Disable Tech and Greater Forcewall provides utility in disabling sec equipment or blocking their path. <br> \
		Care should be taken in hiding the item you choose as your phylactery after using Bind Soul, as you cannot revive if it destroyed or too far from your body! <br><br> \
		</i>Provides Bind Soul, Ethereal Jaunt,  Fireball, Rod Form, Disable Tech, and Greater Forcewall.<i>"
	log_name = "DL"
	spells_path = list(/obj/effect/proc_holder/spell/targeted/lichdom, /obj/effect/proc_holder/spell/targeted/ethereal_jaunt, /obj/effect/proc_holder/spell/targeted/click/fireball, \
		/obj/effect/proc_holder/spell/targeted/rod_form, /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech, /obj/effect/proc_holder/spell/targeted/forcewall/greater)
	is_ragin_restricted = TRUE

/datum/spellbook_entry/loadout/wands
	name = "Utility Focus : Wands"
	desc = "This set contain a Belt of Wands, providing offensive, defensive, and utility wands. Wands have limited charges, but can be partially recharged with the Charge spell included. <br> \
		Ethereal Jaunt and Blink provide escape and mobility, while Disintegrate and Repulse can be used to annihilate or push away anyone that gets too close to you. <br> \
		Do not lose any of your wands to the station's crew, as they are extremely deadly even in their hands. Remember that the Revive wand can be used on yourself for a full heal! <br><br> \
		</i>Provides a Belt of Wands, Charge, Ethereal Jaunt, Blink, Repulse, and Disintegrate.<i>"
	log_name = "UW"
	items_path = list(/obj/item/storage/belt/wands/full)
	spells_path = list(/obj/effect/proc_holder/spell/targeted/charge, /obj/effect/proc_holder/spell/targeted/ethereal_jaunt, /obj/effect/proc_holder/spell/targeted/turf_teleport/blink, \
		/obj/effect/proc_holder/spell/aoe_turf/repulse, /obj/effect/proc_holder/spell/targeted/touch/disintegrate)

//Unique loadouts, which are more gimmicky. Should contain some unique spell or item that separates it from just buying standard wiz spells, and be balanced around a 10 spell point cost.
/datum/spellbook_entry/loadout/mimewiz
	name = "Silencio"
	desc = "...<br><br> \
		</i>Provides Finger Gun and Invisible Greater Wall manuals, Mime Robes, a Cane and Duct Tape, Ethereal Jaunt, Blink, Teleport, Mime Malaise, Knock, and Stop Time.<i>"
	log_name = "SHH"
	items_path = list(/obj/item/spellbook/oneuse/mime/fingergun, /obj/item/spellbook/oneuse/mime/greaterwall, /obj/item/clothing/suit/wizrobe/mime, /obj/item/clothing/head/wizard/mime, \
		/obj/item/clothing/mask/gas/mime/wizard, /obj/item/clothing/shoes/sandal/marisa, /obj/item/cane, /obj/item/stack/tape_roll)
	spells_path = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt, /obj/effect/proc_holder/spell/targeted/turf_teleport/blink, /obj/effect/proc_holder/spell/targeted/area_teleport/teleport, \
		/obj/effect/proc_holder/spell/targeted/touch/mime_malaise, /obj/effect/proc_holder/spell/aoe_turf/knock, /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop)
	category = "Unique"
	destroy_spellbook = TRUE

/datum/spellbook_entry/loadout/mimewiz/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(user.mind)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		user.mind.miming = TRUE
	..()

/datum/spellbook_entry/loadout/gunreaper
	name = "Gunslinging Reaper"
	desc = "Cloned over and over, the souls aboard this station yearn for a deserved rest.<br> \
		Bring them to the afterlife, one trigger pull at a time. <br> \
		You will likely need to scavenge additional ammo or weapons aboard the station. <br><br>\
		</i>Provides a .357 Revolver, 4 speedloaders of ammo, Ethereal Jaunt, Blink, Summon Item, No Clothes, and Bind Soul, with a unique outfit.<i>"
	log_name = "GR"
	items_path = list(/obj/item/gun/projectile/revolver, /obj/item/ammo_box/a357, /obj/item/ammo_box/a357, /obj/item/ammo_box/a357, /obj/item/ammo_box/a357, /obj/item/clothing/under/syndicate)
	spells_path = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt, /obj/effect/proc_holder/spell/targeted/turf_teleport/blink, \
		/obj/effect/proc_holder/spell/targeted/summonitem, /obj/effect/proc_holder/spell/noclothes, /obj/effect/proc_holder/spell/targeted/lichdom/gunslinger)
	category = "Unique"
	destroy_spellbook = TRUE
	is_ragin_restricted = TRUE

/obj/effect/proc_holder/spell/targeted/lichdom/gunslinger/equip_lich(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/det_suit(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(H), slot_w_uniform)
