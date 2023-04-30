unit UnitCode_SQLite3API;

interface

uses
  Windows, SysUtils, UnitCode_CustomDynamicLibrary;


//  +function sqlite3_create_function(_para1:Psqlite3; zFunctionName:Pchar; nArg:longint; eTextRep:longint; _para5:pointer;        xFunc:create_function_func_func; xStep:create_function_step_func; xFinal:create_function_final_func):longint;cdecl; external Sqlite3Lib name 'sqlite3_create_function';
//   4.239 +function sqlite3_create_function16(_para1:Psqlite3; zFunctionName:pointer; nArg:longint; eTextRep:longint; _para5:pointer;            xFunc:create_function_func_func; xStep:create_function_step_func; xFinal:create_function_final_func):longint;cdecl; external Sqlite3Lib name 'sqlite3_create_function16';
//
//
//   4.138 +  sqlite3_callback = function (_para1:pointer; _para2:longint; _para3:PPchar; _para4:PPchar):longint;cdecl;
//   4.139 +  busy_handler_func = function (_para1:pointer; _para2:longint):longint;cdecl;
//   4.140 +  sqlite3_set_authorizer_func = function (_para1:pointer; _para2:longint; _para3:Pchar; _para4:Pchar; _para5:Pchar; _para6:Pchar):longint;cdecl;
//   4.141 +  sqlite3_trace_func = procedure (_para1:pointer; _para2:Pchar);cdecl;
//   4.142 +  sqlite3_progress_handler_func = function (_para1:pointer):longint;cdecl;
//   4.143 +  sqlite3_commit_hook_func = function (_para1:pointer):longint;cdecl;
//   4.144 +  bind_destructor_func = procedure (_para1:pointer);cdecl;

//   4.145 +  create_function_step_func = procedure (_para1:Psqlite3_context; _para2:longint; _para3:PPsqlite3_value);cdecl;
//   4.146 +  create_function_func_func = procedure (_para1:Psqlite3_context; _para2:longint; _para3:PPsqlite3_value);cdecl;
//   4.147 +  create_function_final_func = procedure (_para1:Psqlite3_context);cdecl;

//   4.148 +  sqlite3_set_auxdata_func = procedure (_para1:pointer);cdecl;
//   4.149 +  sqlite3_result_func = procedure (_para1:pointer);cdecl;
//   4.150 +  sqlite3_create_collation_func = function (_para1:pointer; _para2:longint; _para3:pointer; _para4:longint; _para5:pointer):longint;cdecl;
//   4.151 +  sqlite3_collation_needed_func = procedure (_para1:pointer; _para2:Psqlite3; eTextRep:longint; _para4:Pchar);cdecl;

const
  SQLITE_OK         =  0;   // Successful result
  SQLITE_ERROR      =  1;   // SQL error or missing database
  SQLITE_INTERNAL   =  2;   // An internal logic error in SQLite
  SQLITE_PERM       =  3;   // Access permission denied
  SQLITE_ABORT      =  4;   // Callback routine requested an abort
  SQLITE_BUSY       =  5;   // The database file is locked
  SQLITE_LOCKED     =  6;   // A table in the database is locked
  SQLITE_NOMEM      =  7;   // A malloc() failed
  SQLITE_READONLY   =  8;   // Attempt to write a readonly database
  SQLITE_INTERRUPT  =  9;   // Operation terminated by sqlite_interrupt()
  SQLITE_IOERR      = 10;   // Some kind of disk I/O error occurred
  SQLITE_CORRUPT    = 11;   // The database disk image is malformed
  SQLITE_NOTFOUND   = 12;   // (Internal Only) Table or record not found
  SQLITE_FULL       = 13;   // Insertion failed because database is full
  SQLITE_CANTOPEN   = 14;   // Unable to open the database file
  SQLITE_PROTOCOL   = 15;   // Database lock protocol error
  SQLITE_EMPTY      = 16;   // (Internal Only) Database table is empty
  SQLITE_SCHEMA     = 17;   // The database schema changed
  SQLITE_TOOBIG     = 18;   // Too much data for one row of a table
  SQLITE_RAINT      = 19;   // Abort due to contraint violation
  SQLITE_MISMATCH   = 20;   // Data type mismatch
  SQLITE_MISUSE     = 21;   // Library used incorrectly
  SQLITE_NOLFS      = 22;   // Uses OS features not supported on host
  SQLITE_AUTH       = 23;   // Authorization denied
  SQLITE_OOI_PARAM  = 25;   // Parameter index invalid
  SQLITE_ROW        = 100;  // sqlite_step() has another row ready
  SQLITE_DONE       = 101;  // sqlite_step() has finished executing

// These are the allowed values for the eTextRep argument to
// sqlite3_create_collation and sqlite3_create_function.

  SQLITE_UTF8       = 1;
  SQLITE_UTF16LE    = 2;
  SQLITE_UTF16BE    = 3;
  SQLITE_UTF16      = 4;    // Use native byte order
  SQLITE_ANY        = 5;

// values returned by SQLite3_Column_Type

  SQLITE_INTEGER    = 1;
  SQLITE_FLOAT      = 2;
  SQLITE_TEXT       = 3;
  SQLITE_BLOB       = 4;
  SQLITE_NULL       = 5;

  SQLITE_TRANSIENT  = Pointer(-1);
  SQLITE_STATIC     = Pointer(0);

