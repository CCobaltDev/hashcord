#define HL_NAME(n) hlhxdiscord_rpc_##n
#include "hl.h"
#include <iostream>
#include "discord_rpc.hpp"

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
	if (handlers->ready != nullptr)
	{
		hl_add_root(handlers->ready);
		discordHandlers->ready = [](const DiscordUser *request) {

		};
	}
}

HL_PRIM void HL_NAME(Initialize)(vstring *applicationID, vhandlers *handlers, int autoRegister, vstring *optionalSteamID)
{
	setHandlers(handlers);
	Discord_Initialize(hl_to_utf8(applicationID->bytes), discordHandlers, autoRegister, hl_to_utf8(optionalSteamID->bytes));
}