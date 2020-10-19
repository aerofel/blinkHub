import Vapor
import Telegrammer
//let room = Room()

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }
    
    app.get("aircraft") { req in
    	Aircraft.query(on: req.db).all()
	}

	let aircraftController = AircraftController()
    app.get("testac", use: aircraftController.index)


	let weatherController = WeatherController()
    app.get("wx", ":icao", ":ct", use: weatherController.query)

    app.put("wx", ":icao", ":ct", use: weatherController.update)

    app.post("wx", ":icao", ":ct", use: weatherController.create)

    app.patch("wx", ":icao", ":ct", use: weatherController.upsert)

    app.delete("wx", ":icao", ":ct", use: weatherController.delete)


    app.get("weather", ":icao") { req in
//		let icao = req.parameters.get("icao")!
//		print("Hello, \(icao)!")
		

		return Weather.query(on: req.db).all()    	
	}

/*
	let gameSystem = GameSystem(eventLoop: app.eventLoopGroup.next())

    app.webSocket("channel") { req, ws in
        gameSystem.connect(ws)
    }   
*/
    struct HelloCommand: Command {
        struct Signature: CommandSignature { }

        var help: String {
            "Says hello"
        }

        func run(using context: CommandContext, signature: Signature) throws {
            context.console.print("Hello, world!")
        }
    }

    app.commands.use(HelloCommand(), as: "hello")
}

