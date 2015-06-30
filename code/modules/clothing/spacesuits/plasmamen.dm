// PLASMEN SHIT
// CAN'T WEAR UNLESS YOU'RE A PINK SKELLINGTON
/obj/item/clothing/suit/space/eva/plasmaman
	name = "phoronman suit"
	desc = "A special containment suit designed to protect a phoronman's volatile body from outside exposure and quickly extinguish it in emergencies."
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_casing,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	slowdown = 0
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 20)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	species_restricted = list("Phoronman")
	flags = STOPSPRESSUREDMAGE  | PLASMAGUARD

	icon_state = "phoronman_suit"
	item_state = "phoronman_suit"

	var/next_extinguish=0
	var/extinguish_cooldown=10 SECONDS
	var/extinguishes_left=10 // Yeah yeah, reagents, blah blah blah.  This should be simple.

/obj/item/clothing/suit/space/eva/plasmaman/examine(mob/user)
	..()
	user << "<span class='info'>There are [extinguishes_left] extinguisher canisters left in this suit.</span>"

/obj/item/clothing/suit/space/eva/plasmaman/proc/Extinguish(var/mob/user)
	var/mob/living/carbon/human/H=user
	if(extinguishes_left)
		if(next_extinguish > world.time)
			return

		next_extinguish = world.time + extinguish_cooldown
		extinguishes_left--
		H << "<span class='warning'>Your suit automatically extinguishes the fire.</span>"
		H.ExtinguishMob()

/obj/item/clothing/head/helmet/space/eva/plasmaman
	name = "phoronman helmet"
	desc = "A special containment helmet designed to protect a phoronman's volatile body from outside exposure and quickly extinguish it in emergencies."
	flags = STOPSPRESSUREDMAGE | PLASMAGUARD
	species_restricted = list("Phoronman")

	icon_state = "phoronman_helmet0"
	item_state = "phoronman_helmet0"
	var/base_state = "phoronman_helmet"
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	var/no_light=0 // Disable the light on the atmos suit
	action_button_name = "Toggle Helmet Light"

/obj/item/clothing/head/helmet/space/eva/plasmaman/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
		return
	if(no_light)
		return
	on = !on
	icon_state = "[base_state][on]"
	if(on)	user.set_light(user.luminosity + brightness_on)
	else	user.set_light(user.luminosity - brightness_on)
	user.update_inv_head()


/obj/item/clothing/head/helmet/space/eva/plasmaman/pickup(mob/user)
	if(on)
		user.set_light(user.luminosity + brightness_on)
//		user.UpdateLuminosity()
		set_light(0)

/obj/item/clothing/head/helmet/space/eva/plasmaman/dropped(mob/user)
	if(on)
		user.set_light(user.luminosity - brightness_on)
//		user.UpdateLuminosity()
		set_light(brightness_on)



// ENGINEERING
/obj/item/clothing/suit/space/eva/plasmaman/assistant
	name = "phoronman assistant suit"
	icon_state = "phoronmanAssistant_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/assistant
	name = "phoronman assistant helmet"
	icon_state = "phoronmanAssistant_helmet0"
	base_state = "phoronmanAssistant_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/atmostech
	name = "phoronman atmospheric suit"
	icon_state = "phoronmanAtmos_suit"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/eva/plasmaman/atmostech
	name = "phoronman atmospheric helmet"
	icon_state = "phoronmanAtmos_helmet0"
	base_state = "phoronmanAtmos_helmet"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0)
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/eva/plasmaman/engineer
	name = "phoronman engineer suit"
	icon_state = "phoronmanEngineer_suit"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)

/obj/item/clothing/head/helmet/space/eva/plasmaman/engineer
	name = "phoronman engineer helmet"
	icon_state = "phoronmanEngineer_helmet0"
	base_state = "phoronmanEngineer_helmet"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)

/obj/item/clothing/suit/space/eva/plasmaman/engineer/ce
	name = "phoronman chief engineer suit"
	icon_state = "phoronman_CE"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/eva/plasmaman/engineer/ce
	name = "phoronman chief engineer helmet"
	icon_state = "phoronman_CE_helmet0"
	base_state = "phoronman_CE_helmet"
	max_heat_protection_temperature = FIRE_HELM_MAX_TEMP_PROTECT


//SERVICE

/obj/item/clothing/suit/space/eva/plasmaman/botanist
	name = "phoronman botanist suit"
	icon_state = "phoronmanBotanist_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/botanist
	name = "phoronman botanist helmet"
	icon_state = "phoronmanBotanist_helmet0"
	base_state = "phoronmanBotanist_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/chaplain
	name = "phoronman chaplain suit"
	icon_state = "phoronmanChaplain_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/chaplain
	name = "phoronman chaplain helmet"
	icon_state = "phoronmanChaplain_helmet0"
	base_state = "phoronmanChaplain_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/clown
	name = "phoronman clown suit"
	icon_state = "phoronman_Clown"

/obj/item/clothing/head/helmet/space/eva/plasmaman/clown
	name = "phoronman clown helmet"
	icon_state = "phoronman_Clown_helmet0"
	base_state = "phoronman_Clown_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/mime
	name = "phoronman mime suit"
	icon_state = "phoronman_Mime"

/obj/item/clothing/head/helmet/space/eva/plasmaman/mime
	name = "phoronman mime helmet"
	icon_state = "phoronman_Mime_helmet0"
	base_state = "phoronman_Mime_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/service
	name = "phoronman service suit"
	icon_state = "phoronmanService_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/service
	name = "phoronman service helmet"
	icon_state = "phoronmanService_helmet0"
	base_state = "phoronmanService_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/janitor
	name = "phoronman janitor suit"
	icon_state = "phoronmanJanitor_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/janitor
	name = "phoronman janitor helmet"
	icon_state = "phoronmanJanitor_helmet0"
	base_state = "phoronmanJanitor_helmet"


