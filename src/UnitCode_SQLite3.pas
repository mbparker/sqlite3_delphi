unit UnitCode_SQLite3;

interface

uses
  WinApi.Windows, System.SysUtils, System.Classes, System.Variants, System.Contnrs, Data.DB,
  UnitCode_SQLite3API;

type
  ESQLException = class(Exception);

  ESQLiteException = class(ESQLException)
  strict private
    fContext: string;
    fSQLErrorCode: integer;
    fSQLErrorMessage: string;
  public
    constructor Create(ASQLErrorCode: integer; const ASQLErrorMessage: string); overload;
    constructor Create(ASQLErrorCode: integer; const ASQLErrorMessage, AContext: string); overload;
    property Context: string read fContext;
    property SQLErrorCode: integer read fSQLErrorCode;
    property SQLErrorMessage: string read fSQLErrorMessage;
  end;

  TSQLiteDatabase = class;

  TSQLiteBase = class
  strict private
    fDatabase: TSQLiteDatabase;
  strict protected
    function CheckCall(AResult: integer): integer;
    procedure SQLiteError(const AContext: string); overload;
    procedure SQLiteError(AResult: integer; const AContext: string); overload;
    procedure SQLiteError; overload;
    procedure SQLiteError(AResult: integer); overload;
  public
    constructor Create(ADatabase: TSQLiteDatabase); virtual;
    destructor Destroy; override;
    property Database: TSQLiteDatabase read fDatabase;
  end;

  TSQLiteFieldType = (ftUnknown, ftBoolean, ftString, ftWidestring, ftInteger, ftCardinal,
    ftInt64, ftUint64, ftDouble, ftDateTime, ftBlob);

  TSQLiteDatabase = class(TSQLiteBase)
  strict private
    fAPI: TSQLiteAPI;
    fDB: TSQLiteDB;
    fFilename: string;
    fTypeBindings: TStringList;
    fConnected: boolean;
    function FindTypeBinding(const ATypeName: string): integer;
  public
    constructor Create; reintroduce; virtual;
    destructor Destroy; override;
    procedure Connect(const ADatabaseFile: string; AUseDefaultBindings: boolean = True);
    procedure Disconnect;
    procedure RegisterTypeBinding(const ATypeName: string; AFieldType: TSQLiteFieldType);
    procedure UnregisterTypeBinding(const ATypeName: string);
    function GetTypeBinding(const ATypeName: string): TSQLiteFieldType;
    procedure RegisterDefaultTypeBindings;
    procedure ClearTypeBindings;
    procedure BeginTransaction;
    procedure CommitTransaction;
    procedure RollbackTransaction;
    property Connected: boolean read fConnected;
    property DatabaseFilename: string read fFilename;
    property API: TSQLiteAPI read fAPI;
    property DB: Pointer read fDB;
  end;

  TSQLiteQuery = class;

  TSQLiteParameter = class(TSQLiteBase)
  strict private
    fName: string;
    fDataType: TSQLiteFieldType;
    fDataSize: integer;
    fQuery: TSQLiteQuery;
    fInternalValue: Pointer;
    procedure ReleaseMemory;
    function GetStaticFieldSize(AFieldType: TSQLiteFieldType): integer;
    function GetFieldTypeFromValue(const AValue: Variant): TSQLiteFieldType;
    function GetValue: Variant;
    procedure SetValue(const AValue: Variant);
    procedure SetSize(AValue: integer);
    procedure SetInternalValue(AValue: Pointer);
    procedure ReAlloc;
    function GetParameterIndex: integer;
    procedure GetAsBoolean(var AValue: Variant);
    procedure SetAsBoolean(const AValue: Variant);
    procedure GetAsInteger(var AValue: Variant);
    procedure SetAsInteger(const AValue: Variant);
    procedure GetAsCardinal(var AValue: Variant);
    procedure SetAsCardinal(const AValue: Variant);
    procedure GetAsInt64(var AValue: Variant);
    procedure SetAsInt64(const AValue: Variant);
    procedure GetAsUInt64(var AValue: Variant);
    procedure SetAsUInt64(const AValue: Variant);
    procedure GetAsDouble(var AValue: Variant);
    procedure SetAsDouble(const AValue: Variant);
    procedure GetAsDateTime(var AValue: Variant);
    procedure SetAsDateTime(const AValue: Variant);
    procedure GetAsString(var AValue: Variant);
    procedure SetAsString(const AValue: Variant);
    procedure GetAsWideString(var AValue: Variant);
    procedure SetAsWideString(const AValue: Variant);
    procedure GetAsBlob(var AValue: Variant);
    procedure SetAsBlob(const AValue: Variant);
  private
    procedure Bind;
  public
    constructor Create(ADatabase: TSQLiteDatabase; AQuery: TSQLiteQuery;
      const AName: string); reintroduce; virtual;
    destructor Destroy; override;
    procedure SetBlobData(AStream: TStream); overload;
    procedure SetBlobData(const AFilename: string); overload;
    property Name: string read fName;
    property DataType: TSQLiteFieldType read fDataType;
    property Size: integer read fDataSize;
    property Value: Variant read GetValue write SetValue;
  end;

  TSQLiteParameters = class(TSQLiteBase)
  strict private
    fQuery: TSQLiteQuery;
    fItems: TObjectList;
    fNameIndex: TStringList;
    function GetCount: integer;
    function GetItems(AIndex: integer): TSQLiteParameter;
    function FindParameter(const AName: string): TSQLiteParameter;
    function GetItemsByName(const AName: string): TSQLiteParameter;
  private
    procedure Bind;
    procedure Clear;
  public
    constructor Create(ADatabase: TSQLiteDatabase; AQuery: TSQLiteQuery); reintroduce;
    destructor Destroy; override;
    property Items[AIndex: integer]: TSQLiteParameter read GetItems;
    property ItemsByName[const AName: string]: TSQLiteParameter read GetItemsByName; default;
    property Count: integer read GetCount;
  end;

  TSQLiteDataset = class;

  TSQLiteField = class(TSQLiteBase)
  strict private
    fName: string;
    fDataType: TSQLiteFieldType;
    fDataSet: TSQLiteDataset;
    fColumn: integer;
    fValue: Variant;
    procedure ReadValue;
  public
    constructor Create(ADatabase: TSQLiteDatabase; ADataSet: TSQLiteDataset;
      const AFieldName: string; AFieldType: TSQLiteFieldType;
      AColumn: integer); reintroduce; virtual;
    function AsString: AnsiString;
    function AsWideString: string;
    function AsBoolean: boolean;
    function AsInteger: integer;
    function AsCardinal: cardinal;
    function AsInt64: Int64;
    function AsUInt64: UInt64;
    function AsFloat: double;
    function AsDateTime: TDateTime;
    function AsBlob(AStream: TStream = nil): TStream;
    function AsBlobArray: TBytes;
    function AsBlobString: string;
    property Name: string read fName;
    property DataType: TSQLiteFieldType read fDataType;
    property DataSet: TSQLiteDataset read fDataSet;
    property Column: integer read fColumn;
  end;

  TSQLiteDataset = class(TSQLiteBase)
  strict private
    fNeedsReset: boolean;
    fFields: TStringList;
    fRecordNumber: UInt64;
    fEOF: boolean;
    fFieldsInitialized: boolean;

    procedure InitializeFields;
    procedure FreeFields;
    function FindFieldIndex(const AName: string): integer;
    function GetFieldByIndex(AIndex: integer): TSQLiteField;
    function GetFieldByName(const AName: string): TSQLiteField;
    function GetFieldCount: integer;
    procedure Invalidate;
  strict protected
    fCompiledSQL: Pointer;

    procedure FieldsInitialized; virtual;
    procedure QueryOpened; virtual;
    procedure RaiseIfNotOpen; virtual; abstract;
  public
    constructor Create(ADatabase: TSQLiteDatabase); override;
    destructor Destroy; override;
    procedure MoveFirst;
    procedure Next;
    function RecordCount: UInt64;
    property FieldByIndex[AIndex: integer]: TSQLiteField read GetFieldByIndex;
    property FieldByName[const AName: string]: TSQLiteField read GetFieldByName;
    property FieldCount: integer read GetFieldCount;
    property RecordNumber: UInt64 read fRecordNumber;
    property EOF: boolean read fEOF;
    property CompiledSQL: Pointer read fCompiledSQL;
  end;

  TSQLiteQueryState = (qsOpen, qsClosed);

  TSQLiteQuery = class(TSQLiteDataset)
  strict private
    fParameters: TSQLiteParameters;
    fQueryState: TSQLiteQueryState;
    function GetParamValue(const AName: string): Variant;
    procedure SetParamValue(const AName: string; const AValue: Variant);
  strict protected
    procedure FieldsInitialized; override;
    procedure RaiseIfNotOpen; override;
  public
    constructor Create(ADatabase: TSQLiteDatabase); override;
    destructor Destroy; override;
    procedure Open(const ASQL: string);
    procedure Close;
    function Execute: integer;
    function ExecuteScalar: integer;
    function ExecSQL(const ASQL: string): integer;
    function RowsAffected: integer;
    property QueryState: TSQLiteQueryState read fQueryState;
    property Parameters: TSQLiteParameters read fParameters;
    property ParamValue[const AName: string]: Variant read GetParamValue write SetParamValue;
  end;

