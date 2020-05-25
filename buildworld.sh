#! /bin/bash
set -exu
[[ $# -eq 0 ]]

gpg --import < /root/priv.key
gpg --import < /usr/out/pub.key
#rm -v /root/priv.key /usr/out/pub.key

#gcc -march=native -Q --help=target | awk '$1 == "-march=" {print $2}'
LINES="`/march.sh`"
ARCH=`echo $LINES | awk '{print $1}'`
TUNE=`echo $LINES | awk '{print $2}'`
export   CFLAGS="${CFLAGS+x}   -march=$ARCH -mtune=$TUNE"
export CXXFLAGS="${CXXFLAGS+x} -march=$ARCH -mtune=$TUNE"
unset LINES ARCH TUNE

apt-fast update

for k in `awk '$2 == "install" {print $1}' /dpkg.list` ; do (
   apt-fast build-dep $k &&
   apt-fast source $k &&
   #&& cd $k-*/
   cd */ &&
   dpkg-buildpackage         \
     --root-command=fakeroot \
     --compression-level=9   \
     --compression=xz        \
     --sign-key=53F31F9711F06089\!
) || echo $k >> /dpkg.log ;
  apt-fast autoremove     ;
  #for p in $k-*.deb ; do
  # TODO test whether there are debs
  for p in *.deb ; do
    mv -v $p /usr/out/`dpkg --print-architecture`/
  done || :

  /repo.sh /usr/out

  #rm -rf $k-*
  rm -rf *
done

