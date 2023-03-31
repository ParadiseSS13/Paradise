//Contains wizard loadouts and associated unique spells

//Standard loadouts, which are meant to be suggestions for beginners. Should always be worth exactly 10 spell points, and only contain standard wizard spells/items.
/datum/spellbook_entry/loadout/mutant
	name = "Offense Focus : Mutant"
	desc = "A spellset focused around the Mutate spell as its main source of damage, which provides stun protection, laser eyes, and strong punches. <br> \
		Ethereal Jaunt and Blink provide escape and mobility, while Magic Missile and Disintegrate can be used together for dangerous or key targets. <br> \
		As this set lacks any form of healing or resurrection, healing items should be acquired from the station, and you should be careful to avoid being hurt in the first place. <br><br> \
		</i>Provides Mutate, Ethereal Jaunt, Blink, Magic Missile, and Disintegrate.<i>"
	log_name = "OM"
	spells_path = list(/obj/effect/proc_holder/spell/genetic/mutate, /obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/turf_teleport/blink, \
		/obj/effect/proc_holder/spell/projectile/magic_missile, /obj/effect/proc_holder/spell/touch/disintegrate)

/datum/spellbook_entry/loadout/lich
	name = "Defense Focus : Lich"
	desc = "This spellset uses the Bind Soul spell to safeguard your life as a lich and allow for more dangerous offensive spells to be used. <br> \
		Ethereal Jaunt provides escape, Fireball and Rod Form are your offensive spells, and Disable Tech and Forcewall provides utility in disabling sec equipment or blocking their path. <br> \
		Care should be taken in hiding the item you choose as your phylactery after using Bind Soul, as you cannot revive if it destroyed or too far from your body! <br><br> \
		</i>Provides Bind Soul, Ethereal Jaunt,  Fireball, Rod Form, Disable Tech, and Greater Forcewall.<i>"
	log_name = "DL"
	spells_path = list(/obj/effect/proc_holder/spell/lichdom, /obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/fireball, \
		/obj/effect/proc_holder/spell/rod_form, /obj/effect/proc_holder/spell/emplosion/disable_tech, /obj/effect/proc_holder/spell/forcewall)
	is_ragin_restricted = TRUE

/datum/spellbook_entry/loadout/wands
	name = "Utility Focus : Wands"
	desc = "This set contain a Belt of Wands, providing offensive, defensive, and utility wands. Wands have limited charges, but can be partially recharged with the Charge spell included. <br> \
		Ethereal Jaunt and Blink provide escape and mobility, while Disintegrate and Repulse can be used to annihilate or push away anyone that gets too close to you. <br> \
		Do not lose any of your wands to the station's crew, as they are extremely deadly even in their hands. Remember that the Revive wand can be used on yourself for a full heal! <br><br> \
		</i>Provides a Belt of Wands, Charge, Ethereal Jaunt, Blink, Repulse, and Disintegrate.<i>"
	log_name = "UW"
	items_path = list(/obj/item/storage/belt/wands/full)
	spells_path = list(/obj/effect/proc_holder/spell/charge, /obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/turf_teleport/blink, \
		/obj/effect/proc_holder/spell/aoe/repulse, /obj/effect/proc_holder/spell/touch/disintegrate)

//Unique loadouts, which are more gimmicky. Should contain some unique spell or item that separates it from just buying standard wiz spells, and be balanced around a 10 spell point cost.
/datum/spellbook_entry/loadout/mimewiz
	name = "Silencio"
	desc = "...<br><br> \
		</i>Provides Finger Gun and Invisible Greater Wall manuals, Mime Robes, a Cane and Duct Tape, Ethereal Jaunt, Blink, Teleport, Mime Malaise, Knock, and Stop Time.<i>"
	log_name = "SHH"
	items_path = list(/obj/item/spellbook/oneuse/mime/fingergun, /obj/item/spellbook/oneuse/mime/greaterwall, /obj/item/clothing/suit/wizrobe/mime, /obj/item/clothing/head/wizard/mime, \
		/obj/item/clothing/mask/gas/mime/wizard, /obj/item/clothing/shoes/sandal/marisa, /obj/item/cane, /obj/item/stack/tape_roll)
	spells_path = list(/obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/turf_teleport/blink, /obj/effect/proc_holder/spell/area_teleport/teleport, \
		/obj/effect/proc_holder/spell/touch/mime_malaise, /obj/effect/proc_holder/spell/aoe/knock, /obj/effect/proc_holder/spell/aoe/conjure/timestop)
	category = "Unique"
	destroy_spellbook = TRUE

