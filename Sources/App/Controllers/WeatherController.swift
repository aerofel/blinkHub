import Vapor
import Fluent
import FluentSQL // Used only for .raw
import Telegrammer


extension String {
    func match(of: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: of, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, count)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}

func formatWx(of: String) -> String {

	var weather = of

    var pf="🌤 "

    let sc: [String: String] = ["SKC": "☀️", "CLR": "☀️","NCD": "☀️", "CAVOK": "☀️", "FEW": "🌤 ", "SCT": "⛅️", "BKN": "🌥 ", "OVC": "☁️", "CB": "🌩 ", "VV": "🌫 "]
    var match = weather.match(of: "(?:[A-Z0-9]{4}) .*?Z.*?(SKC|CLR|NCD|CAVOK|FEW|SCT|BKN|OVC|CB|VV)")
	if match.count > 0 {
        pf = sc[match[0][1]]!
	}

    let wi: [String: String] = ["SH": "🌦 ", "FG": "🌫 ", "BR": "🌫 ", "FU": "🌫 ", "FZ": "❄️", "TS": "⛈", "SN": "☃️", "SG": "☃️", "GR": "🌧 ", "GS": "🌧 ", "RA": "☔️", "VA": "🌋", "FC": "🌪 "]
    match = weather.match(of: "(?:[A-Z0-9]{4}) .*?Z.*?(SH|FG|BR|FU|FZ|TS|SN|SG|GR|GS|RA|VA|FC)")
	if match.count > 0 {
        pf = wi[match[0][1]]!
	}

    var qa=""
    match = weather.match(of: "(Q|A)([0-9]{4})")
    if match.count > 0 {
        if let qnh = Int(match[0][2]) {
			if(match[0][1] == "Q") {
				if(qnh > 1023) { qa = "⏫" }
				else {
					if(qnh > 1013) { qa = "🔼" }
					else {
						if(qnh < 1003) { qa = "⏬" }
						else {
							if(qnh < 1013) { qa = "🔽" }
							else { qa = "⏹" }
						}
					}
				}
			}
			else {            
				if(qnh > 3021) { qa = "⏫" }
				else {
					if(qnh > 2992) { qa = "🔼" }                
					else {
						if(qnh < 2992) { qa = "🔽" }
						else { qa = "⏹" }
					}
				}
			}
		}
    }

	// LFRN 022030 to LFRN [02]20:30z
	weather = weather.replacingOccurrences(of: "([A-Z0-9]{4}) +([0-9]{2})([0-9]{2})([0-9]{2})Z", with: "$1 [$2]$3:$4z", options: [.regularExpression]) 
	// 20006G15KT to 200˚06G15KT
	weather = weather.replacingOccurrences(of: "(^| |>)([0-9]{3})([0-9]{2})G([0-9]{2})(KT|MPS)( |$|<)", with: "$1$2˚$3G$4$5$6", options: [.regularExpression]) 
	// 20006KT to 200˚20kt
	weather = weather.replacingOccurrences(of: "(^| |>)([0-9]{3})([0-9]{2})(KT|MPS)( |$|<)", with: "$1$2˚$3$4$5", options: [.regularExpression]) 
	// 20006MPS to 200˚20mps
	weather = weather.replacingOccurrences(of: "(^| |>)([0-9]{2})/([0-9]{2})( |$|<)", with: "$1$2˚/$3˚$4", options: [.regularExpression]) 
	// Q1006 to Q1006 bold
	weather = weather.replacingOccurrences(of: "(^| |>)Q([0-1][0-9]{3})( |$|<)", with: "$1<b>Q$2</b>\(qa)$3", options: [.regularExpression]) 
	// A2998 to A29.98 bold
	weather = weather.replacingOccurrences(of: "(^| |>)A([0-9]{2})([0-9]{2})( |$|<)", with: "$1<b>A$2.$3</b>\(qa)$4", options: [.regularExpression]) 
	// FM290430 to FM[29]04:30
	weather = weather.replacingOccurrences(of: "(^| |>)(FM)([0-9][0-9])([0-9][0-9])([0-9][0-9])( |$|<)", with: "$1$2[$3]$4:$5z$6", options: [.regularExpression]) 
	// 0220/0223 to [02]20z/[02]23z
	weather = weather.replacingOccurrences(of: "(^| |>)([0-9][0-9])([0-9][0-9])/([0-9][0-9])([0-9][0-9])( |$|<)", with: "$1[$2]$3z/[$4]$5z$6", options: [.regularExpression]) 

    return "\(pf) \(weather)"
	
}

