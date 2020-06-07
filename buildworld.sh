#! /usr/bin/env bash
set -exu
(( ! $# ))

gpg --import < /root/priv.key
gpg --import < /usr/out/pub.key
#rm -v /root/priv.key /usr/out/pub.key

ARCH="`/march.sh -no-tune`"
TUNE="`/mtune.sh`"
export   CFLAGS="${CFLAGS:-}   -march=$ARCH -mtune=$TUNE"
export CXXFLAGS="${CXXFLAGS:-} -march=$ARCH -mtune=$TUNE"
unset ARCH TUNE

apt-fast update
apt-fast full-upgrade

REPO="/usr/out/`dpkg --print-architecture`"
for k in `awk '$2 == "install" {print $1}' /dpkg.list` ; do (
   ERR=0
   if compgen -G "$REPO/$k-*.deb" > /dev/null ; then continue ; fi

   apt-fast build-dep "$k" &&
   apt-fast source    "$k" &&
   #&& cd $k-*/
   for K in */ ; do (
     cd "$K"
     #  --root-command=fakeroot \
     dpkg-buildpackage         \
       --root-command="firejail --rlimit-as=$((1 << 30))" \
       --compression-level=9   \
       --compression=xz        \
       --sign-key=53F31F9711F06089\!
   ) || ERR=1 ; done

   return "$ERR"
) || echo "$k" >> /dpkg.log ;
  apt-fast autoremove       ;
  #for p in $k-*.deb ; do
  [[ -d "$REPO" ]] || mkdir -pv "$REPO"
  if compgen -G "*.deb" > /dev/null ; then
    for p in *.deb ; do
      mv -v "$p" "$REPO/"
    done
  fi
  /repo.sh /usr/out

  #rm -rf $k-*
  rm -rf *
done

