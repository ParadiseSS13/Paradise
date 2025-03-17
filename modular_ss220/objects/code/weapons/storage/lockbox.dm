/obj/item/storage/lockbox/experimental_weapon/gateway
	name = "A-48 classified lockbox"
	desc = "Contains a classifed item for experimental purposes."
	var/static/list/loot_options = list(
		/obj/item/gun/energy/sparker/selfcharge = 5,
		/obj/item/mod/module/sphere_transform = 5,
		/obj/item/organ/internal/cyberimp/chest/reviver/hardened = 5,

		/obj/item/organ/internal/cyberimp/arm/toolset_abductor,
		/obj/item/organ/internal/cyberimp/arm/medibeam,
		/obj/item/organ/internal/cyberimp/brain/hackerman_deck,
		/obj/item/organ/internal/eyes/cybernetic/eyesofgod,
		/obj/item/organ/internal/heart/demon/pulse,
	)

/obj/item/storage/lockbox/experimental_weapon/gateway/populate_contents()
	var/spawn_type = pick(loot_options)
	new spawn_type(src)
