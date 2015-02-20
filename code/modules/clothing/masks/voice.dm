/obj/item/voice_changer
	name = "voice changer"
	desc = "A voice scrambling module. If you can see this, report it as a bug on the tracker."
	var/voice //If set and item is present in mask/suit, this name will be used for the wearer's speech.
	var/active

/obj/item/clothing/mask/gas/voice
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. It seems to house some odd electronics."
	var/obj/item/voice_changer/changer
	origin_tech = "syndicate=4"

/obj/item/clothing/mask/gas/voice/verb/Toggle_Voice_Changer()
	set category = "Object"
	set src in usr

	changer.active = !changer.active
	usr << "<span class='notice'>You [changer.active ? "enable" : "disable"] the voice-changing module in \the [src].</span>"

/obj/item/clothing/mask/gas/voice/verb/Set_Voice(name as text)
	set category = "Object"
	set src in usr

	var/voice = sanitize(copytext(name,1,MAX_MESSAGE_LEN))
	if(!voice || !length(voice)) return
	changer.voice = voice
	usr << "<span class='notice'>You are now mimicking <B>[changer.voice]</B>.</span>"

/obj/item/clothing/mask/gas/voice/New()
	..()
	changer = new(src)

/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja(norm)"
	item_state = "s-ninja_mask"
	unacidable = 1
	siemens_coefficient = 0.2
	species_fit = list("Vox")
	var/mode = 0// 0==Scouter | 1==Night Vision | 2==Thermal | 3==Meson

/obj/item/clothing/mask/gas/voice/space_ninja/scar
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement. This mask appears to have already seen battle."
	icon_state = "s-ninja(scar)"
	item_state = "s-ninja_mask"

/obj/item/clothing/mask/gas/voice/space_ninja/visor
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement. This variant appears to have a visor to increase vision."
	icon_state = "s-ninja(visor)"
	item_state = "s-ninja_mask"

/obj/item/clothing/mask/gas/voice/space_ninja/monocular
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement. This variant appears to focus the user's vision out of a single port."
	icon_state = "s-ninja(mon)"
	item_state = "s-ninja_mask"