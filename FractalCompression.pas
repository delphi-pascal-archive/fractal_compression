{ *************************************************************************** }
{                                                                             }
{                                                                             }
{                                                                             }
{ ������ FractalCompression - �������� ����� TFractal, ������������ ���       }
{ ������������ ������ / ���������� �����������                                }
{ (c) 2006 ������� ������� ���������                                          }
{ ����� �����: http://matrix.kladovka.net.ru/                                 }
{ e-mail: loginov_d@inbox.ru                                                  }
{                                                                             }
{ *************************************************************************** }

unit FractalCompression;

interface

uses
  Windows, Messages, SysUtils, Graphics, Classes;

type
  // �������� ������ ������� � �������� ����� ���������� �����-������� 6 ����
  // ����� ������� ������ ����� = ���-�� �������� * 6
  TIfsRec = packed record
    DomCoordX, DomCoordY: Word; // ���������� ������ �������� ���� ������
    Betta, FormNum: Byte; // �������� � �������, ����� ��������������
  end;

  TRegionRec = packed record
    MeanColor: Integer; // ����������� ������������     
    Ifs: TIfsRec; // ���������, ����������� ��� ����������
  end;

  TDomainRec = packed record
    MeanColor: Integer; // ����������� ������������ 
  end;

  // ��������� ����� (8 ����)
  TIfsHeader = packed record
    FileExt: array[1..3] of Char;
    RegSize: Byte; // ������ �������
    XRegions, YRegions: Word; // ���-�� �������� �� � � �
  end;       

  // ���� ������� ��������������
  TTransformType = (ttRot0, ttRot90, ttRot180, ttRot270, ttSimmX, ttSimmY, ttSimmDiag1, ttSimmDiag2);

  TProgressProc = procedure(Percent: Integer; TimeRemain: Cardinal) of Object;

  TFractal = class(TComponent)
  private
    SourImage: PByteArray;  // ������� ����������� ����� �������������� � �����
    DomainImage: PByteArray;// ������ �������� ��������� �����������
    SourWidth: Integer;     // ������ �����������
    SourHeight: Integer;    // ������ �����������
    FRegionSize: Integer;   // ������ �������
    FDomainOffset: Integer; // �������� �������
    Regions: array of array of TRegionRec; // ���������� � ��������
    Domains: array of array of TDomainRec; // ���������� � �������
    FGamma: Real;
    FMaxImageSize: Integer; // ����������� ���������� ������ �����������
    FStop: Boolean;
    FIfsIsLoad: Boolean; // ���������, ���� �� ��������� ���������� (��������� �� IFS-������)
    FBaseRegionSize: Integer;  // ������ ������� ��� ������

    {������� ������}
    procedure ClearData;

    {���������� �������������� �������� � ���������� Msg}
    procedure Error(Msg: string; Args: array of const);

    {������� ������ ������ Regions �� ������� }
    procedure CreateRegions;

    {�� ��������� ����������� SourImage ������� �������� �����������}
    procedure CreateDomainImage;

    {������� ������ 2-������ Domains, � ������� ��������� ����������� ������������
     ��� ������� ������}
    procedure CreateDomains;

    {���������� ����������� ������� ��� ������� Image � ������� � �. (X, Y)}
    function GetMeanBrigth(Image: PByteArray; X, Y, Width: Integer): Byte;

    function XRegions: Integer; // ����� �������� �� �
    function YRegions: Integer; // ����� �������� �� �

    function XDomains: Integer; // ����� ������� �� �
    function YDomains: Integer; // ����� ������� �� �
    function DomainImageWidth: Integer; // ������ ��������� �����������
    
    procedure SetGamma(const Value: Real);
    procedure SetMaxImageSize(const Value: Integer);

    procedure SetRegionSize(const Value: Integer);
    procedure SetDomainOffset(const Value: Integer);

    {�������������� �������� ������ � �����. � TransformType. ������� �
     �������� ������� ������ ���� ���� �� ������}
    procedure TransformRegion(Sour, Dest: PByteArray; TransformType: TTransformType);

    {���������� ������� (����������� ����������) ����� �������� � �������}
    function GetDifference(Region: PByteArray; DomCoordX, DomCoordY, Betta: Integer): Integer;

    {�������� ��������� ������ �� ������� AllImage � ������ Dest.
     Width - ������ ������� AllImage}
    procedure CopyRegion(AllImage, Dest: PByteArray; X, Y, Width: Integer);
    function GetPixel(X, Y: Integer): Byte;
  public
    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;

    {��������� ���������� ���� ������. ��� UseAllTransform ����� ���������
     ��� ������� ��������������: ������� � ���������. � ��������� ������
     ����� �������� ������ �������}
    procedure Compress(UseAllTransform: Boolean = True; BackProc: TProgressProc = nil);

    {������������� ��������� ������� ������������ ������}
    procedure Stop;

    {��������� ���������� �����������. IterCount - ���-�� �������� ����������,
     RegSize - ������ ������� � ������������� �����������. ���� ��� ��������
     ����� ��, ��� RegionSize ��� ������, �� ������ ����������� ����� ��� ��� ������.
     ��� ���������� RegSize ������������� ����������� ����������� � ��������}
    procedure Decompress(IterCount: Integer = 15; RegSize: Integer = 0);

    {������ ����������� �� �������. ����� ������������ ����� ����� ������ ��� ����,
     ����� ��������� �������� ������. �����������, ����������� �� �������,
     ������ �� ��������������� �����������, ������ ����� ������� �������������}
    procedure BuildImageWithDomains;

    {���������, ���� �� ��������� ���������� (��������� �� IFS-������, �����������
     ��� ������������). ���� IfsIsLoad=True, �� ����� ����� ������ ������������}
    property IfsIsLoad: Boolean read FIfsIsLoad;

    {������ ����������� (���������, ������������ �� �������, ��� ��������������)}
    property ImageWidth: Integer read SourWidth;

    {������ ����������� (���������, ������������ �� �������, ��� ��������������)}
    property ImageHeight: Integer read SourHeight;

    {���������� �������� ������� ��� ���������� �������}
    property Pixel[X, Y: Integer]: Byte read GetPixel;

    {��������� ������������ ����������� TBitMap ��� ���������� ����������}
    procedure LoadImage(Image: TBitmap);

    {������ ����������� �� ���������� TBitmap. ��� Regions = True �������� ��������
     �����������, ����� �������� �������� ����������� (��� ����� ��, ������
     � 4 ���� ������ �� �������)}
    procedure DrawImage(Image: TBitmap; Regions: Boolean = True);

    {��������� ��������� ������ � �������� ����}
    procedure SaveToFile(FileName: string);

    {��������� �������� ������ �� ��������� �����}
    procedure LoadFromFile(FileName: string);

    {����������, ����� ������ ����� � IFS-����� ����� ����������}
    function GetIFSFileSize(): Cardinal;
  published
    {������������� ������ �������.
     ��������! ������ �������� ������ ������� ����� �������� ����������� ���
     ����������, ��� ��� ����������� ����������� �������������� �
     ������������ � RegionSize}
    property RegionSize: Integer read FRegionSize write SetRegionSize;

    {�������� �������� ������. �� ��������� = 1 (��� ����� �������������
     ��������� �����������, ������� � 4 ���� ������ ���������)}
    property DomainOffset: Integer read FDomainOffset write SetDomainOffset;

    {�������� ����������� �����}
    property Gamma: Real read FGamma write SetGamma;

    {������������ ������ �����������}
    property MaxImageSize: Integer read FMaxImageSize write SetMaxImageSize;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TFractal]);
