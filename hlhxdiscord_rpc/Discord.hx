package hlhxdiscord_rpc;

import haxe.Int64;

enum abstract DiscordPremiumType(Int) {
	var None;
	var NitroClassic;
	var Nitro;
	var NitroBasic;
}

enum abstract DiscordActivityPartyPrivacy(Int) {
	var Private;
	var Public;
}

enum abstract DiscordActivityType(Int) {
	var Playing = 0;
	var Listening = 1;
	var Watching = 3;
	var Competing = 5;
}

enum abstract DiscordActivityJoinRequestReply(Int) {
	var No;
	var Yes;
	var Ignore;
}

@:publicFields
class DiscordRichPresence {
	var type:DiscordActivityType;
	var state:String;
	var details:String;
	var startTimestamp:Int64;
	var endTimestamp:Int64;
	var largeImageKey:String;
	var largeImageText:String;
	var smallImageKey:String;
	var smallImageText:String;
	var partyID:String;
	var partySize:Int;
	var partyMax:Int;
	var partyPrivacy:DiscordActivityPartyPrivacy;
	// button shit here
	var matchSecret:String;
	var joinSecret:String;
	var spectateSecret:String;
	var instance:Bool;
}

@:publicFields
@:structInit
class DiscordUser {
	var userID:String;
	var username:String;
	var globalName:String;
	var discriminator:String;
	var avatar:String;
	var premiumType:DiscordPremiumType;
	var bot:Bool;
}

@:publicFields
class DiscordEventHandlers {
	var ready:(request:DiscordUser) -> Void;
	var disconnected:(errorCode:Int, message:String) -> Void;
	var errored:(errorCode:Int, message:String) -> Void;
	var joinGame:(joinSecret:String) -> Void;
	var spectateGame:(spectateSecret:String) -> Void;
	var joinRequest:(request:DiscordUser) -> Void;
}

@:publicFields
class DiscordButton {
	var label:String;
	var url:String;
}

@:publicFields
class Discord {
	static function Register(applicationID:String, command:String):Void {}

	static function RegisterSteamGame(applicationID:String, steamID:String):Void {}

	static function Initialize(applicationID:String, handlers:DiscordEventHandlers, autoRegister:Int, optionalSteamID:String):Void {
		var rpcHandlers = new RPCEventHandlers();
		if (handlers.ready != null)
			rpcHandlers.ready = (userID, username, globalName, discriminator, avatar, premiumType, bot) -> handlers.ready({
				userID: userID,
				username: username,
				globalName: globalName,
				discriminator: discriminator,
				avatar: avatar,
				premiumType: premiumType,
				bot: bot
			});
		rpcHandlers.disconnected = handlers.disconnected;
		rpcHandlers.errored = handlers.errored;
		rpcHandlers.joinGame = handlers.joinGame;
		rpcHandlers.spectateGame = handlers.spectateGame;
		if (handlers.joinRequest != null)
			rpcHandlers.joinRequest = (userID, username, globalName, discriminator, avatar, premiumType, bot) -> handlers.joinRequest({
				userID: userID,
				username: username,
				globalName: globalName,
				discriminator: discriminator,
				avatar: avatar,
				premiumType: premiumType,
				bot: bot
			});
		Discord_RPC.Initialize(applicationID, rpcHandlers, autoRegister, optionalSteamID);
	}

	static function Shutdown():Void {}

	static function RunCallbacks():Void {}

	#if DISCORD_DISABLE_IO_THREAD
	static function UpdateConnection():Void {}
	#end

	static function UpdatePresence(presence:DiscordRichPresence):Void {}

	static function ClearPresence():Void {}

	static function Respond(userID:String, reply:DiscordActivityJoinRequestReply):Void {}

	static function UpdateHandlers(handlers:DiscordEventHandlers):Void {}
}

@:publicFields
private class RPCEventHandlers {
	var ready:(userID:String, username:String, globalName:String, discriminator:String, avatar:String, premiumType:DiscordPremiumType, bot:Bool) -> Void;
	var disconnected:(errorCode:Int, message:String) -> Void;
	var errored:(errorCode:Int, message:String) -> Void;
	var joinGame:(joinSecret:String) -> Void;
	var spectateGame:(spectateSecret:String) -> Void;
	var joinRequest:(userID:String, username:String, globalName:String, discriminator:String, avatar:String, premiumType:DiscordPremiumType, bot:Bool) -> Void;

	function new() {}
}

@:publicFields
@:hlNative('discord_rpc')
private class Discord_RPC {
	static function Initialize(applicationID:String, handlers:RPCEventHandlers, autoRegister:Int, optionalSteamID:String):Void {}
}
