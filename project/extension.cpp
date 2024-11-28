#define HL_NAME(n) hlhxdiscord_rpc_##n
#include "hl.h"
#include <cstring>
#include <iostream>
#include "discord_rpc.hpp"

// uhh ok c++ formatter
#define _HANDLERS _OBJ(                                        \
	_FUN(_VOID, _BYTES _BYTES _BYTES _BYTES _BYTES _I32 _BOOL) \
		_FUN(_VOID, _I32 _BYTES)                               \
			_FUN(_VOID, _I32 _BYTES)                           \
				_FUN(_VOID, _BYTES)                            \
					_FUN(_VOID, _BYTES)                        \
						_FUN(_VOID, _BYTES _BYTES _BYTES _BYTES _BYTES _I32 _BOOL))

typedef struct
{
	hl_type *t;
	vclosure *ready;
	vclosure *disconnected;
	vclosure *errored;
	vclosure *joinGame;
	vclosure *spectateGame;
	vclosure *joinRequest;
} vhandlers;

vhandlers *haxeHandlers = nullptr;
DiscordEventHandlers *discordHandlers = nullptr;

void setHandlers(vhandlers *handlers)
{
	if (discordHandlers == nullptr)
		discordHandlers = new DiscordEventHandlers();

	// Reset the handlers
	std::memset(discordHandlers, 0, sizeof(DiscordEventHandlers));
	if (handlers != nullptr)
	{
		if (handlers->ready != nullptr)
			hl_remove_root(&handlers->ready);
		if (handlers->disconnected != nullptr)
			hl_remove_root(&handlers->disconnected);
		if (handlers->errored != nullptr)
			hl_remove_root(&handlers->errored);
		if (handlers->joinGame != nullptr)
			hl_remove_root(&handlers->joinGame);
		if (handlers->spectateGame != nullptr)
			hl_remove_root(&handlers->spectateGame);
		if (handlers->joinRequest != nullptr)
			hl_remove_root(&handlers->joinRequest);
	}

	haxeHandlers = handlers;
	if (haxeHandlers->ready != nullptr)
	{
		hl_add_root(haxeHandlers->ready);
		discordHandlers->ready = [](const DiscordUser *request)
		{
			vdynamic args[7];
			vdynamic *vargs[7] = {
				&args[0],
				&args[1],
				&args[2],
				&args[3],
				&args[4],
				&args[5],
				&args[6]};

			args[0].t = &hlt_bytes;
			args[0].v.bytes = (vbyte *)request->userId;
			args[1].t = &hlt_bytes;
			args[1].v.bytes = (vbyte *)request->username;
			args[2].t = &hlt_bytes;
			args[2].v.bytes = (vbyte *)request->globalName;
			args[3].t = &hlt_bytes;
			args[3].v.bytes = (vbyte *)request->discriminator;
			args[4].t = &hlt_bytes;
			args[4].v.bytes = (vbyte *)request->avatar;
			args[5].t = &hlt_i32;
			args[5].v.i = (int)request->premiumType;
			args[6].t = &hlt_bool;
			args[6].v.i = (bool)request->bot;
			hl_dyn_call(haxeHandlers->ready, vargs, 7);
		};
	}
}

HL_PRIM void HL_NAME(register)(vstring *applicationID, vstring *command)
{
	Discord_Register((const char *)hl_to_utf8(applicationID->bytes), (const char *)hl_to_utf8(command->bytes));
}

HL_PRIM void HL_NAME(register_steam_game)(vstring *applicationID, vstring *command)
{
	Discord_RegisterSteamGame((const char *)hl_to_utf8(applicationID->bytes), (const char *)hl_to_utf8(command->bytes));
}

HL_PRIM void HL_NAME(initialize)(vstring *applicationID, vhandlers *handlers, int autoRegister, vstring *optionalSteamID)
{
	setHandlers(handlers);
	Discord_Initialize((const char *)hl_to_utf8(applicationID->bytes), discordHandlers, autoRegister, (const char *)hl_to_utf8(optionalSteamID->bytes));
}

HL_PRIM void HL_NAME(shutdown)()
{
	Discord_Shutdown();
}

HL_PRIM void HL_NAME(run_callbacks)()
{
	Discord_RunCallbacks();
}

#ifdef DISCORD_DISABLE_IO_THREAD
HL_PRIM void HL_NAME(update_connection)()
{
	Discord_UpdateConnection();
}
#endif

DEFINE_PRIM(_VOID, register, _STRING _STRING)
DEFINE_PRIM(_VOID, register_steam_game, _STRING _STRING)
DEFINE_PRIM(_VOID, initialize, _STRING _HANDLERS _I32 _STRING)
DEFINE_PRIM(_VOID, shutdown, _NO_ARG)
DEFINE_PRIM(_VOID, run_callbacks, _NO_ARG)
#ifdef DISCORD_DISABLE_IO_THREAD
DEFINE_PRIM(_VOID, update_connection, _NO_ARG)
#endif