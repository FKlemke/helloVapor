import Vapor

let drop = Droplet()

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

drop.get("friends") { req in
    return try JSON(node: ["friends": [
        ["name":"Sven", "nationality by heart": "where the kivis grow"],
        ["name":"gregor", "nationality by heart": "shakes & fitches"],
        ["name":"dustin", "nationality by heart": "RUST"],
        ["name":"jakob", "nationality by heart": "RICH JEW"],
        ["name":"max", "nationality by heart": "Belgian Banana Republic"],
        ["name":"dominik", "nationality by heart": "Zigeuner"],
        ]
        ])
}

drop.resource("posts", PostController())

drop.run()
