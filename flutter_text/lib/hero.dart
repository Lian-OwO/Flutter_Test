class Hero{
  String name = 'hero';

  void run(){}
}

class SuperHero extends Hero{
  //Hero를 상속
  //부모의 run() 메서드를 다시 정의(오버라이드)
  @override
  void run(){
    super.run(); //부모의 run실행
    this.fly(); //추가로 fly도 실행
}
void fly(){}
}

void main(){
  var hero = SuperHero();
  hero.run();
  hero.fly();
  print(hero.name);
}