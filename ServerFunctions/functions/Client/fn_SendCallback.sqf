_scriptName = if (isNil "_thisScript") then {""} else {_thisScript};
private ["_return","_call","_namevar","_params","_time","_exit","_skipped"];
_return = "";
_call = param [0,str(round random 100)];
_params = param [1,[]];

_namevar = format ["RPCAnswer_%1",_call];
missionNamespace setVariable [_namevar,nil];
[_call,_params] remoteExec ["Dr_fnc_ServerCall", 2];
_time = time;
_skipped = false;

waitUntil {
	_return = missionNamespace getVariable [_namevar,nil];
	_exit = false;
	if (isNil "_return") then {_exit = false} else {_exit = true};
	if ((time - _time) > 30) then {_skipped = true; _exit = true};
	_exit
};
if (_skipped) then {
	diag_log format ["SKIPPED CALLBACK! NAME: %1 PARAMS: %2",_namevar,_params];
	_return = "CALLBACK_ERROR"
};
missionNamespace setVariable [_namevar,nil];
_return