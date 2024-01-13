



/datum/ban
	var/title = "Unspecified"
	var/SQLname = "UNSPECIFIED"
	var/verbtext = "Unspecified"
	var/block = FALSE // will disallow access (if banevading)
	var/param = ""

/datum/ban/proc/convertfromDB(param)
	return param

/datum/ban/proc/converttoDB(param)
	return param

/datum/ban/proc/gen()
	return list(src)

/datum/ban/ban
	title = "ban"
	verbtext = "banned"
	SQLname = "BAN"
	block = TRUE


/datum/ban/job
	title = "job-ban"
	verbtext = "job-banned"
	SQLname = "JOBBAN"

/datum/ban/job/convertfromDB(param)
	return text2path(param)

/datum/ban/job/converttoDB(param)
	return "[param]"

/datum/ban/job/gen()
	var/list/retlist = list()
	for(var/datum/job/jobthing in get_job_datums() - /datum/job)
		if(jobthing.title == "NOPE")
			continue
		var/datum/ban/job/proto = new
		proto.title = "[jobthing.title] [proto.title]"
		proto.param = "[jobthing]"
		proto.verbtext = "[proto.verbtext] from [jobthing.title]"
		retlist += proto
	return retlist

/datum/ban/role
	title = "role-ban"
	verbtext = "role-banned"
	SQLname = "ROLEBAN"

/datum/ban/role/convertfromDB(param)
	return text2path(param)

/datum/ban/role/converttoDB(param)
	return "[param]"

/datum/ban/role/gen()
	var/list/retlist = list()
	for(var/role in subtypesof(/datum/role))
		var/datum/role/rolething = role
		var/datum/ban/role/proto = new
		proto.title = "[initial(rolething.name)] [proto.title]"
		proto.param = "[initial(rolething.name)]"
		proto.verbtext = "[proto.verbtext] from [initial(rolething.name)]"
		retlist += proto
	return retlist

/datum/ban/mute
	title = "mute-ban"
	verbtext = "banned from chatting"
	SQLname = "MUTE"

/datum/ban/mute/ooc
	title = "OOC mute-ban"
	verbtext = "banned from OOC chat"
	param = "OOC"

/datum/ban/mute/deadchat
	title = "deadchat mute-ban"
	verbtext = "banned from deadchat"
	param = "DEADCHAT"

/datum/ban/mute/looc
	title = "LOOC mute-ban"
	verbtext = "banned from LOOC chat"
	param = "LOOC"

/datum/ban/mute/say
	title = "IC Say mute-ban"
	verbtext = "banned from IC chat"
	param = "SAY"

/datum/ban/mute/emote
	title = "IC Emote mute-ban"
	verbtext = "banned from emoting."
	param = "EMOTE"

/datum/ban/retard
	title = "retard-ban"
	verbtext = "retard-banned"
	SQLname = "RETARD"

/datum/ban/retard/braindamage
	title = "brain damage retard-ban"
	verbtext = "braindamaged as part of a retard-ban"
	param = "BRAINDAMAGE"

/datum/ban/retard/fat
	title = "fat retard-ban"
	verbtext = "fattened as part of a retard-ban"
	param = "FAT"

/datum/ban/retard/seizure
	title = "seizure retard-ban"
	verbtext = "subjected to seizures as part of a retard-ban"
	param = "SEIZURE"

/datum/ban/retard/lisp
	title = "lisp retard-ban"
	verbtext = "turned into lithping thaggot ath pawt oth a wetawd-ban"
	param = "LISP"

/datum/ban/appearance
	title = "appearance-ban"
	verbtext = "appearance-banned"
	SQLname = "APPEARANCE"

/datum/ban/cluwne
	title = "cluwne-ban"
	verbtext = "CLUWNED"
	SQLname = "CLUWNE"

/datum/ban/spectate
	title = "spectate-ban"
	verbtext = "banned from spectating"
	SQLname = "SPECTATE"

/datum/ban/spectate/station
	title = "station spectate-ban"
	verbtext = "banned from spectating the station"
	param = "STATION"

/datum/ban/spectate/asteroid
	title = "asteroid spectate-ban"
	verbtext = "banned from spectating the asteroid"
	param = "ASTEROID"

/datum/ban/spectate/derelict
	title = "derelict-only spectate-ban"
	verbtext = "banned from spectating anything other than the derelict Z-level"
	param = "DERELICT"

/datum/ban/spectate/blind
	title = "blind spectate-ban"
	verbtext = "blinded from spectating"
	param = "BLIND"