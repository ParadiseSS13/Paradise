#define MODKIT_HELMET 1
#define MODKIT_SUIT 2
#define MODKIT_FULL 3

/obj/item/device/modkit
	name = "hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user."
	icon_state = "modkit"
	var/parts = MODKIT_FULL
	var/target_species = "Human"

	var/list/permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig,
		/obj/item/clothing/suit/space/rig
		)

/obj/item/device/modkit/afterattack(obj/O, mob/user as mob, proximity)
	if(!proximity)
		return

	if(!target_species)
		return	//it shouldn't be null, okay?

	if(!parts)
		to_chat(user, "<span class='warning'>This kit has no parts for this modification left.</span>")
		user.unEquip(src)
		qdel(src)
		return

	var/allowed = 0
	for(var/permitted_type in permitted_types)
		if(istype(O, permitted_type))
			allowed = 1

	var/obj/item/clothing/I = O
	if(!istype(I) || !allowed)
		to_chat(user, "<span class='notice'>[src] is unable to modify that.</span>")
		return

	var/excluding = ("exclude" in I.species_restricted)
	var/in_list = (target_species in I.species_restricted)
	if(excluding ^ in_list)
		to_chat(user, "<span class='notice'>[I] is already modified.</span>")
		return

	if(!isturf(O.loc))
		to_chat(user, "<span class='warning'>[O] must be safely placed on the ground for modification.</span>")
		return

	playsound(user.loc, 'sound/items/Screwdriver.ogg', 100, 1)

	user.visible_message("\red [user] opens \the [src] and modifies \the [O].","\red You open \the [src] and modify \the [O].")

	I.refit_for_species(target_species)

	if(istype(I, /obj/item/clothing/head/helmet))
		parts &= ~MODKIT_HELMET
	if(istype(I, /obj/item/clothing/suit))
		parts &= ~MODKIT_SUIT

	if(!parts)
		user.unEquip(src)
		qdel(src)

/obj/item/device/modkit/examine(mob/user)
	..(user)
	to_chat(user, "It looks as though it modifies hardsuits to fit [target_species] users.")

/obj/item/device/modkit/tajaran
	name = "Tajaran hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajaran."
	target_species = "Tajaran"

/obj/item/device/modkit/unathi
	name = "Unathi hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another species. This one looks like it's meant for Unathi."
	target_species = "Unathi"

/obj/item/device/modkit/skrell
	name = "Skrell hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another species. This one looks like it's meant for Skrell."
	target_species = "Skrell"

/obj/item/device/modkit/vox
	name = "Vox hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another species. This one looks like it's meant for Vox."
	target_species = "Vox"