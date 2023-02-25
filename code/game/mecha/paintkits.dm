/obj/item/paintkit //Please don't use this for anything, it's a base type for custom mech paintjobs.
	name = "mecha customisation kit"
	desc = "A generic kit containing all the needed tools and parts to turn a mech into another mech."
	icon = 'icons/obj/paintkit.dmi'
	icon_state = "paintkit" //What sprite will your paintkit use?

	var/new_name = "mech"    //What is the variant called?
	var/new_desc = "A mech." //How is the new mech described?
	var/new_icon = "ripley"  //What base icon will the new mech use?
	var/removable = null     //Can the kit be removed?
	var/list/allowed_types = list() //Types of mech that the kit will work on.

//If you want to add new paintkit, grab a paintkit sprite from: "icons/obj/paintkit.dmi" or make a new one
//Then throw the sprites of the new mecha skin to the "icons/mecha/mecha.dmi and add a new object below"

/obj/item/paintkit/ripley_titansfist
	name = "APLU \"Titan's Fist\" customisation kit"
	icon_state = "paintkit_titan"
	desc = "A kit containing all the needed tools and parts to turn a Ripley into a Titan's Fist worker mech."

	new_name = "APLU \"Titan's Fist\""
	new_desc = "This ordinary mining Ripley has been customized to look like a unit of the Titans Fist."
	new_icon = "titan"
	allowed_types = list("ripley")

/obj/item/paintkit/ripley_mercenary
	name = "APLU \"Strike the Earth!\" customisation kit"
	icon_state = "paintkit_earth"
	desc = "A kit containing all the needed tools and parts to turn a Ripley into an old Mercenaries APLU."


	new_name = "APLU \"Strike the Earth!\""
	new_desc = "Looks like an over worked, under maintained Ripley with some horrific damage."
	new_icon = "earth"
	allowed_types = list("ripley")

/obj/item/paintkit/gygax_syndie
	name = "Syndicate Gygax customisation kit"
	icon_state = "paintkit_Black"
	desc = "A very suspicious kit containing all the needed tools and parts to turn a Gygax into a infamous Black Gygax"

	new_name = "Black Gygax"
	new_desc = "Why does this thing have a Syndicate logo on it? Wait a second..."
	new_icon = "gygax_black"
	allowed_types = list("gygax")

/obj/item/paintkit/gygax_alt
	name = "Old gygax customisation kit"
	icon_state = "paintkit_alt"
	desc = "A kit containing all the needed tools and parts to turn a Gygax into an outdated version of itself. Why would you do that?"

	new_name = "Old Gygax"
	new_desc = "An outdated security exosuit. It is a real achievement to find a preserved exosuit of this model."
	new_icon = "gygax_alt"
	allowed_types = list("gygax")

/obj/item/paintkit/ripley_red
	name = "APLU \"Firestarter\" customisation kit"
	icon_state = "paintkit_red"
	desc = "A kit containing all the needed tools and parts to turn a Ripley into APLU \"Firestarter\""

	new_name = "APLU \"Firestarter\""
	new_desc = "A standard APLU exosuit with stylish orange flame decals."
	new_icon = "ripley_flames_red"
	allowed_types = list("ripley")

/obj/item/paintkit/firefighter_Hauler
	name = "APLU \"Hauler\" customisation kit"
	icon_state = "paintkit_hauler"
	desc = "A kit containing all the needed tools and parts to turn an Ripley into an old engineering exosuit"

	new_name = "APLU \"Hauler\""
	new_desc = "An old engineering exosuit. For lovers of classics."
	new_icon = "hauler"
	allowed_types = list( "firefighter")

/obj/item/paintkit/durand_shire
	name = "Durand \"Shire\" modification kit"
	icon_state = "paintkit_shire"
	desc = "A kit containing all the needed tools and parts to turn a Durand into incredibly heavy war machine."

	new_name = "Shire"
	new_desc = "An incredibly heavy-duty war machine derived from an Interstellar War design."
	new_icon = "shire"
	allowed_types = list("durand")

