var/datum/subsystem/ban/SSban

/datum/subsystem/ban
	name       = "Ban"
	init_order = SS_INIT_BAN
	flags      = SS_FIRE_IN_LOBBY


/datum/subsystem/ban/New()
	NEW_SS_GLOBAL(SSban)

/datum/subsystem/ban/Initialize(timeofday)
	ban_master = new /datum/controller/bans()
	ban_master.init()
	..()

/datum/subsystem/ban/fire(resumed = FALSE)
	ban_master.processQueue()