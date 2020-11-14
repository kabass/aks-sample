if %1=="" goto :error

git status
git add .
git commit -m %1
git pull
git status
git commit -m "merge"
git push
goto :done

:error
echo No parameter. Please enter the commit message and retry.

:done
echo done