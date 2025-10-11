/obj/item/smithed_item/tool_bit
	name = "Debug tool bit"
	icon_state = "bit"
	desc = "Debug tool bit. If you see this, notify the development team."
	/// Base Speed modifier
	var/base_speed_mod = 0
	/// Base Efficiency modifier
	var/base_efficiency_mod = 0
	/// Base productivity modifier
	var/base_productivity_mod = 0
	/// Productivity mod
	var/productivity_mod = 1.0
	/// Speed modifier
	var/speed_mod = 1.0
	/// Efficiency modifier
	var/efficiency_mod = 1.0
	/// Failure rate
	var/failure_rate = 0
	/// Size modifier
	var/size_mod = 0
	/// Durability
	var/durability = 90
	/// Max durability
	var/max_durability = 90
	/// The tool the bit is attached to
	var/obj/item/attached_tool

/obj/item/smithed_item/tool_bit/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(istype(target, /obj/item))
		SEND_SIGNAL(target, COMSIG_BIT_ATTACH, src, user)
		return ITEM_INTERACT_COMPLETE

/obj/item/smithed_item/tool_bit/set_stats()
	..()
	durability = initial(durability) * material.durability_mult
	max_durability = durability
	size_mod = initial(size_mod) + material.size_mod
	speed_mod = 1 + (base_speed_mod * quality.stat_mult * material.tool_speed_mult)
	failure_rate = initial(failure_rate) * quality.stat_mult * material.tool_failure_mult
	efficiency_mod = 1 + (base_efficiency_mod * quality.stat_mult * material.power_draw_mult)
	productivity_mod = 1 + (base_productivity_mod * quality.stat_mult * material.tool_productivity_mult)

/obj/item/smithed_item/tool_bit/on_attached(obj/item/target)
	if(!istype(target))
		return
	attached_tool = target
	attached_tool.w_class += size_mod
	attached_tool.toolspeed = attached_tool.toolspeed * speed_mod
	attached_tool.bit_failure_rate += failure_rate
	attached_tool.bit_efficiency_mod = attached_tool.bit_efficiency_mod * efficiency_mod
	attached_tool.bit_productivity_mod = attached_tool.bit_productivity_mod * productivity_mod

/obj/item/smithed_item/tool_bit/on_detached()
	attached_tool.toolspeed = attached_tool.toolspeed / speed_mod
	attached_tool.w_class -= size_mod
	attached_tool.bit_failure_rate -= failure_rate
	attached_tool.bit_efficiency_mod = attached_tool.bit_efficiency_mod / efficiency_mod
	attached_tool.bit_productivity_mod = attached_tool.bit_productivity_mod / productivity_mod
	attached_tool.attached_bits -= src
	attached_tool = null

/obj/item/smithed_item/tool_bit/examine(mob/user)
	. = ..()
	var/healthpercent = (durability/max_durability) * 100
	switch(healthpercent)
		if(80 to 100)
			. +=  "It looks pristine."
		if(60 to 79)
			. +=  "It looks slightly used."
		if(40 to 59)
			. +=  "It's seen better days."
		if(20 to 39)
			. +=  "It's been heavily used."
		if(0 to 19)
			. +=  "<span class='warning'>It's falling apart!</span>"

/obj/item/smithed_item/tool_bit/proc/damage_bit()
	durability--
	if(istype(attached_tool, /obj/item/rcd))
		durability--
	if(durability == 0)
		break_bit()

/obj/item/smithed_item/tool_bit/proc/break_bit()
	on_detached()
	qdel(src)

/obj/item/smithed_item/tool_bit/speed
	name = "speed bit"
	desc = "A tool bit optimized for speed, at the cost of efficiency."
	base_speed_mod = -0.2
	failure_rate = 5
	base_efficiency_mod = 0.1
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/tool_bit/efficiency
	name = "efficient bit"
	desc = "A tool bit optimized for efficiency, at the cost of speed."
	base_speed_mod = 0.2
	base_efficiency_mod = -0.25
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/tool_bit/balanced
	name = "balanced bit"
	desc = "A tool bit that's fairly balanced in all aspects."
	base_speed_mod = -0.1
	failure_rate = 2
	base_productivity_mod = 0.5
	base_efficiency_mod = -0.1
	secondary_goal_candidate = TRUE

/obj/item/smithed_item/tool_bit/heavy
	name = "heavy duty bit"
	desc = "A large, advanced tool bit that maximises speed."
	base_speed_mod = -0.4
	failure_rate = 10
	base_efficiency_mod = 0.25
	size_mod = 1
	durability = 120

/obj/item/smithed_item/tool_bit/productivity
	name = "productivity bit"
	desc = "A tool bit that minimizes waste."
	base_speed_mod = -0.1
	base_productivity_mod = 2
	durability = 50

/obj/item/smithed_item/tool_bit/economical
	name = "economical bit"
	desc = "An advanced tool bit that maximises efficiency."
	base_speed_mod = 0.4
	base_efficiency_mod = -0.45
	durability = 60

/obj/item/smithed_item/tool_bit/advanced
	name = "advanced bit"
	desc = "An advanced tool bit that's fairly balanced in all aspects."
	base_speed_mod = -0.25
	base_productivity_mod = 1
	failure_rate = 2
	base_efficiency_mod = -0.3

/obj/item/smithed_item/tool_bit/admin
	name = "adminium bit"
	desc = "A hyper-advanced bit restricted to central command officials."
	speed_mod = -1
	failure_rate = -20
	durability = 300
	productivity_mod = 4
	quality = /datum/smith_quality/masterwork
	material = /datum/smith_material/platinum

/obj/item/smithed_item/tool_bit/AltClick(mob/user, modifiers)
	if(!HAS_TRAIT(user.mind, TRAIT_SMITH))
		return
	if(do_after_once(user, 3 SECONDS, target = src, allow_moving = TRUE, must_be_held = TRUE))
		var/compiled_message = "<span class='notice'>\
		You determine the following properties on [src]: <br>\
		Base Speed mod: [base_speed_mod] <br>\
		Base Efficiency mod: [base_efficiency_mod] <br>\
		Base Productivity mod: [base_productivity_mod] <br>\
		Speed Multiplier: [speed_mod] <br>\
		Efficiency Multiplier: [efficiency_mod] <br>\
		Productivity Multiplier: [productivity_mod] <br>\
		Failure Rate: [failure_rate] <br>\
		Size Mod: [size_mod] <br>\
		Durability: [durability] <br>\
		</span>"
		to_chat(user, compiled_message)
