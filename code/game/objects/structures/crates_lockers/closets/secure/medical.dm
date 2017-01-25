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


	New()
		..()
		new /obj/item/weapon/storage/box/autoinjectors(src)
		new /obj/item/weapon/storage/box/syringes(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
		new /obj/item/weapon/reagent_containers/glass/beaker(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/epinephrine(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/epinephrine(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/charcoal(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/charcoal(src)



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


	New()
		..()
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/weapon/tank/anesthetic(src)
		new /obj/item/weapon/tank/anesthetic(src)
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

	New()
		..()
		if(prob(50))
			new /obj/item/weapon/storage/backpack/medic(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_med(src)
		new /obj/item/weapon/storage/backpack/duffel/medical(src)
		new /obj/item/clothing/under/rank/medical(src)
		new /obj/item/clothing/suit/storage/labcoat(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/device/radio/headset/headset_med(src)
		new /obj/item/clothing/gloves/color/latex/nitrile(src)
		new /obj/item/weapon/defibrillator/loaded(src)
		new /obj/item/weapon/storage/belt/medical(src)
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


	New()
		..()
		new /obj/item/weapon/storage/box/syringes(src)
		new /obj/item/weapon/reagent_containers/dropper(src)
		new /obj/item/weapon/storage/belt/medical(src)
		new /obj/item/clothing/mask/surgical(src)
		new /obj/item/clothing/glasses/hud/health(src)
		new /obj/item/clothing/gloves/color/latex/nitrile(src)
		new /obj/item/clothing/accessory/stethoscope(src)
		new /obj/item/device/flashlight/pen(src)
		new /obj/item/weapon/storage/firstaid/regular(src)
		new /obj/item/weapon/storage/firstaid/adv(src)
		new /obj/item/weapon/storage/firstaid/brute(src)
		new /obj/item/weapon/storage/firstaid/fire(src)
		new /obj/item/weapon/storage/firstaid/o2(src)
		new /obj/item/weapon/storage/firstaid/toxin(src)


// Psychiatrist's pill bottle
/obj/item/weapon/storage/pill_bottle/psychiatrist
	name = "psychiatrist's pill bottle"
	desc = "Contains various pills to calm or sedate patients."

/obj/item/weapon/storage/pill_bottle/psychiatrist/New()
	..()
	new /obj/item/weapon/reagent_containers/food/pill/haloperidol(src)
	new /obj/item/weapon/reagent_containers/food/pill/haloperidol(src)
	new /obj/item/weapon/reagent_containers/food/pill/methamphetamine(src)
	new /obj/item/weapon/reagent_containers/food/pill/methamphetamine(src)

/obj/structure/closet/secure_closet/psychiatrist
	name = "psychiatrist's locker"
	req_access = list(access_psychiatrist)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemedoff"

	New()
		..()
		new /obj/item/clothing/suit/straight_jacket(src)
		new /obj/item/weapon/reagent_containers/syringe(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/ether(src)
		new /obj/item/weapon/storage/pill_bottle/psychiatrist(src)

/obj/structure/closet/secure_closet/CMO
	name = "chief medical officer's locker"
	req_access = list(access_cmo)
	icon_state = "cmosecure1"
	icon_closed = "cmosecure"
	icon_locked = "cmosecure1"
	icon_opened = "cmosecureopen"
	icon_broken = "cmosecurebroken"
	icon_off = "cmosecureoff"

	New()
		..()
		if(prob(50))
			new /obj/item/weapon/storage/backpack/medic(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_med(src)
		new /obj/item/weapon/storage/backpack/duffel/medical(src)
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
		new /obj/item/clothing/shoes/brown	(src)
		new /obj/item/device/radio/headset/heads/cmo(src)
		new /obj/item/clothing/gloves/color/latex/nitrile(src)
		new /obj/item/weapon/defibrillator/compact/loaded(src)
		new /obj/item/weapon/storage/belt/medical(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/reagent_containers/hypospray/CMO(src)
		new /obj/item/organ/internal/cyberimp/eyes/hud/medical(src)
		new /obj/item/weapon/door_remote/chief_medical_officer(src)



/obj/structure/closet/secure_closet/animal
	name = "animal control locker"
	req_access = list(access_surgery)


	New()
		..()
		new /obj/item/device/assembly/signaler(src)
		new /obj/item/device/radio/electropack(src)
		new /obj/item/device/radio/electropack(src)
		new /obj/item/device/radio/electropack(src)



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


	New()
		..()
		new /obj/item/weapon/storage/box/pillbottles(src)
		new /obj/item/weapon/storage/box/pillbottles(src)

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


	New()
		..()
		new /obj/item/clothing/suit/space/eva/paramedic(src)
		new /obj/item/clothing/head/helmet/space/eva/paramedic(src)
		new /obj/item/clothing/head/helmet/space/eva/paramedic(src)
		new /obj/item/device/sensor_device(src)

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


	New()
		..()
		new /obj/item/weapon/reagent_containers/glass/bottle/reagent/phenol(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/reagent/ammonia(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/reagent/oil(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/reagent/acetone(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/reagent/acid(src)
		new /obj/item/weapon/reagent_containers/glass/bottle/reagent/diethylamine(src)
