import Vapor
import Fluent

final class Filter: Model, Content {
	static let schema = "j_filters"

	//@ID(custom: "chat_id", generatedBy: .user) // Can be .user .random or .database
	//var id: String?
    @ID() var id: UUID?

    @Field(key: "chat_id") var chatid: String

    @Field(key: "message_id") var messageid: String
    
    @Field(key: "ft") var ft: String
    
    @Field(key: "filter") var filter: String
    
    init() { }

    // Creates a new Wx with all properties set.
    init(id: UUID? = nil, chatid: String, messageid: String, ft: String, filter: String) {
        self.id = id
        self.chatid = chatid
        self.messageid = messageid
        self.ft = ft
        self.filter = filter
    }
}

struct AddFilterUUID: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Filter.schema) 
            .id()
            .update()        
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(Filter.schema)
            .deleteField("id")
            .update()        
    }

}
