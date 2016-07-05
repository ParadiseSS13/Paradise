/datum/job/prisoner
	title = "D-class Prisoner"
	flag = PRISONER
	department_flag = SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "security officers"
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/prisoner
	access = list()
	minimal_access = list()
	prisonlist_job = 1

/datum/job/prisoner/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_or_collect(new /obj/item/clothing/under/color/orange(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/orange(H), slot_shoes)
	H.equip_or_collect(new /obj/item/weapon/storage/box/survival/prisoner(H), slot_r_hand)
	return 1

/obj/effect/datacore/proc/fabricate_crime(var/mob/living/carbon/human/P)
  var/id = add_zero(num2hex(rand(1, 1.6777215E7)), 6)
  var/list/commited_crime_major = list("Public Enemy",
                 "Bank Robber",
                 "Murderer",
                 "Maniac",
                 "Terrorist",
                 "Gang Boss",
                 "None",
                 "None",
                 "Smuggler",
                 "Kidnapper")

  var/commited_crime_minor = list("Arsonist",
                "Blackmailer",
                "Shoplifter",
                "Hijacker",
                "Pickpocket",
                "Thief",
                "Vandal")

  var/datum/data/record/G = new()
  G.fields["id"]			= id
  G.fields["name"]		= P.real_name
  G.fields["criminal"]	= "Incarcerated"
  G.fields["mi_crim"]		= "[pick(commited_crime_minor)]"
  G.fields["mi_crim_d"]	= "Do not try to release."
  G.fields["ma_crim"]		= "[pick(commited_crime_major)]"
  G.fields["ma_crim_d"]	= "Convicted by NT to Permabrig Sentence"
  G.fields["notes"]		= "(TOP SECRET) WHITELIST INITIATIVE - CENTRAL COMMAND ACCESS ONLY"
  security += G
  return
