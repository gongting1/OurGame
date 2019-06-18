import Felgo 3.0
import QtQuick 2.0

GameWindow {
  id: gameWindow

  activeScene: scene

  screenWidth: 640
  screenHeight: 960

  onSplashScreenFinished: scene.startGame()
  //onSplashScreenFinished：scene.startGame（）行将在Felgo启动画面消失后触发第一次初始化

  EntityManager{
      id: entityManager
      entityContainer: gameArea
  }

  // 自定义字体加载的ttf字体
  FontLoader {
     id: gameFont
     source: "../assets/fonts/akaDylan Plain.ttf"
  }

  Scene {
    id: scene

    // “逻辑大小” - 场景内容自动缩放以匹配GameWindow大小
    width: 320
    height: 480

    // property to hold game score
    property int score

    // background image
    BackgroundImage {
        width: 330
        height: 560
      source: "../assets/JuicyBackground.png"
      anchors.centerIn: scene.gameWindowAnchorItem
    }

    // display score
    Text {
      // set font
      font.family: gameFont.name
      font.pixelSize: 12
      color: "red"
      text: scene.score

      // set position
      anchors.horizontalCenter: parent.horizontalCenter
      y: 446
    }

    GameArea{
        id:gameArea
        anchors.horizontalCenter: scene.horizontalCenter
        blockSize: 30
        y:20
        onGameOver: gameOverWindow.show()
    }

    GameOverWindow{
        id:gameOverWindow
        y:90
        opacity: 0
        anchors.horizontalCenter: scene.horizontalCenter
        onNewGameClicked: scene.startGame()
    }

    function startGame(){
        gameOverWindow.hide()
        gameArea.initializeField()
        scene.score = 0
    }
  }
}
