@edho off
chcp 65001
SET ARCHIVE="C:\Program Files\7-Zip\7z.exe"
SET filename=PyVertexColorObjView
SET PARAMETERS=a -tzip

REM Korean OS = YYYY-MM-DD 
FOR /F "tokens=1-4 delims=- " %%i IN ('date /t') DO SET MZP_FILE=%filename%_%%i-%%j-%%k.mzp

%ARCHIVE% %PARAMETERS% %MZP_FILE% @_ArchiveList.txt

REM  pause