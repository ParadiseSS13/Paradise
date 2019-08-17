//The chests dropped by mob spawner tendrils. Also contains associated loot.

/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necrocrate"
	icon_opened = "necrocrateopen"
	icon_closed = "necrocrate"
	burn_state = LAVA_PROOF | FIRE_PROOF
	unacidable = 1

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously."

/obj/structure/closet/crate/necropolis/tendril/New(add_loot = TRUE)
	..()

	if(!add_loot)
		return

	var/loot = rand(1,25)
	switch(loot)
		if(1)
			new /obj/item/shared_storage/red(src)
		if(2)
			new /obj/item/clothing/head/helmet/space/cult(src)
			new /obj/item/clothing/suit/space/cult(src)
		if(3)
			new /obj/item/soulstone/anybody(src)
		if(4)
			new /obj/item/katana/cursed(src)
		if(5)
			new /obj/item/clothing/glasses/godeye(src)
		if(6)
			new /obj/item/pickaxe/diamond(src)
		if(7)
			new /obj/item/clothing/suit/hooded/cultrobes(src)
			new /obj/item/bedsheet/cult(src)
		if(8)
			if(prob(50))
				new /obj/item/disk/design_disk/modkit_disc/resonator_blast(src)
			else
				new /obj/item/disk/design_disk/modkit_disc/rapid_repeater(src)
		if(9)
			new /obj/item/organ/internal/heart/cursed/wizard(src)
		if(10)
			new /obj/item/ship_in_a_bottle(src)
		if(11)
			new /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/berserker(src)
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/berserker(src)
		if(12)
			new /obj/item/sord(src)
		if(13)
			new /obj/item/nullrod/scythe/talking(src)
		if(14)
			new /obj/item/nullrod/armblade(src)
		if(15)
			new /obj/item/guardiancreator(src)
		if(16)
			new /obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe(src)
		if(17)
			new /obj/item/warp_cube/red(src)
		if(18)
			new /obj/item/wisp_lantern(src)
		if(19)
			new /obj/item/immortality_talisman(src)
		if(20)
			new /obj/item/gun/magic/hook(src)
		if(21)
			new /obj/item/voodoo(src)
		if(22)
			new /obj/item/grenade/clusterbuster/inferno(src)
		if(23)
			new /obj/item/reagent_containers/food/drinks/bottle/holywater/hell(src)
			new /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor(src)
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor(src)
		if(24)
			new /obj/item/spellbook/oneuse/summonitem(src)
		if(25)
			new /obj/item/borg/upgrade/modkit/lifesteal(src)
			new /obj/item/bedsheet/cult(src)

/obj/structure/closet/crate/necropolis/puzzle
	name = "puzzling chest"

/obj/structure/closet/crate/necropolis/puzzle/New()
	..(FALSE)

	var/loot = rand(1,3)
	switch(loot)
		if(1)
			new /obj/item/soulstone/anybody(src)
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

/datum/design/unique_modkit
	category = list("Mining", "Cyborg Upgrade Modules") //can't be normally obtained
	build_type = PROTOLATHE | MECHFAB

/datum/design/unique_modkit/offensive_turf_aoe
	name = "Kinetic Accelerator Offensive Mining Explosion Mod"
	desc = "A device which causes kinetic accelerators to fire AoE blasts that destroy rock and damage creatures."
	id = "hyperaoemod"
	materials = list(MAT_METAL = 7000, MAT_GLASS = 3000, MAT_SILVER= 3000, MAT_GOLD = 3000, MAT_DIAMOND = 4000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs

/datum/design/unique_modkit/rapid_repeater
	name = "Kinetic Accelerator Rapid Repeater Mod"
	desc = "A device which greatly reduces a kinetic accelerator's cooldown on striking a living target or rock, but greatly increases its base cooldown."
	id = "repeatermod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_URANIUM = 8000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown/repeater

/datum/design/unique_modkit/resonator_blast
	name = "Kinetic Accelerator Resonator Blast Mod"
	desc = "A device which causes kinetic accelerators to fire shots that leave and detonate resonator blasts."
	id = "resonatormod"
	materials = list(MAT_METAL = 5000, MAT_GLASS = 5000, MAT_SILVER= 5000, MAT_URANIUM = 5000)
	build_path = /obj/item/borg/upgrade/modkit/resonator_blasts