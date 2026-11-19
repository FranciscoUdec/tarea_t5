* ============================================================
* Tarea T5 — Do-file automatizado (CASEN)
* Autor: Francisco Inostroza
* Fecha: 19-11-2026
* ============================================================
version 18
clear all
set more off
capture mkdir "output"
capture log close
log using "output/tarea_t5.log", replace text

* --- 1. Parámetros  -----------------------------------
local  datos     "data/raw/casen_reducido.csv"
local  depvar    "ingreso"
local  numericas "ingreso educ edad experiencia"
local  controles "educ experiencia"
local  grupos    "sector region genero"
local  grupo_reg "sector"
global umbral    = 500000
global fuente    "CASEN, muestra del curso (60 personas)"

* Cumple con la prueba de fuego, ya que el codigo sigue funcionando y cambian los resultados.

* Justificación local vs global:
* Uso `local` para las listas de variables y rutas internas (`datos`, `controles`,
* `grupos`) porque solo deben funcionar mientras corre este do-file y así evito que
* interfieran o sean pisadas por otros scripts. Uso `global` para `umbral` y `fuente`
* porque son parámetros generales de referencia (como el corte de ingreso y la nota
* al pie de exportación) que podrían compartirse en toda la sesión o en otros do-files.

* --- 2. Carga y preparación de datos ----------------------------------------
import delimited "`datos'", clear varnames(1) encoding("utf-8")

* Experiencia potencial de Mincer 
generate experiencia = max(edad - educ - 6, 0) if !missing(edad, educ)
label variable experiencia "Experiencia potencial (años)"

* Variable indicadora 
generate mujer = (genero == "F") if genero != ""
label variable mujer "Mujer (1 = sí)"
label define mujer_lbl 0 "Hombre" 1 "Mujer"
label values mujer mujer_lbl

* --- 3. Loop foreach sobre lista de variables numéricas ---------------------
foreach v of local numericas {
    display _newline "===== Resumen detallado: `v' ====="
    summarize `v', detail
}

* --- 4. Loop forvalues con rango económico (tramos de escolaridad) ----------
forvalues t = 4(4)16 {
    quietly count if educ >= `t' & educ < `t' + 4
    display "Educación de `t' a " `t' + 3 " años: " r(N) " personas"
}

* --- 5. Programa reutilizable con argumentos llamado desde un loop ----------
capture program drop descriptivos_grupo
program define descriptivos_grupo
    args grupo y
    display _newline "=== Descriptivos de `y' por `grupo' ==="
    tabulate `grupo'
    tabstat `y' educ, by(`grupo') statistics(mean sd n)
end

foreach g of local grupos {
    descriptivos_grupo `g' `depvar'
}

* --- 6. Uso de tempvar para variable auxiliar -------------------------------
tempvar ing_miles
generate `ing_miles' = `depvar' / 1000
summarize `ing_miles'

* Explicación sobre tempvar:
* `tempvar` crea una variable con un nombre interno único que Stata borra
* automáticamente al terminar el bloque o el do-file. Es más seguro que crear una
* variable normal y usar `drop` porque garantiza que nunca pisarás por accidente
* una variable existente en la base ni dejarás residuos si el script se detiene antes.

* --- 7. Manejo explícito de missing al filtrar ------------------------------
count if `depvar' > $umbral & !missing(`depvar')

* Explicación sobre missing:
* Sin `& !missing(`depvar')`, Stata evalúa el missing (.) como un número mayor que
* cualquier cifra real (infinito positivo). Por lo tanto, contaría erróneamente a las
* 5 personas sin dato de ingreso como si ganaran más de $500.000 (dando 46 en vez de 41).

* --- 8. Modelos guardados y comparados --------------------------------------
quietly regress `depvar' `controles'
estimates store m1

quietly regress `depvar' `controles' i.mujer
estimates store m2

estimates table m1 m2, b(%9.0f) se stats(N r2) stfmt(%5.3f)

* Muestro el coeficiente de educación del último modelo (m2) usando _b[]
display "Coeficiente de educación en m2: $" %9.0fc _b[educ] " (ee = " %7.0fc _se[educ] ")"

* --- 9. Regresión por sector en loop, matriz J() y exportación a Excel ------
levelsof `grupo_reg', local(niveles)
local k : word count `niveles'
matrix R = J(`k', 3, .)

local i = 1
foreach s of local niveles {
    quietly regress `depvar' educ if `grupo_reg' == "`s'"
    matrix R[`i', 1] = _b[educ]
    matrix R[`i', 2] = _se[educ]
    matrix R[`i', 3] = e(N)
    local i = `i' + 1
}

matrix colnames R = beta_educ ee n
matrix rownames R = `niveles'
matrix list R, format(%9.0f)

* Exportar resultados a Excel con putexcel
putexcel set "output/tarea_t5_por_sector.xlsx", replace
putexcel A1 = ("Sector") B1 = ("Beta educ") C1 = ("Error est.") D1 = ("n")
putexcel B2 = matrix(R)

local fila = 2
foreach s of local niveles {
    putexcel A`fila' = ("`s'")
    local fila = `fila' + 1
}
local ult = `k' + 3
putexcel A`ult' = ("Fuente: $fuente")

* --- 10. Cierre de bitácora e interpretación --------------------------------
log close

* Interpretación:
* En m1, cada año adicional de educación se asocia con $42.080 más de ingreso mensual
* en promedio (R2 = 0,458; n = 55), a igual experiencia. En m2, al agregar sexo, el
* coeficiente casi no cambia ($42.246 por año; R2 = 0,475), y ser mujer se asocia con
* $55.686 menos de ingreso a igual educación y experiencia. Por sector, los coeficientes
* van de $23.783 (Construcción) a $42.713 (Industria), pero son imprecisos: hay solo
* entre 5 y 15 personas por sector. Limitación: con 60 personas y sin variables como
* horas trabajadas, estas asociaciones no pueden leerse como causales.