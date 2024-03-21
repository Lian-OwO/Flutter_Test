void main(){
  var status = Status.Authenticating;

  switch(status){
    case Status.Authenticated:
      print('인증됨');
      break;
    case Status.Authenticating:
      print('인증 처리 중');
      break;
    case Status.Unauthenticated:
      print('미인증');
      break;
    case Status.Uninitialized:
      print('초기화됨');
      break;
  }


  var items = ['밥', '라면', '빵'];
  for (var i = 2; i < items.length; i++){
    print(items[i]);
  }

}

enum Status{Uninitialized, Authenticated, Authenticating, Unauthenticated}