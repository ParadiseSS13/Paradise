///Hispania alcohol
/datum/reagent
	var/icon

/datum/reagent/consumable/ethanol/hispania
	icon = 'icons/hispania/obj/drinks.dmi'

/datum/reagent/consumable/ethanol/hispania/fernet /// By Soulster
	name = "Fernet"
	id = "fernet"
	description = "It's Fernet, a drink with a strong bitter taste."
	color = "#15140f"
	dizzy_adj = 3
	alcohol_perc = 0.6
	drink_icon = "fernet_glass"
	drink_name = "Glass of Fernet"
	drink_desc = "A crystal clear glass of Fernet Branca."
	taste_description = "pure bitter oil"

/datum/reagent/consumable/ethanol/hispania/mezcal /// By mazapan
	name = "Mezcal"
	id = "mezcal"
	description = "It's mezcal, like tequila, but hipster."
	color = "#dddcd6"
	dizzy_adj = 3
	alcohol_perc = 0.6
	drink_icon = "mezcal_glass"
	drink_name = "Glass of Mezcal"
	drink_desc = "A crystal clear glass of 400 Conejos with a little worm inside."
	taste_description = "tasty worm"

/datum/reagent/consumable/ethanol/hispania/fernetcola
	name= "Fernet with cola"
	id = "fernetcola"
	description = "A drinkable version of Fernet."
	color = "#2f1b1b"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.4
	drink_icon = "fernetcoke_glass"
	drink_name = "Fernet with cola"
	drink_desc = "It has a nice brown color and a good amount of fizzy foam."
	taste_description = "sweet oil "

/datum/reagent/consumable/ethanol/hispania/michelada
	name= "Michelada"
	id = "michelada"
	description = "Beer with topings, nasty."
	color = "#E6502F"
	alcohol_perc = 0.2
	drink_icon = "michelada"
	drink_name = "michelada"
	drink_desc = "looks spicy and salty, yummi."
	taste_description ="spicy guilt"

/datum/reagent/consumable/ethanol/hispania/vampire
	name= "Vampire"
	id = "vampire"
	description = "You did not have vodka and now you have a piñata."
	color = "#E6502F"
	alcohol_perc = 0.2
	drink_icon = "vampire"
	drink_name = "vampire"
	drink_desc = "Ayayay."
	taste_description ="illegal immigration"

/datum/reagent/consumable/ethanol/hispania/acapulco_de_noche
	name= "Acapulco de noche"
	id = "acapulco_de_noche"
	description = "Gay cocktail with beach look."
	color = "#F9800F"
	alcohol_perc = 0.3
	drink_icon = "acapulco_de_noche"
	drink_name = "acapulco de noche"
	drink_desc = "Ice cold and refreshing drink, smells like medicine.."
	taste_description ="sweat of the 70s."

/datum/reagent/consumable/ethanol/hispania/matadora_beer
	name= "Matadora beer"
	id = "matadora_beer"
	description = "Mix everything that was in the fridge."
	color = "#F9800F"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	alcohol_perc = 0.3
	drink_icon = "matadora_beer"
	drink_name = "matadora beer"
	drink_desc = "It smells strangely good despite its appearance taken out of the garbage."
	taste_description ="lemonade with strawberry soda and medicinal alcohol."

/datum/reagent/consumable/ethanol/hispania/hanky_panky
	name= "Hanky panky"
	id = "hanky_panky"
	description = "Ideal for afterwork."
	color = "#F9800F"
	alcohol_perc = 0.3
	drink_icon = "hanky_panky"
	drink_name = "hanky panky"
	drink_desc = "Bad enough to be served in a pretty glass."
	taste_description ="strong and light at the same time."

/datum/reagent/consumable/ethanol/hispania/hotline_bling
	name= "Hotline Bling"
	id = "hotline_bling"
	description = "You used to call me on my cell phone....."
	color = "#E6502F"
	alcohol_perc = 0.4
	drink_icon = "hotline_bling"
	drink_name = "hotline bling"
	drink_desc = "You see Drake dancing inside"
	taste_description ="good days in california"

/datum/reagent/consumable/ethanol/hispania/peach_bellini
	name= "Peach Bellini"
	id = "peach_bellini"
	description = "Oh la la fancy man."
	color = "#E3E04B"
	alcohol_perc = 0.4
	drink_icon = "peach_bellini"
	drink_name = "Peach Bellini"
	drink_desc = "Oh la la fancy man."
	taste_description ="fresh"

/datum/reagent/consumable/ethanol/hispania/vampire_bf
	name= "Vampire Bestfriend"
	id = "vampire_bf"
	description = "Do you steal the chaplain flask, son?"
	color = "#E0C875"
	alcohol_perc = 0.7
	drink_icon = "vampirebf_glass"
	drink_name = "Vampire Bestfriend"
	drink_desc = "Do you steal the chaplain flask, son?"
	taste_description ="garlic"
