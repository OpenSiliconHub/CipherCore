@echo off

REM ==========================================================
REM Toggle Synchronizer Regression Script
REM All generated files remain inside the sim directory.
REM ==========================================================

REM Change to the directory containing this batch file (sim)
cd /d "%~dp0"

REM Create the work library directory if it doesn't exist
if not exist work mkdir work

REM Remove any previous compiled library
if exist work\work-obj08.cf del /q work\work-obj08.cf

echo.
echo ==========================================
echo Compiling design...
echo ==========================================

ghdl -a --std=08 --workdir=work ..\src\toggle_synchronizer.vhd
if errorlevel 1 exit /b

ghdl -a --std=08 --workdir=work ..\tb\toggle_synchronizer_tb\src\toggle_synchronizer_tb.vhd
if errorlevel 1 exit /b

ghdl -e --std=08 --workdir=work toggle_synchronizer_tb
if errorlevel 1 exit /b

echo.
echo ==========================================
echo Running simulations...
echo ==========================================

for %%S in (2 5 10) do (

    echo.
    echo ------------------------------------------
    echo FAST clock, %%S synchronization stages
    echo ------------------------------------------

    ghdl -r --std=08 --workdir=work toggle_synchronizer_tb ^
        -gSYNC_STAGES=%%S ^
        -gSRC_CLK_PERIOD_NS=10 ^
        -gDEST_CLK_PERIOD_NS=8 ^
        --wave=fast_%%S.ghw
    if errorlevel 1 exit /b

    echo.
    echo ------------------------------------------
    echo SAME clock, %%S synchronization stages
    echo ------------------------------------------

    ghdl -r --std=08 --workdir=work toggle_synchronizer_tb ^
        -gSYNC_STAGES=%%S ^
        -gSRC_CLK_PERIOD_NS=10 ^
        -gDEST_CLK_PERIOD_NS=10 ^
        --wave=same_%%S.ghw
    if errorlevel 1 exit /b

    echo.
    echo ------------------------------------------
    echo SLOW clock, %%S synchronization stages
    echo ------------------------------------------

    ghdl -r --std=08 --workdir=work toggle_synchronizer_tb ^
        -gSYNC_STAGES=%%S ^
        -gSRC_CLK_PERIOD_NS=10 ^
        -gDEST_CLK_PERIOD_NS=16 ^
        --wave=slow_%%S.ghw
    if errorlevel 1 exit /b
)

echo.
echo ==========================================
echo All simulations completed successfully!
echo ==========================================
pause