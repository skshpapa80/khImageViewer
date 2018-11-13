unit BrowserThreadUnit;

interface

uses
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
    Vcl.Controls, Vcl.ImgList, System.SyncObjs, WinApi.CommCtrl, System.Masks, ShlObj, Jpeg, pngimage;

type
    TBrowserThread = class;
    TExImageList = class (TCustomImageList)
    private
        fBrowserThread : TBrowserThread;
        fUpdating : boolean;
    protected
        procedure Change; override;
    public
        procedure BeginUpdate;
        procedure EndUpdate;
    end;

    TBrowserThread = class(TThread)
    private
        fBrowseEvent : TEvent;
        fBrowseDirectory : string;
        fGraphicsFilter : string;
        fAbort : boolean;
        fFileList : TStringList;
        fOnFiles: TNotifyEvent;
        fImageList : TExImageList;

        function MatchesFilter (const fileName : string): boolean;
        procedure AddToImageList (const fileName : string);
        procedure DoBrowse;
        function GetImageList: TCustomImageList;
    protected
        procedure Execute; override;
    public
        constructor Create (createSuspended : boolean);
        destructor Destroy; override;
        procedure Browse (const directory : string);
        function CreateThumbnail (const FileName : string) : TBitmap;
        procedure Terminate;
        procedure SetFileName (idx : Integer; const newName : string);
        property FileList : TStringList read fFileList;
        property ImageList : TCustomImageList read GetImageList;
        property OnBrowsedFiles : TNotifyEvent read fOnFiles write fOnFiles;
    end;

const
    US_BITMAP_TYPE = $4D42;
    US_JPEG_TYPE   = $FFFFD8FF;
    US_GIF_TYPE    = $4947;
    US_WMF_TYPE    = $FFFFCDD7;
    US_TIF_TYPE    = $4949;
    US_PCX_TYPE    = $50A;
    US_PSD_TYPE    = $4238;
    US_PNG_TYPE    = $5089;

implementation

{ TExImageList }

procedure TExImageList.BeginUpdate;
begin
    fUpdating := True
end;

procedure TExImageList.Change;
begin
    if not fUpdating then
        inherited;
end;

procedure TExImageList.EndUpdate;
begin
    fUpdating := False;
    Change;
end;

{ TBrowserThread }

procedure TBrowserThread.AddToImageList(const fileName: string);
var
    b : TBitmap;
begin
    b := CreateThumbnail(FileName);

    if Assigned (b) then
    try
        ImageList_Add(fImageList.Handle, b.Handle, 0);
    finally
        b.Free
    end
end;

procedure TBrowserThread.Browse(const directory: string);
begin
    fAbort := True;
    fBrowseDirectory := directory;
    fBrowseEvent.SetEvent
end;

constructor TBrowserThread.Create(createSuspended: boolean);
begin
    fBrowseEvent := TEvent.Create (Nil, False, False, '');
    fGraphicsFilter := '*.jpg;*.png;*.bmp;';
    fFileList := TStringList.Create;
    fImageList := TExImageList.CreateSize (190, 120);
    fImageList.fBrowserThread := Self;
    fImageList.AllocBy := 128;
    inherited Create (createSuspended);
end;

function TBrowserThread.CreateThumbnail(const FileName: string): TBitmap;
var
    bmp : TBitmap;
    pict : TPicture;
    r, br : TRect;
    j : TJPEGImage;
    m : TFileStream;
    isJPeg : boolean;
    w, h, c, rw, rh : Integer;
    g : TGraphic;
    sExt: string;
    MyType: SmallInt;
    MyFile: TFileStream;
    p : TPNGImage;
