program ChatAI;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  Main in 'Main.pas' {Frm_Main};

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TFrm_Main, Frm_Main);
  Application.Run;
end.
