local Target = "Mr_Purrsalot"
-- ^^ EDIT ABOVE TO THE USER YOU WANT

-- // DO NOT MODIFY BELOW UNLESS YOU KNOW WHAT YOU ARE DOING.
function PrintSync(Txt)
    if rconsoleprint then
        rconsoleprint(Txt)
    else
        print(Txt)
    end
end
function WarnSync(Txt)
    if rconsolewarn then
        rconsolewarn(Txt)
    else
        print(Txt)
    end
end

if rconsolewarn then rconsolewarn("WHILE BADGE SNIPER IS RUNNING DO NOT PRESS THE RCONSOLE") end

local CurrentId = "0"
local NoLongerLooking = false
local CurrentBadge = "0"
PrintSync("\nWelcome to BadgeSniper by pigeon#1818! Username for user search = "..Target)
if rconsolename then rconsolename("Badge Sniper//Get CMD-X or gay.") end
PrintSync("\n")
WarnSync("Due to Roblox sorting badges by oldest first the badge checking process may take some time.")
PrintSync("Make sure to check out my Admin GUI (CMD-X) search CMD-X Roblox on Google!")
PrintSync("\n")

pcall(function() Http = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://api.roblox.com/users/get-by-username?username="..Target)); CurrentId = Http.Id end)
if CurrentId == "0" then
    PrintSync("\n")
    WarnSync("Your request was cancelled by Roblox - for more info on this scenario see below;")
    PrintSync("\n")
    WarnSync("Your API requests may have exceeded 60 per minute.")
    PrintSync("\n")
    WarnSync("You may be blacklisted by Roblox on your IP.")
    PrintSync("\n")
    WarnSync("You may have the wrong user name, or it may not exist.")
    return
end

local Online = true
function CheckOnlineStatus(UserId)
    Online = true
    pcall(function() 
        Http2 = game:GetService("HttpService"):JSONDecode(game:HttpGet("http://api.roblox.com/users/"..UserId.."/onlinestatus")) 
        if Http2.IsOnline == true then Online = "true" else Online = "false" end
    end)
    return Online
end
if CheckOnlineStatus(CurrentId) ~= "true" then
    WarnSync("User is not online?")
    return
end

PrintSync("\n"..CurrentId)

function CheckBadges(UserId)
    local TopBadge = "1"
    local Badges = {}
    local URL = ("https://badges.roblox.com/v1/users/"..UserId.."/badges?limit=100&sortOrder=Asc")
	local Http = game:GetService("HttpService"):JSONDecode(game:HttpGet(URL))
	local RAP = 0
	function ListItems(Look)
		for i,v in pairs(Look.data) do
			if v.id ~= nil then Badges[#Badges+1] = v.id end
		end
	end
	PrintSync("\nChecking badges page 0")
	ListItems(Http)
	for i = 1,5000 do
	    PrintSync("\nChecking badges page "..i)
		if NoLongerLooking == true then break end
		if Http.nextPageCursor ~= null then
			Http = game:GetService("HttpService"):JSONDecode(game:HttpGet(URL.."&cursor="..Http.nextPageCursor))
			ListItems(Http)
		else
			TopBadge = Badges[#Badges]
			break
		end
	end
	if TopBadge ~= "1" then return TopBadge else return "sorry" end
end

function CheckPlaces(UserId, PlaceId)
	local GUID = "0"
	local userFound = false
    local Http = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="))
    for i = 1,100 do
        for i,v in pairs(Http.data) do
            for x,y in pairs(v.playerIds) do
                if tonumber(y) == UserId then
                    userFound = true
                    GUID = v.id
                    break
                end
            end
            if userFound then break end
        end
        if userFound then break end
        PrintSync("Servers page searched...")
        if Http.nextPageCursor ~= null then Http = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="..Http.nextPageCursor)) else break end
    end
	if GUID ~= "0" then return GUID else return "sorry" end
end

game:GetService("Players").LocalPlayer.Chatted:Connect(function(txt)
    arguments = txt:lower():split(" ")
    if arguments[1] == "bsstop" then NoLongerLooking = true end
    if arguments[1] == "bslookup" then 
        NoLongerLooking = true
        WarnSync("Stopping... Please wait.") 
        wait(10)
        pcall(function() Http = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://api.roblox.com/users/get-by-username?username="..arguments[2])); CurrentId = Http.Id end)
        NoLongerLooking = false 
    end
end)

local i = 0
repeat i = i + 1
    if CheckOnlineStatus(CurrentId) ~= "true" then
        WarnSync("User is no longer online.")
        NoLongerLooking = true
        break
    end
    if NoLongerLooking == true then break end
    pcall(function() 
        PrintSync("\nRe-running badge check...")
        CurrentBadger = CheckBadges(CurrentId)
        if CurrentBadger ~= "sorry" then
            if CurrentBadge ~= CurrentBadger then
                PrintSync("\nNew badge detected on profile, searching linked game...")
                pcall(function() HttpBadge = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://badges.roblox.com/v1/badges/"..CurrentBadger)) end)
                PrintSync("\n".."Checking place... "..HttpBadge.awardingUniverse.rootPlaceId)
                local PlaceId = HttpBadge.awardingUniverse.rootPlaceId
                local GotchaBro = CheckPlaces(CurrentId, PlaceId)
                if GotchaBro ~= "sorry" then game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, GotchaBro, game:GetService("Players").LocalPlayer) else rconsoleprint("\nUser could not be found, they may have left.") end
            end
            CurrentBadge = CurrentBadger
        end
    end)
    wait(5)
until NoLongerLooking
