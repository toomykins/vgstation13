/proc/updatetempbans()
	var/sqltext = "UPDATE erro_ban SET unbanned = 1, unbanned_datetime = Now() WHERE duration != -1 AND isnull(unbanned) AND expiration_time < Now()"
	var/datum/DBQuery/query = SSdbcore.NewQuery(sqltext,list())
	if(!query.Execute())
		message_admins("Error: [query.ErrorMsg()]")
		log_sql("Error: [query.ErrorMsg()]")
		world.log << "Could not update temporary bans."
		diary << "Could not update temporary bans."
	qdel(query)



/proc/BanvaderAlert(var/ckey,var/list/found) // called by goonchat cookie checker
	if(!ckey || !found)
		return
	if(ckey == found["ckey"])
		return
	message_admins("<span class='danger big'>[ckey] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])</span>")
	log_admin("[ckey] has a cookie from a banned account! (Matched: [found["ckey"]], [found["ip"]], [found["compid"]])")
	var/admins_number = admins.len
	var/admin_number_afk = get_afk_admins()
	var/available_admins = admins_number - admin_number_afk
	//Probably not a good idea to print IP and CID in these channels
	send2adminirc("[ckey] has a cookie from a banned account! (Matched: [found["ckey"]]) [available_admins ? "" : "No non-AFK admins online"]")
	send2admindiscord("**[ckey] has a cookie from a banned account! (Matched: [found["ckey"]]) [available_admins ? "" : "No non-AFK admins online"]**", !available_admins)


///proc/jobban_ban(ckey)


//proc/customBan(bantime,serverip,bantype,reason,param,duration,rounds,)
///datum/admins/proc/DB_ban_record(var/bantype, var/mob/banned_mob, var/duration = -1, var/reason, var/job = "", var/rounds = 0, var/banckey = null)
//	if(!check_rights(R_BAN))
//		return
//	customBan(bantype, banned_mob, duration,reason, job, rounds, banckey)

/proc/GetExp(minutes as num)
	var/CMinutes = (world.realtime / 10) / 60
	var/exp = minutes - CMinutes
	if (exp <= 0)
		return 0
	else
		var/timeleftstring
		if (exp >= 1440) //1440 = 1 day in minutes
			timeleftstring = "[round(exp / 1440, 0.1)] Days"
		else if (exp >= 60) //60 = 1 hour in minutes
			timeleftstring = "[round(exp / 60, 0.1)] Hours"
		else
			timeleftstring = "[exp] Minutes"
		return timeleftstring


/proc/PrepareBan()
	var/ckey = input(usr,"What ckey do you wish to ban?","bannings","") as text|null
	if(!ckey)
		return
	PrepareBanForCkey(ckey)

/proc/PrepareBanForCkey(ckey)
	var/list/bdetails = QueryBanDetails()
	var/datum/ban/bantype = bdetails[1]
	var/duration = bdetails[2]
	var/reason = bdetails[3]
	var/a_ckey, a_computerid, a_ip
	if(usr.client && istype(usr.client, /client))
		a_ckey = usr.client:ckey
		a_computerid = usr.client:computer_id
		a_ip = usr.client:address
	to_chat(usr,"test0")
	customBan(bantype,ckey,duration,reason,a_ckey,a_computerid,a_ip)

/proc/QueryBanDetails()
	if(!ban_master)
		return
	//var/duration = -1

	var/datum/ban/bantype = input(usr, "Which ban?","bantype") as null|anything in ban_master.bantypes
	to_chat(usr,"[bantype]")
	if(!bantype)
		return
	var/mins = input(usr,"How long (in minutes)? Enter -1 if permanent","Ban time",-1) as num|null
	if(!mins)
		return
	mins = min(525599,mins)
	//if(mins == -1)
	//	duration = mins
	//else
	//	duration = GetExp(((world.realtime / 10) / 60) + mins)
	to_chat(usr,"test51515")
	var/reason = input(usr,"reason?","reason","No Reason") as text|null
	if(!reason)
		return
	return list(bantype,mins,reason)


/datum/admins/proc/AddBan(var/bantype,var/ckey,var/duration=-1,var/reason="")
	if(!check_rights(R_BAN))
		return
	var/a_ckey, a_computerid, a_ip
	if(src.owner && istype(src.owner, /client))
		a_ckey = src.owner:ckey
		a_computerid = src.owner:computer_id
		a_ip = src.owner:address

	customBan(bantype,ckey,duration,reason,a_ckey,a_computerid,a_ip)

///proc/AddBan(ckey, computerid, reason, bannedby, temp, minutes, address)
//	customBan(/datum/ban/ban, ckey, minutes, reason, "", 0, 1, ckey, a_ckey, a_computerid, a_ip)


