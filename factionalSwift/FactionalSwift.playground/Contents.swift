//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

/*
    swift函数式编程
    
    函数在swift 中是一等值，函数可以作为参数传递给其他的函数，也可以作为返回值？？？？
 
 */

//定义两种类型  distance  Position  定义了一种类型
typealias Distance  = Double
struct Position{
    var x :Distance
    var y :Distance
}
  //定义一个函数，检测一个点是否在某一个区域
extension Position{
    func minus(p:Position) -> Position {
        return Position(x:x-p.x ,y:y-p.y)
    }
    //距离
    var length :Double{
        return sqrt(x * x + y*y);
    }
    
    func inRange(range:Distance) -> Bool {
        return sqrt(x*x + y*y)<=range;
    }
}


//引入结构体ship ,他有个属性是position
struct Ship{
    var position:Position
    var firstRange:Distance
    var unsafeRange:Distance
}

//用于检测是否有船在范围内
extension Ship{
    func canEngageShip(target:Ship,friendly:Ship) -> Bool {
        let friendlyDistance = friendly.position.minus(p: position).length
        let targetDistance = target.position.minus(p: position).length;
        return targetDistance <= firstRange && targetDistance>unsafeRange && (friendlyDistance > unsafeRange);
    }
}

//声明一个函数，以更加声明式的方式来判断一个区域是否包含了某一个点
//Region指代将Positon转化为bool的函数 不是必须得，但是可以让我们更容易理解看到的一些类型
/*
    我们使用一个能判断给定点是否在给定的区域的函数来代表一个区域，而不是定义一个结构体来代表他，在swift中函数式一等值，函数式编程的核心理念是函数是值，和bool类型 结构体没有什么区别
 */
typealias Region = (Position) -> Bool //表示把Posion转化成bool类型的函数
func circle(radius:Distance) ->Region{
    return {point in point.length <= radius}; //这是一个闭包的省略写法，swift 可以根据上下文来推断参数的类型，
}

//传入一个距离和圆心的位置，就可以返回一个函数，这个函数的功能是判断船舶在不在范围内
func cycle2(radius:Distance,center:Position) -> Region{
    return { point in point.minus(p: center).length <= radius};
}

//写一个区域变换函数，这个函数按一定的偏移量移动一个区域
func shift(region:@escaping Region,offset:Position) ->Region{
    return {point in region(point.minus(p: offset))}
}

//pt表示一个区域，是一个函数，传入一个 点可以判断是不是在区域内部
let  pt:Region  =  shift(region: circle(radius: 10), offset: Position(x:5,y:5));

//可逃逸闭包
func invert(region:@escaping Region) ->Region{
    return {point in !region(point)}
}

//计算区域中两个区域中的交集
func intersection(region:@escaping Region, _region2:@escaping Region) ->Region{
    return {point in region(point) && _region2(point)}
}

//计算两个区域中的并集
func union (region1:@escaping Region, _region:@escaping Region) ->Region{
    return{point in region1(point)||_region(point)}
}

func difference(region:@escaping Region,minus:@escaping Region) ->Region{

    return intersection(region: region, _region2: minus);
}

/*swift 中计算和传递函数的方式与整形或布尔类型没有任何不同，这让我们能够写出 一些基础的图形组建，进而以这些组建为基础，来构建一系列的函数，每个函数都能修改或者合并区域，并且依此来创建新的区域，比起写复杂的函数来解决某些具体的问题，现在我们可以通过将一些小型函数装配起来，广泛的解决各种问题*/

//关于区域的小型的函数库已经准备就绪，我们可以重构canSafelyEngageShip这个函数
extension Ship{
    func canSafelyEngageShip(target:Ship,friendly:Ship) -> Bool {
        
        let rangeRegion = difference(region: circle(radius: firstRange), minus: circle(radius: unsafeRange));
        //攻击区域
        let firngRegion = shift(region: rangeRegion, offset: position)
        
        //友方船只
        let friendlyRegion = shift(region: circle(radius: unsafeRange), offset: friendly.position);
        
        //计算这两个区域的差集
        let resultRegion = difference(region: firngRegion, minus: friendlyRegion);
        return resultRegion(target.position);
    }
}




















