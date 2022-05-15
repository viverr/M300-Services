Rem run as administrator
@echo on & @setlocal enableextensions
@echo =========================
@echo Turn off the time service
net stop w32time
@echo ======================================================================
@echo Set the SNTP (Simple Network Time Protocol) source for the time server
w32tm /config /syncfromflags:manual /manualpeerlist:"127.0.0.1:123"
@echo =============================================
@echo ... and then turn on the time service back on
net start w32time
@echo =============================================
@echo Tell the time sync service to use the changes
w32tm /config /update
@echo =======================================================
@echo Reset the local computer's time against the time server
w32tm /resync /rediscover
@endlocal & @goto :EOF