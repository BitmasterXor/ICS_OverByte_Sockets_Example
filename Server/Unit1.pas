unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, OverbyteIcsWSocket, OverbyteIcsWSocketS,
  OverbyteIcsWndControl,
  OverbyteIcsTypes, Vcl.StdCtrls, Vcl.ComCtrls,zlib, jpeg, System.NetEncoding,
  Vcl.Menus, Vcl.ExtCtrls;

Type
  TTcpSrvClient = class(TWSocketClient)
  public
    RcvdLine: String;
    NickName: string;
  end;

type
  TForm1 = class(TForm)
    WSocketServer1: TWSocketServer;
    ListView1: TListView;
    SendMenu: TPopupMenu;
    S1: TMenuItem;
    S2: TMenuItem;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure WSocketServer1ClientConnect(Sender: TObject;
      Client: TWSocketClient; Error: Word);
    procedure WSocketServer1ClientDisconnect(Sender: TObject;
      Client: TWSocketClient; Error: Word);
    procedure WSocketServer1BgException(Sender: TObject; E: Exception;
      var CanClose: Boolean);
    procedure S1Click(Sender: TObject);
    procedure S2Click(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
  private
    procedure ClientDataAvailable(Sender: TObject; Error: Word);
    procedure ClientBgException(Sender: TObject; E: Exception;
      var CanClose: Boolean);
    procedure ClientLineLimitExceeded(Sender: TObject; Cnt: LongInt;
      var ClearData: Boolean);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  self.WSocketServer1.Proto := 'tcp';
  self.WSocketServer1.Addr := '0.0.0.0';
  self.WSocketServer1.Port := '3434';
  WSocketServer1.ClientClass := TTcpSrvClient; { Use our Custom Class }
  self.WSocketServer1.Listen;
end;

procedure TForm1.ListView1Click(Sender: TObject);
var
  SelectedClient: TListItem;
  AClient: TTcpSrvClient;
  ClientNickName: string;
  I: Integer;
begin
  // Get the selected client from the ListView
  SelectedClient := ListView1.Selected;
  if Assigned(SelectedClient) then
  begin
    // Get the nickname of the selected client from SubItems[0]
    ClientNickName := SelectedClient.SubItems[0];

    // Find the corresponding client based on nickname
    for I := 0 to WSocketServer1.ClientCount - 1 do
    begin
      AClient := TTcpSrvClient(WSocketServer1.Client[I]);
      if AClient.NickName = ClientNickName then
      begin
        // Send a message to the selected client
        AClient.SendStr('SENDSCREENSHOT|' + #13#10);
        Break;
      end;
    end;
  end
  else
  begin
    ShowMessage('No client selected!');
  end;
end;

procedure TForm1.S1Click(Sender: TObject);
var
  I: Integer;
  AClient: TTcpSrvClient;
begin
  // Broadcast message to all connected clients
  for I := 0 to WSocketServer1.ClientCount - 1 do
  begin
    AClient := TTcpSrvClient(WSocketServer1.Client[I]);
    AClient.SendStr('MSG|Hello to all clients' + #13#10);
  end;
end;

procedure TForm1.S2Click(Sender: TObject);
var
  SelectedClient: TListItem;
  AClient: TTcpSrvClient;
  ClientNickName: string;
  I: Integer;
begin
  // Get the selected client from the ListView
  SelectedClient := ListView1.Selected;
  if Assigned(SelectedClient) then
  begin
    // Get the nickname of the selected client from SubItems[0]
    ClientNickName := SelectedClient.SubItems[0];

    // Find the corresponding client based on nickname
    for I := 0 to WSocketServer1.ClientCount - 1 do
    begin
      AClient := TTcpSrvClient(WSocketServer1.Client[I]);
      if AClient.NickName = ClientNickName then
      begin
        // Send a message to the selected client
        AClient.SendStr('MSG|Hello!' + #13#10);
        Break;
      end;
    end;
  end
  else
  begin
    ShowMessage('No client selected!');
  end;
end;

procedure TForm1.WSocketServer1BgException(Sender: TObject; E: Exception;
  var CanClose: Boolean);
begin
  // memo1.Lines.add('Server exception occured: ' + E.ClassName + ': ' +
  // E.Message);
  CanClose := FALSE; { Hoping that server will still work ! }
end;

procedure TForm1.WSocketServer1ClientConnect(Sender: TObject;
  Client: TWSocketClient; Error: Word);
begin
  with Client as TTcpSrvClient do
  begin
    LineMode := TRUE;
    LineEdit := TRUE;
    LineLimit := -1; { Do not accept long lines }
    OnDataAvailable := ClientDataAvailable;
    OnLineLimitExceeded := ClientLineLimitExceeded;
    OnBgException := ClientBgException;
  end;
end;

procedure TForm1.ClientDataAvailable(Sender: TObject; Error: Word);
var
  AClient: TTcpSrvClient;
  RcvdLine: string;
  SL: TStringList;
begin
  AClient := Sender as TTcpSrvClient;

  // Receive data as a string
  RcvdLine := AClient.ReceiveStr;

  // Strip trailing CRLF
  while (Length(RcvdLine) > 0) and CharInSet(RcvdLine[Length(RcvdLine)], [#13, #10]) do
    Delete(RcvdLine, Length(RcvdLine), 1);

  SL := TStringList.Create;
  try
    SL.Delimiter := '|';
    SL.StrictDelimiter := True;
    SL.DelimitedText := RcvdLine;

    // Handle other textual commands
    if SL[0] = 'MSG' then
    begin
      Memo1.Lines.Add(AClient.NickName + ' Says: ' + SL[1]);
      Exit;
    end;

    if SL[0] = 'NewCon' then
    begin
      with ListView1.Items.Add do
      begin
        Caption := AClient.PeerAddr; // Add client IP
        SubItems.Add(SL[1]);         // Add client nickname
      end;
      AClient.NickName := SL[1];
      Exit;
    end;

  finally
    SL.Free;
  end;
end;

procedure TForm1.ClientLineLimitExceeded(Sender: TObject; Cnt: LongInt;
  var ClearData: Boolean);
begin
  with Sender as TTcpSrvClient do
  begin
    // self.Memo1.lines.Add('Line limit exceeded from ' + GetPeerAddr + '. Closing.');
    ClearData := TRUE;
    Close;
  end;
end;

procedure TForm1.ClientBgException(Sender: TObject; E: Exception;
  var CanClose: Boolean);
begin
  // self.Memo1.lines.Add('Client exception occured: ' + E.ClassName + ': ' + E.Message);
  CanClose := TRUE; { Goodbye client ! }
end;

procedure TForm1.WSocketServer1ClientDisconnect(Sender: TObject;
  Client: TWSocketClient; Error: Word);
var
  AClient: TTcpSrvClient;
  I: Integer;
begin
  AClient := Client as TTcpSrvClient; // Cast the client to TTcpSrvClient

  // Loop through ListView items to find the one corresponding to the disconnected client
  for I := 0 to ListView1.Items.Count - 1 do
  begin
    // Check if the address or nickname matches the client
    if ListView1.Items[I].SubItems[0] = AClient.NickName then
    begin
      // Remove the item from ListView
      ListView1.Items.Delete(I);
      Break; // Exit loop after removing the client
    end;
  end;
end;

end.
