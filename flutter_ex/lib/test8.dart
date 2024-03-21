//추상클래스
abstract class Monster{
  void attack();
}

class Goblin implements Monster{
  @override
  void attack(){
    print('attack');
  }
}

class Bee implements Monster{
  @override
  void attack(){
    print('niddle');
  }
}

abstract class Flyable{
  void fly();
}

class Bat implements Monster,Flyable{
  @override
  void attack(){
    print('claw');
  }
  @override
  void fly(){
    print('fly');
  }

}


void main(){
  var bat = Bat();
  bat.fly();
  var goblin = Goblin();
  goblin.attack();
  var bee = Bee();
  bee.attack();
}