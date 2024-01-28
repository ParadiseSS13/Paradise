//Contains wizard loadouts and associated unique spells

//Standard loadouts, which are meant to be suggestions for beginners. Should always be worth exactly 10 spell points, and only contain standard wizard spells/items.
/datum/spellbook_entry/loadout/mutant
	name = "Offense Focus - Mutant"
	desc = "A spellset focused around the Mutate spell as its main source of damage, which provides stun protection, laser eyes, and strong punches. <br> \
		Ethereal Jaunt and Blink provide escape and mobility, while Magic Missile and Disintegrate can be used together for dangerous or key targets. <br> \
		As this set lacks any form of healing or resurrection, healing items should be acquired from the station, and you should be careful to avoid being hurt in the first place. <br><br> \
		</i>Provides Mutate, Ethereal Jaunt, Blink, Magic Missile, and Disintegrate.<i>"
	spells_path = list(/obj/effect/proc_holder/spell/genetic/mutate, /obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/turf_teleport/blink, \
		/obj/effect/proc_holder/spell/projectile/magic_missile, /obj/effect/proc_holder/spell/touch/disintegrate)

/datum/spellbook_entry/loadout/lich
	name = "Defense Focus - Lich"
	desc = "This spellset uses the Bind Soul spell to safeguard your life as a lich and allow for more dangerous offensive spells to be used. <br> \
		Ethereal Jaunt provides escape, Fireball and Rod Form are your offensive spells, and Disable Tech and Forcewall provides utility in disabling sec equipment or blocking their path. <br> \
		Care should be taken in hiding the item you choose as your phylactery after using Bind Soul, as you cannot revive if it destroyed or too far from your body! <br><br> \
		</i>Provides Bind Soul, Ethereal Jaunt,  Fireball, Rod Form, Disable Tech, and Greater Forcewall.<i>"
	spells_path = list(/obj/effect/proc_holder/spell/lichdom, /obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/fireball, \
		/obj/effect/proc_holder/spell/rod_form, /obj/effect/proc_holder/spell/emplosion/disable_tech, /obj/effect/proc_holder/spell/forcewall)
	is_ragin_restricted = TRUE

/datum/spellbook_entry/loadout/wands
	name = "Utility Focus - Wands"
	desc = "This set contain a Belt of Wands, providing offensive, defensive, and utility wands. Wands have limited charges, but can be partially recharged with the Charge spell included. <br> \
		Ethereal Jaunt and Blink provide escape and mobility, while Disintegrate and Repulse can be used to annihilate or push away anyone that gets too close to you. <br> \
		Do not lose any of your wands to the station's crew, as they are extremely deadly even in their hands. Remember that the Revive wand can be used on yourself for a full heal! <br><br> \
		</i>Provides a Belt of Wands, Charge, Ethereal Jaunt, Blink, Repulse, and Disintegrate.<i>"
	items_path = list(/obj/item/storage/belt/wands/full)
	spells_path = list(/obj/effect/proc_holder/spell/charge, /obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/turf_teleport/blink, \
		/obj/effect/proc_holder/spell/aoe/repulse, /obj/effect/proc_holder/spell/touch/disintegrate)

//Unique loadouts, which are more gimmicky. Should contain some unique spell or item that separates it from just buying standard wiz spells, and be balanced around a 10 spell point cost.
/datum/spellbook_entry/loadout/mimewiz
	name = "Silencio"
	desc = "...<br><br> \
		</i>Provides Finger Gun and Invisible Greater Wall manuals, Mime Robes, a Cane and Duct Tape, Ethereal Jaunt, Blink, Teleport, Mime Malaise, Knock, and Stop Time.<i>"
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
	items_path = list(/obj/item/gun/projectile/revolver, /obj/item/ammo_box/a357, /obj/item/ammo_box/a357, /obj/item/ammo_box/a357, /obj/item/ammo_box/a357, /obj/item/clothing/under/syndicate)
	spells_path = list(/obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/turf_teleport/blink, \
		/obj/effect/proc_holder/spell/summonitem, /obj/effect/proc_holder/spell/noclothes, /obj/effect/proc_holder/spell/lichdom/gunslinger)
	category = "Unique"
	destroy_spellbook = TRUE
	is_ragin_restricted = TRUE

/obj/effect/proc_holder/spell/lichdom/gunslinger/equip_lich(mob/living/carbon/human/H)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/storage/det_suit(H), SLOT_HUD_OUTER_SUIT)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(H), SLOT_HUD_SHOES)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/combat(H), SLOT_HUD_GLOVES)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/syndicate(H), SLOT_HUD_JUMPSUIT)

