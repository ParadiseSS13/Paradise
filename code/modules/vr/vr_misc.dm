/obj/machinery/vr_medical_dummy
	name = "human dummy spawner"
	desc = "Press to make a medical dummy for all your medical practice needs."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	anchored = 1.0
	var/mob/living/carbon/human/dummy = /mob/living/carbon/human
	var/cooldown = 0

/obj/machinery/vr_medical_dummy/attack_hand(mob/user as mob)
	if(cooldown > world.time)
		to_chat(user, "Querying medical database for the next [round((cooldown-world.time)/10)] seconds. Please wait.")
	else
		var/mob/living/carbon/human/medical_dummy
		var/S = input(user, "Choose a Species for your medical dummy.","Select Species") as null|anything in all_species
		if(!S)
			return 0
		medical_dummy = new dummy(loc)
		medical_dummy.set_species(S)
		if(medical_dummy.species.name == "Plasmaman")
			medical_dummy.equip_or_collect(new /obj/item/weapon/storage/backpack(medical_dummy), slot_back)
		medical_dummy.species.after_equip_job(null, medical_dummy)
		icon_state = "doorctrl1"
		cooldown = world.time + 1 MINUTES
		spawn(1 MINUTES)
			icon_state = "doorctrl0"

/obj/item/device/radio/headset/vr
	name = "vr radio headset"
	desc = "Your link to the world that you once knew."
	ks2type = /obj/item/device/encryptionkey/headset_vr

/obj/item/device/encryptionkey/headset_vr
	name = "Virtual Reality Radio Encryption Key"
//	channels = list("VR" = 1)