type
  TSQLiteDB = Pointer;
  TSQLiteStatement = Pointer;
  TSQLiteBlob = Pointer;
  TSQLite_Func = record
    P: Pointer;
  end;
  PSQLite_Func = ^TSQLite_Func;
  TSQLiteDestructor = procedure (APointer: Pointer); cdecl;

  Psqlite3  = Pointer;
  Psqlite3_context  = Pointer;
  Psqlite3_value  = Pointer;
  PPsqlite3_value  = ^Psqlite3_value;
  TSQLite3ValueArray = array of Psqlite3_value;
  PSQLite3ValueArray = ^TSQLite3ValueArray;

  Tcreate_function_step_func = procedure (_para1: Psqlite3_context; _para2: longint; _para3: PPsqlite3_value); cdecl;
  Tcreate_function_func_func = procedure (_para1: Psqlite3_context; _para2: longint; _para3: PPsqlite3_value); cdecl;
  Tcreate_function_final_func = procedure (_para1: Psqlite3_context); cdecl;

  TSQLite3_Bind_Blob = function (AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: Pointer; ASize: Integer; ADestructor: TSQLiteDestructor): integer; cdecl;
  TSQLite3_Bind_Double = function (AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: Double): Integer; cdecl;
  TSQLite3_Bind_Int = function (AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: Integer): Integer; cdecl;
  TSQLite3_Bind_Int64 = function (AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: Int64): Integer; cdecl;
  TSQLite3_Bind_Null = function (AStatement: TSQLiteStatement; AParameterIndex: Integer): Integer; cdecl;
  TSQLite3_Bind_Text = function (AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: PAnsiChar; ASize: Integer; ADestructor: TSQLiteDestructor): Integer; cdecl;
  TSQLite3_Bind_Text16 = function (AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: PAnsiChar; ASize: Integer; ADestructor: TSQLiteDestructor): Integer; cdecl;
  TSQLite3_Bind_Value = function (AStatement: TSQLiteStatement; AParameterIndex: Integer; const AValue: Pointer): Integer; cdecl;
  TSQLite3_Bind_ZeroBlob = function (AStatement: TSQLiteStatement; AParameterIndex: Integer; ASize: integer): Integer; cdecl;
  TSQLite3_Bind_Parameter_Count = function(AStatement: TSQLiteStatement): Integer; cdecl;
  TSQLite3_Bind_Parameter_Index = function(AStatement: TSQLiteStatement; const AName: PAnsiChar): Integer; cdecl;
  TSQLite3_Bind_Parameter_Name = function(AStatement: TSQLiteStatement; AParameterIndex: Integer): PAnsiChar; cdecl;
  TSQLite3_Busy_Handler = procedure(ADatabase: TSQLiteDB; ACallbackPtr: Pointer; ASender: TObject); cdecl;
  TSQLite3_Busy_Timeout = procedure(ADatabase: TSQLiteDB; ATimeOut: Integer); cdecl;
  TSQLite3_Changes = function(ADatabase: TSQLiteDB): Integer; cdecl;
  TSQLite3_Close = function (ADatabase: TSQLiteDB): Integer; cdecl;
  TSQlite_Collation_Needed = function(ADatabase: TSQLiteDB; ACollNeededArg: Pointer; ACollationFunctionPtr: Pointer): Integer; cdecl;
  TSQlite_Collation_Needed16 = function(ADatabase: TSQLiteDB; ACollNeededArg: Pointer; ACollationFunctionPtr: Pointer): Integer; cdecl;
  TSQLite3_Column_Blob = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): Pointer; cdecl;
  TSQLite3_Column_Bytes = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): Integer; cdecl;
  TSQLite3_Column_Bytes16 = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): Integer; cdecl;
  TSQLite3_Column_Count = function(AStatement: TSQLiteStatement): Integer; cdecl;
  TSQLite3_Column_Double = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): Double; cdecl;
  TSQLite3_Column_Int = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): Integer; cdecl;
  TSQLite3_Column_Int64 = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): Int64; cdecl;
  TSQLite3_Column_Text = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): PAnsiChar; cdecl;
  TSQLite3_Column_Text16 = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): PChar; cdecl;
  TSQLite3_Column_Type = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): Integer; cdecl;
  TSQLite3_Column_Decltype = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): PAnsiChar; cdecl;
  TSQLite3_Column_Decltype16 = function (AStatement: TSQLiteStatement; AColumnIndex: Integer): PChar; cdecl;
  TSQLite3_Column_Name = function(AStatement: TSQLiteStatement; AColumnIndex: Integer): PAnsiChar; cdecl;
  TSQLite3_Column_Name16 = function (AStatement: TSQLiteStatement; AColumnIndex: Integer): PChar; cdecl;
  TSQLite3_Complete = function(const ASQL: PAnsiChar): Integer; cdecl;
  TSQLite3_Complete16 = function(const ASQL: PChar): Integer; cdecl;
  TSQLite3_Create_Collation = function(ADatabase: TSQLiteDB; AColumnName: PAnsiChar; ATextRep: Integer; ACtx: Pointer; ACompareFuncPtr: Pointer): Integer; cdecl;
  TSQLite3_Create_Collation16 = function(ADatabase: TSQLiteDB; AColumnName: PChar; ATextRep: Integer; ACtx: Pointer; ACompareFuncPtr: Pointer): Integer; cdecl;
  TSQLite3_Data_Count = function(AStatement: TSQLiteStatement): Integer; cdecl;
  TSQLite3_ErrCode = function(ADatabase: TSQLiteDB): Integer; cdecl;
  TSQLite3_ErrMsg = function(ADatabase : TSQLiteDB): PAnsiChar; cdecl;
  TSQLite3_ErrMsg16 = function(ADatabase : TSQLiteDB): PChar; cdecl;
  TSQLite3_Exec = function(ADatabase: TSQLiteDB; ASQLStatement: PAnsiChar; ACallbackPtr: Pointer; ASender: TObject; var AErrMsg: PAnsiChar): Integer; cdecl;
  TSQLite3_Finalize = function(AStatement: TSQLiteStatement): Integer; cdecl;
  TSQLite3_Free = procedure(P: PAnsiChar); cdecl;
  TSQLite3_Get_Table = function(ADatabase: TSQLiteDB; ASQLStatement: PAnsiChar; var AResultPtr: Pointer; var ARowCount: Integer; var AColCount: Integer; var AErrMsg: PAnsiChar): Integer; cdecl;
  TSQLite3_Free_Table = procedure(Table: PAnsiChar); cdecl;
  TSQLite3_Interrupt = procedure(ADatabase : TSQLiteDB); cdecl;
  TSQLite3_Last_Insert_RowId = function(ADatabase: TSQLiteDB): Int64; cdecl;
  TSQLite3_LibVersion = function(): PAnsiChar; cdecl;
  TSQLite3_Open = function(const AFilename: PAnsiChar; var ADatabase: TSQLiteDB): Integer; cdecl;
  TSQLite3_Open16 = function(const AFilename: PChar; var ADatabase: TSQLiteDB): Integer; cdecl;
  TSQLite3_Prepare = function(ADatabase: TSQLiteDB; ASQLStatement: PAnsiChar; ASQLLength: Integer; var AStatement: TSQLiteStatement; var ATail: pointer): Integer; cdecl;
  TSQLite3_Prepare_v2 = function(ADatabase: TSQLiteDB; ASQLStatement: PAnsiChar; ASQLLength: Integer; var AStatement: TSQLiteStatement; var ATail: pointer): Integer; cdecl;
  TSQLite3_Prepare16 = function(ADatabase: TSQLiteDB; ASQLStatement: PChar; ASQLLength: Integer; var AStatement: TSQLiteStatement; var ATail: pointer): Integer; cdecl;
  TSQLite3_Prepare16_v2 = function(ADatabase: TSQLiteDB; ASQLStatement: PChar; ASQLLength: Integer; var AStatement: TSQLiteStatement; var ATail: pointer): Integer; cdecl;
  TSQLite3_Reset = function(AStatement: TSQLiteStatement): Integer; cdecl;
  TSQLite3_Step = function(AStatement: TSQLiteStatement): Integer; cdecl;
  TSQLite3_Total_Changes = function(ADatabase: TSQLiteDB): Integer; cdecl;
  TSQLite3_Blob_Open = function (const ADatabase: TSQLiteDB; const ADBSymbolicName, ATable, AColumn: PAnsiChar; const ARow: Int64; AFlags: integer; var ABlob: TSQLiteBlob): Integer; cdecl;
  TSQLite3_Blob_Close = function (const ABlob: TSQLiteBlob): Integer; cdecl;
  TSQLite3_Blob_Bytes = function (const ABlob: TSQLiteBlob): Integer; cdecl;
  TSQLite3_Blob_Read = function (const ABlob: TSQLiteBlob; const ABuff: Pointer; ACount, AOffset: integer): Integer; cdecl;
  TSQLite3_Blob_Write = function (const ABlob: TSQLiteBlob; const ABuff: Pointer; ACount, AOffset: integer): Integer; cdecl;
  TSQLite3_Create_Function16 = function (ADatabase: TSQLiteDB; zFunctionName: pointer; nArg: longint; eTextRep: longint; _para5: pointer;
    xFunc: Tcreate_function_func_func; xStep: Tcreate_function_step_func; xFinal: Tcreate_function_final_func): longint; cdecl;

  TSQLite3_Value_Text16 = function (AValue: Psqlite3_value): Pointer; cdecl;

  TSQLite3_Result_Int = procedure (AContext: Psqlite3_context; AValue: integer); cdecl;
  TSQLite3_Result_Blob = procedure (AContext: Psqlite3_context; AValue: Pointer; AValueSize: integer; ADestructor: TSQLiteDestructor); cdecl;


  TSQLiteAPI = class(TCustomDynamicLibrary)
  strict private
    fSQLite3_Bind_Blob: TSQLite3_Bind_Blob;
    fSQLite3_Bind_Double: TSQLite3_Bind_Double;
    fSQLite3_Bind_Int: TSQLite3_Bind_Int;
    fSQLite3_Bind_Int64: TSQLite3_Bind_Int64;
    fSQLite3_Bind_Null: TSQLite3_Bind_Null;
    fSQLite3_Bind_Text: TSQLite3_Bind_Text;
    fSQLite3_Bind_Text16: TSQLite3_Bind_Text16;
    fSQLite3_Bind_Value: TSQLite3_Bind_Value;
    fSQLite3_Bind_ZeroBlob: TSQLite3_Bind_ZeroBlob;
    fSQLite3_Bind_Parameter_Count: TSQLite3_Bind_Parameter_Count;
    fSQLite3_Bind_Parameter_Index: TSQLite3_Bind_Parameter_Index;
    fSQLite3_Bind_Parameter_Name: TSQLite3_Bind_Parameter_Name;
    fSQLite3_Busy_Handler: TSQLite3_Busy_Handler;
    fSQLite3_Busy_Timeout: TSQLite3_Busy_Timeout;
    fSQLite3_Changes: TSQLite3_Changes;
    fSQLite3_Close: TSQLite3_Close;
    fSQlite_Collation_Needed: TSQlite_Collation_Needed;
    fSQlite_Collation_Needed16: TSQlite_Collation_Needed16;
    fSQLite3_Column_Blob: TSQLite3_Column_Blob;
    fSQLite3_Column_Bytes: TSQLite3_Column_Bytes;
    fSQLite3_Column_Bytes16: TSQLite3_Column_Bytes16;
    fSQLite3_Column_Count: TSQLite3_Column_Count;
    fSQLite3_Column_Double: TSQLite3_Column_Double;
    fSQLite3_Column_Int: TSQLite3_Column_Int;
    fSQLite3_Column_Int64: TSQLite3_Column_Int64;
    fSQLite3_Column_Text: TSQLite3_Column_Text;
    fSQLite3_Column_Text16: TSQLite3_Column_Text16;
    fSQLite3_Column_Type: TSQLite3_Column_Type;
    fSQLite3_Column_Decltype: TSQLite3_Column_Decltype;
    fSQLite3_Column_Decltype16: TSQLite3_Column_Decltype16;
    fSQLite3_Column_Name: TSQLite3_Column_Name;
    fSQLite3_Column_Name16: TSQLite3_Column_Name16;
    fSQLite3_Complete: TSQLite3_Complete;
    fSQLite3_Complete16: TSQLite3_Complete16;
    fSQLite3_Create_Collation: TSQLite3_Create_Collation;
    fSQLite3_Create_Collation16: TSQLite3_Create_Collation16;
    fSQLite3_Data_Count: TSQLite3_Data_Count;
    fSQLite3_ErrCode: TSQLite3_ErrCode;
    fSQLite3_ErrMsg: TSQLite3_ErrMsg;
    fSQLite3_ErrMsg16: TSQLite3_ErrMsg16;
    fSQLite3_Exec: TSQLite3_Exec;
    fSQLite3_Finalize: TSQLite3_Finalize;
    fSQLite3_Free: TSQLite3_Free;
    fSQLite3_Get_Table: TSQLite3_Get_Table;
    fSQLite3_Free_Table: TSQLite3_Free_Table;
    fSQLite3_Interrupt: TSQLite3_Interrupt;
    fSQLite3_Last_Insert_RowId: TSQLite3_Last_Insert_RowId;
    fSQLite3_LibVersion: TSQLite3_LibVersion;
    fSQLite3_Open: TSQLite3_Open;
    fSQLite3_Open16: TSQLite3_Open16;
    fSQLite3_Prepare: TSQLite3_Prepare;
    fSQLite3_Prepare_v2: TSQLite3_Prepare_v2;
    fSQLite3_Prepare16: TSQLite3_Prepare16;
    fSQLite3_Prepare16_v2: TSQLite3_Prepare16_v2;
    fSQLite3_Reset: TSQLite3_Reset;
    fSQLite3_Step: TSQLite3_Step;
    fSQLite3_Total_Changes: TSQLite3_Total_Changes;
    fSQLite3_Blob_Open: TSQLite3_Blob_Open;
    fSQLite3_Blob_Close: TSQLite3_Blob_Close;
    fSQLite3_Blob_Bytes: TSQLite3_Blob_Bytes;
    fSQLite3_Blob_Read: TSQLite3_Blob_Read;
    fSQLite3_Blob_Write: TSQLite3_Blob_Write;
    fSQLite3_Create_Function16: TSQLite3_Create_Function16;
    fSQLite3_Value_Text16: TSQLite3_Value_Text16;
    fSQLite3_Result_Int: TSQLite3_Result_Int;
    fSQLite3_Result_Blob: TSQLite3_Result_Blob;
  strict protected
    procedure MapRoutines; override;
  public
    function SQLite3_Bind_Blob(AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: Pointer; ASize: Integer; ADestructor: TSQLiteDestructor): integer;
    function SQLite3_Bind_Double(AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: Double): Integer;
    function SQLite3_Bind_Int(AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: Integer): Integer;
    function SQLite3_Bind_Int64(AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: Int64): Integer;
    function SQLite3_Bind_Null(AStatement: TSQLiteStatement; AParameterIndex: Integer): Integer;
    function SQLite3_Bind_Text(AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: PAnsiChar; ASize: Integer; ADestructor: TSQLiteDestructor): Integer;
    function SQLite3_Bind_Text16(AStatement: TSQLiteStatement; AParameterIndex: Integer; AData: PAnsiChar; ASize: Integer; ADestructor: TSQLiteDestructor): Integer;
    function SQLite3_Bind_Value(AStatement: TSQLiteStatement; AParameterIndex: Integer; const AValue: Pointer): Integer;
    function SQLite3_Bind_ZeroBlob(AStatement: TSQLiteStatement; AParameterIndex: Integer; ASize: integer): Integer;
    function SQLite3_Bind_Parameter_Count(AStatement: TSQLiteStatement): Integer;
    function SQLite3_Bind_Parameter_Index(AStatement: TSQLiteStatement; const AName: PAnsiChar): Integer;
    function SQLite3_Bind_Parameter_Name(AStatement: TSQLiteStatement; AParameterIndex: Integer): PAnsiChar;
    procedure SQLite3_Busy_Handler(ADatabase: TSQLiteDB; ACallbackPtr: Pointer; ASender: TObject);
    procedure SQLite3_Busy_Timeout(ADatabase: TSQLiteDB; ATimeOut: Integer);
    function SQLite3_Changes(ADatabase: TSQLiteDB): Integer;
    function SQLite3_Close(ADatabase: TSQLiteDB): Integer;
    function SQlite_Collation_Needed(ADatabase: TSQLiteDB; ACollNeededArg: Pointer; ACollationFunctionPtr: Pointer): Integer;
    function SQlite_Collation_Needed16(ADatabase: TSQLiteDB; ACollNeededArg: Pointer; ACollationFunctionPtr: Pointer): Integer;
    function SQLite3_Column_Blob(AStatement: TSQLiteStatement; AColumnIndex: Integer): Pointer;
    function SQLite3_Column_Bytes(AStatement: TSQLiteStatement; AColumnIndex: Integer): Integer;
    function SQLite3_Column_Bytes16(AStatement: TSQLiteStatement; AColumnIndex: Integer): Integer;
    function SQLite3_Column_Count(AStatement: TSQLiteStatement): Integer;
    function SQLite3_Column_Double(AStatement: TSQLiteStatement; AColumnIndex: Integer): Double;
    function SQLite3_Column_Int(AStatement: TSQLiteStatement; AColumnIndex: Integer): Integer;
    function SQLite3_Column_Int64(AStatement: TSQLiteStatement; AColumnIndex: Integer): Int64;
    function SQLite3_Column_Text(AStatement: TSQLiteStatement; AColumnIndex: Integer): PAnsiChar;
    function SQLite3_Column_Text16(AStatement: TSQLiteStatement; AColumnIndex: Integer): PChar;
    function SQLite3_Column_Type(AStatement: TSQLiteStatement; AColumnIndex: Integer): Integer;
    function SQLite3_Column_Decltype(AStatement: TSQLiteStatement; AColumnIndex: Integer): PAnsiChar;
    function SQLite3_Column_Decltype16(AStatement: TSQLiteStatement; AColumnIndex: Integer): PChar;
    function SQLite3_Column_Name(AStatement: TSQLiteStatement; AColumnIndex: Integer): PAnsiChar;
    function SQLite3_Column_Name16(AStatement: TSQLiteStatement; AColumnIndex: Integer): PChar;
    function SQLite3_Complete(const ASQL: PAnsiChar): Integer;
    function SQLite3_Complete16(const ASQL: PChar): Integer;
    function SQLite3_Create_Collation(ADatabase: TSQLiteDB; AColumnName: PAnsiChar; ATextRep: Integer; ACtx: Pointer; ACompareFuncPtr: Pointer): Integer;
    function SQLite3_Create_Collation16(ADatabase: TSQLiteDB; AColumnName: PChar; ATextRep: Integer; ACtx: Pointer; ACompareFuncPtr: Pointer): Integer;
    function SQLite3_Data_Count(AStatement: TSQLiteStatement): Integer;
    function SQLite3_ErrCode(ADatabase: TSQLiteDB): Integer;
    function SQLite3_ErrMsg(ADatabase : TSQLiteDB): PAnsiChar;
    function SQLite3_ErrMsg16(ADatabase : TSQLiteDB): PChar;
    function SQLite3_Exec(ADatabase: TSQLiteDB; ASQLStatement: PAnsiChar; ACallbackPtr: Pointer; ASender: TObject; var AErrMsg: PAnsiChar): Integer;
    function SQLite3_Finalize(AStatement: TSQLiteStatement): Integer;
    procedure SQLite3_Free(P: PAnsiChar);
    function SQLite3_Get_Table(ADatabase: TSQLiteDB; ASQLStatement: PAnsiChar; var AResultPtr: Pointer; var ARowCount: Integer; var AColCount: Integer; var AErrMsg: PAnsiChar): Integer;
    procedure SQLite3_Free_Table(Table: PAnsiChar);
    procedure SQLite3_Interrupt(ADatabase : TSQLiteDB);
    function SQLite3_Last_Insert_RowId(ADatabase: TSQLiteDB): Int64;
    function SQLite3_LibVersion(): PAnsiChar;
    function SQLite3_Open(const AFilename: PAnsiChar; var ADatabase: TSQLiteDB): Integer;
    function SQLite3_Open16(const AFilename: PChar; var ADatabase: TSQLiteDB): Integer;
    function SQLite3_Prepare(ADatabase: TSQLiteDB; ASQLStatement: PAnsiChar; ASQLLength: Integer; var AStatement: TSQLiteStatement; var ATail: pointer): Integer;
    function SQLite3_Prepare_v2(ADatabase: TSQLiteDB; ASQLStatement: PAnsiChar; ASQLLength: Integer; var AStatement: TSQLiteStatement; var ATail: pointer): Integer;
    function SQLite3_Prepare16(ADatabase: TSQLiteDB; ASQLStatement: PChar; ASQLLength: Integer; var AStatement: TSQLiteStatement; var ATail: pointer): Integer;
    function SQLite3_Prepare16_v2(ADatabase: TSQLiteDB; ASQLStatement: PChar; ASQLLength: Integer; var AStatement: TSQLiteStatement; var ATail: pointer): Integer;
    function SQLite3_Reset(AStatement: TSQLiteStatement): Integer;
    function SQLite3_Step(AStatement: TSQLiteStatement): Integer;
    function SQLite3_Total_Changes(ADatabase: TSQLiteDB): Integer;
    function SQLite3_Blob_Open(const ADatabase: TSQLiteDB; const ADBSymbolicName, ATable, AColumn: PAnsiChar; const ARow: Int64; AFlags: integer; var ABlob: TSQLiteBlob): Integer;
    function SQLite3_Blob_Close(const ABlob: TSQLiteBlob): Integer;
    function SQLite3_Blob_Bytes(const ABlob: TSQLiteBlob): Integer;
    function SQLite3_Blob_Read(const ABlob: TSQLiteBlob; const ABuff: Pointer; ACount, AOffset: integer): Integer;
    function SQLite3_Blob_Write(const ABlob: TSQLiteBlob; const ABuff: Pointer; ACount, AOffset: integer): Integer;
    function SQLite3_Create_Function16(ADatabase: TSQLiteDB; zFunctionName: pointer; nArg: Integer; eTextRep: Integer; _para5: pointer;
      xFunc: Tcreate_function_func_func; xStep: Tcreate_function_step_func; xFinal: Tcreate_function_final_func): Integer;
    function SQLite3_Value_Text16(AValue: Psqlite3_value): Pointer;
    procedure SQLite3_Result_Int(AContext: Psqlite3_context; AValue: integer);
    procedure SQLite3_Result_Blob(AContext: Psqlite3_context; AValue: Pointer; AValueSize: integer; ADestructor: TSQLiteDestructor);
  end;


