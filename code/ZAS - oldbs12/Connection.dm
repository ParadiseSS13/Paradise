/*
This object is contained within zone/var/connections. It's generated whenever two turfs from different zones are linked.
Indirect connections will not merge the two zones after they reach equilibrium.
*/
#define CONNECTION_DIRECT   2
#define CONNECTION_INDIRECT 1
#define CONNECTION_CLOSED   0

/connection
	var/turf/simulated/A
	var/turf/simulated/B

	var/zone/zone_A
	var/zone/zone_B

	var/indirect = CONNECTION_DIRECT //If the connection is purely indirect, the zones should not join.


/connection/New(turf/T,turf/O)
	. = ..()

	A = T
	B = O

	if(A.zone && B.zone)
		if(!A.zone.connections)
			A.zone.connections = list()
		A.zone.connections += src
		zone_A = A.zone

		if(!B.zone.connections)
			B.zone.connections = list()
		B.zone.connections += src
		zone_B = B.zone

		if(A in air_master.turfs_with_connections)
			var/list/connections = air_master.turfs_with_connections[A]
			connections.Add(src)
		else
			air_master.turfs_with_connections[A] = list(src)

		if(B in air_master.turfs_with_connections)
			var/list/connections = air_master.turfs_with_connections[B]
			connections.Add(src)
		else
			air_master.turfs_with_connections[B] = list(src)

		if(A.CanPass(null, B, 0, 0))

			if(!A.CanPass(null, B, 1.5, 1))
				indirect = CONNECTION_INDIRECT

			ConnectZones(A.zone, B.zone, indirect)

		else
			ConnectZones(A.zone, B.zone)
			indirect = CONNECTION_CLOSED

	else
		world.log << "Attempted to create connection object for non-zone tiles: [T] ([T.x],[T.y],[T.z]) -> [O] ([O.x],[O.y],[O.z])"
		SoftDelete()


/connection/Del()
	//remove connections from master lists.
	if(B in air_master.turfs_with_connections)
		var/list/connections = air_master.turfs_with_connections[B]
		connections.Remove(src)

	if(A in air_master.turfs_with_connections)
		var/list/connections = air_master.turfs_with_connections[A]
		connections.Remove(src)

	//Remove connection from zones.
	if(A)
		if(A.zone && A.zone.connections)
			A.zone.connections.Remove(src)
			if(!A.zone.connections.len)
				A.zone.connections = null

	if(istype(zone_A) && (!A || A.zone != zone_A))
		if(zone_A.connections)
			zone_A.connections.Remove(src)
			if(!zone_A.connections.len)
				zone_A.connections = null

	if(B)
		if(B.zone && B.zone.connections)
			B.zone.connections.Remove(src)
			if(!B.zone.connections.len)
				B.zone.connections = null

	if(istype(zone_B) && (!B || B.zone != zone_B))
		if(zone_B.connections)
			zone_B.connections.Remove(src)
			if(!zone_B.connections.len)
				zone_B.connections = null

	//Disconnect zones while handling unusual conditions.
	//	e.g. loss of a zone on a turf
	DisconnectZones(zone_A, zone_B)

	//Finally, preform actual deletion.
	. = ..()


/connection/proc/SoftDelete()
	//remove connections from master lists.
	if(B in air_master.turfs_with_connections)
		var/list/connections = air_master.turfs_with_connections[B]
		connections.Remove(src)

	if(A in air_master.turfs_with_connections)
		var/list/connections = air_master.turfs_with_connections[A]
		connections.Remove(src)

	//Remove connection from zones.
	if(A)
		if(A.zone && A.zone.connections)
			A.zone.connections.Remove(src)
			if(!A.zone.connections.len)
				A.zone.connections = null

	if(istype(zone_A) && (!A || A.zone != zone_A))
		if(zone_A.connections)
			zone_A.connections.Remove(src)
			if(!zone_A.connections.len)
				zone_A.connections = null

	if(B)
		if(B.zone && B.zone.connections)
			B.zone.connections.Remove(src)
			if(!B.zone.connections.len)
				B.zone.connections = null

	if(istype(zone_B) && (!B || B.zone != zone_B))
		if(zone_B.connections)
			zone_B.connections.Remove(src)
			if(!zone_B.connections.len)
				zone_B.connections = null

	//Disconnect zones while handling unusual conditions.
	//	e.g. loss of a zone on a turf
	DisconnectZones(zone_A, zone_B)


