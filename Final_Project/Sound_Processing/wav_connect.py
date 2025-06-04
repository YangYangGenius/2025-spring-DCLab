import os
import csv
import numpy as np
from scipy.io import wavfile

import sys
if sys.version_info[0] < 3:
    reload(sys)
    sys.setdefaultencoding('utf-8')     

def load_pcm_wav(filepath):
    sr, data = wavfile.read(filepath)
    assert sr == 32000, f"{filepath} 不是 32kHz"
    assert data.dtype == np.int16, f"{filepath} 不是 int16 PCM"
    if data.ndim != 1:
        raise ValueError(f"{filepath} 不是單聲道")
    return data

def process_wavs(folder):
    combined = []
    addr_map = {}
    current_addr = 0

    for fname in sorted(os.listdir(folder)):
        if fname.endswith(".wav"):
            path = os.path.join(folder, fname)
            data = load_pcm_wav(path)
            length = len(data)
            start = current_addr
            end = current_addr + length - 1
            addr_map[fname] = (start, end, length)
            combined.extend(data)
            current_addr += length

    return np.array(combined, dtype=np.int16), addr_map

def save_hex(data: np.ndarray, filename: str):
    with open(filename, "w") as f:
        for value in data:
            f.write(f"{value & 0xFFFF:04X}\n")

def save_bin(data: np.ndarray, filename: str):
    with open(filename, "wb") as f:
        f.write(data.astype('<i2').tobytes())

def save_csv(addr_map: dict, filename: str):
    with open(filename, "w", newline="") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(["sound_name", "start_addr", "end_addr", "length"])
        for fname, (start, end, length) in addr_map.items():
            writer.writerow([fname, start, end, length])

# --- 主程式 ---
wav_folder = "C:/1Yang_University_programming_hw/4DCLab/Final_Project/Sound_Processing/sounds"
output_hex = os.path.join(wav_folder, "output.hex")
output_bin = os.path.join(wav_folder, "output.bin")
output_csv = os.path.join(wav_folder, "address_map.csv")

pcm_data, addr_map = process_wavs(wav_folder)
save_hex(pcm_data, output_hex)
save_bin(pcm_data, output_bin)
save_csv(addr_map, output_csv)

print(" Address Map:")
for fname, (start, end, length) in addr_map.items():
    print(f"{fname}: {start} ~ {end} (len={length})")

print(f"\n Done. Total samples: {len(pcm_data)}")
print(f"Output files: {output_hex}, {output_bin}, {output_csv}")
