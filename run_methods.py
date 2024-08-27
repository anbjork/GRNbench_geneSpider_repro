
import subprocess
import json
import functools

timeout = 60*5  # In seconds


s = './get_method_list/gene_spider_methods.json'
with open(s) as f:
    methods = json.load(f)

flush_print = functools.partial(print, flush = True)


for method in methods:

    flush_print()
    flush_print()

    matlab_commands = f"method = string('{method}'); run('geneSpider_GRNB_script.m'); exit;"
    flush_print(matlab_commands)

    cmd = [
        'matlab', 
        '-nodisplay', 
        '-nosplash', 
        '-nodesktop', 
        '-r', 
        matlab_commands]

    try:
        p = subprocess.run(cmd, timeout=timeout)
    except subprocess.TimeoutExpired:
        flush_print(f'Timeout for {cmd} ({timeout}s) expired')
    # Never so far reached this, because on error in Matlab, 
    # one just sits in the Matlab prompt until timeout
    except Exception as e:
        # There is no Matlab error that would make me want to stop
        # execution of this. I want to know what it was though
        flush_print(e)

