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

  test('Should parse empty bullet', () {
    String line = "* This is a header\n*";
    OrgConverter converter = new OrgConverter();

    List<Bullet> bullets = converter.parseFromString(line);

    expect(bullets.first.title, "This is a header");
    expect(bullets.first.isTodo, false);
    expect(bullets[1].title, "");
  });

  test('Should stringify empty bullet', () {
    Bullet bullet1 = Bullet.create("Heading1", false,1);
    bullet1.isTodo = false;
    Bullet bullet2 = Bullet.create("", false,1);
    bullet2.isTodo = false;
    List<Bullet> list = List<Bullet>();
    list.add(bullet1);
    list.add(bullet2);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* Heading1\n*");
  });

  test('Should parse primary bullet with higher level', () {
    int level = 10;
    String line ="*"*level+" This is a header";
    OrgConverter converter = new OrgConverter();

    List<Bullet> bullets = converter.parseFromString(line);

    expect(bullets.first.title, "This is a header");
    expect(bullets.first.isTodo, false);
    expect(bullets.first.level, 10);
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
    Bullet bullet = Bullet.create("Heading1", false,1);
    bullet.isTodo = false;
    List<Bullet> list = List<Bullet>();
    list.add(bullet);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* Heading1");
  });

  test('Should stringify primary bullet with higher level', () {
    int level = 10;
    Bullet bullet = Bullet.create("Heading1", false,level);
    bullet.isTodo = false;
    List<Bullet> list = List<Bullet>();
    list.add(bullet);

    OrgConverter converter = new OrgConverter();
    expect(converter.bulletsToString(list) ,"*"*level+" Heading1");
  });

  test('Should stringify TODO state', () {
    Bullet bullet = Bullet.create("Heading1", false,1);
    bullet.isTodo = true;
    List<Bullet> list = List<Bullet>();
    list.add(bullet);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* TODO Heading1");
  });

  test('Should stringify DONE state', () {
    Bullet bullet = Bullet.create("Heading1", true,1);
    bullet.isTodo = true;
    List<Bullet> list = List<Bullet>();
    list.add(bullet);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* DONE Heading1");
  });


  test('Should parse bullet with description', () {
    String line = "* This is a header\nthis is a description";

    OrgConverter converter = new OrgConverter();

    List<Bullet> bullets = converter.parseFromString(line);

    expect(bullets.first.title, "This is a header");
    expect(bullets.first.description, "this is a description");
    expect(bullets.first.isTodo, false);
  });

  test('Should stringify heading with description', () {
    Bullet bullet = Bullet.create("Header1", false,1);
    bullet.isTodo = true;
    bullet.description = "with description";
    List<Bullet> list = List<Bullet>();
    list.add(bullet);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* TODO Header1\nwith description");
  });

  test('Should stringify two bullets of the same hierachy with multiline', () {
    Bullet bullet1 = Bullet.create("Header1 \notherThings", false,1);
    bullet1.isTodo = true;

    Bullet bullet2 = Bullet.create("Header2 \notherThings", false,1);
    bullet2.isTodo = true;

    List<Bullet> list = List<Bullet>();
    list.add(bullet1);
    list.add(bullet2);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* TODO Header1 \notherThings\n* TODO Header2 \notherThings");
  });

  test('Should parse two bullets of the same hierachy with description', () {
    String line = "* This is a header 1 \nwith description\n* This is a header 2 \nwith description";

    OrgConverter converter = new OrgConverter();

    List<Bullet> bullets = converter.parseFromString(line);

    expect(bullets.first.title, "This is a header 1");
    expect(bullets.first.description, "with description");
    expect(bullets.first.isTodo, false);
    expect(bullets[1].title, "This is a header 2");
    expect(bullets[1].description, "with description");
    expect(bullets[1].isTodo, false);
  });

  test('Should stringify heading with increasing/decreasing hierachies', () {
    Bullet bullet1 = Bullet.create("Header1 \notherThings", false,1);
    bullet1.isTodo = true;
    Bullet bullet2 = Bullet.create("Header2 \notherThings", false,2);
    bullet2.isTodo = true;
    Bullet bullet3 = Bullet.create("Header3 \notherThings", false,1);
    bullet3.isTodo = true;
    List<Bullet> list = List<Bullet>();
    list.add(bullet1);
    list.add(bullet2);
    list.add(bullet3);

    OrgConverter converter = new OrgConverter();

    expect(converter.bulletsToString(list) , "* TODO Header1 \notherThings\n** TODO Header2 \notherThings\n* TODO Header3 \notherThings");
  });




}
