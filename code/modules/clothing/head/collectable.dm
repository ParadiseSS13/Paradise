
//Hat Station 13

/obj/item/clothing/head/collectable
	name = "collectable hat"
	desc = "A rare collectable hat."

/obj/item/clothing/head/collectable/petehat
	name = "ultra rare Pete's hat!"
	desc = "It smells faintly of plasma."
	icon_state = "petehat"

/obj/item/clothing/head/collectable/petehat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/collectable/slime
	name = "collectable slime cap!"
	desc = "It just latches right in place!"
	icon_state = "headslime"

/obj/item/clothing/head/collectable/xenom
	name = "collectable xenomorph helmet!"
	desc = "Hiss hiss hiss!"
	icon_state = "xenom"

/obj/item/clothing/head/collectable/chef
	name = "collectable chef's hat"
	desc = "A rare Chef's Hat meant for hat collectors!"
	icon_state = "chef"
	inhand_icon_state = "chefhat"
	dog_fashion = /datum/dog_fashion/head/chef
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/collectable/chef/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/collectable/paper
	name = "collectable paper hat"
	desc = "What looks like an ordinary paper hat, is actually a rare and valuable collector's edition paper hat. Keep away from water, fire and Librarians."
	icon_state = "paper"
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/head/collectable/paper/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/collectable/tophat
	name = "collectable top hat"
	desc = "A top hat worn by only the most prestigious hat collectors."
	icon_state = "tophat"
	dog_fashion = /datum/dog_fashion/head
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/collectable/tophat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/collectable/captain
	name = "collectable captain's hat"
	desc = "A Collectable Hat that'll make you look just like a real captain!"
	icon_state = "captain_hat"
	dog_fashion = /datum/dog_fashion/head/captain
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/collectable/captain/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/collectable/police
	name = "collectable police officer's hat"
	desc = "A Collectable Police Officer's Hat. This hat emphasizes that you are THE LAW."
	icon_state = "policehat"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	dog_fashion = /datum/dog_fashion/head/warden

/obj/item/clothing/head/collectable/beret
	name = "collectable beret"
	desc = "A Collectable red Beret. It smells faintly of Garlic."
	icon = 'icons/obj/clothing/head/beret.dmi'
	icon_state = "beret"
	worn_icon = 'icons/mob/clothing/head/beret.dmi'
	dog_fashion = /datum/dog_fashion/head/beret
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head/beret.dmi')

/obj/item/clothing/head/collectable/welding
	name = "collectable welding helmet"
	desc = "A Collectable Welding Helmet. Now with 80% less lead! Not for actual welding. Any welding done while wearing this Helmet is done so at the owner's own risk!"
	icon_state = "welding"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/helmet.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi'
		)

/obj/item/clothing/head/collectable/flatcap
	name = "collectable flat cap"
	desc = "A Collectable farmer's Flat Cap!"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	icon_state = "flat_cap"

/obj/item/clothing/head/collectable/pirate
	name = "collectable pirate hat"
	desc = "You'd make a great Dread Syndie Roberts!"
	icon_state = "pirate"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	dog_fashion = /datum/dog_fashion/head/pirate

/obj/item/clothing/head/collectable/kitty
	name = "collectable kitty ears"
	desc = "The fur feels.....a bit too realistic."
	icon_state = "kitty"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	dog_fashion = /datum/dog_fashion/head/kitty

/obj/item/clothing/head/collectable/rabbitears
	name = "collectable rabbit ears"
	desc = "Not as lucky as the feet!"
	icon_state = "bunny"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	dog_fashion = /datum/dog_fashion/head/rabbit

/obj/item/clothing/head/collectable/wizard
	name = "collectable wizard's hat"
	desc = "NOTE:Any magical powers gained from wearing this hat are purely coincidental."
	icon_state = "wizard"
	dog_fashion = /datum/dog_fashion/head/blue_wizard

/obj/item/clothing/head/collectable/wizard/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/collectable/hardhat
	name = "collectable hard hat"
	desc = "WARNING! Offers no real protection, or luminosity, but it is damn fancy!"
	icon_state = "hardhat0_yellow"
	dog_fashion = /datum/dog_fashion/head/hardhat

/obj/item/clothing/head/collectable/hos
	name = "collectable HoS hat"
	desc = "Now you can beat prisoners, set silly sentences and arrest for no reason too!"
	icon_state = "hos_cap"

/obj/item/clothing/head/collectable/hos/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/collectable/hop
	name = "collectable HoP hat"
	desc = "It's your turn to demand excessive paperwork, signatures, stamps, and hire more clowns! Papers, please!"
	icon_state = "hopcap"
	dog_fashion = /datum/dog_fashion/head/hop

/obj/item/clothing/head/collectable/hop/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/collectable/thunderdome
	name = "collectable Thunderdome helmet"
	desc = "Go Red! I mean Green! I mean Red! No Green!"
	icon_state = "thunderdome"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/helmet.dmi'

/obj/item/clothing/head/collectable/swat
	name = "collectable SWAT helmet"
	desc = "Now you can be in the Deathsquad too!"
	icon_state = "swat"
	inhand_icon_state = "swat_hel"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/helmet.dmi'
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/helmet.dmi')
