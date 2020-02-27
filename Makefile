	# TEORÍA DE LENGUAJES -  ACTIVIDAD 3
	# AUTOR	: Juan Pablo García Plaza Pérez - jgarciapft

# Parametros de compilación
ARTIFACTS_BASE_DIR = out/
BUILD_DIR = $(ARTIFACTS_BASE_DIR)build/
EXEC_DIR = $(ARTIFACTS_BASE_DIR)bin/

# Parametros de los fuentes
SOURCES_DIR = 
LEX_SOURCES = lexico.l
LEX_OUTPUT_FILE = lex.yy.c
GCC_SOURCES = debug.h
EXEC_FILENAME = lexico

.PHONY: all run clean deep_clean

all: $(EXEC_FILENAME)

# OBJETIVO PRINCIPAL
$(EXEC_FILENAME): $(LEX_OUTPUT_FILE)
	cp $(GCC_SOURCES) $(BUILD_DIR) && g++ -o $(EXEC_DIR)$(EXEC_FILENAME) $(BUILD_DIR)$(LEX_OUTPUT_FILE) $(BUILD_DIR)$(GCC_SOURCES)

$(LEX_OUTPUT_FILE): $(SOURCES_DIR)$(LEX_SOURCES) | artifacts_dir
	flex -o $(BUILD_DIR)$(LEX_OUTPUT_FILE) $(SOURCES_DIR)$(LEX_SOURCES)

# Crear la estructura de la carpeta de artefactos
artifacts_dir:
	mkdir -p $(ARTIFACTS_BASE_DIR) $(BUILD_DIR) $(EXEC_DIR)

# Configuración de ejecución predeterminada. El fichero de entrada es 'entrada.txt' y el fichero de salida 'salida.txt'
run:
	./$(EXEC_DIR)$(EXEC_FILENAME) entrada.txt salida.txt

# Eliminar solo ficheros
clean:
	rm -f $(BUILD_DIR)* $(EXEC_DIR)*

# Eliminar por completo la carpeta de artefactos
deep_clean: 
	rm -rf $(ARTIFACTS_BASE_DIR)