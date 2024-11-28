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

#define _PRESENCE _OBJ(                                                 \
	_I32                                                                \
		_STRING                                                         \
			_STRING                                                     \
				_I64                                                    \
					_I64                                                \
						_STRING                                         \
							_STRING                                     \
								_STRING                                 \
									_STRING                             \
										_STRING                         \
											_I32                        \
												_I32                    \
													_I32                \
														_STRING         \
															_STRING     \
																_STRING \
																	_BOOL)

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

typedef struct
{
	hl_type *t;
	DiscordActivityType type;
	vstring *state;
	vstring *details;
	int64_t startTimestamp;
	int64_t endTimestamp;
	vstring *largeImageKey;
	vstring *largeImageText;
	vstring *smallImageKey;
	vstring *smallImageText;
	vstring *partyID;
	int partySize;
	int partyMax;
	DiscordActivityPartyPrivacy partyPrivacy;
	// todo buttons
	vstring *matchSecret;
	vstring *joinSecret;
	vstring *spectateSecret;
	bool instance;
} vpresence;

vhandlers *haxeHandlers = nullptr;
DiscordEventHandlers *discordHandlers = nullptr;
DiscordRichPresence *discordPresence = nullptr;

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
		hl_add_root(&haxeHandlers->ready);
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

	if (haxeHandlers->disconnected != nullptr)
	{
		hl_add_root(&haxeHandlers->disconnected);
		discordHandlers->disconnected = [](int errorCode, const char *message)
		{
			vdynamic args[2];
			vdynamic *vargs[2] = {
				&args[0],
				&args[1]};

			args[0].t = &hlt_i32;
			args[0].v.i = errorCode;
			args[1].t = &hlt_bytes;
			args[1].v.bytes = (vbyte *)message;
			hl_dyn_call(haxeHandlers->disconnected, vargs, 2);
		};
	}

	if (haxeHandlers->errored != nullptr)
	{
		hl_add_root(&haxeHandlers->errored);
		discordHandlers->errored = [](int errorCode, const char *message)
		{
			vdynamic args[2];
			vdynamic *vargs[2] = {
				&args[0],
				&args[1]};

			args[0].t = &hlt_i32;
			args[0].v.i = errorCode;
			args[1].t = &hlt_bytes;
			args[1].v.bytes = (vbyte *)message;
			hl_dyn_call(haxeHandlers->errored, vargs, 2);
		};
	}

	if (haxeHandlers->joinGame != nullptr)
	{
		hl_add_root(&haxeHandlers->joinGame);
		discordHandlers->joinGame = [](const char *joinSecret)
		{
			vdynamic args[1];
			vdynamic *vargs[1] = {&args[0]};

			args[1].t = &hlt_bytes;
			args[1].v.bytes = (vbyte *)joinSecret;
			hl_dyn_call(haxeHandlers->joinGame, vargs, 1);
		};
	}

	if (haxeHandlers->spectateGame != nullptr)
	{
		hl_add_root(&haxeHandlers->spectateGame);
		discordHandlers->spectateGame = [](const char *spectateSecret)
		{
			vdynamic args[1];
			vdynamic *vargs[1] = {&args[0]};

			args[1].t = &hlt_bytes;
			args[1].v.bytes = (vbyte *)spectateSecret;
			hl_dyn_call(haxeHandlers->spectateGame, vargs, 1);
		};
	}

	if (haxeHandlers->joinRequest != nullptr)
	{
		hl_add_root(&haxeHandlers->joinRequest);
		discordHandlers->joinRequest = [](const DiscordUser *request)
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
			hl_dyn_call(haxeHandlers->joinRequest, vargs, 7);
		};
	}
}

void setPresence(vpresence *presence)
{
	if (discordPresence == nullptr)
		discordPresence = new DiscordRichPresence();

	std::memset(discordPresence, 0, sizeof(DiscordRichPresence));

	discordPresence->type = presence->type;
	if (presence->state != nullptr)
		discordPresence->state = (const char *)hl_to_utf8(presence->state->bytes);
	if (presence->details != nullptr)
		discordPresence->details = (const char *)hl_to_utf8(presence->details->bytes);
	discordPresence->startTimestamp = presence->startTimestamp;
	discordPresence->endTimestamp = presence->endTimestamp;
	if (presence->largeImageKey != nullptr)
		discordPresence->largeImageKey = (const char *)hl_to_utf8(presence->largeImageKey->bytes);
	if (presence->largeImageText != nullptr)
		discordPresence->largeImageText = (const char *)hl_to_utf8(presence->largeImageText->bytes);
	if (presence->smallImageKey != nullptr)
		discordPresence->smallImageKey = (const char *)hl_to_utf8(presence->smallImageKey->bytes);
	if (presence->smallImageText != nullptr)
		discordPresence->smallImageText = (const char *)hl_to_utf8(presence->smallImageText->bytes);
	if (presence->partyID != nullptr)
		discordPresence->partyId = (const char *)hl_to_utf8(presence->partyID->bytes);
	discordPresence->partySize = presence->partySize;
	discordPresence->partyMax = presence->partyMax;
	discordPresence->partyPrivacy = presence->partyPrivacy;
	if (presence->matchSecret != nullptr)
		discordPresence->matchSecret = (const char *)hl_to_utf8(presence->matchSecret->bytes);
	if (presence->joinSecret != nullptr)
		discordPresence->joinSecret = (const char *)hl_to_utf8(presence->joinSecret->bytes);
	if (presence->spectateSecret != nullptr)
		discordPresence->spectateSecret = (const char *)hl_to_utf8(presence->spectateSecret->bytes);
	discordPresence->instance = presence->instance;
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
	delete discordHandlers;
	delete discordPresence;
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
#else
#pragma message("so im NOT insane")
#endif

HL_PRIM void HL_NAME(update_presence)(vpresence *presence)
{
	setPresence(presence);
	Discord_UpdatePresence(discordPresence);
}

HL_PRIM void HL_NAME(clear_presence)()
{
	Discord_ClearPresence();
}

HL_PRIM void HL_NAME(respond)(vstring *userID, DiscordActivityJoinRequestReply reply)
{
	Discord_Respond((const char *)hl_to_utf8(userID->bytes), reply);
}

HL_PRIM void HL_NAME(update_handlers)(vhandlers *handlers)
{
	setHandlers(handlers);
	Discord_UpdateHandlers(discordHandlers);
}

DEFINE_PRIM(_VOID, register, _STRING _STRING)
DEFINE_PRIM(_VOID, register_steam_game, _STRING _STRING)
DEFINE_PRIM(_VOID, initialize, _STRING _HANDLERS _I32 _STRING)
DEFINE_PRIM(_VOID, shutdown, _NO_ARG)
DEFINE_PRIM(_VOID, run_callbacks, _NO_ARG)
#ifdef DISCORD_DISABLE_IO_THREAD
DEFINE_PRIM(_VOID, update_connection, _NO_ARG)
#endif
DEFINE_PRIM(_VOID, update_presence, _PRESENCE)
DEFINE_PRIM(_VOID, clear_presence, _NO_ARG)
DEFINE_PRIM(_VOID, respond, _STRING _I32)
DEFINE_PRIM(_VOID, update_handlers, _HANDLERS)