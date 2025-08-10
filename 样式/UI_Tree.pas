unit Ui_Tree;

interface

uses
  Windows, Classes, XCGUI, SysUtils;

procedure XTree_SetDefStyle(Tree: Integer);

implementation

uses
  UI_Resource;

procedure XTree_SetDefStyle(Tree: Integer);
begin
  XTree_SetItemTemplate(Tree, XResource_LoadZipTemp(listItemTemp_type_tree, 'Tree.xml'));
  XTree_CreateAdapter(Tree);
  XTree_EnableConnectLine(Tree,False,False);
  XTree_SetItemHeightDefault(Tree,30,30);
  XTree_SetRowSpace(Tree,1);
 // index := XTree_InsertItemText(Tree, '������־');
 // XTree_ExpandItem(Tree,index,True);
 // XTree_InsertItemText(Tree, '������־',index);
 // XTree_InsertItemText(Tree, '������־',index);
end;

end.

