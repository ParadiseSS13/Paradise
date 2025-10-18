//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	icon = 'icons/obj/clothing/species/plasmaman/hats.dmi'
	icon_state = "plasmaman-helm"
	base_icon_state = "plasmaman-helm"
	worn_icon = 'icons/mob/clothing/species/plasmaman/helmet.dmi'
	worn_icon_state = null
	inhand_icon_state = "plasmaman_helmet"
	icon_monitor = null
	strip_delay = 80
	tint = FLASH_PROTECTION_WELDER
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = INFINITY, ACID = 150)
	resistance_flags = FIRE_PROOF
	var/brightness_on = 4 //luminosity when the light is on
	var/on = FALSE
	var/smile = FALSE
	var/smile_color = "#FF0000"
	var/visor_icon = "envisor"
	var/light_icon = "enlight"
	var/smile_state = "envirohelm_smile"

	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_PLASMAMEN_HELMET
	actions_types = list(/datum/action/item_action/toggle_helmet_light, /datum/action/item_action/toggle_welding_screen/plasmaman)
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	visor_flags_inv = HIDEEYES|HIDEFACE
	species_restricted = list("Plasmaman")
	can_have_hats = TRUE
	can_be_hat = FALSE
	sprite_sheets = null

/obj/item/clothing/head/helmet/space/plasmaman/Initialize(mapload)
	. = ..()
	base_icon_state = icon_state
	visor_toggling()
	update_icon()

/obj/item/clothing/head/helmet/space/plasmaman/AltClick(mob/user)
	if(!user.incapacitated() && Adjacent(user))
		toggle_welding_screen(user)

/obj/item/clothing/head/helmet/space/plasmaman/proc/toggle_welding_screen(mob/living/user)
	if(weldingvisortoggle(user))
		if(on)
			toggle_light(update_light = TRUE)
		else
			update_icon()
		playsound(src, 'sound/mecha/mechmove03.ogg', 50, 1) //Visors don't just come from nothing

/obj/item/clothing/head/helmet/space/plasmaman/update_icon(updates=ALL)
	. = ..()
	update_action_buttons()

/obj/item/clothing/head/helmet/space/plasmaman/update_icon_state()
	if(!up)
		icon_state = base_icon_state

/obj/item/clothing/head/helmet/space/plasmaman/update_overlays()
	. = ..()
	if(!up)
		. += visor_icon
	else if(on)
		. += light_icon

/obj/item/clothing/head/helmet/space/plasmaman/attack_self__legacy__attackchain(mob/user)
	toggle_light(user)

/obj/item/clothing/head/helmet/space/plasmaman/proc/toggle_light(mob/user, update_light)
	if(!update_light)
		on = !on
	update_icon()
	if(isnull(user))
		user = loc
	var/mob/living/carbon/human/H = user
	if(istype(H))
		H.update_inv_head()
		if(!update_light)
			to_chat(user, "<span class='notice'>You turn \the [src]'s torch [on ? "on":"off"].</span>")
		if(on && !up)
			to_chat(user, "<span class='notice'>[src]'s torch can't pass through your welding visor!</span>")

	if(!on || !up)
		set_light(0)
		return

	set_light(brightness_on)

/obj/item/clothing/head/helmet/space/plasmaman/extinguish_light(force = FALSE)
	if(on)
		toggle_light()

/obj/item/clothing/head/helmet/space/plasmaman/security
	name = "security plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for security officers, protecting them from being flashed and burning alive, alongside other undesirables."
	icon_state = "security_envirohelm"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = INFINITY, ACID = 150)

/obj/item/clothing/head/helmet/space/plasmaman/security/warden
	name = "warden's plasma envirosuit helmet"
	desc = "A plasmaman containment helmet designed for the warden, a pair of white stripes being added to differentiate them from other members of security."
	icon_state = "warden_envirohelm"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = INFINITY, ACID = 150)

/obj/item/clothing/head/helmet/space/plasmaman/security/hos
	desc = "A plasmaman containment helmet designed for the head of security."
	icon_state = "hos_envirohelm"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = INFINITY, ACID = 150)

