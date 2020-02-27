    /*
    *               TEORÍA DE LENGUAJES - ACTIVIDAD 3
    *	        Actividad 3 de Evaluación Continua (2/3/20)
    *
    *	     AUTOR : Juan Pablo García Plaza Pérez - jgarciapft
    *                    Documentación : README.md
    * (Disponible en el repositorio https://github.com/jgarciapft/Lexico)
    */

%option noyywrap

%{
    #include <iostream>
    #include <cstring>
    #include "debug.h"

    #define MAX_TAM_BUFFER 4096
    #define MAX_TAM_CADENA 4096

    using namespace std;

    // Defininciones estáticas de métodos auxiliares para utilizarlos en las acciones
    static string cad_toUpper(char* in_text);
    static void buff_concatenarToken(char* token);
    static void buff_vaciar();
    static void procesarToken(string valorToken);
    static void procesarNuevaLinea();
    static void printDebugInfo(u_int8_t debug_bitmask);
    
    // *** VARIABLES GLOBALES ***
    int nLinea;                 // Número de línea procesado hasta ahora
    bool ignorarNuevasLineas;   // Bandera para ignorar nuevas lineas mientras se procesa un comentario multilínea
    char* bufferCadena;         // Buffer intermedio para el procesamiento de cadenas de texto
%}

    // Construcciones básicas
