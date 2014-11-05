datum/directive/vox_heist
  var/list/vox = list()
  var/list/sympathizers = list()

  proc/get_vox_candidates()
    var/list/candidates[0]
    for(var/mob/M in player_list)
      if(M.is_ready() && is_vox(M))
        candidates.Add(M)
    return candidates

  proc/get_sympathizer_candidates()
    var/list/candidates[0]
    for(var/mob/M in player_list)
      if(M.is_ready() && !is_vox(M) && !M.is_mechanical() && M.mind.assigned_role != "Captain")
        candidates[M] = get_weight(M)
    return candidates

  proc/is_vox(mob/M)
    return M.get_species() == "Vox"

  proc/get_weight(mob/M)
    // You will have a high chance of being regarded as a vox sympathizer if your
    // relationship with NanoTrasen is negative. Otherwise, command and security
    // staff are pretty well trusted and maltreated alien races are easy suspects.
    var/relation = M.client.prefs.nanotrasen_relation
    if(relation == "Opposed")
      return 8
    if(relation == "Skeptical")
      return 5
    if(command_positions.Find(M.mind.assigned_role))
      return 1
    var/species = M.get_species()
    if(species == "Tajaran" || species == "Unathi")
      return 5
    if(security_positions.Find(M.mind.assigned_role))
      return 2
    return 3

datum/directive/vox_heist/get_description()
  return {"
    <p>
      A vox warship has commandeered a NanoTrasen transport carrying 2,500 cubic meters of liquid plasma.
      The raiders are willing to return the stolen cargo in exchange for the capture or execution of so-called "vox pariah" that are stationed aboard [station_name()].
      If the transport is not recovered, the estimated loss of profits is a threat to the solvency of the company.
      Predictive analysis has identified certain members of the crew as sympathetic to the vox pariah. Detain the sympathizers to guarantee a successful exchange.
      Lethal force is authorized by the High Command Department of Security. Further information is classified.
    </p>
  "}

datum/directive/vox_heist/initialize()
  var/list/vox_candidates = get_vox_candidates()
  for(var/mob/pariah in vox_candidates)
    vox.Add(pariah.mind)

  special_orders = list(
    "Brig or kill all Vox Pariah.")

  var/list/sympathizer_candidates = get_sympathizer_candidates()
  var/list/sympathizer_names = list()
  var/sympathizer_count = min(rand(2,4), sympathizer_candidates.len)
  for(var/i=0, i < sympathizer_count, i++)
    if(!sympathizer_candidates.len)
      break

    var/mob/candidate = pickweight(sympathizer_candidates)
    sympathizer_candidates.Remove(candidate)
    sympathizers.Add(candidate.mind)
    sympathizer_names.Add("[candidate.mind.assigned_role] [candidate.mind.name]")

  if(sympathizers.len)
    special_orders.Add("Brig the following sympathizers: [list2text(sympathizer_names, ", ")]")

datum/directive/vox_heist/meets_prerequisites()
  var/list/candidates = get_vox_candidates()
  return candidates.len >= 2

datum/directive/vox_heist/directives_complete()
  if(!vox.len && !sympathizers.len)
    return 1

  for(var/datum/mind/pariah in vox)
    if(!pariah.current.is_in_brig())
      return 0

  for(var/datum/mind/sympathizer in sympathizers)
    if(!sympathizer.current.is_in_brig())
      return 0

  return 1

datum/directive/vox_heist/get_remaining_orders()
  var/text = ""
  for(var/datum/mind/pariah in vox)
    if(!pariah.current.is_in_brig())
      text += "<li>Brig or Kill [pariah]</li>"
  for(var/datum/mind/sympathizer in sympathizers)
    if(!sympathizer.current.is_in_brig())
      text += "<li>Brig [sympathizer]</li>"
  return text

/hook/death/proc/vox_or_sympathizer_killed(mob/living/carbon/human/deceased, gibbed)
  var/datum/directive/vox_heist/D = get_directive("vox_heist")
  if(!D) return 1

  var/datum/mind/M = deceased.mind
  if(M in D.vox)
    D.vox.Remove(M)
  if(M in D.sympathizers)
    D.sympathizers.Remove(M)
  return 1
