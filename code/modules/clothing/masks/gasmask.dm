/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply."
	icon_state = "gas_alt"
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	w_class = 3
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	burn_state = FIRE_PROOF
	species_fit = list("Vox", "Unathi", "Tajaran", "Vulpkanin")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/mask.dmi',
		"Drask" = 'icons/mob/species/drask/mask.dmi'
		)

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "welding mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	icon_state = "weldingmask"
	item_state = "weldingmask"
	materials = list(MAT_METAL=4000, MAT_GLASS=2000)
	flash_protect = 2
	tint = 2
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	origin_tech = "materials=2;engineering=2"
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/mask/gas/welding/attack_self()
	toggle()

/obj/item/clothing/mask/gas/welding/proc/toggle()
	if(up)
		up = !src.up
		flags |= (MASKCOVERSEYES)
		flags_inv |= (HIDEEYES)
		icon_state = initial(icon_state)
		to_chat(usr, "You flip the [src] down to protect your eyes.")
		flash_protect = 2
		tint = 2
	else
		up = !up
		flags &= ~(MASKCOVERSEYES)
		flags_inv &= ~(HIDEEYES)
		icon_state = "[initial(icon_state)]up"
		to_chat(usr, "You push the [src] up out of your face.")
		flash_protect = 0
		tint = 0
	usr.update_inv_wear_mask()	//so our mob-overlays update

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

//Bane gas mask
/obj/item/clothing/mask/banemask
	name = "bane mask"
	desc = "Only when the station is in flames, do you have my permission to robust."
	icon_state = "bane_mask"
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	w_class = 3
	item_state = "bane_mask"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01


//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out toxins but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list(melee = 0, bullet = 0, laser = 2, energy = 2, bomb = 0, bio = 75, rad = 0)

/obj/item/clothing/mask/gas/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "swat"
	strip_delay = 60

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | BLOCKHAIR
	burn_state = FLAMMABLE

/obj/item/clothing/mask/gas/clown_hat/attack_self(mob/user)

	var/mob/M = usr
	var/list/options = list()
	options["True Form"] = "clown"
	options["The Feminist"] = "sexyclown"
	options["The Madman"] = "joker"
	options["The Rainbow Color"] ="rainbow"

	var/choice = input(M,"To what form do you wish to Morph this mask?","Morph Mask") in options

	if(src && choice && !M.stat && in_range(M,src))
		icon_state = options[choice]
		to_chat(M, "Your Clown Mask has now morphed into [choice], all praise the Honk Mother!")
		return 1

/obj/item/clothing/mask/gas/clownwiz
	name = "wizard clown wig and mask"
	desc = "Some pranksters are truly magical."
	icon_state = "wizzclown"
	item_state = "wizzclown"
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | BLOCKHAIR

/obj/item/clothing/mask/gas/virusclown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	icon_state = "clown"
	item_state = "clown_hat"

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	icon_state = "sexyclown"
	item_state = "sexyclown"
	burn_state = FLAMMABLE

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	item_state = "mime"
	burn_state = FLAMMABLE

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon_state = "monkeymask"
	item_state = "monkeymask"
	burn_state = FLAMMABLE

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	icon_state = "sexymime"
	item_state = "sexymime"
	burn_state = FLAMMABLE

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop"
	icon_state = "death"
	burn_state = FLAMMABLE

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT
	burn_state = FLAMMABLE
	actions_types = list(/datum/action/item_action/hoot)

/obj/item/clothing/mask/gas/owl_mask/super_hero
	flags = MASKCOVERSMOUTH | MASKCOVERSEYES | BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | NODROP

/obj/item/clothing/mask/gas/owl_mask/attack_self()
	hoot()

/obj/item/clothing/mask/gas/owl_mask/proc/hoot()
	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		playsound(src.loc, "sound/misc/hoot.ogg", 50, 1)
		cooldown = world.time

// ********************************************************************

// **** Security gas mask ****

/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device, plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you taze them. Do not tamper with the device."
	icon_state = "sechailer"
	var/phrase = 1
	var/aggressiveness = 1
	var/safety = 1
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/hos
	name = "\improper HOS SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000. It has a tan stripe."
	icon_state = "hosmask"
	aggressiveness = 3
	phrase = 12
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/warden
	name = "\improper Warden SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000. It has a blue stripe."
	icon_state = "wardenmask"
	aggressiveness = 3
	phrase = 12
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)


