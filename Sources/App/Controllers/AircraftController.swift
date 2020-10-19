import Vapor
import Fluent

final class AircraftController {

/*
    let db: Database

    init(db: Database) {
        self.db = db
    }
*/

    /// Returns a list of all `Aircraft`s.
    func index(req: Request) throws -> EventLoopFuture<[Aircraft]> {
        return Aircraft.query(on: req.db).all()
    }
	
/*
    func create(req: Request) throws -> EventLoopFuture<Aircraft> {
        let aircraft = try req.content.decode(Aircraft.self)
        return aircraft.save(on: self.db).map { aircraft }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return Aircraft.find(req.parameters.get("aircraftID"), on: self.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: self.db) }
            .transform(to: .ok)
    }
*/
}
