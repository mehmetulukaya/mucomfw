unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterAny,
  synhighlighterunixshellscript, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, Buttons, LazSerial

  , synaser
  , IniFiles
  , MuLibs    // general library
  , EditBtn, Grids


  ;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btn_FwdOpenCom: TButton;
    btn_Save_Settings: TButton;
    btn_SrcOpenCom: TButton;
    chk_SrcRxDsrSensivity: TCheckBox;
    chk_FwdRxDsrSensivity: TCheckBox;
    chk_InstRxDsrSensivity: TCheckBox;
    chk_SrcRxDtrEnable: TCheckBox;
    chk_FwdRxDtrEnable: TCheckBox;
    chk_SrcRxDtrEnable1: TCheckBox;
    chk_SrcRxRtsEnable: TCheckBox;
    chk_FwdRxRtsEnable: TCheckBox;
    chk_SrcRxRtsEnable1: TCheckBox;
    chk_SrcXonXoff: TCheckBox;
    chk_FwdXonXoff: TCheckBox;
    chk_SrcXonXoff1: TCheckBox;
    cmb_SrcCommBaud: TComboBox;
    cmb_FwdCommBaud: TComboBox;
    cmb_SrcCommDataBit: TComboBox;
    cmb_FwdCommDataBit: TComboBox;
    cmb_SrcCommParity: TComboBox;
    cmb_FwdCommParity: TComboBox;
    cmb_SrcCommPort: TComboBox;
    cmb_FwdCommPort: TComboBox;
    cmb_SrcCommStopBit: TComboBox;
    cmb_FwdCommStopBit: TComboBox;
    edt_SrcRxBuffSize: TEdit;
    edt_FwdRxBuffSize: TEdit;
    edt_SrcTxBuffSize: TEdit;
    edt_FwdTxBuffSize: TEdit;
    grd_InstBaud1: TStringGrid;
    grd_InstBaud2: TStringGrid;
    grd_InstBaud3: TStringGrid;
    grd_Source: TGroupBox;
    grp_InstBaud: TGroupBox;
    grp_Forward: TGroupBox;
    grp_InstBaud1: TGroupBox;
    grp_InstBaud2: TGroupBox;
    grp_InstBaud3: TGroupBox;
    grp_InstBaud4: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LazSerSrc: TLazSerial;
    LazSerFwd: TLazSerial;
    mem_HexLog: TMemo;
    mem_TextLog: TMemo;
    mem_General: TMemo;
    pnl_LogsMain: TPanel;
    pnl_LogTopMenu: TPanel;
    pgMain: TPageControl;
    spd_SrcComCheck: TSpeedButton;
    spd_FwdComCheck: TSpeedButton;
    spl_Logs: TSplitter;
    spl_Bottom: TSplitter;
    grd_InstBaud: TStringGrid;
    tbLogs: TTabSheet;
    tbSettings: TTabSheet;
    tmrStartUp: TTimer;
    procedure btn_FwdOpenComClick(Sender: TObject);
    procedure btn_SrcOpenComClick(Sender: TObject);
    procedure btn_Save_SettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LazSerFwdRxData(Sender: TObject);
    procedure LazSerSrcRxData(Sender: TObject);
    procedure spd_FwdComCheckClick(Sender: TObject);
    procedure spd_SrcComCheckClick(Sender: TObject);
    procedure tmrStartUpTimer(Sender: TObject);
  private
    procedure AppException(Sender: TObject; E: Exception);
    { private declarations }
    procedure EnumComPorts(lst:TStrings);
    procedure LoadComponentValue(cmp: TComponent);
    procedure LogAdd(LogWindow: TMemo; s: string);
    procedure SaveComponentValue(cmp: TComponent);

    procedure SaveConf;
    procedure LoadConf;
    function StrToBaudRate(baud_str: string): TBaudRate;
    function StrToDataBits(data_bits: string): TDataBits;
    function StrToParity(parity_str: string): TParity;
    function StrToStopBits(stop_bits: string): TStopBits;

  public
    { public declarations }
  end;

