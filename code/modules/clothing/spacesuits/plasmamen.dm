// PLASMEN SHIT
// CAN'T WEAR UNLESS YOU'RE A PINK SKELETON
/obj/item/clothing/suit/space/eva/plasmaman
	name = "plasmaman suit"
	desc = "A special containment suit designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	allowed = list(/obj/item/gun,/obj/item/ammo_casing,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword/saber,/obj/item/restraints/handcuffs,/obj/item/tank)
	slowdown = 0
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	icon = 'icons/obj/clothing/species/plasmaman/suits.dmi'
	species_restricted = list("Plasmaman")
	sprite_sheets = list(
		"Plasmaman" = 'icons/mob/species/plasmaman/suit.dmi'
		)
	flags = STOPSPRESSUREDMAGE
	icon_state = "plasmaman_suit"
	item_state = "plasmaman_suit"

	var/next_extinguish = 0
	var/extinguish_cooldown = 10 SECONDS
	var/max_extinguishes = 5
	var/extinguishes_left = 5 // Yeah yeah, reagents, blah blah blah.  This should be simple.

/obj/item/clothing/suit/space/eva/plasmaman/proc/Extinguish(var/mob/user)
	var/mob/living/carbon/human/H=user
	if(extinguishes_left)
		if(next_extinguish > world.time)
			return

		next_extinguish = world.time + extinguish_cooldown
		extinguishes_left--
		to_chat(user, "<span class='warning'>You hear a soft click and a hiss from your suit as it automatically extinguishes the fire.</span>")
		if(!extinguishes_left)
			to_chat(user, "<span class='warning'>Onboard auto-extinguisher depleted, refill with a cartridge.</span>")
		playsound(src.loc, 'sound/effects/spray.ogg', 10, 1, -3)
		H.ExtinguishMob()

/obj/item/clothing/suit/space/eva/plasmaman/attackby(var/obj/item/A as obj, mob/user as mob, params)
	..()
	if(istype(A, /obj/item/plasmensuit_cartridge)) //This suit can only be reloaded by the appropriate cartridges, and only if it's got no more extinguishes left.
		if(!extinguishes_left)
			extinguishes_left = max_extinguishes //Full replenishment from the cartridge.
			to_chat(user, "<span class='notice'>You replenish \the [src] with the cartridge.</span>")
			qdel(A)
		else
			to_chat(user, "<span class='notice'>The suit must be depleted before it can be refilled.</span>")

/obj/item/clothing/suit/space/eva/plasmaman/examine(mob/user)
	..(user)
	to_chat(user, "<span class='info'>There are [extinguishes_left] extinguisher canisters left in this suit.</span>")

/obj/item/plasmensuit_cartridge //Can be used to refill Plasmaman suits when they run out of autoextinguishes.
	name = "auto-extinguisher cartridge"
	desc = "A tiny and light fibreglass-framed auto-extinguisher cartridge."
	icon = 'icons/obj/items.dmi'
	icon_state = "miniFE0"
	item_state = "miniFE"
	hitsound = null //Ultralight and
	flags = null //non-conductive
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL //Fits in boxes.
	materials = list()
	attack_verb = list("tapped")

/obj/item/clothing/head/helmet/space/eva/plasmaman
	name = "plasmaman helmet"
	desc = "A special containment helmet designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	flags = STOPSPRESSUREDMAGE
	icon = 'icons/obj/clothing/species/plasmaman/hats.dmi'
	species_restricted = list("Plasmaman")
	sprite_sheets = list(
		"Plasmaman" = 'icons/mob/species/plasmaman/helmet.dmi'
		)
	icon_state = "plasmaman_helmet0"
	item_state = "plasmaman_helmet0"
	var/base_state = "plasmaman_helmet"
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/head/helmet/space/eva/plasmaman/attack_self(mob/user)
	toggle_light(user)

/obj/item/clothing/head/helmet/space/eva/plasmaman/proc/toggle_light(mob/user)
	on = !on
	icon_state = "[base_state][on]"

	if(on)
		set_light(brightness_on)
	else
		set_light(0)

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/eva/plasmaman/extinguish_light()
	if(on)
		toggle_light()
		visible_message("<span class='danger'>[src]'s light fades and turns off.</span>")

// ENGINEERING
/obj/item/clothing/suit/space/eva/plasmaman/atmostech
	name = "plasmaman atmospheric suit"
	icon_state = "plasmamanAtmos_suit"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/eva/plasmaman/atmostech
	name = "plasmaman atmospheric helmet"
	icon_state = "plasmamanAtmos_helmet0"
	base_state = "plasmamanAtmos_helmet"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	flash_protect = 2

/obj/item/clothing/suit/space/eva/plasmaman/engineer
	name = "plasmaman engineer suit"
	icon_state = "plasmamanEngineer_suit"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)

