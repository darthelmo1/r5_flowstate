untyped																					//~mkos

#if TRACKER && HAS_TRACKER_DLL
//////////////////////////////
// INTERNAL STATS FUNCTIONS //
//////////////////////////////

global function Stats__AddPlayerStatsTable
global function Stats__GenerateOutBoundJsonData
global function Stats__RegisterStatOutboundData
global function Stats__SetStatKeys

global function GetPlayerStatInt
global function GetPlayerStatString
global function GetPlayerStatBool
global function GetPlayerStatFloat

global function SetPlayerStatInt
global function SetPlayerStatString
global function SetPlayerStatBool
global function SetPlayerStatFloat

struct
{
	table< string, table<string, var> > allStatsTables
	array<string> statKeys
	
	table< string, var functionref( string UID )> registeredStatOutboundValues

} file

void function Stats__SetStatKeys( array<string> keys )
{
	file.statKeys = keys
}

array<string> function Stats__AddPlayerStatsTable( string player_oid ) 
{
	var rawStatsTable = GetPlayerStats__internal( player_oid )
	array<string> statKeys = []
	
	if ( typeof rawStatsTable == "table" && rawStatsTable.len() > 0 ) 
	{
		table<string, var> statsTable = {}

        foreach ( key, value in rawStatsTable )
        {
            statsTable[ expect string( key ) ] <- value;
			statKeys.append( expect string( key ) )
        }
		
		file.allStatsTables[ player_oid ] <- statsTable
	}
	
	return statKeys
}

int function GetPlayerStatInt( string player_oid, string statname ) 
{
	if ( player_oid in file.allStatsTables && statname in file.allStatsTables[ player_oid ] ) 
	{
		return expect int( file.allStatsTables[ player_oid ][ statname ] )
	}
	
	return 0
}

string function GetPlayerStatString( string player_oid, string statname ) 
{
	if ( player_oid in file.allStatsTables && statname in file.allStatsTables[ player_oid ] ) 
	{
		return expect string( file.allStatsTables[ player_oid ][ statname ] )
	}
	
	return ""
}

bool function GetPlayerStatBool( string player_oid, string statname ) 
{
	if ( player_oid in file.allStatsTables && statname in file.allStatsTables[ player_oid ] ) 
	{
		return expect bool( file.allStatsTables[ player_oid ][ statname ] )
	}
	
	return false
}

float function GetPlayerStatFloat( string player_oid, string statname ) 
{
	if ( player_oid in file.allStatsTables && statname in file.allStatsTables[ player_oid ] ) 
	{
		return expect float( file.allStatsTables[ player_oid ][ statname ] )
	}
	return 0.0
}

void function SetPlayerStatInt( string player_oid, string statname, int value ) 
{	
	if ( player_oid in file.allStatsTables && statname in file.allStatsTables[ player_oid ] ) 
	{
		file.allStatsTables[ player_oid ][ statname ] = value
	}
}

void function SetPlayerStatString( string player_oid, string statname, string value ) 
{
	#if DEVELOPER
		//This will be thrown out in the backend if exceeded.
		mAssert( value.len() <= 30, "Invalid string length for the value of statname \"" + statname + "\" value: \"" + value )
	#endif
	
	if ( player_oid in file.allStatsTables && statname in file.allStatsTables[ player_oid ] ) 
	{
		file.allStatsTables[ player_oid ][ statname ] = value
	}
}

void function SetPlayerStatBool( string player_oid, string statname, bool value ) 
{
	if ( player_oid in file.allStatsTables && statname in file.allStatsTables[ player_oid ] ) 
	{
		file.allStatsTables[ player_oid ][ statname ] = value
	}
}

void function SetPlayerStatFloat( string player_oid, string statname, float value ) 
{
	if ( player_oid in file.allStatsTables && statname in file.allStatsTables[ player_oid ] ) 
	{
		file.allStatsTables[ player_oid ][ statname ] = value
	}
}

// These are not handled by script registered stats and it is futile to send out, 
// as they will be dropped in the backend.
const array<string> IGNORE_STATS = 
[
	"player",
	"jumps",
	"settings",
	"total_time_played",
	"total_matches",
	"score"
]

array<string> function GenerateOutBoundDataList()
{
	array<string> generatedOutboundList = []
	
	foreach( key in file.statKeys )
	{
		if( !IGNORE_STATS.contains( key ) )
			generatedOutboundList.append( key )
	}
	
	return generatedOutboundList
}

string function Stats__GenerateOutBoundJsonData( string UID )
{
	string json = "";
	array<string> validOutBoundStats = GenerateOutBoundDataList()
	
	foreach( statKey in validOutBoundStats )
	{
		if( statKey in file.registeredStatOutboundValues )
		{		
			string vType = typeof( file.registeredStatOutboundValues[ statKey ]( UID ) )
			
			switch( vType )
			{
				case "string":
					json += "\"" + statKey + "\": \"" + expect string( file.registeredStatOutboundValues[ statKey ]( UID ) ) + "\", ";
					break 
				
				case "int":
					json += "\"" + statKey + "\": " + expect int( file.registeredStatOutboundValues[ statKey ]( UID ) ).tostring() + ", ";
					break
					
				case "float":
					json += "\"" + statKey + "\": " + expect float( file.registeredStatOutboundValues[ statKey ]( UID ) ).tostring() + ", ";
					break
				
				case "bool":
					json += "\"" + statKey + "\": " + expect bool( file.registeredStatOutboundValues[ statKey ]( UID ) ).tostring() + ", ";
			}
		}
	}
	
	return json
}

void function Stats__RegisterStatOutboundData( string statname, var functionref( string UID ) func )
{
	if( ( statname in file.registeredStatOutboundValues ) )
	{
		sqerror("Tried to add func " + string( func ) + "() as an outbound data func for [" + statname + "] but func " + string( file.registeredStatOutboundValues[statname] ) + "() is already defined to handle outbound data for stat.")
		return
	}
	
	file.registeredStatOutboundValues[ statname ] <- func
}
#else //TRACKER && HAS_TRACKER_DLL

global function GetPlayerStatInt
global function GetPlayerStatString
global function GetPlayerStatBool
global function GetPlayerStatFloat

global function SetPlayerStatInt
global function SetPlayerStatString
global function SetPlayerStatBool
global function SetPlayerStatFloat

int function GetPlayerStatInt( string player, string statname ){ return 0 }
string function GetPlayerStatString( string player, string statname ){ return "" }
bool function GetPlayerStatBool( string player, string statname ){ return false }
float function GetPlayerStatFloat( string player, string statname ){ return 0.0 }

void function SetPlayerStatInt( string player, string statname, int value ){}
void function SetPlayerStatString( string player, string statname, string value ){}
void function SetPlayerStatBool( string player, string statname, bool value ){}
void function SetPlayerStatFloat( string player, string statname, float value ){}

#endif // ELSE !TRACKER && !HAS_TRACKER_DLL