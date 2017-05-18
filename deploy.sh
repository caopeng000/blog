hexo generate
cp -R public/* deploy/caopeng000.github.io
cd deploy/caopeng000.github.io
git add -A
git commit -m ¡°update¡±
git push origin master