/obj/item/paintkit/firefighter_zairjah
	name = "APLU \"Zairjah\" customisation kit"
	icon_state = "paintkit_zairjah"
	desc = "A kit containing all the needed tools and parts to turn a Firefighter into weird-looking mining exosuit"

	new_name = "APLU \"Zairjah\""
	new_desc = "A mining mecha of custom design, a closed cockpit with powerloader appendages."
	new_icon = "ripley_zairjah"
	allowed_types = list("firefighter")

/obj/item/paintkit/firefighter_combat
	name = "APLU \"Combat Ripley\" customisation kit"
	icon_state = "paintkit_combat"
	desc = "A kit containing all the needed tools and parts to turn a Firefighter into a real combat exosuit. Weapons are not included!"

	new_name = "APLU \"Combat Ripley\""
	new_desc = "Wait a second, why does his equipment slots spark so dangerously?"
	new_icon = "combatripley"
	allowed_types = list("firefighter")

/obj/item/paintkit/firefighter_Reaper
	name = "APLU \"Reaper\" customisation kit"
	icon_state = "paintkit_death"
	desc = "A kit containing all the needed tools and parts to turn a Firefighter into a famous DeathSquad ripley!"

	new_name = "APLU \"Reaper\""
	new_desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA D- Stop, it's just a painted firefighter."
	new_icon = "deathripley"
	allowed_types = list("firefighter")

/obj/item/paintkit/odysseus_hermes
	name = "Odysseus \"Hermes\" customisation kit"
	icon_state = "paintkit_hermes"
	desc = "A kit containing all the needed tools and parts to turn a Odysseus into a alien-like diving exosuit"

	new_name = "Hermes"
	new_desc = "Heavy-duty diving exosuit developed and produced for for highly specialized underwater operations. How did he end up here?"
	new_icon = "hermes"
	allowed_types = list("odysseus")

/obj/item/paintkit/durand_unathi
	name = "Durand \"Kharn MK. IV\" customisation kit"
	icon_state = "paintkit_unathi"
	desc = "A kit containing all the needed tools and parts to turn a Durand into an alien-like lizard mech"

	new_name = "Kharn MK. IV"
	new_desc = "My life for the empress!"
	new_icon = "unathi"
	allowed_types = list("durand")

/obj/item/paintkit/phazon_imperion
	name = "Phazon \"Imperion\" customisation kit"
	icon_state = "paintkit_imperon"
	desc = "A kit containing all the needed tools and parts to turn your expensive Phazon into more expensive and advanced Imperion"

	new_name = "Imperion"
	new_desc = "The pinnacle of scientific research and pride of Nanotrasen, it uses cutting edge bluespace technology and expensive materials."
	new_icon = "imperion"
	allowed_types = list("phazon")

/obj/item/paintkit/phazon_janus
	name = "Phazon \"Janus\" customisation kit"
	icon_state = "paintkit_janus"
	desc = "A kit containing all the needed tools and parts to turn a Phazon into darker and more expensive version of itself"

	new_name = "Janus"
	new_desc = "The pinnacle of scientific research and pride of Nanotrasen, it uses cutting edge bluespace technology and expensive materials."
	new_icon = "janus"
	allowed_types = list("phazon")

/obj/item/paintkit/phazon_plazmus
	name = "Phazon \"Plazmus\" customisation kit"
	icon_state = "paintkit_plazmus"
	desc = "A kit containing all the needed tools and parts to turn a Phazon into purple mech"

	new_name = "Plazmus"
	new_desc = "So, you combined two of the most dangerous technologies into this thing?"
	new_icon = "plazmus"
	allowed_types = list("phazon")

/obj/item/paintkit/phazon_blanco
	name = "Phazon \"Blanco\" customisation kit"
	icon_state = "paintkit_white"
	desc = "A kit containing all the needed tools and parts to paint your Phazon white"

	new_name = "Blanco"
	new_desc = "It took more than six months of work to find the perfect pastel colors for this mech"
	new_icon = "phazon_blanco"
	allowed_types = list("phazon")

