class CfgPatches
{
	class ServerFunctions
	{
		units[] = {};
		weapons[] = {};
		requiredAddons[] = {"A3_characters_F","A3_Data_F"};
	};
};

class CfgFunctions
{
	class Dr
	{
		class Server
		{
            file = "ServerFunctions\functions\Server";

            class serverCall {}; //Функция, принимающая коллбек с клиента и отправляющая обратно результат
            class extdb3_asyncCall {};
            class extdb3_init {
                postInit = 1;
            };
        };
        
        class Client 
        {
            file = "ServerFunctions\functions\Client";

            class sendCallback {}; //Отправка коллбека на сервер
            class test {}; //Тест коллбеков
            class apiCall {};
        };
    };
};