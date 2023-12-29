@echo off

:start

del netstat.tmp

netstat -aon > netstat.tmp

for /F %%i in ('findstr 1\.2\.3 netstat.tmp') do ( set pid=%%i)

if "%pid%" neq "" (tasklist /svc)

timeout /T 1 /NOBREAK

goto start
