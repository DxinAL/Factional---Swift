//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
//首先我们定义两种类型
typealias Distance = Double

struct Positon{
    var x :Double;
    var y:Double;
}
//检测一个点是否在允许范围之内 ,返回bool类型.
extension Positon {
    func inRange(range:Distance) -> Bool {
        return sqrt(x*x + y*y)<=range;//外部传入允许范围。
    }
    
    //这个函数用来计算目标的坐标
    func minus(p:Positon) ->Positon{
        return Positon(x:x-p.x,y:y-p.y);
    }
    
    //然后 计算两个position之间的距离
    var length:Double{
        return sqrt(x * x + y * y);
    }
    
}

//船只都有自己的位置。可以定义一个船只的结构体
struct Ship{
    var position:Positon
    var firingRange:Distance
    var unsafeRange:Distance
}

//定义一个函数，用来检验是否有另一艘 船在范围内，不论我们是位于原点还是其他的位置
extension Ship{
    //检验一个船是否在设计范围之内
    func canEngageShip(target:Ship,friendly:Ship ) -> Bool {
        let   friendlyDistance = friendly.position.minus(p: target.position).length;
        let targetDistance = target.position.minus(p: position).length;
        return targetDistance <= firingRange && targetDistance>=unsafeRange&&targetDistance<=friendlyDistance;
    }
}



//以上代码完成了可以检测一个环形区域，可以检测在设计范围之内但是在非安全区域之外的船只
//为了避免友方船只离我们过近
//需求增多代码会越来越难以维护，在函数中包含了一大段计算的代码，我们可以在Position 中添加两个负责集合运算的额函数，让这段代码变得清晰易懂
/////////////////////////////////////////////////////
//用一种声明式的方式来说明
//更加模块化的结局方案
//func pointInRange(position:Positon) ->Bool  我们归根结底是要定义一个函数来判断一个点是否在范围内，
//单独定义一种类型
typealias Region  = (Positon) ->Bool
//region指代一个函数，region 类型是把Position转化成bool的函数，指定一个点就可以知道在不在某个范围之内，这个类型就是Region,他是一个函数
/*
  函数式编程核心理念就是韩式是值，他和结构体、bool值一样没有什么区别，所以要把他当多对象一样去命名，而不是以说明他的功能的方法去命名
 */
//一下几个函数式用来控制、合并、创建目标区域的
func circle(radius:Distance) ->Region{
    return {point in point.length <= radius};
} //这个函数返回一个区域,这是圆心在原点发射区域
//并非所有的圆是圆心在原点，需要定义任意位置的圆，函数多了一个圆心参数

func  circle2(radius:Distance,center:Positon) ->Region{
    //返回的是一个范围
    return {point in point.minus(p: center).length<=radius};
}

func shift(region:@escaping Region,offset:Positon) ->Region{
    return{point in region(point.minus(p: offset))}
}

//函数式的核心思想是：为了避免出现过于复杂的函数，扣去构造新的函数去改变另一个函数
shift(region: circle(radius: 10), offset: Positon(x:5,y:5));

//翻转区域以获得另一个区域
func invert(region:@escaping Region)->Region{
    return {point in !region(point)}
}

//可以计算交集和并集
func intersection(region1:@escaping Region, _region2:@escaping Region) ->Region{
    return {point in region1(point) && _region2(point)}
}

func union(region:@escaping Region, _region2:@escaping Region) ->Region{
    return {point in region(point) || _region2(point)}
}

//定义一个区域，函数传入两个区域，返回一个区域在第一个区域且不再第二个区域中
func  difference(region:@escaping Region,minus:@escaping Region) ->Region{
  return  intersection(region1: region, _region2: invert(region: minus))
}


//重构canSafelyEngageShip函数
extension Ship{
    func canSafelyEngageShip(target:Ship,friendly:Ship) -> Bool {
        //这一步获得的是再原点的船的环形区域
        let rangRegion  = difference(region: circle(radius: firingRange), minus: circle(radius: unsafeRange));
        //这是随着自身位置的移动，射击区域的变化
        let fireRange = shift(region: rangRegion, offset: position);
        //友方船只可以移动的范围
        let friendlyRange = shift(region: circle(radius: unsafeRange), offset: friendly.position);
        let resultRegion = difference(region: fireRange, minus: friendlyRange);
        return resultRegion(target.position);
    }
}

//所谓一等函数  就是闭包  ，就是 oc 中的block




















