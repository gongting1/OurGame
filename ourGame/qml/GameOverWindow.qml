import QtQuick 2.0

Item {
    id:gameOverWindow

    width: 232
    height: 160

    //hide when opacity = 0
    visible: opacity>0

    enabled: opacity==1

    signal newGameClicked()

    Image{
        source: "../assets/GameOver.png"
        anchors.fill: parent
    }

    Text{
        //set font
        font.family: gameFont.name
        font.pixelSize: 30
        color: "#1a1a1a"
        text: scene.score

        //set position
        anchors.horizontalCenter: parent.horizontalCenter
        y: 72
    }

    //play again button
    Text{
        //set font
        font.family: gameFont.name
        font.pixelSize: 15
        color: "red"
        text: "play again"

        //set position
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 15

        //signal clicl event
        MouseArea{
            anchors.fill: parent
            onClicked: gameOverWindow.newGameClicked()
        }

        SequentialAnimation on color {
            loops: Animation.Infinite
            PropertyAnimation{
                to: "#ff8800"
                duration: 1000
            }
            PropertyAnimation{
                to:"red"
                duration: 1000
            }
        }
    }

    // fade in/out animation
    Behavior on opacity {
      NumberAnimation { duration: 400 }
    }

    function show(){
        gameOverWindow.opacity = 1
    }

    function hide(){
        gameOverWindow.opacity = 0
    }
}