const
   max_log_line=10000;

var
  frmMain: TfrmMain;

  AppPath,
  IniFName: String;
  IniF : TIniFile;


implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormShow(Sender: TObject);
begin
  Caption:=Application.Title+' '+ProgramVersion;
  tmrStartUp.Enabled:=True;
end;

procedure TfrmMain.LazSerFwdRxData(Sender: TObject);
var
  s:String;
begin
  s:=LazSerFwd.ReadData;
  if s<>'' then
    if LazSerSrc.Active then
    begin
      LazSerSrc.WriteData(s);
      LogAdd(mem_HexLog,'RCV: '+StrToHex(s));
      LogAdd(mem_TextLog,'RCV: '+s);
    end;
end;

procedure TfrmMain.LazSerSrcRxData(Sender: TObject);
var
  s:String;
begin
  s:=LazSerSrc.ReadData;
  if s<>'' then
    if LazSerFwd.Active then
    begin
      LazSerFwd.WriteData(s);
      LogAdd(mem_HexLog,'SND: '+StrToHex(s));
      LogAdd(mem_TextLog,'SND: '+s);
    end;
end;

procedure TfrmMain.spd_FwdComCheckClick(Sender: TObject);
begin
  try
    EnumComPorts(cmb_FwdCommPort.Items);
  except
    LogAdd(mem_General,'Exception: Com port listing error!');
  end;
  cmb_FwdCommPort.DroppedDown:=True;
end;

procedure TfrmMain.spd_SrcComCheckClick(Sender: TObject);
begin
  try
    EnumComPorts(cmb_SrcCommPort.Items);
  except
    LogAdd(mem_General,'Exception: Com port listing error!');
  end;
  cmb_SrcCommPort.DroppedDown:=True;
end;

procedure TfrmMain.tmrStartUpTimer(Sender: TObject);
begin
  tmrStartUp.Enabled:=False;
  LogAdd(mem_General,'Started');
  EnumComPorts(cmb_SrcCommPort.Items);
  EnumComPorts(cmb_FwdCommPort.Items);
  LoadConf;
end;

procedure TfrmMain.EnumComPorts(lst: TStrings);
begin
  if not Assigned(lst) then
    Exit;

  lst.CommaText := GetSerialPortNames();
  lst.Insert(0,'');
end;

procedure TfrmMain.LogAdd(LogWindow: TMemo; s: string);
var
  log_time_str:String;
begin
  if LogWindow.Lines.Count>max_log_line then
    LogWindow.Clear;
  log_time_str:=FormatDateTime('DD.MM.YY HH:NN:SS.ZZZ',now);
  LogWindow.Lines.Add(log_time_str+' : '+s);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  AppPath := GetCurrentDir;
  IniFName := AppPath+PathDelim+'settings.ini';
  IniF := TIniFile.Create(IniFName);
  Application.OnException:=@AppException;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  mem_HexLog.Width:= pnl_LogsMain.ClientWidth div 2;
end;

procedure TfrmMain.btn_Save_SettingsClick(Sender: TObject);
begin
  SaveConf;
end;

