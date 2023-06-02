_puid = "76561198111429009"; //offline puid is incorrect
_key = ["client_getapikey",[_puid, 1]] call Dr_fnc_SendCallback;
_data = [_key,[str(_puid)]] call Dr_fnc_APICall;
hint str _data;