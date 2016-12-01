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
    procedure btn_Save_SettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure spd_FwdComCheckClick(Sender: TObject);
    procedure spd_SrcComCheckClick(Sender: TObject);
  private
    { private declarations }
    procedure EnumComPorts(lst:TStrings);
    procedure LoadComponentValue(cmp: TComponent; iniF: TInifile);
    procedure LogAdd(LogWindow: TMemo; s: string);
    procedure SaveComponentValue(cmp: TComponent; iniF: TInifile);
  public
    { public declarations }
  end;

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
  Caption:=Application.Title;
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

procedure TfrmMain.EnumComPorts(lst: TStrings);
begin
  if not Assigned(lst) then
    Exit;

  lst.CommaText := GetSerialPortNames();
  lst.Insert(0,'');
end;

procedure TfrmMain.LogAdd(LogWindow: TMemo; s: string);
begin
  //
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  AppPath := GetCurrentDir;
  IniFName := AppPath+PathDelim+Application.ExeName+'.ini';
  IniF := TIniFile.Create(IniFName);
end;

procedure TfrmMain.btn_Save_SettingsClick(Sender: TObject);
begin

end;

procedure TfrmMain.LoadComponentValue(cmp: TComponent; iniF: TInifile);
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

procedure TfrmMain.SaveComponentValue(cmp: TComponent; iniF: TInifile);
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


end.

