#! /bin/bash

infile=$1
testnames=$2

gawk -vtestnames=$testnames '
($1 == "$U/_zombie\\") {
  n = split(testnames, x, ",");
  for (i = 1; i <= n; i++) {
    printf("\t$U/_%s\\\n", x[i]);
  }
} 

{
  print $0;
}' $infile 