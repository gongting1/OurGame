import QtQuick 2.0
import Felgo 3.0

//主要思想是将每个块设置为一个独立的实体，知道它在网格上的位置及其类型。根据type属性的值，我们只显示不同
//的水果图像。为了听取播放器对水果的点击，我们添加了一个覆盖整个项目的MouseArea。只要单击一个块，它就
//会发出一个包含所有相关信息的信号。这样我们可以方便地使用单个函数来处理来自游戏中所有块的点击信号。此外，
//我们直接知道点击发生在哪个网格位置以及该位置处的水果类型。
//现在已经准备好创建并添加到游戏中，但我们需要大量的游戏逻辑和网格计算。我们不希望将所有这些直接放在我们
//的游戏场景中。为了更好地分离代码和明确组件的责任，我们将创建一个额外的项目GameArea.qml来保存水果
//网格和所有必要的计算。

Item {
    id: gameArea

    width: blockSize * 8
    height: blockSize * 12

    property double blockSize//每一块的高度长度
    property int rows: Math.floor(height/blockSize)//保存了一列有多少个(总的行数)
    property int columns: Math.floor(width/blockSize)//保存了一行有多少个(总的列数)
    property var field:[]


    //增加游戏难度的属性
    property int maxTypes
    property int clicks


    signal gameOver()

    function index(row, column){
        return row * columns + column
    }

    function initializeField(){

        gameArea.clicks=0
        gameArea.maxTypes=3

        clearField()

        for(var i=0; i<rows; i++){
            for(var j=0; j<columns; j++){
                gameArea.field[index(i, j)] = createBlock(i, j)
            }
        }
    }

    function clearField(){
        for(var i=0; i<gameArea.field.length;i++){
            var block = gameArea.field[i]
            if(block !== null){
                entityManager.removeEntityById(block.entityId)
            }
        }
        gameArea.field = []
    }

    function createBlock(row, column){
        var entityProperties = {
            width: blockSize,
            height: blockSize,
            x: column * blockSize,
            y: row * blockSize,
            type: Math.floor(Math.random()*gameArea.maxTypes),//只有5种水果
            row: row,
            column: column
        }
        var id = entityManager.createEntityFromUrlWithProperties(Qt.resolvedUrl("Block.qml"), entityProperties)//从给定的entityUrl创建实体并返回所创建实体的entityId。 entityUrl必须是实体的完整路径，因此请使用Qt.resolvedUrl（）。

        var entity = entityManager.getEntityById(id)
        entity.clicked.connect(handleClick)//实体的点击信号链接到handleClick函数

        return entity
    }

    function handleClick(row, column, type){
        if(!isFieldReadyForNewBlockRemoval())
            return
        var fieldCopy = field.slice()
        //field是一个数组,slice()是该数组所有的元素，slice(2)是从第二个元素开始到结束，slice(2, 5)是第2个元素到第5个元素。（从0开始计数）
        var blockCount = getNumberOfConnectedBlocks(fieldCopy, row, column, type)
        if(blockCount >= 3){
            removeConnectedBlocks(fieldCopy)
            //现在我们想要在每次移除组时向下移动更高的块并创建新的果实。 我们为此目的使用了一个新函数moveBlocksToBottom。 删除一组块后，将在我们的clicked-handler中调用此函数。 此外，我们还计算并增加玩家得分以完成我们的处理程序功能。
            moveBlocksToBottom(fieldCopy)

            var score = blockCount*(blockCount+1)/2
            scene.score += score

            if(isGameOver())
                gameOver()

            gameArea.clicks++
            if((gameArea.maxTypes<5)&&(gameArea.clicks%10==0))
                gameArea.maxTypes++
        }
        //我们定义了两个新属性maxTypes和click来保存当前可用类型的数量以及玩家成功移动的次数。 我们每次初始化字段时都会重置这些属性。 然后，新块的随机类型基于maxTypes属性。 在每次成功移动玩家之后，我们会增加点击计数器，并在此基础上增加最大类型数量。 我们决定从只有三种水果类型开始，并在每第10次成功移动后添加一种新类型，直到我们达到最大类型数量。
    }

    //递归检查一个块及其邻居
    //返回已连接块的数量
    function getNumberOfConnectedBlocks(fieldCopy, row, column, type){
        if(row >= rows||column >= columns||row < 0|| column < 0)
            return 0
        var block = fieldCopy[index(row, column)]

        if(block === null)
            return 0

        if(block.type !== type)     //?
            return 0

        var count = 1//    //块具有所需类型，之前未检查过

        //从字段副本中删除块，以便我们不能再次检查它
        //在我们完成搜索之后，我们找到的每个正确的块都会在其中留下空值
        //在字段副本中的位置，然后我们使用它来删除实际字段数组中的块
        fieldCopy[index(row, column)] = null


        //检查当前块的所有邻居并累计连接块的数量
        //此时函数使用不同的参数调用自身
        //这个原理在编程中被称为“递归”
        //每次调用都会导致函数再次调用自己，直到其中一个调用
        //检查上面立即返回0（例如越界，不同的块类型，......）
        count += getNumberOfConnectedBlocks(fieldCopy, row+1, column, type)
        count += getNumberOfConnectedBlocks(fieldCopy, row, column+1, type)
        count += getNumberOfConnectedBlocks(fieldCopy, row-1, column, type)
        count += getNumberOfConnectedBlocks(fieldCopy, row, column-1, type)

        //返回已连接块的数量
        return count
    }

    //删除以前标记的块
    function removeConnectedBlocks(fieldCopy){
        for(var i=0; i<fieldCopy.length; i++){
            if(fieldCopy[i] === null){
                var block = gameArea.field[i]
                if(block !== null){
                    gameArea.field[i] = null
//                    entityManager.removeEntityById(block.entityId)
                    block.remove()
                }
            }
        }
    }

    //将剩余的块移动到底部，并用新块填充列
    function moveBlocksToBottom(){
        for(var col = 0; col<columns; col++){
            for(var row = rows-1; row >= 0; row--){
                if(gameArea.field[index(row, col)] === null){
                    var moveBlock = null
                    for(var moveRow = row-1; moveRow >= 0; moveRow--){
                        //检测到空的block则，将上面的行逐行向下移
                        moveBlock = gameArea.field[index(moveRow, col)]
                        if(moveBlock !==null){
                            gameArea.field[index(moveRow, col)] =null
                            gameArea.field[index(row, col)] = moveBlock
                            moveBlock.row = row
                            moveBlock.fallDown(row-moveRow)
//                            moveBlock.y = row*gameArea.blockSize
                            break
                        }
                    }
                    if(moveBlock === null){
                        var distance = row+1
                        for(var newRow = row; newRow>=0;newRow--){
                            var newBlock = createBlock(newRow-distance, col)
    gameArea.field[index(newRow, col)]=newBlock
                            newBlock.row = newRow
                            newBlock.fallDown(distance)
//                            newBlock.y = newRow*gameArea.blockSize
                        }
                        break
                    }
                }
            }
        }
    }

    function isGameOver(){
        var gameOver = true

        var fieldCopy = field.slice()

        for(var row = 0; row<rows; row++){
            for(var col = 0; col<columns; col++){
                var block = fieldCopy[index(row,col)]
                if(block !== null){
                    var blockCount = getNumberOfConnectedBlocks(fieldCopy, row, col, block.type)

                    if(blockCount>=3){
                        gameOver = false
                        break
                    }
                }
            }
        }
        return gameOver
    }

    function isFieldReadyForNewBlockRemoval(){
        for(var col = 0; col < columns; col++){
            var block = field[index(0, col)]
            if(block === null||block.y<0)
                return false
        }
        return true
    }
}
