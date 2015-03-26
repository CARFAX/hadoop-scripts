# hadoop-scripts
Generalized utility scripts for Hadoop.

sudo -u hdfs ./hadoopspace.sh
<pre>
usage: hadoopspace.sh [options] [path]
     : hadoopspace.sh [path] [options]

This script gives a visual representation of space consumed by HDFS
It will use "snakebite" if available on the path.
It will use "hdfs dfs" otherwise.
The output has an exponential(/logarithmic) scale!

The executables perl, awk, sort, and either snakebite or hdfs must be in your \$PATH

OPTIONS:
 -h     Show this message
 -r     Recursive
 -l     Use letters (K,M,G,T,P) instead of *
 -d     Display the command instead of running it
 path   The HDFS path to interrogate.  The default path is "/"
</pre>
This script can take a long time, especially for recursive requests.  Consider installing snakebite (https://github.com/spotify/snakebite) to improve speed.
