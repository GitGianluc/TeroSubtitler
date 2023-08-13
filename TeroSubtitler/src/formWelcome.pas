{*
 *  URUWorks
 *
 *  The contents of this file are used with permission, subject to
 *  the Mozilla Public License Version 2.0 (the "License"); you may
 *  not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/2.0.html
 *
 *  Software distributed under the License is distributed on an
 *  "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 *  implied. See the License for the specific language governing
 *  rights and limitations under the License.
 *
 *  Copyright (C) 2023 URUWorks, uruworks@gmail.com.
 *}

unit formWelcome;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, UWFlatButton, UWCheckBox, LResources;

type

  { TfrmWelcome }

  TfrmWelcome = class(TForm)
    bvlLine1: TBevel;
    bvlLine2: TBevel;
    bvlLine3: TBevel;
    bvlLine4: TBevel;
    chkShowOnStartup: TUWCheckBox;
    fbnBatchConvert: TUWFlatButton;
    fbnExit: TUWFlatButton;
    fbnNewTranscription: TUWFlatButton;
    ImageList_Dark: TImageList;
    ImageList_Default: TImageList;
    imgLogo: TImage;
    lblExit: TLabel;
    lblNewSubtitle: TLabel;
    lblNewTranscription: TLabel;
    lblOpenFile: TLabel;
    lblBatchConvert: TLabel;
    lblRecentFiles: TLabel;
    shaBackground: TShape;
    fbnNewSubtitle: TUWFlatButton;
    fbnOpenSubtitle: TUWFlatButton;
    shaBorder: TShape;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure fbnNewSubtitleClick(Sender: TObject);
    procedure fbnNewTranscriptionClick(Sender: TObject);
    procedure fbnOpenFileClick(Sender: TObject);
    procedure fbnBatchConvertClick(Sender: TObject);
    procedure fbnExitClick(Sender: TObject);
  private
    procedure MRUItemClick(Sender: TObject);
  public

  end;

var
  frmWelcome: TfrmWelcome;

// -----------------------------------------------------------------------------

implementation

uses
  procTypes, procFiles, procColorTheme, procCommon, procForms, formMain,
  procWorkspace;

{$R *.lfm}

// -----------------------------------------------------------------------------

{ TfrmWelcome }

// -----------------------------------------------------------------------------

procedure TfrmWelcome.FormCreate(Sender: TObject);
var
  i, h : Integer;
  lbl  : TLabel;
begin
  LoadLanguage(Self, False);
  chkShowOnStartup.Checked := AppOptions.ShowWelcomeAtStartup;

  h := lblRecentFiles.Top + lblRecentFiles.Height + 16;
  if MRU.Items.Count > 0 then
  for i := 0 to MRU.Items.Count-1 do
  begin
    lbl            := TLabel.Create(Self);
    lbl.Parent     := Self;
    lbl.SetBounds(lblRecentFiles.Left, h + (i*(lblRecentFiles.Height+6)), 400, 15);
    lbl.Caption    := ExtractFileName(MRU.Items[i]);
    lbl.Hint       := ExtractFilePath(MRU.Items[i]);
    lbl.ShowHint   := True;
    lbl.Tag        := i;
    lbl.Font.Color := ColorThemeInstance.Colors.Text;

    if not FileExists(MRU.Items[i]) then
    begin
      lbl.Enabled := False;
      lbl.Font.Style := lbl.Font.Style + [fsStrikeOut];
    end
    else
    begin
      lbl.Cursor  := crHandPoint;
      lbl.OnClick := @MRUItemClick;
    end;
  end;
end;

// -----------------------------------------------------------------------------

procedure TfrmWelcome.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  {$IFDEF DARWIN}
  if not frmMain.Visible then frmMain.Show;
  {$ENDIF}

  AppOptions.ShowWelcomeAtStartup := chkShowOnStartup.Checked;
  CloseAction := caFree;
  frmWelcome  := NIL;
end;

// -----------------------------------------------------------------------------

procedure TfrmWelcome.FormShow(Sender: TObject);
var
  png: TPortableNetworkGraphic;
begin
  ColorThemeInstance.Apply(Self, ColorThemeInstance.ColorMode, ImageList_Dark, ImageList_Default);
  png := TPortableNetworkGraphic.Create;
  try
    if ColorThemeInstance.GetRealColorMode = cmDark then
    begin
      png.LoadFromLazarusResource('terosubtitler_dark');
      shaBackground.Brush.Color := ColorThemeInstance.Colors.Window;
      shaBorder.Pen.Color       := ColorThemeInstance.Colors.Text;
    end
    else
    begin
      png.LoadFromLazarusResource('terosubtitler');
      fbnNewSubtitle.Color := shaBackground.Brush.Color;
      fbnNewTranscription.Color := fbnNewSubtitle.Color;
      fbnOpenSubtitle.Color := fbnNewSubtitle.Color;
      fbnBatchConvert.Color := fbnNewSubtitle.Color;
      fbnExit.Color := fbnNewSubtitle.Color;
      fbnNewSubtitle.DrawBuffer;
      fbnNewSubtitle.Invalidate;
      fbnNewTranscription.DrawBuffer;
      fbnNewTranscription.Invalidate;
      fbnOpenSubtitle.DrawBuffer;
      fbnOpenSubtitle.Invalidate;
      fbnBatchConvert.DrawBuffer;
      fbnBatchConvert.Invalidate;
      fbnExit.DrawBuffer;
      fbnExit.Invalidate;
    end;
    imgLogo.Picture.Graphic := png;
  finally
    png.Free;
  end;
end;

// -----------------------------------------------------------------------------

procedure TfrmWelcome.MRUItemClick(Sender: TObject);
begin
  Hide;
  SetViewMode(vmList);
  LoadSubtitle(MRU.Items[(Sender as TLabel).Tag]);
  Close;
end;

// -----------------------------------------------------------------------------

procedure TfrmWelcome.fbnNewSubtitleClick(Sender: TObject);
begin
  Hide;
  SetViewMode(vmList);
  NewSubtitle;
  Close;
end;

// -----------------------------------------------------------------------------

procedure TfrmWelcome.fbnNewTranscriptionClick(Sender: TObject);
begin
  Hide;
  SetViewMode(vmTranscription);
  Close;
end;

// -----------------------------------------------------------------------------

procedure TfrmWelcome.fbnOpenFileClick(Sender: TObject);
begin
  Hide;
  SetViewMode(vmList);
  LoadSubtitleWithDialog;
  Close;
end;

// -----------------------------------------------------------------------------

procedure TfrmWelcome.fbnBatchConvertClick(Sender: TObject);
begin
  Hide;
  ShowBatchConvert;
  Close;
end;

// -----------------------------------------------------------------------------

procedure TfrmWelcome.fbnExitClick(Sender: TObject);
begin
  frmMain.Close;
end;

// -----------------------------------------------------------------------------

initialization
{$I tero.lrs}

// -----------------------------------------------------------------------------

end.

