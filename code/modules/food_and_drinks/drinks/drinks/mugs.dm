
/obj/item/reagent_containers/food/drinks/mug
	name = "coffee mug"
	desc = "A mug for sipping hot beverages out of."
	icon = 'icons/obj/mugs.dmi'
	icon_state = "mug"
	var/novelty = FALSE
	var/preset = FALSE

/obj/item/reagent_containers/food/drinks/mug/novelty
	name = "novelty coffee mug"
	desc = "A fun mug for your coffee or other hot beverage!"
	novelty = TRUE

/datum/novelty_mug
	var/name = "novelty coffee mug"
	var/description = "A fun mug for your coffee or other hot beverage!"
	var/state = "mug"

/datum/novelty_mug/peace
	name = "peaceful mug"
	description = "It's like... so peaceful, man."
	state = "mug_peace"

/datum/novelty_mug/fire
	name = "fire mug"
	description = "Caution: contents and design may be incredibly hot."
	state = "mug_fire"

/datum/novelty_mug/best
	name = "best mug"
	description = "By decree of this mug, you are the best!"
	state = "mug_best"

/datum/novelty_mug/best/New()
	var/locale = pick("Room's", "Department's", "Station's", "World's", "Sector's", "System's", "Galaxy's", "Universe's", "Multi-verse's", "Nanotrasen's", "Syndicate's")
	var/what = pick("Crewmember", "Spessman", "Employee", "Coffee", "Coffee-drinker", "Survivor", "Personality", "Lifeform", "Doctor", "Scientist", "Engineer", "Officer", "Civillian", "Captain", "Agent")
	name = "\"[locale] Best [what]\" mug"

/datum/novelty_mug/worst
	name = "worst mug"
	description = "By decree of this mug, you are the worst!"
	state = "mug_worst"

/datum/novelty_mug/worst/New()
	var/locale = pick("Room's", "Department's", "Station's", "World's", "Sector's", "System's", "Galaxy's", "Universe's", "Multi-verse's", "Nanotrasen's", "Syndicate's")
	var/what = pick("Crewmember", "Spessman", "Employee", "Coffee", "Coffee-drinker", "Survivor", "Personality", "Lifeform", "Doctor", "Scientist", "Engineer", "Officer", "Civillian", "Captain", "Agent")
	name = "\"[locale] Worst [what]\" mug"

/datum/novelty_mug/insult
	name = "insulting coffee mug"
	description = "How rude!"
	state = "mug_insult"

/datum/novelty_mug/insult/New()
	var/insult = pick("There isn't enough coffee to make you tolerable.", "I drink coffee so I can pretend to like people.", "I haven't had my coffee yet... What's your excuse?", "This coffee is more robust than you.", "Decaf is for weaklings like you.")
	description = "This one says:\"[insult]\""

/datum/novelty_mug/pda
	name = "PDA mug"
	description = "Finally, a use for one of these!"
	state = "mug_pda"

/datum/novelty_mug/rad
	name = "radioactive mug"
	description = "Is coffee supposed to be green... and glowing?"
	state = "mug_rad"

/datum/novelty_mug/tide
	name = "greytide mug"
	description = "This coffee packs almost as much of a punch as a toolbox to the face!"
	state = "mug_tide"

/datum/novelty_mug/happy
	name = "happy mug"
	description = "Even when you aren't, this mug helps you look happy around coworkers."
	state = "mug_happy"

/datum/novelty_mug/pills
	name = "prescription mug"
	description = "Prescription: caffeine. Dosage: As much as it takes."
	state = "mug_pill"

/datum/novelty_mug/rainbow
	name = "rainbow mug"
	description = "So mesmerizing!"
	state = "mug_rainbow"

/obj/item/reagent_containers/food/drinks/mug/New()
	..()
	if(preset)
		return
	if(novelty)
		var/novelty_type = pick(subtypesof(/datum/novelty_mug))
		var/datum/novelty_mug/selected = new novelty_type
		name = selected.name
		desc = selected.description
		icon_state = selected.state
	else
		icon_state = pick("mug_black", "mug_white", "mug_red", "mug_blue", "mug_green", "mug_pink")

/obj/item/reagent_containers/food/drinks/mug/eng
	name = "engineer's mug"
	desc = "A mug engineered to hold your beverage... IN SPACE!"
	icon_state = "mug_eng"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/med
	name = "doctor's mug"
	desc = "A mug that can hold the cure for what ails you!"
	icon_state = "mug_med"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/sci
	name = "scientist's mug"
	desc = "Nothing fuels research like a coffee mug... or grant money!"
	icon_state = "mug_sci"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/sec
	name = "officer's mug"
	desc = "The perfect partner for a sprinkled donut or stunbaton!"
	icon_state = "mug_sec"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/serv
	name = "crewmember's mug"
	desc = "Serve your thirst better than you serve the rest of the crew!"
	icon_state = "mug_serv"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/ce
	name = "chief engineer's mug"
	desc = "Broken and welded back together countless times, just like the station! Probably microwave safe."
	icon_state = "mug_ce"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/hos
	name = "head of security's mug"
	desc = "If only your officers were as robust as this coffee's flavor!"
	icon_state = "mug_hos"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/rd
	name = "research director's mug"
	desc = "Energy tech level: 99"
	icon_state = "mug_rd"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/cmo
	name = "chief medical officer's mug"
	desc = "Fill it with something to keep you awake while you try to keep the crew alive."
	icon_state = "mug_cmo"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/hop
	name = "head of personnel's mug"
	desc = "Are the stains on the bottom coffee or ink?"
	icon_state = "mug_hop"
	preset = TRUE

/obj/item/reagent_containers/food/drinks/mug/cap
	name = "captain's mug"
	desc = "An inscription on the side reads \"Best Captain 2559\"... The last time the station had a worthy captain."
	icon_state = "mug_cap"
	preset = TRUE
