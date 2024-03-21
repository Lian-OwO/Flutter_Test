import 'person.dart';
import 'Rectangle.dart';

//게터 세터
void main(){
  var person = Person(); //기본 생성자
  var person2 = Person(name:'순심', age: 9);// 호출가능

  var person3 = Person3();
  print(person3.age); //_age값 출력


  var rect = Rectangle(5, 5, 5, 5);

  print(rect.right);
  rect.right = 12;
  print(rect.left);
}


class Person{
  String? name;
  int? age;
  Person({this.name, this.age}); //생성자
}