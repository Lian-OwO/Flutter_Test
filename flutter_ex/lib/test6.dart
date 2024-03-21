void main() {
  var person = Person();
  person.initialize('순심이', 9);

  print(person.name);
  print(person.age);
  print('${person.age}살');

  var person2 = Person2('순심이', 9);
  print(person2.age);
}

class Person {
  late String name;
  late int age;

  void initialize(String newName, int newAge) {
    name = newName;
    age = newAge;
  }

  void addOneYear() {
    age++;
  }
}

// 겟셋
class Person2 {
  late String name;
  late int _age;

  // 생성자를 통해 초기화
  Person2(String newName, int newAge) : name = newName, _age = newAge;

  // 세터 추가
  set age(int value) {
    if (value >= 0) {
      _age = value;
    } else {
      print('나이는 음수일 수 없습니다.');
    }
  }

  // 게터
  int get age => _age;
}
