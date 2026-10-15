SECONDS=0
src="$PWD"
stage="$(mktemp -d)"

find "$src" -mindepth 1 -maxdepth 1 \
  ! -name "run_clock*" \
  ! -name "mcmctree.clock*.final" \
  ! -name "summary.clock*.txt" \
  ! -name "figtree_clock*.nwk" \
  ! -name "rate_clock*.tre" \
  -exec cp -a {} "$stage"/ \;

for clock in 4 3 31 32; do
(
  set -euo pipefail

  d="$src/run_clock${clock}"
  rm -rf "$d"
  mkdir -p "$d"

  cp -a "$stage"/. "$d"/
  cd "$d"

  sed -E -i \
    "s/^[[:space:]]*clock[[:space:]]*=.*/clock=${clock}/" \
    mcmctree.ctl

  /mnt/hd1/home/sishuo/project/new_clock_models/GBM_OU/paml_edit/newest/src/mcmctree \
    > "$src/mcmctree.clock${clock}.final"

  # posterior mean summaries
  f="mcmc.txt"
  [ -f "$f" ] || f="mcmc.txt.gz"

  gzip -dcf "$f" |
  awk '
    NR==1{
      for(i=1;i<=NF;i++)
        if($i~/^(mu|r0|sigma2|drift|rgeneOpt|theta)$/){
          k++; idx[k]=i; name[k]=$i
        }
      next
    }
    {
      n++
      for(j=1;j<=k;j++){
        v=$(idx[j])
        s[j]+=v
        s2[j]+=v*v
      }
    }
    END{
      for(j=1;j<=k;j++)
        printf "%s\t%.10g\t%.10g\n",
          name[j], s[j]/n,
          (s2[j]-s[j]*s[j]/n)/n
    }
  ' > "$src/summary.clock${clock}.txt"


  # divergence-time tree
  ~/lab-tools/dating/figtree2tree.sh -i FigTree.tre \
    > "$src/figtree_clock${clock}.nwk"

  # branch-rate tree
  grep -A1 "^rateg" ./out.txt | tail -1 > ./rate.tre
  cp ./rate.tre "$src/rate_clock${clock}.tre"
) &
done

wait
rm -rf "$stage"

echo "DONE: clocks 4 3 31 32 finished in ${SECONDS}s"

> run_clocks.nohup.log 2>&1 &

