
/datum/ban/proc/DBbancheck(ckey,ip,cid)
	if(!(ckey || ip || cid))
		return FALSE
	ckey = ckey(ckey)
	var/isparam = FALSE
	if( (!isnull(param)) && length(param) > 0 )
		isparam = TRUE
	var/sqltext = "SELECT * from erro_ban WHERE bantype = :bantype [isparam ? "AND param = :param" : ""] AND (ckey = :ckey [ip ? "OR ip = :ip" : ""]  [cid ? "OR computerid = :cid" : ""]) AND isnull(unbanned)"
	var/list/sqllist = list("bantype" = "[SQLname]", "param" = "[param]", "ckey" = "[ckey]")
	if(ip)
		sqllist += "ip"
		sqllist["ip"] = "[ip]"
	if(cid)
		sqllist += "computerid"
		sqllist["computerid"] = "[cid]"
	var/datum/DBQuery/query = SSdbcore.NewQuery(sqltext,sqllist)
	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
		qdel(query)
		return FALSE
	if(query.NextRow())
		return TRUE
	return FALSE

/proc/appearance_isbanned(ckey)

/proc/retardban_isbanned(ckey)

/proc/paxban_isbanned(ckey)

/proc/ban_isbanned(ckey,bantype,param)
	if(ismob(ckey))
		ckey=ckey(ckey)
	if(!ban_master)
		log_admin("[ckey] activated a ban check, but ban_master wasn't loaded!")
		return FALSE
	var/bantoget = ban_master.getbanfrombancache(ckey,bantype,param)
	if(bantoget)
		return TRUE
	return FALSE

/proc/jobban_isbanned(ckey,job)
	if(!(ckey && job))
		return FALSE
	if(!ban_master || !job_master)
		return
	if(istext(job))
		job = job_master.GetJob(job)
	if(!job || istype(job,/datum/job))
		return FALSE

	return ban_isbanned(ckey,/datum/ban/job,job)


/proc/roleban_isbanned(ckey,role)
	role = GetRoleFromID(role)
	if(!role || istype(role,/datum/role))
		return FALSE
	if(!ban_master)
		log_admin("[ckey] activated a role check, but ban_master wasn't loaded!")
		return FALSE
	var/bantoget = ban_master.getbanfrombancache(ckey,/datum/ban/role,role)
	if(bantoget)
		return TRUE
	return FALSE

/proc/oocban_isbanned(ckey)
	if(!ban_master)
		log_admin("[ckey] activated a role check, but ban_master wasn't loaded!")
		return FALSE
	var/bantoget = ban_master.getbanfrombancache(ckey,/datum/ban/mute/ooc)
	if(bantoget)
		return TRUE
	return FALSE


