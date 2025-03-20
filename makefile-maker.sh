#!/bin/bash

classic()
{
	name=$(basename $(pwd))	#Get the current directory name
	mkdir -p srcs includes	#Create srcs and include directory if they don't exist
	touch Makefile		#Create Makefile

	#Write the program name to Makefile
	echo "NAME	=	$name" >> Makefile
	echo '' >> Makefile


	#Start adding the sources to the Makefile

	echo -n 'SRC	=' >> Makefile	#Create source variable
	SRC=$(cd srcs; find . -type f)	#Taking all sources files


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

	echo 'SRC_DIR	=	srcs/' >> Makefile #Create source dir variable
	echo '' >> Makefile	#Append a new line

	echo 'BUILD	=	.build/' >> Makefile #Create build dir variable
	echo '' >> Makefile	#Append a new line

	echo 'OBJ	=	$(addprefix $(BUILD, $(SRC:.c=.o)))' >> Makefile #Create obj variable
	echo '' >> Makefile	#Append a new line

	
	echo 'DEPS	=	$(OBJ:.o=.d)' >> Makefile #Create depa variable
	echo '' >> Makefile	#Append a new line


	echo 'CC	=	cc' >> Makefile	#Create cc variable
	echo '' >> Makefile	#Append a new line


	echo 'CFLAGS	=	-Wall -Wextra -Werror -MMD -g3' >> Makefile	#Create cflags variable
	echo '' >> Makefile	#Append a new line


	echo 'INCLUDE	=	includes' >> Makefile	#Create include variable
	echo '' >> Makefile	#Append a new line


	echo 'all:	$(NAME)' >> Makefile	#Create all rule
	echo '' >> Makefile	#Append a new line

	echo '$(BUILD):' >> Makefile
	echo '	@mkdir -p $@' >> Makefile
	echo '' >> Makefile

	echo '$(NAME):	$(BUILD) $(OBJ)' >> Makefile	#Create $(NAME) rule
	echo '	$(CC) $(OBJ) -o $@' >> Makefile
	echo '' >> Makefile	#Append a new line

	echo '$(BUILD)%.o:	$(SRC_DIR)%.c Makefile' >> Makefile	#Create obj rule
	echo '	$(CC) $(CFLAGS) -c $< -o $@ -I $(INCLUDES)' >> Makefile
	echo '' >> Makefile	#Append a new line

	
	echo 'clean:' >> Makefile	#Create clean rule
	echo '	rm -rf $(BUILD)' >> Makefile
	echo '' >> Makefile	#Append a new line

	echo 'fclean:	clean' >> Makefile	#Create fclean rule
	echo 'rm -rf $(NAME)' >> Makefile
	echo '' >> Makefile	#Append a new line

	echo 're: fclean all' >> Makefile	#Create re rule
	echo '' >> Makefile	#Append a new line

	echo '.PHONY: re all fclean clean' >> Makefile	#Create .PHONY rule
	echo '' >> Makefile	#Append a new line

	echo '-include $(OBJ:.o=.d)' >> Makefile
	echo '' >> Makefile

	return
}

personalized()
{
	touch Makefile		#Create Makefile
	
	echo -n "Enter program name: "	#Get the current directory name
	read name

	#Write the program name to Makefile
	echo "NAME	=	$name" >> Makefile
	echo '' >> Makefile

	echo -n 'Enter sources dir with "/": '	#Get souces dir
	read src_dir
	echo -n 'Enter includes dir with "/": '	#Get includes dir
	read includes

	mkdir -p $src_dir $includes	#Create srcs and include directory if they don't exist

	#Start adding the sources to the Makefile

	echo -n 'SRC	=' >> Makefile	#Create source variable
	SRC=$(cd $src_dir; find . -type f)	#Taking all sources files


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

	echo 'SRC_DIR	=	srcs/' >> Makefile #Create source dir variable
	echo '' >> Makefile	#Append a new line

	echo 'BUILD	=	.build/' >> Makefile #Create build dir variable
	echo '' >> Makefile	#Append a new line

	echo 'OBJ	=	$(addprefix $(BUILD, $(SRC:.c=.o)))' >> Makefile #Create obj variable
	echo '' >> Makefile	#Append a new line

	
	echo 'DEPS	=	$(OBJ:.o=.d)' >> Makefile #Create depa variable
	echo '' >> Makefile	#Append a new line

	echo -n 'Enter compilator: '	#Get compilator
	read compilator

	echo "CC	=	$compilator" >> Makefile	#Create cc variable
	echo '' >> Makefile	#Append a new line


	echo -n 'Enter flags: '
	read flags

	echo "CFLAGS	=	$flags" >> Makefile	#Create cflags variable
	echo '' >> Makefile	#Append a new line


	echo "INCLUDE	=	$include" >> Makefile	#Create include variable
	echo '' >> Makefile	#Append a new line


	echo 'all:	$(NAME)' >> Makefile	#Create all rule
	echo '' >> Makefile	#Append a new line

	echo '$(BUILD):' >> Makefile
	echo '	@mkdir -p $@' >> Makefile
	echo '' >> Makefile

	echo '$(NAME):	$(BUILD) $(OBJ)' >> Makefile	#Create $(NAME) rule
	echo '	$(CC) $(OBJ) -o $@' >> Makefile
	echo '' >> Makefile	#Append a new line

	echo '$(BUILD)%.o:	$(SRC_DIR)%.c Makefile' >> Makefile	#Create obj rule
	echo '	$(CC) $(CFLAGS) -c $< -o $@ -I $(INCLUDES)' >> Makefile
	echo '' >> Makefile	#Append a new line

	
	echo 'clean:' >> Makefile	#Create clean rule
	echo '	rm -rf $(BUILD)' >> Makefile
	echo '' >> Makefile	#Append a new line

	echo 'fclean:	clean' >> Makefile	#Create fclean rule
	echo 'rm -rf $(NAME)' >> Makefile
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
	if [ -s Makefile ]; then 
		return 
	fi

	echo -n "make your choice (1:classic, 2:personalized.): "
	read option
	if [ $option -eq 1 ]; then 
		classic
	elif [ $option -eq 2 ]; then
		personalized
	fi
	return 
	echo -n "Enter executable name: "
	read NAME
	echo $NAME

}

f
