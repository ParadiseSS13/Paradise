#define MODKIT_HELMET 1
#define MODKIT_SUIT 2
#define MODKIT_FULL 3

/obj/item/device/modkit
	name = "hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user."
	icon_state = "modkit"
	var/parts = MODKIT_FULL
	var/list/target_species = list("Human","Skrell")

	var/list/permitted_types = list(
		/obj/item/clothing/head/helmet/space/rig,
		/obj/item/clothing/suit/space/rig
		)

/obj/item/device/modkit/afterattack(obj/O, mob/user as mob)

	if(!parts)
		user << "<span class='warning'>This kit has no parts for this modification left.</span>"
		user.drop_from_inventory(src)
		del(src)
		return

	/* TODO: list comparison
	if(istype(O,to_type))
		user << "<span class='notice'>[O] is already modified.</span>"
		return
	*/

	if(!isturf(O.loc))
		user << "<span class='warning'>[O] must be safely placed on the ground for modification.</span>"
		return

	playsound(user.loc, 'sound/items/Screwdriver.ogg', 100, 1)

	user.visible_message("\red [user] opens \the [src] and modifies \the [O].","\red You open \the [src] and modify \the [O].")

	var/obj/item/clothing/I = O
	if(istype(I))
		I.species_restricted = target_species.Copy()

	parts--
	if(!parts)
		user.drop_from_inventory(src)
		del(src)

/obj/item/device/modkit/tajaran
	name = "tajaran hardsuit modification kit"
	desc = "A kit containing all the needed tools and parts to modify a hardsuit for another user. This one looks like it's meant for Tajara."
	target_species = list("Tajaran")

/obj/item/device/modkit/examine()
	..()
	usr << "It looks as though it modifies hardsuits to fit the following users:"
	for(var/species in target_species)
		usr << "- [species]"