
if "%1"=="" goto :done
git status
git add .
git commit -m %1
git pull
git status
git commit -m "merge"
git push

:done
echo No parameter. Please enter the commit message and retry