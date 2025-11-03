Write-Host "Building Flutter web app..."
flutter build web --release --base-href "/trackit/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed. Please check for errors."
    exit 1
}

Write-Host "Deploying to GitHub Pages..."

# Create orphan commit and push
Set-Location build/web
git init
git add .
git commit -m "Deploy: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git push https://github.com/shadhin7/trackit.git HEAD:gh-pages --force
Set-Location ../..

Write-Host "Deployment successful!"
Write-Host "Visit your site at: https://shadhin7.github.io/trackit/"