#include <amxmodx>
#include <amxmisc>
#include <cromchat>
#include <fun>

/* Администраторският флаг */
#define ADMIN_FLAG "e"

/* Команда в конзолата. Сложете // в началото на реда за да я изключите */
new const CONSOLE_COMMAND[] = "amx_gravity"

/* Команда в чата. Сложете // в началото на реда за да я изключите */
new const CHAT_COMMAND[] = "/gravity"

/* Дали командата да може да се ползва върху себе си (true = да; false = не) */
new const bool:USE_ON_SELF = true

/* Префикс преди командата. Сложете // в началото на реда за да го изключите */
new const COMMAND_PREFIX[] = "&x04[AMXX]"

/* --- Край на настройките --- */

#define PLUGIN_VERSION "1.0"
new ADMIN_FLAG_BIT

public plugin_init()
{
	register_plugin("Gravity command", PLUGIN_VERSION, "OciXCrom @ amxx-bg.info")
	register_cvar("CRXCMD_Gravity", PLUGIN_VERSION, FCVAR_SERVER|FCVAR_SPONLY|FCVAR_UNLOGGED)
	ADMIN_FLAG_BIT = read_flags(ADMIN_FLAG)
	
	#if defined CONSOLE_COMMAND
	register_concmd(CONSOLE_COMMAND, "Cmd_Main", ADMIN_FLAG_BIT, "<nick|#userid> <gravity amount>")
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
	if(!cmd_access(id, iLevel, iCid, 3))
		return PLUGIN_HANDLED
		
	new szPlayer[32], szAmount[8]
	read_argv(1, szPlayer, charsmax(szPlayer))
	read_argv(2, szAmount, charsmax(szAmount))
	DoAction(id, szPlayer, szAmount)
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
		new szPlayer[32], szAmount[8]
		parse(szArgs, szArgs, charsmax(szArgs), szPlayer, charsmax(szPlayer), szAmount, charsmax(szAmount))
		DoAction(id, szPlayer, szAmount)
		return PLUGIN_HANDLED
	}
	
	@END:
	return PLUGIN_CONTINUE
}
#endif

stock DoAction(id, szPlayer[], szAmount[])
{
	new iPlayer = cmd_target(id, szPlayer, CMDTARGET_ONLY_ALIVE)
	
	if(!iPlayer)
		return PLUGIN_HANDLED
	
	if(!is_str_num(szAmount))
	{
		CC_SendMessage(id, "Invalid gravity amount: &x07%s", szAmount)
		return PLUGIN_HANDLED
	}
	
	new iAmount = str_to_num(szAmount)
		
	if(id == iPlayer && !USE_ON_SELF)
	{
		CC_SendMessage(id, "You can't use this command on yourself!")
		return PLUGIN_HANDLED
	}
	
	set_user_gravity(iPlayer, float(iAmount) / 800.0)
	
	new szName[2][32]
	get_user_name(id, szName[0], charsmax(szName[]))
	get_user_name(iPlayer, szName[1], charsmax(szName[]))
	
	CC_LogMessage(0, _, "ADMIN &x03%s &x01set gravity &x04%i &x01on &x03%s", szName[0], iAmount, szName[1])
	return PLUGIN_CONTINUE
}
