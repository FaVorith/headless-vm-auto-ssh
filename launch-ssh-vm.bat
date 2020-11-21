@echo off
SETLOCAL EnableDelayedExpansion

REM Author: Fabian Voith
REM Version: 1.0.0
REM admin@fabian-voith.de

set VirtualBox="C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
set VM="CentOS 8 Minimal"
set ForwardingRuleName=SSHfromHost
set HostPort=2222
set GuestPort=22
set WaitingTime=0
set LogonUser=root

REM Check if VM is already running (VMState="running")
%VirtualBox% showvminfo %VM% --machinereadable | findstr VMState=\"running\" >NUL
IF %ERRORLEVEL% EQU 0 GOTO PORTFORWARDING
REM If we did not find "VMState=running", we will start up the VM:
echo Starting up VM...
%VirtualBox% startvm %VM% --type headless
set WaitingTime=120
set createdNewRule=True

:PORTFORWARDING
REM Check if a port forwarding rule is already present
%VirtualBox% showvminfo %VM% --machinereadable | findstr Forwarding(.)=\"%ForwardingRuleName%,tcp,,%HostPort%,,%GuestPort%" >NUL
IF %ERRORLEVEL% EQU 0 GOTO STARTUP
REM If we could not find a forwarding rule that looks like the one we would like to set up, we create one
echo Creating port forwarding rule...
%VirtualBox% controlvm %VM% natpf1 "%ForwardingRuleName%,tcp,,%HostPort%,,%GuestPort%"

:STARTUP
REM For more elegant solutions on finding out if VM is ready, check:
REM https://askubuntu.com/questions/307677/constantly-check-if-the-virtualbox-is-started-or-still-booting-up-from-a-script
timeout %WaitingTime%
ssh %LogonUser%@127.0.0.1 -p %HostPort%
REM For PuTTY: "C:\Program Files\PuTTY\putty.exe" %LogonUser%@127.0.0.1 -P %HostPort%
