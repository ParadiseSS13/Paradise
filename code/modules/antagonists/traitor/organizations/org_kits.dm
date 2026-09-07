/obj/item/storage/box/syndie_kit/faid_hacking_kit
	desc = "It's just an ordinary box."
	icon_state = "box"

/obj/item/storage/box/syndie_kit/faid_hacking_kit/populate_contents()
	new /obj/item/malware_injector(src)
	new /obj/item/paper/guides/antag/malware_injecting(src)

/obj/item/paper/guides/antag/malware_injecting
	info = "<b>The Malware Injector And You</b><hr /> \
		Congratulations, agent! You've been chosen to plant malware in something of Nanotrasen's. Here's how to do it:<br> \
		1. Get access to the device you need to hack.<br> \
		2. Use the malware injector on the device. Don't lose it!<br>\
		3. Wait for the automated systems to finish injecting malware into the systems.<br> \
		4. Get out of there!<br> \
		Warning: The malware typically results in side effects that are noticable for the crew. <br> \
		Don't stick around, unless you want to get caught!"

/obj/item/storage/box/syndie_kit/cybersun_implant_kit
	desc = "It's just an ordinary box."
	icon_state = "box"

/obj/item/storage/box/syndie_kit/cybersun_implant_kit/populate_contents()
	var/obj/item/I = pick(/obj/item/organ/internal/cyberimp/chest/nutriment/sus, /obj/item/organ/internal/cyberimp/arm/gun/laser/sus,
		/obj/item/organ/internal/cyberimp/chest/nutriment/death_alarm)
	new I(src)
	new /obj/item/paper/guides/antag/implant_experimenting(src)

/obj/item/paper/guides/antag/implant_experimenting
	info = "<b>Experimenting on the Crew</b><hr /> \
		Congratulations, agent! You've been chosen to test a cutting-edge implant. Here's how to do it:<br> \
		1. Acquire a test subject, willing or unwilling.<br> \
		2. Start an organ manipulation surgery on the correct body part.<br>\
		3. Add the implant and close the incision.<br> \
		4. Stand back and watch!<br> \
		The implants are highly experimental, so it's likely to have some side effects. <br> \
		Feel free to take notes!"

/obj/item/storage/box/syndie_kit/interdyne_chemical_kit
	desc = "It's just an ordinary box."
	icon_state = "box"

/obj/item/storage/box/syndie_kit/interdyne_chemical_kit/populate_contents()
	new /obj/item/reagent_containers/glass/bottle/experiment(src)
	new /obj/item/paper/guides/antag/chemical_experimenting(src)

/obj/item/paper/guides/antag/chemical_experimenting
	info = "<b>Experimenting on the Crew</b><hr /> \
		Congratulations, agent! You've been chosen to test a cutting-edge chemical. Here's how to do it:<br> \
		1. Acquire a test subject, willing or unwilling.<br> \
		2. Ensure the chemical makes it to their bloodstream.<br>\
		3. Stand back and watch!<br> \
		The chemicals are highly experimental, so it's likely to have some side effects. <br> \
		Feel free to take notes!"

/obj/item/storage/box/syndie_kit/arc_kidnap_kit
	desc = "It's just an ordinary box."
	icon_state = "box"

/obj/item/storage/box/syndie_kit/arc_kidnap_kit/populate_contents()
	new /obj/item/wormhole_jaunter/kidnap

/obj/item/paper/guides/antag/pet_kidnapping
	info = "<b>Freeing Station Pets</b><hr /> \
		Congratulations, agent! You've been chosen to free one of the station's pets from Nanotrasen's cruel ownership. Here's how to do it:<br> \
		1. Acquire your target.<br> \
		2. Proceed to one of the extraction locations inscribed on the flare included in this box.<br>\
		3. Light the flare. The portal will take 30 seconds to calibrate.<br> \
		4. Place the target into the portal.<br> \
		The pet will be taken care of.<br> \
		WARNING: The portal will only remain for 30 seconds. Do not lose the flare, and do not take too long."