implementation

type
  PUInt64 = ^UInt64;
  PLongBool = ^LongBool;

{ ESQLiteException }

constructor ESQLiteException.Create(ASQLErrorCode: integer;
  const ASQLErrorMessage, AContext: string);
begin
  if AContext = EmptyStr then
    Create(ASQLErrorCode, ASQLErrorMessage)
  else
  begin
    fSQLErrorCode := ASQLErrorCode;
    fSQLErrorMessage := ASQLErrorMessage;
    fContext := AContext;
    inherited CreateFmt('%s'#10'0x%x'#10'%s', [AContext, ASQLErrorCode, ASQLErrorMessage]);
  end;
end;

constructor ESQLiteException.Create(ASQLErrorCode: integer;
  const ASQLErrorMessage: string);
begin
  fSQLErrorCode := ASQLErrorCode;
  fSQLErrorMessage := ASQLErrorMessage;
  inherited CreateFmt('0x%x'#10'%s', [ASQLErrorCode, ASQLErrorMessage]);
end;

{ TSQLiteBase }

function TSQLiteBase.CheckCall(AResult: integer): integer;
begin
  Result := AResult;
  if Result <> SQLITE_OK then
    SQLiteError(Result);
end;

constructor TSQLiteBase.Create(ADatabase: TSQLiteDatabase);
begin
  inherited Create;
  fDatabase := ADatabase;
end;

destructor TSQLiteBase.Destroy;
begin
  fDatabase := nil;
  inherited Destroy;
end;

procedure TSQLiteBase.SQLiteError(AResult: integer; const AContext: string);
var
  lErrorMsg: PChar;
begin
  if AResult <> SQLITE_OK then
  begin
    if Database.DB <> nil then
      lErrorMsg := Database.API.SQLite3_ErrMsg16(Database.DB)
    else
      lErrorMsg := nil;
    raise ESQLiteException.Create(AResult, string(lErrorMsg), AContext);
  end;
end;

procedure TSQLiteBase.SQLiteError(const AContext: string);
var
  lError: integer;
begin
  if Database.DB <> nil then
    lError := Database.API.SQLite3_ErrCode(Database.DB)
  else
    lError := -1;
  SQLiteError(lError, AContext);
end;

procedure TSQLiteBase.SQLiteError;
begin
  SQLiteError('');
end;

procedure TSQLiteBase.SQLiteError(AResult: integer);
begin
  SQLiteError(AResult, '');
end;

{ TSQLiteDatabase }

constructor TSQLiteDatabase.Create;
begin
  inherited Create(Self);
  fConnected := False;
  fDB := nil;
  fAPI := TSQLiteAPI.Create('sqlite3.dll');
  fTypeBindings := TStringList.Create;
  fTypeBindings.Duplicates := dupIgnore;
  fTypeBindings.Sorted := True;
end;

destructor TSQLiteDatabase.Destroy;
begin
  Disconnect;
  FreeAndNil(fTypeBindings);
  FreeAndNil(fAPI);
  inherited Destroy;
end;

procedure TSQLiteDatabase.Disconnect;
begin
  if fConnected then
  begin
    try
      if DB <> nil then
      begin
        try
          API.SQLite3_Close(DB);
        except
        end;
        fDB := nil;
      end;
      ClearTypeBindings;
    finally
      fConnected := False;
    end;
  end;
end;

procedure TSQLiteDatabase.CommitTransaction;
var
  lDummy: PAnsiChar;
begin
  lDummy := nil;
  CheckCall(API.SQLite3_Exec(Database.DB, 'END;', nil, nil, lDummy));
end;

function TSQLiteDatabase.FindTypeBinding(const ATypeName: string): integer;
begin
  if not fTypeBindings.Find(ATypeName, Result) then
    Result := -1;
end;

function TSQLiteDatabase.GetTypeBinding(const ATypeName: string): TSQLiteFieldType;
var
  lIndex: integer;
begin
  lIndex := FindTypeBinding(ATypeName);
  if lIndex >= 0 then
    Result := TSQLiteFieldType(fTypeBindings.Objects[lIndex])
  else
    Result := ftUnknown;
end;

procedure TSQLiteDatabase.BeginTransaction;
var
  lDummy: PAnsiChar;
begin
  lDummy := nil;
  CheckCall(API.SQLite3_Exec(Database.DB, 'BEGIN;', nil, nil, lDummy));
end;

procedure TSQLiteDatabase.ClearTypeBindings;
begin
  fTypeBindings.Clear;
end;

procedure TSQLiteDatabase.Connect(const ADatabaseFile: string; AUseDefaultBindings: boolean = True);
var
  lOpenResult: integer;
begin
  if not fConnected then
  begin
    if DB = nil then
    begin
      fFilename := ADatabaseFile;
      lOpenResult := API.SQLite3_Open16(PChar(fFilename), fDB);
      if lOpenResult <> SQLITE_OK then
        raise ESQLException.CreateFmt('Failed to open database: 0x%x', [lOpenResult]);
      if AUseDefaultBindings then
        RegisterDefaultTypeBindings;
      fConnected := True;
    end;
  end;
end;

procedure TSQLiteDatabase.RegisterDefaultTypeBindings;
begin
  RegisterTypeBinding('ANSI_TEXT', ftString);
  RegisterTypeBinding('TEXT', ftWidestring);
  RegisterTypeBinding('VARCHAR', ftWidestring);
  RegisterTypeBinding('INTEGER', ftInteger);
  RegisterTypeBinding('INT32', ftInteger);
  RegisterTypeBinding('UINT32', ftCardinal);
  RegisterTypeBinding('INT64', ftInt64);
  RegisterTypeBinding('UINT64', ftUint64);
  RegisterTypeBinding('DOUBLE', ftDouble);
  RegisterTypeBinding('DOUBLE_DATETIME', ftDateTime);
  RegisterTypeBinding('TIMESTAMP', ftDateTime);
  RegisterTypeBinding('INT32_BOOLEAN', ftInteger);
  RegisterTypeBinding('BOOLEAN', ftInteger);
  RegisterTypeBinding('BOOL', ftInteger);
  RegisterTypeBinding('BLOB', ftBlob);
end;

procedure TSQLiteDatabase.RegisterTypeBinding(const ATypeName: string;
  AFieldType: TSQLiteFieldType);
begin
  if AFieldType = ftUnknown then
    raise ESQLException.Create('ftUnknown cannot be bound.');
  if FindTypeBinding(ATypeName) >= 0 then
    raise ESQLException.CreateFmt('Datatype "%s" is already bound.', [ATypeName]);
  fTypeBindings.AddObject(ATypeName, TObject(AFieldType));
end;

procedure TSQLiteDatabase.RollbackTransaction;
var
  lDummy: PAnsiChar;
begin
  lDummy := nil;
  CheckCall(API.SQLite3_Exec(Database.DB, 'ROLLBACK;', nil, nil, lDummy));
end;

procedure TSQLiteDatabase.UnregisterTypeBinding(const ATypeName: string);
var
  lIndex: integer;
begin
  lIndex := FindTypeBinding(ATypeName);
  if lIndex >= 0 then
    fTypeBindings.Delete(lIndex);
end;

{ TSQLiteParameter }

procedure TSQLiteParameter.Bind;
var
  lParameterIndex: integer;
begin
  try
    lParameterIndex := GetParameterIndex;
    if lParameterIndex > 0 then
    begin
      case DataType of
        ftBoolean: CheckCall(Database.API.SQLite3_Bind_Int(fQuery.CompiledSQL, lParameterIndex, PInteger(PLongBool(fInternalValue))^));
        ftString: CheckCall(Database.API.SQLite3_Bind_Text(fQuery.CompiledSQL, lParameterIndex, fInternalValue, Size, SQLITE_STATIC));
        ftWidestring: CheckCall(Database.API.SQLite3_Bind_Text16(fQuery.CompiledSQL, lParameterIndex, fInternalValue, Size, SQLITE_STATIC));
        ftInteger: CheckCall(Database.API.SQLite3_Bind_Int(fQuery.CompiledSQL, lParameterIndex, PInteger(fInternalValue)^));
        ftCardinal: CheckCall(Database.API.SQLite3_Bind_Int(fQuery.CompiledSQL, lParameterIndex, PCardinal(fInternalValue)^));
        ftInt64: CheckCall(Database.API.SQLite3_Bind_Int64(fQuery.CompiledSQL, lParameterIndex, PInt64(fInternalValue)^));
        ftUint64: CheckCall(Database.API.SQLite3_Bind_Int64(fQuery.CompiledSQL, lParameterIndex, PUInt64(fInternalValue)^));
        ftDouble: CheckCall(Database.API.SQLite3_Bind_Double(fQuery.CompiledSQL, lParameterIndex, PDouble(fInternalValue)^));
        ftDateTime: CheckCall(Database.API.SQLite3_Bind_Double(fQuery.CompiledSQL, lParameterIndex, PDateTime(fInternalValue)^));
        ftBlob: CheckCall(Database.API.SQLite3_Bind_Blob(fQuery.CompiledSQL, lParameterIndex, fInternalValue, Size, SQLITE_STATIC));
      end;
    end;
  except
    on E:Exception do
    begin
      E.Message := E.Message + #10 + 'Param: ' + Name;
      raise;
    end;
  end;
end;

constructor TSQLiteParameter.Create(ADatabase: TSQLiteDatabase;
  AQuery: TSQLiteQuery; const AName: string);
begin
  inherited Create(ADatabase);
  fName := AName;
  fQuery := AQuery;
  fDataSize := 0;
  fDataType := ftUnknown;
  ReAlloc;
end;

destructor TSQLiteParameter.Destroy;
begin
  ReleaseMemory;
  inherited Destroy;
end;

function TSQLiteParameter.GetStaticFieldSize(
  AFieldType: TSQLiteFieldType): integer;
begin
  case AFieldType of
    ftBoolean: Result := SizeOf(LongBool);
    ftInteger: Result := SizeOf(Integer);
    ftCardinal: Result := SizeOf(Cardinal);
    ftInt64: Result := SizeOf(Int64);
    ftUint64: Result := SizeOf(UInt64);
    ftDouble: Result := SizeOf(Double);
    ftDateTime: Result := SizeOf(TDateTime);
    else Result := 0;
  end;
end;

function TSQLiteParameter.GetValue: Variant;
begin
  case DataType of
    ftBoolean: GetAsBoolean(Result);
    ftInteger: GetAsInteger(Result);
    ftCardinal: GetAsCardinal(Result);
    ftInt64: GetAsInt64(Result);
    ftUint64: GetAsUInt64(Result);
    ftDouble: GetAsDouble(Result);
    ftDateTime: GetAsDateTime(Result);
    ftString: GetAsString(Result);
    ftWidestring: GetAsWideString(Result);
    ftBlob: GetAsBlob(Result);
    else Result := Null;
  end;
end;

procedure TSQLiteParameter.GetAsBlob(var AValue: Variant);
var
  lTemp: AnsiString;
begin
  SetLength(lTemp, Size);
  CopyMemory(@PAnsiChar(lTemp)^, fInternalValue, Size);
  AValue := lTemp;
end;

procedure TSQLiteParameter.GetAsBoolean(var AValue: Variant);
begin
  AValue := PLongBool(fInternalValue)^;
end;

procedure TSQLiteParameter.GetAsCardinal(var AValue: Variant);
begin
  AValue := PCardinal(fInternalValue)^;
end;

procedure TSQLiteParameter.GetAsDateTime(var AValue: Variant);
begin
  AValue := PDateTime(fInternalValue)^;
end;

procedure TSQLiteParameter.GetAsDouble(var AValue: Variant);
begin
  AValue := PDouble(fInternalValue)^;
end;

procedure TSQLiteParameter.GetAsInt64(var AValue: Variant);
begin
  AValue := PInt64(fInternalValue)^;
end;

procedure TSQLiteParameter.GetAsInteger(var AValue: Variant);
begin
  AValue := PInteger(fInternalValue)^;
end;

procedure TSQLiteParameter.GetAsString(var AValue: Variant);
var
  lValue: AnsiString;
begin
  lValue := PAnsiChar(fInternalValue);
  AValue := lValue;
end;

procedure TSQLiteParameter.GetAsUInt64(var AValue: Variant);
begin
  AValue := PUInt64(fInternalValue)^;
end;

procedure TSQLiteParameter.GetAsWideString(var AValue: Variant);
var
  lValue: string;
begin
  lValue := PChar(fInternalValue);
  AValue := lValue;
end;

function TSQLiteParameter.GetFieldTypeFromValue(
  const AValue: Variant): TSQLiteFieldType;
var
  lValType: Word;
begin
  lValType := VarType(AValue);
  case lValType of
    varSmallInt,
    varShortInt,
    varInteger: Result := ftInteger;
    varInt64: Result := ftInt64;
    varUInt64: Result := ftUint64;
    varSingle,
    varDouble,
    varCurrency: Result := ftDouble;
    varDate: Result := ftDateTime;
    varBoolean: Result := ftBoolean;
    varByte,
    varWord,
    varLongWord,
    varError: Result := ftCardinal;
    varString: Result := ftString;
    varOleStr,
    varUString: Result := ftWidestring;
    else Result := ftUnknown;
  end;
end;

function TSQLiteParameter.GetParameterIndex: integer;
begin
  Result := Database.API.SQLite3_Bind_Parameter_Index(fQuery.CompiledSQL, PAnsiChar(':' + AnsiString(Name)));
end;

procedure TSQLiteParameter.ReAlloc;
begin
  ReleaseMemory;
  if Size > 0 then
    fInternalValue := GetMemory(Size);
end;

procedure TSQLiteParameter.ReleaseMemory;
begin
  if fInternalValue <> nil then
  begin
    FreeMemory(fInternalValue);
    fInternalValue := nil;
  end;
end;

procedure TSQLiteParameter.SetBlobData(AStream: TStream);
var
  lStream: TMemoryStream;
  lCreated: boolean;
begin
  lCreated := False;
  lStream := nil;
  try
    if AStream is TMemoryStream then
      lStream := TMemoryStream(AStream)
    else
    begin
      lStream := TMemoryStream.Create;
      lStream.CopyFrom(AStream, AStream.Size);
      lCreated := True;
    end;
    fDataType := ftBlob;
    SetSize(lStream.Size);
    SetInternalValue(lStream.Memory);
  finally
    if lCreated then
      lStream.Free;
  end;
end;

procedure TSQLiteParameter.SetAsBlob(const AValue: Variant);
var
  lValue: AnsiString;
begin
  lValue := AnsiString(VarToStrDef(AValue, ''));
  SetSize(Length(lValue));
  SetInternalValue(@PAnsiChar(lValue)^);
end;

procedure TSQLiteParameter.SetAsBoolean(const AValue: Variant);
var
  lValue: LongBool;
begin
  lValue := AValue;
  SetInternalValue(@lValue);
end;

procedure TSQLiteParameter.SetAsCardinal(const AValue: Variant);
var
  lValue: Cardinal;
begin
  lValue := AValue;
  SetInternalValue(@lValue);
end;

procedure TSQLiteParameter.SetAsDateTime(const AValue: Variant);
var
  lValue: TDateTime;
begin
  lValue := AValue;
  SetInternalValue(@lValue);
end;

procedure TSQLiteParameter.SetAsDouble(const AValue: Variant);
var
  lValue: Double;
begin
  lValue := AValue;
  SetInternalValue(@lValue);
end;

procedure TSQLiteParameter.SetAsInt64(const AValue: Variant);
var
  lValue: Int64;
begin
  lValue := AValue;
  SetInternalValue(@lValue);
end;

procedure TSQLiteParameter.SetAsInteger(const AValue: Variant);
var
  lValue: Integer;
begin
  lValue := AValue;
  SetInternalValue(@lValue);
end;

procedure TSQLiteParameter.SetAsString(const AValue: Variant);
var
  lValue: AnsiString;
begin
  lValue := AnsiString(VarToStrDef(AValue, ''));
  SetSize(Length(lValue));
  SetInternalValue(@PAnsiChar(lValue)^);
end;

procedure TSQLiteParameter.SetAsUInt64(const AValue: Variant);
var
  lValue: UInt64;
begin
  lValue := AValue;
  SetInternalValue(@lValue);
end;

procedure TSQLiteParameter.SetAsWideString(const AValue: Variant);
var
  lValue: string;
begin
  lValue := VarToStrDef(AValue, '');
  SetSize(Length(lValue) * SizeOf(Char));
  SetInternalValue(@PChar(lValue)^);
end;

procedure TSQLiteParameter.SetBlobData(const AFilename: string);
var
  lStream: TFileStream;
begin
  lStream := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyWrite);
  try
    SetBlobData(lStream);
  finally
    lStream.Free;
  end;
end;

procedure TSQLiteParameter.SetInternalValue(AValue: Pointer);
begin
  CopyMemory(fInternalValue, AValue, Size);
end;

procedure TSQLiteParameter.SetSize(AValue: integer);
begin
  fDataSize := AValue;
  ReAlloc;
end;

procedure TSQLiteParameter.SetValue(const AValue: Variant);
begin
  fDataType := GetFieldTypeFromValue(AValue);
  SetSize(GetStaticFieldSize(DataType));
  case DataType of
    ftBoolean: SetAsBoolean(AValue);
    ftInteger: SetAsInteger(AValue);
    ftCardinal: SetAsCardinal(AValue);
    ftInt64: SetAsInt64(AValue);
    ftUint64: SetAsUInt64(AValue);
    ftDouble: SetAsDouble(AValue);
    ftDateTime: SetAsDateTime(AValue);
    ftString: SetAsString(AValue);
    ftWidestring: SetAsWideString(AValue);
    ftBlob: SetAsBlob(AValue);
  end;
end;

{ TSQLiteParameters }

procedure TSQLiteParameters.Bind;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Bind;
end;

procedure TSQLiteParameters.Clear;
begin
  fItems.Clear;
  fNameIndex.Clear;
end;

constructor TSQLiteParameters.Create(ADatabase: TSQLiteDatabase;
  AQuery: TSQLiteQuery);
begin
  inherited Create(ADatabase);
  fQuery := AQuery;
  fItems := TObjectList.Create(True);
  fNameIndex := TStringList.Create;
  fNameIndex.Sorted := True;
  fNameIndex.Duplicates := dupError;
end;

destructor TSQLiteParameters.Destroy;
begin
  FreeAndNil(fNameIndex);
  FreeAndNil(fItems);
  inherited Destroy;
end;

function TSQLiteParameters.FindParameter(const AName: string): TSQLiteParameter;
var
  lIndex: integer;
begin
  if fNameIndex.Find(AName, lIndex) then
    Result := TSQLiteParameter(fNameIndex.Objects[lIndex])
  else
    Result := nil;
end;

function TSQLiteParameters.GetCount: integer;
begin
  Result := fItems.Count;
end;

function TSQLiteParameters.GetItems(AIndex: integer): TSQLiteParameter;
begin
  Result := TSQLiteParameter(fItems[AIndex]);
end;

function TSQLiteParameters.GetItemsByName(
  const AName: string): TSQLiteParameter;
begin
  Result := FindParameter(AName);
  if Result = nil then
  begin
    Result := TSQLiteParameter.Create(fQuery.Database, fQuery, AName);
    fItems.Add(Result);
    fNameIndex.AddObject(AName, Result);
  end;
end;

{ TSQLiteQuery }

procedure TSQLiteQuery.Close;
begin
  if fCompiledSQL <> nil then
  begin
    try
      CheckCall(Database.API.SQLite3_Finalize(fCompiledSQL));
    finally
      fCompiledSQL := nil;
      fQueryState := qsClosed;
      fParameters.Clear;
    end;
  end;
end;

constructor TSQLiteQuery.Create(ADatabase: TSQLiteDatabase);
begin
  inherited Create(ADatabase);
  fParameters := TSQLiteParameters.Create(ADatabase, Self);
  fQueryState := qsClosed;
end;

destructor TSQLiteQuery.Destroy;
begin
  Close;
  FreeAndNil(fParameters);
  inherited Destroy;
end;

function TSQLiteQuery.ExecSQL(const ASQL: string): integer;
begin
  Open(ASQL);
  try
    Result := Execute;
  finally
    Close;
  end;
end;

function TSQLiteQuery.Execute: integer;
begin
  RaiseIfNotOpen;
  MoveFirst;
  Result := RowsAffected;
end;

function TSQLiteQuery.ExecuteScalar: integer;
begin
  RaiseIfNotOpen;
  MoveFirst;
  Result := FieldByIndex[0].AsInteger;
end;

procedure TSQLiteQuery.FieldsInitialized;
begin
  inherited FieldsInitialized;
  fParameters.Bind;
end;

function TSQLiteQuery.GetParamValue(const AName: string): Variant;
begin
  Result := Parameters.ItemsByName[AName].Value;
end;

procedure TSQLiteQuery.Open(const ASQL: string);
var
  lTail: Pointer;
begin
  Close;
  CheckCall(Database.API.SQLite3_Prepare16_v2(Database.DB, PChar(ASQL), Length(ASQL) * SizeOf(Char), fCompiledSQL, lTail));
  fQueryState := qsOpen;
  QueryOpened;
end;

procedure TSQLiteQuery.RaiseIfNotOpen;
begin
  if fQueryState <> qsOpen then
    raise ESQLException.Create('Query must be open to perform this operation.');
end;

function TSQLiteQuery.RowsAffected: integer;
begin
  Result := Database.API.SQLite3_Total_Changes(Database.DB);
end;

procedure TSQLiteQuery.SetParamValue(const AName: string;
  const AValue: Variant);
begin
  Parameters.ItemsByName[AName].Value := AValue;
end;

{ TSQLiteField }

function TSQLiteField.AsBlob(AStream: TStream = nil): TStream;
var
  lBytes: integer;
  lData: pointer;
begin
  if fDataType = ftBlob then
  begin
    if AStream <> nil then
      Result := AStream
    else
      Result := TMemoryStream.Create;
    lBytes := Database.API.SQLite3_Column_Bytes(fDataSet.CompiledSQL, fColumn);
    Result.Position := 0;
    Result.Size := 0;
    if lBytes > 0 then
    begin
      lData := Database.API.SQLite3_Column_Blob(fDataSet.CompiledSQL, fColumn);
      Result.WriteBuffer(lData^, lBytes);
      Result.Position := 0;
    end;
  end else
    raise ESQLException.Create('Field is not a BLOB type.');
end;

function TSQLiteField.AsBlobArray: TBytes;
var
  lStream: TStream;
begin
  if fDataType = ftBlob then
  begin
    lStream := TMemoryStream.Create;
    try
      AsBlob(lStream);
      if lStream.Size > 0 then
      begin
        lStream.Position := 0;
        SetLength(Result, lStream.Size);
        lStream.Read(Result, 0, Length(Result));
      end;
    finally
      lStream.Free;
    end;
  end else
    raise ESQLException.Create('Field is not a BLOB type.');
end;

function TSQLiteField.AsBlobString: string;
var
  I: Integer;
  lStream: TStream;
  lVal: Byte;
begin
  lStream := TMemoryStream.Create;
  try
    AsBlob(lStream);
    Result := '';
    if lStream.Size > 0 then
    begin
      lStream.Position := 0;
      for I := 0 to (lStream.Size div SizeOf(lVal)) - 1 do
      begin
        lStream.Read(lVal, SizeOf(lVal));
        Result := Result + IntToHex(lVal, 2);
      end;
    end;
  finally
    lStream.Free;
  end;
end;

function TSQLiteField.AsBoolean: boolean;
begin
  ReadValue;
  Result := fValue;
end;

function TSQLiteField.AsCardinal: cardinal;
begin
  ReadValue;
  Result := fValue;
end;

function TSQLiteField.AsDateTime: TDateTime;
begin
  ReadValue;
  Result := fValue;
end;

function TSQLiteField.AsFloat: double;
begin
  ReadValue;
  Result := fValue;
end;

function TSQLiteField.AsInt64: Int64;
begin
  ReadValue;
  Result := fValue;
end;

function TSQLiteField.AsInteger: integer;
begin
  ReadValue;
  Result := fValue;
end;

function TSQLiteField.AsString: AnsiString;
begin
  ReadValue;
  Result := AnsiString(VarToStr(fValue));
end;

function TSQLiteField.AsUInt64: UInt64;
begin
  ReadValue;
  Result := fValue;
end;

function TSQLiteField.AsWideString: string;
begin
  ReadValue;
  Result := VarToWideStr(fValue);
end;

constructor TSQLiteField.Create(ADatabase: TSQLiteDatabase;
  ADataSet: TSQLiteDataset; const AFieldName: string;
  AFieldType: TSQLiteFieldType; AColumn: integer);
begin
  inherited Create(ADatabase);
  fName := AFieldName;
  fDataType := AFieldType;
  fDataSet := ADataSet;
  fColumn := AColumn;
end;

procedure TSQLiteField.ReadValue;
begin
  case fDataType of
    ftString: fValue := AnsiString(Database.API.SQLite3_Column_Text(fDataSet.CompiledSQL, fColumn));
    ftWidestring: fValue := string(Database.API.SQLite3_Column_Text16(fDataSet.CompiledSQL, fColumn));
    ftBoolean: fValue := BOOL(Database.API.SQLite3_Column_Int(fDataSet.CompiledSQL, fColumn));
    ftInteger: fValue := Database.API.SQLite3_Column_Int(fDataSet.CompiledSQL, fColumn);
    ftCardinal: fValue := Cardinal(Database.API.SQLite3_Column_Int(fDataSet.CompiledSQL, fColumn));
    ftInt64: fValue := Int64(Database.API.SQLite3_Column_Int64(fDataSet.CompiledSQL, fColumn));
    ftUint64: fValue := Uint64(Database.API.SQLite3_Column_Int64(fDataSet.CompiledSQL, fColumn));
    ftDouble: fValue := Database.API.SQLite3_Column_Double(fDataSet.CompiledSQL, fColumn);
    ftDateTime: fValue := TDateTime(Database.API.SQLite3_Column_Double(fDataSet.CompiledSQL, fColumn));
    else fValue := Null;
  end;
end;

{ TSQLiteDataset }

constructor TSQLiteDataset.Create(ADatabase: TSQLiteDatabase);
begin
  inherited Create(ADatabase);
  fFields := TStringList.Create;
end;

destructor TSQLiteDataset.Destroy;
begin
  FreeFields;
  FreeAndNil(fFields);
  inherited Destroy;
end;

procedure TSQLiteDataset.FieldsInitialized;
begin

end;

function TSQLiteDataset.FindFieldIndex(const AName: string): integer;
begin
  if not fFields.Find(AName, Result) then
    Result := -1;
end;

procedure TSQLiteDataset.FreeFields;
var
  I: Integer;
begin
  for I := 0 to fFields.Count - 1 do
    fFields.Objects[I].Free;
  fFields.Clear;
end;

function TSQLiteDataset.GetFieldByIndex(AIndex: integer): TSQLiteField;
begin
  Result := TSQLiteField(fFields.Objects[AIndex]);
end;

function TSQLiteDataset.GetFieldByName(const AName: string): TSQLiteField;
var
  lIndex: integer;
begin
  lIndex := FindFieldIndex(AName);
  if lIndex >= 0 then
    Result := GetFieldByIndex(lIndex)
  else
    raise Exception.CreateFmt('Field "%s" not in dataset', [AName]);
end;

function TSQLiteDataset.GetFieldCount: integer;
begin
  Result := fFields.Count;
end;

procedure TSQLiteDataset.InitializeFields;
var
  I: Integer;
  lCols: integer;
  lColName: AnsiString;
  lColType: AnsiString;
  lColValType: TSQLiteFieldType;
  lField: TSQLiteField;
begin
  if not fFieldsInitialized then
  begin
    FreeFields;
    lCols := Database.API.SQLite3_Column_Count(CompiledSQL);
    for I := 0 to lCols - 1 do
    begin
      lColName := Database.API.SQLite3_Column_Name(CompiledSQL, I);
      lColType := Database.API.SQLite3_Column_Decltype(CompiledSQL, I);
      lColValType := Database.GetTypeBinding(UnicodeString(lColType));
      if (lColValType = ftUnknown) then
      begin
        if Pos('count(*)', Lowercase(UnicodeString(lColName))) > 0 then
        begin
          lColType := 'UINT32';
          lColValType := Database.GetTypeBinding(UnicodeString(lColType));
        end
        else
        if Pos('max(', Lowercase(UnicodeString(lColName))) > 0 then
        begin
          lColName := AnsiString(Copy(lColName, 5, Length(UnicodeString(lColName)) - 5));
          { TODO : figure out the declared type for this column }
          // http://www.sqlite.org/pragma.html#schema
          lColType := 'INT64';
          lColValType := Database.GetTypeBinding(UnicodeString(lColType));
        end
      end;
      if lColValType = ftUnknown then
        raise ESQLException.CreateFmt('Column "%s" type "%s" is not bound to a datatype.', [lColName, lColType]);
      lField := TSQLiteField.Create(Database, Self, UnicodeString(lColName), lColValType, I);
      fFields.AddObject(UnicodeString(lColName), lField);
    end;
    fFields.Sort;
    fFieldsInitialized := True;
    FieldsInitialized;
  end;
end;

procedure TSQLiteDataset.Invalidate;
begin
  fRecordNumber := 0;
  fEOF := False;
end;

procedure TSQLiteDataset.MoveFirst;
begin
  RaiseIfNotOpen;
  if fNeedsReset then
  begin
    Database.API.SQLite3_Reset(CompiledSQL);
    Invalidate;
  end;
  InitializeFields;
  Next;
end;

procedure TSQLiteDataset.Next;
var
  lRet: integer;
begin
  RaiseIfNotOpen;
  if EOF then
    raise ESQLException.Create('Dataset is at EOF.');
  fNeedsReset := True;
  lRet := Database.API.SQLite3_Step(CompiledSQL);
  case lRet of
    SQLITE_ROW: ;
    SQLITE_DONE: fEOF := True;
    else SQLiteError();
  end;
  if not EOF then
    Inc(fRecordNumber);
end;

procedure TSQLiteDataset.QueryOpened;
begin
  fNeedsReset := False;
  fFieldsInitialized := False;
  Invalidate;
end;

function TSQLiteDataset.RecordCount: UInt64;
begin
  MoveFirst;
  while not EOF do Next;
  Result := RecordNumber;
  MoveFirst;
end;

end.