/// Controls basic CRUD operations on `Todo`s.
final class WeatherController {
    // let db: Database

    // init(db: Database) {
    //     self.db = db
    // }

	//public let bot: Bot

    func index(req: Request) throws -> EventLoopFuture<[Weather]> {
        return Weather.query(on: req.db).all()
    }

    func query(req: Request) throws -> EventLoopFuture<[Weather]> {

		guard let icao = req.parameters.get("icao", as: String.self) else {
            throw Abort(.badRequest)
        }

		let _ = Filter.query(on: req.db)
					.filter(\.$filter == icao)
					.filter(\.$ft == "WN")
					.all(\.$chatid)
					.flatMapThrowing { chatids in 
						print(chatids)
						for chatid in chatids {
							if let number = Int64(chatid) {
								let params = Bot.SendMessageParams(chatId: .chat(number), text: """
										🎊🎉👋😃
										Just received a query for \(number):
										ICAO: \(icao)
										""")
								try bot.sendMessage(params: params)
							}
						}
					}


//		ws.sendJsonBlob({ key: "up", isPressed: false })
		
		print("ICAO: \(icao)")
		
		if let ct = req.parameters.get("ct")! as String? {

			print("CT  : \(ct)")
			return Weather.query(on: req.db)
					.filter(\.$icao == icao)
					.filter(\.$ct == ct)
					.all()
					
		}
		else {
			return Weather.query(on: req.db)
					.filter(\.$icao == icao)
					.sort(\.$ct, .ascending)
					.all()					
		}
	}

