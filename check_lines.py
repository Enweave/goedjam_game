import glob

if __name__ == '__main__':
    # find all files with .gd extension and count lines
    files = glob.glob('**/*.gd', recursive=True)
    total_lines = 0

    for file in files:
        with open(file) as f:
            total_lines += len(f.readlines())

    print(f'Total lines of code: {total_lines}')