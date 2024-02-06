/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply."
	icon_state = "gas_alt"
	flags = BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	resistance_flags = NONE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Plasmaman" = 'icons/mob/clothing/species/plasmaman/mask.dmi'
		)

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "welding mask"
	desc = "A gas mask with built in welding goggles and face shield. Looks like a skull, clearly designed by a nerd."
	icon_state = "weldingmask"
	item_state = "weldingmask"
	materials = list(MAT_METAL=4000, MAT_GLASS=2000)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = FLASH_PROTECTION_WELDER
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = INFINITY, ACID = 60)
	origin_tech = "materials=2;engineering=3"
	actions_types = list(/datum/action/item_action/toggle)
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = MASKCOVERSEYES
	can_toggle = TRUE
	visor_flags_inv = HIDEEYES
	resistance_flags = FIRE_PROOF

	sprite_sheets = list(
		"Kidan" = 'icons/mob/clothing/species/kidan/mask.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi'
	)

/obj/item/clothing/mask/gas/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/mask/gas/explorer
	name = "explorer gas mask"
	desc = "A military-grade gas mask that can be connected to an air supply."
	icon_state = "gas_mining"
	actions_types = list(/datum/action/item_action/adjust)
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 10, ACID = 35)
	resistance_flags = FIRE_PROOF
	can_toggle = TRUE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi'
		)

/obj/item/clothing/mask/gas/explorer/marines
	name = "military gas mask"

/obj/item/clothing/mask/gas/explorer/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/gas/explorer/adjustmask(user)
	..()
	w_class = up ? WEIGHT_CLASS_SMALL : WEIGHT_CLASS_NORMAL

/obj/item/clothing/mask/gas/explorer/folded/Initialize()
	. = ..()
	force_adjust_mask()

/obj/item/clothing/mask/gas/explorer/folded/proc/force_adjust_mask()
	up = !up
	update_icon(UPDATE_ICON_STATE)
	gas_transfer_coefficient = null
	permeability_coefficient = null
	flags_cover &= ~MASKCOVERSMOUTH
	flags_inv &= ~HIDEFACE
	flags &= ~AIRTIGHT
	w_class = WEIGHT_CLASS_SMALL


//Bane gas mask
/obj/item/clothing/mask/banemask
	name = "bane mask"
	desc = "Only when the station is in flames, do you have my permission to robust."
	icon_state = "bane_mask"
	flags = BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = MASKCOVERSMOUTH | MASKCOVERSEYES
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "bane_mask"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01


//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out toxins but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

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
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask. Its form can be changed by using it in your hand."
	icon_state = "clown"
	item_state = "clown_hat"
	flags = BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | BLOCKHAIR
	resistance_flags = FLAMMABLE
	dog_fashion = /datum/dog_fashion/head/clown

/obj/item/clothing/mask/gas/clown_hat/attack_self(mob/living/user)
	var/list/mask_type = list("True Form" = /obj/item/clothing/mask/gas/clown_hat,
							"The Feminist" = /obj/item/clothing/mask/gas/clown_hat/sexy,
							"The Madman" = /obj/item/clothing/mask/gas/clown_hat/joker,
							"The Rainbow Color" = /obj/item/clothing/mask/gas/clown_hat/rainbow)
	var/list/mask_icons = list("True Form" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "clown"),
							"The Feminist" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "sexyclown"),
							"The Madman" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "joker"),
							"The Rainbow Color" = image(icon = 'icons/obj/clothing/masks.dmi', icon_state = "rainbow"))
	var/mask_choice = show_radial_menu(user, src, mask_icons)
	var/picked_mask = mask_type[mask_choice]

	if(QDELETED(src) || !picked_mask)
		return
	if(user.stat || !in_range(user, src))
		return
	var/obj/item/clothing/mask/gas/clown_hat/new_mask = new picked_mask(get_turf(user))
	qdel(src)
	user.put_in_active_hand(new_mask)
	to_chat(user, "<span class='notice'>Your Clown Mask has now morphed into its new form, all praise the Honk Mother!</span>")
	return TRUE

/obj/item/clothing/mask/gas/clown_hat/sexy
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers. Its form can be changed by using it in your hand."
	icon_state = "sexyclown"
	item_state = "sexyclown"

/obj/item/clothing/mask/gas/clown_hat/joker
	name = "deranged clown wig and mask"
	desc = "A fiendish clown mask that inspires a deranged mirth. Its form can be changed by using it in your hand."
	icon_state = "joker"
	item_state = "joker"

/obj/item/clothing/mask/gas/clown_hat/rainbow
	name = "rainbow clown wig and mask"
	desc = "A colorful clown mask for the clown that loves to dazzle and impress. Its form can be changed by using it in your hand."
	icon_state = "rainbow"
	item_state = "rainbow"

/obj/item/clothing/mask/gas/clownwiz
	name = "wizard clown wig and mask"
	desc = "Some pranksters are truly magical."
	icon_state = "wizzclown"
	item_state = "wizzclown"
	flags = BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | BLOCKHAIR
	flags_inv = HIDEEARS | HIDEEYES
	magical = TRUE

/obj/item/clothing/mask/gas/clown_hat/nodrop
	flags = BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | BLOCKHAIR | NODROP

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	icon_state = "mime"
	item_state = "mime"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/mime/wizard
	name = "magical mime mask"
	desc = "A mime mask glowing with power. Its eyes gaze deep into your soul."
	flags_inv = HIDEEARS | HIDEEYES
	magical = TRUE

/obj/item/clothing/mask/gas/mime/nodrop
	flags = BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | NODROP

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	icon_state = "monkeymask"
	item_state = "monkeymask"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	icon_state = "sexymime"
	item_state = "sexymime"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop"
	icon_state = "death"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/hoot)

