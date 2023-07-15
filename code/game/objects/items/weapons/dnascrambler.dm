/obj/item/dnascrambler
	name = "dna scrambler"
	desc = "An illegal genetic serum designed to randomize the user's identity."
	icon = 'icons/obj/hypo.dmi'
	item_state = "syringe_0"
	icon_state = "lepopen"
	var/used = FALSE
	var/choice

/obj/item/dnascrambler/update_icon_state()
	if(used)
		icon_state = "lepopen0"
	else
		icon_state = "lepopen"

/obj/item/dnascrambler/attack(mob/M as mob, mob/user as mob)
	if(!M || !user)
		return

	if(!ishuman(M) || !ishuman(user))
		return

	if(used)
		return

	if(HAS_TRAIT(M, TRAIT_GENELESS))
		to_chat(user, "<span class='warning'>You failed to inject [M], as [M.p_they()] [M.p_have()] no DNA to scramble, nor flesh to inject.</span>")
		return

	if(M == user)
		user.visible_message("<span class='danger'>[user] injects [user.p_themselves()] with [src]!</span>")
		injected(user, user)
	else
		user.visible_message("<span class='danger'>[user] is trying to inject [M] with [src]!</span>")
		if(do_mob(user,M, 10 SECONDS))
			user.visible_message("<span class='danger'>[user] injects [M] with [src].</span>")
			injected(M, user)
		else
			to_chat(user, "<span class='warning'>You failed to inject [M].</span>")
//To-do: Organs change, visual bugs, default set if nothing selected
/obj/item/dnascrambler/AltClick(mob/user)
	var/list/specieschange = list("Diona" = image(icon = 'icons/mob/human_races/r_diona.dmi', icon_state = "preview"),
									"Human" = image(icon = 'icons/mob/human_races/r_human.dmi', icon_state = "preview"),
									"Skrell" = image(icon = 'icons/mob/human_races/r_skrell.dmi', icon_state = "preview"),
									"Tajaran" = image(icon = 'icons/mob/human_races/r_tajaran.dmi', icon_state = "preview"),
									"Unathi" = image(icon = 'icons/mob/human_races/r_lizard.dmi', icon_state = "preview"),
									"Vulp" = image(icon = 'icons/mob/human_races/r_vulpkanin.dmi', icon_state = "preview"),
									"Nian" = image(icon = 'icons/mob/human_races/r_moth.dmi', icon_state = "preview"),
)
	specieschange["Grey"] = image(icon = 'icons/mob/human_races/r_grey.dmi', icon_state = "preview")
	specieschange["Kidan"] = image(icon = 'icons/mob/human_races/r_kidan.dmi', icon_state = "preview")
	specieschange["Plasmaman"] = image(icon = 'icons/mob/human_races/r_plasmaman_sb.dmi', icon_state = "body")
	specieschange["Slime"] = image(icon = 'icons/mob/human_races/r_slime.dmi', icon_state = "preview")
	specieschange["Vox"] = image(icon = 'icons/mob/human_races/vox/r_vox.dmi', icon_state = "preview")
	specieschange["Drask"] = image(icon = 'icons/mob/human_races/r_drask.dmi', icon_state = "template")
	choice = show_radial_menu(user, src, specieschange, radius = 40)

/obj/item/dnascrambler/proc/injected(mob/living/carbon/human/target, mob/living/carbon/user)
	if(istype(target))
		var/mob/living/carbon/human/H = target
		if(isnull(choice))
			return
		scramble(H, choice)
		H.real_name = random_name(H.gender, H.dna.species.name) //Give them a name that makes sense for their species.
		H.sync_organ_dna(assimilate = 1)
		H.update_body()
		H.reset_hair() //No more winding up with hairstyles you're not supposed to have, and blowing your cover.
		H.reset_markings() //...Or markings.
		H.dna.ResetUIFrom(H)
		H.flavor_text = ""
	target.update_icons()

	add_attack_logs(user, target, "injected with [src]")
	used = TRUE
	update_icon(UPDATE_ICON_STATE)
	name = "used " + name

/obj/item/dnascrambler/proc/scramble(mob/living/carbon/human/M, choice)
	if(!M || !M.dna)
		return
	switch(choice)
		if("Grey")
			M.dna.species = new /datum/species/grey()
		if("Human")
			M.dna.species = new /datum/species/human()
		if("Diona")
			M.dna.species = new /datum/species/diona()
		if("Kidan")
			M.dna.species = new /datum/species/kidan()
		if("Plasmaman")
			M.dna.species = new /datum/species/plasmaman()
		if("Skrell")
			M.dna.species = new /datum/species/skrell()
		if("Slime")
			M.dna.species = new /datum/species/slime()
		if("Tajaran")
			M.dna.species = new /datum/species/tajaran()
		if("Unathi")
			M.dna.species = new /datum/species/unathi()
		if("Vox")
			M.dna.species = new /datum/species/vox()
		if("Vulp")
			M.dna.species = new /datum/species/vulpkanin()
		if("Drask")
			M.dna.species = new /datum/species/drask()
		if("Nian")
			M.dna.species = new /datum/species/moth()
	M.dna.check_integrity()
	for(var/i = 1, i <= DNA_UI_LENGTH - 1, i++)
		M.dna.SetUIValue(i, rand(1, 4095), 1)
	M.dna.UpdateUI()
	M.dna.UpdateSE()
	M.UpdateAppearance()
	domutcheck(M)
