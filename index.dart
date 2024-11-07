import 'dart:io';
import 'dart:math';

// Character 클래스 정의
class Character {
  String name;
  int health;
  int attack;
  int defense;

  Character(this.name, this.health, this.attack, this.defense);

  // 공격 메서드
  void attackMonster(Monster monster) {
    int damage = max(0, attack - monster.defense);
    monster.health -= damage;

    print('$name의 턴 \n$name이(가)  ${monster.name}에게 $damage의 데미지를 입혔습니다.');
  }

  // 방어 메서드
  void defend() {
    health += defense;
    print('$name이(가) 방어 태세를 취하여 $defense만큼 체력을 얻었습니다.');
  }

  // 상태 출력 메서드
  void showStatus() {
    print('캐릭터: $name | 체력: $health | 공격력: $attack | 방어력: $defense');
  }
}

// Monster 클래스 정의
class Monster {
  String name;
  int health;
  int maxAttack;
  int defense = 0;

  Monster(this.name, this.health, this.maxAttack);

  // 공격 메서드
  void attackCharacter(Character character) {
    int monsterAttack = max(character.defense, Random().nextInt(maxAttack) + 1);
    int damage = max(0, monsterAttack - character.defense);
    character.health -= damage;

    print('$name이(가) ${character.name}에게 $damage의 데미지를 입혔습니다.');
  }

  // 상태 출력 메서드
  void showStatus() {
    print('몬스터: $name | 체력: $health | 공격력: $maxAttack');
  }
}

// Game 클래스 정의
class Game {
  Character character;
  List<Monster> monsters;
  int defeatedMonsters = 0;

  Game(this.character, this.monsters);

  // 게임 시작 메서드
  void startGame() {
    print('게임 시작!');

    while (character.health > 0 && defeatedMonsters < monsters.length) {
      Monster monster = getRandomMonster();
      bool continueBattle = battle(monster);
      if (!continueBattle) break;
    }

    // 게임 결과 저장 여부 확인
    endGame();
  }

  // 전투 메서드
  bool battle(Monster monster) {
    while (character.health > 0 && monster.health > 0) {
      character.showStatus();
      monster.showStatus();

      // 행동 선택
      print('행동을 선택하세요 (1: 공격, 2: 방어): ');
      String? choice = stdin.readLineSync();

      if (choice == '1') {
        character.attackMonster(monster);
      } else if (choice == '2') {
        character.defend();
      } else {
        print('Invalid choice, try again.');
        continue;
      }

      if (monster.health > 0) {
        monster.attackCharacter(character);
      }

      if (character.health <= 0) {
        print('You have been defeated by ${monster.name}. Game over!');
        return false;
      } else if (monster.health <= 0) {
        print('${monster.name}를 물리쳤습니다!');
        defeatedMonsters++;
        monsters.remove(monster);

        if (defeatedMonsters < monsters.length) {
          print('다음 몬스터와 싸우시겠습니까? (y/n): ');
          String? next = stdin.readLineSync();
          return next?.toLowerCase() == 'y';
        }
      }
    }
    return false;
  }

  // 랜덤 몬스터 반환 메서드
  Monster getRandomMonster() {
    return monsters[Random().nextInt(monsters.length)];
  }

  // 게임 종료 메서드
  void endGame() {
    print('결과를 저장하시겠습니까? (y/n): ');
    String? save = stdin.readLineSync();
    if (save?.toLowerCase() == 'y') {
      saveResult();
    }
  }

  // 결과 저장 메서드
  void saveResult() {
    String result = character.health > 0 ? 'Victory' : 'Defeat';
    String content =
        'Character: ${character.name}\nHealth: ${character.health}\nResult: $result';
    File('result.txt').writeAsStringSync(content);
    print('result.txt 파일에 게임이 저장 되었습니다.');
  }
}

// 캐릭터 이름 입력 받기 함수
String getCharacterName() {
  print('캐릭터의 이름을 입력하세요: ');
  String? name = stdin.readLineSync();

  if (name == null ||
      name.isEmpty ||
      !RegExp(r'^[a-zA-Z가-힣]+$').hasMatch(name)) {
    print('Invalid name. Please enter a valid name with only letters.');
    return getCharacterName();
  }
  return name;
}

// 캐릭터 로드 함수
Character loadCharacterStats() {
  try {
    final file = File('characters.txt');
    final contents = file.readAsStringSync();
    final stats = contents.split(',');

    if (stats.length != 3) throw FormatException('Invalid character data');
    int health = int.parse(stats[0]);
    int attack = int.parse(stats[1]);
    int defense = int.parse(stats[2]);
    String name = getCharacterName();

    return Character(name, health, attack, defense);
  } catch (e) {
    print('캐릭터를 불러오는데 실패했습니다: $e');
    exit(1);
  }
}

// 몬스터 로드 함수
List<Monster> loadMonsterStats() {
  List<Monster> monsters = [];
  try {
    final file = File('monsters.txt');
    final lines = file.readAsLinesSync();

    for (var line in lines) {
      final stats = line.split(',');
      if (stats.length != 3) throw FormatException('Invalid monster data');

      String name = stats[0];
      int health = int.parse(stats[1]);
      int maxAttack = int.parse(stats[2]);

      monsters.add(Monster(name, health, maxAttack));
    }
  } catch (e) {
    print('캐릭터를 불러오는데 실패했습니다: $e');
    exit(1);
  }
  return monsters;
}

void main() {
  Character character = loadCharacterStats();
  List<Monster> monsters = loadMonsterStats();
  Game game = Game(character, monsters);

  game.startGame();
}
