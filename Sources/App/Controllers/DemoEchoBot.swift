import Foundation
import Telegrammer
import TelegrammerMiddleware

class DemoEchoBot: TelegrammerMiddleware {
    public let dispatcher: Dispatcher
    public let path: String
    public let bot: Bot

    public init(path: String, settings: Bot.Settings) throws {
        self.path = path
        self.bot = try Bot(settings: settings)
        self.dispatcher = Dispatcher(bot: bot)

        // dispatcher.add(
        //     handler: MessageHandler(
        //         filters: .all,
        //         callback: echoResponse
        //     )
        // )
    }

    func tgNotify(chatId: Int64, text: String) throws {

        let params = Bot.SendMessageParams(
            chatId: .chat(chatId),
            text: text
        )

        try bot.sendMessage(params: params)
    }
}