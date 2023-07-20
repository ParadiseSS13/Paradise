#define BATTERY_STATUS_CHARGING		"Battery Charging"
#define BATTERY_STATUS_DRAINING		"Battery Draining"
#define BATTERY_STATUS_DISCHARGING 	"Battery Discharging"
#define BATTERY_STATUS_OVERCHARGING "Battery Overcharging"
#define BATTERY_STATUS_IDLE			"Battery Idle"
#define BATTERY_STATUS_DISABLED		"Battery Disabled"

/obj/machinery/power/battery
	name = "power battery"
	desc = "A power container which can save power over long periods of time"
	icon_state = "smes"
	density = TRUE


	powernet_connection_type = PW_CONNECTION_NODE
	/// Current amount that this battery is charged
	var/charge = 0
	/// The absolute max amount of power that can be stored in the battery
	var/max_capacity = DEFAULT_SAFE_CAPACITY * 2
	/// The current status of the battery, used for debug and power monitoring panels
	var/battery_status = BATTERY_STATUS_IDLE

/obj/machinery/power/battery/Initialize(mapload)
	. = ..()
	connect_to_network()

/obj/machinery/power/battery/connect_to_network(connection_method = powernet_connection_type)
	. = ..()
	if(!.)
		return
	powernet.batteries |= src

/obj/machinery/power/battery/disconnect_from_network()
	powernet.batteries -= src
	return ..()


/// will remove charge from the battery equal to the amount specified or up to what charge is left in the battery, returns amount of energy consumed
/obj/machinery/power/battery/proc/consume_charge(amount)
	var/amount_consumed = clamp(round(amount), 0, charge) // can't consume less than 0, can't consume more than the current charge
	battery_status = amount_consumed ? BATTERY_STATUS_DRAINING : BATTERY_STATUS_IDLE

	charge -= amount_consumed
	return amount_consumed

/// will add charge to the battery equal to the amount specified or up to what the max charge is for the battery
/obj/machinery/power/battery/proc/add_charge(amount)
	var/amount_added = clamp(round(amount), 0, (max_capacity - charge)) // can't consume less than 0, can't consume more than the current charge
	battery_status = amount_added ? BATTERY_STATUS_CHARGING : BATTERY_STATUS_IDLE
	charge += amount_added
	return amount_added