letra				    [a-zA-Z]
caracter_alfanumerico	[a-zA-Z0-9]
digito				    [0-9]
separador_decimal       [.,]
secescape_cad           [$]["]
comentario_linea        "//"
comentario_mlinea_in    "/*"
comentario_mlinea_fin   "*/"

    // Expresiones complejas
palabras_reservadas	    main|int|float|for|cout|endl|return
entero                  {digito}+
identificador		    [a-zA-Z_][a-zA-Z0-9_]*
real                    {digito}+{separador_decimal}{digito}*|{digito}*{separador_decimal}{digito}+
real_notCientifica      {real}([eE][+-]{digito}+)

    // Reglas exclusivas
%x SECESCAPE COM1 COM2

%%

 /*
  * Detección de palabras reservadas. VER: Documentacion.Palabras reservadas
  */
{palabras_reservadas}           {
                                    procesarToken(cad_toUpper(yytext));
                                } 

 /*
  * Detección de identificadores. VER: Documentacion.Identificadores
  */
{identificador}                 {
                                    procesarToken("ID");
                                }

 /*
  * Detección de enteros. VER: Documentacion.Números Enteros
  */
{entero}                        {
                                    procesarToken("ENTERO");
                                }

 /*
  * Detección de números reales. VER: Documentacion.Números Reales
  */
{real}|{real_notCientifica}     {
                                    procesarToken("REAL");
                                } 

 /*
  * Detección de cadenas de texto. VER: Documentacion.Cadenas de texto
  */
["]                             BEGIN(SECESCAPE);
    <SECESCAPE>["]              { BEGIN(0); procesarToken("TEXTO"); buff_vaciar(); }
    <SECESCAPE>{secescape_cad}  {
                                    char* temp = new char[2]; strcpy(temp, "\"");
                                    buff_concatenarToken(temp);
                                }
    <SECESCAPE>.                buff_concatenarToken(yytext);

 /*
  * Detección de cada línea del fichero de entrada
  */
\n                              {
                                    // Tratar el fin de línea si no se está procesando un comentario multilínea
                                    if(!ignorarNuevasLineas)
                                        procesarNuevaLinea();
                                    else
                                        ignorarNuevasLineas = false; // El comentario multilínea ha terminado
                                } 

 /*
  * Detección de comentarios C de una sola línea y multilínea. VER: Documentación.Comentarios de una sola línea y Documentación.Comentario multilínea
  */  
{comentario_linea}                  BEGIN(COM1);
    <COM1>\n                        { BEGIN(0); procesarNuevaLinea(); }
{comentario_mlinea_in}              { BEGIN(COM2); ignorarNuevasLineas = true; }
    <COM2>{comentario_mlinea_fin}   BEGIN(0);
    <COM2>\n                        ;
    <COM1,COM2>.                    ;

 /*
  * LIMPIEZA DEL FICHERO DE ENTRADA
  */
[ ]+                            procesarToken(" "); // Compactar múltiples espacios en uno solo
[\t ]+$                         ;                   // Eliminar tabuladores y espacios del final de la línea
^[\t\n ]+                       ;                   // Eliminar tabuladores y espacios del inicio y líneas vacías

%%

/*
 * Escribe en stderr información de depuración
 *
 * Los valores que se muestran pueden configurarse mediante una máscara de bits. Valores predefinidos:
 *      D_ALL       ->  Atajo para mostrar todos los valores de depuración
 *      D_NONE      ->  No muestra ningún valor
 *      D_TOK       ->  Muestra el valor de la cadena procesada (token -> yytext)
 *      D_NL        ->  Muestra el número de línea actual 
 *      D_BUFFCAD   ->  Muestra una representación del buffer de procesamiento de cadenas
 */ 
void printDebugInfo(u_int8_t debug_bitmask) {
    // Comprobar si no se desea mostrar ningún valor de depuración
    if (debug_bitmask & D_NONE) return;

    char *temp = new char[MAX_TAM_CADENA];
	char *cadDebug = new char[MAX_TAM_CADENA];

    // Inicializar la cadena temporal y la cadena con la información de depuración
	strcpy(temp, "");
	strcpy(cadDebug, "");

    // Construcción de la cadena con la información de depuración
	if (debug_bitmask & D_NL) {
		sprintf(temp, "\u001b[32mlinea:\u001b[0m %d; ", nLinea);
		strcat(cadDebug, temp);
	}
	if (debug_bitmask & D_TOK) {
		sprintf(temp, "\u001b[32mtoken:\u001b[0m %s; ", yytext);
		strcat(cadDebug, temp);
	}
	if (debug_bitmask & D_BUFFCAD) {
		sprintf(temp, "\u001b[32mbuffer_cad:\u001b[0m %s; ", bufferCadena);
		strcat(cadDebug, temp);
	}

    fprintf(stderr, "{ %s}\n", cadDebug);
}

// Convierte una cadena de texto (char*) a mayúsculas
string cad_toUpper(char* in_text) {
	int idx = 0;
	char* procd_text = new char [strlen(in_text) + 1]; // Cadena procesada

    // Formar la nueva cadena con la reprensentación en mayúsculas de cada caracter
	for (;idx < strlen(in_text); idx++) {
		procd_text[idx] = (char) toupper(in_text[idx]);
	}
	procd_text[idx] = '\0'; // Añadir caracter de terminación de cadena

	return string(procd_text); // Devolver la cadena procesada como un tipo <string>
}

// Añade al buffer intermedio de procesamiento de cadenas el token
void buff_concatenarToken(char* token) {
    if ((strlen(bufferCadena) + strlen(token)) < MAX_TAM_BUFFER) {
        strcat(bufferCadena, token);
    } else {
        fprintf(stderr, "%s", "[ERROR] El buffer de procesamiento de cadenas está lleno");
        exit(EXIT_FAILURE);
    }

    #if DEBUG
    printDebugInfo(D_ALL);
    #endif
}

void buff_vaciar() {
    strcpy(bufferCadena, "");
}

// Escribe en stdout el valor correspondiente al token representado por 'yytext'
void procesarToken(string valorToken) {
    fprintf(yyout, "%s", valorToken.c_str());

    #if DEBUG
    printDebugInfo(D_ALL);
    #endif
}

// Formatea y adjunta el número de línea a cada nueva línea procesada
void procesarNuevaLinea() {
    fprintf(yyout, "\n%d\t", nLinea++);

    #if DEBUG
    printDebugInfo(D_ALL);
    #endif
}

/*
 * Uso del programa : ./lexico ficheroEntrada ficheroSalida  
 *      ficheroEntrada  -> ruta (relativa o absoluta) al archivo que alamcena el programa a interpretar
 *      ficheroSalida   -> ruta (relativa o absoluta) al archivo que guardará la entrada procesada por este analizador
 *
 * Instrucciones de compilación : make
 * Para ejecutar con argumentos por defecto : make run
 * Para limpiar los archivos temporales : make clean
 * Para eliminar el directorio de archivos temporales : make deep_clean
 */
int main(int argc, char* argv[]) {
    // Inicializar variables globales
    nLinea = 1;
    ignorarNuevasLineas = false;
    bufferCadena = new char[MAX_TAM_BUFFER];buff_vaciar();

    // Comprobar que el número de parametros de entrada sea correcto
    if (argc == 3) {
		yyin = fopen(argv[1], "r");
		yyout = fopen(argv[2], "w");

        // Comprobar que los flujos estén abiertos correctamente
        if (yyin != nullptr && yyout != nullptr) {
			fprintf(yyout, "%d\t", nLinea++);
			yylex(); // Llamada al analizador léxico

            // Cerrar los flujos
			fflush(yyout);
			fclose(yyin);
			fclose(yyout);
		} else {
            perror("Algo fue mal...");
        }
	} else {
		cout << "[ERROR] Número incorrecto de argumentos proporcionado " << endl
			<< "\tUso : ./lexico ficheroEntrada ficheroSalida" << endl;
        return EXIT_FAILURE;
	}

  	return EXIT_SUCCESS;  
}