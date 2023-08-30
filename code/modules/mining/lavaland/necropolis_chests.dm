//The chests dropped by mob spawner tendrils. Also contains associated loot.

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"
	icon_opened = "necrocrateopen"
	icon_closed = "necrocrate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously."

/obj/structure/closet/crate/necropolis/tendril/populate_contents()
	var/loot = rand(1, 30)
	switch(loot)
		if(1)
			new /obj/item/shared_storage/red(src)
		if(2)
			new /obj/item/clothing/head/helmet/space/cult(src)
			new /obj/item/clothing/suit/space/cult(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(3)
			new /obj/item/soulstone/anybody(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(4)
			new /obj/item/katana/cursed(src)
		if(5)
			new /obj/item/book_of_babel(src)
		if(6)
			new /obj/item/pickaxe/diamond(src)
		if(7)
			new /obj/item/clothing/suit/hooded/cultrobes(src)
			new /obj/item/bedsheet/cult(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(8)
			new /obj/item/spellbook/oneuse/summonitem(src)
		if(9)
			new /obj/item/rod_of_asclepius(src)
		if(10)
			new /obj/item/organ/internal/heart/cursed/wizard(src)
		if(11)
			new /obj/item/ship_in_a_bottle(src)
		if(12)
			new /obj/item/clothing/suit/space/hardsuit/champion(src)
		if(13)
			new /obj/item/jacobs_ladder(src)
		if(14)
			new /obj/item/nullrod/scythe/talking(src)
		if(15)//select and spawn a random nullrod that a chaplain could choose from
			var/path = pick(subtypesof(/obj/item/nullrod))
			new path(src)
		if(16)
			new /obj/item/borg/upgrade/modkit/lifesteal(src)
			new /obj/item/bedsheet/cult(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(17)
			new /obj/item/organ/internal/heart/gland/heals(src)
		if(18)
			new /obj/item/warp_cube/red(src)
		if(19)
			new /obj/item/wisp_lantern(src)
		if(20)
			new /obj/item/immortality_talisman(src)
		if(21)
			new /obj/item/gun/magic/hook(src)
		if(22)
			new /obj/item/voodoo(src)
		if(23)
			new /obj/item/grenade/clusterbuster/inferno(src)
		if(24)
			if(prob(60))
				new /obj/item/reagent_containers/food/drinks/bottle/holywater/hell(src)
				new /obj/item/clothing/suit/space/hardsuit/champion/templar(src)
			else
				new /obj/item/reagent_containers/food/drinks/bottle/holywater(src)
				new /obj/item/clothing/suit/space/hardsuit/champion/templar/premium(src)
		if(25)
			new /obj/item/eflowers(src)
		if(26)
			new /obj/item/rune_scimmy(src)
		if(27)
			new /obj/item/dnainjector/midgit(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
			new /obj/item/grenade/plastic/miningcharge/mega(src)
		if(28)
			var/mega = rand(1, 4)
			switch(mega)
				if(1)
					new /obj/item/twohanded/kinetic_crusher/mega(src)
				if(2)
					new /obj/item/gun/energy/plasmacutter/shotgun/mega(src)
				if(3)
					new /obj/item/gun/energy/plasmacutter/adv/mega(src)
				if(4)
					new /obj/item/gun/energy/kinetic_accelerator/mega(src)
		if(29)
			new /obj/item/clothing/suit/hooded/clockrobe_fake(src)
			new /obj/item/clothing/gloves/clockwork_fake(src)
			new /obj/item/clothing/shoes/clockwork_fake(src)
			new /obj/item/stack/sheet/brass_fake/fifty(src)
		if(30)
			new /obj/item/clothing/suit/armor/clockwork_fake(src)
			new /obj/item/clothing/head/helmet/clockwork_fake(src)
			new /obj/item/stack/sheet/brass_fake/fifty(src)

/obj/structure/closet/crate/necropolis/puzzle
	name = "puzzling chest"

/obj/structure/closet/crate/necropolis/puzzle/populate_contents()
	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/soulstone/anybody(src)
			new /obj/item/stack/sheet/runed_metal_fake/fifty(src)
		if(2)
			new /obj/item/wisp_lantern(src)
		if(3)
			new /obj/item/prisoncube(src)

//KA modkit design discs
/obj/item/disk/design_disk/modkit_disc
	name = "KA Mod Disk"
	desc = "A design disc containing the design for a unique kinetic accelerator modkit. It's compatible with a research console."
	icon_state = "datadisk1"
	var/modkit_design = /datum/design/unique_modkit

/obj/item/disk/design_disk/modkit_disc/New()
	. = ..()
	blueprint = new modkit_design

/obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe
	name = "Offensive Mining Explosion Mod Disk"
	modkit_design = /datum/design/unique_modkit/offensive_turf_aoe

/obj/item/disk/design_disk/modkit_disc/rapid_repeater
	name = "Rapid Repeater Mod Disk"
	modkit_design = /datum/design/unique_modkit/rapid_repeater

/obj/item/disk/design_disk/modkit_disc/resonator_blast
	name = "Resonator Blast Mod Disk"
	modkit_design = /datum/design/unique_modkit/resonator_blast

/obj/item/disk/design_disk/modkit_disc/bounty
	name = "Death Syphon Mod Disk"
	modkit_design = /datum/design/unique_modkit/bounty

/datum/design/unique_modkit
	build_type = PROTOLATHE | MECHFAB

/datum/design/unique_modkit/offensive_turf_aoe
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	id = "hyperaoemod"
	materials = list(MAT_METAL = 7000, MAT_GLASS = 3000, MAT_SILVER= 3000, MAT_GOLD = 3000, MAT_DIAMOND = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	category = list("Mining")

/datum/design/unique_modkit/rapid_repeater
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	id = "repeatermod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_URANIUM = 8000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater
	category = list("Mining")

/datum/design/unique_modkit/resonator_blast
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	id = "resonatormod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_SILVER= 5000, MAT_URANIUM = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts
	category = list("Mining")

/datum/design/unique_modkit/bounty
	name = "Kinetic Accelerator Death Syphon Mod"
	desc = "A device which causes kinetic accelerators to permanently gain damage against creature types killed with it."
	id = "bountymod"
	materials = list(MAT_METAL = 4000, MAT_SILVER = 4000, MAT_GOLD = 4000, MAT_BLUESPACE = 4000)
	reagents_list = list("blood" = 40)
	build_path = /obj/item/borg/upgrade/modkit/bounty
	category = list("Mining")

//Spooky special loot

//Rod of Asclepius
/obj/item/rod_of_asclepius
	name = "\improper Rod of Asclepius"
	desc = "A wooden rod about the size of your forearm with a snake carved around it, winding its way up the sides of the rod. Something about it seems to inspire in you the responsibilty and duty to help others."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "asclepius_dormant"
	item_state = "asclepius_dormant"
	var/activated = FALSE
	var/usedHand

/obj/item/rod_of_asclepius/attack_self(mob/user)
	if(activated)
		return
	if(!iscarbon(user))
		to_chat(user, "<span class='warning'>The snake carving seems to come alive, if only for a moment, before returning to its dormant state, almost as if it finds you incapable of holding its oath.</span>")
		return
	var/mob/living/carbon/itemUser = user
	if(itemUser.l_hand == src)
		usedHand = 1
	if(itemUser.r_hand == src)
		usedHand = 0
	if(itemUser.has_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH))
		to_chat(user, "<span class='warning'>You can't possibly handle the responsibility of more than one rod!</span>")
		return
	var/failText = "<span class='warning'>The snake seems unsatisfied with your incomplete oath and returns to its previous place on the rod, returning to its dormant, wooden state. You must stand still while completing your oath!</span>"
	to_chat(itemUser, "<span class='notice'>The wooden snake that was carved into the rod seems to suddenly come alive and begins to slither down your arm! The compulsion to help others grows abnormally strong...</span>")
	if(do_after_once(itemUser, 40, target = itemUser))
		itemUser.say("Клянусь Аполлоном врачом, Асклепием, всеми богами и богинями, беря их в свидетели, исполнять честно, соответственно моим силам и здравому смыслу, следующую клятву:")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 40, target = itemUser))
		itemUser.say("Я буду применять во благо больного все необходимые меры, воздерживаясь от причинения всякого вреда и несправедливости.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 40, target = itemUser))
		itemUser.say("Я буду предотвращать болезнь всякий раз, как смогу, поскольку предотвращение предпочтительнее, чем лечение.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 40, target = itemUser))
		itemUser.say("Я не выдам никому просимого у меня смертельного средства и не покажу пути для исполнения подобного замысла.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 40, target = itemUser))
		itemUser.say("Я буду уважать личную жизнь своих пациентов, поскольку их проблемы раскрываются мне не для того, чтобы о них мог узнать весь мир. Особенно с большой осторожностью я обязуюсь поступать в вопросах жизни и смерти. Если мне будет дано спасти жизнь — я выражу благодарность. Но также может оказаться в моей власти и лишение жизни, эта колоссальная ответственность должна встречаться с великим смирением и осознанием моей собственной бренности.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 40, target = itemUser))
		itemUser.say("Я буду помнить, что остаюсь членом общества, но с особыми обязательствами ко всем моим собратьям, как к немощным, так и к здоровым телом и умом.")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 40, target = itemUser))
		itemUser.say("Пока я не нарушаю эту клятву, да смогу я наслаждаться этим, заслуженно чтимым, искусством, пока я живу и меня вспоминают с любовью. Да буду я всегда действовать так, чтобы сохранить лучшие традиции моего призвания, и буду долго я испытывать радость исцеления тех, кто обращается за моей помощью.")
	else
		to_chat(itemUser, failText)
		return
	to_chat(itemUser, "<span class='notice'>The snake, satisfied with your oath, attaches itself and the rod to your forearm with an inseparable grip. Your thoughts seem to only revolve around the core idea of helping others, and harm is nothing more than a distant, wicked memory...</span>")
	var/datum/status_effect/hippocraticOath/effect = itemUser.apply_status_effect(STATUS_EFFECT_HIPPOCRATIC_OATH)
	effect.hand = usedHand
	activated()

/obj/item/rod_of_asclepius/proc/activated()
	flags =  NODROP | DROPDEL
	desc = "A short wooden rod with a mystical snake inseparably gripping itself and the rod to your forearm. It flows with a healing energy that disperses amongst yourself and those around you. "
	icon_state = "asclepius_active"
	item_state = "asclepius_active"
	activated = TRUE
// enchanced flowers
#define COOLDOWN_SUMMON 1 MINUTES
/obj/item/eflowers
	name ="enchanted flowers"
	desc ="A charming bunch of flowers, most animals seem to find the bearer amicable after momentary contact with it. Squeeze the bouquet to summon tamed creatures. Megafauna cannot be summoned. <b>Megafauna need to be exposed 35 times to become friendly.</b>"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "eflower"
	var/next_summon = 0
	var/list/summons = list()
	attack_verb = list("thumped", "brushed", "bumped")

/obj/item/eflowers/attack_self(mob/user)
	var/turf/T = get_turf(user)
	var/area/A = get_area(user)
	if(next_summon > world.time)
		to_chat(user, span_warning("You can't do that yet!"))
		return
	if(is_station_level(T.z) && !A.outdoors)
		to_chat(user, span_warning("You feel like calling a bunch of animals indoors is a bad idea."))
		return
	user.visible_message(span_warning("[user] holds the bouquet out, summoning their allies!"))
	for(var/mob/m in summons)
		m.forceMove(T)
	playsound(T, 'sound/effects/splat.ogg', 80, 5, -1)
	next_summon = world.time + COOLDOWN_SUMMON

/obj/item/eflowers/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	var/mob/living/simple_animal/M = target
	if(istype(M))
		if(M.client)
			to_chat(user, span_warning("[M] is too intelligent to tame!"))
			return
		if(M.stat)
			to_chat(user, span_warning("[M] is dead!"))
			return
		if(M.faction == user.faction)
			to_chat(user, span_warning("[M] is already on your side!"))
			return
		if(M.sentience_type == SENTIENCE_BOSS)
			var/datum/status_effect/taming/G = M.has_status_effect(STATUS_EFFECT_TAMING)
			if(!G)
				M.apply_status_effect(STATUS_EFFECT_TAMING, user)
			else
				G.add_tame(G.tame_buildup)
				if(ISMULTIPLE(G.tame_crit-G.tame_amount, 5))
					to_chat(user, span_notice("[M] has to be exposed [G.tame_crit-G.tame_amount] more times to accept your gift!"))
			return
		if(M.sentience_type != SENTIENCE_ORGANIC)
			to_chat(user, span_warning("[M] cannot be tamed!"))
			return
		if(!do_after(user, 1.5 SECONDS, target = M))
			return
		M.visible_message(span_notice("[M] seems happy with you after exposure to the bouquet!"))
		M.add_atom_colour("#11c42f", FIXED_COLOUR_PRIORITY)
		M.drop_loot()
		M.faction = user.faction
		summons |= M
	..()

//Runite Scimitar. Some weird runescape reference
/obj/item/rune_scimmy
	name = "rune scimitar"
	desc = "A curved sword smelted from an unknown metal. Looking at it gives you the otherworldly urge to pawn it off for '30k', whatever that means."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "rune_scimmy"
	force = 28
	slot_flags = SLOT_BELT
	damtype = BRUTE
	sharp = TRUE
	hitsound = 'sound/weapons/rs_slash.ogg'
	attack_verb = list("slashed","pk'd","atk'd")
