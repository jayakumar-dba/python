# ============================================================
#  deploy.ps1  -  Deploy Python app to AWS Docker container
#  Uses GitHub repo for code delivery (git clone / git pull)
#  Requirements: PuTTY tools (plink) installed and in PATH
#  PuTTY download: https://www.putty.org/
# ============================================================

$SERVER_IP   = "52.66.249.154"
$REMOTE_USER = "ubuntu"
$PPK_KEY     = "C:\Users\admin\Downloads\key_upuntu.ppk"
$REMOTE_DIR  = "/home/ubuntu/jay"
$GITHUB_REPO = "https://github.com/jayakumar-dba/python.git"
$IMAGE_NAME  = "jay-python-app"
$CONTAINER   = "jay-python-container"
$HOST_PORT   = "80"
$APP_PORT    = "5000"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Deploying Python App to AWS Docker Container"      -ForegroundColor Cyan
Write-Host " Source : $GITHUB_REPO"                             -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# ---- Step 1: Check plink ----
if (-not (Get-Command plink -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] 'plink' not found. Install PuTTY from https://www.putty.org/" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] plink found." -ForegroundColor Green

# ---- Step 2: Ensure git is installed on server ----
Write-Host "`n[1/5] Ensuring git is installed on server ..." -ForegroundColor Yellow
plink -i $PPK_KEY -batch "$REMOTE_USER@$SERVER_IP" `
    "which git > /dev/null 2>&1 || sudo apt-get install -y git"

# ---- Step 3: Clone or Pull latest code from GitHub ----
Write-Host "[2/5] Syncing code from GitHub to $REMOTE_DIR ..." -ForegroundColor Yellow
plink -i $PPK_KEY -batch "$REMOTE_USER@$SERVER_IP" @"
if [ -d "$REMOTE_DIR/.git" ]; then
    echo ">>> Pulling latest changes..."
    cd $REMOTE_DIR && git pull origin main
else
    echo ">>> Cloning repository..."
    git clone $GITHUB_REPO $REMOTE_DIR
fi
"@
Write-Host "[OK] Code synced from GitHub." -ForegroundColor Green

# ---- Step 4: Build Docker image ----
Write-Host "[3/5] Building Docker image '$IMAGE_NAME' on server ..." -ForegroundColor Yellow
plink -i $PPK_KEY -batch "$REMOTE_USER@$SERVER_IP" `
    "cd $REMOTE_DIR && sudo docker build -t $IMAGE_NAME ."
Write-Host "[OK] Docker image built." -ForegroundColor Green

# ---- Step 5: Stop & remove existing container (if any) ----
Write-Host "[4/5] Removing old container (if exists) ..." -ForegroundColor Yellow
plink -i $PPK_KEY -batch "$REMOTE_USER@$SERVER_IP" `
    "sudo docker rm -f $CONTAINER 2>/dev/null || true"

# ---- Step 6: Run new container ----
Write-Host "[5/5] Starting container '$CONTAINER' on port $HOST_PORT ..." -ForegroundColor Yellow
plink -i $PPK_KEY -batch "$REMOTE_USER@$SERVER_IP" `
    "sudo docker run -d --name $CONTAINER --restart always -p ${HOST_PORT}:${APP_PORT} $IMAGE_NAME"
Write-Host "[OK] Container started." -ForegroundColor Green

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " ✅ Deployment Complete!"                             -ForegroundColor Green
Write-Host "    App URL  : http://$SERVER_IP"                    -ForegroundColor White
Write-Host "    API Info : http://$SERVER_IP/api/info"           -ForegroundColor White
Write-Host "    Health   : http://$SERVER_IP/health"             -ForegroundColor White
Write-Host "==================================================" -ForegroundColor Cyan
