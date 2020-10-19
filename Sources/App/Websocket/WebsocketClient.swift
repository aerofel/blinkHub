import Vapor

open class WebSocketClient {
    open var id: UUID
    open var socket: WebSocket

    public init(id: UUID, socket: WebSocket) {
        self.id = id
        self.socket = socket
    }
}

open class WebsocketClients {
    var eventLoop: EventLoop
    var storage: [UUID: WebSocketClient]
    
    var active: [WebSocketClient] {
        self.storage.values.filter { !$0.socket.isClosed }
    }

    init(eventLoop: EventLoop, clients: [UUID: WebSocketClient] = [:]) {
        self.eventLoop = eventLoop
        self.storage = clients
    }
    
    func add(_ client: WebSocketClient) {
        self.storage[client.id] = client
    }

    func remove(_ client: WebSocketClient) {
        self.storage[client.id] = nil
    }
    
    func find(_ uuid: UUID) -> WebSocketClient? {
        self.storage[uuid]
    }

    deinit {
        let futures = self.storage.values.map { $0.socket.close() }
        try! self.eventLoop.flatten(futures).wait()
    }
}

struct WebsocketMessage<T: Codable>: Codable {
    let client: UUID
    let data: T
}

extension ByteBuffer {
    func decodeWebsocketMessage<T: Codable>(_ type: T.Type) -> WebsocketMessage<T>? {
        try? JSONDecoder().decode(WebsocketMessage<T>.self, from: self)
    }
}

import Foundation

struct Connect: Codable {
    let connect: Bool
}

struct Point: Codable {
    var x: Int = 0
    var y: Int = 0
    
    func distance(_ to: Point) -> Float {
        let xDist = Float(self.x - to.x)
        let yDist = Float(self.y - to.y)
        return sqrt(xDist * xDist + yDist * yDist)
    }
}

struct Input: Codable {

    enum Key: String, Codable {
        case up
        case down
        case left
        case right
    }

    let key: Key
    let isPressed: Bool
}

/*
final class PlayerClient: WebSocketClient {

    struct Status: Codable {
        var id: UUID!
        var position: Point
        var color: String
        var catcher: Bool = false
        var speed = 4
    }
    
    var status: Status
    var upPressed: Bool = false
    var downPressed: Bool = false
    var leftPressed: Bool = false
    var rightPressed: Bool = false
    
    
    public init(id: UUID, socket: WebSocket, status: Status) {
        self.status = status
        self.status.id = id

        super.init(id: id, socket: socket)
    }

    func update(_ input: Input) {
        switch input.key {
        case .up:
            self.upPressed = input.isPressed
        case .down:
            self.downPressed = input.isPressed
        case .left:
            self.leftPressed = input.isPressed
        case .right:
            self.rightPressed = input.isPressed
        }
    }

    func updateStatus() {
        if self.upPressed {
            self.status.position.y = max(0, self.status.position.y - self.status.speed)
        }
        if self.downPressed {
            self.status.position.y = min(480, self.status.position.y + self.status.speed)
        }
        if self.leftPressed {
            self.status.position.x = max(0, self.status.position.x - self.status.speed)
        }
        if self.rightPressed {
            self.status.position.x = min(640, self.status.position.x + self.status.speed)
        }
    }
}

class GameSystem {
    var clients: WebsocketClients

    init(eventLoop: EventLoop) {
        self.clients = WebsocketClients(eventLoop: eventLoop)
    }

    func connect(_ ws: WebSocket) {
        ws.onBinary { [unowned self] ws, buffer in
            if let msg = buffer.decodeWebsocketMessage(Connect.self) {
                let player = PlayerClient(id: msg.client, socket: ws)
				print("connect \(msg.client)")
                self.clients.add(player)
            }
        }
    }
    
    
}


class Room {
    var connections: [String: WebSocket]

    func bot(_ message: String) {
        send(name: "Bot", message: message)
    }

    func send(name: String, message: String) {
//        let message = message.truncated(to: 256)

//        let messageNode: [String: NodeRepresentable] = [
//            "username": name,
//            "message": message
//        ]

//        guard let json = try? JSON(node: messageNode) else {
//            return
//        }

		print("Triggered")

        for (name, socket) in connections {
//            guard username != name else {
//                continue
//            }
			print(name)

            try? socket.send("Name: "+name+" Message:"+message)
        }
        
   
    }

    init() {
        connections = [:]
    }
}
*/
