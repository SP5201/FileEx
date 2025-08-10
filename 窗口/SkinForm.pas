unit SkinForm;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, XCGUI, XLayout, XWidget, XElement, UI_Resource, XForm,
  Ui_Color, UI_SkinForm;

type
  TSkinForm = class(TSkinFormUI)
  private
    // 私有成员变量
  protected
    procedure Init; override;
  public
    constructor Create(hParent: integer);
  end;

implementation

uses
  Winapi.Messages, Winapi.ShellAPI, System.UITypes;

{ TSkinForm }

constructor TSkinForm.Create(hParent: integer);
var
  Form: TSkinForm;
begin
  Form := TSkinForm.FromXml('换肤窗口\SkinForm.xml', hParent) as TSkinForm;
  Form.Show;
end;

procedure TSkinForm.Init;
begin
  inherited;

end;

end. 