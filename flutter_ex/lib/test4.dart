void main(){
  //익명함수 짝수이면 true 홀수이면 false 반환
  var number = 1;
  var isEven = checkEven(number);
  print(isEven);

  something(name: '순심', age: 10);


  //if else
  String text = 'hello';
  if (text is int){
    print('정수');
  }else if(text is String){
    print('문자형');
  }else{
    print('정수도 실수도 아님');
  }

  //삼항연산
  var todo = isRainy ? '빨래 안함' : '빨래함';
  print(todo);
  
}

bool checkEven(int number){
  return number % 2 == 0;
}

//선택매개변수
//required 널 안정성 2.12부터 필수
void something({required String name, required int age}){
  print("안녕하세요, $name님! $age살이시군요.");
}

bool isRainy = false;