unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, StdCtrls, Buttons, LazSerial

  , synaser
  , IniFiles
  , MuLibs    // general library
  , EditBtn


  ;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btn_Save_Settings: TButton;
    chk_SrcRxDsrSensivity: TCheckBox;
    chk_FwdRxDsrSensivity: TCheckBox;
    chk_SrcRxDtrEnable: TCheckBox;
    chk_FwdRxDtrEnable: TCheckBox;
    chk_SrcRxRtsEnable: TCheckBox;
    chk_FwdRxRtsEnable: TCheckBox;
    chk_SrcXonXoff: TCheckBox;
    chk_FwdXonXoff: TCheckBox;
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
    grd_Source: TGroupBox;
    grp_Forward: TGroupBox;
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
    mem_General: TMemo;
    pnl_LogsMain: TPanel;
    pgMain: TPageControl;
    spd_SrcComCheck: TSpeedButton;
    spd_FwdComCheck: TSpeedButton;
    Splitter4: TSplitter;
    tbLogs: TTabSheet;
    tbSettings: TTabSheet;
    tmrStartUp: TTimer;
    procedure btn_Save_SettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure spd_FwdComCheckClick(Sender: TObject);
    procedure spd_SrcComCheckClick(Sender: TObject);
    procedure tmrStartUpTimer(Sender: TObject);
  private
    { private declarations }
    procedure EnumComPorts(lst:TStrings);
    procedure LoadComponentValue(cmp: TComponent);
    procedure LogAdd(LogWindow: TMemo; s: string);
    procedure SaveComponentValue(cmp: TComponent);

    procedure SaveConf;
    procedure LoadConf;

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
  IniFName := AppPath+PathDelim+Application.ExeName+'.ini';
  IniF := TIniFile.Create(IniFName);
end;

procedure TfrmMain.btn_Save_SettingsClick(Sender: TObject);
begin
  SaveConf;
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


end.