/obj/item/clothing/head/helmet/space/plasmaman/medical
	name = "medical plasma envirosuit helmet"
	desc = "An envirohelmet designed for plasmaman medical doctors, having two stripes down its length to denote as much."
	icon_state = "doctor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/cmo
	name = "chief medical officer's plasma envirosuit helmet"
	desc = "An envirohelmet designed for plasmamen employed as the chief medical officer."
	icon_state = "cmo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/genetics
	name = "geneticist's plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for geneticists."
	icon_state = "geneticist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/viro
	name = "virology plasma envirosuit helmet"
	desc = "The helmet worn by the safest people on the station, those who are completely immune to the monstrosities they create."
	icon_state = "virologist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/chemist
	name = "chemistry plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for chemists, two orange stripes going down its face."
	icon_state = "chemist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/science
	name = "science plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for scientists."
	icon_state = "scientist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/rd
	name = "research director's plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for the research director."
	icon_state = "rd_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/robotics
	name = "robotics plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for roboticists."
	icon_state = "roboticist_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/engineering
	name = "engineering plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for engineer plasmamen, the usual purple stripes being replaced by engineering's orange."
	icon_state = "engineer_envirohelm"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 10, FIRE = INFINITY, ACID = 75)

/obj/item/clothing/head/helmet/space/plasmaman/engineering/ce
	name = "chief engineer's plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for plasmamen employed as the chief engineer."
	icon_state = "ce_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/atmospherics
	name = "atmospherics plasma envirosuit helmet"
	desc = "A space-worthy helmet specially designed for atmos technician plasmamen, the usual purple stripes being replaced by engineering's blue."
	icon_state = "atmos_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/cargo
	name = "cargo plasma envirosuit helmet"
	desc = "A plasmaman envirohelmet designed for cargo techs and quartermasters."
	icon_state = "cargo_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mining
	name = "mining plasma envirosuit helmet"
	desc = "A khaki helmet given to plasmaman miners operating on Lavaland."
	icon_state = "explorer_envirohelm"
	visor_icon = "explorer_envisor"

/obj/item/clothing/head/helmet/space/plasmaman/expedition
	name = "expedition plasma envirosuit helmet"
	desc = "A brown and blue helmet given to plasmaman explorers operating in Space.."
	icon_state = "expedition_envirohelm"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = INFINITY, ACID = 150)

/obj/item/clothing/head/helmet/space/plasmaman/smith
	name = "smithing plasma envirosuit helmet"
	desc = "A plasmaman helmet design for smiths."
	icon_state = "smith_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain
	name = "chaplain's black plasma envirosuit helmet"
	desc = "An envirohelmet specially designed for only the most pious of plasmamen."
	icon_state = "chapbw_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain/green
	name = "chaplain's white plasma envirosuit helmet"
	icon_state = "chapwg_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/chaplain/orange
	name = "chaplain's orange plasma envirosuit helmet"
	desc = "An envirohelmet specially designed for only the most pious of plasmamen, molded like a turban."
	icon_state = "chapco_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/white
	name = "white plasma envirosuit helmet"
	desc = "A generic white envirohelm."
	icon_state = "white_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/chef
	name = "chef plasma envirosuit helmet"
	desc = "An envirohelm designed for plasmamen chefs."
	icon_state = "chef_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/librarian
	name = "librarian plasma envirosuit helmet"
	desc = "A slight modification on a traditional voidsuit helmet, this helmet was Nanotrasen's first solution to the *logistical problems* that come with employing plasmamen. Despite their limitations, these helmets still see use by historian and old-styled plasmamen alike."
	icon_state = "prototype_envirohelm"
	actions_types = list(/datum/action/item_action/toggle_welding_screen/plasmaman)
	visor_icon = "prototype_envisor"
	light_icon = "prototype_enlight"

/obj/item/clothing/head/helmet/space/plasmaman/botany
	name = "botany plasma envirosuit helmet"
	desc = "A green and blue envirohelmet designating its wearer as a botanist. While not specially designed for it, it would protect against minor plant-related injuries."
	icon_state = "botany_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/janitor
	name = "janitor's plasma envirosuit helmet"
	desc = "A grey helmet bearing a pair of purple stripes, designating the wearer as a janitor."
	icon_state = "janitor_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/mime
	name = "mime envirosuit helmet"
	desc = "The makeup is painted on, it's a miracle it doesn't chip. It's not very colourful."
	icon_state = "mime_envirohelm"
	visor_icon = "mime_envisor"
	light_icon = "mime_envirohelm-light"

/obj/item/clothing/head/helmet/space/plasmaman/clown
	name = "clown envirosuit helmet"
	desc = "The makeup is painted on, it's a miracle it doesn't chip. <i>'HONK!'</i>"
	icon_state = "clown_envirohelm"
	visor_icon = "clown_envisor"
	light_icon = "clown_envirohelm-light"

