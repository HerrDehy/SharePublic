@echo off
chcp 65001 >nul
title Triton and SageAttention Installation Helper - ComfyUI Desktop version

echo Welcome to the Triton and SageAttention installation helper utility - ComfyUI Desktop version
echo.
color 0E
echo ====================================================
echo =============== PLEASE READ CAREFULLY ==============
echo ====================================================
color 07
echo.
echo 1. This utility only works with the portable version of ComfyUI.
echo 2. This utility must be placed at the same level as your ComfyUI folder (not inside).
echo 3. Make sure to meet the prerequisites below before continuing:
echo.
echo     - Ensure that Python 3.12 or higher is installed and available in PATH.
echo       Run: python --version
echo         - ^If version is lower than 3.12, install latest Python 3.12+ from:
echo         https://www.python.org/downloads/windows/
echo.
echo     - Ensure that CUDA version is 12.8 or higher.
echo       Run: nvcc --version
echo         - ^If version is lower than 12.8, update CUDA:
echo         https://developer.nvidia.com/cuda-downloads
echo.
echo     - Download and install VC Redist, then restart your PC:
echo       https://aka.ms/vs/17/release/vc_redist.x64.exe
echo.
pause

echo.
echo === Creating Python virtual environment in ComfyUI\venv ===
python -m venv ComfyUI\venv

if errorlevel 1 (
    echo Failed to create virtual environment. Ensure Python 3.12+ is installed and accessible.
    pause
    exit /b
)

echo Activating virtual environment...
call ComfyUI\venv\Scripts\activate.bat

echo.
echo === Upgrading pip ===
python -m pip install --upgrade pip

echo.
echo === Uninstalling Triton ===
python -m pip uninstall -y triton-windows

echo === Installing Triton ===
python -m pip install -U "triton-windows<3.4"

echo.
echo === Uninstalling Torch ===
python -m pip uninstall -y torch torchvision torchaudio

echo === Installing Torch ===
python -m pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu128

echo.
echo Cleaning and creating folder ComfyUI\sage-attention-source...

if exist "ComfyUI\sage-attention-source" (
    rmdir /s /q "ComfyUI\sage-attention-source"
)
mkdir "ComfyUI\sage-attention-source"

echo.
color 0C
echo ####################################################
echo #######         MANUAL STEP REQUIRED         #######
echo ####################################################
color 07
echo Visit: https://github.com/woct0rdho/SageAttention/releases
echo.
echo Download the version of Sage Attention matching your installed torch version.
echo Example: For "cu128torch2.7.1-cp312-cp312-win_amd64", download:
echo "sageattention-2.2.0+cu128torch2.7.1-cp312-cp312-win_amd64.whl"
echo.
echo Then place the file inside: ComfyUI\sage-attention-source
echo.
pause

echo.
echo === Uninstalling Sage Attention ===
python -m pip uninstall -y sageattention

echo === Installing Sage Attention ===

set "found_whl="
for %%f in (ComfyUI\sage-attention-source\*.whl) do (
    set "found_whl=%%f"
    goto :install_whl
)

echo No .whl file found in ComfyUI\sage-attention-source
pause
exit /b

:install_whl
python -m pip install "%found_whl%"

echo.
echo Creating run_nvidia_gpu_sageattention.bat...
(
    echo.^@echo off
    echo.call ComfyUI\venv\Scripts\activate.bat
    echo.python ComfyUI\main.py --windows-standalone-build --use-sage-attention
    echo.pause
) > run_nvidia_gpu_sageattention.bat

echo.
echo Installation complete.
color 0B
echo -----------------------------------------------------
echo To launch ComfyUI with Sage Attention, run:
echo run_nvidia_gpu_sageattention.bat
echo.
echo The message "Using sage attention" displayed when starting ComfyUI indicates that Sage Attention has been successfully detected and activated.
echo -----------------------------------------------------
color 07
echo.
pause
