/datum/game_mode/mutiny/proc/check_antagonists_ui(admins)
  var/turf/captains_key_loc = captains_key ? captains_key.get_loc_turf() : "Lost or Destroyed"
  var/turf/secondary_key_loc = secondary_key ? secondary_key.get_loc_turf() : "Lost or Destroyed"
  var/remaining_objectives = current_directive.get_remaining_orders()
  var/txt = {"
    <h5>Context:</h5>
    <p>
      [current_directive.get_description()]
    </p>
    <h5>Orders:</h5>
    <ol>
      [fluff.get_orders()]
    </ol>
    <br>
    <h5>Remaining Objectives</h5>
    <ol>
      [remaining_objectives ? remaining_objectives : "<li>None</li>"]
    </ol>
    <br>
    <h5>Authentication:</h5>
    <b>Captain's Key:</b> [captains_key_loc]
    <a href='?src=\ref[admins];choice=activate_captains_key'>Activate</a><br>
    <b>Secondary Key:</b> [secondary_key_loc]
    <a href='?src=\ref[admins];choice=activate_secondary_key'>Activate</a><br>
    <b>EAD: [ead ? ead.get_status() : "Lost or Destroyed"]</b>
    <a href='?src=\ref[admins];choice=activate_ead'>Activate</a><br>
    <hr>
  "}

  txt += "<a href='?src=\ref[admins];choice=reassign_head_loyalist'>Reassign Head Loyalist</a><br>"
  if(head_loyalist)
    txt += check_role_table("Head Loyalist", list(head_loyalist), admins, 0)

  var/list/loyal_crew = loyalists - head_loyalist
  if(loyal_crew.len)
    txt += check_role_table("Loyalists", loyal_crew, admins, 0)

  txt += "<a href='?src=\ref[admins];choice=reassign_head_mutineer'>Reassign Head Mutineer</a><br>"
  if(head_mutineer)
    txt += check_role_table("Head Mutineer", list(head_mutineer), admins, 0)

  var/list/mutiny_crew = mutineers - head_mutineer
  if(mutiny_crew.len)
    txt += check_role_table("Mutineers", mutiny_crew, admins, 0)

  if(body_count.len)
    txt += check_role_table("Casualties", body_count, admins, 0)

  return txt

/datum/game_mode/mutiny/check_antagonists_topic(href, href_list[])
  switch(href_list["choice"])
    if("activate_captains_key")
      ead.captains_key = 1
      return 1
    if("activate_secondary_key")
      ead.secondary_key = 1
      return 1
    if("activate_ead")
      ead.activated = 1
      return 1
    if("reassign_head_loyalist")
      var/mob/M = get_reassignment_candidate("Loyalist")
      if(M)
        head_loyalist = M.mind
        equip_head_loyalist()
      return 1
    if("reassign_head_mutineer")
      var/mob/M = get_reassignment_candidate("Mutineer")
      if(M)
        head_mutineer = M.mind
        equip_head_mutineer()
      return 1
    else
      return 0

/datum/game_mode/mutiny/proc/get_reassignment_candidate(faction)
  var/list/targets[0]
  for(var/mob/living/carbon/human/H in player_list)
    if(H.is_ready() && !H.is_dead())
      targets.Add(H)

  return input("Select a player to lead the [faction] faction.", "Head [faction] reassignment", null) as mob in targets
