import 'dart:math';

void main(){

  //any
  final items = [1,2,2,3,3,4,5];

  var result = false;
  for ( var i = 0; i < items.length; i++){
    if(items[i] % 2 == 0 ){
      result = true;
      break;
    }
  }
  print('any result 출력 $result');

  print(items.any((e) => e % 2 == 0));

  //reduce
  final items2 = [1,2,3,4,5];

  var maxResult = items2[0];
  for ( var i = 1; i< items2.length; i++){
    maxResult = max(items2[i], maxResult);
  }
  print('maxResult의 값은 $maxResult');

  print(items2
      ..add(6)
      ..remove(2));
//컬렉션 if
  bool promoActive = false;
  if(promoActive){
    print([1,2,3,4,5,6]);
  }else{
    print([1,2,3,4,5]); //false라 출력
  }

//컬렉션 for
  var listOfInts = [1,2,3];
  var listOfStrings = [
    '#0',
    for(var i in listOfInts) '#$i'
  ];

  listOfStrings.forEach(print);

  String? name;
  print(name?.length);

  //null이 아니면 길이, null이면 0 반환
  print(0);
}

