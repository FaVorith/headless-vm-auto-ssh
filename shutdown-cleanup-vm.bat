REM Shutdown logic based on https://stackoverflow.com/a/53821501/9675307
echo Shutting down VM
%VirtualBox% controlvm %VM% acpipowerbutton
IF ERRORLEVEL 1 EXIT /B 1

:SHUTDOWNLOOP
REM Sleep for 1 second
timeout 5
%VirtualBox% showvminfo %VM% --machinereadable | findstr VMState=\"running\">NUL
IF %ERRORLEVEL% NEQ 0 GOTO END
echo VM %VM% not powered off yet...
GOTO SHUTDOWNLOOP

:END
echo VM %VM% powered off. Bye.

REM Delete forwarding rule if we created one in this script
IF %createdNewRule%==True %VirtualBox% modifyvm %VM% --natpf1 delete %ForwardingRuleName%
