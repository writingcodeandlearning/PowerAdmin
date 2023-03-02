<#
Une un equipo a un dominio
Remplaza el valor de las variable que contengan [] por las de tu ambiente.
Nombre del archivo: unir_dominio.ps1
Fecha: 24/02/2023
Autor: Sergio Torres
#>

#Agregar usuario de dominio
$username = "[usuariodedominio]" # Remplazar
$password = "[passwordusuariodedominio]" # Remplazar

$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

#Agregar información de dominios
$newdomain = "[nuevodominio.com]" # Remplazar
$valndom = Test-NetConnection $newdomain -Hops 1


if($valndom.PingSucceeded -eq $true){
	try {
		$addresult = Add-Computer -DomainName $newdomain -Credential $creds -PassThru -Force -WarningAction SilentlyContinue -InformationAction SilentlyContinue
	} catch {
		Write-Host "[x] Error al ejecutar Add-Computer."
		Write-Error $_
		exit 1
	}

	if($addresult.HasSucceeded){
		Write-Host "[i] Se ha unido a dominio correctamente"
		Write-Host "[i] Se requiere reinicio para completar"
		exit 0
	} else {
		Write-Host "[x] La unión a dominio ha fallado"
		exit 1
	}
}else{
	Write-Host "[x] El dominio $newdomain no es alcanzable. No se realizó ningún cambio en el equipo."
	exit 1
}
