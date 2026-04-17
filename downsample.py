"""
Erstellt eine verkleinerte Kopie eines Patientenordners für Testzwecke.
Alle NIfTI-Bilder werden auf eine einheitliche Zielgröße runtersampelt.
"""

import nibabel as nib
import numpy as np
from scipy.ndimage import zoom
import os
import shutil

SOURCE = "Patients/0"
TARGET = "Patients/0_small"
TARGET_SHAPE = (64, 64, 32)

os.makedirs(TARGET, exist_ok=True)

for fname in os.listdir(SOURCE):
    src_path = os.path.join(SOURCE, fname)

    if fname.endswith(".nii.gz"):
        print(f"Verkleinere {fname}...")
        img = nib.load(src_path)
        data = img.get_fdata()

        # Zoomfaktoren berechnen
        factors = tuple(t / s for t, s in zip(TARGET_SHAPE, data.shape))

        # Segmentierungen (peritumor, tumor) mit nearest-neighbor interpolieren
        # um Labels nicht zu verfälschen, alles andere mit linearer Interpolation
        if "tumor" in fname or "peritumor" in fname or "cavity" in fname:
            resampled = zoom(data, factors, order=0)  # nearest neighbor
        else:
            resampled = zoom(data, factors, order=1)  # linear

        # Affine anpassen
        new_affine = img.affine.copy()
        for i in range(3):
            new_affine[i, i] *= data.shape[i] / TARGET_SHAPE[i]

        new_img = nib.Nifti1Image(resampled, new_affine, img.header)
        nib.save(new_img, os.path.join(TARGET, fname))
        print(f"  {data.shape} → {resampled.shape}")
    else:
        # Nicht-NIfTI Dateien einfach kopieren
        shutil.copy(src_path, os.path.join(TARGET, fname))

print("\nFertig! Verkleinerter Patientenordner liegt in:", TARGET)