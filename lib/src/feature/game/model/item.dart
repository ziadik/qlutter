enum ItemColor { green, red, blue, yellow, purple, cyan, gray }

abstract class Item {
  Item(this.color);
  final ItemColor color;
}

class Block extends Item {
  Block() : super(ItemColor.gray);
}

class Ball extends Item {
  Ball(super.color);
}

class Hole extends Item {
  Hole(super.color);
}
