//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	icon_state = "plasmaman-helm"
	item_state = "plasmaman-helm"
	strip_delay = 80
	flash_protect = 2
	tint = 2
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 0)
	resistance_flags = FIRE_PROOF
	var/brightness_on = 4 //luminosity when the light is on
	var/on = FALSE
	var/smile = FALSE
	var/smile_color = "#FF0000"
	var/visor_icon = "envisor"
	var/smile_state = "envirohelm_smile"
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen/plasmaman)
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSMOUTH|HEADCOVERSEYES
	visor_flags_inv = HIDEEYES|HIDEFACE
	icon = 'icons/obj/clothing/species/plasmaman/hats.dmi'
	species_restricted = list("Plasmaman")
	sprite_sheets = list("Plasmaman" = 'icons/mob/species/plasmaman/helmet.dmi')

/obj/item/clothing/head/helmet/space/plasmaman/New()
	..()
	visor_toggling()
	update_icon()
	cut_overlays()

/obj/item/clothing/head/helmet/space/plasmaman/AltClick(mob/user)
	if(!user.incapacitated() && Adjacent(user))
		toggle_welding_screen(user)

/obj/item/clothing/head/helmet/space/plasmaman/visor_toggling() //handles all the actual toggling of flags
	up = !up
	flags ^= visor_flags
	flags_inv ^= visor_flags_inv
	icon_state = "[initial(icon_state)]"
	if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
		flash_protect ^= initial(flash_protect)
	if(visor_vars_to_toggle & VISOR_TINT)
		tint ^= initial(tint)

/obj/item/clothing/head/helmet/space/plasmaman/proc/toggle_welding_screen(mob/living/user)
	if(weldingvisortoggle(user))
		if(on)
			to_chat(user, "<span class='notice'>Your helmet's torch can't pass through your welding visor!</span>")
			on = FALSE
			playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1) //Visors don't just come from nothing
			update_icon()
		else
			playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1) //Visors don't just come from nothing
			update_icon()

/obj/item/clothing/head/helmet/space/plasmaman/update_icon()
	cut_overlays()
	add_overlay(visor_icon)
	..()
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	on = !on
	icon_state = "[initial(icon_state)][on ? "-light":""]"
	item_state = icon_state
	user.update_inv_head() //So the mob overlay updates

	if(on)
		if(!up)
			to_chat(user, "<span class='notice'>Your helmet's torch can't pass through your welding visor!</span>")
			set_light(0)
		else
			set_light(brightness_on)
	else
		set_light(0)

	for(var/X in actions)
		var/datum/action/A=X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "security plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for security officers, protecting them from being flashed and burning alive, along-side other undesirables."
	icon_state = "security_envirohelm"
	item_state = "security_envirohelm"
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 0)

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	name = "warden's plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the warden, a pair of white stripes being added to differeciate them from other members of security."
	icon_state = "warden_envirohelm"
	item_state = "warden_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	name = "security plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the head of security."
	icon_state = "hos_envirohelm"
	item_state = "hos_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "medical's plasma envirosuit helmet"
	desc = "An envriohelmet designed for plasmaman medical doctors, having two stripes down it's length to denote as much"
	icon_state = "doctor_envirohelm"
	item_state = "doctor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/cmo
	name = "chief medical officer's plasma envirosuit helmet"
	desc = "An envriohelmet designed for plasmaman employed as the cheif medical officer."
	icon_state = "cmo_envirohelm"
	item_state = "cmo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	name = "geneticist's plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for geneticists."
	icon_state = "geneticist_envirohelm"
	item_state = "geneticist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology plasma envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	icon_state = "virologist_envirohelm"
	item_state = "virologist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	name = "chemistry plasma envirosuit helmet"
	desc = "A plasmaman envirosuit designed for chemists, two orange stripes going down it's face."
	icon_state = "chemist_envirohelm"
	item_state = "chemist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "science plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for scientists."
	icon_state = "scientist_envirohelm"
	item_state = "scientist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/rd
	name = "research director plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for the research director."
	icon_state = "rd_envirohelm"
	item_state = "rd_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/robotics
	name = "robotics plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for roboticists."
	icon_state = "roboticist_envirohelm"
	item_state = "roboticist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	icon_state = "engineer_envirohelm"
	item_state = "engineer_envirohelm"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 10)

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	name = "chief engineer's plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for chief engineer employed plasmamen."
	icon_state = "ce_envirohelm"
	item_state = "ce_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/atmospherics
	name = "atmospherics plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for atmos technician plasmamen, the usual purple stripes being replaced by engineering's blue."
	icon_state = "atmos_envirohelm"
	item_state = "atmos_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "cargo plasma envirosuit helmet"
	desc = "An plasmaman envirohelmet designed for cargo techs and quartermasters."
	icon_state = "cargo_envirohelm"
	item_state = "cargo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mining
	name = "mining plasma envirosuit helmet"
	desc = "A khaki helmet given to plasmamen miners operating on lavaland."
	icon_state = "explorer_envirohelm"
	item_state = "explorer_envirohelm"
	visor_icon = "explorer_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "chaplain's plasma envirosuit helmet"
	desc = "An envirohelmet specially designed for only the most pious of plasmamen."
	icon_state = "chap_envirohelm"
	item_state = "chap_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/white
	name = "white plasma envirosuit helmet"
	desc = "A generic white envirohelm."
	icon_state = "white_envirohelm"
	item_state = "white_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/chef
	name = "chef plasma envirosuit helmet"
	desc = "An envirohelm designed for plasmamen chefs."
	icon_state = "chef_envirohelm"
	item_state = "chef_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/librarian
	name = "librarian's plasma envirosuit helmet"
	desc = "A slight modification on a tradiational voidsuit helmet, this helmet was Nano-Trasen's first solution to the *logistical problems* that come with employing plasmamen. Despite their limitations, these helmets still see use by historian and old-styled plasmamen alike."
	icon_state = "prototype_envirohelm"
	item_state = "prototype_envirohelm"
	actions_types = list(/datum/action/item_action/toggle_welding_screen/plasmaman)
	visor_icon = "prototype_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/botany
	name = "botany plasma envirosuit helmet"
	desc = "A green and blue envirohelmet designating it's wearer as a botanist. While not specially designed for it, it would protect against minor planet-related injuries."
	icon_state = "botany_envirohelm"
	item_state = "botany_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "janitor's plasma envirosuit helmet"
	desc = "A grey helmet bearing a pair of purple stripes, designating the wearer as a janitor."
	icon_state = "janitor_envirohelm"
	item_state = "janitor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime envirosuit helmet"
	desc = "The make-up is painted on, it's a miracle it doesn't chip. It's not very colourful."
	icon_state = "mime_envirohelm"
	item_state = "mime_envirohelm"
	visor_icon = "mime_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/clown
	name = "clown envirosuit helmet"
	desc = "The make-up is painted on, it's a miracle it doesn't chip. <i>'HONK!'</i>"
	icon_state = "clown_envirohelm"
	item_state = "clown_envirohelm"
	visor_icon = "clown_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/hop
	name = "head of personnel envirosuit helmet"
	desc = "A plasmaman envirohelm that reeks of bureaucracy."
	icon_state = "hop_envirohelm"
	item_state = "hop_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/captain
	name = "captain envirosuit helmet"
	desc = "A plasmaman envirohelm designed with the insignia and markings befitting a captain."
	icon_state = "cap_envirohelm"
	item_state = "cap_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/blueshield
	name = "blueshield envirosuit helmet"
	desc = "A plasmaman envirohelm designed for the blueshield."
	icon_state = "bs_envirohelm"
	item_state = "bs_envirohelm"