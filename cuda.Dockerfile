FROM nvidia/cuda:12.3.1-devel-ubuntu22.04
RUN apt-get update --fix-missing && \
    apt-get upgrade -y && \
    apt-get install -y --fix-missing --no-install-recommends git build-essential cmake gcc g++ portaudio19-dev ffmpeg libportaudio2 libasound-dev python3 python3-pip wget ocl-icd-opencl-dev opencl-headers clinfo libclblast-dev libopenblas-dev ninja-build python3.10-dev && \
    mkdir -p /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*

WORKDIR /app
ENV HOST=0.0.0.0 \
    CUDA_DOCKER_ARCH=all \
    LLAMA_CUBLAS=1
COPY cuda-requirements.txt .
RUN python3 -m pip install --upgrade pip cmake scikit-build setuptools wheel --no-cache-dir && \
    CMAKE_ARGS="-DLLAMA_CUBLAS=on" FORCE_CMAKE=1 pip install llama-cpp-python --no-cache-dir && \
    pip install --no-cache-dir -r cuda-requirements.txt
COPY . .
EXPOSE 8091
ENTRYPOINT ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8091", "--workers", "1", "--proxy-headers"]
