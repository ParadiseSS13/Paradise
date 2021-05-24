/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	value = -4
	mob_trait = TRAIT_PACIFISM
	gain_text = "<span class='danger'>You feel repulsed by the thought of violence!</span>"
	lose_text = "<span class='notice'>You think you can defend yourself again.</span>"
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."

/datum/quirk/diacaluroso
	name = "Heat Intolerance"
	desc = "Your body cant handle heat. Heat damage it's deadlier than usual."
	value = -1
	gain_text = "<span class='danger'>I dont like warm enviroments.</span>"
	lose_text = "<span class='notice'>Vacations to a beach now don't look that bad.</span>"

/datum/quirk/diacaluroso/add()
	quirk_holder.dna.species.heatmod += 1

/datum/quirk/diafrio
	name = "Cold Intolerance"
	desc = "Your body cant handle cold. Cold damage it's deadlier than usual."
	value = -1
	gain_text = "<span class='danger'>I dont like cold enviroments.</span>"
	lose_text = "<span class='notice'>Vacations to a mountain now don't look that bad.</span>"

/datum/quirk/diafrio/add()
	quirk_holder.dna.species.coldmod += 1

/datum/quirk/manco
	name = "One-Hand"
	desc = "You lost one hand a long time ago."
	value = -2
	gain_text = "<span class='danger'>Where is my hand... Ah yeah that...</span>"
	lose_text = "<span class='notice'>Well now i can land a hand!.</span>"
	medical_record_text = "Patient lost one hand a long time ago on and incident."

/datum/quirk/manco/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/picked_hand = pick("l_hand", "r_hand")
	var/obj/item/organ/external/M = H.get_organ(picked_hand)
	qdel(M)

/datum/quirk/dedosgordos
	name = "Big Fingers"
	desc = "Your fingers are so big that standard triggers just wont fit."
	value = -2
	mob_trait = TRAIT_CHUNKYFINGERS
	gain_text = "<span class='danger'>Your old trusty sausage fingers are here!</span>"
	lose_text = "<span class='notice'>Where are your lovely sausage fingers?!.</span>"
	medical_record_text = "Patient fingers are abnormally huge."

/datum/quirk/debilucho
	name = "Weak"
	desc = "Your body is not that robust."
	value = -2
	gain_text = "<span class='danger'>I hope we dont get into a fight.</span>"
	lose_text = "<span class='notice'>I can fight anyone right now.</span>"

/datum/quirk/debilucho/add()
	quirk_holder.dna.species.brute_mod += 0.7
	to_chat(quirk_holder, "<span class='notice'>Lets just be nice and avoid any fights.</span>")

/datum/quirk/pielligera
	name = "Thin Skin"
	desc = "Your skin its easy to burn."
	value = -2
	gain_text = "<span class='danger'>Lets just try to avoid any fire.</span>"
	lose_text = "<span class='notice'>Fire its not that scary anymore.</span>"

/datum/quirk/pielligera/add()
	quirk_holder.dna.species.burn_mod += 0.7
	to_chat(quirk_holder, "<span class='notice'>Fire in space? I'm going to be fine.</span>")

/datum/quirk/crazybastard ///The fuck are you doing taking this trait?????
	name = "Cursed from birth"
	desc = "Your skin and body are so weak it's a miracle you made it this far on life."
	value = -6
	gain_text = "<span class='danger'>I dont want any troubles with anyone.</span>"
	lose_text = "<span class='notice'>Its the curse finally gone?</span>"

/datum/quirk/crazybastard/add()
	quirk_holder.dna.species.burn_mod += 1.8
	quirk_holder.dna.species.brute_mod += 1.8
	to_chat(quirk_holder, "<span class='notice'>I dont want any troubles.</span>")
