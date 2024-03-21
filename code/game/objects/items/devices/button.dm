/obj/item/money_button
	name = "red button"
	desc = "If you press this button, you will get 1000 credits. HOWEVER, one random crewmember will die, which can be you. If you press the button, the button will transfer to someone else."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "syndicate=2"
	var/mob/living/last_pressed_person

/obj/item/money_button/attack_self(mob/user)
	if(!istype(user))
		return

	if(prob(10) && last_pressed_person) // Fuck you for selling your colleague's lives for a measly 1k credits.
		last_pressed_person.death()
	else
		var/list/copy_list = GLOB.alive_mob_list
		var/tries = 0
		while(tries < 30)
			var/mob/living/carbon/human/bad_luck_brandon = pick(copy_list)
			if(!istype(bad_luck_brandon))
				copy_list -= bad_luck_brandon
				continue
			if(!bad_luck_brandon.mind)
				tries++
				copy_list -= bad_luck_brandon
				continue
			if(!bad_luck_brandon.mind.assigned_role || bad_luck_brandon.mind.offstation_role)
				tries++
				copy_list -= bad_luck_brandon
				continue
			to_chat(bad_luck_brandon, "<span class='biggerdanger'>You have been randomly selected to donate your heart!</span>")
			var/datum/organ/organ_datum = bad_luck_brandon.get_int_organ_datum(ORGAN_DATUM_HEART)
			qdel(organ_datum.linked_organ)
			new /obj/item/stack/spacecash/c1000(get_turf(user))
			break

		if(tries >= 30)
			to_chat(user, "No organ donors have been found yet.")
			return
		tries = 0
		while(tries < 30)
			var/mob/living/carbon/human/new_test_subject = pick(copy_list)
			if(!new_test_subject.mind || new_test_subject.mind.offstation_role || (user == new_test_subject))
				tries++
				copy_list -= new_test_subject
				continue
			forceMove(get_turf(new_test_subject))
			new_test_subject.put_in_hands(src)
			break
	last_pressed_person = user
