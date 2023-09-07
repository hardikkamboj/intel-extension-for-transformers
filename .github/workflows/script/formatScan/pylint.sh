#!/bin/bash

source /intel-extension-for-transformers/.github/workflows/script/change_color.sh
cd /intel-extension-for-transformers
$BOLD_YELLOW && echo "---------------- git submodule update --init --recursive -------------" && $RESET
git config --global --add safe.directory "*"
git submodule update --init --recursive

$BOLD_YELLOW && echo "---------------- run python setup.py sdist bdist_wheel -------------" && $RESET
#pip install build --upgrade
#python3 -m build -s -w
export PYTHONPATH=`pwd`
#$BOLD_YELLOW && echo "---------------- pip install binary -------------" && $RESET
#pip install dist/intel_extension_for_transformers*.whl
pip list

cd /intel-extension-for-transformers/intel_extension_for_transformers/neural_chat/
if [ -f "requirements.txt" ]; then
    python -m pip install --default-timeout=100 -r requirements.txt
    pip list
else
    echo "Not found requirements.txt file."
fi

cd /intel-extension-for-transformers
log_dir=/intel-extension-for-transformers/.github/workflows/script/formatScan
if [ -f "requirements.txt" ]; then
    python -m pip install --default-timeout=100 -r requirements.txt
    pip list
else
    echo "Not found requirements.txt file."
fi
# install packages
pip install accelerate intel_extension_for_pytorch nlpaug nltk
pip install git+https://github.com/EleutherAI/lm-evaluation-harness.git@83dbfbf6070324f3e5872f63e49d49ff7ef4c9b3

echo "[DEBUG] list pipdeptree..."
pip install pipdeptree
pipdeptree

python -m pylint -f json --disable=R,C,W,E1129 \
    --enable=line-too-long \
    --max-line-length=120 \
    --extension-pkg-whitelist=numpy,nltk \
    --ignored-classes=TensorProto,NodeProto \
    --ignored-modules=tensorflow,torch,torch.quantization,torch.tensor,torchvision,mxnet,onnx,onnxruntime,neural_compressor,engine_py,neural_engine_py,intel_extension_for_transformers.neural_engine_py,neural_compressor.benchmark,intel_extension_for_transformers.transformers.modeling.modeling_causal \
    /intel-extension-for-transformers/intel_extension_for_transformers >${log_dir}/pylint.json
exit_code=$?

$BOLD_YELLOW && echo " -----------------  Current log file output start --------------------------" && $RESET
cat ${log_dir}/pylint.json
$BOLD_YELLOW && echo " -----------------  Current log file output end --------------------------" && $RESET

if [ ${exit_code} -ne 0 ]; then
    $BOLD_RED && echo "Error!! Please Click on the artifact button to download and view Pylint error details." && $RESET
    exit 1
fi
$BOLD_PURPLE && echo "Congratulations, Pylint check passed!" && $LIGHT_PURPLE && echo " You can click on the artifact button to see the log details." && $RESET
exit 0