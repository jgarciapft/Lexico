#define D_NONE 1 << 0                   // No muestra ningún valor
#define D_TOK 1 << 1                    // Muestra el valor de la cadena procesada (token -> yytext)
#define D_NL 1 << 2                     // Muestra el número de línea actual 
#define D_BUFFCAD 1 << 3                // Muestra una representación del buffer de procesamiento de cadenas
#define D_ALL D_TOK|D_NL|D_BUFFCAD      // Atajo para mostrar todos los valores de depuración

#define DEBUG 0                         // Bandera de depuración [ 0 -> RUN / 1 -> DEBUG ]