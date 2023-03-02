<#
Busca un archivo por sha256 en un equipo
Nombre del archivo: search_sha256.ps1
Fecha: 24/02/2023
Autor: Sergio Torres
#>

cd "C:\" # Remplaza
$ext = "*.bat" # Remplaza
$Files = Get-ChildItem $ext -Recurse -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -InformationAction SilentlyContinue
$hash = "DCBC1F8D1D32EA44DD721CB3058264584507FB6F3BD7356" # Remplaza por sha256 del archivo buscado

ForEach ($File in $Files) {
    Get-FileHash $File -Algorithm SHA256 | Set-Variable -Name n
    if($n.Hash -eq $hash) {
        echo $n.Path
		    # Configura acciones en esta parte
		    # Puedes eliminar, copiar, renombrar, etc.
        sleep -seconds 1
    }
}