    func create(req: Request) throws -> EventLoopFuture<Weather> {
        let weather = try req.content.decode(Weather.self)
        return weather.save(on: req.db).map { weather }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {

		guard let icao = req.parameters.get("icao", as: String.self) else {
            throw Abort(.badRequest)
        }

		// Delete based on icao / ct or icao only (deletes all cts)
		if let ct = req.parameters.get("ct")! as String? {

	        return Weather.query(on: req.db)
					.filter(\.$icao == icao)
					.filter(\.$ct == ct)
					.first()
		            .unwrap(or: Abort(.notFound))
					.flatMap { $0.delete(on: req.db) }
		            .transform(to: .ok)
		}
		else {
			
	        return Weather.query(on: req.db)
					.filter(\.$icao == icao)
					.first()
		            .unwrap(or: Abort(.notFound))
					.flatMap { $0.delete(on: req.db) }
		            .transform(to: .ok)
		}
    }

//	func update(req: Request) throws -> EventLoopFuture<Weather.Output> {
	func update(req: Request) throws -> EventLoopFuture<HTTPStatus> {
		guard let icao = req.parameters.get("icao", as: String.self) else {
            throw Abort(.badRequest, reason: "no ICAO provided")
        }

		guard let ct = req.parameters.get("ct", as: String.self) else {
            throw Abort(.badRequest, reason: "no category provided")
        }

		let params = Bot.SendMessageParams(chatId: .chat(834355583), text: """
				🎊🎉👋😃
				Just received a PUT:
				ICAO: \(icao)
				CT: \(ct)             
				""")
		try bot.sendMessage(params: params)
		
		let input = try req.content.decode(Weather.Input.self)

		return Weather.query(on: req.db)
				.filter(\.$icao == icao)
				.filter(\.$ct == ct)
				.first()
	            .unwrap(or: Abort(.notFound))
				.flatMap { weather in
					weather.content = input.content
					weather.sct = input.sct
					weather.dtime = input.dtime
					weather.src = input.src
					return weather.save(on: req.db)
						.transform(to: .ok)
						//.map { Weather.Output(id: weather.id!.uuidString, content: weather.content) }
				}
	}

	func upsert(req: Request) throws -> EventLoopFuture<HTTPStatus> {

		guard let icao = req.parameters.get("icao", as: String.self) else {
            throw Abort(.badRequest, reason: "no ICAO provided")
        }

		guard let ct = req.parameters.get("ct", as: String.self) else {
            throw Abort(.badRequest, reason: "no category provided")
        }

		let input = try req.content.decode(Weather.Input.self)

		return Weather.query(on: req.db)
			.filter(\.$icao == icao)
			.filter(\.$ct == ct)
            .first()
			.flatMapThrowing { result in

				var notify = false

                if let weather = result {
	                //print("Already exists: \(String(describing:result))")
					print("UPDATE \(input.src): \(icao)-\(ct) \(input.dtime)")
					
					if input.dtime > weather.dtime {
						notify = true

						weather.content = input.content
						weather.sct = input.sct
						weather.dtime = input.dtime
						weather.src = input.src
						let _ = weather.save(on: req.db)
					}
                }
				else {
	                print("CREATE \(input.src): \(icao)-\(ct)")
					notify = true

					let weather = Weather()

					weather.id = "\(icao)-\(ct)"

					weather.icao = icao
					weather.ct = ct

					weather.content = input.content
					weather.sct = input.sct
					weather.dtime = input.dtime
					weather.src = input.src
					let _ = weather.save(on: req.db)							
                }

				if notify {
					let _ = Filter.query(on: req.db)
						.filter(\.$filter == icao)
						.filter(\.$ft == "WN")
						.all(\.$chatid)
						.flatMapThrowing { chatids in 
							if chatids.count > 0 {
								print(chatids)
							}
							for chatid in chatids {
								if let number = Int64(chatid) {
									let params = Bot.SendMessageParams(chatId: .chat(number), text: """
											<b>\(ct) \(input.sct)</b><pre>\(formatWx(of: input.content))</pre>
											""", parseMode: .html)
									try bot.sendMessage(params: params)
								}
							}
						}
				}
			}.transform(to: .ok)
    }

	func upsertRaw(req: Request) throws -> EventLoopFuture<HTTPStatus> {

		guard let icao = req.parameters.get("icao", as: String.self) else {
            throw Abort(.badRequest, reason: "no ICAO provided")
        }

		guard let ct = req.parameters.get("ct", as: String.self) else {
            throw Abort(.badRequest, reason: "no category provided")
        }

		let input = try req.content.decode(Weather.Input.self)

		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		let dtimeString = formatter.string(from: input.dtime)

		print("ICAO   : \(icao)")
		print("CT     : \(ct)")
		print("SCT    : \(input.sct)")
		print("DTIME  : \(dtimeString)")
		print("CONTENT: \(input.content)")
		print("SRC    : \(input.src)")		
		
		if let sqldb = req.db as? SQLDatabase {
			return sqldb.raw("""
				INSERT INTO j_wx (icao,ct,sct,dtime,content,src) 
					VALUES ('\(icao)\','\(ct)','\(input.sct)','\(dtimeString)','\(input.content)','\(input.src)') 
				ON DUPLICATE KEY UPDATE 
					sct = IF( '\(dtimeString)' > dtime, '\(input.sct)', sct),					
					content = IF( '\(dtimeString)' > dtime, '\(input.content)', content),
					src = IF( '\(dtimeString)' > dtime, '\(input.src)', src),
					dtime = IF( '\(dtimeString)' > dtime, '\(dtimeString)', dtime)
				""").all().transform(to: .ok)

        }
        else {
			throw Abort(.badRequest, reason: "Upsert failed")
	    }
    }
    
}
