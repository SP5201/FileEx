unit FormatHelpers;

interface

uses
  SysUtils;

function FormatByteSize(const bytes: UInt64): string;

implementation

function FormatByteSize(const bytes: UInt64): string;
const
  Units: array[0..5] of string = ('B', 'KB', 'MB', 'GB', 'TB', 'PB');
var
  i: Integer;
  value: Extended;
begin
  if bytes = 0 then
    Exit('0B/s');

  // 不再特殊处理小于1KB的值
  i := 0;
  value := bytes;

  while (i < High(Units)) and (value >= 1024) do
  begin
    value := value / 1024;
    Inc(i);
  end;

  // 根据大小调整显示精度
  if i = 0 then
    Result := Format('%d%s/s', [Trunc(value), Units[i]])
  else if value >= 100 then
    Result := Format('%.0f%s/s', [value, Units[i]])
  else if value >= 10 then
    Result := Format('%.1f%s/s', [value, Units[i]])
  else
    Result := Format('%.2f%s/s', [value, Units[i]]);
end;

end.