procedure TfrmMain.btn_SrcOpenComClick(Sender: TObject);
begin
  if (cmb_SrcCommPort.Text = '') then
    Exit;

  if LazSerSrc.Active then
  begin
    try
      LazSerSrc.Close;
    finally
      btn_SrcOpenCom.Caption := 'Source Start';
      LogAdd(mem_General, 'COM Scr: Closed! ');
    end;
  end
  else
  begin
    with LazSerSrc do
    begin

      Device     := cmb_SrcCommPort.Text;
      BaudRate := StrToBaudRate(cmb_SrcCommBaud.Text);
      DataBits := StrToDataBits(cmb_SrcCommDataBit.Text);


      {if StrToInt(edt_TxBuffSize.Text) <> integer(Buffer.OutputSize) then
        Buffer.OutputSize := StrToInt(edt_TxBuffSize.Text);

      if StrToInt(edt_RxBuffSize.Text) <> integer(Buffer.InputSize) then
        Buffer.InputSize := StrToInt(edt_RxBuffSize.Text);}

        case cmb_SrcCommStopBit.ItemIndex  of
          1: StopBits := sbOne;
          2: StopBits := sbOneAndHalf;
          3: StopBits := sbTwo;
        end;

        case cmb_SrcCommParity.ItemIndex of
          0: Parity := pNone;
          1: Parity := pOdd;
          2: Parity := pEven;
          3: Parity := pMark;
          4: Parity := pSpace;
        end;

        if (frmMain.chk_SrcRxDtrEnable.Checked) or
           (frmMain.chk_SrcRxRtsEnable.Checked) or
           (frmMain.chk_SrcRxDsrSensivity.Checked) then
          FlowControl := fcHardware
        else
          FlowControl := fcNone;

        if frmMain.chk_SrcXonXoff.Checked then
        begin
          FlowControl  := fcXonXoff;
        end
        else
        begin
          FlowControl  := fcNone;
        end;

        try
          LazSerSrc.Open;
          btn_SrcOpenCom.Caption := 'Source Stop';
        except
          exit;
        end;

        if LazSerSrc.Active then
        begin
          LogAdd(mem_General, 'COM Scr: Opened... ');
        end
        else
          LogAdd(mem_General, 'COM Scr: Did`t open... ');

      end; //with LazSerSrc do

  end;

end;

procedure TfrmMain.btn_FwdOpenComClick(Sender: TObject);
begin
  if (cmb_FwdCommPort.Text = '') then
    Exit;

  if LazSerFwd.Active then
  begin
    try
      LazSerFwd.Close;
    finally
      btn_FwdOpenCom.Caption := 'Forward Start';
      LogAdd(mem_General, 'COM Fwd: Closed! ');
    end;
  end
  else
  begin
    with LazSerFwd do
    begin

      Device     := cmb_FwdCommPort.Text;
      BaudRate := StrToBaudRate(cmb_FwdCommBaud.Text);
      DataBits := StrToDataBits(cmb_FwdCommDataBit.Text);


      {if StrToInt(edt_TxBuffSize.Text) <> integer(Buffer.OutputSize) then
        Buffer.OutputSize := StrToInt(edt_TxBuffSize.Text);

      if StrToInt(edt_RxBuffSize.Text) <> integer(Buffer.InputSize) then
        Buffer.InputSize := StrToInt(edt_RxBuffSize.Text);}

        case cmb_FwdCommStopBit.ItemIndex  of
          1: StopBits := sbOne;
          2: StopBits := sbOneAndHalf;
          3: StopBits := sbTwo;
        end;

        case cmb_FWdCommParity.ItemIndex of
          0: Parity := pNone;
          1: Parity := pOdd;
          2: Parity := pEven;
          3: Parity := pMark;
          4: Parity := pSpace;
        end;

        if (frmMain.chk_FwdRxDtrEnable.Checked) or
           (frmMain.chk_FwdRxRtsEnable.Checked) or
           (frmMain.chk_FwdRxDsrSensivity.Checked) then
          FlowControl := fcHardware
        else
          FlowControl := fcNone;

        if frmMain.chk_FwdXonXoff.Checked then
        begin
          FlowControl  := fcXonXoff;
        end
        else
        begin
          FlowControl  := fcNone;
        end;

        try
          LazSerFwd.Open;
          btn_FwdOpenCom.Caption := 'Forward Stop';
        except
          exit;
        end;

        if LazSerFwd.Active then
        begin
          LogAdd(mem_General, 'COM Fwd: Opened... ');
        end
        else
          LogAdd(mem_General, 'COM Fwd: Did`t open... ');

      end; //with LazSerSrc do

  end;