//CARGO

/obj/item/clothing/suit/space/eva/plasmaman/cargo
	name = "phoronman cargo suit"
	icon_state = "phoronmanCargo_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/cargo
	name = "phoronman cargo helmet"
	icon_state = "phoronmanCargo_helmet0"
	base_state = "phoronmanCargo_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/miner
	name = "phoronman miner suit"
	icon_state = "phoronmanMiner_suit"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)

/obj/item/clothing/head/helmet/space/eva/plasmaman/miner
	name = "phoronman miner helmet"
	icon_state = "phoronmanMiner_helmet0"
	base_state = "phoronmanMiner_helmet"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)


// MEDSCI

/obj/item/clothing/suit/space/eva/plasmaman/medical
	name = "phoronman medical suit"
	icon_state = "phoronmanMedical_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/medical
	name = "phoronman medical helmet"
	icon_state = "phoronmanMedical_helmet0"
	base_state = "phoronmanMedical_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/medical/paramedic
	name = "phoronman paramedic suit"
	icon_state = "phoronman_Paramedic"

/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/paramedic
	name = "phoronman paramedic helmet"
	icon_state = "phoronman_Paramedic_helmet0"
	base_state = "phoronman_Paramedic_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/medical/chemist
	name = "phoronman chemist suit"
	icon_state = "phoronman_Chemist"

/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/chemist
	name = "phoronman chemist helmet"
	icon_state = "phoronman_Chemist_helmet0"
	base_state = "phoronman_Chemist_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/medical/cmo
	name = "phoronman chief medical officer suit"
	icon_state = "phoronman_CMO"

/obj/item/clothing/head/helmet/space/eva/plasmaman/medical/cmo
	name = "phoronman chief medical officer helmet"
	icon_state = "phoronman_CMO_helmet0"
	base_state = "phoronman_CMO_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/science
	name = "phoronman scientist suit"
	icon_state = "phoronmanScience_suit"

/obj/item/clothing/head/helmet/space/eva/plasmaman/science
	name = "phoronman scientist helmet"
	icon_state = "phoronmanScience_helmet0"
	base_state = "phoronmanScience_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/science/rd
	name = "phoronman research director suit"
	icon_state = "phoronman_RD"

/obj/item/clothing/head/helmet/space/eva/plasmaman/science/rd
	name = "phoronman research director helmet"
	icon_state = "phoronman_RD_helmet0"
	base_state = "phoronman_RD_helmet"


//SECURITY

/obj/item/clothing/suit/space/eva/plasmaman/security
	name = "phoronman security suit"
	icon_state = "phoronmanSecurity_suit"
	armor = list(melee = 30, bullet = 15, laser = 30,energy = 10, bomb = 10, bio = 100, rad = 50)

/obj/item/clothing/head/helmet/space/eva/plasmaman/security
	name = "phoronman security helmet"
	icon_state = "phoronmanSecurity_helmet0"
	base_state = "phoronmanSecurity_helmet"
	armor = list(melee = 30, bullet = 15, laser = 30,energy = 10, bomb = 10, bio = 100, rad = 50)

/obj/item/clothing/suit/space/eva/plasmaman/security/hos
	name = "phoronman head of security suit"
	icon_state = "phoronman_HoS"

/obj/item/clothing/head/helmet/space/eva/plasmaman/security/hos
	name = "phoronman head of security helmet"
	icon_state = "phoronman_HoS_helmet0"
	base_state = "phoronman_HoS_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/security/hop
	name = "phoronman head of personnel suit"
	icon_state = "phoronman_HoP"

/obj/item/clothing/head/helmet/space/eva/plasmaman/security/hop
	name = "phoronman head of personnel helmet"
	icon_state = "phoronman_HoP_helmet0"
	base_state = "phoronman_HoP_helmet"

/obj/item/clothing/suit/space/eva/plasmaman/security/captain
	name = "phoronman captain suit"
	icon_state = "phoronman_Captain"

/obj/item/clothing/head/helmet/space/eva/plasmaman/security/captain
	name = "phoronman captain helmet"
	icon_state = "phoronman_Captain_helmet0"
	base_state = "phoronman_Captain_helmet"

//NUKEOPS

/obj/item/clothing/suit/space/eva/plasmaman/nuclear
	name = "blood red phoronman suit"
	icon_state = "phoronman_Nukeops"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 60)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/gun,/obj/item/ammo_casing,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/restraints/handcuffs)
	siemens_coefficient = 0.6

/obj/item/clothing/head/helmet/space/eva/plasmaman/nuclear
	name = "blood red phoronman helmet"
	icon_state = "phoronman_Nukeops_helmet0"
	base_state = "phoronman_Nukeops_helmet"
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.6
	var/obj/machinery/camera/camera

/obj/item/clothing/head/helmet/space/eva/plasmaman/nuclear/attack_self(mob/user)
	if(camera)
		..(user)
	else
		camera = new /obj/machinery/camera(src)
		camera.network = list("NUKE")
		cameranet.removeCamera(camera)
		camera.c_tag = user.name
		user << "<span class='notice'>User scanned as [camera.c_tag]. Camera activated.</span>"

/obj/item/clothing/head/helmet/space/eva/plasmaman/nuclear/examine(mob/user)
	..()
	if(get_dist(user,src) <= 1)
		user << "<span class='info'>This helmet has a built-in camera. It's [camera ? "" : "in"]active.</span>"