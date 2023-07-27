/obj/effect/proc_holder/spell/touch/fake_disintegrate
	name = "Disintegrate"
	desc = "This spell charges your hand with vile energy that can be used to violently explode victims."
	hand_path = "/obj/item/melee/touch_attack/fake_disintegrate"

	school = "evocation"
	clothes_req = FALSE
	base_cooldown = 60 SECONDS
	cooldown_min = 20 SECONDS//100 deciseconds reduction per rank

	action_icon_state = "gib"

