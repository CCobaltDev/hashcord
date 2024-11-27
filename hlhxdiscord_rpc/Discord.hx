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

	function new() {}
}

@:publicFields
class DiscordButton {
	var label:String;
	var url:String;
}

@:publicFields
class Discord {
	static function Register(applicationID:String, command:String):Void {
		Discord_RPC.register(applicationID, command);
	}

	static function RegisterSteamGame(applicationID:String, steamID:String):Void {
		Discord_RPC.register_steam_game(applicationID, steamID);
	}

	static function Initialize(applicationID:String, handlers:DiscordEventHandlers, autoRegister:Int, optionalSteamID:String):Void {
		var rpcHandlers = new RPCEventHandlers();
		if (handlers.ready != null)
			rpcHandlers.ready = (userID, username, globalName, discriminator, avatar, premiumType, bot) -> @:privateAccess handlers.ready({
				userID: String.fromUTF8(userID),
				username: String.fromUTF8(username),
				globalName: String.fromUTF8(globalName),
				discriminator: String.fromUTF8(discriminator),
				avatar: String.fromUTF8(avatar),
				premiumType: premiumType,
				bot: bot
			});
		rpcHandlers.disconnected = (errorCode, message) -> @:privateAccess handlers.disconnected(errorCode, String.fromUTF8(message));
		rpcHandlers.errored = (errorCode, message) -> @:privateAccess handlers.errored(errorCode, String.fromUTF8(message));
		rpcHandlers.joinGame = joinSecret -> @:privateAccess handlers.joinGame(String.fromUTF8(joinSecret));
		rpcHandlers.spectateGame = spectateSecret -> @:privateAccess handlers.spectateGame(String.fromUTF8(spectateSecret));
		rpcHandlers.joinRequest = (userID, username, globalName, discriminator, avatar, premiumType, bot) -> @:privateAccess handlers.joinRequest({
			userID: String.fromUTF8(userID),
			username: String.fromUTF8(username),
			globalName: String.fromUTF8(globalName),
			discriminator: String.fromUTF8(discriminator),
			avatar: String.fromUTF8(avatar),
			premiumType: premiumType,
			bot: bot
		});

		Discord_RPC.initialize(applicationID, rpcHandlers, autoRegister, optionalSteamID ?? "");
	}

	static function Shutdown():Void {
		Discord_RPC.shutdown();
	}

	static function RunCallbacks():Void {
		Discord_RPC.run_callbacks();
	}

	#if DISCORD_DISABLE_IO_THREAD
	static function UpdateConnection():Void {
		Discord_RPC.update_connection();
	}
	#end

	static function UpdatePresence(presence:DiscordRichPresence):Void {}

	static function ClearPresence():Void {}

	static function Respond(userID:String, reply:DiscordActivityJoinRequestReply):Void {}

	static function UpdateHandlers(handlers:DiscordEventHandlers):Void {}
}

@:publicFields
private class RPCEventHandlers {
	var ready:(userID:hl.Bytes, username:hl.Bytes, globalName:hl.Bytes, discriminator:hl.Bytes, avatar:hl.Bytes, premiumType:DiscordPremiumType,
		bot:Bool) -> Void;
	var disconnected:(errorCode:Int, message:hl.Bytes) -> Void;
	var errored:(errorCode:Int, message:hl.Bytes) -> Void;
	var joinGame:(joinSecret:hl.Bytes) -> Void;
	var spectateGame:(spectateSecret:hl.Bytes) -> Void;
	var joinRequest:(userID:hl.Bytes, username:hl.Bytes, globalName:hl.Bytes, discriminator:hl.Bytes, avatar:hl.Bytes, premiumType:DiscordPremiumType,
		bot:Bool) -> Void;

	function new() {}
}

@:publicFields
@:hlNative('discord_rpc')
private class Discord_RPC {
	static function register(applicationID:String, command:String):Void {}

	static function register_steam_game(applicationID:String, steamID:String):Void {}

	static function initialize(applicationID:String, handlers:RPCEventHandlers, autoRegister:Int, optionalSteamID:String):Void {}

	static function shutdown():Void {}

	static function run_callbacks():Void {}

	#if DISCORD_DISABLE_IO_THREAD
	static function update_connection():Void {}
	#end
}