end;

{ TFractal }

procedure TFractal.ClearData;
begin
  if Assigned(SourImage) then FreeMem(SourImage);
  if Assigned(DomainImage) then FreeMem(DomainImage);
  SourImage := nil;
  DomainImage := nil;
  SourWidth := 0;
  SourHeight := 0;
  Regions := nil;
  Domains := nil;
end;

procedure TFractal.Compress(UseAllTransform: Boolean = True; BackProc: TProgressProc = nil);
var
  RegX, RegY, DomX, DomY, Error, BestError, Betta, TransNum, TransCount: Integer;
  Region, BaseRegion: PByteArray;
  DCoordX, DCoordY, BestFormNum, BestDomX, BestDomY, BestBetta: Integer;
  Percent: Real;
  Tc, OneRegTime, AllRegTime: Cardinal;
label
  LExit;
begin
  FStop := False;
  FIfsIsLoad := False;

  FBaseRegionSize := RegionSize;

  if UseAllTransform then TransCount := 8 else TransCount := 4;

  if SourImage = nil then
    raise Exception.Create('����������� ��� ������������ ������ ��� �� ���������!');

  CreateRegions;
  CreateDomains;

  GetMem(BaseRegion, RegionSize * RegionSize);
  GetMem(Region, RegionSize * RegionSize);


  OneRegTime := 0;
  AllRegTime := 0;
  Tc := GetTickCount;
  // ���������� �������
  for RegY := 0 to YRegions - 1 do
    for RegX := 0 to XRegions - 1 do
    begin
      if RegY * XRegions + RegX > 10 then Tc := GetTickCount;

      Percent := (RegY * XRegions + RegX) / (YRegions * XRegions) * 100;
      BestError := $7FFFFFFF;
      BestFormNum := -1;
      BestDomX := -1;
      BestDomY := -1;
      BestBetta := 0;

      CopyRegion(SourImage, BaseRegion, RegX * RegionSize, RegY * RegionSize, SourWidth);

      // ���������� ������
      for DomY := 0 to YDomains - 1 do
        for DomX := 0 to XDomains - 1 do
        begin

          // ���������� ������� � �������. ��� ������ ���� ��� ����� �������������.
          Betta := Regions[RegX, RegY].MeanColor - Domains[DomX, DomY].MeanColor;
          
          DCoordX := DomX * DomainOffset;
          DCoordY := DomY * DomainOffset;

          // �������� ���� �� ��������������
          for TransNum := 0 to TransCount - 1 do
          begin
            // ��������� ������� ��������������
            TransformRegion(BaseRegion, Region, TTransformType(TransNum));

            // ���������� �������� ������� ����� �������������
            Error := GetDifference(Region, DCoordX, DCoordY, Betta);

            // ���������� �� ��������� ���������� ������ ����������
            if Error < BestError then
            begin
              BestError := Error;
              BestFormNum := TransNum;
              BestDomX := DCoordX;
              BestDomY := DCoordY;
              BestBetta := Betta;
            end;

            if FStop then goto LExit; // ���������� ������� �� ������� ������ Stop
          end;  // ���� �� ��������������
        end;  // ���� �� �������

      // ������ �������� ���, ��� ����� ��� ������� �������
      with Regions[RegX, RegY].Ifs do
      begin
        DomCoordX := BestDomX;
        DomCoordY := BestDomY;
        Betta := BestBetta;
        if BestFormNum = 1 then BestFormNum := 3 else // 90 -> 270
          if BestFormNum = 3 then BestFormNum := 1;  // 270 -> 90
        FormNum := BestFormNum;
      end;

      
      if RegY * XRegions + RegX = 10 then
      begin
        OneRegTime := (GetTickCount - Tc) div 10;
        AllRegTime := OneRegTime * Cardinal(XRegions * YRegions);
      end;
      if Assigned(BackProc) and (Percent >= 0) then
        BackProc(Trunc(Percent), (AllRegTime - OneRegTime * Cardinal(RegY * XRegions + RegX)) div 1000);

    end; // ���� �� ��������
                             
  FIfsIsLoad := True;

  LExit:
    
  FreeMem(BaseRegion);
  FreeMem(Region);
