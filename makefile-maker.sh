#!/bin/bash

get_src()
{
	#Start adding the sources to the Makefile

	echo $1 $2
	echo -n 'SRC	=' >> Makefile	#Create source variable
	if [ "$2" = "c++" ]
	then
		SRC=$(cd $1; find . -type f -name *.cpp -not -name ".*")	#Taking all sources files
	elif [ "$2" = "cc" ]
	then
		SRC=$(cd $1; find . -type f -name *.c -not -name ".*")	#Taking all sources files
	fi

	local total_files=$(echo $SRC| xargs -n 1 | wc -l)	#Get the nb of files

	IFS=$'\n' read -rd '' -a array <<< $SRC	#Converting into an array

	for i in ${!array[@]}; do #For each file
		echo -n '	' >> Makefile	#Append a tab
		if [ $i -gt 0 ]; then
			echo -n '	' >> Makefile #Append one more time if not the first one
		fi
		echo -n ${array[i]} | sed 's|^./||g' >> Makefile	#Write the file name without the cwd
		if [ $i -lt $((total_files - 1)) ]; then
			echo -n '\' >> Makefile	#Append a backslash if not the last one
		fi
		echo '' >> Makefile	#Append a new line
	done

	echo '' >> Makefile	#Append a new line
}

classic()
{
	name=$(basename $(pwd))	#Get the current directory name
	mkdir -p srcs includes	#Create srcs and include directory if they don't exist
	touch Makefile		#Create Makefile

	#Write the program name to Makefile
	echo "NAME	=	$name" >> Makefile
	echo '' >> Makefile

	echo -n 'Enter compilator: '	#Get compilator
	read compilator

	get_src srcs $compilator

	echo "CC	=	$compilator" >> Makefile	#Create cc variable
	echo '' >> Makefile	#Append a new line


	echo 'CFLAGS	=	-Wall -Wextra -Werror -MMD -g3' >> Makefile	#Create cflags variable
	echo '' >> Makefile	#Append a new line


	echo 'INCLUDES	=	includes/' >> Makefile	#Create include variable
	echo '' >> Makefile	#Append a new line

	echo "SRC_DIR	=	srcs/" >> Makefile #Create source dir variable
	echo '' >> Makefile	#Append a new line

	rule
}

is_dir()
{
	input=$1
	len=${#input}
	for (( i=0; i < len; i++ )); do
		str=${input:$i:1}
		if [ $((i+1)) -eq $len ] && [ $str = '/' ]
		then
			return 1
		fi
	done
	return 0
}

personalized()
{
	touch Makefile		#Create Makefile
	
	echo -n "Enter program name: "	#Get the current directory name
	read name

	#Write the program name to Makefile
	echo "NAME	=	$name" >> Makefile
	echo '' >> Makefile

	local ret_val=0
	while [ $ret_val -eq 0 ]
	do
		echo -n 'Enter sources dir with "/": '	#Get sources dir
		read src_dir
		is_dir $src_dir
		ret_val=$(echo $?)
	done

	ret_val=0
	while [ $ret_val -eq 0 ]
	do
		echo -n 'Enter includes dir with "/": '	#Get souces dir
		read includes
		is_dir $includes
		ret_val=$(echo $?)
	done

	mkdir -p $src_dir $includes	#Create srcs and include directory if they don't exist

	echo -n 'Enter compilator: '	#Get compilator
	read compilator

	get_src $src_dir $compilator

	echo "CC	=	$compilator" >> Makefile	#Create cc variable
	echo '' >> Makefile	#Append a new line

	echo -n 'Enter flags: '
	read flags

	echo "CFLAGS	=	$flags" >> Makefile	#Create cflags variable
	echo '' >> Makefile	#Append a new line

	echo "INCLUDES	=	$includes" >> Makefile	#Create include variable
	echo '' >> Makefile	#Append a new line

	echo "SRC_DIR	=	$src_dir" >> Makefile #Create source dir variable
	echo '' >> Makefile	#Append a new line

	rule
}

rule()
{
	echo 'BUILD	=	.build/' >> Makefile #Create build dir variable
	echo '' >> Makefile	#Append a new line

	if [ "$compilator" = 'c++' ]
	then
		echo 'OBJ	=	$(addprefix $(BUILD), $(SRC:.cpp=.o))' >> Makefile #Create obj variable
	elif [ "$compilator" = 'cc' ]
	then	
		echo 'OBJ	=	$(addprefix $(BUILD), $(SRC:.c=.o))' >> Makefile #Create obj variable
	fi
	echo '' >> Makefile	#Append a new line
	
	echo 'DEPS	=	$(OBJ:.o=.d)' >> Makefile #Create depa variable
	echo '' >> Makefile	#Append a new line
	echo 'all:	$(NAME)' >> Makefile	#Create all rule
	echo '' >> Makefile	#Append a new line

	echo '$(BUILD):' >> Makefile
	echo '	@mkdir -p $@' >> Makefile
	echo '' >> Makefile

	echo '$(NAME):	$(BUILD) $(OBJ)' >> Makefile	#Create $(NAME) rule
	echo '	$(CC) $(OBJ) -o $@' >> Makefile
	echo '' >> Makefile	#Append a new line

	if [ "$compilator" = 'c++' ]
	then
		echo '$(BUILD)%.o:	$(SRC_DIR)%.cpp Makefile' >> Makefile	#Create obj rule
	elif [ "$compilator" = 'cc' ]
	then
		echo '$(BUILD)%.o:	$(SRC_DIR)%.c Makefile' >> Makefile	#Create obj rule
	fi
	echo '	$(CC) $(CFLAGS) -c $< -o $@ -I $(INCLUDES)' >> Makefile
	echo '' >> Makefile	#Append a new line

	echo 'clean:' >> Makefile	#Create clean rule
	echo '	rm -rf $(BUILD)' >> Makefile
	echo '' >> Makefile	#Append a new line

	echo 'fclean:	clean' >> Makefile	#Create fclean rule
	echo '	rm -rf $(NAME)' >> Makefile
	echo '' >> Makefile	#Append a new line

	echo 're: fclean all' >> Makefile	#Create re rule
	echo '' >> Makefile	#Append a new line

	echo '.PHONY: re all fclean clean' >> Makefile	#Create .PHONY rule
	echo '' >> Makefile	#Append a new line

	echo '-include $(OBJ:.o=.d)' >> Makefile
	echo '' >> Makefile

	return
}


f()
{
	if [ -s Makefile ]; then	#If we already have a Makefile
		answer="ok"
		while [ $answer != 'y' ]  && [ $answer != 'N' ]	#While not correctly answered
		do
			echo -n "Do you want to remake your Makefile ?(y/N): "
			read answer
		done
		if [ $answer = 'N' ]	#If said no return 
		then
			return 
		fi
		rm -rf Makefile
	fi

	option="no"
	while [ "$option" != '1' ] && [ "$option" != '2' ] 
	do
		echo -n "Make your choice (1:classic, 2:personalized.): "	#Choose what kind of makefile
		read option
	done

	if [ $option = 1 ]; then 
		classic
	elif [ $option = 2 ]; then
		personalized
	fi

	return
}

f
