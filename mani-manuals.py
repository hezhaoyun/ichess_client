import os


def enumerate_files(path):
    for root, _, files in os.walk(path):
        for file in files:
            yield os.path.join(root, file)

if __name__ == '__main__':
    
    for file in enumerate_files('assets/manuals'):
    
        if not file.endswith('.pgn'):
            continue

        manual_count = 0
        event_name = ''

        try:
            for line in open(file, 'r'):
                
                if line.startswith('[Event '):
                    
                    manual_count += 1
                    
                    if event_name == '':
                        event_name = line.split('"')[1]

        except UnicodeDecodeError:
            print(f"处理文件 {file} 时发生错误: UnicodeDecodeError")
            continue  # 如果当前编码失败，尝试下一个编码

        except Exception as e:
            print(f"处理文件 {file} 时发生错误: {str(e)}")
            break


        # convert to json format
        line = f'{{"file": "{file.split("/")[-1]}", "count": {manual_count}, "event": "{event_name}"}}'

        # write to file
        with open('assets/manuals.json', 'a') as f:
            f.write(line + ',\n')
