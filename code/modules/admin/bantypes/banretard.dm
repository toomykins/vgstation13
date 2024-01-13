var/retardban_keylist[0]

/proc/retardban_isbanned(mob/M, var/param)
	var/found = retardban_keylist.Find("[M.ckey]")
	if(!found):
		return FALSE
	if(retardban_keylist["[M.ckey]"] & param)
		return TRUE
	return FALSE

/proc/retard_unban(mob/M)
	if(!M)
		return 0
	return retardban_keylist.Remove("[M.ckey]")

/proc/retard_ban(mob/M)
	if(!M)
		return 0
	return retardban_keylist.Add("[M.ckey]")

/proc/retardban_loadbanfile()
	if(!SSdbcore.Connect())
		world.log << "Database connection failed. Skipping retard ban loading"
		diary << "Database connection failed. Skipping retard ban loading"
		return


	var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT ckey, param FROM erro_ban WHERE (bantype = :retard_perma  OR (bantype = :retard_temp AND expiration_time > Now())) AND isnull(unbanned)",
		list(
			"retard_perma" = "retard_PERMABAN",
			"retard_temp" = "retard_TEMPBAN",
		))
	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
		qdel(query)
		return

	while(query.NextRow())
		var/ckey = query.item[1]
		if(!(ckey in retardban_keylist)):
			retardban_keylist.Add("[ckey]")
		if(isnull(retardban_keylist["[ckey]"]))
			retardban_keylist["ckey"] = 0
		retardban_keylist["[ckey]"] |= text2num(query.item[2])
	qdel(query)
