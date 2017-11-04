program githubprojectinfo;

{$APPTYPE CONSOLE}

uses
  Classes,
  SysUtils;

const
  username = 'aleksusklim';
  url = 'https://github.com/' + username + '/';
  info = 'githubproject.info';
  md = 'README.md';
  bom = #$EF#$BB#$BF;

function GitHub(Project: string; Directory: string = ''): string;
begin
  if Directory = '' then
    Result := url + Project
  else
    Result := url + Project + '/tree/master/' + Directory;
end;

function CopyInfo(ReadFrom: string; var Desten: Text): string;
var
  Line: string;
  Source: Text;
begin
  FileMode := 0;
  Assign(Source, ReadFrom);
  Reset(Source);
  while not Eof(Source) do
  begin
    Readln(Source, Line);
    Line := StringReplace(Line, bom, '', []);
    Writeln(Desten, Line);
  end;
  Close(Source);
  FileMode := 2;
end;

procedure TreeList(List: TStringList; Path: string);
var
  Search: TSearchRec;
begin
  if FindFirst(Path + '*', faDirectory, Search) <> 0 then
    Exit;
  repeat
    if (Search.Attr and faDirectory) <> 0 then
      if Search.Name[1] <> '.' then
        if FileExists(Path + search.Name + '\' + info) then
          List.Add(Search.Name);
  until FindNext(Search) <> 0;
end;

procedure Navigation(var Readme: Text; Repository, Category, Project: string);
begin
  Write(Readme, '# [', Repository, '](', GitHub(Repository), ' "', Repository, '")');
  if Category <> '' then
    Write(Readme, '/[', Category, '](', GitHub(Repository, Category), ' "', Repository, '/', Category, '/")/');
  if Project <> '' then
    Write(Readme, '[', Project, '](', GitHub(Project), ' "', Repository, '/', Category, '/', Project, '/")/');
  Writeln(Readme);
  Writeln(Readme);
end;

function DoProject(Path, Repository, Category, Project: string): string;
var
  Readme: Text;
begin
  Writeln('P: ', Project);
  Result := '';
  Assign(Readme, Path + '\' + md);
  Rewrite(Readme);
  Write(Readme, bom);
  Navigation(Readme, Repository, Category, Project);
  CopyInfo(Path + info, Readme);
  Writeln(Readme);
  Writeln(Readme, '---');
  Writeln(Readme);
  Writeln(Readme, '_[Back](', GitHub(Repository, Category), ' "', Repository, '/', Category, '/', '")_');
  Writeln(Readme);
  Writeln(Readme, '_[Home](', GitHub(Repository), ' "', Repository, '")_');
  Close(Readme);
end;

function DoCategory(Path, Repository, Category: string): Integer;
var
  Readme: Text;
  List: TStringList;
  Index: Integer;
  Project, Descr: string;
begin
  Writeln('C: ', Category);
  List := TStringList.Create();
  Assign(Readme, Path + '\' + md);
  Rewrite(Readme);
  Write(Readme, bom);
  Navigation(Readme, Repository, Category, '');
  CopyInfo(Path + info, Readme);
  Writeln(Readme);
  Writeln(Readme, 'For more info, see the [global index](', GitHub(Repository), ' "', Repository, '").');
  Writeln(Readme);
  Writeln(Readme, '## Projects:');
  Writeln(Readme);
  TreeList(List, Path);
  Result := List.Count;
  for Index := 0 to List.Count - 1 do
  begin
    Project := List[Index];
    Descr := DoProject(Path + '\' + Project + '\', Repository, Category, Project);
    if Descr <> '' then
      Descr := ' (' + Descr + ')';
    Writeln(Readme, '- [', Project, '](', GitHub(Project), ' "', Repository, '/', Category, '/', Project, '/")', Descr);
  end;
  Writeln(Readme);
  Writeln(Readme, '---');
  Writeln(Readme);
  Writeln(Readme, '_[Back](', GitHub(Repository), ' "', Repository, '/', '")_');
  Close(Readme);
  List.Free();
end;

procedure DoRepository(Path, Repository: string);
var
  Readme: Text;
  List: TStringList;
  Index, Count: Integer;
  Category: string;
begin
  Writeln('R: ', Repository);
  List := TStringList.Create();
  Assign(Readme, Path + '\' + md);
  Rewrite(Readme);
  Write(Readme, bom);
  Navigation(Readme, Repository, '', '');
  CopyInfo(Path + info, Readme);
  Writeln(Readme);
  Writeln(Readme, '## Categories:');
  Writeln(Readme);
  TreeList(List, Path);
  for Index := 0 to List.Count - 1 do
  begin
    Category := List[Index];
    Count := DoCategory(Path + Category + '\', Repository, Category);
    Writeln(Readme, '- [', Category, '](./', Category, '/ "', Repository, '/', Category, '/") (', Count, ' proj.)');
  end;
  Writeln(Readme);
  Writeln(Readme, '### License:');
  Writeln(Readme);
  Writeln(Readme, '[WTFPL](https://en.wikipedia.org/wiki/WTFPL "Wikipedia: WTFPL") (Public Domain) always for my own code.');
  Close(Readme);
  List.Free();
end;

procedure Main();
var
  rootdir, repository: string;
begin
  rootdir := GetCurrentDir();
  repository := ExtractFileName(rootdir);
  rootdir := rootdir + '\';
  if not FileExists(rootdir + info) then
    Exit;
  DoRepository(rootdir, repository);
  Writeln('Done!');
  Writeln('');
end;

begin
  Main();
end.