end;

procedure TfrmMain.LoadComponentValue(cmp: TComponent);
const
   section = 'COMP';
begin
  // Load component values from ini file
  if (cmp is TEdit) then
    with (cmp as TEdit) do
      Text := iniF.ReadString(section,cmp.Name, Text );

  if (cmp is TCheckBox) then
    with (cmp as TCheckBox) do
      Checked := iniF.ReadBool(section,cmp.Name, Checked );

  if (cmp is TRadioButton) then
    with (cmp as TRadioButton) do
      Checked := iniF.ReadBool(section,cmp.Name, Checked );

  if (cmp is TListBox) then
    with (cmp as TListBox) do
      ItemIndex := iniF.ReadInteger(section,cmp.Name, ItemIndex );

  if (cmp is TComboBox) then
    with (cmp as TComboBox) do
      ItemIndex := iniF.ReadInteger(section,cmp.Name, ItemIndex );

  if (cmp is TFileNameEdit) then
    with (cmp as TFileNameEdit) do
      FileName := iniF.ReadString(section,cmp.Name, FileName );

  if (cmp is TFontDialog) then
    with (cmp as TFontDialog) do
    begin
      Font.Color:=iniF.ReadInteger(section,cmp.Name+'.Font.Color', Font.Color);
      iniF.WriteInteger(section,cmp.Name+'.Font.Size', Font.Size );
    end;

end;

procedure TfrmMain.SaveComponentValue(cmp: TComponent);
const
   section = 'COMP';
begin
  // Save component values into ini file
  if (cmp is TEdit) then
    with (cmp as TEdit) do
      iniF.WriteString(section,cmp.Name, Text );

  if (cmp is TCheckBox) then
    with (cmp as TCheckBox) do
      iniF.WriteBool(section,cmp.Name, Checked );

  if (cmp is TRadioButton) then
    with (cmp as TRadioButton) do
      iniF.WriteBool(section,cmp.Name, Checked );

  if (cmp is TListBox) then
    with (cmp as TListBox) do
      iniF.WriteInteger(section,cmp.Name, ItemIndex );

  if (cmp is TComboBox) then
    with (cmp as TComboBox) do
      iniF.WriteInteger(section,cmp.Name, ItemIndex );

  if (cmp is TFileNameEdit) then
    with (cmp as TFileNameEdit) do
      iniF.WriteString(section,cmp.Name, FileName );

  if (cmp is TFontDialog) then
    with (cmp as TFontDialog) do
    begin
      iniF.WriteInteger(section,cmp.Name+'.Font.Color', Font.Color );
      iniF.WriteInteger(section,cmp.Name+'.Font.Size', Font.Size );
    end;

end;

procedure TfrmMain.SaveConf;
begin
  SaveComponentValue(cmb_SrcCommBaud);
  SaveComponentValue(cmb_SrcCommDataBit);
  SaveComponentValue(cmb_SrcCommParity);
  SaveComponentValue(cmb_SrcCommPort);
  SaveComponentValue(cmb_SrcCommStopBit);

  SaveComponentValue(cmb_FwdCommBaud);
  SaveComponentValue(cmb_FwdCommDataBit);
  SaveComponentValue(cmb_FwdCommParity);
  SaveComponentValue(cmb_FwdCommPort);
  SaveComponentValue(cmb_FwdCommStopBit);

  SaveComponentValue(chk_SrcRxDsrSensivity);
  SaveComponentValue(chk_SrcRxDtrEnable);
  SaveComponentValue(chk_SrcRxRtsEnable);
  SaveComponentValue(chk_SrcXonXoff);

  SaveComponentValue(chk_FwdRxDsrSensivity);
  SaveComponentValue(chk_FwdRxDtrEnable);
  SaveComponentValue(chk_FwdRxRtsEnable);
  SaveComponentValue(chk_FwdXonXoff);

  SaveComponentValue(edt_SrcRxBuffSize);
  SaveComponentValue(edt_SrcTxBuffSize);

  SaveComponentValue(edt_FwdRxBuffSize);
  SaveComponentValue(edt_FwdTxBuffSize);