/obj/item/clothing/head/helmet/space/plasmaman/hop
	name = "head of personnel's envirosuit helmet"
	desc = "A plasmaman envirohelm that reeks of bureaucracy."
	icon_state = "hop_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/captain
	name = "captain's envirosuit helmet"
	desc = "A plasmaman envirohelm designed with the insignia and markings befitting a captain."
	icon_state = "cap_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/blueshield
	name = "blueshield's envirosuit helmet"
	desc = "A plasmaman envirohelm designed for the blueshield."
	icon_state = "bs_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/wizard
	name = "wizard plasma envirosuit helmet"
	desc = "A magical plasmaman containment helmet designed to spread chaos in safety and comfort."
	icon_state = "wizard_envirohelm"
	light_icon = "wizard_enlight"
	gas_transfer_coefficient = 0.01
	armor = list(MELEE = 20, BULLET = 10, LASER = 10, ENERGY = 10, BOMB = 10, RAD = 10, FIRE = INFINITY, ACID = INFINITY)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	magical = TRUE

/obj/item/clothing/head/helmet/space/plasmaman/assistant
	name = "assistant envirosuit helmet"
	desc = "A plasmaman envirohelm designed for the common, maint-dwelling masses."
	icon_state = "assistant_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/coke
	name = "coke envirosuit helmet"
	desc = "A plasmaman envirohelm designed by Space Cola Co for the plasmamen."
	icon_state = "coke_envirohelm"
	light_icon = "coke_enlight"

/obj/item/clothing/head/helmet/space/plasmaman/tacticool
	name = "diver envirosuit helmet"
	desc = "A plasmaman helm resembling old diver helms."
	icon_state = "diver_envirohelm"
	base_icon_state = "diver_envirohelm"
	light_icon = "diver_enlight"
	/// Different icons and names for the helm to use when reskinning
	var/list/static/plasmaman_helm_options = list("Diver" = "diver_envirohelm", "Knight" = "knight_envirohelm", "Skull" = "skull_envirohelm")
	/// Checks if the helm has been reskinned already
	var/reskinned = FALSE

/obj/item/clothing/head/helmet/space/plasmaman/tacticool/examine(mob/user)
	. = ..()
	if(!reskinned)
		. += "<span class='notice'>You can <b>Ctrl-Shift-Click</b> to reskin it when held.</span>"

/obj/item/clothing/head/helmet/space/plasmaman/tacticool/CtrlShiftClick(mob/user)
	..()
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(reskin_radial_check(user) && !reskinned)
		reskin(user)

/obj/item/clothing/head/helmet/space/plasmaman/tacticool/proc/reskin(mob/M)
	var/list/skins = list()
	for(var/I in plasmaman_helm_options)
		skins[I] = image(icon, icon_state = plasmaman_helm_options[I])
	var/choice = show_radial_menu(M, src, skins, radius = 40, custom_check = CALLBACK(src, PROC_REF(reskin_radial_check), M), require_near = TRUE)

	if(!choice || !reskin_radial_check(M))
		return
	switch(choice)
		if("Diver")
			name = initial(name)
			desc = initial(desc)
			base_icon_state = initial(base_icon_state)
			light_icon = initial(light_icon)
		if("Knight")
			name = "knight envirosuit helmet"
			desc = "A plasmaman envirohelm designed in the shape of a knight helm."
			base_icon_state = "knight_envirohelm"
			visor_icon = "knight_envisor"
			light_icon = "knight_enlight"
		if("Skull")
			name = "skull envirosuit helmet"
			desc = "A plasmaman envirohelm designed in the shape of a skull."
			base_icon_state = "skull_envirohelm"
			visor_icon = "skull_envisor"
			light_icon = "skull_enlight"
	update_icon()
	M.update_inv_head()
	reskinned = TRUE

/obj/item/clothing/head/helmet/space/plasmaman/tacticool/proc/reskin_radial_check(mob/user)
	if(!ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!H.is_in_hands(src) || HAS_TRAIT(H, TRAIT_HANDS_BLOCKED))
		return FALSE
	return TRUE

/obj/item/clothing/head/helmet/space/plasmaman/trainer
	name = "\improper NT Career Trainer envirosuit helmet"
	desc = "A plasmaman envirohelm designed for the nanotrasen career trainer."
	icon_state = "trainer_envirohelm"

/obj/item/clothing/head/helmet/space/plasmaman/centcom
	name = "central command envirosuit helmet"
	desc = "A plasmaman containment helmet designed for central command officials."
	icon_state = "centcom_envirohelm"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = INFINITY, ACID = 150)

/obj/item/clothing/head/helmet/space/plasmaman/centcom/soo
	desc = "A plasmaman containment helmet designed for central command officials. This one has been modified for use by special operations officers."
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags =  STOPSPRESSUREDMAGE | THICKMATERIAL
	flags_2 = RAD_PROTECT_CONTENTS_2
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	HUDType = MEDHUD
	see_in_dark = 8
	armor = list(MELEE = 200, BULLET = 200, LASER = 50, ENERGY = 50, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
