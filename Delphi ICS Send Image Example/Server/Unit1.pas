unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, OverbyteIcsWSocket, OverbyteIcsWSocketS, OverbyteIcsTypes,
  OverbyteIcsWndControl, Vcl.ComCtrls;

// Form definition
type
  TForm1 = class(TForm)
    WSocketServer1: TWSocketServer; // TCP server component
    Image1: TImage; // Displays received images
    MemoLog: TMemo; // Logs server events
    ButtonStart: TButton; // Start server button
    ButtonStop: TButton; // Stop server button
    ProgressBar1: TProgressBar; // Shows image reception progress
    procedure ButtonStartClick(Sender: TObject); // Start server
    procedure ButtonStopClick(Sender: TObject); // Stop server
    procedure WSocketServer1ClientConnect(Sender: TObject;
      Client: TWSocketClient; Error: Word); // Handle client connections
    procedure WSocketServer1ClientDisconnect(Sender: TObject;
      Client: TWSocketClient; Error: Word); // Handle client disconnections
    procedure FormCreate(Sender: TObject); // Form initialization
  private
    procedure ClientDataAvailable(Sender: TObject; Error: Word);
    // Handle incoming data
    procedure LogMessage(const Msg: string); // Log messages to MemoLog
  public
  end;

var
  ServerForm: TForm1;

implementation

{$R *.dfm}

// Custom client class for handling image data
type
  TImageClient = class(TWSocketClient)
  private
    FStream: TMemoryStream; // Stores received image data
    FSize: Cardinal; // Expected image size
    FReceived: Cardinal; // Bytes received so far
    FSizeStr: string; // String representation of image size
    FSizeReceived: Boolean; // Whether size has been received
  public
    constructor Create(AOwner: TComponent); override; // Constructor
    destructor Destroy; override; // Destructor
    procedure ResetState; // Reset client state for new image
  end;

  // Constructor: initializes memory stream and resets state
constructor TImageClient.Create(AOwner: TComponent);
begin
  inherited;
  FStream := TMemoryStream.Create;
  ResetState;
end;

// Reset client state for receiving new image
procedure TImageClient.ResetState;
begin
  FSize := 0;
  FReceived := 0;
  FSizeReceived := False;
  FSizeStr := '';
  FStream.Clear;
end;

// Destructor: frees memory stream
destructor TImageClient.Destroy;
begin
  FStream.Free;
  inherited;
end;

// Start the server
procedure TForm1.ButtonStartClick(Sender: TObject);
begin
  WSocketServer1.Proto := 'tcp'; // Protocol: TCP
  WSocketServer1.Port := '9001'; // Port number
  WSocketServer1.Addr := '0.0.0.0'; // Listen on all interfaces
  WSocketServer1.ClientClass := TImageClient; // Use custom client class
  try
    WSocketServer1.Listen; // Start listening for connections
    LogMessage('Server listening on port ' + WSocketServer1.Port);
    ButtonStart.Enabled := False;
    ButtonStop.Enabled := True;
  except
    on E: Exception do
      LogMessage('Error starting server: ' + E.Message);
  end;
end;

// Stop the server
procedure TForm1.ButtonStopClick(Sender: TObject);
begin
  WSocketServer1.DisconnectAll; // Disconnect all clients
  WSocketServer1.Close; // Stop listening
  LogMessage('Server stopped');
  ButtonStart.Enabled := True;
  ButtonStop.Enabled := False;
end;

// Handle new client connections
procedure TForm1.WSocketServer1ClientConnect(Sender: TObject;
  Client: TWSocketClient; Error: Word);
begin
  LogMessage('Client connected from: ' + Client.PeerAddr);
  Client.OnDataAvailable := ClientDataAvailable; // Set data handler
end;

// Handle client disconnections
procedure TForm1.WSocketServer1ClientDisconnect(Sender: TObject;
  Client: TWSocketClient; Error: Word);
begin
  LogMessage('Client disconnected: ' + Client.PeerAddr);
end;

// update progress bar percentage of recieved image...
procedure UpdateProgress(thevalue: integer);
begin
  ServerForm.ProgressBar1.Position := thevalue;
end;

// Handle incoming data from a client
procedure TForm1.ClientDataAvailable(Sender: TObject; Error: Word);
var
  Client: TImageClient;
  Buffer: array [0 .. 8191] of Byte; // Data buffer
  Count: integer; // Bytes received
  SizeBuffer: array [0 .. 9] of AnsiChar; // Buffer for size string
  Icon: TIcon; // Icon object for ICO files
  Magic: array [0 .. 3] of Byte; // Magic number for file type
  IsIcon: Boolean; // Flag for detecting ICO files
begin
  Client := TImageClient(Sender);

  // Receive size string (first 10 bytes)
  if not Client.FSizeReceived then
  begin
    Count := Client.Receive(@SizeBuffer, 10);
    if Count = 10 then
    begin
      SetString(Client.FSizeStr, SizeBuffer, 10);
      Client.FSize := StrToIntDef(Client.FSizeStr, 0);
      Client.FSizeReceived := True;
      LogMessage('Size string received: ' + Client.FSizeStr);
      LogMessage('Expected image size: ' + IntToStr(Client.FSize));
    end
    else
      Exit; // Wait for more data
  end;

  // Receive image data
  if (Client.FSize > 0) then
  begin
    repeat
      Count := Client.Receive(@Buffer, SizeOf(Buffer));
      if Count <= 0 then
        Break;

      Client.FStream.WriteBuffer(Buffer, Count); // Write to memory stream
      Client.FReceived := Client.FReceived + Count; // Update received count

      LogMessage(Format('Received %d of %d bytes (%.1f%%)', [Client.FReceived,
        Client.FSize, (Client.FReceived / Client.FSize) * 100]));

      UpdateProgress(Client.FReceived div Client.FSize * 100);

      // Check if image is fully received
      if Client.FReceived >= Client.FSize then
      begin
        Client.FStream.Position := 0;
        try
          Client.FStream.ReadBuffer(Magic, SizeOf(Magic));
          // Read file signature
          Client.FStream.Position := 0;

          // Check for ICO file signature (00 00 01 00)
          IsIcon := (Magic[0] = 0) and (Magic[1] = 0) and (Magic[2] = 1) and
            (Magic[3] = 0);

          if IsIcon then
          begin
            LogMessage('Detected ICO format');
            Icon := TIcon.Create;
            try
              Icon.LoadFromStream(Client.FStream);
              Image1.Picture.Assign(Icon);
            finally
              Icon.Free;
            end;
          end
          else
          begin
            LogMessage('Loading as standard image format');
            Image1.Picture.LoadFromStream(Client.FStream);
          end;
          LogMessage('Image received and displayed successfully');
        except
          on E: Exception do
          begin
            LogMessage('Error loading image: ' + E.Message);
          end;
        end;

        Client.ResetState; // Prepare for next image
        Break;
      end;
    until False;
  end;
end;

// Form initialization
procedure TForm1.FormCreate(Sender: TObject);
begin
  // Placeholder for additional initialization if needed
end;

// Log a message to the memo
procedure TForm1.LogMessage(const Msg: string);
begin
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ': ' + Msg);
end;

end.
