#!/bin/bash
#
roman=$1
declare -i number=0;

for char in $(grep -o . <<<"$roman"); do
       echo "My current char is = $char previous_char = $prev_char"


        if [[ $char == "I" ]]; then
                 number=$number+1;
        fi
        if [[ $char == "V" ]]; then
                number=$number+5;
        fi
        if [[ $char == "X" ]]; then
                number=$number+10;

        if [[ ($char == "V" || $char == "X") && $prev_char == "I" ]]; then
               number=$number-2;
       fi
        fi
        if [[ $char == "L" ]]; then
                number=$number+50;
        fi
        if [[ $char == "C" ]]; then
                number=$number+100;
        fi

        if [[ ($char == "C" || $char == "L") && $prev_char == "X" ]]; then
                number=$number-20;
       fi

        if [[ $char == "D" ]]; then
                number=$number+500;

"numeral_converter.sh" 51L, 994B                                                                                           1,1           Top
#!/bin/bash
#
roman=$1
declare -i number=0;

for char in $(grep -o . <<<"$roman"); do
       echo "My current char is = $char previous_char = $prev_char"


        if [[ $char == "I" ]]; then
                 number=$number+1;
        fi
        if [[ $char == "V" ]]; then
                number=$number+5;
        fi
#!/bin/bash
#
roman=$1
declare -i number=0;
        fi
        if [[ $char == "X" ]]; then
                number=$number+10;

        if [[ ($char == "V" || $char == "X") && $prev_char == "I" ]]; then
               number=$number-2;
       fi
        fi
        if [[ $char == "L" ]]; then
                number=$number+50;
        fi
        if [[ $char == "C" ]]; then
                number=$number+100;
        fi

        if [[ ($char == "C" || $char == "L") && $prev_char == "X" ]]; then
                number=$number-20;
       fi

        if [[ $char == "D" ]]; then
                number=$number+500;

        fi

        if [[ $char == "M" ]]; then
                number=$number+1000;
        fi


        if [[ ($char == "D" || $char == "M") && $prev_char == "C" ]]; then
               number=$number-200;

        fi
        prev_char=$char

done
echo "The number is : $number"
