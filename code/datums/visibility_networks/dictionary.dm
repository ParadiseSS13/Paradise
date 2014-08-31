var/datum/visibility_network/cameras/cameranet = new()
var/datum/visibility_network/cult/cultNetwork = new()
var/datum/visibility_network/list/visibility_networks = list("ALL_CAMERAS"=cameranet, "CULT" = cultNetwork)


// used by turfs and objects to update all visibility networks
/proc/updateVisibilityNetworks(atom/A, var/opacity_check = 1)
	var/datum/visibility_network/currentNetwork
	for (var/networkName in visibility_networks)
		currentNetwork = visibility_networks[networkName]
		currentNetwork.updateVisibility(A, opacity_check)