implementation


{ TSQLiteAPI }

procedure TSQLiteAPI.MapRoutines;
begin
  MapRoutine('sqlite3_bind_blob', @@fSQLite3_Bind_Blob);
  MapRoutine('sqlite3_bind_double', @@fSQLite3_Bind_Double);
  MapRoutine('sqlite3_bind_int', @@fSQLite3_Bind_Int);
  MapRoutine('sqlite3_bind_int64', @@fSQLite3_Bind_Int64);
  MapRoutine('sqlite3_bind_null', @@fSQLite3_Bind_Null);
  MapRoutine('sqlite3_bind_text', @@fSQLite3_Bind_Text);
  MapRoutine('sqlite3_bind_text16', @@fSQLite3_Bind_Text16);
  MapRoutine('sqlite3_bind_value', @@fSQLite3_Bind_Value);
  MapRoutine('sqlite3_bind_zeroblob', @@fSQLite3_Bind_ZeroBlob);
  MapRoutine('sqlite3_bind_parameter_count', @@fSQLite3_Bind_Parameter_Count);
  MapRoutine('sqlite3_bind_parameter_index', @@fSQLite3_Bind_Parameter_Index);
  MapRoutine('sqlite3_bind_parameter_name', @@fSQLite3_Bind_Parameter_Name);
  MapRoutine('sqlite3_busy_handler', @@fSQLite3_Busy_Handler);
  MapRoutine('sqlite3_busy_timeout', @@fSQLite3_Busy_Timeout);
  MapRoutine('sqlite3_changes', @@fSQLite3_Changes);
  MapRoutine('sqlite3_close', @@fSQLite3_Close);
  MapRoutine('sqlite3_collation_needed', @@fSQLite_Collation_Needed);
  MapRoutine('sqlite3_collation_needed16', @@fSQLite_Collation_Needed16);
  MapRoutine('sqlite3_column_blob', @@fSQLite3_Column_Blob);
  MapRoutine('sqlite3_column_bytes', @@fSQLite3_Column_Bytes);
  MapRoutine('sqlite3_column_bytes16', @@fSQLite3_Column_Bytes16);
  MapRoutine('sqlite3_column_count', @@fSQLite3_Column_Count);
  MapRoutine('sqlite3_column_double', @@fSQLite3_Column_Double);
  MapRoutine('sqlite3_column_int', @@fSQLite3_Column_Int);
  MapRoutine('sqlite3_column_int64', @@fSQLite3_Column_Int64);
  MapRoutine('sqlite3_column_text', @@fSQLite3_Column_Text);
  MapRoutine('sqlite3_column_text16', @@fSQLite3_Column_Text16);
  MapRoutine('sqlite3_column_type', @@fSQLite3_Column_Type);
  MapRoutine('sqlite3_column_decltype', @@fSQLite3_Column_Decltype);
  MapRoutine('sqlite3_column_decltype16', @@fSQLite3_Column_Decltype16);
  MapRoutine('sqlite3_column_name', @@fSQLite3_Column_Name);
  MapRoutine('sqlite3_column_name16', @@fSQLite3_Column_Name16);
  MapRoutine('sqlite3_complete', @@fSQLite3_Complete);
  MapRoutine('sqlite3_complete16', @@fSQLite3_Complete16);
  MapRoutine('sqlite3_create_collation', @@fSQLite3_Create_Collation);
  MapRoutine('sqlite3_create_collation16', @@fSQLite3_Create_Collation16);
  MapRoutine('sqlite3_data_count', @@fSQLite3_Data_Count);
  MapRoutine('sqlite3_errcode', @@fSQLite3_ErrCode);
  MapRoutine('sqlite3_errmsg', @@fSQLite3_ErrMsg);
  MapRoutine('sqlite3_errmsg16', @@fSQLite3_ErrMsg16);
  MapRoutine('sqlite3_exec', @@fSQLite3_Exec);
  MapRoutine('sqlite3_finalize', @@fSQLite3_Finalize);
  MapRoutine('sqlite3_free', @@fSQLite3_Free);
  MapRoutine('sqlite3_get_table', @@fSQLite3_Get_Table);
  MapRoutine('sqlite3_free_table', @@fSQLite3_Free_Table);
  MapRoutine('sqlite3_interrupt', @@fSQLite3_Interrupt);
  MapRoutine('sqlite3_last_insert_rowid', @@fSQLite3_Last_Insert_RowId);
  MapRoutine('sqlite3_open', @@fSQLite3_Open);
  MapRoutine('sqlite3_open16', @@fSQLite3_Open16);
  MapRoutine('sqlite3_prepare', @@fSQLite3_Prepare);
  MapRoutine('sqlite3_prepare_v2', @@fSQLite3_Prepare_v2);
  MapRoutine('sqlite3_prepare16', @@fSQLite3_Prepare16);
  MapRoutine('sqlite3_prepare16_v2', @@fSQLite3_Prepare16_v2);
  MapRoutine('sqlite3_reset', @@fSQLite3_Reset);
  MapRoutine('sqlite3_blob_open', @@fSQLite3_Blob_Open);
  MapRoutine('sqlite3_blob_close', @@fSQLite3_Blob_Close);
  MapRoutine('sqlite3_blob_bytes', @@fSQLite3_Blob_Bytes);
  MapRoutine('sqlite3_blob_read', @@fSQLite3_Blob_Read);
  MapRoutine('sqlite3_blob_write', @@fSQLite3_Blob_Write);
  MapRoutine('sqlite3_step', @@fSQLite3_Step);
  MapRoutine('sqlite3_total_changes', @@fSQLite3_Total_Changes);
  MapRoutine('sqlite3_libversion', @@fSQLite3_LibVersion);
  MapRoutine('sqlite3_create_function16', @@fSQLite3_Create_Function16);
  MapRoutine('sqlite3_value_text16', @@fSQLite3_Value_Text16);
  MapRoutine('sqlite3_result_int', @@fSQLite3_Result_Int);
  MapRoutine('sqlite3_result_blob', @@fSQLite3_Result_Blob);
