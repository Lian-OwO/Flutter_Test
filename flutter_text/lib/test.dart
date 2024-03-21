void main(){
//var 타입추론
//일반적으로 타입을 명시하지 않고 var로 대체
  var i = 10;
  var d = 10.0;
  var s = 'hello';
  var s2 = 'hello';
  var b = true;
  var b2 = i < 10;
  var b3 = s.isEmpty;

  //assert 산술 연산 결과가 true가 아니면 에러가 출력
  assert(2+3 == 5);
  assert(5-2 == 3);
  assert(3 * 5 == 15);
  assert(5 / 2 == 2.5);
  assert(5 ~/ 2 == 2);
  assert(5 % 2 == 1);


  //증감
  var num = 0;
  print(num++); //후위연산으로 출력은 0 이후 +1
  print(++num); //전위연산으로 이전에 1이 되었으므로 2가 출력

  //비교연산
  assert(2 == 2);
  assert(2 != 3);
  assert(3 > 2);
  assert(2 < 3);
  assert(2 <= 3);


  print('&& 그리고');
  print(true && true);
  print(true && false);
  print(false && false);
  print('|| 또는');
  print(true || true);
  print(true || false);
  print(false || false);
  print('== 같다');
  print(true == true);
  print(true == false);
  print(false == false);
  print('! 부정 // != 다름');
  print(true != true);
  print(true != false);
  print(false != false);
}