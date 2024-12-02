package hashcord;

import haxe.Int64;
import hl.NativeArray;

enum abstract DiscordPremiumType(Int)
{
	var None;
	var NitroClassic;
	var Nitro;
	var NitroBasic;
}

enum abstract DiscordActivityPartyPrivacy(Int)
{
	var Private;
	var Public;
}

enum abstract DiscordActivityType(Int)
{
	var Playing = 0;
	var Listening = 1;
	var Watching = 3;
	var Competing = 5;
}

enum abstract DiscordActivityJoinRequestReply(Int)
{
	var No;
	var Yes;
	var Ignore;
}

@:publicFields
@:structInit
class DiscordRichPresence
{
	var type:DiscordActivityType = Playing;
	var state:String = '';
	var details:String = '';
	var startTimestamp:Int64 = 0i64;
	var endTimestamp:Int64 = 0i64;
	var largeImageKey:String = '';
	var largeImageText:String = '';
	var smallImageKey:String = '';
	var smallImageText:String = '';
	var partyID:String = '';
	var partySize:Int = 0;
	var partyMax:Int = 0;
	var partyPrivacy:DiscordActivityPartyPrivacy = Private;
	var buttons = new Array<DiscordButton>();
	var matchSecret:String = '';
	var joinSecret:String = '';
	var spectateSecret:String = '';
	var instance:Bool = false;

	function new() {}
}

@:publicFields
@:structInit
class DiscordUser
{
	var userID:String;
	var username:String;
	var globalName:String;
	var discriminator:String;
	var avatar:String;
	var premiumType:DiscordPremiumType;
	var bot:Bool;
}

@:publicFields
@:structInit
class DiscordEventHandlers
{
	var ready:(request:DiscordUser) -> Void = null;
	var disconnected:(errorCode:Int, message:String) -> Void = null;
	var errored:(errorCode:Int, message:String) -> Void = null;
	var joinGame:(joinSecret:String) -> Void = null;
	var spectateGame:(spectateSecret:String) -> Void = null;
	var joinRequest:(request:DiscordUser) -> Void = null;

	function new() {}
}

@:publicFields
@:structInit
class DiscordButton
{
	var label:String = '';
	var url:String = '';

	function new() {}
}

@:publicFields
class Discord
{
	static inline function Register(applicationID:String, command:String):Void
	{
		Discord_RPC.register(applicationID, command);
	}

	static inline function RegisterSteamGame(applicationID:String, steamID:String):Void
	{
		Discord_RPC.register_steam_game(applicationID, steamID);
	}

	static inline function Initialize(applicationID:String, handlers:DiscordEventHandlers, autoRegister:Int = 1, optionalSteamID:String = ""):Void
	{
		Discord_RPC.initialize(applicationID, handlersHelper(handlers), autoRegister, optionalSteamID);
	}

	static inline function Shutdown():Void
	{
		Discord_RPC.shutdown();
	}

	static inline function RunCallbacks():Void
	{
		Discord_RPC.run_callbacks();
	}

	#if DISCORD_DISABLE_IO_THREAD
	static inline function UpdateConnection():Void
	{
		Discord_RPC.update_connection();
	}
	#end

	static inline function UpdatePresence(presence:DiscordRichPresence):Void
	{
		Discord_RPC.update_presence(presenceHelper(presence));
	}

	static inline function ClearPresence():Void
	{
		Discord_RPC.clear_presence();
	}

	static inline function Respond(userID:String, reply:DiscordActivityJoinRequestReply):Void
	{
		Discord_RPC.respond(userID, reply);
	}

	static inline function UpdateHandlers(handlers:DiscordEventHandlers):Void
	{
		Discord_RPC.update_handlers(handlersHelper(handlers));
	}

