/obj/item/projectile/forcebolt
	name = "force bolt"
	icon_state = "ice_1"
	damage = 20
	flag = "energy"

/obj/item/projectile/forcebolt/strong

/obj/item/projectile/forcebolt/on_hit(atom/movable/target, blocked = 0)
	. = ..()
	if(istype(target) && blocked < 100)
		var/throwdir = get_dir(firer, target)
		target.throw_at(get_edge_target_turf(target, throwdir), 10, 10)