/obj/item/clothing/mask/gas/owl_mask/super_hero
	flags = BLOCK_GAS_SMOKE_EFFECT | AIRTIGHT | NODROP

/obj/item/clothing/mask/gas/owl_mask/attack_self()
	hoot()

/obj/item/clothing/mask/gas/owl_mask/proc/hoot()
	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		playsound(src.loc, 'sound/creatures/hoot.ogg', 50, 1)
		cooldown = world.time

/obj/item/clothing/mask/gas/navy_officer
	name = "nanotrasen navy officer gas mask"
	desc = "A durable gas mask designed for Nanotrasen Navy Officers."
	icon_state = "navy_officer_gasmask"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 10, ACID = 50)
	strip_delay = 6 SECONDS

// ********************************************************************

// **** Security gas mask ****

/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device, plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you taze them. Do not tamper with the device."
	icon_state = "sechailer"
	item_state = "sechailer"
	var/phrase = 1
	var/aggressiveness = 1
	var/safety = 1
	can_toggle = TRUE
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/adjust, /datum/action/item_action/selectphrase)
	var/phrase_list = list(

								"halt" 			= "HALT! HALT! HALT! HALT!",
								"bobby" 		= "Stop in the name of the Law.",
								"compliance" 	        = "Compliance is in your best interest.",
								"justice"		= "Prepare for justice!",
								"running"		= "Running will only increase your sentence.",
								"dontmove"		= "Don't move, Creep!",
								"floor"			= "Down on the floor, Creep!",
								"robocop"		= "Dead or alive you're coming with me.",
								"god"			= "God made today for the crooks we could not catch yesterday.",
								"freeze"		= "Freeze, Scum Bag!",
								"imperial"		= "Stop right there, criminal scum!",
								"bash"			= "Stop or I'll bash you.",
								"harry"			= "Go ahead, make my day.",
								"asshole"		= "Stop breaking the law, asshole.",
								"stfu"			= "You have the right to shut the fuck up",
								"shutup"		= "Shut up crime!",
								"super"			= "Face the wrath of the golden bolt.",
								"dredd"			= "I am, the LAW!"
								)
/obj/item/clothing/mask/gas/sechailer/hos
	name = "head of security's SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000. It has a tan stripe."
	icon_state = "hosmask"
	can_toggle = FALSE
	aggressiveness = 3
	phrase = 12
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)

/obj/item/clothing/mask/gas/sechailer/warden
	name = "warden's SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000. It has a blue stripe."
	icon_state = "wardenmask"
	can_toggle = FALSE
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
		var/key = phrase_list[phrase]
		var/message = phrase_list[key]

		if(!safety)
			to_chat(user, "<span class='notice'>You set the restrictor to: FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND DO SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT.</span>")
			return

		switch(aggressiveness)
			if(1)
				phrase = (phrase < 6) ? (phrase + 1) : 1
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			if(2)
				phrase = (phrase < 11 && phrase >= 7) ? (phrase + 1) : 7
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			if(3)
				phrase = (phrase < 18 && phrase >= 12 ) ? (phrase + 1) : 12
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			if(4)
				phrase = (phrase < 18 && phrase >= 1 ) ? (phrase + 1) : 1
				key = phrase_list[phrase]
				message = phrase_list[key]
				to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")
			else
				to_chat(user, "<span class='notice'>It's broken.</span>")

/obj/item/clothing/mask/gas/sechailer/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/wirecutters))
		if(aggressiveness != 5)
			to_chat(user, "<span class='warning'>You broke it!</span>")
			aggressiveness = 5
			return
	. = ..()

/obj/item/clothing/mask/gas/sechailer/screwdriver_act(mob/living/user, obj/item/I)
	switch(aggressiveness)
		if(1)
			to_chat(user, "<span class='notice'>You set the aggressiveness restrictor to the second position.</span>")
			aggressiveness = 2
			phrase = 7
		if(2)
			to_chat(user, "<span class='notice'>You set the aggressiveness restrictor to the third position.</span>")
			aggressiveness = 3
			phrase = 13
		if(3)
			to_chat(user, "<span class='notice'>You set the aggressiveness restrictor to the fourth position.</span>")
			aggressiveness = 4
			phrase = 1
		if(4)
			to_chat(user, "<span class='notice'>You set the aggressiveness restrictor to the first position.</span>")
			aggressiveness = 1
			phrase = 1
		if(5)
			to_chat(user, "<span class='warning'>You adjust the restrictor but nothing happens, probably because its broken.</span>")
	return TRUE

/obj/item/clothing/mask/gas/sechailer/attack_self()
	halt()

/obj/item/clothing/mask/gas/sechailer/emag_act(mob/user as mob)
	if(safety)
		safety = 0
		to_chat(user, "<span class='warning'>You silently fry [src]'s vocal circuit with the cryptographic sequencer.")
	else
		return

/obj/item/clothing/mask/gas/sechailer/proc/halt()
	var/key = phrase_list[phrase]
	var/message = phrase_list[key]


	if(cooldown < world.time - 35) // A cooldown, to stop people being jerks
		if(!safety)
			message = "FUCK YOUR CUNT YOU SHIT EATING COCKSUCKER MAN EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND DO SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT."
			usr.visible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[message]</b></font>")
			playsound(src.loc, 'sound/voice/binsult.ogg', 100, 0, 4)
			cooldown = world.time
			return

		usr.visible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[message]</b></font>")
		playsound(src.loc, "sound/voice/complionator/[key].ogg", 100, 0, 4)
		cooldown = world.time



// ********************************************************************
