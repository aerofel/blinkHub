import Vapor
import Fluent

final class Weather: Model, Content {
    static let schema = "j_wx_copy"

	@ID(custom: "id", generatedBy: .user) var id: String?
    //@ID() var id: UUID?

    @Field(key: "icao") var icao: String

    @Field(key: "ct") var ct: String
    
    @OptionalField(key: "sct") var sct: String?
    
    @OptionalField(key: "content") var content: String?
    
    @Field(key: "dtime") var dtime: Date
    
//    @Timestamp(key: "dtime", on: .update, format: .default) var dtime: Date?
    
    @Field(key: "src") var src: String

    init() { }

    // Creates a new Wx with all properties set.
    init(id: String? = nil, icao: String, ct: String, sct: String?, content: String?, dtime: Date, src: String) {
        self.id = id
        self.icao = icao
        self.ct = ct
        self.sct = sct
        self.content = content
        self.dtime = dtime
        self.src = src
    }
    
	struct Input: Content {
        let sct: String
        let content: String
        let dtime: Date
        let src: String
    }

    struct Output: Content {
        let id: String
        let icao: String
        let ct: String
        let sct: String
        let content: String
        let dtime: Date
        let src: String
    }
}

struct CreateWeather: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Weather.schema)
            .id()
            .field("icao", .string, .required)
            .field("ct", .string, .required)
            .field("sct", .string)
            .field("content", .string)
            .field("dtime", .datetime, .required)
            .field("src", .string, .required)
            .unique(on: "icao", "ct")
            .ignoreExisting()
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Weather.schema).delete()
    }
}

struct AddWeatherUUID: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Weather.schema) 
            .id()
            .update()        
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Weather.schema)
            .deleteField("id")
            .update()        
    }

}