end;

constructor TFractal.Create(AOwner: TComponent);
begin
  inherited;
  FRegionSize := 8;
  DomainOffset := 1;
  Gamma := 0.75;
  MaxImageSize := 512;
end;

procedure TFractal.CreateDomains;
var
  Y, X: Integer;
begin
  Domains := nil;

  SetLength(Domains, XDomains, YDomains);

  // ��� ������� ������ ���������� ��� ���������� � ����������� �������
  for Y := 0 to YDomains - 1 do
    for X := 0 to XDomains - 1 do
      Domains[X, Y].MeanColor := GetMeanBrigth(DomainImage, X * DomainOffset,
        Y * DomainOffset, DomainImageWidth);
end;

procedure TFractal.CreateRegions;
var
  X, Y: Integer;
begin
  Regions := nil;
  SetLength(Regions, XRegions, YRegions);

  // ��� ������� ������� ���������� ��� ���������� � ����������� �������
  for Y := 0 to YRegions - 1 do
    for X := 0 to XRegions - 1 do
      Regions[X, Y].MeanColor := GetMeanBrigth(SourImage, X * RegionSize, Y * RegionSize, SourWidth);
end;

destructor TFractal.Destroy;
begin
  ClearData();
  inherited;
end;

procedure TFractal.DrawImage(Image: TBitmap; Regions: Boolean = True);
var
  X, Y, Pixel: Integer;
  Handle: HDC;
