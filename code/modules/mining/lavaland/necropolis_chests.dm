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

/obj/structure/closet/crate/necropolis/tendril/New()
	..()
	var/loot = rand(1,24)
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
			new /obj/item/clothing/head/culthood(src)
			new /obj/item/clothing/suit/hooded/cultrobes(src)
			new /obj/item/bedsheet/cult(src)
		if(8)
			new /obj/item/organ/internal/brain/xeno(src)
		if(9)
			new /obj/item/organ/internal/heart/cursed(src)
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
			new /obj/item/borg/upgrade/modkit/aoe/turfs/andmobs(src)
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