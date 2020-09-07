//Refer to game/centcom_orders.dm

/datum/event/centcom_order

/datum/event/centcom_order/can_start()
	return 25

/datum/event/centcom_order/start()
	create_random_order()