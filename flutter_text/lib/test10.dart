void main(){
  //Map
  var city = {
    'korea' : 'busan',
    'japan' : 'tokyo',
    'china' : 'basing'
  };

  city['korea'] = 'seoul';

  print(city.length);
  print(city['china']);
  print(city['america']);

  city['america'] = 'US';
  print(city['america']);


  //Set
  var citySet = {'seoul','soowon','osan','busan'};

  citySet.add('jinju');
  citySet.remove('soowon');

  print(citySet.contains('seoul'));
  print(citySet.contains('tokyo'));
}