/world/IsBanned(key, address, computer_id, goonchat=FALSE)
	bancheckqueue += key
	var/real_login = !goonchat //cookie checks

	log_access("IsBanned: Checking [ckey(key)], [address], CID[computer_id] [goonchat?"(in cookies)":""]")
	if(real_login) //not a cookie check?
		if(!key || !address || !computer_id)
			log_access("Failed Login (invalid data): [key] [address]-[computer_id]")
			return list("reason" = "invalid login data", "desc" = "Your computer provided invalid or blank information to the server on connection (byond username, IP, and Computer ID.) Provided information for reference: Username: '[key]' IP: '[address]' Computer ID: '[computer_id]', If you continue to get this error, please restart byond or contact byond support.")
		if(computer_id == 2147483647) //this cid causes stickybans to go haywire
			log_access("Failed Login (invalid cid): [key] [address]-[computer_id]")
			return list("reason"="invalid login data", "desc"="Error: Could not check ban status, Please try again. Error message: Your computer provided an invalid Computer ID.)")

		//Guest Checking
		if(!guests_allowed && IsGuestKey(key))
			log_access("Failed Login: [key] - Guests not allowed")
			message_admins("<span class='notice'>Failed Login: [key] - Guests not allowed</span>")
			return list("reason"="guest", "desc"="\nReason: Guests not allowed. Please sign in with a byond account.")


	var/ckeytext = ckey(key)

	if(!SSdbcore.Connect())
		world.log << "Ban database connection failure. Key [ckeytext] not checked"
		diary << "Ban database connection failure. Key [ckeytext] not checked"
		return

	var/failedcid = 1
	var/failedip = 1

	if(address)
		failedip = 0

	if(computer_id)
		failedcid = 0

	var/sqltext = "SELECT ckey, ip, computerid, a_ckey, reason, expiration_time, duration, bantime, bantype FROM erro_ban WHERE "
	var/sqllist = list(
			"ckey" = "[ckeytext]",
			"address" = "[address]",
			"computer_id" = "[computer_id]"
	)
	for(var/datum/ban/bantype in subtypesof(/datum/ban) - /datum/ban)
		if(bantype.block)
			sqltext += "bantype = :[bantype.SQLname] AND "
			sqllist["[bantype.SQLname]"] = bantype.SQLname
	sqltext += "(ckey = :ckey [address ? "OR ip = :address" : ""]  [computer_id ? "OR computerid = :computer_id" : ""]) AND isnull(unbanned)"

	var/datum/DBQuery/query = SSdbcore.NewQuery(sqltext,sqllist)

	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
		qdel(query)
		return
	while(query.NextRow())
		var/pckey = query.item[1]
			//var/pip = query.item[2]
			//var/pcid = query.item[3]
		var/ackey = query.item[4]
		var/reason = query.item[5]
		var/expiration = query.item[6]
		var/duration = query.item[7]
		var/bantime = query.item[8]
		var/bantype = query.item[9]
		var/desc = ""
		var/expires = ""
		if(text2num(duration) > 0)
			expires = "The ban is for [duration] minutes and expires on [expiration] (server time)."
		else
			expires = "NEVER"
		if(config.banappeals)
			desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban was applied by [ackey] on [bantime] \nBan type: [bantype] \nExpires: [expires] \nFor more information on your ban, or to appeal, head to [config.banappeals]"
		else
			desc = "\nReason: You, or another user of this computer or connection ([pckey]) is banned from playing here. The ban reason is:\n[reason]\nThis ban was applied by [ackey] on [bantime] \nBan type: [bantype] \nExpires: [expires]"
		log_access("Failed Login: [key] [computer_id] [address] - Banned [desc]")
		qdel(query)
		return list("reason"="[bantype]", "desc"="[desc]")
		//return "[bantype][desc]"
	qdel(query)
	if(failedcid && real_login)
		message_admins("[key] has logged in with a blank computer id in the ban check.")
	if(failedip && real_login)
		message_admins("[key] has logged in with a blank ip in the ban check.")
	//sticky ban logging
	. = ..()
	var/list/what = .
	if(istype(what,/list))
		message_admins("Attempted stickyban login key: [what["keys"]] IP: [what["IP"]] CID: [what["computer_id"]] Admin: [what["admin"]]")
		log_access("Attempted stickyban login key: [what["keys"]] IP: [what["IP"]] CID: [what["computer_id"]] Admin: [what["admin"]]")
		var/desc
		if(config.banappeals)
			desc = "\nReason: You, or another user of this computer or connection ([ckey(key)]) is banned from playing here. The ban reason is:\n[what["message"]]\nThis ban was applied by [what["admin"]]\nBan type: PERMABAN \nExpires: NEVER \nFor more information on your ban, or to appeal, head to [config.banappeals]"
		else
			desc = "\nReason: You, or another user of this computer or connection ([ckey(key)]) is banned from playing here. The ban reason is:\n[what["message"]]\nThis ban was applied by [what["admin"]]\nBan type: PERMABAN \nExpires: NEVER"
			what.Remove("message")
			what["desc"] = "[desc]"
			what["reason"] = "PERMABAN"
	return .	//default pager ban stuff
