#ifndef UTIL1_H
#define UTIL1_H


char* variable_name[100];
int variable_set[100];
double variable_values[100];
int variable_counter = 0;


int add_variable(char* var_name){
    int x;
    /* search for index x,  if found, return it; else, add it*/
    for(x = 0; x < variable_counter; x++){
        if (strcmp(var_name, variable_name[x]) == 0) {
				return x;
		  }
    }
    variable_counter++;
    variable_name[x] = strdup(var_name);
    return x;
}
#endif