/obj/item/clothing/mask/gas/sechailer/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000."
	icon_state = "officermask"
	aggressiveness = 3
	phrase = 12
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/blue
	name = "\improper blue SWAT mask"
	desc = "A neon blue swat mask, used for demoralizing Greytide in the wild."
	icon_state = "blue_sechailer"
	item_state = "blue_sechailer"
	aggressiveness = 3
	phrase = 12
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/cyborg
	name = "security hailer"
	desc = "A set of recognizable pre-recorded messages for cyborgs to use when apprehending criminals."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_idle"
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/halt)
		halt()
	else if(actiontype == /datum/action/item_action/adjust)
		adjustmask(user)
	else if(actiontype == /datum/action/item_action/selectphrase)
		switch(aggressiveness)
			if(1)
				switch(phrase)
					if(1)
						to_chat(user, "<span class='notice'>You set the restrictor to: Stop in the name of the Law.</span>")
						phrase = 2
					if(2)
						to_chat(user, "<span class='notice'>You set the restrictor to: Compliance is in your best interest.</span>")
						phrase = 3
					if(3)
						to_chat(user, "<span class='notice'>You set the restrictor to: Prepare for justice.</span>")
						phrase = 4
					if(4)
						to_chat(user, "<span class='notice'>You set the restrictor to: Running will only increase your sentence.</span>")
						phrase = 5
					if(5)
						to_chat(user, "<span class='notice'>You set the restrictor to: Don't move, Creep!</span>")
						phrase = 6
					if(6)
						to_chat(user, "<span class='notice'>You set the restrictor to: HALT! HALT! HALT! HALT!</span>")
						phrase = 1
					else
						to_chat(user, "<span class='notice'>You set the restrictor to: HALT! HALT! HALT! HALT!</span>")
						phrase = 1
			if(2)
				switch(phrase)
					if(7)
						to_chat(user, "<span class='notice'>You set the restrictor to: Dead or alive you're coming with me.</span>")
						phrase = 8
					if(8)
						to_chat(user, "<span class='notice'>You set the restrictor to: God made today for the crooks we could not catch yesterday.</span>")
						phrase = 9
					if(9)
						to_chat(user, "<span class='notice'>You set the restrictor to: Freeze, Scum Bag!</span>")
						phrase = 10
					if(10)
						to_chat(user, "<span class='notice'>You set the restrictor to: Stop right there, criminal scum!</span>")
						phrase = 11
					if(11)
						to_chat(user, "<span class='notice'>You set the restrictor to: Down on the floor, Creep!</span>")
						phrase = 7
					else
						to_chat(user, "<span class='notice'>You set the restrictor to: Down on the floor, Creep!</span>")
						phrase = 7
			if(3)
				switch(phrase)
					if(12)
						to_chat(user, "<span class='notice'>You set the restrictor to: Go ahead, make my day.</span>")
						phrase = 13
					if(13)
						to_chat(user, "<span class='notice'>You set the restrictor to: Stop breaking the law, ass hole.</span>")
						phrase = 14
					if(14)
						to_chat(user, "<span class='notice'>You set the restrictor to: You have the right to shut the fuck up.</span>")
						phrase = 15
					if(15)
						to_chat(user, "<span class='notice'>You set the restrictor to: Shut up crime!</span>")
						phrase = 16
					if(16)
						to_chat(user, "<span class='notice'>You set the restrictor to: Face the wrath of the golden bolt.</span>")
						phrase = 17
					if(17)
						to_chat(user, "<span class='notice'>You set the restrictor to: I am, the LAW!</span>")
						phrase = 18
					if(18)
						to_chat(user, "<span class='notice'>You set the restrictor to: Stop or I'll bash you.</span>")
						phrase = 12
					else
						to_chat(user, "<span class='notice'>You set the restrictor to: Go ahead, make my day.</span>")
						phrase = 13

			if(4)
				switch(phrase)
					if(1)
						to_chat(user, "<span class='notice'>You set the restrictor to: Stop in the name of the Law.</span>")
						phrase = 2
					if(2)
						to_chat(user, "<span class='notice'>You set the restrictor to: Compliance is in your best interest.</span>")
						phrase = 3
					if(3)
						to_chat(user, "<span class='notice'>You set the restrictor to: Prepare for justice.</span>")
						phrase = 4
					if(4)
						to_chat(user, "<span class='notice'>You set the restrictor to: Running will only increase your sentence.</span>")
						phrase = 5
					if(5)
						to_chat(user, "<span class='notice'>You set the restrictor to: Don't move, Creep!</span>")
						phrase = 6
					if(6)
						to_chat(user, "<span class='notice'>You set the restrictor to: Down on the floor, Creep!</span>")
						phrase = 7
					if(7)
						to_chat(user, "<span class='notice'>You set the restrictor to: Dead or alive you're coming with me.</span>")
						phrase = 8
					if(8)
						to_chat(user, "<span class='notice'>You set the restrictor to: God made today for the crooks we could not catch yesterday.</span>")
						phrase = 9
					if(9)
						to_chat(user, "<span class='notice'>You set the restrictor to: Freeze, Scum Bag!</span>")
						phrase = 10
					if(10)
						to_chat(user, "<span class='notice'>You set the restrictor to: Stop right there, criminal scum!</span>")
						phrase = 11
					if(11)
						to_chat(user, "<span class='notice'>You set the restrictor to: Stop or I'll bash you.</span>")
						phrase = 12
					if(12)
						to_chat(user, "<span class='notice'>You set the restrictor to: Go ahead, make my day.</span>")
						phrase = 13
					if(13)
						to_chat(user, "<span class='notice'>You set the restrictor to: Stop breaking the law, ass hole.</span>")
						phrase = 14
					if(14)
						to_chat(user, "<span class='notice'>You set the restrictor to: You have the right to shut the fuck up.</span>")
						phrase = 15
					if(15)
						to_chat(user, "<span class='notice'>You set the restrictor to: Shut up crime!</span>")
						phrase = 16
					if(16)
						to_chat(user, "<span class='notice'>You set the restrictor to: Face the wrath of the golden bolt.</span>")
						phrase = 17
					if(17)
						to_chat(user, "<span class='notice'>You set the restrictor to: I am, the LAW!</span>")
						phrase = 18
					if(18)
						to_chat(user, "<span class='notice'>You set the restrictor to: HALT! HALT! HALT! HALT!</span>")
						phrase = 1
			else
				to_chat(user, "<span class='notice'>It's broken.</span>")

