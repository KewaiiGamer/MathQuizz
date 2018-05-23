/* [CS:GO] Knife Round
 *
 *  Copyright (C) 2018 Miguel 'Kewaii' Viegas
 * 
 * All Rights reserved
 */
#include <sourcemod>
#include <sdktools>
#include <store>
#include <multicolors>

#define PLUGIN_NAME 		"Math Quizz"
#define PLUGIN_DESCRIPTION 	"Give credits on correct math answer."
#define PLUGIN_AUTHOR 		"Kewaii"
#define PLUGIN_VERSION 		"1.0.1"
#define PLUGIN_TAG 			"{red}[{orange}MathQuizz by Kewaii{red}]{green}"
#define PLUS				"+"
#define MINUS				"-"
#define DIVISOR				"/"
#define MULTIPL				"*"

bool inQuizz;

char op[32];
char operators[4][5] = {"+", "-", "/", "*"};

int nbrmin;
int nbrmax;
int maxcredits;
int mincredits;
int questionResult;
int credits;

Handle timerQuestionEnd;
Handle CVAR_MinimumNumber;
Handle CVAR_MaximumNumber;
Handle CVAR_MaximumCredits;
Handle CVAR_MinimumCredits;
Handle CVAR_TimeBetweenQuestion;
Handle CVAR_TimeAnswer;

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/KewaiiGamer"
};
 
public void OnPluginStart()
{
	LoadTranslations("kewaii_mathquizz.phrases");
	RegAdminCmd("sm_math", Command_StartQuestion, ADMFLAG_ROOT);
	inQuizz = false;
	CVAR_MinimumNumber = CreateConVar("kewaii_mathquizz_minimum_number", "1", "What should be the minimum number for questions ?");
	CVAR_MaximumNumber = CreateConVar("kewaii_mathquizz_maximum_number", "100", "What should be the maximum number for questions ?");
	CVAR_MaximumCredits = CreateConVar("kewaii_mathquizz_maximum_credits", "50", "What should be the maximum number of credits earned for a correct answers ?");
	CVAR_MinimumCredits = CreateConVar("kewaii_mathquizz_minimum_credits", "5", "What should be the minimum number of credits earned for a correct answers ?");
	CVAR_TimeBetweenQuestion = CreateConVar("kewaii_mathquizz_time_between_questions", "50", "Time in seconds between each questions.");
	CVAR_TimeAnswer = CreateConVar("kewaii_mathquizz_time_answer_questions", "10", "Time in seconds to give a answer to a question.");
	AutoExecConfig(true, "MathQuizz");
}
public void OnMapStart()
{
	CreateTimer(GetConVarFloat(CVAR_TimeBetweenQuestion) + GetConVarFloat(CVAR_TimeAnswer), CreateQuestion, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Command_StartQuestion(int client, int args)
{
	CreateTimer(1.0, CreateQuestion, client);
	return Plugin_Handled;
}

public void OnConfigsExecuted()
{		
	nbrmin = GetConVarInt(CVAR_MinimumNumber);
	nbrmax = GetConVarInt(CVAR_MaximumNumber);
	maxcredits = GetConVarInt(CVAR_MaximumCredits);
	mincredits = GetConVarInt(CVAR_MinimumCredits);
}

public Action EndQuestion(Handle timer, any data)
{
	SendEndQuestion(-1);
}

public Action CreateQuestion(Handle timer, any data)
{
	int client = data;
	int nbr1 = GetRandomInt(nbrmin, nbrmax);
	int nbr2 = GetRandomInt(nbrmin, nbrmax);
	//int nbr3 = GetRandomInt(0, 10);
	credits = GetRandomInt(mincredits, maxcredits);
	
	Format(op, sizeof(op), operators[GetRandomInt(0,3)]);

	if(StrEqual(op, PLUS))
	{
		questionResult = nbr1 + nbr2;
	}
	else if(StrEqual(op, MINUS))
	{
		questionResult = nbr1 - nbr2;
	}
	else if(StrEqual(op, DIVISOR))
	{
		do{
			nbr1 = GetRandomInt(nbrmin, nbrmax);
			nbr2 = GetRandomInt(nbrmin, nbrmax);
		}
		while(nbr1 % nbr2 != 0);
		questionResult = nbr1 / nbr2;
	}
	else if(StrEqual(op, MULTIPL))
	{
		questionResult = nbr1 * nbr2;
	}
	CPrintToChatAll("%s %t", PLUGIN_TAG, "QuizzGenerated", nbr1, op, nbr2, credits);
	
	inQuizz = true;

	timerQuestionEnd = CreateTimer(GetConVarFloat(CVAR_TimeAnswer), EndQuestion, client);
}

public Action OnChatMessage(&author, Handle recipients, char[] name, char[] message)
{
	if(inQuizz)
	{
		char bit[1][5];
		ExplodeString(message, " ", bit, sizeof bit, sizeof bit[]);
		TrimString(bit[0]);
		ReplaceString(bit[0], sizeof(bit[]), "", "");
		int number = StringToInt(bit[0]);
		if(ProcessSolution(author, number))
			SendEndQuestion(author);
	}
}

public bool ProcessSolution(client, int number)
{
	if(questionResult == number)
	{
		Store_SetClientCredits(client, Store_GetClientCredits(client) + credits);

		return true;
	}
	else
	{
		return false;
	}
}

public void SendEndQuestion(int client)
{
	if(timerQuestionEnd != INVALID_HANDLE)
	{
		KillTimer(timerQuestionEnd);
		timerQuestionEnd = INVALID_HANDLE;
	}

	char answer[200], name[64];
	
	if(client != -1) 
	{
		GetClientName(client, name, sizeof(name));
		Format(answer, sizeof(answer), "%s %T", PLUGIN_TAG, "CorrectAnswer", client, name, credits);	
	}
	else 
	{	
		Format(answer, sizeof(answer), "NoAnswer");
	}

	Handle pack = CreateDataPack();
	CreateDataTimer(0.3, AnswerQuestion, pack);
	WritePackString(pack, answer);

	inQuizz = false;
}

public Action AnswerQuestion(Handle timer, Handle pack)
{
	char str[200];
	ResetPack(pack);
	ReadPackString(pack, str, sizeof(str));

	if (StrEqual(str, "NoAnswer")) {

		CPrintToChatAll("%s %t", PLUGIN_TAG, "NoAnswer", questionResult);
	}
	else {
		CPrintToChatAll(str);
	}
}