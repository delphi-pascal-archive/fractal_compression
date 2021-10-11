unit U_Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, jpeg, ExtDlgs, FractalCompression, ComCtrls;

type
  TForm1 = class(TForm)
    ImPreview: TImage;
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Label2: TLabel;
    Button2: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    lbSize: TLabel;
    CheckBox1: TCheckBox;
    ProgressBar1: TProgressBar;
    Button4: TButton;
    Button5: TButton;
    Label4: TLabel;
    Edit2: TEdit;
    Label5: TLabel;
    Edit3: TEdit;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    Button6: TButton;
    Label6: TLabel;
    Edit4: TEdit;
    Button7: TButton;
    Button8: TButton;
    Label7: TLabel;
    Bevel1: TBevel;
    CheckBox2: TCheckBox;
    Label3: TLabel;
    Bevel2: TBevel;
    Label8: TLabel;
    Edit5: TEdit;
    Label9: TLabel;
    lbTime: TLabel;
    Button9: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ImageExists: Boolean;
    procedure ProgressProc(Percent: Integer; TimeRemain: Cardinal);
  end;

var
  Form1: TForm1;
  FractalComp: TFractal;
  FractalDeComp: TFractal;

implementation

uses U_ShowImage;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
  begin
    try
      ImPreview.Picture.LoadFromFile(OpenPictureDialog1.FileName);
      if (ImPreview.Picture.Width > 512) or (ImPreview.Picture.Height > 512) then Abort;
      lbSize.Caption := Format('%d x %d', [ImPreview.Picture.Width, ImPreview.Picture.Height]);
      ImageExists := True;

      // ��������� ����������� � ������ ������������� � ����� ����������
      // �������� �������������
      FractalComp.LoadImage(ImPreview.Picture.Bitmap);
      Edit1.Text := OpenPictureDialog1.FileName;
    except
      ImPreview.Picture := nil;
      ImPreview.Canvas.TextOut(5, 10, '������');
      ImPreview.Canvas.TextOut(5, 30, '��������');
      Edit1.Text := '����������� �� �������!';
      lbSize.Caption := '';
      ImageExists := False;
    end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ImPreview.Canvas.TextOut(5, 10, '�����������');
  ImPreview.Canvas.TextOut(5, 30, '�����������');

  FractalComp := TFractal.Create(Application);
  FractalDeComp := TFractal.Create(Application);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  // ���������� ����������� �� ������ ���������.
  if ImageExists then
  begin
    Application.CreateForm(TfmShowImage, fmShowImage);
    if CheckBox1.Checked then
      FractalComp.DrawImage(fmShowImage.Image1.Picture.Bitmap, False)
    else
      fmShowImage.Image1.Picture := ImPreview.Picture;

    with fmShowImage do
    begin
      AutoSize := True;
      Position := poScreenCenter;
      ShowModal;
    end;

    FreeAndNil(fmShowImage);
  end;
end;

procedure TForm1.ProgressProc(Percent: Integer; TimeRemain: Cardinal);
begin
  ProgressBar1.Position := Percent;
  lbTime.Caption := IntToStr(TimeRemain);
  Application.ProcessMessages;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  if ImageExists then
  begin
    FractalComp.RegionSize := StrToInt(Edit3.Text);
    FractalComp.DomainOffset := StrToInt(Edit2.Text);

    FractalComp.LoadImage(ImPreview.Picture.Bitmap);
    FractalComp.Compress(CheckBox2.Checked, ProgressProc);

    ProgressBar1.Position := 0;
    lbTime.Caption := '';
  end;     
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  OpenDialog1.Title := '���������� IFS-������';
  if OpenDialog1.Execute then
    FractalComp.SaveToFile(OpenDialog1.FileName);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  OpenDialog1.Title := '�������� IFS-������';
  if OpenDialog1.Execute then
    FractalDeComp.LoadFromFile(OpenDialog1.FileName);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  FractalDeComp.Decompress(StrToInt(Edit4.Text), StrToInt(Edit5.Text));
  // ���������� ����������� �� ������ ���������.

  Application.CreateForm(TfmShowImage, fmShowImage);
  FractalDeComp.DrawImage(fmShowImage.Image1.Picture.Bitmap);


  with fmShowImage do
  begin
    AutoSize := True;
    Position := poScreenCenter;
    ShowModal;
  end;

  FreeAndNil(fmShowImage);

end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  FractalComp.BuildImageWithDomains;

  Application.CreateForm(TfmShowImage, fmShowImage);
  FractalComp.DrawImage(fmShowImage.Image1.Picture.Bitmap);


  with fmShowImage do
  begin
    AutoSize := True;
    Position := poScreenCenter;
    ShowModal;
  end;

  FreeAndNil(fmShowImage);  
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  FractalComp.Stop;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  ShowMessage(IntToStr(FractalComp.GetIFSFileSize) + ' ����');
end;

end.