begin
  if SourWidth * SourHeight < 1 then
    Error('������ ��������� �����������!', []);
  Image.Width := SourWidth;
  Image.Height := SourHeight;
  Handle := Image.Canvas.Handle;

  for Y := 0 to SourHeight - 1 do
  begin
    for X := 0 to SourWidth - 1 do
    begin
      Pixel := SourImage[Y * SourWidth + X];
      Pixel := (Pixel shl 16) + (Pixel shl 8) + Pixel;
      SetPixel(Handle, X, Y, Pixel);
    end;
  end;

  if not Regions then
  for Y := 0 to SourHeight div 2 - 1 do
  begin
    for X := 0 to SourWidth div 2 - 1 do
    begin
      Pixel := DomainImage[Y * DomainImageWidth + X];
      Pixel := (Pixel shl 16) + (Pixel shl 8) + Pixel;
      SetPixel(Handle, X, Y, Pixel);
    end;
  end;
end;

procedure TFractal.Error(Msg: string; Args: array of const);
begin
  raise Exception.CreateFmt(Msg, Args);
end;

function TFractal.GetMeanBrigth(Image: PByteArray; X, Y, Width: Integer): Byte;
var
  I, J, Bufer: Integer;
begin
  Bufer := 0;
  for I := Y to Y + RegionSize - 1 do
    for J := X to X + RegionSize - 1 do
      Inc(Bufer, Image[I * Width + J]);
  Result := Trunc(Bufer / (RegionSize * RegionSize));
end;

procedure TFractal.LoadImage(Image: TBitmap);
var
  X, Y: Integer;
  PixColor: TColor;
  red, green, blue, mask: integer;
begin
  ClearData;  // ������� �������

  SourWidth := (Image.Width div RegionSize) * RegionSize;
  SourHeight := (Image.Height div RegionSize) * RegionSize;
  if (SourWidth > MaxImageSize) or (SourWidth < 16) or
     (SourHeight > MaxImageSize) or (SourHeight < 16)
    then Error('������������ ������� ����������� %d x %d', [Image.Width, Image.Height]);

  // ======= ��������� ������ SourImage (��� ��������) ===========
  // �������� ������ ��� �����������
  GetMem(SourImage, SourWidth * SourHeight);

  // ������ ������� ������ � ��������� �� � ��������� ������� SourImage
  mask := $000000FF;
  for Y := 0 to SourHeight - 1 do
    for X := 0 to SourWidth - 1 do
    begin
      PixColor := Image.Canvas.Pixels[X, Y]; // ���������� ���� �������
      red := (PixColor shr 16) and mask;
      green := (PixColor shr 8) and mask;
      blue := PixColor and mask;
      SourImage[Y * SourWidth + X] := Byte((red + green + blue) div 3);
    end;
  // ���! ������ ��� ������� ����� ������.

  // ======= ��������� ������ DomenImage (��� �������) ===========
  // ������-�� ������ � 2 ���� ������ ��������, ������ ��-�� ����� �� ������ ����������.
  // � ��� ���� �� �������� ����������� �������� � 4 ���� (�� �������), ��
  // ������ 1 ������ ������ ������ ������� 1 �������, ��� ������� �����
  // � ���������.
  CreateDomainImage;

  FIfsIsLoad := False;
