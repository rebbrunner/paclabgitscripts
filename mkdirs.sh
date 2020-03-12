mkdir test && cd test && git init
echo "Hello World" > README.md && git add . && git commit -m "Initial commit"
echo "print('Hello World')" > src/main.py && git add . && git commit -m "Second commit"
echo "data/" > .gitignore && git add . && git commit -m "Third commit"
