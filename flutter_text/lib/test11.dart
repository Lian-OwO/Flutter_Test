//함수형
void greeting(String text){
  print(text);
}

//something() 함수는 인수로 Function이라는 특수한 클래스의 인스턴스를 받음
//Function은 다트에서 함수를 매개변수로 전달할때 사용
//something() 함수는 내부에서 14가 매개변수로 전달된 f() 함수로 리턴하고, f() 함수는 익명함수
void something(Function(int i)f){
  f(14);
}

void printFunction(int i){
  print('만든 함수에서 출력한 $i');
}

void main(){
  var f = greeting; //함수를 다른 변수에 대입 가능
  f('hello');
  something((value){
    print(value);
  });

  something((i) => printFunction(i));
  something(printFunction);
  //둘은 동일한 결과값임
  something((i) => print(i)); // 14
  something(print); //14

}