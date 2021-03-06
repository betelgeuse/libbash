EAPI="1"
DESCRIPTION="SunPinyin is a SLM (Statistical Language Model) based IME"
HOMEPAGE="http://sunpinyin.googlecode.com"
SRC_URI="http://open-gram.googlecode.com/files/dict.utf8.tar.bz2
		http://open-gram.googlecode.com/files/lm_sc.t3g.arpa.tar.bz2"
LICENSE="LGPL-2.1 CDDL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RDEPEND="dev-db/sqlite:3"
DEPEND="${RDEPEND}
		dev-util/pkgconfig"
MY_PATCH=ldflags.patch
PATCH=("1.patch" 2.patch)
ARRAY01=(1 2 3 [5]=4 5)
ARRAY02=(1 2 3)
ARRAY02[2]=4
ARRAY02[3]=5
EMPTY=
PARTIAL[5]=5
ARRAY_LAST=${ARRAY01[6]}
EMPTY_ARRAY=()
ARRAY03=(1 2 3)
ARRAY03[0]=
ARRAY04=(1 2 3)
# The following one is equivalent to ARRAY04[0]=
ARRAY04=
ARRAY05=(1 2 3 4 5)
ARRAY06=${ARRAY05[@]}
ARRAY07=${ARRAY05[*]}
ARRAY08="${ARRAY05[@]}"
ARRAY09="${ARRAY05[*]}"
IFS=";,:"
ARRAY10="${ARRAY05[*]}"
FOO001="networkmanager"
FOO002="0.8.2"
FOO003=${FOO001}-${FOO002}
FOO004=$?
FOO004=$!
FOO005=abc
FOO005+=def
echo $-