/connection/proc/ConnectZones(var/zone/zone_1, var/zone/zone_2, open = 0)

	//Sanity checking
	if(!istype(zone_1) || !istype(zone_2))
		return

	//Handle zones connecting indirectly/directly.
	if(open)

		//Create the lists if necessary.
		if(!zone_1.connected_zones)
			zone_1.connected_zones = list()

		if(!zone_2.connected_zones)
			zone_2.connected_zones = list()

		//Increase the number of connections between zones.
		if(zone_2 in zone_1.connected_zones)
			zone_1.connected_zones[zone_2]++
		else
			zone_1.connected_zones += zone_2
			zone_1.connected_zones[zone_2] = 1

		if(zone_1 in zone_2.connected_zones)
			zone_2.connected_zones[zone_1]++
		else
			zone_2.connected_zones += zone_1
			zone_2.connected_zones[zone_1] = 1

		if(open == CONNECTION_DIRECT)
			if(!zone_1.direct_connections)
				zone_1.direct_connections = list(src)
			else
				zone_1.direct_connections += src

			if(!zone_2.direct_connections)
				zone_2.direct_connections = list(src)
			else
				zone_2.direct_connections += src


	//Handle closed connections.
	else

		//Create the lists
		if(!zone_1.closed_connection_zones)
			zone_1.closed_connection_zones = list()

		if(!zone_2.closed_connection_zones)
			zone_2.closed_connection_zones = list()

		//Increment the connections.
		if(zone_2 in zone_1.closed_connection_zones)
			zone_1.closed_connection_zones[zone_2]++
		else
			zone_1.closed_connection_zones += zone_2
			zone_1.closed_connection_zones[zone_2] = 1

		if(zone_1 in zone_2.closed_connection_zones)
			zone_2.closed_connection_zones[zone_1]++
		else
			zone_2.closed_connection_zones += zone_1
			zone_2.closed_connection_zones[zone_1] = 1

	if(zone_1.status == ZONE_SLEEPING)
		zone_1.SetStatus(ZONE_ACTIVE)

	if(zone_2.status == ZONE_SLEEPING)
		zone_2.SetStatus(ZONE_ACTIVE)

/connection/proc/DisconnectZones(var/zone/zone_1, var/zone/zone_2)
	//Sanity checking
	if(!istype(zone_1) || !istype(zone_2))
		return

	if(indirect != CONNECTION_CLOSED)
		//Handle disconnection of indirectly or directly connected zones.
		if( (zone_1 in zone_2.connected_zones) || (zone_2 in zone_1.connected_zones) )

			//If there are more than one connection, decrement the number of connections
			//Otherwise, remove all connections between the zones.
			if(zone_2 in zone_1.connected_zones)
				if(zone_1.connected_zones[zone_2] > 1)
					zone_1.connected_zones[zone_2]--
				else
					zone_1.connected_zones -= zone_2
					//remove the list if it is empty
					if(!zone_1.connected_zones.len)
						zone_1.connected_zones = null

			//Then do the same for the other zone.
			if(zone_1 in zone_2.connected_zones)
				if(zone_2.connected_zones[zone_1] > 1)
					zone_2.connected_zones[zone_1]--
				else
					zone_2.connected_zones -= zone_1
					if(!zone_2.connected_zones.len)
						zone_2.connected_zones = null

			if(indirect == CONNECTION_DIRECT)
				zone_1.direct_connections -= src
				if(!zone_1.direct_connections.len)
					zone_1.direct_connections = null

				zone_2.direct_connections -= src
				if(!zone_2.direct_connections.len)
					zone_2.direct_connections = null

	else
		//Handle disconnection of closed zones.
		if( (zone_1 in zone_2.closed_connection_zones) || (zone_2 in zone_1.closed_connection_zones) )

			//If there are more than one connection, decrement the number of connections
			//Otherwise, remove all connections between the zones.
			if(zone_2 in zone_1.closed_connection_zones)
				if(zone_1.closed_connection_zones[zone_2] > 1)
					zone_1.closed_connection_zones[zone_2]--
				else
					zone_1.closed_connection_zones -= zone_2
					//remove the list if it is empty
					if(!zone_1.closed_connection_zones.len)
						zone_1.closed_connection_zones = null

			//Then do the same for the other zone.
			if(zone_1 in zone_2.closed_connection_zones)
				if(zone_2.closed_connection_zones[zone_1] > 1)
					zone_2.closed_connection_zones[zone_1]--
				else
					zone_2.closed_connection_zones -= zone_1
					if(!zone_2.closed_connection_zones.len)
						zone_2.closed_connection_zones = null


