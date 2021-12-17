// Steps:
// Open Inspect Element, (roblox.com/home > Right Click > Inspect Element) (F12)
// Go to Console
// Paste script in

// Changes will take a while to show, but will unfriend everyone

var userId = $("meta[name='user-data']").data("userid")
var cursor

async function getNextPage() {
    var resp = await fetch(`https://friends.roblox.com/v1/users/${userId}/friends?sortOrder=Desc&limit=100&cursor=${cursor || ''}`)
    var data = await resp.json()
    cursor = data.nextPageCursor
    return data.data
}

const forLoop = async _ => {
    while (true) {
        var friends = await getNextPage()
        if (friends.length == 0) break
        for (const friend of friends) {
            $.ajax({
                url: "https://friends.roblox.com/v1/users/" + friend.id + "/unfriend",
                type: "POST",
                headers: {"X-CSRF-TOKEN": Roblox.XsrfToken.getToken()},
                contentType: "application/json;charset=UTF-8",
            })
        }
        if (!cursor) break
    }
}
forLoop()
