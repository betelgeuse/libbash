shopt -s extglob
ARRAY=(hi hello 1 2 3)
EAPI="3"
EAPI4="$((EAPI+1))"
FOO001="${EAPI:-hello}"
FOO002="${EAPI3:-hello}"
FOO003=123
FOO004=$EAPI
FOO005=$(( 1+1 ))
FOO006=${EAPI:=hello}
FOO007=${FOO008:=hello world}
FOO009=${EAPI:+hello}
FOO010=${NOT_EXIST:+hello}
FOO011=${FOO009:0}
FOO012=${FOO009:2}
FOO013=${FOO009: -2}
FOO014=${FOO009:100}
FOO015=${FOO009: -100}
FOO016=${FOO009:(-5 + 5)}
FOO017=${NOT_EXIST:0}
FOO018=${FOO009:0:2}
FOO019=${FOO009:2:2}
FOO020=${FOO009: -2:2}
FOO021=${FOO009:2:100}
FOO022=${FOO009: -2:100}
FOO023=${NOT_EXIST:0:2}
FOO024=${#FOO009}
FOO025=${#NOT_EXIST}
FOO026="${ARRAY[0]:-hello}"
FOO028="${ARRAY[5]:-hello}"
FOO029="${ARRAY2[0]:=hello}"
FOO030="${ARRAY2[0]:=hi}"
FOO031="${ARRAY2[0]:+hi}"
FOO032="${ARRAY2[1]:+hi}"
FOO033="${ARRAY[1]:1}"
FOO034="${ARRAY[1]:1:3}"
FOO035="${#ARRAY[0]}"
FOO036="${#ARRAY[@]}"
FOO037="${#ARRAY[*]}"
FOO038="${#ARRAY}"
FOO039="Hello World"
FOO040=${FOO039/nothing/nothing}
FOO041=${FOO039/o W/ow}
FOO042=${FOO039//o/e}
FOO043=${FOO039/#He/he}
FOO044=${FOO039/#he/he}
FOO045=${FOO039/%rld/rlD}
FOO046=${FOO039/%rlD/rlD}
FOO047=${FOO039/o W}
FOO048=${FOO039//o}
FOO049=${FOO039/#He}
FOO050=${FOO039/#he}
FOO051=${FOO039/%rld}
FOO052=${FOO039/%rlD}
FOO053=${FOO039/aaaaaaaaaaaa}
FOO054=${FOO039#hello}
FOO055=${FOO039##hello}
FOO056=${FOO039#Hello}
FOO057=${FOO039##Hello}
FOO058=${FOO039%world}
FOO059=${FOO039%%world}
FOO060=${FOO039%World}
FOO061=${FOO039%%World}
FOO062=${FOO039#Hel*}
FOO063=${FOO039##Hel*}
FOO064=${FOO039%*rld}
FOO065=${FOO039%%*rld}
FOO066=${FOO039/l/r}
FOO067=${FOO039//l/r}
FOO068=${FOO039/#He/he}
FOO069=${FOO039/#ello/i}
FOO070=${FOO039/%ld/d}
FOO071=${FOO039/%rl/r}
FOO072=${FOO039/+(l)/}
FOO073=${FOO039/+(l|e)}
FOO074=${FOO039/*(l)}
FOO075=${FOO039//*(l)}
FOO076=${FOO039//*(l|e)}
FOO077=${FOO039/?(l)}
FOO078=${FOO039//?(l)}
FOO079=${FOO039//?(l|e|o)}
FOO080=${FOO039/@([a-c]|[k-m])}
FOO081=${FOO039//@([a-c]|[k-m])}
target="abc123abc"
FOO082="${target##+(ab[c])*([[:digit:]])}"
function positional_parameter_test(){
    FOO083=$*
    FOO084=${*}
    FOO085=${*:1}
    FOO086=${*:1:2}
    FOO087=${*: -1}
    FOO088=${*: -2:5}
    FOO089=${*:0}
    FOO090=$@
    FOO091=${@}
    FOO092=${@:1}
    FOO093=${@:1:2}
    FOO094=${@: -1}
    FOO095=${@: -2:5}
    FOO096=${@:0}
    echo $#
}
positional_parameter_test 1 2 3 4 5
target="abc*abc"
echo ${target/*}
echo ${target/'*'}
echo ${target/"*"}
: ${FOO089:=}
ARRAY=(1 2 3 4 5)
echo ${ARRAY[@]:1}
echo ${ARRAY[@]:1:3}
echo $#
