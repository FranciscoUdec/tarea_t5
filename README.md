# tarea_t5


Limpieza de datos, creación y
etiquetado de variables, manejo de valores faltantes y cálculo de estadísticos
descriptivos en Stata sobre una muestra de la encuesta CASEN.

Qué se automatizó:Se reemplazaron los comandos repetidos por macros de
configuración (`local` y `global`), bucles (`foreach` y `forvalues`), un
programa reutilizable con argumentos (`descriptivos_grupo`), almacenamiento
y comparación de modelos (`estimates store` / `estimates table`) y una
matriz (`J()`) que guarda regresiones por sector para exportarlas
automáticamente a Excel mediante `putexcel`

Qué editar para reutilizar con otros datos: Basta con modificar el bloque
de parámetros al inicio de `scripts/tarea_t5.do` (la ruta `datos`, la
variable dependiente `depvar`, las listas `numericas`, `controles`, `grupos`,
`grupo_reg` y el `global umbral`), sin tocar el resto del código.

## Datos
`data/raw/casen_reducido.csv`: Muestra reducida de la encuesta CASEN (60
observaciones y 6 variables 

## Cómo correrlo

Abrir y ejecutar el script:
`scripts/tarea_a5.do`

## Estructura

```
├── data/
│   └── raw/
│       └── casen_reducido.csv
├── output/
│   └── tarea_t5.log
├── scripts/
│   ├── tarea_t5.do
└── README.md
```

## Autor

Francisco Inostroza — 19-11-2026