#First arg is path to where you want to deploy
#creates a work tree free of everything except what's necessary to run the game

 mkdir -p \
    $1/_maps \
    $1/config \
    $1/goon \
    $1/strings \

 if [ -d ".git" ]; then
  # Control will enter here if $DIRECTORY exists.
  mkdir -p $1/.git/logs
  cp -r .git/logs/* $1/.git/logs/
fi

 cp paradise.dmb paradise.rsc rust_g.dll $1/
cp -r _maps/* $1/_maps/
cp -r config/* $1/config/
cp -r goon/* $1/goon/
cp -r config/example/* $1/config/
cp -r strings/* $1/strings/