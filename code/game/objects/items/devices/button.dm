/obj/item/money_button
	name = "red button"
	desc = "If you press this button, you will get 1000 credits. HOWEVER, one random crewmember will die, which can be you. If you press the button, the button will transfer to someone else."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "syndicate=2"
	var/mob/living/carbon/human/last_pressed_person
	var/last_pressed_time

/obj/item/money_button/attack_self(mob/living/carbon/human/user)
	if(last_pressed_time > world.time)
		to_chat(user, "<span class='notice'>Wait a bit before clicking the button!</span>")
		return

	if(!istype(user))
		return

	last_pressed_time = world.time + 1 MINUTES
	var/tries = 0
	var/list/copy_list = GLOB.alive_mob_list.Copy()

	if(prob(10) && last_pressed_person) // Fuck you for selling your colleague's lives for a measly 1k credits.
		var/datum/organ/organ_datum = last_pressed_person.get_int_organ_datum(ORGAN_DATUM_HEART)
		qdel(organ_datum.linked_organ)
		to_chat(last_pressed_person, "<span class='biggerdanger'>This is your punishment for selling someone's life.</span>")
	else
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
			break

	if(tries >= 30)
		to_chat(user, "No organ donors have been found yet.")
		return

	new /obj/item/stack/spacecash/c1000(get_turf(user))
	tries = 0
	while(tries < 30)
		var/mob/living/carbon/human/new_test_subject = pick(copy_list)
		if(!new_test_subject.mind || new_test_subject.mind.offstation_role || (user == new_test_subject))
			tries++
			copy_list -= new_test_subject
			continue
		user.unEquip(src, TRUE)
		forceMove(get_turf(new_test_subject))
		new_test_subject.put_in_hands(src)
		to_chat(new_test_subject, "<span class'biggerdanger'>I want to play a game with you. Press the button and you will receive 1000 credits, but a random person will die, which can be you. Choose wisely.</span>")
		break
	last_pressed_person = user