end;

procedure TFractal.SetDomainOffset(const Value: Integer);
begin
  if (Value < 1) or (Value > 32) then
    Error('������ ������������ �������� �������� ������ %d', [Value]);
  FDomainOffset := Value;
end;

procedure TFractal.SetGamma(const Value: Real);
begin
  if (Value < 0.1) or (Value > 1) then
    Error('�������� GAMMA ����� ������������ �������� %d', [Value]);
  FGamma := Value;
end;

procedure TFractal.SetMaxImageSize(const Value: Integer);
begin
  FMaxImageSize := Value;
end;

procedure TFractal.SetRegionSize(const Value: Integer);
begin
  if (Value < 2) or (Value > 64) then
    Error('������ ������������ �������� ������� %d', [Value]);
  FRegionSize := Value;
end;

function TFractal.XDomains: Integer;
begin
  Result := SourWidth div (2 * DomainOffset) - 1;
  if Result <= 1 then
    Error('������������ ���������� ������� �� � %d', [Result]);
end;

function TFractal.YDomains: Integer;
begin
  Result := SourHeight div (2 * DomainOffset) - 1;
  if Result <= 1 then
    Error('������������ ���������� ������� �� Y %d', [Result]);
end;

function TFractal.XRegions: Integer;
begin
  Result := SourWidth div RegionSize;
end;

function TFractal.YRegions: Integer;
begin
  Result := SourHeight div RegionSize;
end;

procedure TFractal.TransformRegion(Sour, Dest: PByteArray; TransformType: TTransformType);
var
  I, J: Integer;
begin
  case TransformType of
    ttRot0: // ������� �� 0 ��������
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[I * RegionSize + J] := Sour[I * RegionSize + J];
      end;

    ttRot90: // ������� �� 90 ��������
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[(RegionSize - 1 - J) * RegionSize + I] := Sour[I * RegionSize + J];
      end;

    ttRot180: // ������� �� 180 ��������
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[(RegionSize - 1 - I) * RegionSize + (RegionSize - 1 - J)] := Sour[I * RegionSize + J];
      end;

    ttRot270: // ������� �� 270 ��������
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[J * RegionSize + (RegionSize - 1 - I)] := Sour[I * RegionSize + J];
      end;

    ttSimmX: // ��������� ������������ �
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[(RegionSize - 1 - I) * RegionSize + J] := Sour[I * RegionSize + J];
      end;

    ttSimmY: // ��������� ������������ �
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[I * RegionSize + (RegionSize - 1 - J)] := Sour[I * RegionSize + J];
      end;

    ttSimmDiag1: // ��������� ��. ������� ���������
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[J * RegionSize + I] := Sour[I * RegionSize + J];
      end;

    ttSimmDiag2: // ��������� ��. �������������� ���������
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[(RegionSize - 1 - J) * RegionSize + (RegionSize - 1 - I)] := Sour[I * RegionSize + J];
      end;
  end;
end;

function TFractal.DomainImageWidth: Integer;
begin
  Result := SourWidth div 2;
end;

procedure TFractal.LoadFromFile(FileName: string);
var
  X, Y: Integer;
  Header: TIfsHeader;
