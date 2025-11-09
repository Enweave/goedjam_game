import os
import subprocess
from pprint import pprint
from typing import Dict, List


def wav_to_mp3():
    current_directory = os.getcwd()
    all_files = []
    for root, dirs, files in os.walk(current_directory):
        for file in files:
            all_files.append(os.path.join(root, file))
    wav_files = [file for file in all_files if file.endswith('.wav')]
    for wav_file in wav_files:
        mp3_file = wav_file.replace('.wav', '.mp3')
        subprocess.run(['ffmpeg', '-i', wav_file, '-b:a', '320k', mp3_file])
        os.remove(wav_file)

def normalize_sfx_names():
    current_directory = os.getcwd()
    dir_file_map: Dict[str, List[str]] = {}

    sfx_path_part = 'sfx/'

    for root, dirs, files in os.walk(os.path.join(current_directory, sfx_path_part)):
        for file in files:
            if file.endswith('.mp3'):
                dir_path = os.path.dirname(os.path.join(root, file))
                dir_name = os.path.basename(dir_path)

                if dir_name not in dir_file_map:
                    dir_file_map[dir_name] = []
                dir_file_map[dir_name].append(os.path.join(dir_path, file))

    for dir_path, files in dir_file_map.items():
        if len(files) > 0:
            for i, file_path in enumerate(files):
                old_path = file_path
                new_name = f"{dir_path.replace("_",'-')}-{i + 1}.mp3"

                new_path = os.path.dirname(old_path)
                new_path = os.path.join(new_path, new_name)
                
                print(f"Renaming {old_path} to {new_path}")
                if not os.path.exists(old_path):
                    print(f"Old path does not exist: {old_path}")
                    continue
                if not os.path.exists(os.path.dirname(new_path)):
                    print(f"New path directory does not exist: {os.path.dirname(new_path)}")
                    continue
                print('Renaming file...')
                os.rename(old_path, new_path)

if __name__ == "__main__":
    wav_to_mp3()
    normalize_sfx_names()