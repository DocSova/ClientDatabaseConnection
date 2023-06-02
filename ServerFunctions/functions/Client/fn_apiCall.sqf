params [["_key",""],["_data",[]],["_waitForResult",false]];

_formattedData = "";
{
	_formattedData = _formattedData + format["%1",_x];
	if (_forEachIndex != (count _data) - 1) then {
		_formattedData = _formattedData + ";";
	};
} forEach _data;
diag_log format["API CALL: Key: %1, Data: %2",_key,_formattedData];

_return = [];
_result = "ClientConnection" callExtension format["1:%1:%2",_key,_formattedData];

if (_result == "") exitWith {
	diag_log("API CALL ERROR! Can't find a module!");
	_return
};

diag_log(_result);

for "_i" from 0 to 1 step 0 do {
	_result = "ClientConnection" callExtension format["2:%1",_key];
	if (_result != "NoData") exitWith {};
	UiSleep 0.001;
};

_return = parseSimpleArray _result;
diag_log format["API CALL RESULT: Key: %1, Data: %2",_key,_return];

_return
