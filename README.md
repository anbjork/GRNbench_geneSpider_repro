
This is a repo for reproducing GRNbenchmark 
https://grnbenchmark.org/
results of some of the GeneSpider
https://sonnhammer-tutorials.bitbucket.io/genespider.html
https://bitbucket.org/sonnhammergrni/genespider/src/master/
methods.

run_methods.py
and
run_methods.sh
are automation scripts to run all methods. 

Call
bash run_methods.sh
to run all methods. Know that some methods will crash and some won't finish within the 5 minute timeout.

geneSpider_GRNB_script.m
is called by the automation scripts. GeneSpider used for the network inference is a Matlab package.

Run with versions:
Matlab R2023b Update 4 (23.2.0.2428915) 64-bit (glnxa64), October 23, 2023
Python 3.10.12

Other versions probably work fine as well. If yours deviate a lot, some accomodations may be needed.

For questions about this repo, write
anton.bjork@scilifelab.se
Happy for questions or comments.

May the bits be ever in your favor,
Anton
