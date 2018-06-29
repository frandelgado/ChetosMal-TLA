#define KEY_MAX_LENGTH (256)

static const char* header = "\
#include <stdlib.h>\n\
#include <stdio.h>\n\
#include <string.h>\n\
#include \"hashmap.h\"\n\
#define KEY_MAX_LENGTH (256)\n\
typedef struct {\n\
    char key[KEY_MAX_LENGTH];\n\
    double numValue;\n\
    char *strValue;\n\
} var_t;\n\
map_t var_map;\n\
void __dank_define(char * varname) {\n\
    var_t* var = malloc(sizeof(var_t));\n\
    strcpy(var->key, varname);\n\
    hashmap_put(var_map, var->key, var);\n\
}\n\
var_t * __dank_getvar(char * varname) {\n\
    var_t * var;\n\
    hashmap_get(var_map, varname, (void**)&var);\n\
    return var;\n\
}\n\
char * __dank_dtoa(double val) {\n\
    char * str = malloc(128);\n\
    sprintf(str, \"%%g\", val);\n\
    return str;\n\
}\n\
char * __dank_concat(char * str1, char * str2) {\n\
    char * out = malloc(strlen(str1) + strlen(str2) + 1);\n\
    strcpy(out, str1);\n\
    strcat(out, str2);\n\
    return out;\n\
}\n\
int main(){\n\
    var_map = hashmap_new();\n";

static const char* footer = "\n\
    hashmap_free(var_map);\n\
	return 0;\n\
}";