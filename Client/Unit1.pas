unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  OverbyteIcsTypes, OverbyteIcsWndControl, jpeg, OverbyteIcsWSocket,
  Vcl.StdCtrls, System.NetEncoding,zlib;

type
  TForm1 = class(TForm)
    WSocket1: TWSocket;
    Memo1: TMemo;
    Edit1: TEdit;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure WSocket1SessionConnected(Sender: TObject; ErrCode: Word);
    procedure WSocket1DataAvailable(Sender: TObject; ErrCode: Word);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  self.WSocket1.SendStr('MSG|' + self.Edit1.Text + #13#10);
  self.Memo1.Lines.Add('You Said: ' + Edit1.Text);
  self.Edit1.Clear;
  self.Edit1.SetFocus;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  WSocket1.Proto := 'tcp';
  WSocket1.Port := '3434';
  WSocket1.Addr := 'localhost';
  WSocket1.LineMode := TRUE;
  WSocket1.LineEnd := #13#10;
  WSocket1.Connect;
end;

procedure TForm1.WSocket1SessionConnected(Sender: TObject; ErrCode: Word);
var
  RandomNickName: string;
begin
  // Generate a random nickname
  Randomize;
  RandomNickName := 'User' + IntToStr(Random(1000)); // Example: User123
  self.Caption:= 'Client | ' + RandomNickName;
  // Send the "NewCon" message with the random nickname
  self.WSocket1.SendStr('NewCon|' + RandomNickName + #13#10);
end;

procedure TForm1.WSocket1DataAvailable(Sender: TObject; ErrCode: Word);
var
  ReceivedData: string;
  sl: TStringList;
begin
  ReceivedData := WSocket1.ReceiveStr;

  sl := TStringList.Create;
  try
    sl.Delimiter := '|';
    sl.StrictDelimiter := True;
    sl.DelimitedText := ReceivedData;

    if sl[0] = 'MSG' then
    begin
      Memo1.Lines.Add('Server Says: ' + sl[1]);
      Exit;
    end;
  finally
    sl.Free;
  end;
end;

end.
