/obj/item/paper/fluff/lavaland_xenobiologist
	name = "Important Notice"
	info = "To the research team at Xenobiology site LD-472<br><br> \
	I would like to remind you all to NOT MESS THIS UP, as you all aware, you were sent to that hellish place that barely counts as habitable after what you did to the Director's cat, \
	Be lucky that you haven't been sent to work in accounting. As per instructions, catalogue whatever abomination that lives on that hellscape and, if possible, capture them.<br><br>  \
	AVOID the larger life forms, the so called 'megafauna', as they are impossible to contain and are a massive health hazard.<br><br> \
	As a side note, those bastards from Nanotrasen moved in a while back, despite the fact that we made a claim on this sector of space with the Sol government. Avoid interacting with any of the crew \
	and, unless they are tring to steal or harm you, do NOT steal, injure or kill them, we cannot afford the legal fees against any 'damages' caused to Nanotrasen.<br><br> \
	\ -  Regional Research Manager"

/obj/effect/mob_spawn/human/researcher/lavaland
	name = "Xenobiologist Cryogenic Pod"
	desc = "A one use cryogenic pod usually used for when staff awaits for further tasks."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	mob_name = "a lavaland researcher"
	flavour_text = "<span class='big bold'>You are a Xenobiologist</span><b> You have been stationed for a while on this hellish hellscape, in attempt to catalogue and capture the local fauna. \
	You however received several instructors from your superiors, to avoid the so called \'mega fauna'\ as capturing and researching them is near impossible, and to be wary of the local Nanotrasen  \
	Crew stationed in the local space sector, as Nanotrasen is <i>notorious</i> on taking the research and resources from other companies and branding it as their own.</b>"

	suit = /obj/item/clothing/suit/storage/labcoat
	uniform = /obj/item/clothing/under/rank/ntrep
	shoes = /obj/item/clothing/shoes/laceup
	id = /obj/item/card/id/away/old/sci


	assignedrole = "Lavaland Researcher"

/obj/effect/mob_spawn/human/researcher/lavaland/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()