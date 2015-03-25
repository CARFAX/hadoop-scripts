#!/bin/bash
#author David Abadir, CARFAX, INC. & uncredited Perl algorithm & lots of Bash scripting examples
#date 2015 03 25
#version=0.1
#notes: The awesome perl algorithm below can be found on many websites.  I found it here: https://snipt.net/djillanoise/improved-find-large-files-command/
#       The awesome perl algoritim below used variables $1 ($ ONE) and $l ($ lowercase L).  I changed $l to $log because it was very dificult to distinguish between the 1 (one) and the l (lowercase L).
#license: BSD 3
#Copyright (c) 2015, CARFAX, INC.
#All rights reserved.

#Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

#1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

#2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

#3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

FS_PATH="/"
SPLATSPACES=40
RECURSE=false
HADOOP_COMMAND="du"
AWK_COMMAND="awk "
PERL_COMMAND="perl -ne "
COMMAND=
SIZE_POSITION=\$1
DISPLAY_CHARS='"*"'
DISPLAY_ONLY=false

usage()
{
cat << EOF
usage: $0 [options] [path]
     : $0 [path] [options]

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

This script can take a long time, especially for recursive requests.  Consider installing snakebite (https://github.com/spotify/snakebite) to improve speed.

EOF
}
#Parse incoming options/arguments
while [[ $# > 0 ]]
do
key="$1"

case $key in
    -r)
       RECURSE=true
       ;;
    -h)
       usage
       exit
       ;;
    -l)
       DISPLAY_CHARS='("K","M","G","T","P")[$m]'
       ;;
    -d)
       DISPLAY_ONLY=true
       ;;
    *)
       FS_PATH=$1
       ;;
esac
shift
done
#Between snakebite, hdfs, and recursive searching, the desired data will be in different locations of the output.
if [[ $RECURSE = true ]]
then
    HADOOP_COMMAND="ls -R"
    SIZE_POSITION=\$5
    FNAME_POSITION=\$8
else
    SIZE_POSITION=\$1
fi

if [[ $(type -P "snakebite") ]]
then
     EXECUTABLE="snakebite "
     if [[ $RECURSE = false ]]
     then
        FNAME_POSITION=\$2
     fi
else
     EXECUTABLE="hdfs dfs -"
     if [[ $RECURSE = false ]]
     then
      FNAME_POSITION=\$3
     fi
fi

COMMAND="$EXECUTABLE$HADOOP_COMMAND $FS_PATH"
AWK_PROGRAM="{print int($SIZE_POSITION/1024), $FNAME_POSITION}"
PERL_PROGRAM='if ( /^(\d+)\s+(.*$)/){$log=log($1+.1);$m=int($log/log(1024)); printf  ("%6.1f\t%s\t%'$SPLATSPACES's  %s\n",($1/(2**(10*$m))),(("K","M","G","T","P")[$m]),'$DISPLAY_CHARS'x (1.5*$log),$2);}'

RUN_ME=("$COMMAND | $AWK_COMMAND '$AWK_PROGRAM' | sort -n | $PERL_COMMAND '$PERL_PROGRAM'")
if [[ $DISPLAY_ONLY = true ]]
then
  echo $RUN_ME
else
  eval $RUN_ME
fi
