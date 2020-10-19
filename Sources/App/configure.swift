import Vapor
import NIOSSL

import Fluent
import FluentMySQLDriver
import FluentSQL

import Foundation
import Telegrammer

extension Application {
    static let databaseUrl = URL(string: Environment.get("DB_URL")!)!

    static let dbHost = Environment.get("DB_HOST") ?? ""
    static let dbPort = Environment.get("DB_PORT").flatMap(Int.init) ?? 3306
    static let dbUser = Environment.get("DB_USER") ?? ""
    static let dbPass = Environment.get("DB_PASS") ?? ""
    static let dbName = Environment.get("DB_NAME") ?? ""

    static let botToken = Environment.get("BOT_TOKEN") ?? ""
    static let monitId = Environment.get("MONIT_ID") ?? ""

    
}

var settings = Bot.Settings(token: Application.botToken, debugMode: true)
let bot = try! Bot(settings: settings)

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	print("Starting...")

	app.databases.use(.mysql(
		hostname: Application.dbHost,
		port: Application.dbPort,
		username: Application.dbUser,
		password: Application.dbPass,
		database: Application.dbName,
		tlsConfiguration: .forClient(certificateVerification: .none)
	), as: .mysql)
	    
	app.http.server.configuration.hostname = "127.0.0.1"
    app.http.server.configuration.port = 8080
    
    //var settings = Bot.Settings(token: Application.botToken)
    //settings.webhooksConfig = Webhooks.Config(ip: "0.0.0.0", url: "https://test.url", port: 88)
    //let bot = try DemoEchoBot(path: "bot", settings: settings)

    //app.middleware.use(bot)

    //let uu = try bot.tgNotify(chatId: 834355583, text: "GET: TEST")




    app.migrations.add(CreateWeather())
    //app.migrations.add(AddFilterUUID())

    // register routes
    try routes(app)
    
//    try webSockets(app)
}
