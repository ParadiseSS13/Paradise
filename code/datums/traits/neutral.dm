//traits with no real impact that can be taken freely
//MAKE SURE THESE DO NOT MAJORLY IMPACT GAMEPLAY. those should be positive or negative traits.

/datum/quirk/no_taste
	name = "Ageusia"
	desc = "You can't taste anything! Toxic food will still poison you."
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = "<span class='notice'>You can't taste anything!</span>"
	lose_text = "<span class='notice'>You can taste again!</span>"
	medical_record_text = "Patient suffers from ageusia and is incapable of tasting food or reagents."


/datum/quirk/neat
	name = "Neat"
	desc = "You really don't like being unhygienic, and will get sad if you are."
	mob_trait = TRAIT_NEAT
	gain_text = "<span class='notice'>You feel like you have to stay clean.</span>"
	lose_text = "<span class='danger'>You no longer feel the need to always be clean.</span>"
	mood_quirk = TRUE