begin
  if not FileExists(FileName) then
    Error('���� "%s" �� ����������', [FileName]);

  with TMemoryStream.Create do
  begin
    LoadFromFile(FileName);
    Seek(0, soFromBeginning);
    Read(Header, SizeOf(TIfsHeader));
    if Header.FileExt <> 'IFS' then
    begin
      Free;
      Error('���� "%s" ����� ������������ ������!', [FileName]);
    end;
    
    SourWidth := Header.XRegions * Header.RegSize;
    SourHeight := Header.YRegions * Header.RegSize;
    RegionSize := Header.RegSize;

    Regions := nil;

    SetLength(Regions, XRegions, YRegions);
    for Y := 0 to YRegions - 1 do
      for X := 0 to XRegions - 1 do
        Read(Regions[X, Y].Ifs, SizeOf(TIfsRec));

    Free;       
  end;

  // ����� ��� ��������������� ��� ������������
  FBaseRegionSize := RegionSize;
  
  FIfsIsLoad := True;
end;

procedure TFractal.SaveToFile(FileName: string);
var
  X, Y: Integer;
  Header: TIfsHeader;
begin
  if Regions = nil then
    Error('������ ����������� �� ���������!', []);

  if FileExists(FileName) and not DeleteFile(FileName) then
    Error('���������� ������� ���� %s. �������� �� ������������ ������ �����������' +
          '��� �������� ������ ��� ������.', [FileName]);    

  Header.FileExt := 'IFS';
  Header.RegSize := RegionSize;
  Header.XRegions := XRegions;
  Header.YRegions := YRegions;

  with TMemoryStream.Create() do
  begin
    // ��������� ������������ ����������
    Write(Header, SizeOf(TIfsHeader));
    for Y := 0 to YRegions - 1 do
      for X := 0 to XRegions - 1 do
        Write(Regions[X, Y].Ifs, SizeOf(TIfsRec));

    try
      SaveToFile(FileName);
    except
      Free;
      Error('��������� ������ ��� ���������� � ���� "%s"', [FileName]);
    end;
    Free;
  end;

end;

procedure TFractal.Decompress(IterCount: Integer = 15; RegSize: Integer = 0);
var
  I, J, X, Y, Pixel, Iter: Integer;
  Domain1, Domain2: PByteArray;
  Scale: Real;
begin
  // ������ Region ������ ���� ��� �����������.
  if not FIfsIsLoad then
    Error('������, ����������� ��� ������������, �� ���������!', []);


  Scale := 1;
  if RegSize >= 2 then
    begin
      SourWidth := XRegions * RegSize;
      SourHeight := YRegions * RegSize;
      Scale := FBaseRegionSize / RegSize;
      RegionSize := RegSize;
    end;


  // ������� ����� �����������.
  if Assigned(SourImage) then FreeMem(SourImage);
  GetMem(SourImage, SourWidth * SourHeight);

  // ������ ������� ������ � ��������� �� � ��������� ������� SourImage
  for I := 0 to SourHeight * SourWidth - 1 do SourImage[I] := 127;

  for Iter := 1 to IterCount do
  begin
    // ������� �������� �����������
    CreateDomainImage;
    // �������� � ��������� ����������� �������

    // �������� �� ���� ��������
    for J := 0 to YRegions - 1 do
      for I := 0 to XRegions - 1 do
      begin
        // ���������� ��������������� �����, ����� ��� ��� ����� ���� ��������� ��������������
        GetMem(Domain1, RegionSize * RegionSize);
        GetMem(Domain2, RegionSize * RegionSize);
        CopyRegion(DomainImage, Domain1,
          Trunc(Regions[I, J].Ifs.DomCoordX / Scale),
          Trunc(Regions[I, J].Ifs.DomCoordY / Scale), DomainImageWidth);

        // ��������� �������� ��������������
        TransformRegion(Domain1, Domain2, TTransformType(Regions[I, J].Ifs.FormNum));

        // �������� ������� �������� �������
        for Y := 0 to RegionSize - 1 do
          for X := 0 to RegionSize - 1 do
          begin
            Pixel := Domain2[Y * RegionSize + X] + Regions[I, J].Ifs.Betta;
            SourImage[(J * RegionSize + Y) * SourWidth + I * RegionSize + X] := Pixel;
          end;

        FreeMem(Domain1);
        FreeMem(Domain2);
      end;
  end;  