end;

function TSQLiteAPI.SQLite3_Bind_Blob(AStatement: TSQLiteStatement;
  AParameterIndex: Integer; AData: Pointer; ASize: Integer;
  ADestructor: TSQLiteDestructor): integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Blob(AStatement, AParameterIndex, AData, ASize, ADestructor);
end;

function TSQLiteAPI.SQLite3_Bind_Double(AStatement: TSQLiteStatement;
  AParameterIndex: Integer; AData: Double): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Double(AStatement, AParameterIndex, AData);
end;

function TSQLiteAPI.SQLite3_Bind_Int(AStatement: TSQLiteStatement;
  AParameterIndex, AData: Integer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Int(AStatement, AParameterIndex, AData);
end;

function TSQLiteAPI.SQLite3_Bind_Int64(AStatement: TSQLiteStatement;
  AParameterIndex: Integer; AData: Int64): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Int64(AStatement, AParameterIndex, AData);
end;

function TSQLiteAPI.SQLite3_Bind_Null(AStatement: TSQLiteStatement;
  AParameterIndex: Integer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Null(AStatement, AParameterIndex);
end;

function TSQLiteAPI.SQLite3_Bind_Parameter_Count(
  AStatement: TSQLiteStatement): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Parameter_Count(AStatement);
end;

function TSQLiteAPI.SQLite3_Bind_Parameter_Index(AStatement: TSQLiteStatement;
  const AName: PAnsiChar): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Parameter_Index(AStatement, AName);
end;

function TSQLiteAPI.SQLite3_Bind_Parameter_Name(AStatement: TSQLiteStatement;
  AParameterIndex: Integer): PAnsiChar;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Parameter_Name(AStatement, AParameterIndex);
end;

function TSQLiteAPI.SQLite3_Bind_Text(AStatement: TSQLiteStatement;
  AParameterIndex: Integer; AData: PAnsiChar; ASize: Integer;
  ADestructor: TSQLiteDestructor): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Text(AStatement, AParameterIndex, AData, ASize, ADestructor);
end;

function TSQLiteAPI.SQLite3_Bind_Text16(AStatement: TSQLiteStatement;
  AParameterIndex: Integer; AData: PAnsiChar; ASize: Integer;
  ADestructor: TSQLiteDestructor): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Text16(AStatement, AParameterIndex, AData, ASize, ADestructor);
end;

function TSQLiteAPI.SQLite3_Bind_Value(AStatement: TSQLiteStatement;
  AParameterIndex: Integer; const AValue: Pointer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_Value(AStatement, AParameterIndex, AValue);
end;

function TSQLiteAPI.SQLite3_Bind_ZeroBlob(AStatement: TSQLiteStatement;
  AParameterIndex, ASize: integer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Bind_ZeroBlob(AStatement, AParameterIndex, ASize);
end;

function TSQLiteAPI.SQLite3_Blob_Bytes(const ABlob: TSQLiteBlob): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Blob_Bytes(ABlob);
end;

function TSQLiteAPI.SQLite3_Blob_Close(const ABlob: TSQLiteBlob): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Blob_Close(ABlob);
end;

function TSQLiteAPI.SQLite3_Blob_Open(const ADatabase: TSQLiteDB;
  const ADBSymbolicName, ATable, AColumn: PAnsiChar; const ARow: Int64;
  AFlags: integer; var ABlob: TSQLiteBlob): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Blob_Open(ADatabase, ADBSymbolicName, ATable, AColumn, ARow, AFlags, ABlob);
end;

function TSQLiteAPI.SQLite3_Blob_Read(const ABlob: TSQLiteBlob;
  const ABuff: Pointer; ACount, AOffset: integer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Blob_Read(ABlob, ABuff, ACount, AOffset);
end;

function TSQLiteAPI.SQLite3_Blob_Write(const ABlob: TSQLiteBlob;
  const ABuff: Pointer; ACount, AOffset: integer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Blob_Write(ABlob, ABuff, ACount, AOffset);
end;

procedure TSQLiteAPI.SQLite3_Busy_Handler(ADatabase: TSQLiteDB;
  ACallbackPtr: Pointer; ASender: TObject);
begin
  EnsureLoaded;
  fSQLite3_Busy_Handler(ADatabase, ACallbackPtr, ASender);
end;

procedure TSQLiteAPI.SQLite3_Busy_Timeout(ADatabase: TSQLiteDB;
  ATimeOut: Integer);
begin
  EnsureLoaded;
  fSQLite3_Busy_Timeout(ADatabase, ATimeOut);
end;

function TSQLiteAPI.SQLite3_Changes(ADatabase: TSQLiteDB): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Changes(ADatabase);
end;

function TSQLiteAPI.SQLite3_Close(ADatabase: TSQLiteDB): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Close(ADatabase);
end;

function TSQLiteAPI.SQLite3_Column_Blob(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): Pointer;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Blob(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Bytes(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Bytes(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Bytes16(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Bytes16(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Count(AStatement: TSQLiteStatement): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Count(AStatement);
end;

function TSQLiteAPI.SQLite3_Column_Decltype(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): PAnsiChar;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Decltype(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Decltype16(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): PChar;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Decltype16(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Double(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): Double;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Double(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Int(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Int(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Int64(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): Int64;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Int64(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Name(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): PAnsiChar;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Name(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Name16(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): PChar;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Name16(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Text(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): PAnsiChar;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Text(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Text16(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): PChar;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Text16(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Column_Type(AStatement: TSQLiteStatement;
  AColumnIndex: Integer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Column_Type(AStatement, AColumnIndex);
end;

function TSQLiteAPI.SQLite3_Complete(const ASQL: PAnsiChar): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Complete(ASQL);
end;

function TSQLiteAPI.SQLite3_Complete16(const ASQL: PChar): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Complete16(ASQL);
end;

function TSQLiteAPI.SQLite3_Create_Collation(ADatabase: TSQLiteDB;
  AColumnName: PAnsiChar; ATextRep: Integer; ACtx,
  ACompareFuncPtr: Pointer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Create_Collation(ADatabase, AColumnName, ATextRep, ACtx, ACompareFuncPtr);
end;

function TSQLiteAPI.SQLite3_Create_Collation16(ADatabase: TSQLiteDB;
  AColumnName: PChar; ATextRep: Integer; ACtx,
  ACompareFuncPtr: Pointer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Create_Collation16(ADatabase, AColumnName, ATextRep, ACtx, ACompareFuncPtr);
end;

function TSQLiteAPI.SQLite3_Create_Function16(ADatabase: TSQLiteDB;
  zFunctionName: pointer; nArg, eTextRep: Integer; _para5: pointer;
  xFunc: Tcreate_function_func_func; xStep: Tcreate_function_step_func;
  xFinal: Tcreate_function_final_func): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Create_Function16(ADatabase, zFunctionName, nArg, eTextRep,
    _para5, xFunc, xStep, xFinal);
end;

function TSQLiteAPI.SQLite3_Data_Count(AStatement: TSQLiteStatement): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Data_Count(AStatement);
end;

function TSQLiteAPI.SQLite3_ErrCode(ADatabase: TSQLiteDB): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_ErrCode(ADatabase);
end;

function TSQLiteAPI.SQLite3_ErrMsg(ADatabase: TSQLiteDB): PAnsiChar;
begin
  EnsureLoaded;
  Result := fSQLite3_ErrMsg(ADatabase);
end;

function TSQLiteAPI.SQLite3_ErrMsg16(ADatabase: TSQLiteDB): PChar;
begin
  EnsureLoaded;
  Result := fSQLite3_ErrMsg16(ADatabase);
end;

function TSQLiteAPI.SQLite3_Exec(ADatabase: TSQLiteDB; ASQLStatement: PAnsiChar;
  ACallbackPtr: Pointer; ASender: TObject; var AErrMsg: PAnsiChar): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Exec(ADatabase, ASQLStatement, ACallbackPtr, ASender, AErrMsg);
end;

function TSQLiteAPI.SQLite3_Finalize(AStatement: TSQLiteStatement): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Finalize(AStatement);
end;

procedure TSQLiteAPI.SQLite3_Free(P: PAnsiChar);
begin
  EnsureLoaded;
  fSQLite3_Free(P);
end;

procedure TSQLiteAPI.SQLite3_Free_Table(Table: PAnsiChar);
begin
  EnsureLoaded;
  fSQLite3_Free_Table(Table);
end;

function TSQLiteAPI.SQLite3_Get_Table(ADatabase: TSQLiteDB;
  ASQLStatement: PAnsiChar; var AResultPtr: Pointer; var ARowCount,
  AColCount: Integer; var AErrMsg: PAnsiChar): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Get_Table(ADatabase, ASQLStatement, AResultPtr, ARowCount, AColCount, AErrMsg);
end;

procedure TSQLiteAPI.SQLite3_Interrupt(ADatabase: TSQLiteDB);
begin
  EnsureLoaded;
  fSQLite3_Interrupt(ADatabase);
end;

function TSQLiteAPI.SQLite3_Last_Insert_RowId(ADatabase: TSQLiteDB): Int64;
begin
  EnsureLoaded;
  Result := fSQLite3_Last_Insert_RowId(ADatabase);
end;

function TSQLiteAPI.SQLite3_LibVersion: PAnsiChar;
begin
  EnsureLoaded;
  Result := fSQLite3_LibVersion;
end;

function TSQLiteAPI.SQLite3_Open(const AFilename: PAnsiChar;
  var ADatabase: TSQLiteDB): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Open(AFilename, ADatabase);
end;

function TSQLiteAPI.SQLite3_Open16(const AFilename: PChar;
  var ADatabase: TSQLiteDB): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Open16(AFilename, ADatabase);
end;

function TSQLiteAPI.SQLite3_Prepare(ADatabase: TSQLiteDB; ASQLStatement: PAnsiChar;
  ASQLLength: Integer; var AStatement: TSQLiteStatement;
  var ATail: pointer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Prepare(ADatabase, ASQLStatement, ASQLLength, AStatement, ATail);
end;

function TSQLiteAPI.SQLite3_Prepare16(ADatabase: TSQLiteDB;
  ASQLStatement: PChar; ASQLLength: Integer; var AStatement: TSQLiteStatement;
  var ATail: pointer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Prepare16(ADatabase, ASQLStatement, ASQLLength, AStatement, ATail);
end;

function TSQLiteAPI.SQLite3_Prepare16_v2(ADatabase: TSQLiteDB;
  ASQLStatement: PChar; ASQLLength: Integer; var AStatement: TSQLiteStatement;
  var ATail: pointer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Prepare16_v2(ADatabase, ASQLStatement, ASQLLength, AStatement, ATail);
end;

function TSQLiteAPI.SQLite3_Prepare_v2(ADatabase: TSQLiteDB;
  ASQLStatement: PAnsiChar; ASQLLength: Integer; var AStatement: TSQLiteStatement;
  var ATail: pointer): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Prepare_v2(ADatabase, ASQLStatement, ASQLLength, AStatement, ATail);
end;

function TSQLiteAPI.SQLite3_Reset(AStatement: TSQLiteStatement): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Reset(AStatement);
end;

procedure TSQLiteAPI.SQLite3_Result_Blob(AContext: Psqlite3_context;
  AValue: Pointer; AValueSize: integer; ADestructor: TSQLiteDestructor);
begin
  EnsureLoaded;
  fSQLite3_Result_Blob(AContext, AValue, AValueSize, ADestructor);
end;

procedure TSQLiteAPI.SQLite3_Result_Int(AContext: Psqlite3_context;
  AValue: integer);
begin
  EnsureLoaded;
  fSQLite3_Result_Int(AContext, AValue);
end;

function TSQLiteAPI.SQLite3_Step(AStatement: TSQLiteStatement): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Step(AStatement);
end;

function TSQLiteAPI.SQLite3_Total_Changes(ADatabase: TSQLiteDB): Integer;
begin
  EnsureLoaded;
  Result := fSQLite3_Total_Changes(ADatabase);
end;

function TSQLiteAPI.SQLite3_Value_Text16(AValue: Psqlite3_value): Pointer;
begin
  EnsureLoaded;
  Result := fSQLite3_Value_Text16(AValue);
end;

function TSQLiteAPI.SQlite_Collation_Needed(ADatabase: TSQLiteDB;
  ACollNeededArg, ACollationFunctionPtr: Pointer): Integer;
begin
  EnsureLoaded;
  Result := fSQlite_Collation_Needed(ADatabase, ACollNeededArg, ACollationFunctionPtr);
end;

function TSQLiteAPI.SQlite_Collation_Needed16(ADatabase: TSQLiteDB;
  ACollNeededArg, ACollationFunctionPtr: Pointer): Integer;
begin
  EnsureLoaded;
  Result := fSQlite_Collation_Needed16(ADatabase, ACollNeededArg, ACollationFunctionPtr);
end;

end.



