/obj/structure/closet/secure_closet/medical1
	name = "medicine closet"
	desc = "Filled with medical junk."
	icon_state = "med"
	open_door_sprite = "med_door"
	icon_opened = "med_open"
	req_access = list(ACCESS_MEDICAL)

/obj/structure/closet/secure_closet/medical1/populate_contents()
	new /obj/item/storage/box/autoinjectors(src)
	new /obj/item/storage/box/syringes(src)
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/patch_packs(src)
	new /obj/item/storage/box/iv_bags(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/bottle/epinephrine(src)
	new /obj/item/reagent_containers/glass/bottle/epinephrine(src)
	new /obj/item/reagent_containers/glass/bottle/charcoal(src)
	new /obj/item/reagent_containers/glass/bottle/charcoal(src)

/obj/structure/closet/secure_closet/medical2
	name = "anesthetic locker"
	desc = "Used to knock people out."
	icon_state = "med"
	open_door_sprite = "med_door"
	icon_opened = "med_open"
	req_access = list(ACCESS_SURGERY)

/obj/structure/closet/secure_closet/medical2/populate_contents()
	new /obj/item/tank/internals/anesthetic(src)
	new /obj/item/tank/internals/anesthetic(src)
	new /obj/item/tank/internals/anesthetic(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)


/obj/structure/closet/secure_closet/medical3
	name = "medical doctor's locker"
	req_access = list(ACCESS_MEDICAL)
	icon_state = "med_secure"
	open_door_sprite = "white_secure_door"

/obj/structure/closet/secure_closet/medical3/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	new /obj/item/clothing/under/rank/medical/doctor(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/shoes/sandal/white(src)


//Exam Room
/obj/structure/closet/secure_closet/exam
	name = "exam room closet"
	desc = "Filled with exam room materials."
	icon_state = "med"
	open_door_sprite = "med_door"
	icon_opened = "med_open"
	req_access = list(ACCESS_MEDICAL)

/obj/structure/closet/secure_closet/exam/populate_contents()
	new /obj/item/storage/box/syringes(src)
	new /obj/item/reagent_containers/dropper(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/clothing/accessory/stethoscope(src)
	new /obj/item/flashlight/pen(src)
	new /obj/item/storage/firstaid/regular(src)
	new /obj/item/storage/firstaid/adv(src)
	new /obj/item/storage/firstaid/brute(src)
	new /obj/item/storage/firstaid/fire(src)
	new /obj/item/storage/firstaid/o2(src)
	new /obj/item/storage/firstaid/toxin(src)


// Psychiatrist's pill bottle
/obj/item/storage/pill_bottle/psychiatrist
	name = "psychiatrist's pill bottle"
	desc = "Contains various pills to calm or sedate patients."
	wrapper_color = COLOR_PALE_BTL_GREEN

// Why the hell is this in the closets folder?
/obj/item/storage/pill_bottle/psychiatrist/populate_contents()
	new /obj/item/reagent_containers/food/pill/haloperidol(src)
	new /obj/item/reagent_containers/food/pill/haloperidol(src)
	new /obj/item/reagent_containers/food/pill/haloperidol(src)
	new /obj/item/reagent_containers/food/pill/methamphetamine(src)
	new /obj/item/reagent_containers/food/pill/methamphetamine(src)
	new /obj/item/reagent_containers/food/pill/methamphetamine(src)
	new /obj/item/reagent_containers/food/pill/happy_psych(src)
	new /obj/item/reagent_containers/food/pill/happy_psych(src)
	new /obj/item/reagent_containers/food/pill/happy_psych(src)
	new /obj/item/reagent_containers/food/pill/patch/nicotine(src)
	new /obj/item/reagent_containers/food/pill/patch/nicotine(src)
	new /obj/item/reagent_containers/food/pill/patch/nicotine(src)
	new /obj/item/reagent_containers/food/pill/hydrocodone(src)
	new /obj/item/reagent_containers/food/pill/hydrocodone(src)
	new /obj/item/reagent_containers/food/pill/mannitol(src)
	new /obj/item/reagent_containers/food/pill/mannitol(src)
	new /obj/item/reagent_containers/food/pill/mannitol(src)
	new /obj/item/reagent_containers/food/pill/mannitol(src)
	new /obj/item/reagent_containers/food/pill/mannitol(src)

/obj/structure/closet/secure_closet/psychiatrist
	name = "psychiatrist's locker"
	req_access = list(ACCESS_PSYCHIATRIST)
	icon_state = "med_secure"
	open_door_sprite = "white_secure_door"

/obj/structure/closet/secure_closet/psychiatrist/populate_contents()
	new /obj/item/storage/bag/garment/psychologist(src)
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/ether(src)
	new /obj/item/clipboard(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_med(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_med(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_med(src)
	new /obj/item/storage/pill_bottle/psychiatrist(src)
	new /obj/random/plushie(src)
	for(var/i in 0 to 3)
		var/candy = pick(subtypesof(/obj/item/reagent_containers/food/snacks/candy/fudge))
		new candy(src)

/obj/structure/closet/secure_closet/CMO
	name = "chief medical officer's locker"
	req_access = list(ACCESS_CMO)
	icon_state = "cmo"
	open_door_sprite = "cmo_door"

/obj/structure/closet/secure_closet/CMO/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	new /obj/item/clothing/suit/bio_suit/cmo(src)
	new /obj/item/clothing/head/bio_hood/cmo(src)
	new /obj/item/storage/bag/garment/chief_medical_officer(src)
	new /obj/item/radio/headset/heads/cmo(src)
	new /obj/item/defibrillator/compact/advanced/loaded(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health/sunglasses(src)
	new /obj/item/flash(src)
	new /obj/item/gun/syringe(src)
	new /obj/item/reagent_containers/hypospray/CMO(src)
	new /obj/item/organ/internal/cyberimp/eyes/hud/medical(src)
	new /obj/item/door_remote/chief_medical_officer(src)
	new /obj/item/reagent_containers/food/drinks/mug/cmo(src)
	new /obj/item/clothing/accessory/medal/medical(src)
	new /obj/item/storage/briefcase(src)
	new /obj/item/clothing/mask/gas(src)


/obj/structure/closet/secure_closet/animal
	name = "animal control locker"
	req_access = list(ACCESS_SURGERY)

/obj/structure/closet/secure_closet/animal/populate_contents()
	new /obj/item/assembly/signaler(src)
	new /obj/item/electropack(src)
	new /obj/item/electropack(src)
	new /obj/item/electropack(src)


/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "chemical"
	open_door_sprite = "med_door"
	icon_opened = "med_open"
	req_access = list(ACCESS_CHEMISTRY)

/obj/structure/closet/secure_closet/chemical/populate_contents()
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/patch_packs(src)
	new /obj/item/storage/box/patch_packs(src)

/obj/structure/closet/secure_closet/paramedic
	name = "paramedic EVA gear"
	desc = "A locker with a Rescue MODsuit."
	icon_state = "med"
	open_door_sprite = "med_door"
	icon_opened = "med_open"
	req_access = list(ACCESS_PARAMEDIC)

/obj/structure/closet/secure_closet/paramedic/populate_contents()
	new /obj/item/radio/headset/headset_med/para(src)
	new /obj/item/mod/control/pre_equipped/rescue(src)
	new /obj/item/key/ambulance(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/storage/bag/garment/paramedic(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/firstaid/adv(src)
	new /obj/item/storage/toolbox/emergency(src)
	new /obj/item/fulton_core(src)
	new /obj/item/extraction_pack(src)
	new /obj/item/gps/mining(src)
	new /obj/item/pickaxe/drill(src)

/obj/structure/closet/secure_closet/reagents
	name = "chemical storage closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "chemical"
	open_door_sprite = "med_door"
	icon_opened = "med_open"
	req_access = list(ACCESS_CHEMISTRY)

/obj/structure/closet/secure_closet/reagents/populate_contents()
	new /obj/item/reagent_containers/glass/bottle/reagent/phenol(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/ammonia(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/oil(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/acetone(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/acid(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/diethylamine(src)
