# -----------------------------------------------
# Helper: Check if a Helm repo exists
# -----------------------------------------------
function Add-HelmRepoIfMissing {
    param(
        [string]$Name,
        [string]$Url
    )

    $exists = helm repo list --output json | ConvertFrom-Json | Where-Object { $_.name -eq $Name }

    if ($exists) {
        Write-Host "Helm repo '$Name' already exists. Skipping."
    }
    else {
        Write-Host "Adding Helm repo '$Name'..."
        helm repo add $Name $Url
    }
}

# -----------------------------------------------
# Helper: Check if a Helm release exists
# -----------------------------------------------
function Install-HelmChartIfMissing {
    param(
        [string]$Release,
        [string]$Chart,
        [string]$Namespace = "",
        [string[]]$ExtraArgs = @()
    )

    $exists = helm list -A --output json | ConvertFrom-Json | Where-Object { $_.name -eq $Release }

    if ($exists) {
        Write-Host "Helm release '$Release' already installed. Skipping."
    }
    else {
        Write-Host "Installing Helm release '$Release'..."
        $nsArgs = @()
        if ($Namespace -ne "") {
            $nsArgs = @("--namespace", $Namespace, "--create-namespace")
        }
        Write-Host "helm install $Release $Chart $nsArgs $ExtraArgs"
        helm install $Release $Chart @nsArgs @ExtraArgs
    }
}

# -----------------------------------------------
# Helper: Apply CRDs only if not already present
# -----------------------------------------------
function Apply-CRDs-IfMissing {
    param(
        [string]$CrdUrl,
        [string]$CrdRegex,
        [string[]]$ExtraArgs = @()
    )

    # Count CRDs matching the regex
    $count = (
        kubectl get crd --no-headers 2>$null |
        Select-String -Pattern $CrdRegex |
        Measure-Object |
        Select -ExpandProperty Count
    )

    if ($count -gt 0) {
        Write-Host "CRDs matching '$CrdRegex' already exist ($count found). Skipping CRD apply."
    }
    else {
        Write-Host "Applying CRDs from $CrdUrl ..."
        kubectl apply -f $CrdUrl @ExtraArgs
    }
}

# ======================================================
# 1) Add required helm repos
# ======================================================

Add-HelmRepoIfMissing -Name "ingress-nginx" -Url "https://kubernetes.github.io/ingress-nginx"
Add-HelmRepoIfMissing -Name "mariadb-operator" -Url "https://helm.mariadb.com/mariadb-operator"
Add-HelmRepoIfMissing -Name "elastic" -Url "https://helm.elastic.co"

helm repo update

# ======================================================
# 2) Install ingress-nginx (if missing)
# ======================================================

Install-HelmChartIfMissing `
    -Release "ingress-nginx" `
    -Chart "ingress-nginx/ingress-nginx" `
    -Namespace "ingress-nginx"

# ======================================================
# 3) Install MariaDB operator CRDs + operator
# ======================================================

Install-HelmChartIfMissing `
    -Release "mariadb-operator-crds" `
    -Chart "mariadb-operator/mariadb-operator-crds"

Install-HelmChartIfMissing `
    -Release "mariadb-operator" `
    -Chart "mariadb-operator/mariadb-operator" `
    -Namespace "mariadb-operator"

# ======================================================
# 4) Install CloudNativePG CRDs + operator
# ======================================================

Apply-CRDs-IfMissing `
    -CrdUrl "https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.27/releases/cnpg-1.27.1.yaml" `
    -CrdRegex ".*\.postgresql\.cnpg\.io" `
    -ExtraArgs @("--server-side")

# ======================================================
# 5) Elastic ECK CRDs + operator
# ======================================================

Apply-CRDs-IfMissing `
    -CrdUrl "https://download.elastic.co/downloads/eck/3.2.0/crds.yaml" `
    -CrdRegex ".*\.k8s\.elastic\.co"

Install-HelmChartIfMissing `
    -Release "eck-operator" `
    -Chart "elastic/eck-operator" `
    -Namespace "elastic-operator" `
    -ExtraArgs @("--set", "installCRDs=false")
