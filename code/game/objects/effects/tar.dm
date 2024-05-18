/obj/effect/tar
    gender = PLURAL
    name = "tar"
    desc = "A sticky substance."
    icon_state = "acid"
    density = FALSE
    opacity = FALSE
    resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
    layer = ABOVE_NORMAL_TURF_LAYER
    var/turf/target
    var/old_slowdown // Variable to store the original slowdown value

/obj/effect/tar/New(turf/loc)
    if (loc.has_tar) // Check if the turf already has tar
        qdel(src) // Delete this instance of tar
        return
    loc.has_tar = TRUE // Mark the turf as having tar
    target = loc
    old_slowdown = target.slowdown // Store the original slowdown value
    target.slowdown += 10 // Apply the slowdown effect to the turf
    RegisterSignal(target, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(remove_tar))
    ..()

/obj/effect/tar/proc/remove_tar(datum/source)
    SIGNAL_HANDLER
    if (target) // Check if the target turf is valid
        target.slowdown = old_slowdown // Restore the original slowdown value
        target.has_tar = FALSE // Mark the turf as no longer having tar
    qdel(src)

/obj/effect/tar/Crossed(AM as mob|obj)
    if (isliving(AM))
        var/mob/living/L = AM
        if (L.flying)
            return
        playsound(L, 'sound/effects/attackblob.ogg', 50, TRUE)
        to_chat(L, "<span class='userdanger'>[src] sticks to you!</span>")
