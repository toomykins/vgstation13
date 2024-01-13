var/muteban_keylist[0]

/proc/muteban_isbanned(mob/M, var/param)
	var/found = muteban_keylist.Find("[M.ckey]")
	if(!found)
		return FALSE
	if(muteban_keylist["[M.ckey]"] & param)
		return TRUE
	return FALSE

/proc/mute_unban(mob/M,param)
	if(!M)
		return 0
	return muteban_keylist.Remove("[M.ckey]")

/proc/mute_ban(mob/M,param)
	if(!M)
		return 0
	return muteban_keylist.Add("[M.ckey]")

/proc/muteban_loadbanfile()
	if(!SSdbcore.Connect())
		world.log << "Database connection failed. Skipping mute-ban loading"
		diary << "Database connection failed. Skipping mute-ban loading"
		return


	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey, job FROM erro_ban WHERE (bantype = :mute_perma  OR (bantype = :mute_temp AND expiration_time > Now())) AND isnull(unbanned)",
		list(
			"mute_perma" = "mute_PERMABAN",
			"mute_temp" = "mute_TEMPBAN",
		))
	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
		qdel(query)
		return

	while(query.NextRow())
		var/ckey = query.item[1]
		if(!(ckey in muteban_keylist))
			muteban_keylist.Add("[ckey]")
		if(isnull(muteban_keylist["[ckey]"]))
			muteban_keylist["ckey"] = 0
		muteban_keylist["[ckey]"] |= text2num(query.item[2])
	qdel(query)
