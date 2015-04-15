@echo off
:: Post, pre, script for backups

powershell -ExecutionPolicy Bypass -File "%programfiles%\burp_clientconfig2.ps1" %1 %2