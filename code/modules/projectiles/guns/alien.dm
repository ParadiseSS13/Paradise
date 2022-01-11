//This gun only functions for armalis. The on-sprite is too huge to render properly on other sprites.
/obj/item/gun/energy/noisecannon
	name = "alien heavy cannon"
	desc = "It's some kind of enormous alien weapon, as long as a man is tall."
	icon_state = "noisecannon"
	item_state = "noisecannon"
	recoil = 1
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/sonic)
	cell_type = /obj/item/stock_parts/cell/super
	restricted_species = list(/datum/species/vox/armalis)
	sprite_sheets_inhand = list("Vox Armalis" = 'icons/mob/clothing/species/armalis/held.dmi') //Big guns big birds.

/obj/item/gun/energy/noisecannon/update_icon()
	return

//Casing
/obj/item/ammo_casing/energy/sonic
	projectile_type = /obj/item/projectile/energy/sonic
	fire_sound = 'sound/effects/basscannon.ogg'
	delay = 40

//Projectile.
/obj/item/projectile/energy/sonic
	name = "distortion"
	icon_state = "particle"
	damage = 60
	damage_type = BRUTE
	flag = BULLET
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

	weaken = 5
	stun = 5
