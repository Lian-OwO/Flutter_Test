//for
void main(){
  final items = [1,2,3,4,5];
  for (var i = 0; i < items.length; i++){
    print(items[i]); // 1,2,3,4,5
  }

  items.forEach(print);
  items.forEach((e) {
    print('익명함수 $e');
  });

  //람다식
  items.forEach((e) => print(e));

// 짝수 출력
  for (var i = 0; i < items.length; i++) {
    if (items[i] % 2 == 0) {
      print('for, if 출력은 ${items[i]}');
    }
  }
  //where
  items.where((e) => e % 2 == 0).forEach((element) {
    print('where 출력은 $element');
  });

  //forEach를 이용한 리스트 변환
  final result = [];
  items.forEach((e){
    if (e % 2 == 0){
      result.add(e);
    }
  });
  print('forEach를 이용한 리스트 출력 $result');
  //toList()를 이용한 리스트 변환
  final result2 = items.where((e) => e % 2 == 0).toList();
  print(result2);


  //toSet
  final items2 = [1,2,2,3,3,4,5,];
  var result3 = [];
  for( var i = 0; i < items2.length; i++){
    if(items2[i] % 2 == 0){
      result3.add(items2[i]);
    }
  }
  print('result3 출력값 $result3');

  //toSet, where사용
  final result4 = items2.where((e) => e % 2 == 0).toList();
  print('result4 출력 $result4');

  var result5 = [];
  var temp = <int>{};
  for(var i = 0; i < items2.length; i++){
    if(items2[i] % 2 == 0){
      temp.add(items2[i]);
    }
  }
  result5 = temp.toList();
  print('result5 출력 $result5');

  final result6 = items2.where((e) => e % 2 == 0).toSet().toList();
  print('result6 출력 $result6');
}