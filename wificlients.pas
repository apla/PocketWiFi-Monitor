unit WiFiClients;
// eMobile D25HW/GP01/GP02 Pocket WiFi Access Object - Client List
//@000 2012.08.07 Noah SILVA First Version.

{$mode objfpc}

interface

uses
  Classes, SysUtils, EMConst;

Type
  TWiFiClientList=class(TObject)
    Private
      const
        _url:UTF8String='http://' + ip_addr + '/api/wlan/host-list';
      var
        _LastResult : String;
        _http_timeout : integer;
        _cache_timeout_ms:integer;
        _last_check:TDateTime;
        // This is the raw XMl data retrieved from the HTTP Request
        _xml_data:TStringList;
      Function _StateChanged:Boolean;
      // internal function to perform HTTP GET request
      Function _DoCheck:boolean;       // HTTP GET
      // Parse the raw XML into more useful structure
      Procedure _DoParse;
    Public
      Constructor Create;
      Destructor Destroy;
      Procedure Update;
      // Returns true if there is internet connectivity.
      // Specifically, not just that a connection is active, but that we can request
      // a ping and/or HTTP request to a public IP address or DNS name.
      // Set wait to true if you want to recheck, false to give last result.
//      Property Connected:Boolean read _IsConnected;
      Property StateChanged:Boolean read _StateChanged;
      Property XMLData:TStringList read _xml_data;
  end;

// global Instance
Var
  WiFiClientList:TWiFiClientList;

implementation

uses
  httpsend, // Synapse
  md5;      // MD5Print;

Constructor TWiFiClientList.Create;
  begin
    inherited;
    _http_timeout := 500;
    _cache_timeout_ms := 5000;
    _xml_data := TStringList.Create;
  end;

Destructor TWiFiClientList.Destroy;
  begin
    _xml_data.free;
    inherited;
  end;

Function TWiFiClientList._StateChanged:Boolean;
  var
    tmp:Boolean;
    NewHash:String;
  begin
    NewHash := MD5Print(MD5String(_xml_data.text));
    Result := (NewHash <> _LastResult);
    _LastResult := NewHash;
  end;

Function TWiFiClientList._DoCheck:boolean;
 var
   Success:Boolean;
 begin
    // One possible option, Google also has their own
    try
      Success := httpgettext(_URL, _xml_data, _http_timeout);
      // The following is for unmodified Synapse Library
//      Success := httpgettext(_test_URL, data);
      // for now we only check one host, so the result is always equal to that
      // result.

      Result := Success;
      _last_check := now;
    finally
    end;
 end; // of Function

Procedure TWiFiClientList.Update;
  begin
    _DoCheck;
    if _statechanged then _DoParse;
  end;

Procedure TWiFiClientList._DoParse;
  begin
    // parse the XML data to populate internal structures
  end;

Initialization
  WiFiClientList := TWiFiClientList.create;
Finalization
  WiFiClientList.Destroy;
end.

