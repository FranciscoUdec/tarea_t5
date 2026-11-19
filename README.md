# Tarea_t5

Limpieza de datos, creación y
etiquetado de variables, manejo de valores faltantes y cálculo de estadísticos
descriptivos en Stata sobre una muestra de la encuesta CASEN.

## Qué se automatizó

En lugar de repetir código a mano, el script usa parámetros al inicio (`local` y `global`), 
ciclos (`foreach` y `forvalues`) y un programa propio (`descriptivos_grupo`) para calcular 
los resúmenes por grupo. Además, guarda y compara los modelos de regresión en una tabla y
exporta automáticamente los resultados por sector a Excel desde una matriz.

## Qué editar para reutilizar con otros datos

Solo hay que cambiar las líneas de parámetros al principio de `scripts/tarea_t5.do` 
(la ruta del archivo en `datos`, la variable principal en `depvar`, las listas de variables 
y el valor de `umbral`), sin necesidad de modificar el resto del código.

## Datos
`data/raw/casen_reducido.csv`: Muestra reducida de la encuesta CASEN (60
observaciones y 6 variables 

## Cómo correrlo

Abrir Stata y seleccionar el  directorio de trabajo `tarea_a5/`, Luego ejecutar el 
script: `scripts/tarea_a5.do`

## Estructura

```
├── data/
│   └── raw/
│       └── casen_reducido.csv
├── output/
│   └── tarea_t5.log
│   └── tarea_t5_por_sector.xlsx
├── scripts/
│   ├── tarea_t5.do
└── README.md
```

## Autor

Francisco Inostroza — 19-11-2026

```markdown
## Declaración de autoría y uso de IA
- Herramienta utilizada: Gemini
- Para qué la usé: Corregir la redaccion de mis respuestas, y que verificara en la pauta 
si es que cumplia con todos los requerimientos.
- Qué hice yo: Verifique si no modifico el codigo ni las ideas de las respuestas.
- Verificación: confirmo que entiendo y puedo explicar todo lo que entrego.
```