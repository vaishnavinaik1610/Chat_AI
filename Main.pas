unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, REST.Types,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, FMX.Colors,
  FMX.Memo.Types, FMX.StdCtrls, FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation, System.ImageList, FMX.ImgList, FMX.Effects,
  FMX.Edit, FMX.Objects, FMX.Layouts, System.Skia, FMX.Skia;

const
  cKey = 'Generate API key at https://makersuite.google.com/app/apikey';
  cMsgHeight = 50;

type
  TMsgSender = (msUser, msBot);

  TFrm_Main = class(TForm)
    PN_Credits: TRectangle;
    PN_Request: TRectangle;
    SP_Send: TSpeedButton;
    Lst_Icons: TImageList;
    RESTRequest1: TRESTRequest;
    RESTClient1: TRESTClient;
    RESTResponse1: TRESTResponse;
    ED_Request: TEdit;
    ShadowEffect1: TShadowEffect;
    VSB_Background: TVertScrollBox;
    Img_User: TImage;
    Img_Bot: TImage;
    L_Credit: TLabel;
    Rect_Space: TRectangle;
    Img_Gemini: TSkSvg;
    procedure SP_SendClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ED_RequestKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SetMsgHeight(Sender: TObject);
    procedure InitialiseAPIRequest();
    function SendAPIRequest(aPrompt: String) : String;
    procedure AddMessage(const AText: String; AMsgSender: TMsgSender);
  public
    { Public declarations }
  end;

var
  Frm_Main: TFrm_Main;

implementation

{$R *.fmx}

procedure TFrm_Main.ED_RequestKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  if key = vkReturn then
    SP_SendClick(Sender);
end;

procedure TFrm_Main.FormCreate(Sender: TObject);
begin
  Img_User.Visible := False;
  Img_Bot.Visible := False;
end;

procedure TFrm_Main.FormShow(Sender: TObject);
begin
  InitialiseAPIRequest();
end;

procedure TFrm_Main.InitialiseAPIRequest();
begin
  RESTClient1.BaseURL := 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=' + cKey;

  RESTRequest1.Client := RESTClient1;
  RESTRequest1.Response := RESTResponse1;
  RESTRequest1.Method := rmPOST;

  RESTRequest1.Params.AddItem;
  RESTRequest1.Params[0].Name := 'ParamContent';
  RESTRequest1.Params[0].Kind := pkREQUESTBODY;
  RESTRequest1.Params[0].ContentType := 'application/json';
end;

function TFrm_Main.SendAPIRequest(aPrompt: String) : String;
begin
  if aPrompt = '' then exit;

  RESTRequest1.Params[0].Value := '{ "contents": [{ "parts":[{ "text": "' + aPrompt + '"}]}]}';
  try
    RESTRequest1.Execute;
    Result := RESTResponse1.JSONValue.GetValue<string>('candidates[0].content.parts[0].text');
  finally
  end;
end;

procedure TFrm_Main.SP_SendClick(Sender: TObject);
var
  Prompt: String;
begin
  if ED_Request.Text = '' then exit;
  
  Prompt := ED_Request.Text;
  ED_Request.Text := '';
  ED_Request.TextPrompt := 'Generating Response . . .';
  AddMessage(Prompt, msUser);

  AddMessage(SendAPIRequest(Prompt), msBot);
  ED_Request.TextPrompt := '';
end;

procedure TFrm_Main.AddMessage(const AText: String; AMsgSender: TMsgSender);
var
  CR: TCalloutRectangle;
  LMsg: TLabel;
  ImgDP: TCircle;
  PNImg, PNMain : TRectangle;
begin
  PNMain := TRectangle.Create(Self);
  PNMain.Parent := VSB_Background;
  PNMain.Align := TAlignLayout.Top;
  PNMain.Position.Y := VSB_Background.Height + 1;
  PNMain.Height := cMsgHeight;
  PNMain.Fill.Kind := TBrushKind.None;
  PNMain.Stroke.Kind := TBrushKind.None;

  CR := TCalloutRectangle.Create(Self);
  CR.Parent := PNMain;
  CR.Align := TAlignLayout.Client;
  CR.CalloutOffset := 10;
  CR.CalloutWidth := 10;
  case AMsgSender of
    msUser:
    begin
      CR.CalloutPosition := TCalloutPosition.Right;
      CR.Margins.Left := 15;
      CR.Margins.Right := 5;
    end;
    msBot:
    begin
      CR.CalloutPosition := TCalloutPosition.Left;
      CR.Margins.Right := 15;
      CR.Margins.Left := 5;
    end;
  end;
  CR.Margins.Top := 5;
  CR.Margins.Bottom := 5;
  CR.XRadius := 10;
  CR.YRadius := CR.XRadius;
  CR.Position.Y := 999999;
  CR.Fill.Kind := TBrushKind.None;
  CR.Stroke.Color := TAlphaColorRec.Black;

  PNImg := TRectangle.Create(Self);
  PNImg.Parent := PNMain;
  PNImg.Fill.Kind := TBrushKind.None;
  PNImg.Stroke.Kind := TBrushKind.None;
  case AMsgSender of
    msUser: PNImg.Align := TAlignLayout.Right;
    msBot: PNImg.Align := TAlignLayout.Left;
  end;
  PNImg.Width := 30;
  PNImg.Margins.Left := 5;
  PNImg.Margins.Right := 5;
  PNImg.Margins.Top := 5;
  PNImg.Margins.Bottom := 5;

  ImgDP := TCircle.Create(Self);
  ImgDP.Parent := PNImg;
  ImgDP.Align := TAlignLayout.Top;
  ImgDP.Fill.Kind := TBrushKind.Bitmap;
  case AMsgSender of
    msUser: ImgDP.Fill.Bitmap.Bitmap.Assign(Img_User.Bitmap);
    msBot: ImgDP.Fill.Bitmap.Bitmap.Assign(Img_Bot.Bitmap);
  end;
  ImgDP.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
  ImgDP.Height := 30;

  LMsg := TLabel.Create(Self);
  LMsg.Parent := CR;

  case AMsgSender of
    msUser:
    begin
      LMsg.Position.X := CR.Margins.Right;
      LMsg.Width := CR.Width - LMsg.Position.X - CR.CalloutWidth - CR.Margins.Left - 3;
    end;
    msBot:
    begin
      LMsg.Position.X := CR.CalloutWidth + CR.Margins.Left;
      LMsg.Width := CR.Width - LMsg.Position.X - CR.Margins.Right - 3;
    end;
  end;
  LMsg.Position.Y := 5;
  LMsg.Height := CR.Height - 5;
  LMsg.Anchors := LMsg.Anchors + [TAnchorKind.akRight];
  LMsg.WordWrap := True;
  LMsg.OnResize := SetMsgHeight;
  LMsg.AutoSize := True;
  LMsg.Text := AText;
  VSB_Background.ScrollBy(0,-95);
end;

procedure TFrm_Main.SetMsgHeight(Sender: TObject);
begin
  if TLabel(Sender).Height >= cMsgHeight then
    TPanel(TLabel(Sender).Parent.Parent).Height := TLabel(Sender).Height + 20;
end;

end.
