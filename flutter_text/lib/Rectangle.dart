class Rectangle{
  num left, top, width, height;
  Rectangle(this.left,this.top,this.width, this.height);

  num get right => left + width; //right 게터
  set right(num value) => left = value - width; //right 세터
  num get bottom => top + height;
  set bottom(num value) => top = value - height;
}