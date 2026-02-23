@echo off
REM ################################################################################
REM ExpenseTracker - Automated Android AAB Build Script (Windows)
REM 
REM This script automates the process of building a signed Android App Bundle (AAB)
REM ready for Google Play Store submission.
REM
REM Prerequisites:
REM - Flutter SDK installed
REM - Android SDK installed
REM - Java JDK 11+ installed
REM - Keystore file configured
REM - android\key.properties file configured
REM
REM Usage:
REM   build_android_aab.bat
REM ################################################################################

setlocal enabledelayedexpansion

echo ========================================
echo   ExpenseTracker Android AAB Builder
echo ========================================
echo.

REM Configuration
set APP_NAME=ExpenseTracker
set AAB_PATH=build\app\outputs\bundle\release\app-release.aab
set KEY_PROPERTIES=android\key.properties

REM Check prerequisites
echo [INFO] Checking prerequisites...

where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter is not installed or not in PATH
    exit /b 1
)

where java >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Java is not installed or not in PATH
    exit /b 1
)

where keytool >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] keytool is not available (part of Java JDK)
    exit /b 1
)

echo [SUCCESS] All prerequisites met
echo.

REM Display environment information
echo [INFO] Environment Information:
flutter --version | findstr "Flutter"
java -version 2>&1 | findstr "version"
echo.

REM Check for key.properties
if not exist "%KEY_PROPERTIES%" (
    echo [ERROR] key.properties file not found at %KEY_PROPERTIES%
    echo [ERROR] Please create this file with your keystore configuration
    echo [ERROR] See ANDROID_RELEASE_SIGNING_GUIDE.md for instructions
    exit /b 1
)

echo [SUCCESS] Keystore configuration found
echo.

REM Clean previous builds
echo [INFO] Cleaning previous builds...
call flutter clean
if exist build\app\outputs rmdir /s /q build\app\outputs
echo [SUCCESS] Clean complete
echo.

REM Get dependencies
echo [INFO] Getting Flutter dependencies...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to get dependencies
    exit /b 1
)
echo [SUCCESS] Dependencies retrieved
echo.

REM Build Android App Bundle
echo [INFO] Building Android App Bundle (AAB)...
echo [INFO] This may take several minutes...
echo.

call flutter build appbundle --release

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] AAB build complete
) else (
    echo [ERROR] AAB build failed
    exit /b 1
)
echo.

REM Verify AAB file exists
if not exist "%AAB_PATH%" (
    echo [ERROR] AAB file not found at expected location: %AAB_PATH%
    exit /b 1
)

REM Get AAB file size
for %%A in ("%AAB_PATH%") do set AAB_SIZE=%%~zA
set /a AAB_SIZE_MB=AAB_SIZE/1048576

REM Verify AAB signature
echo [INFO] Verifying AAB signature...
jarsigner -verify -verbose -certs "%AAB_PATH%" >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo [SUCCESS] AAB signature verified
) else (
    echo [ERROR] AAB signature verification failed
    echo [ERROR] The AAB may not be properly signed
    exit /b 1
)
echo.

REM Display results
echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo AAB Location: %AAB_PATH%
echo AAB Size: %AAB_SIZE_MB% MB
echo.

REM Next steps
echo Next Steps:
echo 1. Test the AAB by uploading to Play Console Internal Testing
echo 2. Upload to Google Play Console:
echo    - Go to https://play.google.com/console/
echo    - Select your app
echo    - Production ^> Create new release
echo    - Upload: %AAB_PATH%
echo.
echo 3. Complete release information and submit for review
echo.

echo [SUCCESS] Android AAB build process completed successfully!
pause
