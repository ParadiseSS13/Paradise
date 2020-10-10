//For want of components, this is effectively a power redirection component for the base obj/machinery level.
//This will allow a machine to draw power from sources other than APCs, for use in direct-wire solutions or nucleation abilities.
/datum/power_redirect
    var/name = "Anonymous Redirect" //Purely for admin visualization.
    var/obj/machinery/target //The target machine for redirection. This is what is being powered.
    var/atom/source //The source of the redirect. This is what supplies the power rather than the APC net. Also mostly for admin visualization.

/datum/power_redirect/New(source)
    src.source = source

/datum/power_redirect/proc/supply_to(obj/machinery/new_target) //Changes the target to the new machine, and adds itself to the redirects.
    target = new_target
    if(new_target)
        new_target.redirects += src
        new_target.power_change()

/datum/power_redirect/proc/cut_target() //Removes itself from the redirects and unsets its' target.
    if(target)
        target.redirects -= src
        target.power_change()
    target = null

/datum/power_redirect/proc/powered() //Override with your logic to determine if the redirect is powered. Return TRUE to declare powered.
    return FALSE

/datum/power_redirect/proc/use_power(amount) //Override with your logic to subtract power from a source.
    return