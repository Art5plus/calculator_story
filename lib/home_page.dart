import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final firstController = TextEditingController();
  final secondController = TextEditingController();

  String resultText = 'Результат: —';
  final Box<String> historyBox = Hive.box<String>('history_box');

  void calculate(String operation) {
    final firstNumber = double.tryParse(firstController.text);
    final secondNumber = double.tryParse(secondController.text);

    if (firstNumber == null || secondNumber == null) {
      setState(() {
        resultText = 'Введите корректные числа';
      });
      return;
    }

    if (operation == '/' && secondNumber == 0) {
      setState(() {
        resultText = 'Ошибка: деление на 0';
      });
      return;
    }

    double result = 0;
    switch (operation) {
      case '+':
        result = firstNumber + secondNumber;
        break;
      case '-':
        result = firstNumber - secondNumber;
        break;
      case '*':
        result = firstNumber * secondNumber;
        break;
      case '/':
        result = firstNumber / secondNumber;
        break;
    }

    String formatNum(double num) =>
        (num % 1 == 0) ? num.toInt().toString() : num.toString();

    final formattedFirst = formatNum(firstNumber);
    final formattedSecond = formatNum(secondNumber);
    final formattedResult = formatNum(result);

    final historyEntry =
        '$formattedFirst $operation $formattedSecond = $formattedResult';

    historyBox.add(historyEntry);

    setState(() {
      resultText = 'Результат: $formattedResult';
    });
  }

  void _showHistoryModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'История вычислений',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ValueListenableBuilder(
                    valueListenable: historyBox.listenable(),
                    builder: (context, Box<String> box, _) {
                      if (box.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Очистить историю',
                        onPressed: () => box.clear(),
                      );
                    },
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: historyBox.listenable(),
                  builder: (context, Box<String> box, _) {
                    if (box.isEmpty) {
                      return const Center(
                        child: Text(
                          'История пуста',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    final items = box.values.toList().reversed.toList();

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.calculate_outlined),
                          title: Text(
                            items[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'История',
            onPressed: _showHistoryModal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: firstController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Первое число',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: secondController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Второе число',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              resultText,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => calculate('+'),
                  child: const Text('+'),
                ),
                ElevatedButton(
                  onPressed: () => calculate('-'),
                  child: const Text('-'),
                ),
                ElevatedButton(
                  onPressed: () => calculate('*'),
                  child: const Text('*'),
                ),
                ElevatedButton(
                  onPressed: () => calculate('/'),
                  child: const Text('/'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstController.dispose();
    secondController.dispose();
    super.dispose();
  }
}