	@:noCompletion private static function handlersHelper(handlers:DiscordEventHandlers):NativeEventHandlers
	{
		var nativeHandlers = new NativeEventHandlers();
		if (handlers.ready != null)
			nativeHandlers.ready = (userID, username, globalName, discriminator, avatar, premiumType, bot) -> @:privateAccess handlers.ready({
				userID: String.fromUTF8(userID),
				username: String.fromUTF8(username),
				globalName: String.fromUTF8(globalName),
				discriminator: String.fromUTF8(discriminator),
				avatar: String.fromUTF8(avatar),
				premiumType: premiumType,
				bot: bot
			});

		if (handlers.disconnected != null)
			nativeHandlers.disconnected = (errorCode, message) -> @:privateAccess handlers.disconnected(errorCode, String.fromUTF8(message));
		if (handlers.errored != null)
			nativeHandlers.errored = (errorCode, message) -> @:privateAccess handlers.errored(errorCode, String.fromUTF8(message));
		if (handlers.joinGame != null)
			nativeHandlers.joinGame = joinSecret -> @:privateAccess handlers.joinGame(String.fromUTF8(joinSecret));
		if (handlers.spectateGame != null)
			nativeHandlers.spectateGame = spectateSecret -> @:privateAccess handlers.spectateGame(String.fromUTF8(spectateSecret));

		if (handlers.joinRequest != null)
			nativeHandlers.joinRequest = (userID, username, globalName, discriminator, avatar, premiumType, bot) -> @:privateAccess handlers.joinRequest({
				userID: String.fromUTF8(userID),
				username: String.fromUTF8(username),
				globalName: String.fromUTF8(globalName),
				discriminator: String.fromUTF8(discriminator),
				avatar: String.fromUTF8(avatar),
				premiumType: premiumType,
				bot: bot
			});
		return nativeHandlers;
	}

	@:noCompletion private static function presenceHelper(presence:DiscordRichPresence):NativeRichPresence
	{
		var nativePresence = new NativeRichPresence();
		nativePresence.type = presence.type;
		nativePresence.state = presence.state;
		nativePresence.details = presence.details;
		nativePresence.startTimestamp = presence.startTimestamp;
		nativePresence.endTimestamp = presence.endTimestamp;
		nativePresence.largeImageKey = presence.largeImageKey;
		nativePresence.largeImageText = presence.largeImageText;
		nativePresence.smallImageKey = presence.smallImageKey;
		nativePresence.smallImageText = presence.smallImageText;
		nativePresence.partyID = presence.partyID;
		nativePresence.partySize = presence.partySize;
		nativePresence.partyMax = presence.partyMax;
		nativePresence.partyPrivacy = presence.partyPrivacy;
		for (i in 0...presence.buttons.length)
			nativePresence.buttons[i] = presence.buttons[i];
		nativePresence.matchSecret = presence.matchSecret;
		nativePresence.joinSecret = presence.joinSecret;
		nativePresence.spectateSecret = presence.spectateSecret;
		nativePresence.instance = presence.instance;
		return nativePresence;
	}
}

@:noCompletion
@:publicFields
private class NativeEventHandlers
{
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

@:noCompletion
@:publicFields
private class NativeRichPresence
{
	var type:DiscordActivityType = Playing;
	var state:String;
	var details:String;
	var startTimestamp:Int64 = 0i64;
	var endTimestamp:Int64 = 0i64;
	var largeImageKey:String;
	var largeImageText:String;
	var smallImageKey:String;
	var smallImageText:String;
	var partyID:String;
	var partySize:Int = 0;
	var partyMax:Int = 0;
	var partyPrivacy:DiscordActivityPartyPrivacy = Private;
	var buttons = new NativeArray<DiscordButton>(2);
	var matchSecret:String;
	var joinSecret:String;
	var spectateSecret:String;
	var instance:Bool = false;

	function new() {}
}

@:publicFields
@:hlNative('discord_rpc')
private class Discord_RPC
{
	static function register(applicationID:String, command:String):Void {}

	static function register_steam_game(applicationID:String, steamID:String):Void {}

	static function initialize(applicationID:String, handlers:NativeEventHandlers, autoRegister:Int, optionalSteamID:String):Void {}

	static function shutdown():Void {}

	static function run_callbacks():Void {}

	#if DISCORD_DISABLE_IO_THREAD
	static function update_connection():Void {}
	#end

	static function update_presence(presence:NativeRichPresence):Void {}

	static function clear_presence():Void {}

	static function respond(userID:String, reply:DiscordActivityJoinRequestReply):Void {}

	static function update_handlers(handlers:NativeEventHandlers):Void {}
}
