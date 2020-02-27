# Teoría de Lenguajes **ACTIVIDAD 3**  
Autor *Juan Pablo García Plaza Pérez - jgarciapft*  
## Documentación  
1. Introducción  
2. Compilación y ejecución  
	1. Argumentos de lanzamiento
3. Depuración  
4. Expresiones regulares  
	1. Palabras reservadas
	1. Identificadores 
	1. Números enteros 
	1. Números reales 
	1. Cadenas de texto
	1. Comentarios de una línea
	1. Comentarios multilínea
5. Notas adicionales
### 1. Introducción
Este software es un analizador léxico de programas C escrito en Flex. Admite como entrada un programa fuente escrito en C y su salida es la interpretación de palabras reservadas del lenguaje, identificadores, números enteros y reales, cadenas de texto y comentarios. El comportamiento detallado es descrito en el apartado *Expresiones regulares*
### 2. Compilación y ejecución
Para compilar el software basta con ejecutar el target por defecto del fichero *Makefile* que se encuentra junto a los archivos fuentes. Después puede ser ejecutado como un programa regular pasando los argumentos necesarios, o ejecutando el target *run*, que da los valores `entrada.txt` y `salida.txt` a los argumentos.
```bash
make && make run
```
#### Argumentos de lanzamiento
* *ficheroEntrada* es una ruta (absoluta o relativa) al programa fuente C que debe interpretar el analizador léxico. El usuario que posea el shell desde el que se ejecute el analizador debe tener permisos de lectura sobre el programa fuente C.
* *ficheroSalida* es una ruta (absoluta o relativa) en la que almacenar la salida del analizador léxico (el programa fuente C interpretado). El usuario que posea el shell desde el que se ejecute el analizador debe tener permisos de escritura sobre la ruta especificada.
### 3. Depuración
El software ofrece la posibilidad de mostrar información sobre el estado interno del analizador léxico a través de la macro `DEBUG` definida en el archivo `debug.h`. Para activar la depuración basta con poner un valor distinto de `0` y viceversa.

Una vez activado el modo depuración, la información que muestra puede ser controlada con una máscara de bits en cada llamada a la sigiuente función (abajo). Es invocada cada vez que se procesa un token, se añade una nueva cadena al buffer intermedio de cadenas o se procesa una nueva línea
```c
void printDebugInfo(u_int8_t debug_bitmask)
```
Cada bit está predefinido como una macro
* `D_ALL` : Atajo para mostrar todos los valores de depuración. Cualquier otro valor que se especifique no tiene ningún efecto, a menos que sea `D_NONE`
* `D_NONE` : No muestra ningún valor. Si se especifica simultáneamente con cualquier otro valor de la máscara este será ignorado
* `D_TOK` : Muestra el valor de cada token procesado (`yytext`)
* `D_NL` : Muestra el número de línea actual 
* `D_BUFFCAD` : Muestra una representación del buffer de procesamiento de cadenas

**Ejemplo** Mostrar todos los valores de depuración
```
{ linea: 13; token:  ; buffer_cad: ; }
{ linea: 13; token:  ; buffer_cad: ; }
{ linea: 13; token: n; buffer_cad: n; }
{ linea: 13; token: u; buffer_cad: nu; }
{ linea: 13; token: m; buffer_cad: num; }
{ linea: 13; token:  ; buffer_cad: num ; }
{ linea: 13; token: $"; buffer_cad: num "; }
{ linea: 13; token: v; buffer_cad: num "v; }
{ linea: 13; token: a; buffer_cad: num "va; }
{ linea: 13; token: l; buffer_cad: num "val; }
{ linea: 13; token: e; buffer_cad: num "vale; }
{ linea: 13; token: $"; buffer_cad: num "vale"; }
{ linea: 13; token:  ; buffer_cad: num "vale" ; }
{ linea: 13; token: "; buffer_cad: num "vale" ; }
```
### 4. Expresiones regulares
#### Palabras reservadas
Las siguientes palabras reservadas son convertidas a mayúsculas
* `main`
* `int`
* `float`
* `for`
* `cout`
* `endl`
* `return`
#### Identificadores
Un identificador en C comienza por un letra o una *barra baja* (*underscore* `_`), y puede precederle cualquier longitud de letras, números y *barras bajas*.
#### Números enteros
Cualquier secuencia de números en base decimal en la que no aparezca el separador decimal
#### Números reales
Existen 3 formas de representar números reales. Se admite como separador decimal el punto (.) y la coma (,) indistintamente
* **Especificando la parte entera y decimal**
  * Por ejemplo: `2.5` o `2,5`

* **Especificando únicamente una de las dos partes**
  * Por ejemplo: `.1`, que se interpretaría como `1.0`; o `2.`, que se interpretará como `2.0`
* **Notación científica**. Adjuntando al final del número el carácter `e` o `E`, seguido de un signo un número entero. Admite especificar cualquiera de las dos partes (entera y real) o ambas
  * Por ejemplo: `4.7e+5`, `4.e-10` o `.9E+98`
#### Cadenas de texto
Cualquier secuencia de caracteres encerrada entre dos dobles comillas ("). Para incluir dobles comillas dentro de una cadena debe escaparse con la secuencia `$"`.

**Ejemplo** En la siguiente cadena la palabra *palabra* quedará encerrada entre dobles comillas
```
"esta $"palabra$" estará encerrada entre dobles comillas"
```
#### Comentarios de una línea
Un comentario de una sola línea comienza con la secuencia `\\` y abarca toda la línea en la que se encuentra. Su contenido es ignorado en el fichero de salida. 

*NOTA* Actualmente las líneas que solo contienen comentarios de una sola línea se traducirán en una línea vacía en el fichero de salida, pero esto no ocurre con un comentario de una línea adyacente a código C.
#### Comentarios multilínea
Un comentario multilínea comienza con la secuencia `/*`, termina con la secuencia `*/` y abarca todo el contenido que se encuentre entre el comienzo y el fin.
### 5. Notas adicionales
Adjunto con el repositorio de código se encuentra un fichero de ejemplo `entrada.txt` que incluye código C para cubrir todos los casos descritos en esta documentación.
