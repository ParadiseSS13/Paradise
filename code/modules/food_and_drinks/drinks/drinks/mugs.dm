
/obj/item/weapon/reagent_containers/food/drinks/mug
	name = "coffee mug"
	desc = "A mug for sipping hot beverages out of."
	icon = 'icons/obj/mugs.dmi'
	icon_state = "mug"
	var/novelty = FALSE

/obj/item/weapon/reagent_containers/food/drinks/mug/novelty
	name = "novelty coffee mug"
	desc = "A fun mug for your coffee or other hot beverage!"
	novelty = TRUE

/obj/item/weapon/reagent_containers/food/drinks/mug/New()
	..()
	if(novelty)
		var/novelty_select = pick("peace", "fire", "best", "worst", "insult", "pda", "rad", "tide", "happy", "pills", "rainbow")
		switch(novelty_select)
			if("peace")
				name = "peaceful mug"
				desc = "It's like... so peaceful, man."
				icon_state = "mug_peace"
			if("fire")
				name = "fire mug"
				desc = "Caution: contents and design may be incredibly hot."
				icon_state = "mug_fire"
			if("best")
				var/locale = pick("Room's", "Department's", "Station's", "World's", "Sector's", "System's", "Galaxy's", "Universe's", "Multi-verse's", "Nanotrasen's", "Syndicate's")
				var/what = pick("Crewmember", "Spessman", "Employee", "Coffee", "Coffee-drinker", "Survivor", "Personality", "Lifeform", "Doctor", "Scientist", "Engineer", "Officer", "Civillian", "Captain", "Agent")
				name = "\"[locale] Best [what]\" mug"
				desc = "By decree of this mug, you are the best!"
				icon_state = "mug_best"
			if("worst")
				var/locale = pick("Room's", "Department's", "Station's", "World's", "Sector's", "System's", "Galaxy's", "Universe's", "Multi-verse's", "Nanotrasen's", "Syndicate's")
				var/what = pick("Crewmember", "Spessman", "Employee", "Coffee", "Coffee-drinker", "Survivor", "Personality", "Lifeform", "Doctor", "Scientist", "Engineer", "Officer", "Civillian", "Captain", "Agent")
				name = "\"[locale] Worst [what]\" mug"
				desc = "By decree of this mug, you are the worst!"
				icon_state = "mug_worst"
			if("insult")
				var/insult = pick("There isn't enough coffee to make you tolerable.", "I drink coffee so I can pretend to like people.", "I haven't had my coffee yet... What's your excuse?", "This coffee is more robust than you.", "Decaf is for weaklings like you.")
				name = "insulting coffee mug"
				desc = "This one says:\"[insult]\""
				icon_state = "mug_insult"
			if("pda")
				name = "PDA mug"
				desc = "Finally, a use for one of these things!"
				icon_state = "mug_pda"
			if("rad")
				name = "radioactive mug"
				desc = "Is coffee supposed to be green... and glowing?"
				icon_state = "mug_rad"
			if("tide")
				name = "greytide mug"
				desc = "This coffee packs almost as much of a punch as a toolbox to the face!"
				icon_state = "mug_tide"
			if("happy")
				name = "happy mug"
				desc = "Even when you aren't, this mug helps you look happy around coworkers."
				icon_state = "mug_happy"
			if("pills")
				name = "prescription mug"
				desc = "Prescription: caffeine. Dosage: As much as it takes."
				icon_state = "mug_pills"
			if("rainbow")
				name = "rainbow mug"
				desc = "So mesmerizing!"
				icon_state = "mug_rainbow"
	else
		icon_state = pick("mug_black", "mug_white", "mug_red", "mug_blue", "mug_green", "mug_pink")


