<#
Separa un equipo de dominio

Remplaza el valor de las variable que contengan [] por las de tu ambiente.

Nombre del archivo: separar_dominio.ps1
Fecha: 24/02/2023
Autor: Sergio Torres
#>

#Agregar credenciales de dominio
$username = "[dominio.com\usuario]" # Remplazar
$password = "[contraseñadedominio]" # Remplazar
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

#Agregar credenciales locales
$lusername = "[usuarioadministradorlocal]" # Remplazar
$lpassword = "[contraseñadministradorlocal]" # Remplazar
$lsecpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$lcreds = New-Object System.Management.Automation.PSCredential ($lusername, $lsecpasswd)

#Agregar información de dominios
$newdomain = "[nuevodominio.com]" # Remplazar
$underdomain = "[dominioviejo.com]" # Remplazar
$valndom = Test-NetConnection $newdomain -Hops 1
$valdom = Test-NetConnection $underdomain -Hops 1

if($valdom.PingSucceeded -eq $true){
    if($valndom.PingSucceeded -eq $true){
        
        try{
			$result = Remove-Computer -UnjoinDomainCredential $creds -PassThru -WorkgroupName "WORKGROUP" -LocalCredential $lcreds
        } catch {
            Write-Host "[x] Error al ejecutar Add-Computer."
            Write-Error $_
            exit 1
        }

        if($result.HasSucceeded){
            Write-Host "[i] Se separó correctamente del dominio"
            Write-Host "[i] Se requiere reinicio para completar"
            exit 0
        } else {
            Write-Host "[x] Ocurrió un error al separar el equipo de dominio"
            Write-Error $_
            exit 1
        }
    }else{
        Write-Host "[x] El dominio $newdomain no es alcanzable. No se realizó ningún cambio en el equipo."
        exit 1
    }
}else{
    Write-Host "[x] El dominio $underdomain no es alcanzable. No se realizó ningún cambio en el equipo."
    exit 1
}
