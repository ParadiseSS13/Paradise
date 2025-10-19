/proc/full_server_byond_build()
	var/build = world.byond_build
	while(build >= 1)
		build /= 10
	return world.byond_version + build

/proc/full_client_byond_build(client/my_client)
	var/build = my_client.byond_build
	while(build >= 1)
		build /= 10
	return my_client.byond_version + build
