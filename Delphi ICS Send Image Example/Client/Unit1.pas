unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, OverbyteIcsWSocket, OverbyteIcsTypes, Vcl.ExtDlgs,
  OverbyteIcsWndControl, Vcl.Imaging.jpeg, Vcl.Imaging.pngimage;

// Form definition
type
  TForm1 = class(TForm)
    WSocket1: TWSocket; // Client socket for connecting to the server
    Image1: TImage; // Displays the selected image
    ButtonConnect: TButton; // Button to connect/disconnect from the server
    ButtonSendImage: TButton; // Button to send the selected image
    ButtonBrowse: TButton; // Button to browse for an image
    OpenPictureDialog1: TOpenPictureDialog; // File dialog for selecting images
    MemoLog: TMemo; // Displays log messages
    procedure FormCreate(Sender: TObject); // Initializes the form
    procedure ButtonConnectClick(Sender: TObject); // Handles connect/disconnect
    procedure ButtonBrowseClick(Sender: TObject); // Handles image browsing
    procedure ButtonSendImageClick(Sender: TObject); // Handles image sending
    procedure WSocket1SessionConnected(Sender: TObject; Error: Word); // Handles successful connection
    procedure WSocket1SessionClosed(Sender: TObject; Error: Word); // Handles disconnection
  private
    FFileName: string; // Stores the selected file name
    procedure LogMessage(const Msg: string); // Logs messages to the memo
  public
    Connected: boolean; // Tracks connection status
  end;

var
  ClientForm: TForm1;

implementation

{$R *.dfm}

// Initialize the form
procedure TForm1.FormCreate(Sender: TObject);
begin
  self.Connected := false; // Default to not connected
end;

// Handle connect/disconnect button click
procedure TForm1.ButtonConnectClick(Sender: TObject);
begin
  if not self.Connected then
  begin
    WSocket1.Addr := '127.0.0.1'; // Set server address (localhost)
    try
      WSocket1.Proto := 'tcp'; // Use TCP protocol
      WSocket1.Port := '9001'; // Server port
      WSocket1.Connect; // Connect to the server
    except
      on E: Exception do
        LogMessage('Connection error: ' + E.Message); // Log errors
    end;
  end
  else
  begin
    WSocket1.Close; // Disconnect from the server
    ButtonConnect.Caption := 'Connect';
  end;
end;

// Handle image browsing
procedure TForm1.ButtonBrowseClick(Sender: TObject);
begin
  // Filter supported image formats
  OpenPictureDialog1.Filter := 'All Images|*.bmp;*.jpg;*.jpeg;*.png;*.gif|Bitmap Files|*.bmp|JPEG Files|*.jpg;*.jpeg|PNG Files|*.png|GIF Files|*.gif';

  if OpenPictureDialog1.Execute then
  begin
    FFileName := OpenPictureDialog1.FileName; // Get selected file name
    try
      Image1.Picture.LoadFromFile(FFileName); // Load image into the component
      ButtonSendImage.Enabled := True; // Enable send button
      LogMessage('Image loaded: ' + ExtractFileName(FFileName)); // Log success
    except
      on E: Exception do
      begin
        LogMessage('Error loading image: ' + E.Message); // Log errors
        FFileName := ''; // Clear file name on error
        ButtonSendImage.Enabled := false; // Disable send button
      end;
    end;
  end;
end;

// Handle image sending
procedure TForm1.ButtonSendImageClick(Sender: TObject);
var
  Stream: TMemoryStream; // Memory stream for the image
  Size: Cardinal; // Image size
  SizeStr: string; // Size formatted as a fixed-length string
  Buffer: array [0 .. 8191] of Byte; // Buffer for sending chunks
  BytesRead: Integer; // Bytes read from the stream
  BytesSent: Integer; // Bytes sent to the server
begin
  if not self.Connected then
  begin
    LogMessage('Not connected to server'); // Log if not connected
    Exit;
  end;

  if FFileName = '' then
  begin
    LogMessage('No image selected'); // Log if no image selected
    Exit;
  end;

  Stream := TMemoryStream.Create;
  try
    // Load file into memory stream
    Stream.LoadFromFile(FFileName);
    Size := Stream.Size;

    // Log file size
    LogMessage('File size: ' + IntToStr(Size));

    // Format size as a 10-digit string (zero-padded)
    SizeStr := Format('%.10d', [Size]);
    LogMessage('Sending size string: ' + SizeStr);

    // Send the size string to the server
    if WSocket1.Send(PAnsiChar(AnsiString(SizeStr)), 10) < 10 then
    begin
      LogMessage('Failed to send size information');
      Exit;
    end;

    // Small delay to ensure the size is processed by the server
    Sleep(100);

    // Send image data in chunks
    Stream.Position := 0; // Start from the beginning
    repeat
      BytesRead := Stream.Read(Buffer, SizeOf(Buffer)); // Read a chunk
      if BytesRead <= 0 then
        Break;

      BytesSent := WSocket1.Send(@Buffer, BytesRead); // Send the chunk
      if BytesSent < 0 then
      begin
        LogMessage('Error sending data'); // Log if sending fails
        Exit;
      end;

      // Log the progress
      LogMessage('Sent chunk of ' + IntToStr(BytesSent) + ' bytes');
    until BytesRead < SizeOf(Buffer);

    LogMessage('Image sent to server (' + IntToStr(Size) + ' bytes total)');
  finally
    Stream.Free; // Free the memory stream
  end;
end;

// Handle successful connection
procedure TForm1.WSocket1SessionConnected(Sender: TObject; Error: Word);
begin
  if Error = 0 then
  begin
    LogMessage('Connected to server'); // Log successful connection
    self.Connected := True;
    ButtonConnect.Caption := 'Disconnect'; // Update button text
    ButtonBrowse.Enabled := True; // Enable image browsing
  end
  else
    LogMessage('Connection failed with error: ' + IntToStr(Error)); // Log error
end;

// Handle disconnection
procedure TForm1.WSocket1SessionClosed(Sender: TObject; Error: Word);
begin
  self.Connected := false; // Update connection status
  LogMessage('Disconnected from server'); // Log disconnection
  ButtonConnect.Caption := 'Connect'; // Update button text
  ButtonBrowse.Enabled := false; // Disable image browsing
  ButtonSendImage.Enabled := false; // Disable send button
end;

// Log a message to the memo
procedure TForm1.LogMessage(const Msg: string);
begin
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ': ' + Msg);
end;

end.

