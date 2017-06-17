datum/spacelaw/modifiers/surrender
	name = "Modifier 102 Surrender"
	desc = "Coming to the brig, confessing what you've done and taking the punishment. Getting arrested without a fuss is not surrender. For this, you have to actually come to the Brig yourself."
	maxM_brig = 0.75

datum/spacelaw/modifiers/coorporation
	name = "Modifier 104 Cooperation with prosecution or security"
	desc = "Being helpful to the members of security, revealing things during questioning or providing names of head revolutionaries."
	maxM_brig = 0.75

datum/spacelaw/modifiers/refusaltocorporate
	name = "Modifier 110 Refusal to Cooperate"
	desc = "When already detained inside the Brig, either in Processing or Temporary Detainment and pending a sentence, refusing to cooperate with Security and instead attempting to break free from their cuffs and/or buckling in such a way that the attending Officers must spend more time preventing their escape than they do actually processing the prisoner."
	maxM_brig = 1.25

datum/spacelaw/modifiers/repeatoffender
	name = "Modifier 111 Repeat Offender"
	desc = "To be repeatedly brigged for the same offense multiple times in a single shift (minimum of three times. Applies on the third brigging). Much like crime stacking, these offenses cannot occur during the same incident. Does not apply to Resisting Arrest."
	max_brig = 5