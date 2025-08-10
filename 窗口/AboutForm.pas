unit AboutForm;

interface

uses
  System.SysUtils, System.Classes, Winapi.Windows, XCGUI, XLayout, XWidget, XElement, UI_Resource, XForm,
  Ui_Color, UI_AboutForm;

type
  TAboutForm = class(TAboutFormUI)
  private
    // 私有成员变量
  protected
    procedure Init; override;
  public
        constructor  Create(hParent: integer);
  end;

implementation

uses
  Winapi.Messages, Winapi.ShellAPI, System.UITypes;

{ TAboutForm }

constructor TAboutForm.Create(hParent: integer);
var
  Form: TAboutForm;
begin
  Form := TAboutForm.FromXml('AboutForm.xml', hParent) as TAboutForm;
  Form.Show;
end;

procedure TAboutForm.Init;
begin
  inherited;
end;


end. 