end;

procedure TFractal.CreateDomainImage;
var
  X, Y, PixColor: Integer;
begin
  if Assigned(DomainImage) then FreeMem(DomainImage);
  GetMem(DomainImage, SourWidth * SourHeight div 4);
  
  for Y := 0 to SourHeight div 2 - 1 do
    for X := 0 to SourWidth div 2 - 1 do
    begin
      // ���������� ����������� ���� ������� (�� ������ 4-� �������� ��������)
      PixColor :=
        SourImage[Y * 2 * SourWidth + X * 2] + SourImage[Y * 2 * SourWidth + X * 2 + 1] +
        SourImage[(Y * 2 + 1) * SourWidth + X * 2] + SourImage[(Y * 2 + 1) * SourWidth + X * 2 + 1];
      DomainImage[Y * DomainImageWidth + X] := Trunc(PixColor / 4 * Gamma);
    end;
end;

function TFractal.GetDifference(Region: PByteArray; DomCoordX,
  DomCoordY, Betta: Integer): Integer;
var
  X, Y, Diff: Integer;
begin
  Result := 0;
  for Y := 0 to RegionSize - 1 do
    for X := 0 to RegionSize - 1 do
    begin
      Diff := Region[Y * RegionSize + X] -
        DomainImage[(DomCoordY + Y) * DomainImageWidth + DomCoordX + X];

      Inc(Result, Sqr(Abs(Diff - Betta)));
    end;
end;

procedure TFractal.CopyRegion(AllImage, Dest: PByteArray; X, Y,
  Width: Integer);
var
  I, J: Integer;
begin
  for I := 0 to RegionSize - 1 do
    for J := 0 to RegionSize - 1 do
      Dest[I * RegionSize + J] := AllImage[(Y + I) * Width + X + J];
end;

procedure TFractal.BuildImageWithDomains;
var
  I, J, X, Y: Integer;
  Domain1, Domain2: PByteArray;
begin
  if not FIfsIsLoad then
    Error('������, ����������� ��� �������������� �� �������, �� ���������!', []);

  for J := 0 to YRegions - 1 do
    for I := 0 to XRegions - 1 do
    begin
      GetMem(Domain1, RegionSize * RegionSize);
      GetMem(Domain2, RegionSize * RegionSize);

      // �������� �����
      CopyRegion(DomainImage, Domain1, Regions[I, J].Ifs.DomCoordX,
        Regions[I, J].Ifs.DomCoordY, DomainImageWidth);

      // ��������� ������� ��������������
      TransformRegion(Domain1, Domain2, TTransformType(Regions[I, J].Ifs.FormNum));

      // �������� ����� � ������
      for Y := 0 to RegionSize - 1 do
        for X := 0 to RegionSize - 1 do
          SourImage[(J * RegionSize + Y) * SourWidth + I * RegionSize + X] :=
            Domain2[Y * RegionSize + X] + Regions[I, J].Ifs.Betta;

      FreeMem(Domain1);
      FreeMem(Domain2);  
    end;
end;

procedure TFractal.Stop;
begin
  FStop := True;
end;

function TFractal.GetPixel(X, Y: Integer): Byte;
begin
  Result := SourImage[Y * SourWidth + X];
end;

function TFractal.GetIFSFileSize: Cardinal;
begin
  Result := (ImageWidth div RegionSize) * (ImageHeight div RegionSize) * SizeOf(TIfsRec);
  if Result > 0 then Inc(Result, SizeOf(TIfsHeader));
end;

end.
