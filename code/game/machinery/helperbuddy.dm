/obj/machinery/helperbuddy
  name = "Helper Buddy 3.0"
  desc = "A NanoTrasen-approved holographic Helper Buddy!"
  icon_state = "holopad0"
  anchored = 1

  layer = TURF_LAYER+0.1

/obj/machinery/helperbuddy/New()
  ..()
  component_parts = list()
  component_parts += new /obj/item/weapon/circuitboard/helperbuddy(null)
  component_parts += new /obj/item/weapon/stock_parts/capacitor(null)

/obj/machinery/helperbuddy/attackby(obj/item/A as obj, mob/user as mob, params)
  if(default_deconstruction_screwdriver(user, "holopad_open", "holopad0", A))
    return

  if(exchange_parts(user, A))
    return

  if(default_unfasten_wrench(user, A))
    return

  default_deconstruction_crowbar(A)

/obj/machinery/helperbuddy/attack_ai(mob/user as mob)
  return attack_hand(user)


/obj/machinery/helperbuddy/attack_hand(mob/user)
  var/department
  user.set_machine(src)

  if(stat & NOPOWER)
    return

  if(panel_open)
    to_chat(user, "<b>Close the maintenance panel first.</b>")
    return

  var/dat = "Welcome to Helper Buddy 3.0!<BR><BR>Please select a topic from the list below!<BR><BR>"
