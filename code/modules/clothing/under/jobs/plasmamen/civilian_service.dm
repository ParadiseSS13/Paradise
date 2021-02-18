/obj/item/clothing/under/plasmaman/cargo
	name = "cargo plasma envirosuit"
	desc = "An envirosuit used by plasmaman quartermasters and cargo techs alike, due to the logistical problems of differentiating the two by the length of their pant legs."
	icon_state = "cargo_envirosuit"
	item_state = "cargo_envirosuit"
	item_color = "cargo_envirosuit"

/obj/item/clothing/under/plasmaman/mining
	name = "mining plasma envirosuit"
	desc = "An airtight khaki suit designed for operations on Lavaland by plasmamen."
	icon_state = "explorer_envirosuit"
	item_state = "explorer_envirosuit"
	item_color = "explorer_envirosuit"


/obj/item/clothing/under/plasmaman/chef
	name = "chef's plasma envirosuit"
	desc = "A white plasmaman envirosuit designed for culinary practices. One might question why a member of a species that doesn't need to eat would become a chef."
	icon_state = "chef_envirosuit"
	item_state = "chef_envirosuit"
	item_color = "chef_envirosuit"

/obj/item/clothing/under/plasmaman/enviroslacks
	name = "enviroslacks"
	desc = "The pet project of a particularly posh plasmaman, this custom suit was quickly appropriated by Nanotrasen for its detectives, lawyers, and bartenders alike."
	icon_state = "enviroslacks"
	item_state = "enviroslacks"
	item_color = "enviroslacks"

/obj/item/clothing/under/plasmaman/chaplain
	name = "chaplain's plasma envirosuit"
	desc = "An envirosuit specially designed for only the most pious of plasmamen."
	icon_state = "chap_envirosuit"
	item_state = "chap_envirosuit"
	item_color = "chap_envirosuit"

/obj/item/clothing/under/plasmaman/librarian
	name = "librarian's plasma envirosuit"
	desc = "Made out of a modified voidsuit, this suit was Nanotrasen's first solution to the *logistical problems* that come with employing plasmamen. Due to the modifications, the suit is no longer space-worthy. Despite their limitations, these suits are still in used by historian and old-styled plasmamen alike."
	icon_state = "prototype_envirosuit"
	item_state = "prototype_envirosuit"
	item_color = "prototype_envirosuit"

/obj/item/clothing/under/plasmaman/janitor
	name = "janitor's plasma envirosuit"
	desc = "A grey and purple envirosuit designated for plasmaman janitors."
	icon_state = "janitor_envirosuit"
	item_state = "janitor_envirosuit"
	item_color = "janitor_envirosuit"

/obj/item/clothing/under/plasmaman/botany
	name = "botany envirosuit"
	desc = "A green and blue envirosuit designed to protect plasmamen from minor plant-related injuries."
	icon_state = "botany_envirosuit"
	item_state = "botany_envirosuit"
	item_color = "botany_envirosuit"


/obj/item/clothing/under/plasmaman/mime
	name = "mime envirosuit"
	desc = "It's not very colourful."
	icon_state = "mime_envirosuit"
	item_state = "mime_envirosuit"
	item_color = "mime_envirosuit"

/obj/item/clothing/under/plasmaman/clown
	name = "clown envirosuit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown_envirosuit"
	item_state = "clown_envirosuit"
	item_color = "clown_envirosuit"

/obj/item/clothing/under/plasmaman/assistant
	name = "Assistant envirosuit"
	desc = "The finest from the bottom of the plasmamen clothing barrel."
	icon_state = "assistant_envirosuit"
	item_state = "assistant_envirosuit"
	item_color = "assistant_envirosuit"

/obj/item/clothing/under/plasmaman/clown/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message("<span class='warning'>[H]'s suit spews out a tonne of space lube!</span>", "<span class='warning'>Your suit spews out a tonne of space lube!</span>")
			H.ExtinguishMob()
			new /obj/effect/particle_effect/foam(loc) //Truely terrifying.
	return FALSE

/obj/item/clothing/under/plasmaman/hop
	name = "head of personnel envirosuit"
	desc = "An envirosuit designed for plasmamen employed as the head of personnel."
	icon_state = "hop_envirosuit"
	item_state = "hop_envirosuit"
	item_color = "hop_envirosuit"

/obj/item/clothing/under/plasmaman/captain
	name = "captain envirosuit"
	desc = "An envirosuit designed for plasmamen employed as the captain."
	icon_state = "cap_envirosuit"
	item_state = "cap_envirosuit"
	item_color = "cap_envirosuit"

/obj/item/clothing/under/plasmaman/blueshield
	name = "blueshield envirosuit"
	desc = "An envirosuit designed for plasmamen employed as the blueshield."
	icon_state = "bs_envirosuit"
	item_state = "bs_envirosuit"
	item_color = "bs_envirosuit"
