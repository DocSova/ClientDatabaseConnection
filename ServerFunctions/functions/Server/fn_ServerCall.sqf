//_myInfo = ["keycode",params] call Dr_fnc_SendCallback;
if (isNil "CallbackRecieved") then {CallbackRecieved = 0};
diag_log format ["CURRENT PINGS: %1",CallbackRecieved];
waitUntil {(CallbackRecieved < 50)};

_call 	= param [0,""];
_params = param [1,[]];

CallbackRecieved 	= CallbackRecieved + 1;
_sender 		= remoteExecutedOwner;
_return 		= [];
_calltype 		= "";

switch (_call) do {
	case "ping" : {
		_return = "pong!";
	};
	case "client_getapikey": {
		_queryID 	= format["%1%2",round time, round random 100];
		_steamID 	= _params # 0;
		_actionID 	= _params # 1;

		_query = format["apiCalls_insert:%1:%2:%3",str(_queryID),_actionID,str(_steamID)];
		[_query, 1] call Dr_fnc_extdb3_asyncCall;
		_return = _queryID;
	};
	default {};
};
missionNamespace setVariable [format["RPCAnswer_%1",_call],_return,_sender];
CallbackRecieved = CallbackRecieved - 1;