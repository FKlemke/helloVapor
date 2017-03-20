import Vapor
import VaporPostgreSQL
import HTTP

//create DROPLET
let drop = Droplet()
//adding models
drop.preparations.append(Friend.self)
drop.preparations.append(User.self)

//adding providers
try drop.addProvider(VaporPostgreSQL.Provider.self)

//adding providers and catching error
//do {
//    try drop.addProvider(VaporPostgreSQL.Provider.self)
//} catch {
//    assertionFailure("Error adding SQL provider: \(error)")
//}

//adding middleware
//will add the version of our API to each response
final class VersionMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        response.headers["Version"] = "API v1.0"
        return response
    }
}
drop.middleware.append(VersionMiddleware())


//simple routes
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

//users
drop.post("user") { req in
    var user = try User(node: req.json)
    try user.save()
    return try user.makeJSON()
}

drop.get("users") { req in
    var users = try User.all().makeNode()
    let usersDic = ["users" : users]
    return try JSON(node: usersDic)
}

drop.get("user", Int.self){reg, userId in
    let user = try User.find(userId)
    return try JSON(node: user)
}

//drop.get("userbyname", String.self){ reg, usrName in
//    let smithsQuery = try User.query().filter("name", "Smith")
//    return smithsQuery
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
    throw Abort.custom(status: .badRequest, message: "Sorry 😱 a terrible error happened here")
}

//nesting slashes FALLBACK routes
drop.get("anything", "*") { request in
    return "Matches anything after /anything"
}


//postname send a json to route
drop.post("jsonname") { request in
    guard let name = request.json?["name"]?.string else {
        throw Abort.badRequest
    }
    guard let age = request.json?["age"]?.string else {
        throw Abort.badRequest
    }
    
    return "Hello, \(name) your age is \(age)!"
}

//json response with different types
drop.get("json") { request in
    return try JSON(node: [
        "number": 123,
        "text": "unicorns",
        "bool": false
        ])
}

//views
drop.get("htmltest") { request in
    return try drop.view.make("index.html")
}

//they can contain context
drop.get("template") { request in
    return try drop.view.make("welcome", [
        "message": "So all my bitches and my niggas and my niggas and my bitches Wave your motherfuckin hands in the air And if you dont give a shit like we don t give a shit Wave your motherfuckin fingers in the air"
        ])
}

drop.get("helloleaf"){ req in
    return try drop.view.make("hello", [
        "greetingSnoop": "Snoop DOGGG"])
}

drop.get { req in
    return try drop.view.make("welcome", [
        "message": drop.localization[req.lang, "welcome", "title"]
        ])
}

drop.get("helloworld") { req in
    let greetings = ["Mundo", "Monde", "Welt"]
    return try drop.view.make("hello", ["greeting": "World", "worlds": greetings.makeNode()])
}


drop.resource("posts", PostController())

drop.run()
