/datum/quirk/no_taste
	name = "Ageusia"
	desc = "You can't taste anything! Toxic food will still poison you."
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = "<span class='notice'>You can't taste anything!</span>"
	lose_text = "<span class='notice'>You can taste again!</span>"
	medical_record_text = "Patient suffers from ageusia and is incapable of tasting food or reagents."

/*/datum/quirk/terminator
	name = "Terminator"
	desc = "Eres un IPC que has sido usado para la guerra. Eres resistente, pero tosco y lento. (Solo afecta a los IPC)"
	value = 0
	lose_text = "<span class='notice'>Tu cuerpo se aligera, pero te sientes fragil.</span>"

/datum/quirk/terminator/add()
	if(ismachineperson(quirk_holder))
		quirk_holder.dna.species.brute_mod -= 1
		quirk_holder.dna.species.burn_mod -= 1
		quirk_holder.dna.species.speed_mod += 2
		to_chat(quirk_holder, "<span class='notice'>Te sientes resistente, pero lento.</span>")*/
