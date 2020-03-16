/obj/structure/closet/secure_closet/medical1
	name = "medicine closet"
	desc = "Filled with medical junk."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_medical)

/obj/structure/closet/secure_closet/medical1/New()
	..()
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
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_surgery)

/obj/structure/closet/secure_closet/medical2/New()
	..()
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/tank/anesthetic(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)
	new /obj/item/clothing/mask/breath/medical(src)


/obj/structure/closet/secure_closet/medical3
	name = "medical doctor's locker"
	req_access = list(access_surgery)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemedoff"

/obj/structure/closet/secure_closet/medical3/New()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/radio/headset/headset_med(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/shoes/sandal/white(src)


//Exam Room
/obj/structure/closet/secure_closet/exam
	name = "exam room closet"
	desc = "Filled with exam room materials."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_medical)

/obj/structure/closet/secure_closet/exam/New()
	..()
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

/obj/item/storage/pill_bottle/psychiatrist/New()
	..()
	new /obj/item/reagent_containers/food/pill/haloperidol(src)
	new /obj/item/reagent_containers/food/pill/haloperidol(src)
	new /obj/item/reagent_containers/food/pill/haloperidol(src)
	new /obj/item/reagent_containers/food/pill/methamphetamine(src)
	new /obj/item/reagent_containers/food/pill/methamphetamine(src)
	new /obj/item/reagent_containers/food/pill/methamphetamine(src)
	new /obj/item/reagent_containers/food/pill/patch/nicotine(src)
	new /obj/item/reagent_containers/food/pill/patch/nicotine(src)
	new /obj/item/reagent_containers/food/pill/patch/nicotine(src)
	new /obj/item/reagent_containers/food/pill/hydrocodone(src)
	new /obj/item/reagent_containers/food/pill/hydrocodone(src)

/obj/structure/closet/secure_closet/psychiatrist
	name = "psychiatrist's locker"
	req_access = list(access_psychiatrist)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemedoff"

/obj/structure/closet/secure_closet/psychiatrist/New()
	..()
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/ether(src)
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
	req_access = list(access_cmo)
	icon_state = "cmosecure1"
	icon_closed = "cmosecure"
	icon_locked = "cmosecure1"
	icon_opened = "cmosecureopen"
	icon_broken = "cmosecurebroken"
	icon_off = "cmosecureoff"

/obj/structure/closet/secure_closet/CMO/New()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/medic(src)
	else
		new /obj/item/storage/backpack/satchel_med(src)
	new /obj/item/storage/backpack/duffel/medical(src)
	new /obj/item/clothing/suit/bio_suit/cmo(src)
	new /obj/item/clothing/head/bio_hood/cmo(src)
	new /obj/item/clothing/shoes/white(src)
	switch(pick("blue", "green", "purple"))
		if("blue")
			new /obj/item/clothing/under/rank/medical/blue(src)
			new /obj/item/clothing/head/surgery/blue(src)
		if("green")
			new /obj/item/clothing/under/rank/medical/green(src)
			new /obj/item/clothing/head/surgery/green(src)
		if("purple")
			new /obj/item/clothing/under/rank/medical/purple(src)
			new /obj/item/clothing/head/surgery/purple(src)
	new /obj/item/clothing/suit/storage/labcoat/cmo(src)
	new /obj/item/clothing/under/rank/chief_medical_officer(src)
	new /obj/item/clothing/suit/mantle/labcoat/chief_medical_officer(src)
	new /obj/item/clothing/shoes/brown	(src)
	new /obj/item/radio/headset/heads/cmo(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/defibrillator/compact/loaded(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/flash(src)
	new /obj/item/reagent_containers/hypospray/CMO(src)
	new /obj/item/organ/internal/cyberimp/eyes/hud/medical(src)
	new /obj/item/door_remote/chief_medical_officer(src)
	new /obj/item/reagent_containers/food/drinks/mug/cmo(src)
	new /obj/item/clothing/accessory/medal/medical(src)


/obj/structure/closet/secure_closet/animal
	name = "animal control locker"
	req_access = list(access_surgery)

/obj/structure/closet/secure_closet/animal/New()
	..()
	new /obj/item/assembly/signaler(src)
	new /obj/item/radio/electropack(src)
	new /obj/item/radio/electropack(src)
	new /obj/item/radio/electropack(src)


/obj/structure/closet/secure_closet/chemical
	name = "chemical closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_chemistry)

/obj/structure/closet/secure_closet/chemical/New()
	..()
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/pillbottles(src)
	new /obj/item/storage/box/patch_packs(src)
	new /obj/item/storage/box/patch_packs(src)


/obj/structure/closet/secure_closet/medical_wall
	name = "first aid closet"
	desc = "It's a secure wall-mounted storage unit for first aid supplies."
	icon_state = "medical_wall_locked"
	icon_closed = "medical_wall_unlocked"
	icon_locked = "medical_wall_locked"
	icon_opened = "medical_wall_open"
	icon_broken = "medical_wall_spark"
	icon_off = "medical_wall_off"
	anchored = 1
	density = 0
	wall_mounted = 1
	req_access = list(access_medical)

/obj/structure/closet/secure_closet/medical_wall/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/paramedic
	name = "paramedic EVA gear"
	desc = "A locker with a Paramedic EVA suit."
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medicaloff"
	req_access = list(access_paramedic)

/obj/structure/closet/secure_closet/paramedic/New()
	..()
	new /obj/item/clothing/suit/space/eva/paramedic(src)
	new /obj/item/clothing/head/helmet/space/eva/paramedic(src)
	new /obj/item/sensor_device(src)
	new /obj/item/key/ambulance(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/handheld_defibrillator(src)

/obj/structure/closet/secure_closet/reagents
	name = "chemical storage closet"
	desc = "Store dangerous chemicals in here."
	icon_state = "chemical1"
	icon_closed = "chemical"
	icon_locked = "chemical1"
	icon_opened = "medicalopen"
	icon_broken = "chemicalbroken"
	icon_off = "chemicaloff"
	req_access = list(access_chemistry)

/obj/structure/closet/secure_closet/reagents/New()
	..()
	new /obj/item/reagent_containers/glass/bottle/reagent/phenol(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/ammonia(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/oil(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/acetone(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/acid(src)
	new /obj/item/reagent_containers/glass/bottle/reagent/diethylamine(src)
