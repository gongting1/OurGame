import Felgo 3.0
import QtQuick 2.0

//我们在游戏中有许多不同种类的水果，但在不同的外观下，它们共享相同的游戏逻辑。
//我们可以将它们视为具有不同视觉表示的单个游戏实体。只需在qml文件夹中创建一个新文件Block.qml，
EntityBase{
    id:block
    entityType: "block"

    //我们设置visible：y> = 0以隐藏将放置在游戏区域之外的新创建的水果,当动画将动画移动到游戏区域时，它们会自动显示。
    visible: y>=0

    property int type
    property int row
    property int column

    signal clicked(int row, int column, int type)

    //在移除之前淡出块
    NumberAnimation{
        id: fadeOutAnimation
        target: block
        property: "opacity"
        duration: 100
        from: 1.0
        to: 0

        //淡出完成后删除块
        onStopped:{
entityManager.removeEntityById(block.entityId)
        }
    }

    //动画让块掉下来
    NumberAnimation{
        id:fallDownAnimation
        target: block
        property: "y"
    }

    //定时器等待其他块淡出
    Timer{
        id:fallDownTimer
        interval: fadeOutAnimation.duration// 在任何块开始移动之前，它应该等待游戏中其他块的淡出。 为此，我们使用Timer并将淡出持续时间设置为其间隔。 在那段时间过去之后，我们将开始运动。
        //设置触发器之间的间隔，以毫秒为单位。默认时间间隔为1000毫秒。
        repeat: false//如果repeat为true，则以指定的间隔重复触发定时器; 否则，计时器将以指定的间隔触发一次然后停止（即运行将设置为假）。
        running: false//如果设置为true，则启动计时器; 否则停止计时器。 对于非重复计时器，在触发计时器后，运行设置为false。
        onTriggered:{
            fallDownAnimation.start()
        }
    }

    function remove(){
        fadeOutAnimation.start()
    }

    function fallDown(distance){
        fallDownAnimation.complete()
        fallDownAnimation.duration = 100*distance
        fallDownAnimation.to = block.y+distance*block.height
        fallDownTimer.start()
    }

    Image{
        anchors.fill: parent
        source: {
            if(type==0)
                return "../assets/Apple.png"
            else if(type==1)
                return "../assets/Banana.png"
            else if(type==2)
                return "../assets/Orange.png"
            else if(type==3)
                return "../assets/Pear.png"
            else if(type==4)
                return "../assets/BlueBerry.png"
        }
    }

    MouseArea{
        anchors.fill: parent
        onClicked: parent.clicked(row, column, type)
    }
}