/obj/item/clothing/head/helmet/space/eva/plasmaman/engineer
	name = "plasmaman engineer helmet"
	icon_state = "plasmamanEngineer_helmet0"
	base_state = "plasmamanEngineer_helmet"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	flash_protect = 2

/obj/item/clothing/suit/space/eva/plasmaman/engineer/ce
	name = "plasmaman chief engineer suit"
	icon_state = "plasmaman_CE"
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT


/obj/item/clothing/head/helmet/space/eva/plasmaman/engineer/ce
	name = "plasmaman chief engineer helmet"
	icon_state = "plasmaman_CE_helmet0"
	base_state = "plasmaman_CE_helmet"
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	flash_protect = 2

//SERVICE
/obj/item/clothing/suit/space/eva/plasmaman/assistant
	name = "plasmaman assistant suit"
	icon_state = "plasmamanAssistant_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/assistant
	name = "plasmaman assistant helmet"
	icon_state = "plasmamanAssistant_helmet0"
	base_state = "plasmamanAssistant_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/botanist
	name = "plasmaman botanist suit"
	icon_state = "plasmamanBotanist_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/botanist
	name = "plasmaman botanist helmet"
	icon_state = "plasmamanBotanist_helmet0"
	base_state = "plasmamanBotanist_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/chaplain
	name = "plasmaman chaplain suit"
	icon_state = "plasmamanChaplain_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/chaplain
	name = "plasmaman chaplain helmet"
	icon_state = "plasmamanChaplain_helmet0"
	base_state = "plasmamanChaplain_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/clown
	name = "plasmaman clown suit"
	icon_state = "plasmaman_Clown"

/obj/item/clothing/head/helmet/space/eva/plasmaman/clown
	name = "plasmaman clown helmet"
	icon_state = "plasmaman_Clown_helmet0"
	base_state = "plasmaman_Clown_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/mime
	name = "plasmaman mime suit"
	icon_state = "plasmaman_Mime"

/obj/item/clothing/head/helmet/space/eva/plasmaman/mime
	name = "plasmaman mime helmet"
	icon_state = "plasmaman_Mime_helmet0"
	base_state = "plasmaman_Mime_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/service
	name = "plasmaman service suit"
	icon_state = "plasmamanService_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/service
	name = "plasmaman service helmet"
	icon_state = "plasmamanService_helmet0"
	base_state = "plasmamanService_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/janitor
	name = "plasmaman janitor suit"
	icon_state = "plasmamanJanitor_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/janitor
	name = "plasmaman janitor helmet"
	icon_state = "plasmamanJanitor_helmet0"
	base_state = "plasmamanJanitor_helmet"


//CARGO

/obj/item/clothing/suit/space/eva/plasmaman/cargo
	name = "plasmaman cargo suit"
	icon_state = "plasmamanCargo_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/cargo
	name = "plasmaman cargo helmet"
	icon_state = "plasmamanCargo_helmet0"
	base_state = "plasmamanCargo_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/miner
	name = "plasmaman miner suit"
	icon_state = "plasmamanMiner_suit"
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)
	slowdown = 1

/obj/item/clothing/head/helmet/space/eva/plasmaman/miner
	name = "plasmaman miner helmet"
	icon_state = "plasmamanMiner_helmet0"
	base_state = "plasmamanMiner_helmet"
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)


// MEDSCI

/obj/item/clothing/suit/space/eva/plasmaman/medical
	name = "plasmaman medical suit"
	icon_state = "plasmamanMedical_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/medical
	name = "plasmaman medical helmet"
	icon_state = "plasmamanMedical_helmet0"
	base_state = "plasmamanMedical_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/medical/paramedic
	name = "plasmaman paramedic suit"
	icon_state = "plasmaman_Paramedic"

/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/paramedic
	name = "plasmaman paramedic helmet"
	icon_state = "plasmaman_Paramedic_helmet0"
	base_state = "plasmaman_Paramedic_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/medical/chemist
	name = "plasmaman chemist suit"
	icon_state = "plasmaman_Chemist"

/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/chemist
	name = "plasmaman chemist helmet"
	icon_state = "plasmaman_Chemist_helmet0"
	base_state = "plasmaman_Chemist_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/medical/cmo
	name = "plasmaman chief medical officer suit"
	icon_state = "plasmaman_CMO"

/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/cmo
	name = "plasmaman chief medical officer helmet"
	icon_state = "plasmaman_CMO_helmet0"
	base_state = "plasmaman_CMO_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/medical/coroner
	name = "plasmaman coroner suit"
	icon_state = "plasmaman_Coroner"

/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/coroner
	name = "plasmaman coroner helmet"
	icon_state = "plasmaman_Coroner_helmet0"
	base_state = "plasmaman_Coroner_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/medical/virologist
	name = "plasmaman virologist suit"
	icon_state = "plasmaman_Virologist"

