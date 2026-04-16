# ─────────────────────────────────────────────────────────────────────────────
# GlioMap – Glioblastom Rezidiv-Vorhersage
# Basis: Python 3.9 (pinned) auf Debian Slim für kleine Image-Größe
# ─────────────────────────────────────────────────────────────────────────────
FROM python:3.9-slim

# System-Abhängigkeiten für pyradiomics / SimpleITK / nibabel
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        gcc \
        g++ \
        git \
        libgl1 \
        libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

# requirements zuerst kopieren → Docker-Layer-Caching nutzen
COPY requirements.txt .

# Pakete in zwei Schritten:
# 1) numpy zuerst (pyradiomics braucht es beim Build)
# 2) Rest inkl. pyradiomics
RUN pip install --no-cache-dir numpy==1.21.6 && \
    pip install --no-cache-dir \
        nibabel==4.0.2 \
        matplotlib==3.6.2 \
        pandas==1.5.2 \
        scikit-image==0.19.2 \
        scikit-learn==1.0.2 \
        scipy==1.7.3 \
        SimpleITK==2.2.0 \
        tqdm==4.64.1 \
        PyWavelets==1.1.1 \
        pyarrow==16.1.0 \
        fastparquet==2024.5.0 \
        trimesh==3.13.0 \
        xgboost==1.6.0 \
        lightgbm==4.4.0 \
        catboost==1.0.6 \
    && pip install --no-cache-dir pyradiomics==3.0.1

# Quellcode kopieren
COPY . .

# Patients-Ordner anlegen, falls nicht gemountet
RUN mkdir -p Patients

# Standardmäßig main.py ausführen.
# Zum Überschreiben: docker run ... python extract_feature_functions.py
CMD ["python", "main.py"]