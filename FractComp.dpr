program FractComp;

uses
  Forms,
  U_Main in 'U_Main.pas' {Form1},
  U_ShowImage in 'U_ShowImage.pas' {fmShowImage},
  FractalCompression in 'FractalCompression.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
