Write-Host "Building Flutter web app..."
flutter build web --release --base-href "/expense_tracker/"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed. Please check for errors."
    exit 1
}

Write-Host "Deploying to GitHub Pages..."

$commitHash = git subtree split --prefix build/web main

# Properly construct the push command
$branchRef = "$commitHash`:gh-pages"

git push origin $branchRef --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "Deployment failed. Check git configuration."
    exit 1
}

Write-Host "Deployment successful!"
Write-Host "Visit your site at: https://shadhin7.github.io/expense_tracker/"
