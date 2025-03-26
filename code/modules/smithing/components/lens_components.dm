/obj/item/smithed_item/component/lens_frame
	name = "Debug lens frame"
	icon_state = "lens_frame"
	desc = "Debug smithed component part of a laser lens. If you see this, notify the development team."
	part_type = PART_PRIMARY

/obj/item/smithed_item/component/lens_frame/accelerator
	name = "accelerator lens frame"
	desc = "This is the primary component of an accelerator lens."
	materials = list(MAT_TITANIUM = 4000)
	finished_product = /obj/item/smithed_item/lens/accelerator

/obj/item/smithed_item/component/lens_frame/speed
	name = "speed lens frame"
	desc = "This is the primary component of a speed lens."
	materials = list(MAT_METAL = 4000)
	finished_product = /obj/item/smithed_item/lens/speed

/obj/item/smithed_item/component/lens_frame/amplifier
	name = "amplifier lens frame"
	desc = "This is the primary component of an amplifier lens."
	materials = list(MAT_GOLD = 4000)
	finished_product = /obj/item/smithed_item/lens/amplifier

/obj/item/smithed_item/component/lens_frame/efficiency
	name = "efficiency lens frame"
	desc = "This is the primary component of an efficiency lens."
	materials = list(MAT_SILVER = 4000)
	finished_product = /obj/item/smithed_item/lens/efficiency

/obj/item/smithed_item/component/lens_frame/rapid
	name = "rapid lens frame"
	desc = "This is the primary component of an advanced rapid lens."
	materials = list(MAT_PALLADIUM = 2000)
	finished_product = /obj/item/smithed_item/lens/rapid

/obj/item/smithed_item/component/lens_frame/densifier
	name = "densifier lens frame"
	desc = "This is the primary component of an advanced densifier lens."
	materials = list(MAT_PLATINUM = 2000)
	finished_product = /obj/item/smithed_item/lens/densifier

/obj/item/smithed_item/component/lens_frame/velocity
	name = "velocity lens frame"
	desc = "This is the primary component of an advanced velocity lens."
	materials = list(MAT_BRASS = 30000)
	finished_product = /obj/item/smithed_item/lens/velocity

/obj/item/smithed_item/component/lens_focus
	name = "Debug lens focus"
	icon_state = "lens_focus"
	desc = "Debug smithed component part of a laser lens. If you see this, notify the development team."
	part_type = PART_SECONDARY

/obj/item/smithed_item/component/lens_focus/accelerator
	name = "accelerator lens focus"
	desc = "This is the secondary component of an accelerator lens."
	materials = list(MAT_METAL = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lens/accelerator

/obj/item/smithed_item/component/lens_focus/speed
	name = "speed lens focus"
	desc = "This is the secondary component of a speed lens."
	materials = list(MAT_PLASMA = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lens/speed

/obj/item/smithed_item/component/lens_focus/amplifier
	name = "amplifier lens focus"
	desc = "This is the secondary component of an amplifier lens."
	materials = list(MAT_TITANIUM = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lens/amplifier

/obj/item/smithed_item/component/lens_focus/efficiency
	name = "efficiency lens focus"
	desc = "This is the secondary component of an efficiency lens."
	materials = list(MAT_METAL = 4000, MAT_GLASS = 10000)
	finished_product = /obj/item/smithed_item/lens/efficiency

/obj/item/smithed_item/component/lens_focus/rapid
	name = "rapid lens focus"
	desc = "This is the secondary component of an advanced rapid lens."
	materials = list(MAT_PLASMA = 10000, MAT_GLASS = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/lens/rapid

/obj/item/smithed_item/component/lens_focus/densifier
	name = "densifier lens focus"
	desc = "This is the secondary component of an advanced densifier lens."
	materials = list(MAT_PLASMA = 10000, MAT_GLASS = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/lens/densifier

/obj/item/smithed_item/component/lens_focus/velocity
	name = "velocity lens focus"
	desc = "This is the secondary component of an advanced velocity lens."
	materials = list(MAT_PLASMA = 10000, MAT_GLASS = 10000, MAT_DIAMOND = 2000)
	finished_product = /obj/item/smithed_item/lens/velocity