/datum/spellbook_entry/loadout/greytide
	name = "Tyde the Grey"
	desc = "A set of legendary artifacts used by a bald, grey wizard, now passed on to you. <br> \
		Open His Grace's latch once you are ready to kill by using It in your hand. Keep It fed or you will be Its next meal.<br> \
		If your Homing Toolbox spell is not enough, you might want to raid the Armory or loot a Security Officer to get more ranged weapons like a disabler, His Grace's Hunger has little patience.<br><br> \
		</i>Provides His Grace, an Ancient Jumpsuit, an Assistant ID, a Gas Mask and Shoes, Insulated Gloves, a full Toolbelt, Ethereal Jaunt, Force Wall, Homing Toolbox, Knock and No Clothes.<i>"
	items_path = list(/obj/item/his_grace, /obj/item/clothing/under/color/grey/glorf, /obj/item/clothing/mask/gas, /obj/item/clothing/shoes/black, \
		/obj/item/clothing/gloves/color/yellow, /obj/item/storage/belt/utility/full/multitool)
	spells_path = list(/obj/effect/proc_holder/spell/ethereal_jaunt, /obj/effect/proc_holder/spell/forcewall, \
		/obj/effect/proc_holder/spell/aoe/knock, /obj/effect/proc_holder/spell/noclothes, /obj/effect/proc_holder/spell/fireball/toolbox)
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
	user.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey/glorf, SLOT_HUD_JUMPSUIT) //Just in case they're naked
	var/obj/item/card/id/wizid = new /obj/item/card/id(src)
	user.equip_to_slot_or_del(wizid, SLOT_HUD_WEAR_ID)
	wizid.registered_name = user.real_name
	wizid.access = list(ACCESS_MAINT_TUNNELS)
	wizid.assignment = "Assistant"
	wizid.rank = "Assistant"
	wizid.photo = get_id_photo(user, "Assistant")
	wizid.registered_name = user.real_name
	wizid.SetOwnerInfo(user)
	wizid.UpdateName()
	wizid.RebuildHTML()

/datum/spellbook_entry/loadout/oblivion
	name = "Oblivion Enforcer"
	desc = "The Oblivion Order is an isolated clique of monks that revere supermatter. \
	Oblivion Enforcers are how the Order imposes their will on the universe as a whole. By taking this loadout, \
	you give up your identity and become a faceless hand of the Order. <br>\
	You will be completely protected from the effects of supermatter by the items granted here, so far as to \
	allow you to pick up and throw supermatter slivers, which your halberd can cut from the engine. <br>\
	</i>Provides a Supermatter Halberd, Oblivion Enforcer robes, and an air tank, as well as Instant Summons, Lightning Bolt, and Summon Supermatter Crystal.<i>"
	items_path = list(/obj/item/supermatter_halberd, /obj/item/clothing/gloves/color/white/supermatter_immune, \
		/obj/item/clothing/suit/hooded/oblivion, /obj/item/clothing/mask/gas/voice_modulator/oblivion, /obj/item/tank/internals/emergency_oxygen/double, \
		/obj/item/clothing/under/color/white/enforcer, /obj/item/clothing/shoes/white/enforcer)
	spells_path = list(/obj/effect/proc_holder/spell/summonitem, /obj/effect/proc_holder/spell/charge_up/bounce/lightning, \
		/obj/effect/proc_holder/spell/aoe/conjure/summon_supermatter)
	category = "Unique"
	destroy_spellbook = TRUE

/datum/spellbook_entry/loadout/oblivion/OnBuy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(!user)
		return
	ADD_TRAIT(user, SM_HALLUCINATION_IMMUNE, MAGIC_TRAIT)

/datum/spellbook_entry/loadout/fireball
	name = "Fireball. Fireball. Fireball."
	desc = "Who cares about the rest of the spells. Become an expert in fire magic. Devote yourself to the craft. The only spell you need anyways is <b>Fireball.</b><br>\
		</i>Provides fire immunity, homing fireballs, rapid-fire fireballs, and some fireball wands. Provides no mobility spells. Replaces your robes with infernal versions.<i>"
	spells_path = list(/obj/effect/proc_holder/spell/sacred_flame, /obj/effect/proc_holder/spell/fireball/homing, /obj/effect/proc_holder/spell/infinite_guns/fireball)
	category = "Unique"
	destroy_spellbook = TRUE

/datum/spellbook_entry/loadout/fireball/OnBuy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(user.wear_suit)
		var/jumpsuit = user.wear_suit
		user.unEquip(user.wear_suit, TRUE)
		qdel(jumpsuit)
	if(user.head)
		var/head = user.head
		user.unEquip(user.head, TRUE)
		qdel(head)

	// Part of Sacred Flame
	to_chat(user, "<span class='notice'>You feel fireproof.</span>")
	ADD_TRAIT(user, TRAIT_RESISTHEAT, MAGIC_TRAIT)
	ADD_TRAIT(user, TRAIT_RESISTHIGHPRESSURE, MAGIC_TRAIT)

	user.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/red/fireball(user), SLOT_HUD_OUTER_SUIT)
	user.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/red/fireball(user), SLOT_HUD_HEAD)

	user.equip_or_collect(new /obj/item/storage/belt/wands/fireballs(), SLOT_HUD_BELT)

/obj/item/clothing/suit/wizrobe/red/fireball
	name = "infernal robe"
	desc = "A magnificent, red, glowing robe that seems to radiate heat."
	flags = NODROP

/obj/item/clothing/head/wizard/red/fireball
	name = "infernal hat"
	desc = "A pointy red wizard hat, indicating a magician of great power."
	flags = NODROP
