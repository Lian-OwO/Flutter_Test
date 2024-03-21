//최상위 함수
bool isEven(int number){
  return number % 2 == 0;
}

void main(){
  print(isEven(10));

  var myClass = MyClass();
  print(myClass.isEven2(9));



  Person person = Person('ㅁㄴㅇ', age: 10);
  person.greeting();
}

class MyClass {
  //메서드
  bool isEven2(int number) {
    return number % 2 == 0;
  }
}

class Person{
  String name;
  int? age;
  Person(this.name, {this.age});

  void greeting(){
    print('ㅎㅇㅎㅇ $name임');
  }
}

