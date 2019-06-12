/datum/component/idle_warning
    var/last_action_timer // Last time stamp of which the user did something
    var/ahelp_text // Text to send to the admins if the person goes AFK
    var/time // Time it takes to be AFK to send an ahelp
    var/warning_given = FALSE

/datum/component/idle_warning/Initialize(ahelp_message_text, send_time)
    var/mob/living/M = parent
    if(!istype(M) || !M.mind) //Something went wrong
        return COMPONENT_INCOMPATIBLE
    ahelp_text = ahelp_message_text
    time = send_time
    RegisterSignal(M, COMSIG_CLICK, .proc/activity)
    RegisterSignal(M, COMSIG_LIVING_LIFE, .proc/life)
    RegisterSignal(M, COMSIG_CLIENT_MOVE, .proc/activity)
    RegisterSignal(M.mind, COMSIG_MIND_TRANSFER_TO, .proc/transfer_mind)
    last_action_timer = start_watch() // Reset the timer
    addtimer(CALLBACK(GLOBAL_PROC, .proc/StartUpWarning, M, time), 30)

/datum/component/idle_warning/PostTransfer()
    return 0

/datum/component/idle_warning/proc/StartUpWarning(mob/M, time)
    to_chat(M, "<span class='warning'>Idle Warning component loaded in. Timer before sending an ahelp is set to [time] seconds. Clicking ingame and moving around will reset the timer.</span>")

/datum/component/idle_warning/proc/activity()
    var/cur_time = start_watch()
    if(cur_time < last_action_timer)
        var/mob/living/M = parent
        sendMorAhelp(M.client, "(Automated message from the idle_warning component): The user returned to the game", "Adminhelp")
    last_action_timer = cur_time // Reset the timer
    warning_given = FALSE

/datum/component/idle_warning/proc/life()
    var/mob/living/M = parent
    if(!istype(M))
        return
    if(M.stat == DEAD || !M.mind || M.player_ghosted || M.get_ghost(TRUE))
        last_action_timer = start_watch()
        return
    var/d = stop_watch(last_action_timer)
    if(d >= time)
        sendMorAhelp(M.client, "(Automated message from the idle_warning component): [ahelp_text]", "Adminhelp")
        last_action_timer = INFINITY // Only send once
    else if(!warning_given && d >= 0.8 * time)
        warning_given = TRUE
        to_chat(parent, "<span class='danger'>You've been AFK for [d] seconds. After [time] seconds the system will send an Ahelp. Please move or click somewhere on the screen</span>")
        parent << 'sound/effects/adminhelp.ogg'
        window_flash(M.client)

/datum/component/idle_warning/proc/transfer_mind(datum/mind/mind, mob/new_mob)
    UnregisterSignal(parent, list(COMSIG_CLICK, COMSIG_LIVING_LIFE, COMSIG_CLIENT_MOVE))
    RegisterSignal(new_mob, COMSIG_CLICK, .proc/activity)
    RegisterSignal(new_mob, COMSIG_LIVING_LIFE, .proc/life)
    RegisterSignal(new_mob, COMSIG_CLIENT_MOVE, .proc/activity)
    new_mob.TakeComponent(src)