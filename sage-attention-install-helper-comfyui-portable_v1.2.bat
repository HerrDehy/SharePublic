@echo off
chcp 65001 >nul
title Triton and SageAttention Installation Helper

echo Welcome to the Triton and SageAttention installation helper utility
echo.
echo PLEASE READ CAREFULLY:
echo.
echo 1. This utility only works with the portable version of ComfyUI.
echo 2. This utility must be placed inside the ComfyUI source folder, at the same level as the folders: ComfyUI, python_embeded, and update.
echo 3. Make sure to meet the prerequisites below before continuing:
echo.
echo     - Ensure that the embedded Python version is 3.12 or higher. Run the following command:
echo       "python_embeded\python.exe --version"
echo       from the directory containing ComfyUI, python_embeded, and update folders.
echo         - If the version is lower than 3.12, run the script:
echo         "update\update_comfyui_and_python_dependencies.bat"
echo.
echo     - Ensure that CUDA version is 12.8 or higher. Run the following command:
echo       "nvcc --version"
echo         - If the version is lower than 12.8, update CUDA:
echo         https://developer.nvidia.com/cuda-downloads
echo.
echo     - Download and install VC Redist, then restart your PC:
echo       https://aka.ms/vs/17/release/vc_redist.x64.exe
echo.
pause

echo.
echo === Uninstalling Triton ===
python_embeded\python.exe -m pip uninstall -y triton-windows
echo === Installing Triton ===
python_embeded\python.exe -m pip install -U "triton-windows<3.4"

echo.
echo === Uninstalling Torch ===
python_embeded\python.exe -m pip uninstall -y torch torchvision torchaudio
echo === Installing Torch ===
python_embeded\python.exe -m pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu128


echo.
echo Cleaning and creating folder ComfyUI\sage-attention-source...

if exist "ComfyUI\sage-attention-source" (
    rmdir /s /q "ComfyUI\sage-attention-source"
)
mkdir "ComfyUI\sage-attention-source"


echo.
echo === Manual Step Required ===
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
python_embeded\python.exe -m pip uninstall -y sageattention
echo === Installing Sage Attention ===

if exist "ComfyUI\sage-attention-source\*.whl" (
    for %%f in (ComfyUI\sage-attention-source\*.whl) do (
        python_embeded\python.exe -m pip install "%%f"
        goto :done
    )
) else (
    echo No .whl file found in ComfyUI\sage-attention-source
    pause
    exit /b
)
:done


echo.
echo Creating run_nvidia_gpu_sageattention.bat...
(
    echo.^@echo off
    echo.^.\python_embeded\python.exe -s ComfyUI\main.py --windows-standalone-build --use-sage-attention
    echo.pause
) > run_nvidia_gpu_sageattention.bat


echo.
echo Installation complete.
echo To launch ComfyUI with Sage Attention, run:
echo run_nvidia_gpu_sageattention.bat
echo or add the --use-sage-attention flag to your main.py launch command.
echo.
echo The message "Using sage attention" displayed when starting ComfyUI indicates that Sage Attention has been successfully detected and activated.
echo.
pause
