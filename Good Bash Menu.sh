#!/bin/bash
#--------------
#Made by Arbifox
#--------------
#INSTRUCTIONS TO ADD MENU ITEMS:
#Simply add an option to the options array and the next numerical case to the selectedOptions case statement
#--------------

#Declare starting vars and options
options=("Option 1" "Option 2" "Option 3" "Exit")
selectedOption=0
index=0
stty -icanon -echo #Make inputs available as soon as they're pressed (non-canonical input/-icanon) and make inputted text not echo to terminal (-echo), ty stackoverflow
trap 'stty sane; tput cnorm' EXIT #return black box and revert the icanon and echo on exit, ty stackoverflow
tput civis #hide the black box

#Update the selected menu option
function menu() {
    compileOptions
    clear
    echo -e " Which Option?\n"
    echo -ne "$(for i in "${compiledOptions[@]}"; do echo "$i"; done)"
}

#Determine which option gets the > or space before it
function compileOptions() {
    x=0
    compiledOptions=()
    selectedChar='>'
    unselectedChar=' '
    for i in "${options[@]}"; do
        if [[ $x -eq $index ]]; then
            char=$selectedChar
        else
            char=$unselectedChar
        fi
        compiledOptions[x]=$(echo $i | sed -e 's/^/'"$char"'/')
        ((x++))
    done
}

#Exit the option and return to the menu with the first option selected, bring back non-caninical in
function exitOption() {
    index=0
    stty -icanon -echo; tput civis #Return non-canonical input, no text echo, and hidden black box
    menu
}

#Initialize menu and start menu logic
menu
while true; do
    #init key var, which key was pressed
    if [[ $key == $'\e' ]]; then
        # Read the next two characters for the full escape sequence if longer
        key+=$(dd bs=1 count=2 2>/dev/null)
    else
        key=$(dd bs=1 count=1 2>/dev/null) #read one input quietly and save to key var, ty stack overflow
    fi

    case $key in
    $'\e[A') #up arrow pressed, previous option
        if [[ $index -gt 0 ]]; then
            ((index--))
            menu
        fi
        ;;
    $'\e[B') #down arrow pressed, next option
        if [[ $index -lt $((${#options[@]} - 1)) ]]; then #dear god I hated writing this
            ((index++))
            menu
        fi
        ;;
    $'') #enter key pressed, select the current option
        stty sane; tput cnorm #return default terminal behavior, might be needed
        selectedOption=$((index + 1)) #I just prefer it like this
        case $selectedOption in
        1)
            clear
            echo "Option 1 Selected"
            sleep 2
            exitOption
            ;;
        2)
            clear
            echo "Option 2 Selected"
            sleep 2
            exitOption
            ;;
        3)
            clear
            read -p "Input?: " input #A case where returning normal behavior is needed
            exitOption
            ;;
        4)
            echo #for the newline
            exit
            ;;
        esac
        ;;
    esac
done