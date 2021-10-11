{ *************************************************************************** }
{                                                                             }
{                                                                             }
{                                                                             }
{ Модуль FractalCompression - содержит класс TFractal, используемый для       }
{ фрактального сжатия / распаковки изображений                                }
{ (c) 2006 Логинов Дмитрий Сергеевич                                          }
{ Адрес сайта: http://matrix.kladovka.net.ru/                                 }
{ e-mail: loginov_d@inbox.ru                                                  }
{                                                                             }
{ *************************************************************************** }

unit FractalCompression;

interface

uses
  Windows, Messages, SysUtils, Graphics, Classes;

type
  // Описание одного региона в выходном файле составляет всего-навсего 6 байт
  // Таким образом размер файла = Кол-во регионов * 6
  TIfsRec = packed record
    DomCoordX, DomCoordY: Word; // Координаты левого верхнего угла домена
    Betta, FormNum: Byte; // Различие в яркости, Номер преобразования
  end;

  TRegionRec = packed record
    MeanColor: Integer; // Усредненная цветояркость     
    Ifs: TIfsRec; // Параметры, вычисляемые при компрессии
  end;

  TDomainRec = packed record
    MeanColor: Integer; // Усредненная цветояркость 
  end;

  // Заголовок файла (8 байт)
  TIfsHeader = packed record
    FileExt: array[1..3] of Char;
    RegSize: Byte; // Размер региона
    XRegions, YRegions: Word; // Кол-во регионов по Х и У
  end;       

  // Типы афинных преобразований
  TTransformType = (ttRot0, ttRot90, ttRot180, ttRot270, ttSimmX, ttSimmY, ttSimmDiag1, ttSimmDiag2);

  TProgressProc = procedure(Percent: Integer; TimeRemain: Cardinal) of Object;

  TFractal = class(TComponent)
  private
    SourImage: PByteArray;  // Пиксели изображения после преобразования в серый
    DomainImage: PByteArray;// Массив пикселей доменного изображения
    SourWidth: Integer;     // Ширина изображения
    SourHeight: Integer;    // Высота изображения
    FRegionSize: Integer;   // Размер региона
    FDomainOffset: Integer; // Смещение доменов
    Regions: array of array of TRegionRec; // Информация о регионах
    Domains: array of array of TDomainRec; // Информация о доменах
    FGamma: Real;
    FMaxImageSize: Integer; // Максимально допустимый размер изображения
    FStop: Boolean;
    FIfsIsLoad: Boolean; // Проверяет, была ли выполнена компрессия (загружены ли IFS-данные)
    FBaseRegionSize: Integer;  // Размер региона при сжатии

    {Очищает данные}
    procedure ClearData;

    {Генерирует исключительную ситуация с сообщением Msg}
    procedure Error(Msg: string; Args: array of const);

    {Создает массив ссылок Regions на регионы }
    procedure CreateRegions;

    {По исходному изображению SourImage создает доменное изображение}
    procedure CreateDomainImage;

    {Создает массив 2-мерный Domains, в который заносится усредненная цветояркость
     для каждого домена}
    procedure CreateDomains;

    {Определяет усредненную яркость для участка Image с началом в т. (X, Y)}
    function GetMeanBrigth(Image: PByteArray; X, Y, Width: Integer): Byte;

    function XRegions: Integer; // Число регионов по Х
    function YRegions: Integer; // Число регионов по У

    function XDomains: Integer; // Число доменов по Х
    function YDomains: Integer; // Число доменов по У
    function DomainImageWidth: Integer; // Ширина доменного изображения
    
    procedure SetGamma(const Value: Real);
    procedure SetMaxImageSize(const Value: Integer);

    procedure SetRegionSize(const Value: Integer);
    procedure SetDomainOffset(const Value: Integer);

    {Трансформирует заданный регион в соотв. с TransformType. Пиксели в
     заданном регионе должны идти друг за другом}
    procedure TransformRegion(Sour, Dest: PByteArray; TransformType: TTransformType);

    {Возвращает разницу (метрическое расстояние) между регионом и доменом}
    function GetDifference(Region: PByteArray; DomCoordX, DomCoordY, Betta: Integer): Integer;

    {Копирует указанный регион из массива AllImage в массив Dest.
     Width - ширина массива AllImage}
    procedure CopyRegion(AllImage, Dest: PByteArray; X, Y, Width: Integer);
    function GetPixel(X, Y: Integer): Byte;
  public
    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;

    {Выполняет собственно само сжатие. При UseAllTransform будут выполнены
     все афинные преобразования: поворот и симметрая. В противном случае
     будет выполнен только поворот}
    procedure Compress(UseAllTransform: Boolean = True; BackProc: TProgressProc = nil);

    {Принудительно прерывает процесс фрактального сжатия}
    procedure Stop;

    {Выполняет распаковку изображения. IterCount - кол-во итераций распаковки,
     RegSize - размер региона с распакованном изображении. Если эта величина
     такая же, как RegionSize при сжатии, то размер изображение будет как при сжатии.
     При уменьшении RegSize распакованное изображение уменьшается и наоборот}
    procedure Decompress(IterCount: Integer = 15; RegSize: Integer = 0);

    {Строит изображение по доменам. Можно использовать сразу после сжатия для того,
     чтобы проверить качество сжатия. Изображение, построенное по доменам,
     похоже на восстановленное изображение, только имеет большую контрастность}
    procedure BuildImageWithDomains;

    {Проверяет, была ли выполнена компрессия (загружены ли IFS-данные, необходимые
     для декомпрессии). Если IfsIsLoad=True, то можно смело делать декомпрессию}
    property IfsIsLoad: Boolean read FIfsIsLoad;

    {Ширина изображения (исходного, построенного по доменам, или распакованного)}
    property ImageWidth: Integer read SourWidth;

    {Высота изображения (исходного, построенного по доменам, или распакованного)}
    property ImageHeight: Integer read SourHeight;

    {Возвращает значение яркости для указанного пикселя}
    property Pixel[X, Y: Integer]: Byte read GetPixel;

    {Загружает полноцветное изображение TBitMap для дальнейшей компрессии}
    procedure LoadImage(Image: TBitmap);

    {Рисует изображение на переданном TBitmap. При Regions = True рисуется исходное
     изображение, иначе рисуется доменное изображение (оно такое же, только
     в 4 раза меньше по площади)}
    procedure DrawImage(Image: TBitmap; Regions: Boolean = True);

    {Сохраняет результат сжатия в двоичный файл}
    procedure SaveToFile(FileName: string);

    {Выполняет загрузку данных из двоичного файла}
    procedure LoadFromFile(FileName: string);

    {Определяет, какой размер будет у IFS-файла после компрессии}
    function GetIFSFileSize(): Cardinal;
  published
    {Устанавливает размер региона.
     ВНИМАНИЕ! Нельзя изменять размер региона после загрузки изображения для
     компрессии, так как загруженное изображение корректируется в
     соответствии с RegionSize}
    property RegionSize: Integer read FRegionSize write SetRegionSize;

    {Величина смещения домена. По умолчанию = 1 (это число соответствует
     доменному изображению, которое в 4 раза меньше исходного)}
    property DomainOffset: Integer read FDomainOffset write SetDomainOffset;

    {Цветовой коэффициент Гамма}
    property Gamma: Real read FGamma write SetGamma;

    {Максимальный размер изображения}
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
    raise Exception.Create('Изображение для фрактального сжатия еще не загружено!');

  CreateRegions;
  CreateDomains;

  GetMem(BaseRegion, RegionSize * RegionSize);
  GetMem(Region, RegionSize * RegionSize);


  OneRegTime := 0;
  AllRegTime := 0;
  Tc := GetTickCount;
  // Перебираем регионы
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

      // Перебираем домены
      for DomY := 0 to YDomains - 1 do
        for DomX := 0 to XDomains - 1 do
        begin

          // Определяем разницу в яркости. Она всегда одна для любых трансформаций.
          Betta := Regions[RegX, RegY].MeanColor - Domains[DomX, DomY].MeanColor;
          
          DCoordX := DomX * DomainOffset;
          DCoordY := DomY * DomainOffset;

          // Проходим цикл по трансформациям
          for TransNum := 0 to TransCount - 1 do
          begin
            // Выполняем афинное преобразование
            TransformRegion(BaseRegion, Region, TTransformType(TransNum));

            // Определяем величину разницы между изображениями
            Error := GetDifference(Region, DCoordX, DCoordY, Betta);

            // Запоминаем во временные переменные лучшие показатели
            if Error < BestError then
            begin
              BestError := Error;
              BestFormNum := TransNum;
              BestDomX := DCoordX;
              BestDomY := DCoordY;
              BestBetta := Betta;
            end;

            if FStop then goto LExit; // Мгновенная реакция на команду выхода Stop
          end;  // Цикл по трансформациям
        end;  // Цикл по доменам

      // Теперь известно все, что нужно для данного региона
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

    end; // Цикл по регионам
                             
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

  // Для каждого домена определяем его координаты и усредненную яркость
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

  // Для каждого региона определяем его координаты и усредненную яркость
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
    Error('Ошибка отрисовки изображения!', []);
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
  ClearData;  // Удаляем массивы

  SourWidth := (Image.Width div RegionSize) * RegionSize;
  SourHeight := (Image.Height div RegionSize) * RegionSize;
  if (SourWidth > MaxImageSize) or (SourWidth < 16) or
     (SourHeight > MaxImageSize) or (SourHeight < 16)
    then Error('Недопустимые размеры изображения %d x %d', [Image.Width, Image.Height]);

  // ======= Заполняем массив SourImage (для регионов) ===========
  // Выделяем память под изображение
  GetMem(SourImage, SourWidth * SourHeight);

  // Делаем пиксели серыми и сохраняем их в строковом массиве SourImage
  mask := $000000FF;
  for Y := 0 to SourHeight - 1 do
    for X := 0 to SourWidth - 1 do
    begin
      PixColor := Image.Canvas.Pixels[X, Y]; // Определяем цвет пикселя
      red := (PixColor shr 16) and mask;
      green := (PixColor shr 8) and mask;
      blue := PixColor and mask;
      SourImage[Y * SourWidth + X] := Byte((red + green + blue) div 3);
    end;
  // Все! Теперь все пиксели стали серыми.

  // ======= Заполняем массив DomenImage (для доменов) ===========
  // Вообще-то домены в 2 раза больше регионов, однако из-за этого их сложно сравнивать.
  // А вот если мы доменное изображение уменьшим в 4 раза (по площади), то
  // размер 1 домена станет равным размеру 1 региона, что гораздо лучше
  // и экономнее.
  CreateDomainImage;

  FIfsIsLoad := False;
end;

procedure TFractal.SetDomainOffset(const Value: Integer);
begin
  if (Value < 1) or (Value > 32) then
    Error('Задана недопустимая величина смещения домена %d', [Value]);
  FDomainOffset := Value;
end;

procedure TFractal.SetGamma(const Value: Real);
begin
  if (Value < 0.1) or (Value > 1) then
    Error('Параметр GAMMA имеет недопустимое значение %d', [Value]);
  FGamma := Value;
end;

procedure TFractal.SetMaxImageSize(const Value: Integer);
begin
  FMaxImageSize := Value;
end;

procedure TFractal.SetRegionSize(const Value: Integer);
begin
  if (Value < 2) or (Value > 64) then
    Error('Задано недопустимое значение региона %d', [Value]);
  FRegionSize := Value;
end;

function TFractal.XDomains: Integer;
begin
  Result := SourWidth div (2 * DomainOffset) - 1;
  if Result <= 1 then
    Error('Недопустимое количество доменов по Х %d', [Result]);
end;

function TFractal.YDomains: Integer;
begin
  Result := SourHeight div (2 * DomainOffset) - 1;
  if Result <= 1 then
    Error('Недопустимое количество доменов по Y %d', [Result]);
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
    ttRot0: // Поворот на 0 градусов
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[I * RegionSize + J] := Sour[I * RegionSize + J];
      end;

    ttRot90: // Поворот на 90 градусов
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[(RegionSize - 1 - J) * RegionSize + I] := Sour[I * RegionSize + J];
      end;

    ttRot180: // Поворот на 180 градусов
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[(RegionSize - 1 - I) * RegionSize + (RegionSize - 1 - J)] := Sour[I * RegionSize + J];
      end;

    ttRot270: // Поворот на 270 градусов
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[J * RegionSize + (RegionSize - 1 - I)] := Sour[I * RegionSize + J];
      end;

    ttSimmX: // Симметрия относительно Х
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[(RegionSize - 1 - I) * RegionSize + J] := Sour[I * RegionSize + J];
      end;

    ttSimmY: // Симметрия относительно У
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[I * RegionSize + (RegionSize - 1 - J)] := Sour[I * RegionSize + J];
      end;

    ttSimmDiag1: // Симметрия от. главной диагонали
      begin
        for I := 0 to RegionSize - 1 do
          for J := 0 to RegionSize - 1 do
            Dest[J * RegionSize + I] := Sour[I * RegionSize + J];
      end;

    ttSimmDiag2: // Симметрия от. второстепенной диагонали
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
    Error('Файл "%s" не существует', [FileName]);

  with TMemoryStream.Create do
  begin
    LoadFromFile(FileName);
    Seek(0, soFromBeginning);
    Read(Header, SizeOf(TIfsHeader));
    if Header.FileExt <> 'IFS' then
    begin
      Free;
      Error('Файл "%s" имеет недопустимый формат!', [FileName]);
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

  // Нужен для масштабирования при декомпрессии
  FBaseRegionSize := RegionSize;
  
  FIfsIsLoad := True;
end;

procedure TFractal.SaveToFile(FileName: string);
var
  X, Y: Integer;
  Header: TIfsHeader;
begin
  if Regions = nil then
    Error('Сжатие изображения не выполнено!', []);

  if FileExists(FileName) and not DeleteFile(FileName) then
    Error('Невозможно удалить файл %s. Возможно он используется другим приложением' +
          'или доступен только для чтения.', [FileName]);    

  Header.FileExt := 'IFS';
  Header.RegSize := RegionSize;
  Header.XRegions := XRegions;
  Header.YRegions := YRegions;

  with TMemoryStream.Create() do
  begin
    // Сохраняем заголовочную информацию
    Write(Header, SizeOf(TIfsHeader));
    for Y := 0 to YRegions - 1 do
      for X := 0 to XRegions - 1 do
        Write(Regions[X, Y].Ifs, SizeOf(TIfsRec));

    try
      SaveToFile(FileName);
    except
      Free;
      Error('Произошла ошибка при сохранении в файл "%s"', [FileName]);
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
  // Массив Region должен быть уже заполненным.
  if not FIfsIsLoad then
    Error('Данные, необходимые для декомпрессии, не загружены!', []);


  Scale := 1;
  if RegSize >= 2 then
    begin
      SourWidth := XRegions * RegSize;
      SourHeight := YRegions * RegSize;
      Scale := FBaseRegionSize / RegSize;
      RegionSize := RegSize;
    end;


  // Создаем серое изображение.
  if Assigned(SourImage) then FreeMem(SourImage);
  GetMem(SourImage, SourWidth * SourHeight);

  // Делаем пиксели серыми и сохраняем их в строковом массиве SourImage
  for I := 0 to SourHeight * SourWidth - 1 do SourImage[I] := 127;

  for Iter := 1 to IterCount do
  begin
    // Создаем доменное изображение
    CreateDomainImage;
    // Доменное и регионное изображения создали

    // Проходим по всем регионам
    for J := 0 to YRegions - 1 do
      for I := 0 to XRegions - 1 do
      begin
        // Запоминаем соответствующий домен, чтобы над ним можно было выполнить преобразования
        GetMem(Domain1, RegionSize * RegionSize);
        GetMem(Domain2, RegionSize * RegionSize);
        CopyRegion(DomainImage, Domain1,
          Trunc(Regions[I, J].Ifs.DomCoordX / Scale),
          Trunc(Regions[I, J].Ifs.DomCoordY / Scale), DomainImageWidth);

        // Выполняем заданное преобразование
        TransformRegion(Domain1, Domain2, TTransformType(Regions[I, J].Ifs.FormNum));

        // Изменяем пиксели текущего региона
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
      // Определяем усредненный цвет пикселя (по цветам 4-х соседних пикселей)
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
    Error('Данные, необходимые для восстановления по доменам, не загружены!', []);

  for J := 0 to YRegions - 1 do
    for I := 0 to XRegions - 1 do
    begin
      GetMem(Domain1, RegionSize * RegionSize);
      GetMem(Domain2, RegionSize * RegionSize);

      // Копируем домен
      CopyRegion(DomainImage, Domain1, Regions[I, J].Ifs.DomCoordX,
        Regions[I, J].Ifs.DomCoordY, DomainImageWidth);

      // Выполняем афинное преобразование
      TransformRegion(Domain1, Domain2, TTransformType(Regions[I, J].Ifs.FormNum));

      // Копируем домен в регион
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
