Param (
    [string]$function,
    [string]$inpt,
    [string]$inpt2
)
$hosts = "C:\WINDOWS\System32\drivers\etc\hosts"
$hosts_content = "C:\Windows\Temp\hosts.tmp"
$hosts_bkp = "C:\WINDOWS\System32\drivers\etc\hosts.bkpscmodificarhosts"

function restorebkp {
    if((Test-Path $hosts_bkp) -eq $true){
        try {
            Get-Content -Path $hosts_bkp -Encoding UTF8 | Out-File $hosts -Encoding utf8
            Write-Host "[!] Archivo restaurado correctamente de una copia de seguridad local"
        } catch {
            Write-Host "[X] Ocurrio un error al restaurar el archivo hosts"
            Write-Host $_
        }
    }else{
        Write-Host "[X] No se encontro ninguna copia de seguridad local"
    }
}

function searchline {
    Param (
        [string]$cadena
    )
    $cointer = 0

    foreach($a in Get-Content($hosts_content)){
        $ln = $a | Select-String -Pattern $cadena -Quiet
        if($ln -eq $true){
            return $counter
        }else{
            $counter++
        }
    }
}

function deleteline {
    Param (
        [int]$nolinea
    )
    $counter = 0

    foreach($a in Get-Content($hosts_content)){
        if($counter -eq $nolinea){
            $counter++
        }else{
            if($counter -eq 0){
                $a | Out-File -Encoding utf8 $hosts_content
                $counter++
            }else{
                $a | Out-File -Encoding utf8 -Append $hosts_content
                $counter++
            }
        }
    }
}

function addlines {
    $counter = 0
    $list = $inpt -split ","
    
    foreach($line in $list){
        if((searchline -cadena $list.Item($counter)) -ge 1){
            Write-Host "[!] Omitiendo insersión, ya se encontraba la cadena $line en el archivo"
            $counter++
        }else{
            Write-Host "[!] Insertando: $line"
            echo $line | Out-File -Append $hosts -Encoding utf8
            $counter++
        }

    }

}

function fin {
    exit
}

Get-Content -Path $hosts | Out-File -Encoding utf8 $hosts_content -Force

if((Test-Path $hosts_bkp) -eq $false){
    Get-Content -Path $hosts | Out-File -Encoding utf8 $hosts_bkp -Force
}


switch($function){
    "search" {
        $arr = $inpt -split "," -replace " ",""

        foreach($i in $arr){
            $n = Get-Content $hosts | Select-String -Pattern $i -Quiet
            if($n -eq $true){
                deleteline -nolinea (searchline -cadena $i)
                Get-Content $hosts_content | Out-File -Encoding utf8 $hosts -Force
            }
        }
    }

    "replace" {
        $arr = $inpt -split "," -replace " ",""
        $arr2 = $inpt2 -split "," -replace " ",""
        
        foreach($i in $arr){
            $n = Get-Content $hosts | Select-String -Pattern $i -Quiet
            if($n -eq $true){
                deleteline -nolinea (searchline -cadena $i)
                Get-Content $hosts_content | Out-File -Encoding utf8 $hosts -Force
            }
        }

        $inpt = $inpt2

        sleep -Seconds 1

        addlines

    }

   "number" {
       $gnumsl = $inpt -split "," -replace " ",""

       $linea_borrar = $gnumsl.Item(0)-1
       [int]$veces = $gnumsl.Item(1)

       if($veces -lt 10){
           for ($i=0; $i -le $veces; $i++){
               deleteline -nolinea $linea_borrar
               Get-Content $hosts_content | Out-File -Encoding utf8 $hosts -Force
           }
       }else{
           Write-Host "[x] Solo puedes eliminar hasta 10 lineas"
           fin
       }
   }

   "add" {
       addlines
   }

   "restore" {
       restorebkp
   }

   "show" {
       Write-Host "[!] Mostrando contenido de hosts"
   }
} 


Get-Content $hosts
Remove-Item -Path $hosts_content

<#
Script para editar contenido el archivo hosts via scripting. El script se puede usar para modificar o eliminar contenido especifico del archivo hosts.
Revisar la documentación.

-function: Selector de función, se puede elegir entre las siguientes opciones y no se pueden mezclar o usar más de una al mismo tiempo.
•	search: Busca una IP dentro del archivo host y elimina toda la línea.
o	Inpt – encuentra esta ip y elimina la línea
•	replace: Busca una IP dentro del archivo host, la elimina y agrega una nueva línea.
o	Inpt – Busca esta IP y remplaza toda la línea por inpt2
o	Inpt2 – IP [espacio] HOSTNAME
•	number: Busca un numero de línea en particular del archivo host y la elimina
o	inpt – Elimina este número de línea tantas veces. El numero de línea y las veces se separan por una coma
•	add: Agrega una nueva línea al final del archivo hosts
o	inpt – Agrega esta ip [espacio] hostname.
•	restore: Restaura una copia de seguridad del archivo hosts
•	show: Muestra el contenido del archivo hosts actualmente
-inpt: Entrada primaria del script, hace referencia a las entradas iniciales. 
-inpt2: Entrada parámetros secundarios o de remplazo.	

NOTAS
No es necesario establecer inpt e inpt2 si no son utilizados. Por ejemplo, en la función “restore” y “show” no requiere inpt’s.
Todos los parámetros son de tipo string, por lo que se deben establecer entre comillas dobles.
Se pueden agregar más de un registro a los parámetros inpt’s simplemente separándolos por comas, p.ej. [192.168.0.1 dominio1.com,192.168.0.2 dominio2.com]. Revisa los ejemplos de uso.

Eliminar registro [192.168.0.10 dominio.com] del archivo hosts
modificar_hosts_v2.ps1 -function “search” -inpt “192.168.0.10”

Remplazar direccion ip 192.168.0.10 por 192.168.0.11 del dominio dominio.com
modificar_hosts_v2.ps1 -function “replace” -inpt “192.168.0.10” -inpt2 “192.168.0.11 dominio.com”

Eliminar la línea 16, 3 veces del archivo hosts sin importar que haya ahí. 
modificar_hosts_v2.ps1 -function “number” -inpt 16,3

Agrega al archivo hosts la linea [192.168.0.12 dominio.com]
modificar_hosts_v2.ps1 -function “add” -inpt “192.168.0.12 dominio.com”

Restaura la copia de seguridad del archivo hosts
modificar_hosts_v2.ps1 -function “restore”

Muestra el contenido actual del archivo hosts
modificar_hosts_v2.ps1 -function “show”

Elimina el registro [192.168.0.3] y agrega los siguientes dos registros [192.168.0.1 dominio1.com] y [192.168.0.2 dominio2.com]
modificar_hosts_v2.ps1 -function “replace” -inpt “192.168.0.3” -inpt2 “192.168.0.1 dominio1.com,192.168.0.2 dominio2.com”



Nombre: modificar_hosts_v2.ps1
Fecha: 06/09/2022
Autor: Sergio Torres
#>