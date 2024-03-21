//열거타입 정의
enum Status {login, logout}



void main() {
  var authStatus = Status.login;
  //컬렉션
  //List
  List<String> items = ['밥','라면','빵'];
  //스프레드 연산자
  var items3 = ['떡볶이',items,'튀김'];
  var items2 = ['모니터','마우스','키보드'];
  items[0] = '스피커';

  final num = [1, 2, 3, 4, 5];
  final myNum = [num, 6, 7];
  print('num의 크기는 ${num.length}');
  print('myNum의 크기는 ${myNum.length}');
  print(myNum);


  print(items.length);
  print(items[2]);
  // print(items[3]);

  //dynamic 모든 타입 대변
  List<dynamic> list = [1, 2, 5, '밥'];
  print(list[3]);
  print(list.length);


  switch (authStatus) {
    case Status.login:
      print('로그인');
      break;
    case Status.logout: //열거타입 정의에 있으므로 없으면 에러
      print('로그아웃');
      break;
  }
}