/obj/item/paintkit/firefighter_aluminizer
	name = "APLU \"Aluminizer\" customisation kit"
	icon_state = "paintkit"
	desc = "A kit containing all the needed tools and parts to paint a Firefighter white"

	new_name = "Aluminizer"
	new_desc = "Did you just painted your Ripley white? It looks good."
	new_icon = "aluminizer"
	allowed_types = list("firefighter")

/obj/item/paintkit/odysseus_death
	name = "Odysseus \"Reaper\" customisation kit"
	icon_state = "paintkit_death"
	desc = "A kit containing all the needed tools and parts to turn a Odysseus into terrifying mech"

	new_name = "Reaper"
	new_desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA... get a bad medical treatment?"
	new_icon = "murdysseus"
	allowed_types = list("odysseus")

/obj/item/paintkit/durand_soviet
	name = "Durand \"Dollhouse\" customisation kit"
	icon_state = "paintkit_doll"
	desc = "A kit containing all the needed tools and parts to turn a Durand into soviet mecha. Glory to Space Russia!"

	new_name = "Doll House"
	new_desc = "A extremely heavy-duty combat mech designed in USSP. Glory to Space Russia!"
	new_icon = "dollhouse"
	allowed_types = list("durand")

/obj/item/paintkit/clarke_orangey
	name = "Clarke \"Orangey\" customisation kit"
	icon_state = "paintkit_red"
	desc = "A kit containing all the needed tools and parts to paint a Clarke white"

	new_name = "Orangey"
	new_desc = "Did you just painted your Clarke orange? It looks quite nice."
	new_icon = "orangey"
	allowed_types = list("clarke")

/obj/item/paintkit/clarke_spiderclarke
	name = "Clarke \"Spiderclarke\" customisation kit"
	icon_state = "paintkit_spider"
	desc = "A kit containing all the needed tools and parts to turn a Clarke into terrifying... thing"

	new_name = "Spiderclarke"
	new_desc = "Heavy mining exo-suit coated with chitin. Isn't that a giant spider's scalp on his visor?"
	new_icon = "spiderclarke"
	allowed_types = list("clarke")

/obj/item/paintkit/gygax_pobeda
	name = "Gygax \"Pobeda\" customisation kit"
	icon_state = "paintkit_pobeda"
	desc = "A kit containing all the needed tools and parts to turn a Gygax into a soviet exosuit."

	new_name = "Pobeda"
	new_desc = "A heavy-duty old Gygax designed and painted in USSP. Glory to Space Russia!"
	new_icon = "pobeda"
	allowed_types = list("gygax")

/obj/item/paintkit/gygax_white
	name = "White Gygax customisation kit"
	icon_state = "paintkit_white"
	desc = "A kit containing all the needed tools and parts to paint a Gygax white"

	new_name = "White Gygax"
	new_desc = "Did you just painted your Gygax white? I like it."
	new_icon = "medigax"
	allowed_types = list("gygax")

/obj/item/paintkit/gygax_medgax
	name = "Gygax \"medgax\" customisation kit"
	icon_state = "paintkit_white"
	desc = "A kit containing all the needed tools and parts to turn a Gygax into old \"medical\" gygax"

	new_name = "Medgax"
	new_desc = "OH SHIT THERE IS A COMBAT MECH IN THE HOSPITAL IT'S GONNA KILL US"
	new_icon = "medgax"
	allowed_types = list("gygax")

/obj/item/paintkit/lockermech_syndie
	name = "Locker Mech customisation kit"
	icon_state = "paintkit_syndie"
	desc = "A kit containing all the needed tools and parts to turn a Locker Mech into a Syndie Locker Mech!."
	new_name = "Syndie Locker Mech"
	new_desc = "Dark-red painted locker mech. The paint is still wet."
	new_icon = "syndielockermech"
	allowed_types = list("makeshift")
