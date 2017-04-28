#!/usr/bin/env bash

# SEG1 is MOST SIGNIFICANT SEGMENT
# SEG2 is MIDDLE
# SEG3 is LEAST SIGNIFICANT SEGMENT

export SEG1A=12
export SEG1B=13
export SEG1C=26
export SEG1D=19
export SEG1E=16
export SEG1F=20
export SEG1G=21

export SEG2A=25
export SEG2B=9
export SEG2C=8
export SEG2D=11
export SEG2E=7
export SEG2F=5
export SEG2G=6

export SEG3A=15
export SEG3B=17
export SEG3C=27
export SEG3D=23
export SEG3E=22
export SEG3F=24
export SEG3G=10

if [ "$DEBUG" == "1" ]; then
    # when in debug mode ignore gpio commands
    function gpio () {
        return
    }
fi
gpio -g mode $SEG1A out
gpio -g mode $SEG1B out
gpio -g mode $SEG1C out
gpio -g mode $SEG1D out
gpio -g mode $SEG1E out
gpio -g mode $SEG1F out
gpio -g mode $SEG1G out

gpio -g mode $SEG2A out
gpio -g mode $SEG2B out
gpio -g mode $SEG2C out
gpio -g mode $SEG2D out
gpio -g mode $SEG2E out
gpio -g mode $SEG2F out
gpio -g mode $SEG2G out

gpio -g mode $SEG3A out
gpio -g mode $SEG3B out
gpio -g mode $SEG3C out
gpio -g mode $SEG3D out
gpio -g mode $SEG3E out
gpio -g mode $SEG3F out
gpio -g mode $SEG3G out

gpio -g write $SEG1A 0
gpio -g write $SEG1B 0
gpio -g write $SEG1C 0
gpio -g write $SEG1D 0
gpio -g write $SEG1E 0
gpio -g write $SEG1F 0
gpio -g write $SEG1G 0

gpio -g write $SEG2A 0
gpio -g write $SEG2B 0
gpio -g write $SEG2C 0
gpio -g write $SEG2D 0
gpio -g write $SEG2E 0
gpio -g write $SEG2F 0
gpio -g write $SEG2G 0

gpio -g write $SEG3A 0
gpio -g write $SEG3B 0
gpio -g write $SEG3C 0
gpio -g write $SEG3D 0
gpio -g write $SEG3E 0
gpio -g write $SEG3F 0
gpio -g write $SEG3G 0



num0="1111110"
num1="0110000"
num2="1101101"
num3="1111001"
num4="0110011"
num5="1011011"
num6="1011111"
num7="1110000"
num8="1111111"
num9="1110011"
space="0000000"

underscore="0001000"

A="1110111"
a="1110111" #same
B="1111111"
b="0011111"
C="1001110"
c="0001101"
D="1111110"
d="0111101"
E="1001111"
e="1001111" #same
F="1000111"
f="1000111" #same
G="1011110"
g="1111011"
H="0110111"
h="0010111"
I="0110000"
i="0010000"
J="0111000"
j="0011000"
K="0110111" #H
k="0110111" #same
L="0001110"
l="0000110"
N="1110110" #N
m="0010101" #n
N="1110110"
n="0010101" #n
O="1111110"
o="0011101"
P="1100111"
p="1100111" #P
Q="1110011" #q
q="1110011"
R="0000111" #r
r="0000111"
S="1011011"
s="1011011" #s
T="1000110"
t="1000110" #T
U="0111110"
u="0011100"
V="0111110" #U
V="0011100" #u
W="0111110" #U
w="0011100" #u
X="0110111" #H
x="0110111" #H
Y="0110011" #4
y="0110011" #4
Z="1101101" #2
z="1101101" #2
function clean_up {
    gpio -g write $SEG1A 0
    gpio -g write $SEG1B 0
    gpio -g write $SEG1C 0
    gpio -g write $SEG1D 0
    gpio -g write $SEG1E 0
    gpio -g write $SEG1F 0
    gpio -g write $SEG1G 0

    gpio -g write $SEG2A 0
    gpio -g write $SEG2B 0
    gpio -g write $SEG2C 0
    gpio -g write $SEG2D 0
    gpio -g write $SEG2E 0
    gpio -g write $SEG2F 0
    gpio -g write $SEG2G 0

    gpio -g write $SEG3A 0
    gpio -g write $SEG3B 0
    gpio -g write $SEG3C 0
    gpio -g write $SEG3D 0
    gpio -g write $SEG3E 0
    gpio -g write $SEG3F 0
    gpio -g write $SEG3G 0

    exit $1
}
trap clean_up SIGHUP SIGINT SIGTERM