/obj/item/clothing/mask/gas/sechailer/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		switch(aggressiveness)
			if(1)
				to_chat(user, "\blue You set the aggressiveness restrictor to the second position.")
				aggressiveness = 2
				phrase = 7
			if(2)
				to_chat(user, "\blue You set the aggressiveness restrictor to the third position.")
				aggressiveness = 3
				phrase = 13
			if(3)
				to_chat(user, "\blue You set the aggressiveness restrictor to the fourth position.")
				aggressiveness = 4
				phrase = 1
			if(4)
				to_chat(user, "\blue You set the aggressiveness restrictor to the first position.")
				aggressiveness = 1
				phrase = 1
			if(5)
				to_chat(user, "\red You adjust the restrictor but nothing happens, probably because its broken.")
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(aggressiveness != 5)
			to_chat(user, "\red You broke it!")
			aggressiveness = 5
	else
		..()

/obj/item/clothing/mask/gas/sechailer/attack_self()
	halt()

/obj/item/clothing/mask/gas/sechailer/emag_act(mob/user as mob)
	if(safety)
		safety = 0
		to_chat(user, "<span class='warning'>You silently fry [src]'s vocal circuit with the cryptographic sequencer.")
	else
		return

/obj/item/clothing/mask/gas/sechailer/proc/halt()
	var/phrase_text = null
	var/phrase_sound = null


	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		if(!safety)
			phrase_text = "FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND DO SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT."
			usr.visible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[phrase_text]</b></font>")
			playsound(src.loc, 'sound/voice/binsult.ogg', 100, 0, 4)
			cooldown = world.time
			return


		switch(phrase)	//sets the properties of the chosen phrase
			if(1)				// good cop
				phrase_text = "HALT! HALT! HALT! HALT!"
				phrase_sound = "halt"
			if(2)
				phrase_text = "Stop in the name of the Law."
				phrase_sound = "bobby"
			if(3)
				phrase_text = "Compliance is in your best interest."
				phrase_sound = "compliance"
			if(4)
				phrase_text = "Prepare for justice!"
				phrase_sound = "justice"
			if(5)
				phrase_text = "Running will only increase your sentence."
				phrase_sound = "running"
			if(6)				// bad cop
				phrase_text = "Don't move, Creep!"
				phrase_sound = "dontmove"
			if(7)
				phrase_text = "Down on the floor, Creep!"
				phrase_sound = "floor"
			if(8)
				phrase_text = "Dead or alive you're coming with me."
				phrase_sound = "robocop"
			if(9)
				phrase_text = "God made today for the crooks we could not catch yesterday."
				phrase_sound = "god"
			if(10)
				phrase_text = "Freeze, Scum Bag!"
				phrase_sound = "freeze"
			if(11)
				phrase_text = "Stop right there, criminal scum!"
				phrase_sound = "imperial"
			if(12)				// LA-PD
				phrase_text = "Stop or I'll bash you."
				phrase_sound = "bash"
			if(13)
				phrase_text = "Go ahead, make my day."
				phrase_sound = "harry"
			if(14)
				phrase_text = "Stop breaking the law, ass hole."
				phrase_sound = "asshole"
			if(15)
				phrase_text = "You have the right to shut the fuck up."
				phrase_sound = "stfu"
			if(16)
				phrase_text = "Shut up crime!"
				phrase_sound = "shutup"
			if(17)
				phrase_text = "Face the wrath of the golden bolt."
				phrase_sound = "super"
			if(18)
				phrase_text = "I am, the LAW!"
				phrase_sound = "dredd"

		usr.visible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[phrase_text]</b></font>")
		playsound(src.loc, "sound/voice/complionator/[phrase_sound].ogg", 100, 0, 4)
		cooldown = world.time



// ********************************************************************

