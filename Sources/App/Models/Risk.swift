import Vapor
import Fluent

final class Risk: Model, Content {
    static let schema = "j_risks_copy"
        
	@ID(custom: "rkid", generatedBy: .user) var id: Int?

    @Field(key: "rkorder") var rkorder: Int

    @Field(key: "rkgroup") var rkgroup: String
    
    @Field(key: "rklabel") var rklabel: String
    
    @Field(key: "rkscore") var rkscore: Int

    init() { }

    init(id: Int? = nil, rkorder: Int, rkgroup: String, rklabel: String, rkscore: Int) {
        self.id = id
        self.rkorder = rkorder
        self.rkgroup = rkgroup
        self.rklabel = rklabel
        self.rkscore = rkscore
    }
}