# seperate pattern preperation
function string2patterns () {
    str="$1"
    n=0
    returnval=""
    while [ $n -lt ${#1} ]; do
        c=${1:$n:1}
        case $c in
            [0-9])
                eval pattern=\${num$c}
                ;;
            [a-zA-Z])
                eval pattern=\${$c}
                ;;
            ' ')
                pattern=$space
                ;;
            *)
                pattern=$underscore
                ;;
            # ''|*[!0-9]*) echo bad ;;
        esac
        returnval="${returnval}${pattern} "
        n=$(($n+1))
    done
    echo "$returnval"
}
function print3patterns () {
    gpio -g write $SEG1A ${1:0:1}
    gpio -g write $SEG1B ${1:1:1}
    gpio -g write $SEG1C ${1:2:1}
    gpio -g write $SEG1D ${1:3:1}
    gpio -g write $SEG1E ${1:4:1}
    gpio -g write $SEG1F ${1:5:1}
    gpio -g write $SEG1G ${1:6:1}

    gpio -g write $SEG2A ${2:0:1}
    gpio -g write $SEG2B ${2:1:1}
    gpio -g write $SEG2C ${2:2:1}
    gpio -g write $SEG2D ${2:3:1}
    gpio -g write $SEG2E ${2:4:1}
    gpio -g write $SEG2F ${2:5:1}
    gpio -g write $SEG2G ${2:6:1}

    gpio -g write $SEG3A ${3:0:1}
    gpio -g write $SEG3B ${3:1:1}
    gpio -g write $SEG3C ${3:2:1}
    gpio -g write $SEG3D ${3:3:1}
    gpio -g write $SEG3E ${3:4:1}
    gpio -g write $SEG3F ${3:5:1}
    gpio -g write $SEG3G ${3:6:1}
}
function print3seg () {
    str="$1"
    c1=${str:0:1}     # Get the first character
    c2=${str:1:1}     # Get the second character
    c3=${str:2:1}     # Get the second character
    #echo "DEBUG: c1,c2,c3  $c1,$c2,$c3"
    case $c1 in
        [0-9])
            eval c1pattern=\${num$c1}
            ;;
        [a-zA-Z])
            eval c1pattern=\${$c1}
            ;;
        ' ')
            eval c1pattern=\${$space}
            ;;
        *)
            eval c1pattern=\${$underscore}
            ;;
        # ''|*[!0-9]*) echo bad ;;
    esac
    case $c2 in
        [0-9])
            eval c2pattern=\${num$c2}
            ;;
        [a-zA-Z])
            eval c2pattern=\${$c2}
            ;;
        ' ')
            eval c2pattern=\${$space}
            ;;
        *)
            eval c2pattern=\${$underscore}
            ;;
        # ''|*[!0-9]*) echo bad ;;
    esac
    case $c3 in
        [0-9])
            eval c3pattern=\${num$c3}
            ;;
        [a-zA-Z])
            eval c3pattern=\${$c3}
            ;;
        ' ')
            eval c3pattern=\${$space}
            ;;
        *)
            eval c3pattern=\${$underscore}
            ;;
        # ''|*[!0-9]*) echo bad ;;
    esac
    # gpio -g write $SEG1A 0
    # gpio -g write $SEG1B 0
    # gpio -g write $SEG1C 0
    # gpio -g write $SEG1D 0
    # gpio -g write $SEG1E 0
    # gpio -g write $SEG1F 0
    # gpio -g write $SEG1G 0
    gpio -g write $SEG1A ${c1pattern:0:1}
    gpio -g write $SEG1B ${c1pattern:1:1}
    gpio -g write $SEG1C ${c1pattern:2:1}
    gpio -g write $SEG1D ${c1pattern:3:1}
    gpio -g write $SEG1E ${c1pattern:4:1}
    gpio -g write $SEG1F ${c1pattern:5:1}
    gpio -g write $SEG1G ${c1pattern:6:1}

    # gpio -g write $SEG2A 0
    # gpio -g write $SEG2B 0
    # gpio -g write $SEG2C 0
    # gpio -g write $SEG2D 0
    # gpio -g write $SEG2E 0
    # gpio -g write $SEG2F 0
    # gpio -g write $SEG2G 0
    gpio -g write $SEG2A ${c2pattern:0:1}
    gpio -g write $SEG2B ${c2pattern:1:1}
    gpio -g write $SEG2C ${c2pattern:2:1}
    gpio -g write $SEG2D ${c2pattern:3:1}
    gpio -g write $SEG2E ${c2pattern:4:1}
    gpio -g write $SEG2F ${c2pattern:5:1}
    gpio -g write $SEG2G ${c2pattern:6:1}

    # gpio -g write $SEG3A 0
    # gpio -g write $SEG3B 0
    # gpio -g write $SEG3C 0
    # gpio -g write $SEG3D 0
    # gpio -g write $SEG3E 0
    # gpio -g write $SEG3F 0
    # gpio -g write $SEG3G 0
    gpio -g write $SEG3A ${c3pattern:0:1}
    gpio -g write $SEG3B ${c3pattern:1:1}
    gpio -g write $SEG3C ${c3pattern:2:1}
    gpio -g write $SEG3D ${c3pattern:3:1}
    gpio -g write $SEG3E ${c3pattern:4:1}
    gpio -g write $SEG3F ${c3pattern:5:1}
    gpio -g write $SEG3G ${c3pattern:6:1}

}
