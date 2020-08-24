//#define VOX_SHUTTLE_COOLDOWN 460
//#define VOX_SHUTTLE_TRANSIT_DELAY 260

var/global/datum/shuttle/discount/discount_shuttle = new(starting_area=/area/shuttle/discount/station)

/datum/shuttle/discount
	name = "Discount Shuttle"

	cant_leave_zlevel = list()

	cooldown = 460

	transit_delay = 260 - 30 //Once somebody sends the shuttle, it waits for 3 seconds before leaving. Transit delay is reduced to compensate for that
	pre_flight_delay = 30

	stable = 0
	can_rotate = 1

/datum/shuttle/discount/is_special()
	return 1

/datum/shuttle/discount/initialize() //uses vox heist destinations because why add new ones to every map
	.=..() // adjust all the docking ports
	add_dock(/obj/docking_port/destination/discount/station) // add base of operations

	add_dock(/obj/docking_port/destination/vox/north_station) // all z1 down
	add_dock(/obj/docking_port/destination/vox/east_station)
	add_dock(/obj/docking_port/destination/vox/south_station)
	add_dock(/obj/docking_port/destination/vox/west_station)
	add_dock(/obj/docking_port/destination/vox/northeast_station)
	add_dock(/obj/docking_port/destination/vox/northwest_station)
	add_dock(/obj/docking_port/destination/vox/southeast_station)
	add_dock(/obj/docking_port/destination/vox/southwest_station)
	add_dock(/obj/docking_port/destination/vox/deepspace) //z6 middle of nowhere so vox can hide

	set_transit_dock(/obj/docking_port/destination/discount/transit)


/obj/machinery/computer/shuttle_control/discount
	allow_silicons = 0
	machine_flags = EMAGGABLE //No screwtoggle because this computer can't be built

/obj/machinery/computer/shuttle_control/discount/New() //Main shuttle_control code is in code/game/machinery/computer/shuttle_computer.dm
	link_to(discount_shuttle)
	.=..()


/obj/docking_port/destination/discount/station // ends the round
	areaname = "Discount Dan Operations Outpost"

/obj/docking_port/destination/discount/transit
	areaname = "hyperspace (discount shuttle)"