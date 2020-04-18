/*
 * Contains
 * /obj/item/rig_module/vision
 * /obj/item/rig_module/vision/multi
 * /obj/item/rig_module/vision/meson
 * /obj/item/rig_module/vision/thermal
 * /obj/item/rig_module/vision/nvg
 * /obj/item/rig_module/vision/medhud
 * /obj/item/rig_module/vision/sechud
 */

/datum/rig_vision
	var/mode
	var/obj/item/clothing/glasses/glasses

/datum/rig_vision/nvg
	mode = "night vision"
/datum/rig_vision/nvg/New()
	glasses = new /obj/item/clothing/glasses/night

/datum/rig_vision/thermal
	mode = "thermal scanner"
/datum/rig_vision/thermal/New()
	glasses = new /obj/item/clothing/glasses/thermal

/datum/rig_vision/meson
	mode = "meson scanner"
/datum/rig_vision/meson/New()
	glasses = new /obj/item/clothing/glasses/meson

/datum/rig_vision/sechud
	mode = "security HUD"
/datum/rig_vision/sechud/New()
	glasses = new /obj/item/clothing/glasses/hud/security

/datum/rig_vision/medhud
	mode = "medical HUD"
/datum/rig_vision/medhud/New()
	glasses = new /obj/item/clothing/glasses/hud/health

/obj/item/rig_module/vision

	name = "hardsuit visor"
	desc = "A layered, translucent visor system for a hardsuit."
	icon_state = "optics"

	interface_name = "optical scanners"
	interface_desc = "An integrated multi-mode vision system."

	usable = 1
	toggleable = 1
	disruptive = 0

	engage_string = "Cycle Visor Mode"
	activate_string = "Enable Visor"
	deactivate_string = "Disable Visor"

	var/datum/rig_vision/vision
	var/list/vision_modes = list(
		/datum/rig_vision/nvg,
		/datum/rig_vision/thermal,
		/datum/rig_vision/meson
		)

	var/vision_index

/obj/item/rig_module/vision/multi

	name = "hardsuit optical package"
	desc = "A complete visor system of optical scanners and vision modes."
	icon_state = "fulloptics"


	interface_name = "multi optical visor"
	interface_desc = "An integrated multi-mode vision system."

	vision_modes = list(/datum/rig_vision/meson,
						/datum/rig_vision/nvg,
						/datum/rig_vision/thermal,
						/datum/rig_vision/sechud,
						/datum/rig_vision/medhud)

/obj/item/rig_module/vision/meson

	name = "hardsuit meson scanner"
	desc = "A layered, translucent visor system for a hardsuit."
	icon_state = "meson"

	usable = 0

	interface_name = "meson scanner"
	interface_desc = "An integrated meson scanner."

	vision_modes = list(/datum/rig_vision/meson)

/obj/item/rig_module/vision/thermal

	name = "hardsuit thermal scanner"
	desc = "A layered, translucent visor system for a hardsuit."
	icon_state = "thermal"

	usable = 0

	interface_name = "thermal scanner"
	interface_desc = "An integrated thermal scanner."

	vision_modes = list(/datum/rig_vision/thermal)

/obj/item/rig_module/vision/nvg

	name = "hardsuit night vision interface"
	desc = "A multi input night vision system for a hardsuit."
	icon_state = "night"

	usable = 0

	interface_name = "night vision interface"
	interface_desc = "An integrated night vision system."

	vision_modes = list(/datum/rig_vision/nvg)

/obj/item/rig_module/vision/sechud

	name = "hardsuit security hud"
	desc = "A simple tactical information system for a hardsuit."
	icon_state = "securityhud"

	usable = 0

	interface_name = "security HUD"
	interface_desc = "An integrated security heads up display."

	vision_modes = list(/datum/rig_vision/sechud)

/obj/item/rig_module/vision/medhud

	name = "hardsuit medical hud"
	desc = "A simple medical status indicator for a hardsuit."
	icon_state = "healthhud"

	usable = 0

	interface_name = "medical HUD"
	interface_desc = "An integrated medical heads up display."

	vision_modes = list(/datum/rig_vision/medhud)


// There should only ever be one vision module installed in a suit.
/obj/item/rig_module/vision/installed()
	..()
	holder.visor = src

/obj/item/rig_module/vision/engage()

	var/starting_up = !active

	if(!..() || !vision_modes)
		return 0

	// Don't cycle if this engage() is being called by activate().
	if(starting_up)
		to_chat(holder.wearer, "<font color='blue'>You activate your visual sensors.</font>")
		return 1

	if(vision_modes.len > 1)
		vision_index++
		if(vision_index > vision_modes.len)
			vision_index = 1
		vision = vision_modes[vision_index]

		to_chat(holder.wearer, "<font color='blue'>You cycle your sensors to <b>[vision.mode]</b> mode.</font>")
	else
		to_chat(holder.wearer, "<font color='blue'>Your sensors only have one mode.</font>")
	return 1

/obj/item/rig_module/vision/New()
	..()

	if(!vision_modes)
		return

	vision_index = 1
	var/list/processed_vision = list()

	for(var/vision_mode in vision_modes)
		var/datum/rig_vision/vision_datum = new vision_mode
		if(!vision) vision = vision_datum
		processed_vision += vision_datum

	vision_modes = processed_vision