/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/virologist
	name = "plasmaman virologist helmet"
	icon_state = "plasmaman_Virologist_helmet0"
	base_state = "plasmaman_Virologist_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/science
	name = "plasmaman scientist suit"
	icon_state = "plasmamanScience_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/science
	name = "plasmaman scientist helmet"
	icon_state = "plasmamanScience_helmet0"
	base_state = "plasmamanScience_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/science/geneticist
	name = "plasmaman geneticist suit"
	icon_state = "plasmaman_Geneticist"

/obj/item/clothing/head/helmet/space/eva/plasmaman/science/geneticist
	name = "plasmaman geneticist helmet"
	icon_state = "plasmaman_Geneticist_helmet0"
	base_state = "plasmaman_Geneticist_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/science/rd
	name = "plasmaman research director suit"
	icon_state = "plasmaman_RD"

/obj/item/clothing/head/helmet/space/eva/plasmaman/science/rd
	name = "plasmaman research director helmet"
	icon_state = "plasmaman_RD_helmet0"
	base_state = "plasmaman_RD_helmet"

//MAGISTRATE
/obj/item/clothing/suit/space/eva/plasmaman/magistrate
	name = "plasmaman magistrate suit"
	icon_state = "plasmaman_HoS"

/obj/item/clothing/head/helmet/space/eva/plasmaman/magistrate
	name = "plasmaman magistrate helmet"
	icon_state = "plasmaman_HoS_helmet0"
	base_state = "plasmaman_HoS_helmet"

//NT REP
/obj/item/clothing/suit/space/eva/plasmaman/nt_rep
	name = "plasmaman NT representative suit"
	icon_state = "plasmaman_rep"

/obj/item/clothing/head/helmet/space/eva/plasmaman/nt_rep
	name = "plasmaman NT representative helmet"
	icon_state = "plasmaman_rep_helmet0"
	base_state = "plasmaman_rep_helmet"

//SECURITY

/obj/item/clothing/suit/space/eva/plasmaman/security
	name = "plasmaman security suit"
	icon_state = "plasmamanSecurity_suit"
	armor = list(melee = 15, bullet = 15, laser = 15, energy = 10, bomb = 10, bio = 100, rad = 50)

/obj/item/clothing/head/helmet/space/eva/plasmaman/security
	name = "plasmaman security helmet"
	icon_state = "plasmamanSecurity_helmet0"
	base_state = "plasmamanSecurity_helmet"
	armor = list(melee = 15, bullet = 15, laser = 15, energy = 10, bomb = 10, bio = 100, rad = 50)

/obj/item/clothing/suit/space/eva/plasmaman/security/hos
	name = "plasmaman head of security suit"
	icon_state = "plasmaman_HoS"

/obj/item/clothing/head/helmet/space/eva/plasmaman/security/hos
	name = "plasmaman head of security helmet"
	icon_state = "plasmaman_HoS_helmet0"
	base_state = "plasmaman_HoS_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/security/hop
	name = "plasmaman head of personnel suit"
	icon_state = "plasmaman_HoP"

/obj/item/clothing/head/helmet/space/eva/plasmaman/security/hop
	name = "plasmaman head of personnel helmet"
	icon_state = "plasmaman_HoP_helmet0"
	base_state = "plasmaman_HoP_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/security/captain
	name = "plasmaman captain suit"
	icon_state = "plasmaman_Captain"

/obj/item/clothing/head/helmet/space/eva/plasmaman/security/captain
	name = "plasmaman captain helmet"
	icon_state = "plasmaman_Captain_helmet0"
	base_state = "plasmaman_Captain_helmet"


//IAA/LAWYER
/obj/item/clothing/suit/space/eva/plasmaman/lawyer
	name = "plasmaman lawyer suit"
	icon_state = "plasmamanlawyer_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/lawyer
	name = "plasmaman lawyer helmet"
	icon_state = "plasmamanlawyer_helmet0"
	base_state = "plasmamanlawyer_helmet"

//NUKEOPS

/obj/item/clothing/suit/space/eva/plasmaman/nuclear
	name = "blood red plasmaman suit"
	icon_state = "plasmaman_Nukeops"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/flashlight,/obj/item/tank,/obj/item/gun,/obj/item/ammo_casing,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/melee/energy/sword/saber,/obj/item/restraints/handcuffs)

/obj/item/clothing/head/helmet/space/eva/plasmaman/nuclear
	name = "blood red plasmaman helmet"
	icon_state = "plasmaman_Nukeops_helmet0"
	base_state = "plasmaman_Nukeops_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)

//WIZARD
/obj/item/clothing/suit/space/eva/plasmaman/wizard
	name = "robed plasmaman suit"
	icon_state = "plasmamanWizardBlue_suit"
	magical = TRUE

/obj/item/clothing/head/helmet/space/eva/plasmaman/wizard
	name = "wizard hat"
	icon_state = "plasmamanWizardBlue_helmet0"
	base_state = "plasmamanWizardBlue_helmet"
	magical = TRUE