begin
    pict := Nil;
    j := Nil;
    m := Nil;
    bmp := TBitmap.Create;
    try
        try
            bmp.Width := fImageList.Width;
            bmp.Height := fImageList.Height;
            r := Rect (0, 0, bmp.Width, bmp.Height);

            // 파일 타입 알아내기
            MyFile := TFileStream.Create(fileName, fmOpenRead + fmShareDenyNone);
            MyFile.Read(MyType, SizeOf(MyType));

            sExt := '';
            case MyType of
                US_BITMAP_TYPE: sExt := 'BMP';
                US_JPEG_TYPE: sExt := 'JPEG';
                US_GIF_TYPE: sExt := 'GIF';
                US_WMF_TYPE: sExt := 'WMF';
                US_TIF_TYPE: sExt := 'TIF';
                US_PCX_TYPE: sExt := 'PCX';
                US_PSD_TYPE: sExt := 'PSD';
                US_PNG_TYPE: sExt := 'PNG';
            end;
            MyFile.Free;

            IsJpeg := UpperCase (ExtractFileExt (fileName)) = '.JPG';

            if sExt = 'JPEG' then begin
                // JPEG 처리
                m := TFileStream.Create (fileName, fmOpenRead or fmShareDenyNone);
                j := TJPegImage.Create;
                j.Scale := jsEighth;
                j.LoadFromStream (m);
                g := j;
            end
            else if sExt = 'PNG' then begin
                // PNG 처리
                m := TFileStream.Create (fileName, fmOpenRead or fmShareDenyNone);
                p := TPngImage.Create;
                m.Position := 0;
                p.LoadFromStream(m);
                g := p;
            end
            else begin
                pict := TPicture.Create;
                pict.LoadFromFile (fileName);
                g := pict.Graphic;
            end;
            w := g.Width;
            h := g.Height;

            br := r;
            InflateRect (r, -6, -6);
            bmp.Canvas.Lock;
            try
                DrawEdge (bmp.Canvas.Handle, br, EDGE_RAISED, BF_MIDDLE or BF_TOPLEFT or BF_BOTTOMRIGHT);
                rw := r.Right - r.Left;
                rh := r.Bottom - r.Top;
                if (w  < rw) and (h < rh) then
                    bmp.Canvas.Draw (r.Left + (rw - w) div 2, r.Top + (rh - h) div 2, g)
                else begin
                    if w > h then begin
                        c := h * r.Right div w;
                        r.top := (r.Bottom - c) div 2 + 1;
                        r.Bottom := r.top + c
                    end
                    else begin
                        c := w * r.Bottom div h;
                        r.left := (r.Right - c) div 2 + 1;
                        r.Right := r.left + c
                    end;
                    bmp.Canvas.StretchDraw (r, g)
                end
            finally
                bmp.Canvas.Unlock
            end
        finally
            pict.Free;
            j.Free;
            m.Free;
        end
    except
        FreeAndNil (bmp);
    end;

    Result := bmp
end;

destructor TBrowserThread.Destroy;
begin
    fBrowseEvent.Free;
    fFileList.Free;
    fImageList.Free;
    inherited;
end;

procedure TBrowserThread.DoBrowse;
begin
    if Assigned(OnBrowsedFiles) then
        OnBrowsedFiles(self)
end;

procedure TBrowserThread.Execute;
var
    f : TSearchRec;
    n : Integer;
begin
    while not Terminated do begin
        fBrowseEvent.WaitFor(INFINITE);
        fAbort := False;

        if not fAbort or Terminated then begin
            n := 0;
            fFileList.Clear;
            fImageList.Clear;
            if FindFirst (fBrowseDirectory +'\*.*', faAnyFile, f) = 0 then
                try
                    fImageList.BeginUpdate;
                    try
                        repeat
                            if (f.Attr and faDirectory) = 0 then
                                if MatchesFilter(f.Name) then begin
                                    fFileList.Add(f.Name);
                                    AddToImageList (fBrowseDirectory +'\' + f.Name);
                                    Inc (n);
                                    if n mod 20 = 0 then begin
                                        fImageList.EndUpdate;
                                        fImageList.BeginUpdate;
                                        Synchronize (DoBrowse);
                                    end;
                                end;
                        until Terminated or fAbort or (FindNext (f) <> 0)
                    finally
                        fImageList.EndUpdate
                    end;

                    if not (Terminated or fAbort) then
                        Synchronize (DoBrowse)
                finally
                    FindClose(f)
                end
        end
    end;
end;

function TBrowserThread.GetImageList: TCustomImageList;
begin
    result := fImageList
end;

function TBrowserThread.MatchesFilter(const fileName: string): boolean;
var
    p : Integer;
    s : string;
begin
    result := True;
    s := fGraphicsFilter;
    repeat
        p := Pos (';', s);
        if p > 0 then begin
            if MatchesMask(FileName, Copy (s, 0, p - 1)) then
                exit;
            s := Copy (s, p + 1, MaxInt)
        end
    until p = 0;

    if s <> '' then
        result := MatchesMask(FileName, s)
    else
        result := False
end;

procedure TBrowserThread.SetFileName(idx: Integer; const newName: string);
begin
    fFileList[idx] := newName
end;

procedure TBrowserThread.Terminate;
begin
    inherited Terminate;
    fBrowseEvent.SetEvent;
end;

end.
