#define DATABASE_NAME "Database"


private _protocols = ["custom"];

if (isNil {uiNamespace getVariable format["%1_protocolID",_protocols # 0]}) then
{

	private _ret = "extDB3" callExtension "9:VERSION";
	if(_ret == "") exitWith { diag_log "extDB3: Initialization failed" };
	diag_log format ["extDB3 - Version %1", _ret];

	_ret = parseSimpleArray ("extDB3" callExtension format["9:ADD_DATABASE:%1", DATABASE_NAME]);
	if (_ret # 0 == 0) exitWith { diag_log format ["extDB3 - Database error %1", _ret] };
	diag_log "extDB3 - Database connected";


	{
		private _max = 100000 * (_forEachIndex + 1);
		private _num = round(random [100000 * _forEachIndex,_max / 2,_max]);
		private _protocol = format["%1_protocolID",_x];

		missionNamespace setVariable [_protocol,compileFinal str _num];
		_ret = parseSimpleArray ("extDB3" callExtension format["9:ADD_DATABASE_PROTOCOL:%1:SQL_CUSTOM:%2:%3.ini", DATABASE_NAME, _num,_x]);
		if (_ret # 0 == 0) exitWith {diag_log format ["extDB3 - Database error %1", _ret]};

		uiNamespace setVariable [_protocol,_num];
	} forEach _protocols;

	diag_log "extDB3 - Custom protocol added";

	"extDB3" callExtension "9:LOCK";
	diag_log "extDB3 - Database locked";
}
else
{
	{
		_protocol = format["%1_protocolID",_x];
		missionNamespace setVariable [_protocol,compileFinal str (uiNamespace getVariable _protocol)]
	} forEach _protocols;
	diag_log "extDB3 - Database already connected";
};