end;

procedure TfrmMain.LoadConf;
begin
  LoadComponentValue(cmb_SrcCommBaud);
  LoadComponentValue(cmb_SrcCommDataBit);
  LoadComponentValue(cmb_SrcCommParity);
  LoadComponentValue(cmb_SrcCommPort);
  LoadComponentValue(cmb_SrcCommStopBit);

  LoadComponentValue(cmb_FwdCommBaud);
  LoadComponentValue(cmb_FwdCommDataBit);
  LoadComponentValue(cmb_FwdCommParity);
  LoadComponentValue(cmb_FwdCommPort);
  LoadComponentValue(cmb_FwdCommStopBit);

  LoadComponentValue(chk_SrcRxDsrSensivity);
  LoadComponentValue(chk_SrcRxDtrEnable);
  LoadComponentValue(chk_SrcRxRtsEnable);
  LoadComponentValue(chk_SrcXonXoff);

  LoadComponentValue(chk_FwdRxDsrSensivity);
  LoadComponentValue(chk_FwdRxDtrEnable);
  LoadComponentValue(chk_FwdRxRtsEnable);
  LoadComponentValue(chk_FwdXonXoff);

  LoadComponentValue(edt_SrcRxBuffSize);
  LoadComponentValue(edt_SrcTxBuffSize);

  LoadComponentValue(edt_FwdRxBuffSize);
  LoadComponentValue(edt_FwdTxBuffSize);

end;

procedure TfrmMain.AppException(Sender: TObject; E: Exception);
begin
  LogAdd(mem_General,'INF: Exception: '+Sender.ClassName+' Mes:'+E.Message);
end;

function TfrmMain.StrToBaudRate(baud_str: string): TBaudRate;
const
  ConstBaud: array[0..17] of integer=(110,
    300, 600, 1200, 2400, 4800, 9600,14400, 19200, 38400,56000, 57600,
    115200,128000,230400,256000, 460800, 921600);
var
   baud : integer;
   n : integer;
begin
  try
    baud := StrToInt(baud_str);
    for n:= Low(ConstBaud) to High(ConstBaud) do
      begin
        if ConstBaud[n]=baud then
          begin
            Result := TBaudRate(n);
            Break;
          end;
      end;
  except
    Result := br__9600;
  end;
end;

function TfrmMain.StrToDataBits(data_bits: string): TDataBits;
const
  ConstBits: array[0..3] of integer=(8, 7 , 6, 5);
var
   bits : integer;
   n : integer;
begin
  try
    bits := StrToInt(data_bits);
    for n:= Low(ConstBits) to High(ConstBits) do
      begin
        if ConstBits[n]=bits then
          begin
            Result := TDataBits(n);
            Break;
          end;
      end;
  except
    Result := db8bits;
  end;
end;

function TfrmMain.StrToParity(parity_str: string): TParity;
const
  ConstParity: array[0..4] of char=('N', 'O', 'E', 'M', 'S');
var
   n : integer;
begin
  try
    for n:= Low(ConstParity) to High(ConstParity) do
      begin
        if ConstParity[n]=parity_str[1] then  // Even,None,Odd first char
          begin
            Result := TParity(n);
            Break;
          end;
      end;
  except
    Result := pNone;
  end;
end;

function TfrmMain.StrToStopBits(stop_bits: string): TStopBits;
begin
  Result := sbOne;
  case stop_bits of
    '1'   : Result := sbOne;
    '1.5' : Result := sbOneAndHalf;
    '2'   : Result := sbTwo;
  end;
end;

end.