/connection/proc/Cleanup()

	//Check sanity: existance of turfs
	if(!A || !B)
		SoftDelete()
		return

	//Check sanity: loss of zone
	if(!A.zone || !B.zone)
		SoftDelete()
		return

	//Check sanity: zones are different
	if(A.zone == B.zone)
		SoftDelete()
		return

	//Handle zones changing on a turf.
	if((A.zone && A.zone != zone_A) || (B.zone && B.zone != zone_B))
		Sanitize()

	if(A.zone && B.zone)

		//If no walls are blocking us...
		if(A.ZAirPass(B))
			//...we check to see if there is a door in the way...
			var/door_pass = A.CanPass(null,B,1.5,1)
			//...and if it is opened.
			if(door_pass || A.CanPass(null,B,0,0))

				//Make and remove connections to let air pass.
				if(indirect == CONNECTION_CLOSED)
					DisconnectZones(A.zone, B.zone)
					ConnectZones(A.zone, B.zone, door_pass + 1)

				if(door_pass)
					indirect = CONNECTION_DIRECT
				else if(!door_pass)
					indirect = CONNECTION_INDIRECT

			//The door is instead closed.
			else if(indirect > CONNECTION_CLOSED)
				DisconnectZones(A.zone, B.zone)
				indirect = CONNECTION_CLOSED
				ConnectZones(A.zone, B.zone)

		//If I can no longer pass air, better delete
		else
			SoftDelete()
			return

/connection/proc/Sanitize()
	//If the zones change on connected turfs, update it.

	//Both zones changed (wat)
	if(A.zone && A.zone != zone_A && B.zone && B.zone != zone_B)

		//If the zones have gotten swapped
		//	(do not ask me how, I am just being anal retentive about sanity)
		if(A.zone == zone_B && B.zone == zone_A)
			var/turf/temp = B
			B = A
			A = temp
			zone_B = B.zone
			zone_A = A.zone
			return

		//Handle removal of connections from archived zones.
		if(zone_A && zone_A.connections)
			zone_A.connections.Remove(src)
			if(!zone_A.connections.len)
				zone_A.connections = null

		if(zone_B && zone_B.connections)
			zone_B.connections.Remove(src)
			if(!zone_B.connections.len)
				zone_B.connections = null

		if(A.zone)
			if(!A.zone.connections)
				A.zone.connections = list()
			A.zone.connections |= src

		if(B.zone)
			if(!B.zone.connections)
				B.zone.connections = list()
			B.zone.connections |= src

		//If either zone is null, we disconnect the archived ones after cleaning up the connections.
		if(!A.zone || !B.zone)
			if(zone_A && zone_B)
				DisconnectZones(zone_B, zone_A)

			if(!A.zone)
				zone_A = A.zone

			if(!B.zone)
				zone_B = B.zone
			return

		//Handle diconnection and reconnection of zones.
		if(zone_A && zone_B)
			DisconnectZones(zone_A, zone_B)
		ConnectZones(A.zone, B.zone, indirect)

		//resetting values of archived values.
		zone_B = B.zone
		zone_A = A.zone

	//The "A" zone changed.
	else if(A.zone && A.zone != zone_A)

		//Handle connection cleanup
		if(zone_A)
			if(zone_A.connections)
				zone_A.connections.Remove(src)
				if(!zone_A.connections.len)
					zone_A.connections = null

		if(A.zone)
			if(!A.zone.connections)
				A.zone.connections = list()
			A.zone.connections |= src

		//If the "A" zone is null, we disconnect the archived ones after cleaning up the connections.
		if(!A.zone)
			if(zone_A && zone_B)
				DisconnectZones(zone_A, zone_B)
			zone_A = A.zone
			return

		//Handle diconnection and reconnection of zones.
		if(zone_A && zone_B)
			DisconnectZones(zone_A, zone_B)
		ConnectZones(A.zone, B.zone, indirect)
		zone_A = A.zone

	//The "B" zone changed.
	else if(B.zone && B.zone != zone_B)

		//Handle connection cleanup
		if(zone_B)
			if(zone_B.connections)
				zone_B.connections.Remove(src)
				if(!zone_B.connections.len)
					zone_B.connections = null

		if(B.zone)
			if(!B.zone.connections)
				B.zone.connections = list()
			B.zone.connections |= src

		//If the "B" zone is null, we disconnect the archived ones after cleaning up the connections.
		if(!B.zone)
			if(zone_A && zone_B)
				DisconnectZones(zone_A, zone_B)
			zone_B = B.zone
			return

		//Handle diconnection and reconnection of zones.
		if(zone_A && zone_B)
			DisconnectZones(zone_A, zone_B)
		ConnectZones(A.zone, B.zone, indirect)
		zone_B = B.zone


#undef CONNECTION_DIRECT
#undef CONNECTION_INDIRECT
#undef CONNECTION_CLOSED
