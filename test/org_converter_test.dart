import 'package:flutter_test/flutter_test.dart';
import 'package:tudorg/bullet.dart';
import 'package:tudorg/org_converter.dart';

void main() {
  test('Should parse primary bullet', () {
    String line = "* This is a header";
    OrgConverter converter = new OrgConverter();

    List<Bullet> bullets = converter.parseFromString(line);

    expect(bullets.first.title, "This is a header");
    expect(bullets.first.isTodo, false);
  });

  test('Should parse TODO state', () {
    String line = "* TODO This is a header";

    OrgConverter converter = new OrgConverter();
    List<Bullet> bullets = converter.parseFromString(line);

    expect(bullets.first.isChecked, false);
    expect(bullets.first.isTodo, true);
  });

  test('Should parse DONE state', () {
    String line = "* DONE This is a header";
    OrgConverter converter = new OrgConverter();

    List<Bullet> bullets = converter.parseFromString(line);

    expect(bullets.first.isChecked, true);
    expect(bullets.first.isTodo, true);
  });

  test('Should stringify primary bullet', () {
    Bullet bullet = Bullet.create("Heading1", false);
    bullet.isTodo = false;
    List<Bullet> list = List<Bullet>();
    list.add(bullet);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* Heading1");
  });

  test('Should stringify TODO state', () {
    Bullet bullet = Bullet.create("Heading1", false);
    bullet.isTodo = true;
    List<Bullet> list = List<Bullet>();
    list.add(bullet);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* TODO Heading1");
  });

  test('Should stringify DONE state', () {
    Bullet bullet = Bullet.create("Heading1", true);
    bullet.isTodo = true;
    List<Bullet> list = List<Bullet>();
    list.add(bullet);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* DONE Heading1");
  });


  test('Should parse heading can be multiline', () { //TODO this will be description later
    String line = "* This is a header\nwith multiline";

    OrgConverter converter = new OrgConverter();

    List<Bullet> bullets = converter.parseFromString(line);

    expect(bullets.first.title, "This is a header\nwith multiline");
    expect(bullets.first.isTodo, false);
  });

  test('Should stringify heading can be multiline', () { //TODO this will be description later
    Bullet bullet = Bullet.create("Header1 \notherThings", false);
    bullet.isTodo = true;
    List<Bullet> list = List<Bullet>();
    list.add(bullet);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* TODO Header1 \notherThings");
  });

}