/datum/spellbook_entry/loadout/mimewiz/OnBuy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(user.mind)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/mime/speak(null))
		user.mind.miming = TRUE

/datum/spellbook_entry/loadout/gunreaper
	name = "Gunslinging Reaper"
	desc = "Cloned over and over, the souls aboard this station yearn for a deserved rest. <br> \
		Bring them to the afterlife, one trigger pull at a time. <br> \
		You will likely need to scavenge additional ammo or weapons aboard the station. <br><br>\
		</i>Provides a .357 Revolver, 4 speedloaders of ammo, Ethereal Jaunt, Blink, Summon Item, No Clothes, and Bind Soul, with a unique outfit.<i>"
	log_name = "GR"
	items_path = list(/obj/item/gun/projectile/revolver, /obj/item/ammo_box/a357, /obj/item/ammo_box/a357, /obj/item/ammo_box/a357, /obj/item/ammo_box/a357, /obj/item/clothing/under/syndicate)
	spells_path = list(/obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/turf_teleport/blink, \
		/obj/effect/proc_holder/spell/summonitem, /obj/effect/proc_holder/spell/noclothes, /obj/effect/proc_holder/spell/lichdom/gunslinger)
	category = "Unique"
	destroy_spellbook = TRUE
	is_ragin_restricted = TRUE

/obj/effect/proc_holder/spell/lichdom/gunslinger/equip_lich(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/det_suit(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), slot_gloves)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(H), slot_w_uniform)

/datum/spellbook_entry/loadout/greytide
	name = "Tyde the Grey"
	desc = "A set of legendary artifacts used by a bald, grey wizard, now passed on to you. <br> \
		Open His Grace's latch once you are ready to kill by using It in your hand. Keep It fed or you will be Its next meal.<br> \
		You might want to raid the Armory or loot a Security Officer to get ranged weapons like a disabler, His Grace's Hunger has little patience.<br><br> \
		</i>Provides His Grace, an Ancient Jumpsuit, an Assistant ID, a Gas Mask and Shoes, Insulated Gloves, a full Toolbelt, Ethereal Jaunt, Force Wall, Knock and No Clothes.<i>"
	log_name = "GT"
	items_path = list(/obj/item/his_grace, /obj/item/clothing/under/color/grey/glorf, /obj/item/clothing/mask/gas, /obj/item/clothing/shoes/black, \
		/obj/item/clothing/gloves/color/yellow, /obj/item/storage/belt/utility/full/multitool)
	spells_path = list(/obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/forcewall, \
		/obj/effect/proc_holder/spell/aoe/knock, /obj/effect/proc_holder/spell/noclothes)
	category = "Unique"
	destroy_spellbook = TRUE

/datum/spellbook_entry/loadout/greytide/OnBuy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(!user)
		return
	if(isplasmaman(user))
		to_chat(user, "<span class='notice'>A spectral hand appears from your spellbook and pulls a brand new plasmaman envirosuit, complete with helmet, from the void, then drops it on the floor.</span>")
		new /obj/item/clothing/head/helmet/space/plasmaman/assistant(get_turf(user))
		new /obj/item/clothing/under/plasmaman/assistant(get_turf(user))
	user.unEquip(user.wear_id)
	user.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey/glorf, slot_w_uniform) //Just in case they're naked
	var/obj/item/card/id/wizid = new /obj/item/card/id(src)
	user.equip_to_slot_or_del(wizid, slot_wear_id)
	wizid.registered_name = user.real_name
	wizid.access = list(ACCESS_MAINT_TUNNELS)
	wizid.assignment = "Assistant"
	wizid.rank = "Assistant"
	wizid.photo = get_id_photo(user, "Assistant")
	wizid.registered_name = user.real_name
	wizid.SetOwnerInfo(user)
	wizid.UpdateName()
	wizid.RebuildHTML()
