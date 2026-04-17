FROM python:3.9-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++ \
        git \
        libgl1 \
        libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

RUN pip install --no-cache-dir "numpy<2"

RUN pip install --no-cache-dir \
        nibabel \
        matplotlib \
        pandas \
        scikit-image \
        scikit-learn \
        scipy \
        SimpleITK \
        tqdm \
        PyWavelets \
        pyarrow \
        fastparquet \
        trimesh \
        xgboost \
        lightgbm \
        catboost

RUN pip install --no-cache-dir pyradiomics

COPY . .

RUN mkdir -p Patients

CMD ["python", "main.py"]