/proc/customBan(var/datum/ban/bantype, var/mob/banned_mob, var/duration = -1, var/reason, a_ckey,a_computerid,a_ip)
	to_chat(usr,"test1")
	if(!SSdbcore.Connect())
		message_admins("Error: SSdbcore cannot connect in customBan")
		return

	world.log << "test1"
	var/serverip = "[world.internet_address]:[world.port]"
	var/bantype_str
	if(istext(bantype))
		bantype_str = bantype
		bantype = text2path(bantype)
	else
		if(istype(bantype,/datum/ban/))
			bantype_str = "[bantype]"
	if (!bantype)
		return
	if( !istext(reason) )
		return
	if( !isnum(duration) )
		to_chat(usr,"durat")
		return

	var/ckey
	var/computerid
	var/ip
	var/validckey = 0

	to_chat(usr,"test2")
	if(ismob(banned_mob))
		ckey = banned_mob.ckey
		if (!ckey && banned_mob.mind)
			ckey = ckey(banned_mob.mind.key)
		if(banned_mob.client)
			computerid = banned_mob.client.computer_id
			ip = banned_mob.client.address
		else
			computerid = banned_mob.computer_id
			ip = banned_mob.lastKnownIP
	else if(istext(banned_mob))
		ckey = ckey(banned_mob)
		////
		var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT computerid,ip FROM erro_player WHERE ckey = :ckey", list("ckey" = ckey))
		if(!query.Execute())
			message_admins("Error: [query.ErrorMsg()]")
			log_sql("Error: [query.ErrorMsg()]")
			qdel(query)
			return

		if(query.NextRow())
			computerid = query.item[1]
			ip = query.item[2]
			validckey = 1
		else
			to_chat(usr, "could not fetch player's computerid/ip from database.")
		qdel(query)
	if(!validckey)
		var/datum/DBQuery/query = SSdbcore.NewQuery("SELECT id FROM erro_player WHERE ckey = :ckey", list("ckey" = "[ckey]"))
		if(!query.Execute())
			message_admins("Error: [query.ErrorMsg()]")
			log_sql("Error: [query.ErrorMsg()]")
			qdel(query)
			return
		if(query.NextRow())
			validckey = 1
		qdel(query)
	if(!validckey)
		if(!banned_mob || (banned_mob && !IsGuestKey(banned_mob.key)))
			message_admins("<span class='red'>[key_name_admin(usr)] attempted to ban [ckey], but [ckey] has not been seen yet. Please only ban actual players.</span>",1)
			return
	to_chat(usr,"test3")
	world.log << "test2"

//	if(src.owner && istype(src.owner, /client))
//		a_ckey = src.owner:ckey
//		a_computerid = src.owner:computer_id
//		a_ip = src.owner:address
	var/param = bantype.param

	var/who
	for(var/client/C in clients)
		if(!who)
			who = "[C]"
		else
			who += ", [C]"

	var/adminwho
	for(var/client/C in admins)
		if(!adminwho)
			adminwho = "[C]"
		else
			adminwho += ", [C]"
	to_chat(usr,"look [ip]")
	var/sql = "INSERT INTO erro_ban (`id`,`bantime`,`serverip`,`bantype`,`reason`,`param`,`duration`,`rounds`,`expiration_time`,`ckey`,`computerid`,`ip`,`a_ckey`,`a_computerid`,`a_ip`,`who`,`adminwho`,`edits`,`unbanned`,`unbanned_datetime`,`unbanned_ckey`,`unbanned_computerid`,`unbanned_ip`, `unbanned_notification`) VALUES (null, Now(), '[serverip]', '[bantype_str]', :reason, :param, [(duration)?"[duration]":"0"], 0, Now() + INTERVAL [(duration>0) ? duration : 0] MINUTE, :ckey, :computer_id, :ip, :a_ckey, :a_computerid, :a_ip, :who, :admin_who, '', null, null, null, null, null, 0)"
	var/datum/DBQuery/query_insert = SSdbcore.NewQuery(sql, list(
		"reason" = reason,
		"param" = param,
		"ckey" = ckey,
		"computer_id" = computerid,
		"ip" = ip,
		"a_ckey" = a_ckey,
		"a_computerid" = a_computerid,
		"a_ip" = a_ip,
		"who" = who,
		"admin_who" = adminwho,
	))
	if(!query_insert.Execute())
		message_admins("Error: [query_insert.ErrorMsg()]")
		log_sql("Error: [query_insert.ErrorMsg()]")
		qdel(query_insert)
		return
	qdel(query_insert)
	to_chat(usr, "<span class='notice'>Ban saved to database.</span>")
	message_admins("[key_name_admin(usr)] has added a [bantype_str] for [ckey] [(duration > 0)?"([duration] minutes)":""] with the reason: \"[reason]\" to the ban database.",1)
