#include <amxmodx>
#include <amxmisc>
#include <cromchat>
#include <fun>

/* The admin flag */
#define ADMIN_FLAG "e"

/* The console command. Put // in front to disable it */
new const CONSOLE_COMMAND[] = "amx_grab"

/* The chat command. Put // in front to disable it */
new const CHAT_COMMAND[] = "/grab"

/* Whether the command can be used on yourself (true = yes; false = no) */
new const bool:USE_ON_SELF = false

/* The chat prefix. Put // in front to disable it */
new const COMMAND_PREFIX[] = "&x04[AMXX]"

/* Teleport distance from player */
new const DISTANCE_FROM_PLAYER = 36

/* --- End of settings --- */

#define PLUGIN_VERSION "1.0"
new ADMIN_FLAG_BIT

public plugin_init()
{
	register_plugin("Grab command", PLUGIN_VERSION, "OciXCrom @ amxx-bg.info")
	register_cvar("CRXCMD_Grab", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	ADMIN_FLAG_BIT = read_flags(ADMIN_FLAG)
	
	#if defined CONSOLE_COMMAND
	register_concmd(CONSOLE_COMMAND, "Cmd_Main", ADMIN_FLAG_BIT, "<nick|#userid>")
	#endif
	
	#if defined CHAT_COMMAND
	register_clcmd("say", "Cmd_Say")
	register_clcmd("say_team", "Cmd_Say")
	#endif
	
	#if defined COMMAND_PREFIX
	CC_SetPrefix(COMMAND_PREFIX)
	#endif
}

#if defined CONSOLE_COMMAND
public Cmd_Main(id, iLevel, iCid)
{
	if(!cmd_access(id, iLevel, iCid, 2))
		return PLUGIN_HANDLED
		
	new szPlayer[32]
	read_argv(1, szPlayer, charsmax(szPlayer))
	DoAction(id, szPlayer)
	return PLUGIN_HANDLED
}
#endif

#if defined CHAT_COMMAND
public Cmd_Say(id)
{
	if(~get_user_flags(id) & ADMIN_FLAG_BIT)
		goto @END
		
	static szArgs[64]
	read_args(szArgs, charsmax(szArgs))
	remove_quotes(szArgs)
	
	if(equali(szArgs[0], CHAT_COMMAND, charsmax(CHAT_COMMAND)))
	{
		new szPlayer[32]
		parse(szArgs, szArgs, charsmax(szArgs), szPlayer, charsmax(szPlayer))
		DoAction(id, szPlayer)
		return PLUGIN_HANDLED
	}
	
	@END:
	return PLUGIN_CONTINUE
}
#endif

DoAction(id, szPlayer[])
{
	new iPlayer = cmd_target(id, szPlayer, CMDTARGET_ONLY_ALIVE)
	
	if(!iPlayer)
		return PLUGIN_HANDLED
		
	if(id == iPlayer && !USE_ON_SELF)
	{
		CC_SendMessage(id, "You can't use this command on yourself!")
		return PLUGIN_HANDLED
	}
	
	new iOrigin[3]
	get_user_origin(id, iOrigin)
	iOrigin[1] += DISTANCE_FROM_PLAYER
	set_user_origin(iPlayer, iOrigin)
	
	new szName[2][32]
	get_user_name(id, szName[0], charsmax(szName[]))
	get_user_name(iPlayer, szName[1], charsmax(szName[]))
	
	CC_LogMessage(0, _, "ADMIN &x03%s &x01grabbed &x03%s", szName[0], szName[1])
	return PLUGIN_CONTINUE
}
