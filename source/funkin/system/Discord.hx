package funkin.system;

#if (desktop && cpp)
import Sys.sleep;
import discord_rpc.DiscordRpc as DiscordRPC;
import discord_rpc.DiscordRpc.DiscordPresenceOptions;

using StringTools;

// all images that i upload to the main discord app will be updated here.
// this lets you use vscode intellisense to tab to the image you want
class ArtAssets
{
	public static var icon:String = 'icon';
	public static var options:String = 'options';
}

class Discord
{
	public static var isInitialized:Bool = false;
	private static var instance:Discord;

	public function new()
	{
		#if desktop
		Funkin.log("DiscordRPC starting...");
		DiscordRPC.start({
			clientID: "1079989955201339442",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected,
		});
		Funkin.log("DiscordRPC started.");

		while (true)
		{
			DiscordRPC.process();
			sleep(2);
		}

		DiscordRPC.shutdown();
		#end
	}

	public static function shutdown()
	{
		#if desktop
		DiscordRPC.shutdown();
		#end
	}

	static function onReady()
	{
		#if desktop
		DiscordRPC.presence({});
		#end
	}

	static function onError(_code:Int, _message:String)
	{
		Funkin.log('DiscordRPC Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		Funkin.log('DiscordRPC Disconnected! $_code : $_message');
	}

	private static var discordDaemon:sys.thread.Thread;

	public static function initialize()
	{
		#if desktop
		discordDaemon = sys.thread.Thread.create(() ->
		{
			instance = new Discord();
		});
		Funkin.log("DiscordRPC initialized");
		isInitialized = true;
		#end
	}

	public static function setStatus(status:DiscordPresenceOptions)
	{
		#if desktop
		DiscordRPC.presence(status);
		#end
	}
}
#end
