/datum/event/unlink_from_centcom
	endWhen = 300

/datum/event/unlink_from_centcom/can_start()
	return 10

/datum/event/unlink_from_centcom/start()
	unlink_from_centcom()

/datum/event/unlink_from_centcom/end()
	link_to_centcom()

proc/link_to_centcom()
	if(!map.linked_to_centcom)
		map.linked_to_centcom = 1
		command_alert(/datum/command_alert/command_link_restored)

proc/unlink_from_centcom()
	if(map.linked_to_centcom)
		command_alert(/datum/command_alert/command_link_lost)
		map.linked_to_centcom = 0