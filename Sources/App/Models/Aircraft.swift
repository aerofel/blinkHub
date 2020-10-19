import Vapor
import Fluent

final class Aircraft: Model, Content {
	static let schema = "j_aircraft_copy"

	@ID(custom: "acserial", generatedBy: .user) // Can be .user .random or .database
	var id: String?

    @Field(key: "acreg")
    var acreg: String

    @Field(key: "actype")
    var actype: String

    @Field(key: "acspec")
    var acspec: String

    @Field(key: "aclabel")
    var aclabel: String

    init() { }

    init(id: String? = nil, acreg: String, actype: String, acspec: String, aclabel: String) {
        self.id = id
        self.acreg = acreg
        self.actype = actype
        self.acspec = acspec
        self.aclabel = aclabel
    }
}
