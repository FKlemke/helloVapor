import Vapor
import VaporPostgreSQL
import HTTP


let drop = Droplet()
drop.preparations.append(Friend.self)
try drop.addProvider(VaporPostgreSQL.Provider.self)

do {
    try drop.addProvider(VaporPostgreSQL.Provider.self)
} catch {
    assertionFailure("Error adding provider: \(error)")
}


//routes
drop.get { req in
    return try drop.view.make("welcome", [
    	"message": drop.localization[req.lang, "welcome", "title"]
    ])
}

drop.get("helloFelix") {reg in
    return "Hello Felix!"
}

drop.get("hello", Int.self) {reg, userID in
    return "Hello Felix! this it your \(userID)"
}

//drop.get("friends") { req in
//    let friends = [Friend(name: "Sarah", age: 33, email:"sarah@email.com"),
//                   Friend(name: "Steve", age: 31, email:"steve@email.com"),
//                   Friend(name: "Drew", age: 35, email:"drew@email.com")]
//    let friendsNode = try friends.makeNode()
//    let nodeDictionary = ["friends": friendsNode]
//    return try JSON(node: nodeDictionary)
//}


drop.get("friends") { req in
    let friends = try Friend.all().makeNode()
    let friendsDictionary = ["friends": friends]
    return try JSON(node: friendsDictionary)
}

drop.post("friend") { req in
    var friend = try Friend(node: req.json)
    try friend.save()
    return try friend.makeJSON()
}

//drop.delete("delete", Int.self){ reg, delID in {
//    
//    }


drop.get("vapor") { request in
    return Response(redirect: "http://vapor.codes")
}

//error messages
drop.get("404") { request in
    throw Abort.notFound
}

drop.get("error") { request in
    throw Abort.custom(status: .badRequest, message: "Sorry 😱")
}
    

drop.resource("posts", PostController())

drop.run()
