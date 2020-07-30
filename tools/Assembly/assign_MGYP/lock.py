from filelock import Timeout, FileLock
import time

file_path = 'number.txt'
lock_path = file_path + ".lock"
lock = FileLock(lock_path, timeout=20)
try:
    with lock.acquire(timeout=3600):
        fd = open(file_path, 'r+')
        max = fd.read()
        next_acc = int(max) + 1
        print('Start with accession number ', next_acc)
        fd.seek(0)
        fd.truncate()
        time.sleep(20)
        fd.write(str(next_acc))
        fd.close()
except Timeout:
    print("Another instance of this application currently holds the lock.")
