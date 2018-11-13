// 작성자: 조용호 (skshpapa80@gmail.com)
// 프로그램명 : 델파이로 만든 이미지 뷰어
// 작성일 : 2017-07-25
// 수정일 : 2018-11-14
// 블로그 : https://www.skshpapa80.net
//
// 사용자가 선택한 폴더의 썸네일 표시하고
// 썸네일을 선택하면 큰사진 불러오기

// 2018.11.14 PNG 읽기 추가

unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.Shell.ShellCtrls, Vcl.Menus, BrowserThreadUnit, GR32_Image, GR32, Vcl.ExtDlgs,
  System.ImageList, Vcl.ImgList, Vcl.ToolWin;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    menu_ImageOpen: TMenuItem;
    N3: TMenuItem;
    menu_Close: TMenuItem;
    ShellTreeView1: TShellTreeView;
    Splitter1: TSplitter;
    paImage: TPanel;
    lvThumbnails: TListView;
    Splitter2: TSplitter;
    ImgView32: TImgView32;
    OpenPictureDialog1: TOpenPictureDialog;
    StatusBar: TStatusBar;
    mnu_info: TMenuItem;
    mnu_about: TMenuItem;
    ToolBar: TToolBar;
    Btn_Rotate90: TToolButton;
    Btn_Rotate270: TToolButton;
    ImgList_Toolbar: TImageList;
    Btn_Rotate180: TToolButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure lvThumbnailsData(Sender: TObject; Item: TListItem);
    procedure lvThumbnailsChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure menu_CloseClick(Sender: TObject);
    procedure menu_ImageOpenClick(Sender: TObject);
    procedure mnu_aboutClick(Sender: TObject);
    procedure Btn_Rotate90Click(Sender: TObject);
    procedure Btn_Rotate270Click(Sender: TObject);
    procedure Btn_Rotate180Click(Sender: TObject);
  private
    { Private declarations }
    fBrowserThread : TBrowserThread;
    fSelIdx : Integer;
    procedure OnBrowsedFiles (sender : TObject);
    procedure OpenImage (const fileName : string);
    function FullPath (const fileName : string) : string;
    procedure SetStatusBarFileCount;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

uses uAbout;

procedure TfrmMain.Btn_Rotate180Click(Sender: TObject);
var
    tmp : TCustomBitmap32;
begin
    // 180도 회전
    if ImgView32.Bitmap.Empty then Exit;
    Screen.Cursor := crHourGlass;

    tmp := TCustomBitmap32.Create();

    try
        tmp.Assign(ImgView32.Bitmap);
        tmp.Rotate180(ImgView32.Bitmap);
        tmp.Free;
    finally
	    Screen.Cursor := crDefault;
    end;
end;

procedure TfrmMain.Btn_Rotate270Click(Sender: TObject);
var
    tmp : TCustomBitmap32;
begin
    // 270도 회전
    if ImgView32.Bitmap.Empty then Exit;
    Screen.Cursor := crHourGlass;

    tmp := TCustomBitmap32.Create();

    try
        tmp.Assign(ImgView32.Bitmap);
        tmp.Rotate270(ImgView32.Bitmap);
        tmp.Free;
    finally
	    Screen.Cursor := crDefault;
    end;
end;

procedure TfrmMain.Btn_Rotate90Click(Sender: TObject);
var
    tmp : TCustomBitmap32;
begin
    // 90도 회전
    if ImgView32.Bitmap.Empty then Exit;
    Screen.Cursor := crHourGlass;

    tmp := TCustomBitmap32.Create();

    try
        tmp.Assign(ImgView32.Bitmap);
        tmp.Rotate90(ImgView32.Bitmap);
        tmp.Free;
    finally
	    Screen.Cursor := crDefault;
    end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
    fBrowserThread := TBrowserThread.Create (True);
    fBrowserThread.OnBrowsedFiles := OnBrowsedFiles;
    fBrowserThread.FreeOnTerminate := True;
    fBrowserThread.Resume;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
    fBrowserThread.Terminate;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
    fSelIdx := -1;
    lvThumbnails.LargeImages := fBrowserThread.ImageList;
end;

function TfrmMain.FullPath(const fileName: string): string;
begin
    result := IncludeTrailingPathDelimiter(ShellTreeView1.Path) + fileName
end;

procedure TfrmMain.lvThumbnailsChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
    if Assigned (item) and item.Selected then begin
        OpenImage(FullPath(item.Caption));
        fSelIdx := item.Index;
    end;
end;

procedure TfrmMain.lvThumbnailsData(Sender: TObject; Item: TListItem);
var
    idx : Integer;
begin
    idx := Item.Index;
    if idx < fBrowserThread.FileList.Count then begin
        Item.Caption := fBrowserThread.FileList[idx];
        Item.ImageIndex := idx
    end;
end;

procedure TfrmMain.menu_CloseClick(Sender: TObject);
begin
    Close;
end;

procedure TfrmMain.menu_ImageOpenClick(Sender: TObject);
begin
    if OpenPictureDialog1.Execute then begin
        OpenImage(OpenPictureDialog1.FileName);
    end;
end;

procedure TfrmMain.mnu_aboutClick(Sender: TObject);
begin
    frmAbout := TfrmAbout.Create(Self);
    frmAbout.ShowModal;
    frmAbout.free;
end;

procedure TfrmMain.OnBrowsedFiles(sender: TObject);
begin
    lvThumbnails.Items.Count := fBrowserThread.FileList.Count;
    lvThumbnails.Refresh;
    Application.ProcessMessages;
    SetStatusBarFileCount;
end;

procedure TfrmMain.OpenImage(const fileName: string);
begin
    // 이미지 표시
    ImgView32.Bitmap.LoadFromFile(fileName);
    ImgView32.ScaleMode := smOptimalScaled;
end;

procedure TfrmMain.SetStatusBarFileCount;
begin
    if Assigned (lvThumbnails.Selected) then
        StatusBar.Panels[1].Text := Format ('%d of %d Images        ', [lvThumbnails.Selected.Index + 1, lvThumbnails.Items.Count])
    else
        StatusBar.Panels[1].Text := IntToStr (lvThumbnails.Items.Count) + ' Images        ';
end;

procedure TfrmMain.ShellTreeView1Change(Sender: TObject; Node: TTreeNode);
begin
    lvThumbnails.Items.BeginUpdate;
    try
        lvThumbnails.Items.Clear
    finally
        lvThumbnails.Items.EndUpdate
    end;

    if Assigned (fBrowserThread) then begin
        StatusBar.Panels.Items[0].Text := ShellTreeView1.Path;
        fBrowserThread.Browse(ShellTreeView1.Path);
    end;
end;

end.
