# hashcord

Haxe/HL bindings for `discord_rpc` based on [hldiscord_rpc](https://github.com/D-electra/hldiscord_rpc) and [hxdiscord_rpc](https://github.com/MAJigsaw77/hxdiscord_rpc/)

> [!WARNING]
> Discord Buttons do not currently work, and these bindings are somewhat unreliable.

## Setup

- Install `hashcord` with `haxelib install hashcord`
- `cd` into `project` and run `haxelib run hxcpp Build.xml` (with `-DDISCORD_DISABLE_IO_THREAD` if used on the Haxe side)
- Copy `discord_rpc.hdll` from `project/out` and drop it into your application directory

### Sample

```ts
package;

import sys.thread.Thread;
import hashcord.Discord;

class Main {
	static function main() {
		var handlers = new DiscordEventHandlers();
		handlers.ready = request -> {
			trace('CONNECTED: ${request.username}#${request.discriminator} (${request.globalName})');

			var presence = new DiscordRichPresence();
			presence.state = "STATE";
			presence.details = "DETAILS";
			// presence.largeImageKey = "icon";
			presence.startTimestamp = Std.int(Date.now().getTime() * 0.001);
			Discord.UpdatePresence(presence);
		}
		handlers.disconnected = (errorCode, message) -> {
			trace('DISCONNECTED: code $errorCode message $message');
		}
		handlers.errored = (errorCode, message) -> {
			trace('ERROR: code $errorCode message $message');
		}

		//PUT YOUR ID HERE
		var ID:String = "";
		Discord.Initialize(ID, handlers, 1, null);
		Thread.create(() -> {
			while (true) {
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();
				Sys.sleep(3);
			}
		});

		Sys.sleep(30);
		trace('rpc shutdown');
		Discord.Shutdown();
	}
}

```
