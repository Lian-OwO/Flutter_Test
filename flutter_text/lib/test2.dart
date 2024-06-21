void main(){

  //타입 검사
  //같은 타입 is = true
  //다른 타입 is! = true
  int a = 10;
  print('정수');

  String text = 'hello';
  if(text is! int){
    print('숫자 아님');
  }

  //형변환 as
  var b = 10.5;
  // int d = b as int;
  num d = b;



  //함수
  var result = f(10);
  print(result);

  var result2 = g(10, 10);
  print(result2);

  var result3 = h();
  print(result3);


  greeting(String great){
    print('hello $great');
  }


  print('Hello');
  print(_name);


  print('$_name은 $_age살');
  print('$_name은 ${_name.length}글자');
}



int f(int x){
  return x + 10;
}

int g(int x, int z){
  return x + z + 10;
}

String h(){
  return 'ㅎㅇㅎㅇ';
}

String _name = '홍길동';
int _age = 20;