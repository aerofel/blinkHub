import Vapor
import Fluent

final class Session: Model, Content {
	static let schema = "j_sessions"

	@ID(custom: "chat_id", generatedBy: .user) // Can be .user .random or .database
	var id: String?

    @OptionalField(key: "fname") var fname: String?
    
    @OptionalField(key: "lname") var lname: String?
    
    @Field(key: "tstamp") var tstamp: Date
    
    init() { }

    // Creates a new Wx with all properties set.
    init(id: String? = nil, fname: String?, lname: String?, tstamp: Date) {
        self.id = id
        self.fname = fname
        self.lname = lname
        self.tstamp = tstamp
    }
}
